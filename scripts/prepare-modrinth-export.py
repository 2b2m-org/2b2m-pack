#!/usr/bin/env python3
from __future__ import annotations

import argparse
import datetime as dt
import json
import shutil
import subprocess
import tempfile
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError as exc:
    raise SystemExit("Python 3.11+ is required for tomllib") from exc


MODRINTH_VERSION_FILES_URL = "https://api.modrinth.com/v2/version_files"
USER_AGENT = "2b2m-pack-export/1.0 (https://github.com/2b2m-org/2b2m-pack)"


def toml_str(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def rel(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def load_toml(path: Path) -> dict:
    with path.open("rb") as handle:
        return tomllib.load(handle)


def load_pack_version(repo_root: Path) -> str:
    pack = load_toml(repo_root / "pack.toml")
    version = pack.get("version")
    if not version:
        raise RuntimeError("Could not read version from pack.toml")
    return str(version)


def discover_mods(repo_root: Path) -> list[dict]:
    mods_dir = repo_root / "mods"
    entries: list[dict] = []

    for path in sorted(mods_dir.glob("*.pw.toml")):
        data = load_toml(path)
        download = data.get("download", {})
        update = data.get("update", {})
        curseforge = update.get("curseforge")
        modrinth = update.get("modrinth")
        hash_format = str(download.get("hash-format", "")).lower()
        digest = str(download.get("hash", "")).lower()

        entry = {
            "path": rel(repo_root, path),
            "name": data.get("name", path.stem),
            "filename": data.get("filename", ""),
            "side": data.get("side", "both"),
            "hash_format": hash_format,
            "hash": digest,
            "source": "unknown",
        }

        if curseforge:
            entry["source"] = "curseforge"
            entry["curseforge"] = {
                "project_id": curseforge.get("project-id"),
                "file_id": curseforge.get("file-id"),
            }
            if hash_format == "sha1" and digest:
                entry["sha1"] = digest
        elif modrinth:
            entry["source"] = "modrinth"
            entry["modrinth"] = {
                "project_id": modrinth.get("mod-id"),
                "version_id": modrinth.get("version"),
            }

        entries.append(entry)

    return entries


def chunks(values: list[str], size: int) -> list[list[str]]:
    return [values[index : index + size] for index in range(0, len(values), size)]


def query_modrinth_versions(sha1s: list[str]) -> dict[str, dict]:
    versions: dict[str, dict] = {}
    unique_hashes = sorted(set(sha1s))

    for batch in chunks(unique_hashes, 100):
        body = json.dumps({"hashes": batch, "algorithm": "sha1"}).encode("utf-8")
        request = urllib.request.Request(
            MODRINTH_VERSION_FILES_URL,
            data=body,
            headers={
                "Accept": "application/json",
                "Content-Type": "application/json",
                "User-Agent": USER_AGENT,
            },
            method="POST",
        )

        try:
            with urllib.request.urlopen(request, timeout=45) as response:
                payload = json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")
            raise RuntimeError(
                f"Modrinth hash lookup failed with HTTP {exc.code}: {detail}"
            ) from exc
        except urllib.error.URLError as exc:
            raise RuntimeError(f"Modrinth hash lookup failed: {exc}") from exc

        if not isinstance(payload, dict):
            raise RuntimeError("Modrinth hash lookup returned an unexpected response")

        for digest, version in payload.items():
            versions[str(digest).lower()] = version

    return versions


def exact_version_file(version: dict, sha1: str) -> dict | None:
    for file_info in version.get("files", []):
        hashes = file_info.get("hashes", {})
        if str(hashes.get("sha1", "")).lower() == sha1:
            return file_info
    return None


def rewrite_as_modrinth(repo_root: Path, entry: dict, version: dict, file_info: dict) -> dict:
    hashes = file_info.get("hashes", {})
    digest = hashes.get("sha512") or hashes.get("sha1")
    hash_format = "sha512" if hashes.get("sha512") else "sha1"
    url = file_info.get("url")
    filename = file_info.get("filename") or entry["filename"]

    if not digest or not url:
        raise RuntimeError(f"Modrinth match for {entry['path']} is missing a URL or hash")

    path = repo_root / entry["path"]
    path.write_text(
        "\n".join(
            [
                f"name = {toml_str(entry['name'])}",
                f"filename = {toml_str(filename)}",
                f"side = {toml_str(entry['side'])}",
                "",
                "[download]",
                f"url = {toml_str(url)}",
                f"hash-format = {toml_str(hash_format)}",
                f"hash = {toml_str(str(digest).lower())}",
                "",
                "[update]",
                "[update.modrinth]",
                f"mod-id = {toml_str(version['project_id'])}",
                f"version = {toml_str(version['id'])}",
                "",
            ]
        ),
        encoding="utf-8",
    )

    return {
        "path": entry["path"],
        "name": entry["name"],
        "filename_before": entry["filename"],
        "filename_after": filename,
        "sha1": entry["sha1"],
        "curseforge": entry["curseforge"],
        "modrinth": {
            "project_id": version["project_id"],
            "version_id": version["id"],
            "file_id": file_info.get("id"),
            "url": url,
        },
    }


def convert_exact_matches(repo_root: Path) -> dict:
    entries = discover_mods(repo_root)
    curseforge_entries = [entry for entry in entries if entry["source"] == "curseforge"]
    existing_modrinth = [entry for entry in entries if entry["source"] == "modrinth"]
    convertible = [entry for entry in curseforge_entries if entry.get("sha1")]
    versions = query_modrinth_versions([entry["sha1"] for entry in convertible])

    converted: list[dict] = []
    remaining: list[dict] = []

    for entry in curseforge_entries:
        sha1 = entry.get("sha1")
        version = versions.get(sha1 or "")
        file_info = exact_version_file(version, sha1) if version and sha1 else None

        if file_info:
            converted.append(rewrite_as_modrinth(repo_root, entry, version, file_info))
            continue

        remaining.append(
            {
                "path": entry["path"],
                "name": entry["name"],
                "filename": entry["filename"],
                "sha1": sha1,
                "curseforge": entry.get("curseforge"),
                "reason": "No Modrinth version file with the exact SHA-1 hash",
            }
        )

    return {
        "generated_at": dt.datetime.now(dt.UTC).replace(microsecond=0).isoformat(),
        "total_mod_metadata_files": len(entries),
        "curseforge_source_files": len(curseforge_entries),
        "existing_modrinth_source_files": len(existing_modrinth),
        "converted_curseforge_files": len(converted),
        "remaining_embedded_curseforge_files": len(remaining),
        "existing_modrinth": existing_modrinth,
        "converted": converted,
        "remaining_embedded": remaining,
    }


def copy_repo_to_temp(repo_root: Path, temp_parent: Path) -> Path:
    temp_repo = temp_parent / "pack"

    def ignore(_directory: str, names: list[str]) -> set[str]:
        ignored = {".git", "dist", "__pycache__"}
        return {name for name in names if name in ignored}

    shutil.copytree(repo_root, temp_repo, ignore=ignore)
    return temp_repo


def copy_public_packwiz_tree(source: Path, target: Path) -> None:
    if target.exists():
        shutil.rmtree(target)

    def ignore(_directory: str, names: list[str]) -> set[str]:
        ignored = {
            ".git",
            ".gitattributes",
            ".gitignore",
            ".packwizignore",
            "__pycache__",
            "dist",
            "docs",
            "README.md",
            "scripts",
        }
        return {name for name in names if name in ignored}

    shutil.copytree(source, target, ignore=ignore)


def run(command: list[str], cwd: Path) -> None:
    print("+ " + " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def inspect_mrpack(path: Path) -> dict:
    with zipfile.ZipFile(path) as archive:
        bad_file = archive.testzip()
        if bad_file:
            raise RuntimeError(f"{path} failed zip validation at {bad_file}")

        names = archive.namelist()
        if "modrinth.index.json" not in names:
            raise RuntimeError(f"{path} does not contain modrinth.index.json")

        index = json.loads(archive.read("modrinth.index.json").decode("utf-8"))
        embedded_mod_jars = sorted(
            name
            for name in names
            if name.startswith("overrides/mods/") and name.endswith(".jar")
        )

    return {
        "manifest_download_files": len(index.get("files", [])),
        "embedded_mod_jars": len(embedded_mod_jars),
        "embedded_mod_jar_paths": embedded_mod_jars,
    }


def render_markdown(report: dict) -> str:
    archive = report.get("archive", {})
    lines = [
        "# Modrinth Export Report",
        "",
        f"Generated: `{report['generated_at']}`",
        "",
        "## Summary",
        "",
        f"- Total mod metadata files: `{report['total_mod_metadata_files']}`",
        f"- Existing Modrinth metadata files: `{report['existing_modrinth_source_files']}`",
        f"- CurseForge metadata files converted in the temporary export tree: `{report['converted_curseforge_files']}`",
        f"- CurseForge metadata files still embedded as jar overrides: `{report['remaining_embedded_curseforge_files']}`",
    ]

    if archive:
        lines.extend(
            [
                f"- Modrinth manifest download files in archive: `{archive['manifest_download_files']}`",
                f"- Embedded mod jars in archive: `{archive['embedded_mod_jars']}`",
            ]
        )

    lines.extend(["", "## Remaining Embedded Jar Exceptions", ""])

    if not report["remaining_embedded"]:
        lines.append("No CurseForge-only jar exceptions remain.")
    else:
        lines.extend(
            [
                "| Mod | Metadata | CurseForge project | CurseForge file | SHA-1 |",
                "| --- | --- | --- | --- | --- |",
            ]
        )
        for entry in report["remaining_embedded"]:
            curseforge = entry.get("curseforge") or {}
            lines.append(
                "| "
                + " | ".join(
                    [
                        str(entry["name"]).replace("|", "\\|"),
                        f"`{entry['path']}`",
                        f"`{curseforge.get('project_id', '')}`",
                        f"`{curseforge.get('file_id', '')}`",
                        f"`{entry.get('sha1') or ''}`",
                    ]
                )
                + " |"
            )

    lines.extend(["", "## Converted Exact Matches", ""])

    if not report["converted"]:
        lines.append("No CurseForge metadata files were converted.")
    else:
        lines.extend(
            [
                "| Mod | Metadata | Modrinth project | Modrinth version |",
                "| --- | --- | --- | --- |",
            ]
        )
        for entry in report["converted"]:
            modrinth = entry["modrinth"]
            lines.append(
                "| "
                + " | ".join(
                    [
                        str(entry["name"]).replace("|", "\\|"),
                        f"`{entry['path']}`",
                        f"`{modrinth['project_id']}`",
                        f"`{modrinth['version_id']}`",
                    ]
                )
                + " |"
            )

    lines.append("")
    return "\n".join(lines)


def write_reports(report: dict, output: Path) -> None:
    report_dir = output.parent
    report_dir.mkdir(parents=True, exist_ok=True)
    json_path = report_dir / "modrinth-export-report.json"
    markdown_path = report_dir / "modrinth-export-report.md"

    json_path.write_text(
        json.dumps(report, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    markdown_path.write_text(render_markdown(report), encoding="utf-8")

    print(f"Wrote {json_path}")
    print(f"Wrote {markdown_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Build a Modrinth export from a temporary tree where CurseForge "
            "metadata is converted only when Modrinth has the exact same jar hash."
        )
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Path to the canonical packwiz repo.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Output .mrpack path. Defaults to dist/2b2m-<pack version>.mrpack.",
    )
    parser.add_argument(
        "--keep-temp",
        action="store_true",
        help="Keep the temporary converted pack tree for inspection.",
    )
    parser.add_argument(
        "--packwiz-tree-output",
        type=Path,
        help="Copy the converted packwiz tree to this path after refresh.",
    )
    parser.add_argument(
        "--skip-mrpack",
        action="store_true",
        help="Prepare/copy the converted packwiz tree without building a .mrpack.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    version = load_pack_version(repo_root)
    output = (args.output or repo_root / "dist" / f"2b2m-{version}.mrpack").resolve()

    temp_parent = Path(tempfile.mkdtemp(prefix="2b2m-modrinth-export-"))
    temp_repo = temp_parent / "pack"

    try:
        temp_repo = copy_repo_to_temp(repo_root, temp_parent)
        report = convert_exact_matches(temp_repo)

        print(
            "Converted "
            f"{report['converted_curseforge_files']} of "
            f"{report['curseforge_source_files']} CurseForge metadata files "
            "to Modrinth in the temporary export tree."
        )
        print(
            "Remaining embedded CurseForge jar exceptions: "
            f"{report['remaining_embedded_curseforge_files']}"
        )

        run(["scripts/refresh.sh"], temp_repo)

        if args.packwiz_tree_output:
            tree_output = args.packwiz_tree_output.resolve()
            copy_public_packwiz_tree(temp_repo, tree_output)
            print(f"Wrote converted packwiz tree to {tree_output}")

        if args.skip_mrpack:
            return 0

        temp_output = temp_repo / "dist" / output.name
        temp_output.parent.mkdir(parents=True, exist_ok=True)
        run(["packwiz", "modrinth", "export", "--output", str(temp_output)], temp_repo)

        report["archive"] = inspect_mrpack(temp_output)
        output.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(temp_output, output)
        write_reports(report, output)

        print(f"Wrote {output}")
        return 0
    finally:
        if args.keep_temp:
            print(f"Kept temporary export tree at {temp_repo}")
        else:
            shutil.rmtree(temp_parent, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())

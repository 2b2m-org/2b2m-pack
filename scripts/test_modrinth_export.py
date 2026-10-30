import importlib.util
import tempfile
import tomllib
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("exporter", Path(__file__).with_name("prepare-modrinth-export.py"))
exporter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(exporter)


class ModrinthExportTest(unittest.TestCase):
    def test_unavailable_mirrors_keep_curseforge_and_healthy_mirrors_convert(self):
        files = {
            "ultimate-factory": "ed0ff71df9bfe3b66b97c51a2834031084300a65",
            "lithostitched": "88cdded5b617e19b4d2676948b5550699de23578",
            "healthy": "1111111111111111111111111111111111111111",
        }
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "mods").mkdir()
            versions = {}
            for name, digest in files.items():
                (root / "mods" / (name + ".pw.toml")).write_text(
                    f'name = "{name}"\nfilename = "{name}.jar"\nside = "both"\n'
                    f'[download]\nhash-format = "sha1"\nhash = "{digest}"\n'
                    '[update.curseforge]\nproject-id = 1\nfile-id = 2\n'
                )
                versions[digest] = {"id": name, "project_id": name, "files": [
                    {"filename": name + ".jar", "url": "https://cdn.modrinth.com/" + name + ".jar", "hashes": {"sha1": digest}}
                ]}
            with patch.object(exporter, "query_modrinth_versions", return_value=versions):
                report = exporter.convert_exact_matches(root)
            self.assertEqual([entry["name"] for entry in report["converted"]], ["healthy"])
            self.assertEqual({entry["name"] for entry in report["remaining_embedded"]}, {"ultimate-factory", "lithostitched"})
            for name in files:
                metadata = tomllib.loads((root / "mods" / (name + ".pw.toml")).read_text())
                self.assertIn("modrinth" if name == "healthy" else "curseforge", metadata["update"])


if __name__ == "__main__":
    unittest.main()

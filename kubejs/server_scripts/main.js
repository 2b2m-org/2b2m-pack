PlayerEvents.loggedIn(event => {
  const key = '2b2m_received_ftb_quest_book'
  const player = event.player

  if (!player.persistentData.getBoolean(key)) {
    player.persistentData.putBoolean(key, true)
    player.give(Item.of('ftbquests:book'))
  }
})

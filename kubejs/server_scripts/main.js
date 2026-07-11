PlayerEvents.loggedIn(event => {
  const key = '2b2m_received_ftb_quest_book'
  const player = event.player

  if (!player.persistentData.getBoolean(key)) {
    player.persistentData.putBoolean(key, true)
    player.give(Item.of('ftbquests:book'))
  }
})

if (Platform.isLoaded('createaddition')) {
  ServerEvents.recipes(event => {
    event.remove({ id: 'createaddition:crafting/spool' })
    event.shaped('16x createaddition:spool', [
      'P P',
      ' N '
    ], {
      P: '#c:plates/iron',
      N: '#c:nuggets/iron'
    }).id('kubejs:createaddition_spool')
  })
}

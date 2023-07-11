---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/5/23 4:43 AM
---


COMMANDS               = {}
COMMANDS.PERSIST       = '0xspawn:commands:persist_location'
COMMANDS.SETUP         = '0xspawn:setup'
COMMANDS.PROCESS_SPAWN = '0xspanw:spawn'
COMMANDS.SPAWN_ME      = '0xspawn:spawn-me'

EVENTS                 = {}
EVENTS.DIED            = '0xspawn:died'

STRATEGIES             = {
    ['1'] = 'strategy_random_location',
    ['2'] = 'strategy_last_died_location',
    ['3'] = 'strategy_recent_location',
    ['4'] = 'strategy_ui_location_selector',
    ['5'] = 'strategy_ui_location_selector_with_recent_location',
    ['default'] = 'strategy_random_location',
}
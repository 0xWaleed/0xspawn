---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/4/23 6:10 AM
---

fx_version 'cerulean'

game 'gta5'

--NOTE: order matters

shared_script 'log.lua'

server_script 'bootstrap.lua'

server_script 'coords.lua'

client_script 'api.lua'


file 'js/*.js'

server_export 'getCoords'
server_export 'getFirstCoords'
server_export 'getRandom'


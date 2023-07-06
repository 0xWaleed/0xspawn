---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/1/23 5:28 PM
---

local sm = exports['spawnmanager']

function strategy_recent_location_setup(config)
    local interval = config.saveInterval

    local function persist_location()
        local playerPed = PlayerPedId()
        local coords    = GetEntityCoords(playerPed)
        local model     = GetEntityModel(playerPed)
        local heading   = GetEntityHeading(playerPed)

        if coords.x == 0 then
            log('You are out of the world, aborting saving your location')
            return
        end

        local data = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = heading,
            model = model,
        }

        TriggerServerEvent(COMMANDS.PERSIST, data)
        log('data persist sent', json.encode(data))
    end

    function wrapper()
        persist_location()
        SetTimeout(interval, wrapper)
    end

    RegisterNetEvent(COMMANDS.PROCESS_SPAWN, function(coords)
        log('spawning', coords)
        sm:forceRespawn()
        sm:spawnPlayer(coords)
    end)

    TriggerServerEvent(COMMANDS.SPAWN_ME)

    wrapper()
end

function strategy_random_location_setup(config)
    RegisterNetEvent(COMMANDS.PROCESS_SPAWN, function(coords)
        log('spawning', coords)
        sm:forceRespawn()
        sm:spawnPlayer(coords)
    end)

    TriggerServerEvent(COMMANDS.SPAWN_ME)
end

function setup(config)
    log('setting up with config', config)

    local strategy      = (STRATEGIES[config.strategy] or STRATEGIES['default']) .. '_setup'

    local strategySetup = _G[strategy]

    if type(strategySetup) ~= 'function' then
        error('expected spawn handler to be a function.')
    end

    log(('invoking strategy [%s] setup'):format(strategy))

    strategySetup(config)

    log(('done setting up strategy [%s]'):format(strategy))
end

sm:setAutoSpawn(false)

RegisterNetEvent(COMMANDS.SETUP, setup)

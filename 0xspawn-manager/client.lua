---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/1/23 5:28 PM
---

local sm = exports['spawnmanager']

function on_death(callback)
    adapter_register_event('gameEventTriggered', function(name, data)
        if name ~= 'CEventNetworkEntityDamage' then
            return
        end

        local victim = data[1]
        local isDead = data[4] == 1

        if not isDead then
            return
        end

        if victim ~= PlayerPedId() then
            return
        end

        callback()
    end)
end

function strategy_recent_location_setup(config)
    local interval = config.saveInterval

    local function persist_location()
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local model = GetEntityModel(playerPed)
        local heading = GetEntityHeading(playerPed)

        if coords.x == 0 then
            log('You are out of the world, abort saving location')
            return
        end

        local data = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = heading,
            model = model,
        }

        adapter_trigger_remote_event(COMMANDS.PERSIST, data)
        log('data persist sent', json.encode(data))
    end

    function wrapper()
        persist_location()
        SetTimeout(interval, wrapper)
    end

    adapter_register_net_event(COMMANDS.PROCESS_SPAWN, function(coords)
        log('spawning', coords)
        sm:forceRespawn()
        sm:spawnPlayer(coords)
    end)

    adapter_trigger_remote_event(COMMANDS.SPAWN_ME)

    wrapper()
end

function strategy_random_location_setup(config)
    adapter_register_net_event(COMMANDS.PROCESS_SPAWN, function(coords)
        log('spawning', coords)
        sm:forceRespawn()
        sm:spawnPlayer(coords)
    end)

    adapter_trigger_remote_event(COMMANDS.SPAWN_ME)
end

function strategy_ui_location_selector_setup(config)
    local ui = exports['0xspawn-ui']
    local currentCoords

    function find_coord_by_id(id, coords)
        for _, location in ipairs(coords) do
            if location.id == id then
                return location
            end
        end
    end

    adapter_register_net_event(COMMANDS.PROCESS_SPAWN, function(coords)
        log('process spawn', coords)
        currentCoords = coords
        ui:show(coords)
    end)

    adapter_register_nui_callback('spawn', function(id, responseCallback)
        local coord = find_coord_by_id(id, currentCoords)
        if not coord then
            responseCallback({ ok = false })
            error('invalid coordinate')
        end
        log('process spawn after user selection', id)
        sm:forceRespawn()
        sm:spawnPlayer(coord)
        responseCallback({ ok = true })
        ui:hide()
    end)

    adapter_trigger_remote_event(COMMANDS.SPAWN_ME)
end

function strategy_ui_location_selector_with_recent_location_setup(config)
    local ui = exports['0xspawn-ui']
    local currentCoords

    local interval = config.saveInterval

    local function persist_location()
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local model = GetEntityModel(playerPed)
        local heading = GetEntityHeading(playerPed)

        if coords.x == 0 then
            log('You are out of the world, abort saving your location')
            return
        end

        local data = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = heading,
            model = model,
        }

        adapter_trigger_remote_event(COMMANDS.PERSIST, data)
        log('data persist sent', json.encode(data))
    end

    function wrapper()
        persist_location()
        SetTimeout(interval, wrapper)
    end

    wrapper()

    function find_coord_by_id(id, coords)
        for _, location in ipairs(coords) do
            if location.id == id then
                return location
            end
        end
    end

    adapter_register_net_event(COMMANDS.PROCESS_SPAWN, function(coords)
        log('process spawn', coords)
        currentCoords = coords
        ui:show(coords)
    end)


    adapter_register_nui_callback('spawn', function(id, responseCallback)
        local coord = find_coord_by_id(id, currentCoords)
        if not coord then
            responseCallback({ ok = false })
            error('invalid coordinate')
        end
        log('process spawn after user selection', id)
        sm:forceRespawn()
        sm:spawnPlayer(coord)
        responseCallback({ ok = true })
        ui:hide()
    end)

    adapter_trigger_remote_event(COMMANDS.SPAWN_ME)
end

function register_debug_commands()
    adapter_register_command('die', function()
        SetEntityHealth(PlayerPedId(), 0)
    end)
end

function setup(config)
    log('setting up with config', config)

    local strategy = (STRATEGIES[config.strategy] or STRATEGIES['default']) .. '_setup'

    local strategySetup = _G[strategy]

    if type(strategySetup) ~= 'function' then
        error('expected spawn handler to be a function.')
    end

    log(('invoking strategy [%s] setup'):format(strategy))

    strategySetup(config)

    log(('done setting up strategy [%s]'):format(strategy))

    if config.debug then
        register_debug_commands()
    end
end

on_death(function()
    log('notifying server about the death')
    adapter_trigger_remote_event(EVENTS.DIED)
end)

sm:setAutoSpawn(false)

adapter_register_net_event(COMMANDS.SETUP, setup)

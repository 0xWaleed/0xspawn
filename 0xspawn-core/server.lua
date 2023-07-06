---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/4/23 6:03 PM
---

function extract_identifier_by_type(identifiers, type)
    local typeWithColon = ('%s:'):format(type)
    local typeLength    = typeWithColon:len()

    for _, identifier in ipairs(identifiers) do
        if identifier:sub(1, typeLength) == typeWithColon then
            return identifier
        end
    end
end

function get_player_license(playerServerId)
    local identifiers = GetPlayerIdentifiers(playerServerId)

    log('identifiers', identifiers)

    local license = extract_identifier_by_type(identifiers, 'license') or extract_identifier_by_type(identifiers, 'ip')

    if license then
        return license
    end

    error(('Unable to key player identifier'):format(playerServerId))
end

function strategy_recent_location_setup(config)
    local function persist_location(data)
        local playerServerId = source
        local license        = get_player_license(playerServerId)
        repo_persist_player_coords(license, data)
        log('recent location saved', asJson)
    end

    RegisterNetEvent(COMMANDS.PERSIST, persist_location)

    local function spawn_me(playerServerId)
        local license = get_player_license(playerServerId)
        local data    = repo_retrieve_player_coords(license)

        log('spawning player', GetPlayerName(playerServerId), data)

        if not data then
            local coords = config.defaultCoords
            log('player coords is not found, fallback to default coord', coords)
            data = {
                x = coords[1] or 0,
                y = coords[2] or 0,
                z = coords[3] or 0,
                heading = coords[4] or 0,
                model = 'player_zero'
            }
        end

        TriggerClientEvent(COMMANDS.PROCESS_SPAWN, playerServerId, data)
    end

    RegisterNetEvent(COMMANDS.SPAWN_ME, function()
        local playerServerId = source
        spawn_me(playerServerId)
    end)

    RegisterNetEvent('died', function()
        local playerServerId = source
        log('player died', GetPlayerName(playerServerId))
        Wait(5000)
        spawn_me(playerServerId)
    end)

    RegisterCommand('0xspawn:delete', function(playerServerId)
        local license = get_player_license(playerServerId)
        log('deleting player data', GetPlayerName(playerServerId), license)
        repo_delete_player_coords(license)
    end)
end

function strategy_random_location_setup(config)
    local coords = exports['0xspawn-coords']

    local function spawn_me(playerServerId)
        local location = coords:getRandom()
        log('spawning', GetPlayerName(playerServerId), location)
        TriggerClientEvent(COMMANDS.PROCESS_SPAWN, playerServerId, location)
    end

    RegisterNetEvent(COMMANDS.SPAWN_ME, function()
        local playerServerId = source
        spawn_me(playerServerId)
    end)

    RegisterNetEvent(EVENTS.DIED, function()
        local playerServerId = source
        spawn_me(playerServerId)
    end)
end

function build_context()
    local config         = {}

    config.strategy      = GetConvar('0xspawn.strategy', '1')
    config.saveInterval  = tonumber(
            GetConvar('0xspawn.save-interval', tostring('5000'))
    ) or 5000

    config.defaultCoords = json.decode(GetConvar('0xspawn.default-coord', '[]'))

    return {
        config = config
    }
end

function setup(context)
    local config = context.config

    log('setting up with config', config)

    if context.current ~= nil then
        context.current()
    end

    local strategy      = (STRATEGIES[config.strategy] or STRATEGIES['default']) .. '_setup'

    local strategySetup = _G[strategy]

    if type(strategySetup) ~= 'function' then
        error('expected spawn handler to be a function.')
    end

    log(('invoking strategy [%s] setup'):format(strategy))

    context.current = strategySetup(context.config)

    log(('done setting up strategy [%s]'):format(strategy))
end

local context = build_context()
setup(context)

function client_setup(playerServerId)
    TriggerClientEvent(COMMANDS.SETUP, playerServerId, context.config)
end

AddEventHandler('playerJoining', function()
    client_setup(source)
end)

CreateThread(function()
    Wait(3000)
    for _, player in ipairs(GetPlayers()) do
        client_setup(player)
    end
end)


RegisterCommand('0xspawn:dump', function()
    local coords = repo_dump_all_player_coords()
    log('all player coords', coords)
    local resName = GetCurrentResourceName()
    local data = json.encode(coords)
    log('saving to a file in', resName, type(data), data)
    SaveResourceFile(resName, 'dump.json', data, #data)
end)

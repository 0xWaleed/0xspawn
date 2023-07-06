---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/4/23 6:03 PM
---

function get_player_license(playerServerId)
    -- TODO: support sv_lan=0 ?

    local identifiers      = GetPlayerIdentifiers(playerServerId)
    local licenseKeyLength = ('license:'):len()

    for _, identifier in ipairs(identifiers) do
        if identifier:sub(1, licenseKeyLength) == 'license:' then
            return identifier
        end
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
            data         = {
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

    RegisterNetEvent('baseevents:onPlayerDied', function()
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

function build_context()
    local config         = {}

    config.strategy      = GetConvar('0xspawn.strategy', '1')
    config.saveInterval = tonumber(
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


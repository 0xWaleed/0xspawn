---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/4/23 6:03 PM
---

function extract_identifier_by_type(identifiers, type)
    local typeWithColon = ('%s:'):format(type)
    local typeLength = typeWithColon:len()

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

    error(('Unable to get player identifier'):format(playerServerId))
end

function strategy_recent_location_setup(config)
    local coords = exports['0xspawn-coords']:getFirstCoords()

    if not coords then
        error('expect to define at least one location')
    end

    local function persist_location(data)
        local playerServerId = source
        local license = get_player_license(playerServerId)
        repo_persist_player_coords(license, data)
        log('recent location saved', asJson)
    end

    adapter_register_net_event(COMMANDS.PERSIST, persist_location)

    local function spawn_me(playerServerId)
        local license = get_player_license(playerServerId)
        local data = repo_retrieve_player_coords(license)

        log('spawning player', GetPlayerName(playerServerId), data)

        if not data then
            log('player coords is not found, fallback to default coord', coords)
            data = coords
        end

        adapter_trigger_remote_event(COMMANDS.PROCESS_SPAWN, playerServerId, data)
    end

    adapter_register_net_event(COMMANDS.SPAWN_ME, function()
        local playerServerId = source
        spawn_me(playerServerId)
    end)

    adapter_register_net_event(EVENTS.DIED, function()
        local playerServerId = source
        log('player died', GetPlayerName(playerServerId))
        Citizen.SetTimeout(config.timeInBetween, function()
            spawn_me(playerServerId)
        end)
    end)

    if config.debug then
        log('registering debug commands')
        adapter_register_command('0xspawn:delete', function(playerServerId)
            local license = get_player_license(playerServerId)
            log('deleting player data', GetPlayerName(playerServerId), license)
            repo_delete_player_coords(license)
        end)
    end
end

function strategy_random_location_setup(config)
    local coordsService = exports['0xspawn-coords']

    local firstCoords = coordsService:getFirstCoords()

    if not firstCoords then
        error('expect to define at least one location')
    end

    local function spawn_me(playerServerId)
        local location = coordsService:getRandom() or firstCoords
        log('spawning', GetPlayerName(playerServerId), location)
        adapter_trigger_remote_event(COMMANDS.PROCESS_SPAWN, playerServerId, location)
    end

    adapter_register_net_event(COMMANDS.SPAWN_ME, function()
        local playerServerId = source
        spawn_me(playerServerId)
    end)

    adapter_register_net_event(EVENTS.DIED, function()
        local playerServerId = source
        Citizen.SetTimeout(config.timeInBetween, function()
            spawn_me(playerServerId)
        end)
    end)
end

function strategy_ui_location_selector_setup(config)
    local coordsService = exports['0xspawn-coords']

    adapter_register_net_event(COMMANDS.SPAWN_ME, function()
        local playerServerId = source

        local coords = coordsService:getCoords()

        adapter_trigger_remote_event(COMMANDS.PROCESS_SPAWN, playerServerId, coords)
    end)

    adapter_register_net_event(EVENTS.DIED, function()
        local playerServerId = source

        local coords = coordsService:getCoords()

        Citizen.SetTimeout(config.timeInBetween, function()
            adapter_trigger_remote_event(COMMANDS.PROCESS_SPAWN, playerServerId, coords)
        end)
    end)

end

function strategy_ui_location_selector_with_recent_location_setup(config)
    local coordsService = exports['0xspawn-coords']

    local function persist_location(data)
        local playerServerId = source
        local license = get_player_license(playerServerId)
        repo_persist_player_coords(license, data)
        log('recent location saved', asJson)
    end

    adapter_register_net_event(COMMANDS.PERSIST, persist_location)

    adapter_register_net_event(COMMANDS.SPAWN_ME, function()
        local playerServerId = source

        local coords = coordsService:getCoords()

        local license = get_player_license(playerServerId)
        local data = repo_retrieve_player_coords(license)

        if data then
            log('adding recent location to coords', data)
            table.insert(coords, 1, {
                id = tostring(GetHashKey('<recent-location>')),
                label = 'Recent Location',
                x = data.x,
                y = data.y,
                z = data.z,
                heading = data.heading,
                imageUrl = config.recentImageUrl
            })
        end

        Citizen.SetTimeout(config.timeInBetween, function()
            adapter_trigger_remote_event(COMMANDS.PROCESS_SPAWN, playerServerId, coords)
        end)
    end)

    adapter_register_net_event(EVENTS.DIED, function()
        local playerServerId = source

        local coords = coordsService:getCoords()

        local license = get_player_license(playerServerId)
        local data = repo_retrieve_player_coords(license)

        if data then
            log('adding recent location to coords', data)
            table.insert(coords, 1, {
                id = tostring(GetHashKey('<recent-location>')),
                label = 'Recent Location',
                x = data.x,
                y = data.y,
                z = data.z,
                heading = data.heading,
                imageUrl = config.recentImageUrl
            })
        end

        Citizen.SetTimeout(config.timeInBetween, function()
            adapter_trigger_remote_event(COMMANDS.PROCESS_SPAWN, playerServerId, coords)
        end)
    end)
end

function build_context()
    local config = {}

    config.strategy = GetConvar('0xspawn.strategy', '1')
    config.recentImageUrl = GetConvar('0xspawn.recent-image-url', '')
    config.debug = GetConvar('0xspawn.debug', 'false') == 'true'
    config.saveInterval = tonumber(
            GetConvar('0xspawn.save-interval', tostring('5000'))
    ) or 5000

    config.timeInBetween = tonumber(GetConvar('0xspawn.time-in-between', '3000'))

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

    local strategy = (STRATEGIES[config.strategy] or STRATEGIES['default']) .. '_setup'

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
    log('triggering client setup', playerServerId)
    adapter_trigger_remote_event(COMMANDS.SETUP, playerServerId, context.config)
end

adapter_register_event('playerJoining', function()
    client_setup(source)
end)

if context.config.debug then
    log('registering debug commands & invoke setup manually')
    CreateThread(function()
        Wait(3000)
        for _, player in ipairs(GetPlayers()) do
            client_setup(player)
        end
    end)

    adapter_register_command('0xspawn:dump', function()
        local coords = repo_dump_all_player_coords()
        log('all player coords', coords)
        local resName = GetCurrentResourceName()
        local data = json.encode(coords)
        log('saving to a file in', resName, type(data), data)
        SaveResourceFile(resName, 'dump.json', data, #data)
    end)
end
---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/1/23 5:28 PM
---

local log = (function()
    local logEnabled = GetConvar('0xspawn.log', 'false') == 'true'

    if not logEnabled then
        return function()
        end
    end

    local function milli_to_time(milliseconds)
        local seconds = math.floor(milliseconds / 1000)
        local minutes = math.floor(seconds / 60)
        local hours = math.floor(minutes / 60)

        seconds = seconds % 60
        minutes = minutes % 60

        return ('%s:%s:%s'):format(hours, minutes, seconds)
    end

    return function(...)
        local args = { ... }
        local argsAsStrings = {
            '[',
            milli_to_time(GetGameTimer()),
            ']'
        }
        for _, arg in ipairs(args) do
            if type(arg) == 'table' then
                table.insert(argsAsStrings, json.encode(arg))
            else
                table.insert(argsAsStrings, tostring(arg))
            end
        end
        print(table.concat(argsAsStrings, ' '))
    end
end)()

local sm = exports['spawnmanager']

function strategy_random_location_setup()
    -- TODO: find a way to load random locations
    sm:setAutoSpawn(true)
    sm:forceRespawn()
    sm:setAutoSpawnCallback(nil)
end

function strategy_last_died_location_setup()
    local function on_player_wasted(_, coords)
        local pedId = PlayerPedId()
        local model = GetEntityModel(pedId)
        local x, y, z = table.unpack(coords)
        sm:spawnPlayer({
            x = x,
            y = y,
            z = z,
            heading = 0,
            model,
        })
    end

    local token = AddEventHandler('baseevents:onPlayerDied', on_player_wasted)
    sm:setAutoSpawn(false)

    return function()
        RemoveEventHandler(token)
    end
end

function strategy_recent_location_setup(config)
    local key = "player:last-coords"
    local interval = config.save_interval

    local function persist_location()
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local model = GetEntityModel(playerPed)
        local heading = GetEntityHeading(playerPed)

        if coords.x == 0 then
            log('x coordinate is 0, aborting')
            return
        end

        local data = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = heading,
            model = model,
        }

        local asJson = json.encode(data)

        SetResourceKvp(key, asJson)
        log('recent location saved', asJson)
    end

    local function spawn()
        local data = GetResourceKvpString(key)
        local spawnData
        if data then
            spawnData = json.decode(data)
        end
        sm:spawnPlayer(spawnData)
    end

    function wrapper()
        persist_location()
        SetTimeout(interval, wrapper)
    end

    sm:setAutoSpawnCallback(spawn)
    wrapper()
end

local strategies = {
    ['1'] = 'strategy_random_location',
    ['2'] = 'strategy_last_died_location',
    ['3'] = 'strategy_recent_location',
    ['default'] = 'strategy_random_location',
}

function build_context()
    local config = {}

    config.strategy = GetConvar('0xspawn.strategy', '1')
    config.save_interval = tonumber(
            GetConvar('0xspawn.save-interval', tostring('5000'))
    ) or 5000

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

    local strategy = (strategies[config.strategy] or strategies['default']) .. '_setup'

    local strategySetup = _G[strategy]

    if type(strategySetup) ~= 'function' then
        error('expected spawn handler to be a function.')
    end

    log(('invoking strategy [%s] setup'):format(strategy))

    context.current = strategySetup(context.config)

    log(('done setting up strategy [%s]'):format(strategy))
end

setup(build_context())

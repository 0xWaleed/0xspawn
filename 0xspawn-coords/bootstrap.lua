---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/4/23 6:23 PM
---


local coords = {}

local function is_exist(name)
    for _, coord in pairs(coords) do
        if coord.name == name then
            return true
        end
    end
    return false
end

local function generate_id(name)
    local key = GetHashKey(name)
    key = tostring(key)
    key = key:gsub('%-', '1337')
    return key
end

function loc(name)
    return function(o)
        -- TODO: validate o
        if is_exist(name) then
            return
        end
        o.id = generate_id(name)
        table.insert(coords, o)
        log('adding location', name, o)
    end
end

function getCoords()
    return coords
end

function getRandom()
    local coordsCount = #coords
    local index = math.random(coordsCount)
    log('getting a random location at', index, coordsCount)
    return coords[index]
end

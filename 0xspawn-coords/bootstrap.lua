---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/4/23 6:23 PM
---


local coords = {}
local coordsCount = 0

function loc(name)
    return function(o)
        -- TODO: validate
        if not coords[name] then
            coordsCount = coordsCount + 1
        end
        coords[name] = o
        log('adding location', name, o)
    end
end


exports('getRandom', function()
    local index = math.random(coordsCount)
    log('getting a random location at', index, coordsCount)

    local i = 1
    for _, coord in pairs(coords) do
        if i == index then
            log('found a random location', coord)
            return coord
        end
        log('moving to next coord', i, index)
        i = i + 1
    end
    -- TODO: reconsider this
    return nil
end)

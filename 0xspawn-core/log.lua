---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/5/23 2:07 AM
---

log = (function()
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

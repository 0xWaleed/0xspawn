---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/3/23 5:35 PM
---


function ini_trim(value)
    local v = ''
    local start = 1
    local lastIndex = #value

    while true do
        local startChar = value:sub(start, start)
        local lastChar = value:sub(lastIndex, lastIndex)

        if startChar ~= ' ' and lastChar ~= ' ' and startChar ~= '\n' and lastChar ~= '\n' then
            v = value:sub(start, lastIndex)
            break
        end

        if startChar == ' ' or startChar == '\n' then
            start = start + 1
        end

        if lastChar == ' ' or lastChar == '\n' then
            lastIndex = lastIndex - 1
        end
    end

    return v
end

function ini_parse_line(line)
    local key, value = '', ''
    local current = ''
    local doneKey = false

    for i = 1, #line do
        local char = line:sub(i, i)

        if char == '=' then
            if doneKey then
                error(('Expected `%s` line to have one `=`.'):format(line))
            end
            key = ini_trim(current)
            current = ''
            doneKey = true
            goto continue
        end

        current = current .. char
        :: continue ::
    end

    if not doneKey then
        error(('Expected `%s` line to have `=`.'):format(line))
    end

    value = ini_trim(current)

    if tonumber(value) then
        value = tonumber(value)
    end

    if value == 'true' then
        value = true
    end

    if value == 'false' then
        value = false
    end

    return key, value
end

function ini_parse(input)
    local length = #input
    local out = {}
    local line = ''
    local withInBracket = false
    local lines = {}
    local withInBracketKey = ''
    for i = 1, length do
        local char = input:sub(i, i)
        if char == '[' then
            withInBracket = true
            goto continue
        end

        if char == ']' then
            table.insert(lines, { withInBracketKey })
            withInBracket = false
            withInBracketKey = ''

            goto continue
        end

        if withInBracket then
            withInBracketKey = withInBracketKey .. char
            goto continue
        end

        if char == '\n' or i == length then
            if i == length then
                line = line .. char
            end
            table.insert(lines, line)
            line = ''
        end

        line = line .. char
        :: continue ::
    end

    local temp = out
    local previous = nil

    for _, line in ipairs(lines) do
        if type(line) == 'table' then
            if previous then
                temp = previous
            end
            previous = temp
            temp[line[1]] = {}
            temp = temp[line[1]]
            goto continue
        end

        if line == ' ' or line == '\n' or line == '\r' then
            goto continue
        end

        local key, value = ini_parse_line(line)

        temp[key] = value

        :: continue ::
    end

    return out
end
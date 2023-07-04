---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/3/23 5:35 PM
---

function ini_dump(input)
    return input:gsub(".", function(c)
        return string.format("%02X", string.byte(c))
    end)
end

function ini_is_space(char)
    local byte = char:byte(1)
    return byte == 0x20
end

function ini_is_newline(char)
    local byte = char:byte(1)
    return byte == 10 or byte == 13
end

function ini_space_or_newline(char)
    return ini_is_newline(char) or ini_is_space(char)
end

function ini_trim(value)
    local v = ''
    local start = 1
    local lastIndex = #value

    while true do
        local startChar = value:sub(start, start)
        local lastChar = value:sub(lastIndex, lastIndex)

        if not ini_space_or_newline(startChar) and not ini_space_or_newline(lastChar) then
            v = value:sub(start, lastIndex)
            break
        end

        if ini_space_or_newline(startChar) then
            start = start + 1
        end

        if ini_space_or_newline(lastChar) then
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
        error(('Expected `%s:%s` line to have `=`.'):format(line, ini_dump(line)))
    end

    value = ini_trim(current)

    if tonumber(value) then
        return key, tonumber(value)
    end

    if value == 'true' then
        return key, true
    end

    if value == 'false' then
        return key, false
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

        if ini_is_newline(char) or i == length then
            if i == length then
                line = line .. char
            end
            line = ini_trim(line)
            if line ~= '' then
                table.insert(lines, line)
            end
            line = ''
        end

        line = line .. char
        :: continue ::
    end

    local temp = out
    local previous

    for _, line in ipairs(lines) do
        if type(line) == 'table' then
            local currentLine = line[1]
            if previous then
                temp = previous
            end
            previous = temp
            temp[currentLine] = {}
            temp = temp[currentLine]
            goto continue
        end

        if ini_space_or_newline(line) then
            print(string.format('%02X', line:byte(1)), ini_trim(line))
            goto continue
        end

        local key, value = ini_parse_line(line)

        temp[key] = value

        :: continue ::
    end

    return out
end
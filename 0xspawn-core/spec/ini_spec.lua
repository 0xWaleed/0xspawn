---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/3/23 5:37 PM
---

require('ini')

describe('ini_trim', function()
    it('trims', function()
        assert.equals('', ini_trim(''))
        assert.equals('', ini_trim(' '))
        assert.equals('Waleed', ini_trim('  Waleed'))
        assert.equals('Waleed', ini_trim('  Waleed  '))
        assert.equals('Waleed', ini_trim('Waleed'))
        assert.equals('0x Waleed', ini_trim('0x Waleed'))
        assert.equals('0x Wa le ed', ini_trim('0x Wa le ed'))
    end)

    it('trims line feed', function()
        assert.equals('Waleed', ini_trim([[
      Waleed
        ]]))
    end)

    it('trims line feed at beginning', function()
        assert.equals('Waleed', ini_trim([[

      Waleed
        ]]))
    end)
end)

describe('ini_parse_line', function()
    it('parses ideal line', function()
        local key, value = ini_parse_line('name = 0xWaleed')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line with key that has multiple spaces after the key', function()
        local key, value = ini_parse_line('name   = 0xWaleed')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line with key that has multiple spaces before the key', function()
        local key, value = ini_parse_line('  name = 0xWaleed')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line with key that has no spaces around', function()
        local key, value = ini_parse_line('name= 0xWaleed')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line with value that has multiple spaces after the value', function()
        local key, value = ini_parse_line('name = 0xWaleed  ')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line with value that has multiple spaces before the value', function()
        local key, value = ini_parse_line('name =    0xWaleed')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line with value that has multiple spaces around the value', function()
        local key, value = ini_parse_line('name =    0xWaleed   ')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line with value that has no spaces', function()
        local key, value = ini_parse_line('name =0xWaleed')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line that has multiple spaces around both key and value', function()
        local key, value = ini_parse_line('   name      =    0xWaleed   ')
        assert.equals('name', key)
        assert.equals('0xWaleed', value)
    end)

    it('parses line that has only key', function()
        local key, value = ini_parse_line('name=')
        assert.equals('name', key)
        assert.equals('', value)
    end)

    it('parses a number', function()
        local key, value = ini_parse_line('key=123')
        assert.equals('key', key)
        assert.equals(123, value)
    end)

    it('parses true', function()
        local key, value = ini_parse_line('key=true')
        assert.equals('key', key)
        assert.equals(true, value)
    end)

    it('parses false', function()
        local key, value = ini_parse_line('key=false')
        assert.equals('key', key)
        assert.equals(false, value)
    end)

    it('throws error when line has no =', function()
        assert.error(function()
            ini_parse_line('name')
        end, 'Expected `name` line to have `=`.')
        assert.error(function()
            ini_parse_line('key')
        end, 'Expected `key` line to have `=`.')

        assert.error(function()
            ini_parse_line('InvalidLine')
        end, 'Expected `InvalidLine` line to have `=`.')
    end)

    it('throws error when line has more than one =', function()
        assert.error(function()
            ini_parse_line('name==')
        end, 'Expected `name==` line to have one `=`.')
        assert.error(function()
            ini_parse_line('key===')
        end, 'Expected `key===` line to have one `=`.')
    end)
end)

describe('ini_parse', function()
    local input
    before_each(function()
        input = [[name = Waleed
version = 0.1
[info]

pc=tomato
car = jet
[another_info]
country=earth
boolean1=true
boolean2=false

city=middle-east
]]
    end)

    it('parses', function()
        local o = ini_parse(input)
        assert.same({
            name = "Waleed",
            version = 0.1,
            info = {
                pc = 'tomato',
                car = 'jet'
            },
            another_info = {
                country = 'earth',
                city = 'middle-east',
                boolean1 = true,
                boolean2 = false,
            }
        }, o)
    end)

end)
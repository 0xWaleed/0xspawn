---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/4/23 6:09 AM
---

loc 'store-1' {
    x = -1299.76,
    y = -880.85,
    z = 11.9,
    heading = 20.36,
    model = 'player_two',
    imageUrl = 'https://picsum.photos/1920/1080',
    label = 'Store One'
}

loc 'store-2' {
    x = -1275.11,
    y = -860.88,
    z = 12.22,
    heading = 301.76,
    model = 'player_zero',
    imageUrl = 'https://picsum.photos/1921/1081',
    label = 'Store Two'
}

loc 'store-3' {
    x = -3058.714, y = 3329.19, z = 12.5844,
    heading = 112.63,
    model = 'player_one',
    imageUrl = 'https://picsum.photos/1922/1082',
    label = 'ZancudoBunker'
}

loc 'store-4' {
    x = -1192.75,
    y = -827.75,
    z = 14.34,
    heading = 352.63,
    model = 'a_m_m_bevhills_02',
    imageUrl = 'https://picsum.photos/1923/1083',
    label = 'Store Four'
}


for i = 1, 5 do
    local width = 1084 + i
    loc('random-' .. i) {
        x = -1192.75,
        y = -827.75,
        z = 14.34,
        heading = 352.63,
        model = 'a_m_m_bevhills_02',
        imageUrl = 'https://picsum.photos/1923/' .. width,
        label = 'Store ' .. i
    }
end

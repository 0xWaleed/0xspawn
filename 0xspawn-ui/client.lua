---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/8/23 9:11 PM
---


exports('show', function(coords)
    SendNUIMessage({
        name = '0xspawn',
        type = 'spawn-ui',
        data = coords
    })

    SetNuiFocus(true, true)
end)

exports('hide', function()
    SetNuiFocus(false, false)
end)

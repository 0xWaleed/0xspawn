---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/8/23 7:17 AM
---


function adapter_register_command(name, callback)
    RegisterCommand(name, callback)
end

function adapter_register_event(name, callback)
    AddEventHandler(name, callback)
end

function adapter_register_net_event(name, callback)
    RegisterNetEvent(name)
    AddEventHandler(name, callback)
end

if IsDuplicityVersion() then
    function adapter_trigger_remote_event(name, playerServerId, ...)
        TriggerClientEvent(name, playerServerId, ...)
    end
else
    function adapter_trigger_remote_event(name, ...)
        log('triggering client event', name, ...)
        TriggerServerEvent(name, ...)
    end

    function adapter_register_nui_callback(name, callback)
        RegisterNUICallback(name, callback)
    end
end

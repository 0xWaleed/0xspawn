---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 7/5/23 11:41 PM
---


function repo_persist_data(key, value)
    local valueType = type(value)
    if valueType == 'table' then
        value = json.encode(value)
    end
    SetResourceKvp(key, value)
end

function repo_delete_data(key)
    DeleteResourceKvp(key)
end

function repo_retrieve_json_data(key)
    local data = GetResourceKvpString(key)

    if not data then
        return nil
    end

    return json.decode(data)
end

function repo_persist_player_coords(key, data)
    key = ('0xspawn:player:%s:coords'):format(key)
    log('repo persisting coords', key, data)
    repo_persist_data(key, data)
end

function repo_delete_player_coords(key)
    key = ('0xspawn:player:%s:coords'):format(key)
    log('repo deleting coords', key)
    repo_delete_data(key)
end

function repo_retrieve_player_coords(key)
    key = ('0xspawn:player:%s:coords'):format(key)
    local data = repo_retrieve_json_data(key)
    log('repo retrieving coords', key, data)
    return data
end
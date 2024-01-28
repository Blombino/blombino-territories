Utils = {}

Utils.tableLength = function(T)
    local count = 0
    if type(T) ~= 'table' then return 'nil' end
    for _ in pairs(T) do count += 1 end
    return count
end

Utils.getTerritories = function()
    local result = MySQL.query.await('SELECT * FROM blombinoterritories')
    if result then
        for k,v in pairs(result) do
            CTerritories[v.id] = CreateCTerritory(v.id, v.owner, v.claiming, v.influence, json.decode(v.coords), v.label, v.radius, v.cooldown, json.decode(v.boxes))
        end
        Utils.debugPrint('Created ' .. Utils.tableLength(CTerritories) .. ' territories', 'success')
    else
        Utils.debugPrint('ERROR WITH CONFIG', 'info')
    end
end

Utils.createTerritory = function(label, owner, coords, radius)
    MySQL.insert('INSERT INTO blombinoterritories (label, owner, claiming, influence, coords, radius) VALUES (@label, @owner, @claiming, @influence, @coords, @radius)', {
        ['@label'] = label,
        ['@owner'] = owner,
        ['@claiming'] = '',
        ['@influence'] = 100,
        ['@coords'] = json.encode(coords),
        ['@radius'] = radius
    }, function(id)
        CTerritories[id] = CreateCTerritory(id, owner, nil, 100, coords, label, radius)
        Utils.debugPrint('Territory success created ' .. id, 'success')
    end)
end

Utils.getData = function()
    local territories = {}
    for k,v in pairs(CTerritories) do
        territories[k] = {
            id = v.id,
            owner = v.owner,
            claiming = v.claiming,
            influence = v.influence,
            coords = v.coords,
            label = v.label,
            radius = v.radius,
            radiusblip = nil,
            moneyBoxes = v.moneyBoxes,
        }
    end

    return territories
end

Utils.saveTerritories = function()
    local parameters = {}
    local time = os.time()
    local count = Utils.tableLength(CTerritories)
    for k,v in pairs(CTerritories) do
        parameters[#parameters + 1] = {
            ['@id'] = v.id,
            ['@influence'] = v.influence,
            ['@claiming'] = v.claiming or '',
            ['@owner'] = v.owner,
            ['@cooldown'] = v.cooldown
        }
    end
    
    MySQL.prepare("UPDATE `blombinoterritories` SET `influence` = @influence, `claiming` = @claiming, `owner` = @owner, `cooldown` = @cooldown WHERE `id` = @id", parameters, function(results)
        if results then
            if type(cb) == 'function' then 
                cb() 
            else 
                Utils.debugPrint(('Saved %s %s in %s ms'):format(count, count > 1 and 'territorijos' or 'territorija', (os.time() - time) / 1000000), 'info')
            end
        end
    end)
end

Utils.spawnMoneyBoxes = function()
    for k,v in pairs(CTerritories) do
        local territory = v
        if territory.influence == 100 and territory.claiming == '' then
            territory.createMoneyBox()
        end
    end
end

Utils.createBoxSpawn = function(coords, territory)
    territory.addBox(coords)
    MySQL.update('UPDATE `blombinoterritories` SET `boxes` = @boxes WHERE `id` = @id', {
        ['@boxes'] = json.encode(territory.boxSpawns),
        ['@id'] = territory.id
    }, function(result)
        if result then
            Utils.debugPrint('Created boxes positions ' .. territory.label .. ' - ' .. tostring(coords), 'success')
        else
            Utils.debugPrint('Error with boxes ' .. territory.label, 'error')
        end
    end)
end

Utils.debugPrint = function(text, type)
    if type == 'info' or type == nil then
        print('[^4'..GetCurrentResourceName()..'^7] [^9INFO^7] ' .. text)
    elseif type == 'error' then
        print('[^4'..GetCurrentResourceName()..'^7] [^1ERROR^7] ' .. text)
    elseif type == 'warning' then
        print('[^4'..GetCurrentResourceName()..'^7] [^3WARNING^7] ' .. text)
    elseif type == 'success' then
        print('[^4'..GetCurrentResourceName()..'^7] [^2SUCCESS^7] ' .. text)
    end
end
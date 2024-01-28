CreateCTerritory = function(id, owner, claiming, influence, coords, label, radius, cooldown, boxes)
    local self = {
        id = id,
        owner = owner,
        claiming = claiming,
        influence = influence,
        coords = vec3(coords.x, coords.y, coords.z),
        label = label,
        radius = radius,
        cooldown = cooldown,
        moneyBoxes = {},
        players = {
            count = 0,
            owners = {},
            claimers = {}
        },
        boxSpawns = boxes or {}
    }

    self.save = function()
        MySQL.update('UPDATE blombinoterritories SET influence = @influence, claiming = @claiming, owner = @owner, cooldown = @cooldown WHERE id = @id', {
            ['@influence'] = self.influence,
            ['@claiming'] = self.claiming or nil,
            ['@owner'] = self.owner,
            ['@id'] = self.id,
            ['@cooldown'] = self.cooldown
        }, function(result)
            if result then
                Utils.debugPrint('Save ' .. self.label, 'success')
            else
                Utils.debugPrint('Error ' .. self.label, 'error')
            end
        end)
    end

    self.addPlayer = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local pCoords = GetEntityCoords(GetPlayerPed(xPlayer.source))
        if #(pCoords- self.coords) > self.radius + 100.0 and xPlayer.getGroup() ~= 'admin' then Utils.debugPrint(xPlayer.identifier .. ' bande prisideti save prie teritorijos', 'error') return DropPlayer(xPlayer.source, 'Nice try') end
        if xPlayer.job.name == self.owner then
            self.players.owners[xPlayer.source] = {
                ['source'] = xPlayer.source,
                ['job'] = xPlayer.job.name,
                ['identifier'] = xPlayer.identifier,
            }
        else
            self.players.claimers[xPlayer.source] = {
                ['source'] = xPlayer.source,
                ['job'] = xPlayer.job.name,
                ['identifier'] = xPlayer.identifier,
            }
        end

        self.players.count += 1
    end

    self.removePlayer = function(source)
        if self.players.count == 0 then return end
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            if self.owner == xPlayer.job.name then
                self.players.owners[xPlayer.source] = nil
            else
                self.players.claimers[xPlayer.source] = nil
            end
            self.players.count -= 1
        else
            for k,v in pairs(self.players.owners) do
                if v.source == source then
                    self.players.owners[k] = nil
                    self.players.count -= 1
                    return
                end
            end

            for k,v in pairs(self.players.claimers) do
                if v.source == source then
                    self.players.claimers[k] = nil
                    self.players.count -= 1
                    return
                end
            end
        end
    end

    self.claim = function()
        local ownersCache = self.players.owners
        local claimersCache = self.players.claimers
        local cache = self
        self.owner = cache.claiming
        self.players.owners = claimersCache
        self.players.claimers = ownersCache
        cache = nil
    end

    self.addInfluence = function(amount)
        if self.influence + amount > 100 then 
            self.influence = 100
        else
            self.influence += amount
        end   
    end

    self.removeInfluence = function(amount)
        if self.influence - amount < 1 then 
            self.influence = 0
        else
            self.influence -= amount
        end
    end

    self.getPlayer = function(source)
        if self.players.owners[source] then
            return self.players.owners[source]
        elseif self.players.claimers[source] then
            return self.players.claimers[source]
        end 
    end

    self.setClaiming = function(claimer)
        self.claiming = claimer
    end

    self.sendInfo = function()
        TriggerClientEvent('blombino-territories:setInfo', -1, {
            ['id'] = self.id,
            ['influence'] = self.influence,
            ['owner'] = self.owner,
            ['claiming'] = self.claiming
        })
    end

    self.setCooldown = function()
        self.cooldown = os.time()
    end

    self.isCooldown = function()
        return (os.difftime(os.time(), self.cooldown)/3600) < Config.Cooldown
    end

    self.createMoneyBox = function()
        if #self.boxSpawns == 0 then return end
        math.randomseed(os.time())
        local point = self.boxSpawns[math.random(#self.boxSpawns)]
        point = vec3(point.x, point.y, point.z)
        self.moneyBoxes[#self.moneyBoxes + 1] = {
            ['point'] = point,
            ['reward'] = Config.MoneyBox.rewards[math.random(#Config.MoneyBox.rewards)]
        }
        local xPlayers = ESX.GetExtendedPlayers('job', self.owner)
        for i=1, #xPlayers, 1 do
            local xPlayer = xPlayers[i]
            xPlayer.triggerEvent('blombino-territories:createMoneyBox', point)
        end
        Utils.debugPrint('Money box created at ' .. tostring(point) .. ' info sent to ' .. #xPlayers .. ' players', 'success')
    end

    self.removeMoneyBox = function(index)
        self.moneyBoxes[index] = nil
    end

    self.sendDistress = function()
        local xPlayers = ESX.GetExtendedPlayers('job', self.owner)
        for i=1, #xPlayers, 1 do
            local xPlayer = xPlayers[i]
            xPlayer.showNotification(self.label .. ' The territory is claiming!')
        end
    end

    self.addBox = function(coords)
        self.boxSpawns[#self.boxSpawns + 1] = coords
    end

    return self
end
CTerritories = {}
local deadPlayers = {}
local cachePlayers = {}
local claimingTerritories = {}
local ox_inventory = exports.ox_inventory


RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
    deadPlayers[source] = true
    for k,v in pairs(cachePlayers) do
        if k == source then
            CTerritories[v].removePlayer(source)
            break
        end
    end
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
    if cachePlayers[source] then CTerritories[cachePlayers[source]].addPlayer(source) end
	deadPlayers[source] = nil
end)

RegisterNetEvent('blombino-territories:inZone', function(id, inZone)
    local territory = CTerritories[id]
    if not territory then return end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if territory.claiming ~= '' and territory.claiming ~= xPlayer.job.name then return end
    if inZone and not deadPlayers[_source] then 
        territory.addPlayer(_source)
        cachePlayers[_source] = id
    else
        territory.removePlayer(_source)
        cachePlayers[_source] = nil
    end
end)

RegisterNetEvent('blombino-territories:pickUpMoneyBox', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not cachePlayers[xPlayer.source] then return DropPlayer(xPlayer.source, 'Uh oh 404 not found') end
    local territory = CTerritories[cachePlayers[xPlayer.source]]
    local found, index = false, 0
    local pCoords = GetEntityCoords(GetPlayerPed(xPlayer.source))
    for k,v in pairs(territory.moneyBoxes) do
        if #(v.point.xy - pCoords.xy) < 9.0 then
            if #(v.point.xy - pCoords.xy) < 5.0 then
                found = true
                index = k
            end
        end
    end
    if not found then Utils.debugPrint(string.format('%s nearby idiot', xPlayer.identifier), 'error') return DropPlayer(xPlayer.source, 'Uh oh') end
    if ox_inventory:CanCarryItem(xPlayer.source, territory.moneyBoxes[index].reward.name, territory.moneyBoxes[index].reward.amount) then
        ox_inventory:AddItem(xPlayer.source, territory.moneyBoxes[index].reward.name, territory.moneyBoxes[index].reward.amount)
        TriggerClientEvent('blombino-territories:removeMoneyBox', -1, territory.moneyBoxes[index].point)
        territory.removeMoneyBox(index)
    else
        xPlayer.showNotification('SPACEEE')
    end    
    Wait(1000)
end)

CreateThread(function()
    while GetResourceState('oxmysql') ~= 'started' do
		Wait(100)
	end

    Utils.getTerritories()

    while true do
        Wait(10 * 60000)
        Utils.saveTerritories()
    end
end)

CreateThread(function()
    while true do
        Wait(200 * 60000)
        Utils.spawnMoneyBoxes() 
    end
end)

RegisterCommand('claim', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not cachePlayers[xPlayer.source] then return xPlayer.showNotification('Nesate zonoje') end
    local territory = CTerritories[cachePlayers[xPlayer.source]]
    if #ESX.GetExtendedPlayers('job', territory.owner) < 3 and territory.owner ~= xPlayer.job.name and territory.owner ~= 'unclaimed' then return xPlayer.showNotification('INVITE YOUR FRIENDS IDIOT') end
    if xPlayer.job.name == territory.owner and territory.influence == 100 then return xPlayer.showNotification('You idiot?') end
    if territory.isCooldown() then return xPlayer.showNotification('Wait') end
    if territory.claiming ~= '' then return xPlayer.showNotification('Idk') end
    territory.sendDistress()
    territory.setClaiming(xPlayer.job.name)
    claimingTerritories[territory.id] = SetInterval(function()
        local claimersCount = Utils.tableLength(territory.players.claimers)
        local ownersCount = Utils.tableLength(territory.players.owners)
        if territory.players.count == 0 and claimersCount == 0 then 
            territory.setClaiming('') 
            territory.save()
            territory.sendInfo()
            ClearInterval(claimingTerritories[territory.id])
        end
        if (claimersCount == 0 and ownersCount ~= 0) and territory.influence ~= 100 then
            territory.addInfluence(((ownersCount * 2) / 1 * 100) / territory.radius)
            territory.sendInfo()
            if territory.influence == 100 then
                territory.setClaiming('')
                territory.setCooldown()
                territory.save()
                territory.sendInfo()
                ClearInterval(claimingTerritories[territory.id])
            end
        elseif claimersCount ~= 0 and territory.influence ~= 0 then
            local m = ownersCount
            if ownersCount == 0 then m = 1 end
            territory.removeInfluence(((m * 2) / claimersCount) * 100 / territory.radius)
            territory.sendInfo()
            if territory.influence == 0 then
                territory.claim()
                territory.save()
            end
        end
    end, 2000)
end)

AddEventHandler('playerDropped', function()
    local _source <const> = source
    deadPlayers[_source] = nil
    if cachePlayers[_source] then
        CTerritories[cachePlayers[_source]].removePlayer(_source)
        cachePlayers[_source] = nil
    end
end)

lib.addCommand('group.admin', {'ct','createterritory'}, function(source, args) 
    Utils.createTerritory(args.label or 'NULL', args.owner or 'unclaimed', GetEntityCoords(GetPlayerPed(source)), args.radius or 10)
end, {'radius:number', 'owner:string', 'label:string'})

lib.addCommand('group.admin', {'cb','createbox'}, function(source, args)
    if not cachePlayers[source] then return end
    local territory = CTerritories[cachePlayers[source]]
    Utils.createBoxSpawn(GetEntityCoords(GetPlayerPed(source)), territory)
end, {})

lib.callback.register('blombino-territories:getdata', function(source)
    return Utils.getData()
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
	if eventData.secondsRemaining == 60 then
		CreateThread(function()
			Wait(50000)
			Utils.saveTerritories()
		end)
	end
end)
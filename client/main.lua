_Territories = {}
local isGang = false
local point = nil
local blip = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    for k ,v in pairs(Config.Colors) do    
        if k == playerData.job.name then
            isGang = true
            _playerJob = playerData.job.name
            break
        end
    end
    if isGang then
        _Territories = lib.callback.await('blombino-territories:getdata', false)
        Utils.createBlips()
        Wait(1000)
        for k,v in pairs(_Territories) do
            local territory = _Territories[k]
            if territory.owner == playerData.job.name then
                for k,v in pairs(territory.moneyBoxes) do
                    Utils.spawnMoneyBox(v.point)
                end
            end
        end
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    isGang = false
    Utils.resetEverything()
	for k ,v in pairs(Config.Colors) do
        if k == job.name then
            isGang = true
            _playerJob = job.name
            break
        end
    end
    if isGang then
        _Territories = lib.callback.await('blombino-territories:getdata', false)
        Utils.createBlips()
        for k,v in pairs(_Territories) do
            local territory = _Territories[k]
            if territory.owner == job.name then
                for k,v in pairs(territory.moneyBoxes) do
                    Utils.spawnMoneyBox(v.point)
                end
            end
        end
    end
end)

RegisterNetEvent('blombino-territories:setInfo', function(data)
    if not isGang then return end
    local territory = _Territories[data.id]
    territory.influence = data.influence
    territory.owner = data.owner
    territory.claiming = data.claiming
    UpdateUi(territory.influence, territory.label, Config.GangNames[territory.owner] or 'CLAIM IT!')
    SetBlipAlpha(territory.radiusblip, math.floor((territory.influence * 120) / 100))
    SetBlipColour(territory.radiusblip, Config.Colors[territory.owner] or 0)
    SetBlipFlashes(territory.radiusblip, territory.claiming ~= '')
end)

RegisterNetEvent('blombino-territories:createMoneyBox', function(coords)
    if not isGang then return end
    Utils.spawnMoneyBox(coords)
end)

RegisterNetEvent('blombino-territories:removeMoneyBox', function(coords)
    Utils.removeMoneyBox(coords)
end)



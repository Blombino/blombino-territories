Utils = {}
local objects = {}
local uiOpen = false
local comboZone = nil

--- Local functions

local OpenUi = function(_curr,_name)
    if not uiOpen then
        SendNUIMessage({
            type = 'ui',
            show = true
        })
        uiOpen = true
    end
end

local CloseUi = function(_curr, _name)
    if uiOpen then
        SendNUIMessage({
            type = 'ui',
            show = false,
        })
        uiOpen = false
    end
end

local function DrawText3D(coords, text, customEntry)
    local str = text

    local start, stop = string.find(text, "~([^~]+)~")
    if start then
        start = start - 2
        stop = stop + 2
        str = ""
        str = str .. string.sub(text, 0, start)
    end

    if customEntry ~= nil then
        AddTextEntry(customEntry, str)
        BeginTextCommandDisplayHelp(customEntry)
    else
        AddTextEntry(GetCurrentResourceName(), str)
        BeginTextCommandDisplayHelp(GetCurrentResourceName())
    end
    EndTextCommandDisplayHelp(2, false, false, -1)

    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
end

---

Utils.createBlips = function()
    for k,v in pairs(_Territories) do
        v.radiusblip = AddBlipForRadius(v.coords, v.radius + 0.0)
        SetBlipAlpha(v.radiusblip, math.floor((v.influence * 128) / 100))
        SetBlipColour(v.radiusblip, Config.Colors[v.owner] or 0)
        SetBlipHighDetail(v.radiusblip, true)
    end
    Utils.createZones()
end

Utils.createZones = function()
    local zones = {}
    for k,v in pairs(_Territories) do
        v.zone = CircleZone:Create(v.coords, v.radius, {
            name = v.id,
            debugPoly = false,
            useZ = false,
            data = {
                influence = v.influence,
                label = v.label,
                id = v.id
            }
        })

        zones[#zones + 1] = v.zone
    end

    comboZone = ComboZone:Create(zones, {name='territories', debugPoly = false})
    comboZone:onPlayerInOut(function(isPointInside, point, zone)
        if zone then
            if isPointInside then
                TriggerServerEvent('blombino-territories:inZone', zone.data.id, true)
                OpenUi()
                UpdateUi(_Territories[zone.data.id].influence, zone.data.label, Config.GangNames[_Territories[zone.data.id].owner] or 'Neužimta')
            else
                TriggerServerEvent('blombino-territories:inZone', zone.data.id, false)
                CloseUi()
            end
        end
    end)
end

Utils.spawnMoneyBox = function(coords)
    local count = #objects + 1
    objects[count] = {
        object = nil,
        point = nil,
        coords = nil,
        blip = nil
    }
    RequestModel(Config.MoneyBox.model)
    while not HasModelLoaded(Config.MoneyBox.model) or not HasCollisionForModelLoaded(Config.MoneyBox.model) do Wait(1) end
    objects[count].object = CreateObject(Config.MoneyBox.model, coords.x, coords.y, coords.z - 0.95, false, true, true)
    SetEntityLodDist(objects[count].object, 4095)
    SetEntityAsMissionEntity(objects[count].object, true, true)
    Wait(50)
    FreezeEntityPosition(objects[count].object, true)
    if Config.Debug then
        objects[count].blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(objects[count].blip, 500)
        SetBlipColour(objects[count].blip, 2)
    end
    local newCoords = vec3(coords.x, coords.y, coords.z - 0.35)
    local point = lib.points.new(newCoords, 5, {})
    function point:nearby() 
        if self.currentDistance < 4.5 then
            DrawText3D(vec3(self.coords.x, self.coords.y, self.coords.z + 1), "~INPUT_PICKUP~ Open box")
        end

        if self.currentDistance < 4.3 and IsControlJustReleased(0, 38) then
            TriggerServerEvent('blombino-territories:pickUpMoneyBox')
        end
    end
    objects[count].point = point
    objects[count].coords = coords 
end

Utils.removeMoneyBox = function(coords)
    for k,v in pairs(objects) do
        if v.coords == coords then
            SetEntityAsMissionEntity(v.object, false, true)
            DeleteObject(v.object)
            v.point:remove()
            if Config.Debug then
                RemoveBlip(v.blip)
            end
            objects[k] = nil
            break
        end
    end
end

Utils.resetEverything = function()
    for k,v in pairs(_Territories) do
        local zone = comboZone:RemoveZone(tostring(k))
        zone:destroy()
        RemoveBlip(v.radiusblip)
        for k,v in pairs(objects) do
            DeleteObject(v.object)
            if v.point then
                v.point:remove()
            end
            if Config.Debug then
                RemoveBlip(v.blip)
            end
        end
    end
    _Territories = {}
end

UpdateUi = function(_curr,_name, _owner)
    if uiOpen then
        SendNUIMessage({
            type = 'update',
            show = true,
            curr = _curr,
            name = _name,
            owner = _owner,
            max = 100
        })
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k,v in pairs(objects) do
            DeleteObject(v.object)
            if Config.Debug then
                RemoveBlip(v.blip)
            end
        end
    end
end)
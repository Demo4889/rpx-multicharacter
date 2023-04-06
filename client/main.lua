RPX = exports['rpx-core']:GetObject()

CharacterData = {}

AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then
        return
    end
    Wait(1)
    Camera.DestroyCamera()
    Peds.DestroyPeds()
end)

-- Begin the process of loading characters after loading screen is done
CreateThread(function()
    while true do
        Wait(100)
        if LocalPlayer.state.PlayerSpawned then
            DoScreenFadeOut(500)
            Wait(500)
            RPX.RequestRoutingBucket(math.random(20000) + 10000)
            TriggerServerEvent("SERVER:RPX:LoadCharacters")
            return
        end
    end
end)

CharacterSelected = function()
    if CharacterData[Camera.SelectedChar] then
        DoScreenFadeOut(250)
        Wait(300)
        Camera.DestroyCamera()
        Peds.DestroyPeds()
        TriggerServerEvent("SERVER:MultiCharacter:SelectCharacter", CharacterData[Camera.SelectedChar].citizenid)
        Camera.CamActive = false
        Camera.Cam = nil
        Camera.SelectedChar = 1
        Camera.PointingAtChar = 0
        Citizen.InvokeNative(0x8BC7C1F929D07BF3, GetHashKey("HUD_CTX_FIREFIGHT_CUTSCENE"))   -- revert reticle, help, feed, award massages, etc.
    else
        SendNUIMessage({ action = "OPEN" })
        SetNuiFocus(true, true)
    end
end

DeleteCharacter = function()
    if CharacterData[Camera.SelectedChar] then
        SendNUIMessage({ action = "OPEN_CONFIRMDELETE" })
        SetNuiFocus(true, true)
    else
        Camera.StartCameraThread()
        return
    end
end

RegisterNUICallback("CloseConfirm", function(response)
    SetNuiFocus(false, false)
    if not response then
        Camera.StartCameraThread()
        return
    end

    if response.confirm == true then
        TriggerServerEvent("SERVER:MultiCharacter:DeleteCharacter", CharacterData[Camera.SelectedChar].citizenid)
    else
        Camera.StartCameraThread()
    end
end)

RegisterNetEvent("CLIENT:MultiCharacter:CharacterDeleted", function()
    DoScreenFadeOut(500)
    Wait(500)
    Camera.DestroyCamera()
    Peds.DestroyPeds()
    Camera.CamActive = false
    Camera.Cam = nil
    Camera.SelectedChar = 1
    Camera.PointingAtChar = 0
    RPX.RequestRoutingBucket(math.random(20000) + 10000)
    TriggerServerEvent("SERVER:RPX:LoadCharacters")
end)

RegisterNUICallback("CloseNUI", function(response)
    SetNuiFocus(false, false)
    if not response then
        Camera.StartCameraThread()
        return
    end

    if response.firstname then
        local info = {
            firstname = response.firstname, -- Default name
            lastname = response.lastname, -- Default name
            age = tonumber(response.age), -- 18 is the default age
            gender = tonumber(response.gender), -- 1 = Male, 0 = Female
            height = tonumber(response.height), -- 178cm is the default height
        }
    
        DoScreenFadeOut(250)
        Wait(300)
        Camera.DestroyCamera()
        Peds.DestroyPeds()
        Camera.CamActive = false
        Citizen.InvokeNative(0x8BC7C1F929D07BF3, GetHashKey("HUD_CTX_FIREFIGHT_CUTSCENE"))   -- revert reticle, help, feed, award massages, etc.

        TriggerServerEvent("SERVER:MultiCharacter:CreateCharacter", info, Camera.SelectedChar)
    else
        Camera.StartCameraThread()
    end
end)

RegisterCommand("logout", function()
    if LocalPlayer.state.PlayerSpawned and LocalPlayer.state.isLoggedIn then
        Camera.Cam = nil
        Camera.SelectedChar = 1
        Camera.PointingAtChar = 0
        DoScreenFadeOut(500)
        Wait(500)
        TriggerServerEvent("SERVER:RPX:Logout")
        RPX.RequestRoutingBucket(math.random(20000) + 10000)
        TriggerServerEvent("SERVER:RPX:LoadCharacters")
        return
    end
end)

RegisterNetEvent("CLIENT:MultiCharacter:LoadCharacters", function(chardata)
    CharacterData = {}

    for position,data in ipairs(chardata) do
        if not CharacterData[data.slot] then
            CharacterData[data.slot] = {}
        end
        CharacterData[data.slot].citizenid = data.citizenid
        CharacterData[data.slot].slot = data.slot
        CharacterData[data.slot].charinfo = json.decode(data.charinfo)
        CharacterData[data.slot].skin = json.decode(data.skin)
        CharacterData[data.slot].clothes = json.decode(data.clothes)
    end

    local PositionsTaken = 0

    SetEntityCoords(PlayerPedId(), Config.HidePed.x, Config.HidePed.y, Config.HidePed.z)

    for i = 1, 4 do
        if CharacterData[i] then
            local ped = Peds.SpawnPed(tonumber(CharacterData[i].slot))
            exports['rpx-appearance']:loadSkin(ped, CharacterData[i].skin)
            exports['rpx-appearance']:loadClothes(ped, CharacterData[i].clothes)
            PositionsTaken = PositionsTaken + 1
            Wait(10)
        end
    end

    if PositionsTaken < 4 then
        local Components = exports['rpx-appearance']:getSkinData()
        for i = 1, 4 do
            if not CharacterData[i] then
                local ped = Peds.SpawnPed(i)
                Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
                Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 3, 0)
                NativeUpdatePedVariation(ped)
                NativeSetPedComponentEnabled(ped, Components.Male["BODIES_LOWER"][10], false, true, true)
                NativeSetPedComponentEnabled(ped, Components.Male["BODIES_UPPER"][10], false, true, true)
                NativeUpdatePedVariation(ped)
            end
        end
    end

    Camera.SetUpCamera()

    Wait(100)
    DoScreenFadeIn(500)

    while not IsScreenFadedIn() do
        Citizen.Wait(0)
    end

    Camera.StartCameraThread()
end)

RegisterNetEvent("CLIENT:MultiCharacter:CharacterSelected", function(playerdata, newplayer)
    exports['rpx-appearance']:RequestAndSetModel(playerdata.charinfo.gender and "mp_male" or "mp_female")
    Wait(10)

    exports['rpx-appearance']:loadSkin(PlayerPedId(), playerdata.skin)
    exports['rpx-appearance']:loadClothes(PlayerPedId(), playerdata.clothes, false)
    if not newplayer then
        RPX.RequestRoutingBucket(0)
        local position = playerdata.position
        local SpawnPosition = vector3(position.x, position.y, position.z)
        SetEntityCoords(PlayerPedId(), SpawnPosition.x, SpawnPosition.y, SpawnPosition.z - 1.0)

        TriggerEvent("rpx-spawn:client:SpawnAtPosition", SpawnPosition)

        FreezeEntityPosition(PlayerPedId(), false)
        DoScreenFadeIn(500)
    else
        TriggerEvent("rpx-appearance:client:newPlayer")
    end
end)

function NativeSetPedComponentEnabled(ped, componentHash, immediately, isMp)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, true, false, true)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, true, true, true)
    NativeUpdatePedVariation(ped)
end

function NativeHasPedComponentLoaded(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
end

function NativeUpdatePedVariation(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    while not NativeHasPedComponentLoaded(ped) do
        Wait(1)
    end
end
Peds = {}
Peds.PedList = {}

Peds.SpawnPed = function(position)
    local coords = Config.CharLocations[position]
    RequestModel(GetHashKey("mp_male"))
    while not HasModelLoaded(GetHashKey("mp_male")) do
        Wait(1)    
    end
    local ped = CreatePed(GetHashKey("mp_male"), coords.x, coords.y, coords.z - 1.0, coords.w, false, true, 0, 0)
    while not DoesEntityExist(ped) do
        Wait(1)
    end
    SetEntityAsMissionEntity(ped, true, true)
    NetworkSetEntityInvisibleToNetwork(ped, true)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true) -- _SET_RANDOM_OUTFIT_VARIATION
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, coords.w)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityCanBeDamagedByRelationshipGroup(ped, false, GetHashKey("PLAYER"))
    SetModelAsNoLongerNeeded(GetHashKey("mp_male"))
    Peds.PedList[position] = ped
    return Peds.PedList[position]
end

Peds.DestroyPeds = function()
    for position,ped in pairs(Peds.PedList) do
        DeleteEntity(ped)
    end
end
RPX = exports['rpx-core']:GetObject()

RegisterNetEvent("SERVER:RPX:LoadCharacters", function()
    local src = source
    local characters = RPX.Player.GetCharacters(src)

    TriggerClientEvent("CLIENT:MultiCharacter:LoadCharacters", src, characters)
end)

RegisterNetEvent("SERVER:MultiCharacter:SelectCharacter", function(citizenid)
    local src = source
    RPX.Player.SelectCharacter(src, citizenid)
end)

RegisterNetEvent("SERVER:MultiCharacter:CreateCharacter", function(info, slot)
    local src = source
    RPX.Player.CreateCharacter(src, info, slot)
end)

RegisterNetEvent("SERVER:RPX:Logout", function()
    local src = source
    Player(src).state:set('isLoggedIn', false, true)
    RPX.Player.Logout(src)
end)

RegisterNetEvent("SERVER:MultiCharacter:DeleteCharacter", function(citizenid)
    local src = source
    RPX.Player.DeleteCharacter(src, citizenid)
    TriggerClientEvent("CLIENT:MultiCharacter:CharacterDeleted", src)
end)
---@class Camera
---@field Cam table
---@field SelectedChar number
---@field PointingAtChar number
---@field CamActive boolean
---@field SetUpCamera function
---@field DestroyCamera function
---@field StartCameraThread function

Camera = {}
Camera.Cam = nil
Camera.SelectedChar = 1
Camera.PointingAtChar = 0
Camera.CamActive = false

Camera.SetUpCamera = function()
    Camera.Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(Camera.Cam, Config.CamCoords[1].x, Config.CamCoords[1].y, Config.CamCoords[1].z)
    SetCamRot(Camera.Cam, 0.0, 0.0, Config.CamCoords[1].w)

    --PointCamAtEntity(Camera.Cam, Peds.PedList[1])
    SetCamActive(Camera.Cam, true)
    RenderScriptCams(true, false, 1, true, true)
end

Camera.DestroyCamera = function()
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(Camera.Cam, false)
end

Camera.StartCameraThread = function()
    CreateThread(function()
        Camera.CamActive = true
        Citizen.InvokeNative(0x4CC5F2FC1332577F, GetHashKey("HUD_CTX_FIREFIGHT_CUTSCENE"))   -- removes reticle, help, feed, award massages, etc.
        while true do
            Wait(1)

            -- Point the camera at the selected ped
            if Camera.PointingAtChar ~= Camera.SelectedChar then
                Camera.PointingAtChar = Camera.SelectedChar
                
                for _, ped in pairs(Peds.PedList) do
                    if GetEntityAlpha(ped) ~= 100 then
                        SetEntityAlpha(ped, 100, false)
                    end
                end

                SetCamParams(Camera.Cam, Config.CamCoords[Camera.SelectedChar].x, Config.CamCoords[Camera.SelectedChar].y, Config.CamCoords[Camera.SelectedChar].z, 0.0, 0.0, Config.CamCoords[Camera.SelectedChar].w, GetGameplayCamFov(), 500, 1.0, 2, 1)
                Wait(500)
                --PointCamAtEntity(Camera.Cam, Peds.PedList[Camera.SelectedChar], 0.0, 0.0, 0.0, true)
            end

            -- Set the alpha of the entity the camera is pointing at
            if GetEntityAlpha(Peds.PedList[Camera.PointingAtChar]) ~= 255 then
                SetEntityAlpha(Peds.PedList[Camera.PointingAtChar], 255, false)
            end

            -- Make sure all other peds are not transparent
            for _, ped in pairs(Peds.PedList) do
                if ped ~= Peds.PedList[Camera.PointingAtChar] then
                    if GetEntityAlpha(ped) ~= 100 then
                        SetEntityAlpha(ped, 100, false)
                    end
                end
            end



            DisableControlAction(0, 0xA65EBAB4, true) -- LEFT ARROW
            DisableControlAction(0, 0xDEB34313, true) -- RIGHT ARROW
            DisableControlAction(0, 0xC7B5340A, true) -- ENTER
            DisableControlAction(0, 0x4A903C11, true) -- ESC / PAUSE
            DisableControlAction(0, 0x156F7119, true) -- BACKSPACE
            DisableControlAction(0, 0xD82E0BD2, true) -- P / PAUSE

            HideHudAndRadarThisFrame()

            local text = "<- Create Character ->"
            if CharacterData[Camera.SelectedChar] then
                text = ("<- %s %s ->"):format(CharacterData[Camera.SelectedChar].charinfo.firstname, CharacterData[Camera.SelectedChar].charinfo.lastname)
                RPX.DrawText("[~COLOR_RED~BACKSPACE~q~] TO DELETE", 0.50, 0.85, 0.5, 0.5, true, 255, 255, 255, 255, true)

                -- Delete the character slot
                if IsDisabledControlJustReleased(0, 0x156F7119) then
                    DeleteCharacter()
                    return
                end
            end
            
            RPX.DrawText(text, 0.50, 0.75, 0.5, 0.5, true, 255, 255, 255, 255, true)
            RPX.DrawText("[~COLOR_GOLD~ENTER~q~] TO SELECT", 0.50, 0.80, 0.5, 0.5, true, 255, 255, 255, 255, true)


            -- Change the selected ped left
            if IsDisabledControlJustReleased(0, 0xA65EBAB4) then
                if Camera.SelectedChar == 1 then
                    Camera.SelectedChar = 4
                else
                    Camera.SelectedChar = Camera.SelectedChar - 1
                end
            end

            -- Change the selected ped right
            if IsDisabledControlJustReleased(0, 0xDEB34313) then
                if Camera.SelectedChar == 4 then
                    Camera.SelectedChar = 1
                else
                    Camera.SelectedChar = Camera.SelectedChar + 1
                end
            end

            -- Select the character slot
            if IsDisabledControlJustReleased(0, 0xC7B5340A) then
                CharacterSelected()
                return
            end
        end
    end)
end
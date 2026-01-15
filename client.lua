-- Activez la sécurité des véhicules PNJ
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Récupérer tous les véhicules
        local vehicles = ESX.Game.GetVehicles()
        
        for _, vehicle in ipairs(vehicles) do
            local driver = GetPedInVehicleSeat(vehicle, -1)
            
            -- Vérifier si le conducteur est un PNJ
            if driver > 0 and not IsPedAPlayer(driver) then
                -- Empêcher le PNJ de renverser les joueurs
                SetPedCanBeKnockedOffVehicle(driver, false)
                SetPedCanBeDraggedOut(driver, false)
                SetPedSufferCriticalHits(driver, false)
                
                -- Activer la conduite prudente
                SetDriveTaskDrivingStyle(driver, 786603) -- Style de conduite prudent
                SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSteeringLock', 50.0)
                
                -- Détection d'obstacles
                local frontCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 5.0, 0.0)
                local rayHandle = StartShapeTestRay(
                    GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z,
                    frontCoords.x, frontCoords.y, frontCoords.z,
                    2, vehicle, 0
                )
                
                local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
                
                if hit then
                    -- Si un obstacle est détecté, faire freiner le véhicule
                    TaskVehicleTempAction(driver, vehicle, 6, 1000) -- Freiner
                    SetVehicleForwardSpeed(vehicle, 0.0)
                end
            end
        end
    end
end)

-- Empêcher les véhicules PNJ d'écraser les joueurs
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        
        if IsPedOnFoot(playerPed) then
            local playerCoords = GetEntityCoords(playerPed)
            local vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 10.0)
            
            for _, vehicle in ipairs(vehicles) do
                local driver = GetPedInVehicleSeat(vehicle, -1)
                
                if driver > 0 and not IsPedAPlayer(driver) then
                    -- Calculer la distance entre le joueur et le véhicule
                    local vehicleCoords = GetEntityCoords(vehicle)
                    local distance = #(playerCoords - vehicleCoords)
                    
                    if distance < 3.0 then
                        -- Si le véhicule est trop proche, le faire s'arrêter
                        TaskVehicleTempAction(driver, vehicle, 6, 2000) -- Freiner
                        SetVehicleForwardSpeed(vehicle, 0.0)
                    end
                end
            end
        end
    end
end)

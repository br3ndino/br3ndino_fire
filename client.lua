local activeFires = {}

RegisterNetEvent("fire:syncFires")
AddEventHandler("fire:syncFires", function(fires)
    activeFires = fires
end)

RegisterNetEvent("fire:updateFire")
AddEventHandler("fire:updateFire", function(fireID, spreadRate)
    if activeFires[fireID] then
        activeFires[fireID].spreadRate = spreadRate
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        for fireID, fireData in pairs(activeFires) do
            -- Spread fire
            if math.random(1, fireData.spreadRate) == 1 then
                local newFire = vector3(
                    fireData.location.x + math.random(-5, 5),
                    fireData.location.y + math.random(-5, 5),
                    fireData.location.z
                )
                TriggerServerEvent("fire:startFire", newFire)
            end

            -- Damage players near fire
            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                local coords = GetEntityCoords(ped)

                if #(coords - fireData.location) < 3.0 then
                    ApplyDamageToPed(ped, 10, false) -- Apply damage
                end
            end
        end
    end
end)

RegisterNetEvent("fire:extinguish")
AddEventHandler("fire:extinguish", function(fireID)
    if activeFires[fireID] then
        activeFires[fireID].size = activeFires[fireID].size - Config.ExtinguishRate
        if activeFires[fireID].size <= 0 then
            activeFires[fireID] = nil
        end
    end
end)

RegisterCommand("extinguish", function()
    for fireID, fireData in pairs(activeFires) do
        if #(GetEntityCoords(PlayerPedId()) - fireData.location) < 5.0 then
            TriggerServerEvent("fire:extinguish", fireID)
        end
    end
end, false)

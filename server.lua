QBCore = exports['qb-core']:GetCoreObject()

-- Fire spawn event
RegisterNetEvent("fire:startFire")
AddEventHandler("fire:startFire", function(coords)
    local fireID = #FireData.activeFires + 1
    local zone = "default_zone"  -- Or derive from coords if needed

    local spreadRate = Config.FireSpread.DefaultRate

    -- Store fire data
    FireData.activeFires[fireID] = {
        id = fireID,
        location = coords,
        spreadRate = spreadRate,
        active = true
    }

    -- Sync fires with all clients
    TriggerClientEvent("fire:syncFires", -1, FireData.activeFires)

    -- Dispatch fire alert for jobs (EMS, etc)
    for _, job in ipairs(Config.FireDispatchJobs) do
        TriggerEvent("ps-dispatch:server:fireAlert", job, coords)
    end
end)

-- Automatically start fires every 100ms if EMS is on duty
CreateThread(function()
    while true do
        Wait(100)  -- Check every 100ms

        -- Check if EMS is online and on duty
        local EMSCount = 0
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData.job.name == "ambulance" and Player.PlayerData.job.onduty then
                EMSCount = EMSCount + 1
            end
        end

        -- If EMS is on duty, trigger fire spawn
        if EMSCount > 0 then
            local fireLocation = Config.FireSpawn.Locations[1].coords  -- First location from Config
            TriggerEvent("fire:startFire", fireLocation)
        end
    end
end)


-- 🧯 Extinguish fire (with rekindle chance)
RegisterNetEvent("fire:extinguish")
AddEventHandler("fire:extinguish", function(fireID)
    if FireData.activeFires[fireID] then
        if math.random(1, 100) <= Config.FireSpread.RekindleChance then
            print("[FIRE] Rekindling fire at:", FireData.activeFires[fireID].location)
            TriggerEvent("fire:startFire", FireData.activeFires[fireID].location)
        else
            FireData.activeFires[fireID] = nil
            print("[FIRE] Fire extinguished at:", fireID)
        end

        -- 🔄 Sync fire updates to clients
        TriggerClientEvent("fire:syncFires", -1, FireData.activeFires)
    end
end)

-- 🔄 Automatically start fires every 15 minutes if EMS is online
CreateThread(function()
    while true do
        Wait(900000) -- ⏳ 15 minutes

        -- Check if EMS is online
        local EMSCount = 0
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData.job.name == "ambulance" and Player.PlayerData.job.onduty then
                EMSCount = EMSCount + 1
            end
        end

        -- 🌋 Fire starts only if EMS is online
        if EMSCount > 0 and math.random(1, 100) <= Config.FireSpawn.Chance then
            local randomIndex = math.random(1, #Config.FireSpawn.Locations)
            local fireLocation = Config.FireSpawn.Locations[randomIndex].coords
            local zone = Config.FireSpawn.Locations[randomIndex].zone

            print("[FIRE] Automatic fire starting at:", fireLocation)
            TriggerEvent("fire:startFire", fireLocation, zone)
            TriggerClientEvent("qb-core:Notify", -1, "A fire has broken out!", "error", 5000)
        end
    end
end)


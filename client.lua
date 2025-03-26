local activeFires = {}

RegisterNetEvent("fire:syncFires")
AddEventHandler("fire:syncFires", function(activeFires)
    for _, fire in pairs(activeFires) do
        if fire.active then
            -- Check if fire already exists in the area
            local fireObject = GetClosestObjectOfType(fire.location.x, fire.location.y, fire.location.z, 1.0, `prop_fire_extinguisher`, false, false, false)

            -- If no fire object is found, spawn a new fire
            if fireObject == 0 then
                local fireModel = `prop_fire_extinguisher`
                RequestModel(fireModel)
                while not HasModelLoaded(fireModel) do
                    Wait(100)
                end

                local fireEntity = CreateObject(fireModel, fire.location.x, fire.location.y, fire.location.z, true, true, true)
                SetEntityCoords(fireEntity, fire.location.x, fire.location.y, fire.location.z, false, false, false, false)
                SetEntityVisible(fireEntity, true, false)
                SetEntityInvincible(fireEntity, true)
            end
        end
    end
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

RegisterCommand("startfire", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    TriggerServerEvent('fire:startFire', coords)
end, false)

-- Listen for the fire:spawnFire event to spawn the fire at all clients
RegisterNetEvent('fire:spawnFire')
AddEventHandler('fire:spawnFire', function(coords)
    -- Debug message to ensure fire spawn is triggered at the right place
    print("Attempting to spawn fire at: ", coords)

    -- Create the fire at the specified coordinates
-- Function to actually spawn the fire at the given coordinates (example)
    function StartFireAtCoords(x, y, z)
        -- Example: Trigger a fire effect at the coordinates
        -- Replace with your actual fire effect spawning logic
        print("Attempting to spawn fire at: ", x, y, z)  -- Debug message to check coordinates
        local fireEffect = StartEntityFire(x, y, z)  -- Replace with your actual fire effect
    end

    -- Notify the player that the fire was started
    TriggerEvent("QBCore:Notify", "Fire has started at your location!", "success")
end)

-- Function to actually spawn the fire at the given coordinates (example)
function StartFireAtCoords(x, y, z)
    -- Example: Trigger a fire effect at the coordinates
    -- (Replace with your own fire spawning logic)
    local fireEffect = StartEntityFire(x, y, z)  -- Replace with your actual fire effect
end

RegisterNetEvent('fire:startFire')
AddEventHandler('fire:startFire', function(coords)
    local playerPed = PlayerPedId()
    local firePosition = coords

    -- Debugging log for fire position
    print("Attempting to spawn fire at: ", firePosition)

    -- Spawn the fire (this part depends on the method you're using)
    StartFire(firePosition)  -- Ensure you have a function to start the fire

    -- Debug message to ensure the fire starts
    TriggerEvent("QBCore:Notify", "Fire has started at your location!", "success")
end)


RegisterCommand("extinguish", function()
    for fireID, fireData in pairs(activeFires) do
        if #(GetEntityCoords(PlayerPedId()) - fireData.location) < 5.0 then
            TriggerServerEvent("fire:extinguish", fireID)
        end
    end
end, false)

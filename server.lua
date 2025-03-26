QBCore = exports['qb-core']:GetCoreObject()

local activeFires = {}

RegisterNetEvent("fire:startFire")
AddEventHandler("fire:startFire", function(location)
    local src = source
    local fireID = #activeFires + 1
    activeFires[fireID] = {
        location = location,
        size = 1
    }

    TriggerClientEvent("fire:syncFires", -1, activeFires)
    TriggerEvent("fire:checkWeatherImpact", fireID)

    -- Dispatch alert
    for _, job in ipairs(Config.FireDispatchJobs) do
        TriggerEvent("ps-dispatch:server:fireAlert", job, location)
    end
end)

RegisterNetEvent("fire:checkWeatherImpact")
AddEventHandler("fire:checkWeatherImpact", function(fireID)
    local zone = exports.avweather:getZone(activeFires[fireID].location)
    local weather = exports.avweather:getWeather(zone)

    local spreadRate = Config.FireSpreadRate.Default
    local windSpeed = exports.avweather:getWindSpeed(zone)

    -- Adjust spread rate based on weather
    if weather == "rain" then
        spreadRate = spreadRate - Config.FireSpreadRate.RainReduction
    elseif weather == "thunderstorm" then
        spreadRate = spreadRate - Config.FireSpreadRate.ThunderReduction
    end

    spreadRate = spreadRate - (Config.FireSpreadRate.WindSpeed[windSpeed] or 0)
    
    -- Sync to clients
    activeFires[fireID].spreadRate = spreadRate
    TriggerClientEvent("fire:updateFire", -1, fireID, spreadRate)
end)

RegisterNetEvent("fire:extinguish")
AddEventHandler("fire:extinguish", function(fireID)
    if activeFires[fireID] then
        activeFires[fireID].size = activeFires[fireID].size - Config.ExtinguishRate
        if activeFires[fireID].size <= 0 then
            activeFires[fireID] = nil
            TriggerClientEvent("fire:syncFires", -1, activeFires)
        else
            if math.random(1, 100) <= Config.RekindleChance then
                TriggerEvent("fire:startFire", activeFires[fireID].location)
            end
        end
    end
end)

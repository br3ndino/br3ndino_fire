QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("fire:startFire")
AddEventHandler("fire:startFire", function(location)
    local fireID = FireData.startFire(location)

    TriggerClientEvent("fire:syncFires", -1, FireData.activeFires)
    TriggerEvent("fire:checkWeatherImpact", fireID)

    -- Dispatch alert
    for _, job in ipairs(Config.FireDispatchJobs) do
        TriggerEvent("ps-dispatch:server:fireAlert", job, location)
    end
end)

RegisterNetEvent("fire:checkWeatherImpact")
AddEventHandler("fire:checkWeatherImpact", function(fireID)
    local zone = exports.avweather:getZone(FireData.activeFires[fireID].location)
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
    FireData.activeFires[fireID].spreadRate = spreadRate
    FireData.syncFires()
end)

RegisterNetEvent("fire:extinguish")
AddEventHandler("fire:extinguish", function(fireID)
    if FireData.extinguishFire(fireID) then
        FireData.syncFires()
    else
        if FireData.rekindleFire(fireID) then
            TriggerEvent("fire:startFire", FireData.activeFires[fireID].location)
        end
    end
end)

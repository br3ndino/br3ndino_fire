FireData = {}

-- Active fires storage
FireData.activeFires = {}

-- Function to start a fire
function FireData.startFire(location)
    local fireID = #FireData.activeFires + 1
    FireData.activeFires[fireID] = {
        location = location,
        size = 1
    }
    return fireID
end

-- Function to extinguish a fire
function FireData.extinguishFire(fireID)
    if FireData.activeFires[fireID] then
        FireData.activeFires[fireID].size = FireData.activeFires[fireID].size - Config.ExtinguishRate
        if FireData.activeFires[fireID].size <= 0 then
            FireData.activeFires[fireID] = nil
            return true -- Fire is fully extinguished
        else
            return false -- Fire is still burning
        end
    end
    return false -- Fire ID doesn't exist
end

-- Function to check for rekindling
function FireData.rekindleFire(fireID)
    if math.random(1, 100) <= Config.RekindleChance then
        return true -- Rekindle the fire
    end
    return false
end

-- Function to sync fires with clients
function FireData.syncFires()
    TriggerClientEvent("fire:syncFires", -1, FireData.activeFires)
end

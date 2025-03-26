Config = {}

-- Default fire spread rate and reduction in rain/storms
Config.FireSpreadRate = {
    Default = 15,  -- Base spread rate (seconds)
    WindSpeed = {   -- How much wind affects spread
        [0] = 15,   -- No wind
        [1] = 12,
        [2] = 10,
        [3] = 8,
        [4] = 5,
        [5] = 3,    -- High wind
    },
    RainReduction = 5,    -- Reduce spread rate when raining
    ThunderReduction = 8  -- Reduce spread rate in thunderstorms
}

-- Fire extinguishing settings
Config.ExtinguishRate = 5  -- How fast a fire is put out
Config.RekindleChance = 25 -- % chance of rekindling if not fully extinguished

-- Dispatch settings
Config.FireDispatchJobs = {"fire", "police"}  -- Jobs that get alerts

-- Fire locations
Config.FireLocations = {
    vector3(200.0, -1000.0, 30.0),
    vector3(350.0, -1200.0, 40.0),
    vector3(500.0, -1300.0, 50.0)
}

Config = {}

-- Fire spawn settings (adjusted to spawn fires with EMS on duty)
Config.FireSpawn = {
    Locations = {
        { coords = vector3(-1403.3214, -523.0154, 31.6289), zone = "santos" }  -- Adjusted for only one location
    },
    Chance = 100,  -- Set chance to 100% to ensure fire always spawns when EMS is on duty
}

-- Fire spread settings based on weather (default rates + modifiers)
Config.FireSpread = {
    DefaultRate = 10,  -- Default spread rate for fire
    RainModifier = 3,  -- Reduces spread in rain
    ThunderModifier = 5,  -- Reduces spread in thunderstorms
    MinRate = 1,  -- Minimum spread rate to ensure the fire spreads at a reasonable pace
}

-- Jobs that should receive fire alerts (EMS, firefighters, etc.)
Config.FireDispatchJobs = {
    "ambulance",  -- EMS job
    "firefighter"  -- Firefighter job
}

-- Rekindle chance after fire is extinguished (for random rekindling)
Config.FireSpread.RekindleChance = 30  -- Percentage chance to rekindle fire after extinguishing


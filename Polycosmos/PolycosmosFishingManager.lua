ModUtil.Mod.Register("PolycosmosFishingManager")

local FishNames = 
    {
    Fish_Tartarus_Common_01 = "Hellfish",
    Fish_Tartarus_Rare_01 = "Knucklehead",
    Fish_Tartarus_Legendary_01 = "Scyllascion",
    Fish_Asphodel_Common_01 = "Slavug",
    Fish_Asphodel_Rare_01 = "Chrustacean",
    Fish_Asphodel_Legendary_01 = "Flameater",
    Fish_Elysium_Common_01 = "Chlam",
    Fish_Elysium_Rare_01 = "Charp",
    Fish_Elysium_Legendary_01 = "Seamare",
    Fish_Styx_Common_01 = "Gupp",
    Fish_Styx_Rare_01 = "Scuffer",
    Fish_Styx_Legendary_01 = "Stonewhal",
    Fish_Chaos_Common_01 = "Mati",
    Fish_Chaos_Rare_01 = "Projelly",
    Fish_Chaos_Legendary_01 = "Voidskate",
    Fish_Surface_Common_01 = "Trout",
    Fish_Surface_Rare_01 = "Bass",
    Fish_Surface_Legendary_01 = "Sturgeon"
    }
local SurfaceFish = 
    {
    Fish_Surface_Common_01 = true,
    Fish_Surface_Rare_01 = true,
    Fish_Surface_Legendary_01 = true
    }

ModUtil.Path.Wrap("RecordFish", function(baseFunc, fishName)
    local fishSanity = GameState.ClientGameSettings["FishSanity"]
    if fishSanity == 0 then
        return baseFunc(fishName)
    end

    local firstCatch = GameState.TotalCaughtFish == nil or GameState.TotalCaughtFish[fishName] == nil
    baseFunc(fishName)
    if not firstCatch then
        return 
    end
    if SurfaceFish[fishName] and fishSanity ~= 2 then
        return
    end
    PolycosmosEvents.ProcessLocationCheck("Catch "..FishNames[fishName], true)
    
end)

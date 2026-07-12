ModUtil.Mod.Register("PolycosmosBoonManager")
PolycosmosBoonManager = {}

local boonTypes = {
    "ZeusUpgrade",
    "AthenaUpgrade",
    "PoseidonUpgrade",
    "AresUpgrade",
    "AphroditeUpgrade",
    "ArtemisUpgrade",
    "DionysusUpgrade",
    "DemeterUpgrade",
    "HermesUpgrade"
}

local boonItemNames = {}
for _, type in pairs(boonTypes) do
    boonItemNames[type] = type:gsub("Upgrade", " Boons Unlock")
end

PolycosmosBoonManager.BoonUnlocks = {}
for type, item in pairs(boonItemNames) do
    PolycosmosBoonManager.BoonUnlocks[item] = false
end


--make sure there's one random starting god or the game will break (i think) (verify this later)
--(also probably adjust this to just precollect a random god starting item i guess so that the item placement logic is okay)
ModUtil.LoadOnce(function()
    local startingGod = GetRandomValue(boonTypes)
    PolycosmosBoonManager.BoonUnlocks[boonItemNames[startingGod]] = true
end)


function PolycosmosBoonManager.UnlockBoonItem(name)
    PolycosmosBoonManager.BoonUnlocks[name] = true
end

function PolycosmosBoonManager.IsGodUnlocked(lootName)
    if Contains(boonTypes, lootName) then
        return PolycosmosBoonManager.BoonUnlocks[boonItemNames[lootName]]
    end

    return true
end

function PolycosmosBoonManager.IsBoonItem(name)
    for _, type in pairs(boonItemNames) do
        if type == name then
            return true
        end
    end
    return false
end

ModUtil.Path.Wrap("GetEligibleLootNames", function(baseFunc, excludeLootNames)
    local output = baseFunc(excludeLootNames)

    for i = #output, 1, -1 do
        local lootName = output[i]
        if not PolycosmosBoonManager.IsGodUnlocked(lootName) then
            table.remove( output, i )
        end
    end
    DebugPrint({ Text = "Eligible gods: " .. tostring(#output)})

    return output
end)

function PolycosmosBoonManager.TestBoonPool()
    local lootNames = GetEligibleLootNames()

    DebugPrint({ Text = "Eligible boons:" })

    for _, lootName in ipairs(lootNames) do
        DebugPrint({ Text = lootName })
    end
end

OnControlPressed{ "Rush", function(triggerArgs)
    PolycosmosBoonManager.TestBoonPool()
end }
OnControlPressed{ "Shout", function(triggerArgs)

    PolycosmosBoonManager.UnlockBoonItem("Zeus Boons Unlock")

    local eligible = GetEligibleLootNames()

    DebugPrint({ Text = "Eligible gods after unlock:" })

    for _, lootName in pairs(eligible) do
        DebugPrint({ Text = lootName })
    end

end }
OnControlPressed{ "Attack2", function(triggerArgs)

    for id, unit in pairs( ActiveEnemies ) do
        Kill( unit )
    end

    DebugPrint({ Text = "Killed all enemies" })

end }
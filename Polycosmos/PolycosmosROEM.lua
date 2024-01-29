ModUtil.Mod.Register( "PolycosmosROEM" )

local bufferTime = 2

config = {
    -- below enables are for debugging
    -- comparisons (logic)
    SetupHadesSpawnOptionsEnabled = true,
    SelectHarpySupportAIsEnabled = true,
    GetWeaponAIDataEnabled = true,
    SetupEnemyObjectEnabled = true,

    -- comparisons (voice lines, achievement)
    IsGameStateEligibleEnabled = true,

    -- arrays / direct
    ActivatePrePlacedByShrineLevelEnabled = true,
    BossIntroElysiumEnabled = true,
    StagedAIEnabled = true,
    ChooseNextRoomDataEnabled = true,

    -- Reverse the cost of Extreme Measures
    ReverseCostTableEnabled = true,
}

--------------------

function PolycosmosROEM.LoadBossData( message )
    if (not StyxScribeShared.Root.GameSettings) then
        wait( bufferTime )
        print("Cant load REOM because of lack of data. Sorry.")
        PolycosmosROEM.LoadBossData("")
        return
    end
    if (StyxScribeShared.Root.GameSettings['ReverseOrderEM'] == 0) then
        print("Rever order EM is off. Not loaded.")
        return
    end

    print("starting to load ROEM")

	
	if config.ReverseCostTableEnabled then
		ModUtil.LoadOnce(function()
			MetaUpgradeData.BossDifficultyShrineUpgrade.CostTable = {4,3,2,1}
		end)
	end
	
    -- high priority
    -- determines which set of Hades' mobs are summoned (EM or non-EM)
    if config.SetupHadesSpawnOptionsEnabled then
        ModUtil.Path.Context.Wrap("SetupHadesSpawnOptions", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    return upgradeNameValue + 3
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    -- high priority
    -- determines which Harpies are summoned (EM or non-EM)
    if config.SelectHarpySupportAIsEnabled then
        ModUtil.Path.Context.Wrap("SelectHarpySupportAIs", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    return upgradeNameValue - 3
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    -- low priority
    -- determines whether the HarpyLightning attack in particular has a higher "fire rate," among other things.
    if config.GetWeaponAIDataEnabled then
        ModUtil.Path.Context.Wrap("GetWeaponAIData", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local locals = ModUtil.Locals.Stacked(2)
                local enemy = locals.enemy
                local requiredShrineLevel = WeaponData[enemy.WeaponName].ShrineMetaUpgradeRequiredLevel or 1
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    return upgradeNameValue + (2 * requiredShrineLevel - 5)
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    -- high priority
    -- determines the max health increase from EM or non-EM; also determines if Hades' casts emit a slowing aura, and if Hades has a phase 3.
    if config.SetupEnemyObjectEnabled then
        ModUtil.Path.Context.Wrap("SetupEnemyObject", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local locals = ModUtil.Locals.Stacked(2)
            --  local requiredShrineLevel = locals.requiredShrineLevel or 1
                local newEnemy = locals.newEnemy
                local requiredShrineLevel = newEnemy.ShrineMetaUpgradeRequiredLevel or 1
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    return upgradeNameValue + (2 * requiredShrineLevel - 5)
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    -- med priority
    -- determines voice lines, achievements, etc. based on EM level, among other things.
    if config.IsGameStateEligibleEnabled then
        ModUtil.Path.Context.Wrap("IsGameStateEligible", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local locals = ModUtil.Locals.Stacked(2)
                local requirements = locals.requirements
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    -- RequiredInactiveMetaUpgrade only affects Furies
                    if requirements.RequiredInactiveMetaUpgrade ~= nil then
                        return upgradeNameValue - 3
                    elseif requirements.RequiredMinActiveMetaUpgradeLevel ~= nil then
                        return upgradeNameValue - 5
                    elseif requirements.RequiredMaxActiveMetaUpgradeLevel ~= nil then
                        return upgradeNameValue - 5
                    elseif requirements.RequiredActiveMetaUpgradeLevel ~= nil then
                        return 5 - upgradeNameValue
                    -- RequiredActiveMetaUpgrade does not use "BossDifficultyShrineUpgrade", but if it does start using it, we'd need another statement here.
                    end            
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    -- high priority
    -- determines Theseus & Asterius (Minotaur) behavior
    if config.ActivatePrePlacedByShrineLevelEnabled then
        ModUtil.Path.Context.Wrap("ActivatePrePlacedByShrineLevel", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    -- below needs to change if other bosses start calling this function
                    return math.min(upgradeNameValue + 1, 4)
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    -- high priority
    -- determines Theseus & Asterius (Minotaur) behavior
    if config.BossIntroElysiumEnabled then
        ModUtil.Path.Context.Wrap("BossIntroElysium", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    -- below needs to change if other bosses start calling this function
                    return math.min(upgradeNameValue + 1, 4)
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    -- high priority
    -- determines behaviors of Lernie (Hydra) and Hades based on Pact selection, among other things.
    if config.StagedAIEnabled then
        ModUtil.Path.Context.Wrap("StagedAI", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local locals = ModUtil.Locals.Stacked(2)
                local enemy = locals.enemy
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    -- below needs to change if other bosses start calling this function
                    if enemy.Name == "HydraHeadImmortal"
                    or enemy.Name == "HydraHeadImmortalLavamaker"
                    or enemy.Name == "HydraHeadImmortalSummoner"
                    or enemy.Name == "HydraHeadImmortalSlammer"
                    or enemy.Name == "HydraHeadImmortalWavemaker"
                    then
                        return math.max(upgradeNameValue - 1, 0)
                    elseif enemy.Name == "Hades" then
                        return math.min(upgradeNameValue + 3, 4)
                        -- return 4
                    end
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    -- high priority
    -- determines whether Lernie's (Hydra's) EM2 room is the next room or not, among other things.
    if config.ChooseNextRoomDataEnabled then
        ModUtil.Path.Context.Wrap("ChooseNextRoomData", function()
            ModUtil.Path.Wrap("GetNumMetaUpgrades", function(baseFunc, upgradeName, args)
                local upgradeNameValue = baseFunc(upgradeName, args)
                if upgradeName == "BossDifficultyShrineUpgrade" and upgradeNameValue > 0 and upgradeNameValue < 4 then
                    -- below needs to change if other bosses start calling this function
                    return math.max(upgradeNameValue - 1, 0)
                end
                return upgradeNameValue
            end, ReverseOrderEM)
        end, ReverseOrderEM)
    end

    print("Reverse order EM loaded correctly.")
end

---------------

--Set hook to load Boss data once informacion of setting is loaded
styx_scribe_recieve_prefix = "Client to Polycosmos:"
StyxScribe.AddHook( PolycosmosROEM.LoadBossData, styx_scribe_recieve_prefix.."Data package finished", PolycosmosROEM )

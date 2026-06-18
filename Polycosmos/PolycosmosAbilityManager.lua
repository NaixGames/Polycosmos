ModUtil.Mod.Register("PolycosmosAbilityManager")

PolycosmosAbilityManager = {}

function PolycosmosAbilityManager.Initialize()
    if PolycosmosAbilityManager.UnlockedAbilities == nil then
        PolycosmosAbilityManager.UnlockedAbilities = {}
    end
end

function PolycosmosAbilityManager.HasAbility(name)
    PolycosmosAbilityManager.Initialize()
    return PolycosmosAbilityManager.UnlockedAbilities[name] == true
end

function PolycosmosAbilityManager.UnlockAbility(name)
    PolycosmosAbilityManager.Initialize()
    PolycosmosAbilityManager.UnlockedAbilities[name] = true
	
	if name == "Dash" and HeroHasTrait("NoDashTrait") then
		RemoveTrait(CurrentRun.Hero, "NoDashTrait")
		UpdateHeroTraitDictionary()
	end
	if name == "Special" and HeroHasTrait("NoSpecialTrait") then
		RemoveTrait(CurrentRun.Hero, "NoSpecialTrait")
		UpdateHeroTraitDictionary()
	end
	if name == "Cast" and HeroHasTrait("NoCastTrait") then
		RemoveTrait(CurrentRun.Hero, "NoCastTrait")
		UpdateHeroTraitDictionary()
	end
	if name == "Call" and HeroHasTrait("NoCallTrait") then
		RemoveTrait(CurrentRun.Hero, "NoCallTrait")
		UpdateHeroTraitDictionary()
	end
end

ModUtil.LoadOnce(function ()
    PolycosmosAbilityManager.Initialize()
end)

function PolycosmosAbilityManager.IsAbilityItem(name)
    return name == "Dash"
        or name == "Special"
        or name == "Cast"
        or name == "Call"
end

TraitData.NoDashTrait =
{
    Hidden = true,
	Name = "NoDashTrait",
    PropertyChanges =
    {
		{
            WeaponNames = WeaponSets.HeroRushWeapons,
            WeaponProperty = "Control",
            ChangeValue = "null",
            ChangeType = "Absolute",
        },
	},
}

TraitData.NoSpecialTrait = 
{
    Hidden = true,
	Name = "NoSpecialTrait",
    PropertyChanges =
    {
        {
            WeaponNames = WeaponSets.HeroSecondaryWeapons,
            WeaponProperty = "Control",
            ChangeValue = "null",
            ChangeType = "Absolute",
        },
	},
}

TraitData.NoCastTrait =
{
    Hidden = true,
	Name = "NoCastTrait",
    PropertyChanges =
    {
        {
            WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
            WeaponProperty = "Control",
            ChangeValue = "null",
            ChangeType = "Absolute",
        },
	},
}

TraitData.NoCallTrait =
{
    Hidden = true,
	Name = "NoCallTrait",
	SuperGainMultiplier =
	{
		BaseMin = 0,
		BaseMax = 0,
		SourceIsMultiplier = true,
	},
}

ModUtil.WrapBaseFunction("SetupHeroObject", function(baseFunc, currentRun, applyLuaUpgrades)

    baseFunc(currentRun, applyLuaUpgrades)

    local hero = currentRun.Hero
    if not hero then
        return
    end


    local added = false

    -- DASH
    if not PolycosmosAbilityManager.HasAbility("Dash") and not HeroHasTrait("NoDashTrait") then
        AddTraitToHero({ TraitName = "NoDashTrait" })
        added = true
    end

    -- SPECIAL
    if not PolycosmosAbilityManager.HasAbility("Special") and not HeroHasTrait("NoSpecialTrait") then
        AddTraitToHero({ TraitName = "NoSpecialTrait" })
        added = true
    end

    -- CAST
    if not PolycosmosAbilityManager.HasAbility("Cast") and not HeroHasTrait("NoCastTrait") then
        AddTraitToHero({ TraitName = "NoCastTrait" })
        added = true
    end

    -- CALL
    if not PolycosmosAbilityManager.HasAbility("Call") and not HeroHasTrait("NoCallTrait") then
        AddTraitToHero({ TraitName = "NoCallTrait" })
        hero.SuperMeter = 0
        added = true
    end

    if added then
        ApplyTraitUpgrade(hero, applyLuaUpgrades)
        ApplyAllTraitWeapons(hero)
		UpdateHeroTraitDictionary()
    end

end)


-- Fix TraitData entry fields so we can use them
local function NormalizeRequiredFalseTraits(TraitData)

    -- Start with existing plural
    TraitData.RequiredFalseTraits = TraitData.RequiredFalseTraits or {}

    -- Convert singular → plural
    if TraitData.RequiredFalseTrait ~= nil then
        table.insert(TraitData.RequiredFalseTraits, TraitData.RequiredFalseTrait)
        TraitData.RequiredFalseTrait = nil
    end

    -- Convert typo variant → plural
    if TraitData.RequiresFalseTrait ~= nil then
        table.insert(TraitData.RequiredFalseTraits, TraitData.RequiresFalseTrait)
        TraitData.RequiresFalseTrait = nil
    end

end


ModUtil.LoadOnce(function()
    
    for traitName, traitData in pairs(TraitData) do
		-- restrict to just boons and hammer upgrades
		if traitData.RarityLevels ~= nil and traitData.IsWeaponEnchantment ~= true or (traitData.Frame ~= nil and traitData.Frame == "Hammer") then
			local function AddReq(req)				
				traitData.RequiredFalseTraits = traitData.RequiredFalseTraits or {}
				if not Contains(traitData.RequiredFalseTraits, req) then
					table.insert(traitData.RequiredFalseTraits, req)
				end
			end
			
			if string.find(traitName, "Rush") or string.find(traitName, "Dash") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq("NoDashTrait")
				DebugPrint({Text = "Blocked:"..traitName.." = "..tostring(Contains(traitData.RequiredFalseTraits, "NoDashTrait"))})
			end
			if string.find(traitName, "Secondary") or string.find(traitName, "Special") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq("NoSpecialTrait")
				DebugPrint({Text = "Blocked:"..traitName.." = "..tostring(Contains(traitData.RequiredFalseTraits, "NoSpecialTrait"))})
			end
			if string.find(traitName, "Ranged") or string.find(traitName, "Cast") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq("NoCastTrait")
				DebugPrint({Text = "Blocked:"..traitName.." = "..tostring(Contains(traitData.RequiredFalseTraits, "NoCastTrait"))})
			end
			if string.find(traitName, "Shout") or string.find(traitName, "Super") or string.find(traitName, "Wrath") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq("NoCallTrait")
				DebugPrint({Text = "Blocked:"..traitName.." = "..tostring(Contains(traitData.RequiredFalseTraits, "NoCallTrait"))})
			end
			
		end
			
    end

end)

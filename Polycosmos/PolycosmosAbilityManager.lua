ModUtil.Mod.Register("PolycosmosAbilityManager")

PolycosmosAbilityManager = {}

local abilityMap = PolycosmosAbilityData.AbilityMap
local weaponTraits = PolycosmosAbilityData.WeaponTraits
local otherAttackEffects = PolycosmosAbilityData.OtherAttackEffects
local otherSpecialEffects = PolycosmosAbilityData.OtherSpecialEffects
local function RemoveAbilityTrait(traitName)
    RemoveTrait(CurrentRun.Hero, traitName)

    local traitData = TraitData[traitName]
    local traitWeapons = nil
    if traitData and traitData.PropertyChanges and traitData.PropertyChanges[1] then
        traitWeapons = traitData.PropertyChanges[1].WeaponNames
    end
    if traitWeapons then
        for _, weaponName in pairs(traitWeapons) do
            if CurrentRun.Hero.Weapons[weaponName] then
                UnequipWeapon({ DestinationId = CurrentRun.Hero.ObjectId, Name = weaponName })
                EquipWeapon({ DestinationId = CurrentRun.Hero.ObjectId, Name = weaponName })
            end
        end
    end
end


function PolycosmosAbilityManager.Initialize()
    PolycosmosAbilityManager.UnlockedAbilities = PolycosmosAbilityManager.UnlockedAbilities or {}
end

function PolycosmosAbilityManager.HasAbility(name)
    PolycosmosAbilityManager.Initialize()
    return PolycosmosAbilityManager.UnlockedAbilities[name] == true
end

function PolycosmosAbilityManager.UnlockAbility(name)

    PolycosmosAbilityManager.Initialize()
    PolycosmosAbilityManager.UnlockedAbilities[name] = true
    local trait = abilityMap[name]

    if trait and HeroHasTrait(trait) then

        RemoveAbilityTrait(trait)
        UpdateHeroTraitDictionary()

    elseif name == "Attack" then
        for weaponName, weaponData in pairs(weaponTraits) do
            if HeroHasTrait(weaponData.Attack) then
                RemoveAbilityTrait(weaponData.Attack)
            end
            local specificName = weaponName:gsub("Weapon", "") .. " Attack"
            PolycosmosAbilityManager.UnlockedAbilities[specificName] = true
        end
        UpdateHeroTraitDictionary()
        return
    elseif name == "Special" then
        for weaponName, weaponData in pairs(weaponTraits) do
            if HeroHasTrait(weaponData.Special) then
                RemoveAbilityTrait(weaponData.Special)
            end
            local specificName = weaponName:gsub("Weapon", "") .. " Special"
            PolycosmosAbilityManager.UnlockedAbilities[specificName] = true
        end
        UpdateHeroTraitDictionary()
    end
end

ModUtil.LoadOnce(function ()
    PolycosmosAbilityManager.Initialize()
end)

function PolycosmosAbilityManager.IsAbilityItem(name)
    return abilityMap[name] ~= nil
        or name == "Attack"
        or name == "Special"
end

-- used to fix TraitData entry fields for boons and upgrades so we can use them safely
local function NormalizeRequiredFalseTraits(TraitData)

    -- Start with existing plural
    TraitData.RequiredFalseTraits = TraitData.RequiredFalseTraits or {}

    -- Convert singular -> plural
    if TraitData.RequiredFalseTrait ~= nil then
        table.insert(TraitData.RequiredFalseTraits, TraitData.RequiredFalseTrait)
        TraitData.RequiredFalseTrait = nil
    end

    -- Convert typo -> plural
    if TraitData.RequiresFalseTrait ~= nil then
        table.insert(TraitData.RequiredFalseTraits, TraitData.RequiresFalseTrait)
        TraitData.RequiresFalseTrait = nil
    end

end

ModUtil.WrapBaseFunction("StartRoomPresentation", function(baseFunc, currentRun, currentRoom, metaPointsAwarded)

    baseFunc(currentRun, currentRoom, metaPointsAwarded)

    --section 1:
    --make sure the player starts with all blocking traits unless they have the appropriate ability unlocked
    local hero = currentRun.Hero
    if not hero then
        return
    end

    local added = false
    for abilityName, traitName in pairs(abilityMap) do
        if not PolycosmosAbilityManager.HasAbility(abilityName) and not HeroHasTrait(traitName) then
            AddTraitToHero({ TraitName = traitName })
            added = true
            if abilityName == "Call" then
                hero.SuperMeter = 0
            end
        end
    end

    if added then
        UpdateHeroTraitDictionary()
    end
end)
ModUtil.WrapBaseFunction("SetupHeroObject", function(baseFunc, currentRun, applyLuaUpgrades)

    baseFunc(currentRun, applyLuaUpgrades)
    --section 2:
    --filter the available boons, hammer upgrades, and chaos effects based on the traits the player currently has
    local equippedWeapon

    --pull the currently equipped weapon
    for weaponName in pairs(currentRun.Hero.Weapons) do
        if Contains(WeaponSets.HeroMeleeWeapons, weaponName) then
            equippedWeapon = weaponName
            break
        end
    end

    --restrict available boons based on what abilities are available
    --attack and special depend on the player's current weapon and that weapon's ability matching up. 
    --if they don't have the ability for their current weapon, no boons for them. 
    for traitName, traitData in pairs(TraitData) do
		-- restrict to just boons and hammer upgrades
		if (traitData.RarityLevels ~= nil and traitData.IsWeaponEnchantment ~= true) or traitData.Frame == "Hammer" then
            local function AddReq(req)				
				traitData.RequiredFalseTraits = traitData.RequiredFalseTraits or {}
				if not Contains(traitData.RequiredFalseTraits, req) then
					table.insert(traitData.RequiredFalseTraits, req)
				end
			end
			
            local function RemoveReq(req)
                if traitData.RequiredFalseTraits == nil then
                        return
                end
                for i = #traitData.RequiredFalseTraits, 1, -1 do
                    if traitData.RequiredFalseTraits[i] == req then
                        table.remove(traitData.RequiredFalseTraits, i)
                    end
                end
            end
            
            for _, traits in pairs(weaponTraits) do
                RemoveReq(traits.Attack)
                RemoveReq(traits.Special)
            end

			if string.find(traitName, "Rush") or string.find(traitName, "Dash") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq("NoDashTrait")
			end
			if (string.find(traitName, "Weapon") or string.find(traitName, "Attack")) and not (string.find(traitName, "Chaos") or traitData.Frame == "Hammer") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq(weaponTraits[equippedWeapon].Attack)
			end
            if otherAttackEffects[traitName] then
                NormalizeRequiredFalseTraits(traitData)
                AddReq(weaponTraits[equippedWeapon].Attack)
            end
			if (string.find(traitName, "Secondary") or string.find(traitName, "Special")) and (traitData.Frame ~= "Hammer") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq(weaponTraits[equippedWeapon].Special)
			end
            if otherSpecialEffects[traitName] then
                NormalizeRequiredFalseTraits(traitData)
                AddReq(weaponTraits[equippedWeapon].Special)
            end
			if string.find(traitName, "Ranged") or string.find(traitName, "Cast") or (traitName == "ChaosBlessingAmmoTrait" or traitName == "ChaosCurseAmmoUseDelayTrait") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq("NoCastTrait")
			end
			if string.find(traitName, "Shout") or string.find(traitName, "Super") or string.find(traitName, "Wrath") then
				NormalizeRequiredFalseTraits(traitData)
				AddReq("NoCallTrait")
			end
			
		end
			
    end

end)

ModUtil.Mod.Register( "PolycosmosAspectsManager" )



ModUtil.Table.Merge( WeaponUpgradeData, {
		SwordWeapon = {
			{},
			{},
			{},
			{
				GameStateRequirements = {
					RequiredCosmetics = {"SwordHiddenAspect"},
				}
			}
		},
		BowWeapon = {
			{},
			{},
			{},
			{
				GameStateRequirements = {
					RequiredCosmetics = {"BowHiddenAspect"},
				}
			}
		},
		ShieldWeapon = {
			{},
			{},
			{},
			{
				GameStateRequirements = {
					RequiredCosmetics = {"ShieldHiddenAspect"},
				}
			}
		},
		SpearWeapon = {
			{},
			{},
			{},
			{
				GameStateRequirements = {
					RequiredCosmetics = {"SpearHiddenAspect"},
				}
			}
		},
		GunWeapon = {
			{},
			{},
			{},
			{
				GameStateRequirements = {
					RequiredCosmetics = {"GunHiddenAspect"},
				}
			}
		},
		FistWeapon = {
			{},
			{},
			{},
			{
				GameStateRequirements = {
					RequiredCosmetics = {"FistHiddenAspect"},
				}
			}
		},
})


local HiddenAspects ={
	"SwordHiddenAspect",
	"BowHiddenAspect",
	"SpearHiddenAspect",
	"ShieldHiddenAspect",
	"FirstHiddenAspect",
	"GunHiddenAspect",
}

ModUtil.LoadOnce(function ()
		-- removes requirements for upgrading weapons
        GameState.Flags["AspectsUnlocked"] = true
		-- unlocks sword hidden aspect
        TextLinesRecord["NyxRevealsArthurAspect01"] = true 
        -- unlocks spear hidden aspect
        TextLinesRecord["AchillesRevealsGuanYuAspect01"] = true
        -- unlocks shield hidden aspect
        TextLinesRecord["ChaosRevealsBeowulfAspect01"] = true
        -- unlocks bow hidden aspect
        TextLinesRecord["ArtemisRevealsRamaAspect01"] = true
        -- unlocks fist hidden aspect
        TextLinesRecord["MinotaurRevealsGilgameshAspect01"] = true
        -- unlocks gun hidden aspect
        TextLinesRecord["ZeusRevealsLuciferAspect01"] = true 
end)

function PolycosmosAspectsManager.UnlockAllHiddenAspects( message )
	if (StyxScribeShared.Root.GameSettings["HiddenAspectSanity"] == 0) then
		for k, name in ipairs(HiddenAspects) do
			PolycosmosAspectsManager.UnlockHiddenAspect(name, false)
		end
	end
end

StyxScribe.AddHook( PolycosmosAspectsManager.UnlockAllHiddenAspects, styx_scribe_recieve_prefix.."Data finished", PolycosmosAspectsManager )


function PolycosmosAspectsManager.IsHiddenAspect(itemName)
	return PolycosmosUtils.HasValue(HiddenAspects, itemName)
end

function PolycosmosAspectsManager.UnlockHiddenAspect(aspectName, shouldPrint)
	if (GameState.CosmeticsAdded[aspectName] == nil or GameState.CosmeticsAdded[aspectName] == false) then
		AddCosmetic(aspectName)
		if (shouldPrint == true) then
			PolycosmosMessages.PrintToPlayer("Recieved hidden aspect " .. aspectName)
		end
	end
end



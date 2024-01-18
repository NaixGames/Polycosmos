-- I want to replace the GetNumMetaUpgrades function in RunManager.lua with this one.
-- I want the function to know when "BossDifficultyShrineUpgrade" specifically is getting called.
-- This is important because sometimes, ShrineMetaUpgradeName is "MinibossShrineUpgrade" instead, and we want to ignore the "5 minus" function when that's called. 

function GetNumMetaUpgrades( upgradeName, args )
	if CurrentRun and CurrentRun.Hero and not CurrentRun.Hero.IsDead and CurrentRun.CurrentRoom and not CurrentRun.CurrentRoom.TestRoom and CurrentRun.MetaUpgradeCache then
		-- if-then statement to check if Extreme Measures levels are in cache already, return "5 minus"
		if upgradeName == "BossDifficultyShrineUpgrade" then
			return (5 - CurrentRun.MetaUpgradeCache[upgradeName]) or 0
		end		
		return CurrentRun.MetaUpgradeCache[upgradeName] or 0
	end
	args = args or {}
	if not MetaUpgradeData[upgradeName] then
		return 0
	end

	if not args.UnModified and not IsMetaUpgradeActive( upgradeName ) then
		return 0
	end

	if CurrentRun.MetaUpgrades ~= nil then
		-- Run override
		return CurrentRun.MetaUpgrades[upgradeName] or 0
	end

	-- if-then statement to check if we're using Extreme Measures levels, return "5 minus"
	if upgradeName == "BossDifficultyShrineUpgrade" then
		return (5 - CurrentRun.MetaUpgrades[upgradeName]) or 0
	end

	return GameState.MetaUpgrades[upgradeName] or 0
end
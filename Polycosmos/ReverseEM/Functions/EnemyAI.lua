-- I just want to change two comparison statements here, since they are hard-coded.
-- These need to be changed to these values specifically based on the new GetNumMetaUpgrades function
--      SetupHadesSpawnOptions from >= 4 to >= 1
--      SelectHarpySupportAIs from > 0 to == 1

function SetupHadesSpawnOptions( enemy )
	local enemySetPrefix = "EnemiesHades"
    -- change comparison from >=4 to >=1
	if GetNumMetaUpgrades(enemy.ShrineMetaUpgradeName) >= 1 then
		enemySetPrefix = "EnemiesHadesEM"
	end
	enemy.SpawnOptions = {}

	local spawnOptionsLarge = EnemySets[enemySetPrefix.."Large"]
	local spawnOptionsSmall = EnemySets[enemySetPrefix.."Small"]

	table.insert(enemy.SpawnOptions, GetRandomValue(spawnOptionsLarge))
	table.insert(enemy.SpawnOptions, GetRandomValue(spawnOptionsSmall))
	table.insert(enemy.SpawnOptions, GetRandomValue(spawnOptionsSmall))
end

function SelectHarpySupportAIs(enemy, currentRun)
	local shrineLevel = GetNumMetaUpgrades( enemy.ShrineMetaUpgradeName )

	enemy.SupportAINames = enemy.SupportAINames or {}

    -- change comparison from > 0 to == 1
	if shrineLevel == 1 then
		local supportCount = RandomInt(1, 2)
		if TextLinesRecord.FurySistersUnion01 == nil then
			supportCount = 2
		end
		for i=1, supportCount, 1 do
			local supportAIName = RemoveRandomValue(enemy.SupportAIWeaponSetOptions)
			table.insert(enemy.SupportAINames, supportAIName)
			currentRun.SupportAINames[supportAIName] = true
		end
	end
end
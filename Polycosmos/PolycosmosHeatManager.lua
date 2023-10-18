ModUtil.Mod.Register( "PolycosmosHeatManager" )

local pactSettingLoader = {}

local PactDataTable =
{
    HardLabor = {
        Name = "EnemyDamageShrineUpgrade",
        MaxLevel = 5, 
        ObtainedPactItems = 0,
    },
    LastingConsequences = {
        Name = "HealingReductionShrineUpgrade",
        MaxLevel = 4,
        ObtainedPactItems = 0,
    },
    ConvenienceFee = {
        Name = "ShopPricesShrineUpgrade",
        MaxLevel = 2,
        ObtainedPactItems = 0,
    },
    JurySummons = {
        Name = "EnemyCountShrineUpgrade",
        MaxLevel = 3,
        ObtainedPactItems = 0,
    },
    ExtremeMeasures = {
        Name = "BossDifficultyShrineUpgrade",
        MaxLevel = 4,
        ObtainedPactItems = 0,
    },
    CalisthenicsProgram = {
        Name = "EnemyHealthShrineUpgrade",
        MaxLevel = 2,
        ObtainedPactItems = 0,
    },
    BenefitsPackage = {
        Name = "EnemyEliteShrineUpgrade",
        MaxLevel = 2,
        ObtainedPactItems = 0,
    },
    MiddleManagement = {
        Name = "MinibossCountShrineUpgrade",
        MaxLevel = 1,
        ObtainedPactItems = 0,
    },
    UnderworldCustoms = {
        Name = "ForceSellShrineUpgrade",
        MaxLevel = 1,
        ObtainedPactItems = 0,
    },
    ForcedOvertime = {
        Name = "EnemySpeedShrineUpgrade",
        MaxLevel = 2,
        ObtainedPactItems = 0,
    },
    HeightenedSecurity = {
        Name = "TrapDamageShrineUpgrade",
        MaxLevel = 1,
        ObtainedPactItems = 0,
    },
    RoutineInspection = {
        Name = "MetaUpgradeStrikeThroughShrineUpgrade",
        MaxLevel = 4,
        ObtainedPactItems = 0,
    },
    DamageControl = {
        Name = "EnemyShieldShrineUpgrade",
        MaxLevel = 2,
        ObtainedPactItems = 0,
    },
    ApprovalProcess = {
        Name = "ReducedLootChoicesShrineUpgrade",
        MaxLevel = 2,
        ObtainedPactItems = 0,
    },
    TightDeadline = {
        Name = "BiomeSpeedShrineUpgrade",
        MaxLevel = 2,
        ObtainedPactItems = 0,
    },
    PersonalLiability = {
        Name = "NoInvulnerabilityShrineUpgrade",
        MaxLevel = 1,
        ObtainedPactItems = 0,
    },
}

--------------------functions for loading pact list obtained items

function PolycosmosHeatManager.SetUpHeatLevelFromPactList(pactList)
    PolycosmosHeatManager.ResetPactLevels()
    for i=1,#pactList do
        local pactName = pactList[i]
        PactDataTable[pactName].ObtainedPactItems = PactDataTable[pactName].ObtainedPactItems+1
    end
    PolycosmosHeatManager.UpdatePactsLevel()
end

function PolycosmosHeatManager.ResetPactLevels()
    for pactKey, pactData in pairs(PactDataTable) do
        pactData.ObtainedPactItems = 0
    end
end

-------------------- functions for reflecting the pact levels obtained in game

---if we eventually want to do other heat settings, this is the function we should modify
function PolycosmosHeatManager.UpdatePactsLevel()
	PolycosmosHeatManager.UpdatePactsLevelWithoutMetaCache()
    local oldGameStateMetaUpgrades = DeepCopyTable(GameState.MetaUpgrades)
    BuildMetaupgradeCache() 
    GameState.SpentShrinePointsCache = GetTotalSpentShrinePoints()
    UpdateActiveShrinePoints()
    GameState.MetaUpgrades = DeepCopyTable(oldGameStateMetaUpgrades)

    --[[The use of oldGameStateMetaUpgrades is a really dumb thing, but only way to
    1.- Save the players upgrades in the mirror
    2.- Avoid the upgrades from the mirror that are blocked due to pacts to suddendly get unblocked
    3.- Showing the correct heat level to the player.
    ]]--
end

function PolycosmosHeatManager.UpdatePactsLevelWithoutMetaCache()
	for pactKey, pactData in pairs(PactDataTable) do
        local calculatedLevel = pactData.MaxLevel-pactData.ObtainedPactItems
        if (calculatedLevel<0) then
            PolycosmosMessages.PrintErrorMessage("Calculated negative pact level, something went wrong with the item pool or item sync!",1)
            calculatedLevel=0
        end
        pactSettingLoader[pactData.Name] = calculatedLevel
    end
    for pactName, pactLevel in pairs (pactSettingLoader) do
        GameState.MetaUpgrades[pactName] = pactLevel
    end
end

-------------------- Auxiliary function for checking if a item is a pact level
function PolycosmosHeatManager.IsHeatLevel(string)
    if (PactDataTable[string]==nil) then
        return false
    end
    return true
end


--------------------

function PolycosmosHeatManager.PactDataTableTestPrint()
    print("Starting Pact Data table print")
    for pactKey, pactData in pairs(PactDataTable) do
         print("This is the pact "..pactKey)
         print("The maximum level is "..pactData.MaxLevel)
         print("This is the obtaiend item count "..pactData.ObtainedPactItems)
         print("This is the actual level "..GameState.MetaUpgrades[pactData.Name])
         print("")
    end
    print("Print ended")
end

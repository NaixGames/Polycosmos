ModUtil.Mod.Register( "PolycosmosHeatManager" )

--Sadly I need to put this buffer in case hades request some data before the Shared state is updated.
local bufferTime = 2

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
    PolycosmosHeatManager.UpdateMaxLevelFunctionFromData()
    PolycosmosHeatManager.ResetPactLevels()
    for i=1,#pactList do
        local pactName = pactList[i]
        PactDataTable[pactName].ObtainedPactItems = PactDataTable[pactName].ObtainedPactItems+1
    end
    --If heat settings is minimal heat, set minimum heat here
    PolycosmosHeatManager.CheckMinimalHeatSetting()
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
    GameState.SpentShrinePointsCache = GetTotalSpentShrinePoints()
    UpdateActiveShrinePoints()
end

function PolycosmosHeatManager.UpdatePactsLevelWithoutMetaCache()
	for pactKey, pactData in pairs(PactDataTable) do
        local calculatedLevel = pactData.MaxLevel-pactData.ObtainedPactItems
        if (calculatedLevel<0) then
            PolycosmosMessages.PrintErrorMessage("Calculated negative pact level, something went wrong with the item pool or item sync!",1)
            calculatedLevel=0
        end
        pactSettingLoader[pactData.Name] = calculatedLevel

        --This is just for printing which pact levels were obtained. 
        --If other heat management setting wanted to be implemented this might need change.
        --Also I dont quite like to have this here ... but it is what it is.
        if (GameState.MetaUpgrades[pactData.Name] and calculatedLevel < GameState.MetaUpgrades[pactData.Name] and StyxScribeShared.Root.GameSettings["HeatMode"]~=3) then
            PolycosmosMessages.PrintToPlayer("Obtained "..pactKey.." pact level item!")
            PolycosmosMessages.PrintToPlayer(pactKey.." minimal heat level changed to "..calculatedLevel)
        end
    end
    for pactName, pactLevel in pairs (pactSettingLoader) do
        if (GameState.UserStoredHeat==nil) then
            GameState.UserStoredHeat = {}
        end
        if (GameState.UserStoredHeat[pactName] == nil) then
            GameState.UserStoredHeat[pactName] = 0
        end
        GameState.MetaUpgrades[pactName] = math.max(pactLevel, GameState.UserStoredHeat[pactName])
        if (CurrentRun ~= nil) then
            CurrentRun.MetaUpgradeCache[pactName] = math.max(pactLevel, GameState.UserStoredHeat[pactName])
        end
    end
end

function PolycosmosHeatManager.UpdateMaxLevelFunctionFromData()
    --This is mostly a sanity check
    if not StyxScribeShared.Root.HeatSettings then
        PolycosmosEvents.LoadData()
        wait( bufferTime )
        if not StyxScribeShared.Root.HeatSettings then
            PolycosmosMessages.PrintToPlayer("Polycosmos in a desync state for heat manager. Enter and exit the save file again!")
            return
        end
    end
    if (StyxScribeShared.Root.GameSettings["HeatMode"]==3) then
        --We load the Max levels from the Data
        PactDataTable.HardLabor.MaxLevel = 0
        PactDataTable.LastingConsequences.MaxLevel = 0
        PactDataTable.ConvenienceFee.MaxLevel = 0
        PactDataTable.JurySummons.MaxLevel = 0
        PactDataTable.ExtremeMeasures.MaxLevel = 0
        PactDataTable.CalisthenicsProgram.MaxLevel = 0
        PactDataTable.BenefitsPackage.MaxLevel = 0
        PactDataTable.MiddleManagement.MaxLevel = 0
        PactDataTable.UnderworldCustoms.MaxLevel = 0
        PactDataTable.ForcedOvertime.MaxLevel = 0
        PactDataTable.HeightenedSecurity.MaxLevel = 0
        PactDataTable.RoutineInspection.MaxLevel = 0
        PactDataTable.DamageControl.MaxLevel = 0
        PactDataTable.ApprovalProcess.MaxLevel = 0
        PactDataTable.TightDeadline.MaxLevel = 0
        PactDataTable.PersonalLiability.MaxLevel = 0
    else
        --We load the Max levels from the Data
        PactDataTable.HardLabor.MaxLevel = StyxScribeShared.Root.HeatSettings['HardLaborPactLevel']
        PactDataTable.LastingConsequences.MaxLevel = StyxScribeShared.Root.HeatSettings['LastingConsequencesPactLevel']
        PactDataTable.ConvenienceFee.MaxLevel = StyxScribeShared.Root.HeatSettings['ConvenienceFeePactLevel']
        PactDataTable.JurySummons.MaxLevel = StyxScribeShared.Root.HeatSettings['JurySummonsPactLevel']
        PactDataTable.ExtremeMeasures.MaxLevel = StyxScribeShared.Root.HeatSettings['ExtremeMeasuresPactLevel']
        PactDataTable.CalisthenicsProgram.MaxLevel = StyxScribeShared.Root.HeatSettings['CalisthenicsProgramPactLevel']
        PactDataTable.BenefitsPackage.MaxLevel = StyxScribeShared.Root.HeatSettings['BenefitsPackagePactLevel']
        PactDataTable.MiddleManagement.MaxLevel = StyxScribeShared.Root.HeatSettings['MiddleManagementPactLevel']
        PactDataTable.UnderworldCustoms.MaxLevel = StyxScribeShared.Root.HeatSettings['UnderworldCustomsPactLevel']
        PactDataTable.ForcedOvertime.MaxLevel = StyxScribeShared.Root.HeatSettings['ForcedOvertimePactLevel']
        PactDataTable.HeightenedSecurity.MaxLevel = StyxScribeShared.Root.HeatSettings['HeightenedSecurityPactLevel']
        PactDataTable.RoutineInspection.MaxLevel = StyxScribeShared.Root.HeatSettings['RoutineInspectionPactLevel']
        PactDataTable.DamageControl.MaxLevel = StyxScribeShared.Root.HeatSettings['DamageControlPactLevel']
        PactDataTable.ApprovalProcess.MaxLevel = StyxScribeShared.Root.HeatSettings['ApprovalProcessPactLevel']
        PactDataTable.TightDeadline.MaxLevel = StyxScribeShared.Root.HeatSettings['TightDeadlinePactLevel']
        PactDataTable.PersonalLiability.MaxLevel = StyxScribeShared.Root.HeatSettings['PersonalLiabilityPactLevel']
    end
end

function PolycosmosHeatManager.CheckMinimalHeatSetting() 
    if (StyxScribeShared.Root.GameSettings["HeatMode"]==2) then
        for pactKey, pactData in pairs(PactDataTable) do
            local namePact = pactData.Name
            GameState.UserStoredHeat[namePact] = pactData.MaxLevel 
        end
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


function PolycosmosHeatManager.SaveUserIntededHeat()
    for pactKey, pactData in pairs(PactDataTable) do
        local namePact = pactData.Name
        local calculatedLevel = pactData.MaxLevel-pactData.ObtainedPactItems
        
        -- some guards for dumb cases
        if (GameState.MetaUpgrades[namePact] == nil) then
            GameState.MetaUpgrades[namePact] = 0
        end
        if (GameState.UserStoredHeat==nil) then
            GameState.UserStoredHeat = {}
        end


        if (GameState.MetaUpgrades[namePact]<= calculatedLevel) then
            GameState.UserStoredHeat[namePact] = 0
        else
            GameState.UserStoredHeat[namePact] = GameState.MetaUpgrades[namePact] 
        end
    end
end


ModUtil.WrapBaseFunction("StartNewRun", 
    function ( baseFunc, prevRun, args )
        PolycosmosHeatManager.SaveUserIntededHeat()
        PolycosmosHeatManager.UpdatePactsLevelWithoutMetaCache()

        return baseFunc( prevRun, args )
    end, PolycosmosHeatManager)
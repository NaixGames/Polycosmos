ModUtil.Mod.Register( "PolycosmosMessages" )

-- Change PrintStack height to take up less screen estate
-- Default PrintStackHeight = 10
ModUtil.Table.Merge( ModUtil.Hades, {
	PrintStackHeight = 4
} )

------------ Utils to uniformly change how we desplay messages

function PolycosmosMessages.PrintToPlayer(message)
    ModUtil.Hades.PrintStack(message, 5, {1,0.9,0.1,1}, {0,0,0,1}, 20)
end


function PolycosmosMessages.PrintInformationMessage(message)
    ModUtil.Hades.PrintStack(message, 5, {0.3,0.9,1,1}, {0,0,0,1}, 20)
end

function PolycosmosMessages.PrintErrorMessage(message, id)
    ModUtil.Hades.PrintStack("Error number "..id..": "..message, 5, {1,0,0,1}, {0,0,0,1}, 20)
end

-- for id Error

--id = 0x  is for Boon related errors
--id = 1x is for Heat related errors

--id = 9x is for AP related errors

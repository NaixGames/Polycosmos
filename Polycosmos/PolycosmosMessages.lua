ModUtil.Mod.Register( "PolycosmosMessages" )

-- Change PrintStack height to take up less screen estate
-- Default PrintStackHeight = 10
ModUtil.Table.Merge( ModUtil.Hades, {
	PrintStackHeight = 3
} )

------------ Utils to uniformly change how we desplay messages

function PolycosmosMessages.PrintToPlayer(message)
    ModUtil.Hades.PrintStack(message)
end


function PolycosmosMessages.PrintInformationMessage(message)
    ModUtil.Hades.PrintStack(message)
end

function PolycosmosMessages.PrintErrorMessage(message, id)
    ModUtil.Hades.PrintStack("Error number "..id..": "..message)
end

-- for id Error

--id = 0x  is for Boon related errors
--id = 1x is for Heat related errors

--id = 9x is for AP related errors

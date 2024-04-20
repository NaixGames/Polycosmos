ModUtil.Mod.Register( "PolycosmosVersionChecker" )

polycosmos_version = "0.9.2"

-- Auxiliary function to check if an array has a value
function PolycosmosVersionChecker.CheckVersion(message)
    if (not GameState.ClientDataIsLoaded) then
        wait(bufferTime)
        if (not GameState.ClientDataIsLoaded) then
            print("can't check version out of lack of data. sorry.")
        end
    end
    client_version = GameState.ClientGameSettings["PolycosmosVersion"]
    if (client_version ~= polycosmos_version) then
        PolycosmosMessages.PrintToPlayer("Hades using Polycosmos version "..polycosmos_version.." and Client using "..client_version..". Use compatible versions")
        PolycosmosMessages.PrintToPlayer("Use compatible versions")
    end
end

StyxScribe.AddHook( PolycosmosVersionChecker.CheckVersion, styx_scribe_recieve_prefix.."Data package finished", PolycosmosVersionChecker )
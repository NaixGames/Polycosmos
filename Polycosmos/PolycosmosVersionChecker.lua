ModUtil.Mod.Register( "PolycosmosVersionChecker" )

polycosmos_version = "0.15"


function PolycosmosVersionChecker.CheckVersion()
    print("Checking version compatibility")
    if (not GameState.ClientDataIsLoaded) then
        print("can't check version out of lack of data. sorry.")
        return
    end
    client_version = GameState.ClientGameSettings["PolycosmosVersion"]
    if (client_version ~= polycosmos_version) then
        print("INCOMPATIBLE VERSIONS DETECTED")
        wait(bufferTime)
        PolycosmosMessages.PrintToPlayer("Hades using Polycosmos version "..polycosmos_version.." and Client using "..client_version..".")
        PolycosmosMessages.PrintToPlayer("Your game wont correctly. Checks wont be sent or recieved as expected")
        PolycosmosMessages.PrintToPlayer("DONT push through. Use compatible versions.")
    end
end


ModUtil.Mod.Register( "PolyCosmodLogoInject" )

-- Load custom package for image injection
local mod = "PolyCosmodLogoInject"
local package = "LogoInject"
DebugPrint({Text = "@"..mod.." Trying to load package "..package..".pkg"})
LoadPackages({Name = package})
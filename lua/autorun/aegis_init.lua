--[[--------------------------------------------------------------------------	
	File name:
		aegis_init.lua
		
	Author:
		Mista-Tea ([IJWTB] Thomas)
		
	License:
		
		
	Changelog:
		- Created June 5th, 2015

----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

aegis = aegis or {}

--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------
--
-- 	aegis.Initialize()
--
--]]--
function aegis.Initialize()

	if ( SERVER ) then
		include("aegis/server/aegis.lua")
        include("aegis/shared/enum.lua")
		include("aegis/server/cppi.lua")
		include("aegis/server/hook.lua")
		AddCSLuaFile("aegis/shared/enum.lua")
	else
        include("aegis/shared/enum.lua")
    end
	
	
	
	hook.Run("Aegis.SetupPermissions")
	
end
hook.Add( "Initialize", "aegis.Initialize", aegis.Initialize )
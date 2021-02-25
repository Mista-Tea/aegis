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
		include("aegis/shared/sh_aegis.lua")
        include("aegis/shared/sh_cppi.lua")
        include("aegis/shared/sh_enum.lua")
        
		include("aegis/server/sv_hook.lua")
        
        -- Send shared files
        AddCSLuaFile("aegis/shared/sh_aegis.lua")
        AddCSLuaFile("aegis/shared/sh_cppi.lua")
		AddCSLuaFile("aegis/shared/sh_enum.lua")
	else
        include("aegis/shared/sh_aegis.lua")
        include("aegis/shared/sh_cppi.lua")
        include("aegis/shared/sh_enum.lua")
    end
	
	hook.Run("Aegis.SetupPermissions")
	
end
hook.Add( "Initialize", "aegis.Initialize", aegis.Initialize )
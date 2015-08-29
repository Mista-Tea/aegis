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
-- Localized Functions & Variables
--------------------------------------------------------------------------]]--

local util = util
local hook = hook

--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------
--
-- 	aegis.Initialize( boolean )
--
--]]--
function aegis.Initialize()

	if ( SERVER ) then
		
		utils.AddFiles( "aegis/server", "include" )
		utils.AddFiles( "aegis/shared", "shared" )
		utils.AddFiles( "aegis/client", "client" )


	elseif ( CLIENT ) then
		
		utils.AddFiles( "aegis/shared", "include" )
		utils.AddFiles( "aegis/client", "include" )
	
	end
end
hook.Add( "Initialize", "Aegis", aegis.Initialize )
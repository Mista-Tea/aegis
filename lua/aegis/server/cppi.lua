--[[--------------------------------------------------------------------------	
	File name:
		aegis.lua
		
	Author:
		Mista-Tea ([IJWTB] Thomas)
		
	License:
		
		
	Changelog:
		- Created October 12th, 2015

----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

CPPI = CPPI or {}

local ENTITY = FindMetaTable( "Entity" )

--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------
--
-- 	ENTITY:CPPIGetOwner()
--
--]]--
function ENTITY:CPPIGetOwner()
	return aegis.GetPlayer( aegis.GetUID( self ) )
end

--[[--------------------------------------------------------------------------
--
-- 	ENTITY:CPPICanTool( entity, string )
--
--]]--
function ENTITY:CPPICanTool( ent, tool )
	return aegis.HasAccess( self, ent, AEGIS_ALL_TOOL )
end
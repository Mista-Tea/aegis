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
local PLAYER = FindMetaTable( "Player" )

--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

function CPPI.GetName()
	return "IAM"
end

function CPPI.GetVersion()
	return "0.1"
end

function CPPI.GetInterfaceVersion()
	return 1.3
end

function CPPI.GetNameFromUID( uid )
	return aegis.GetPlayer( uid )
end


--[[--------------------------------------------------------------------------
-- Entity Ownership Functions
--------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------
--
-- 	ENTITY:CPPIGetOwner()
--
--]]--
function ENTITY:CPPIGetOwner()
	--debug.Trace()
	local uid = aegis.GetUID( self )
	--print( "Entity:", self, aegis.GetOwnerUID( self ), aegis.GetPlayer( aegis.GetOwnerUID( self ) ) )
	--print()
	return aegis.GetPlayer( uid ), uid
end

--[[--------------------------------------------------------------------------
--
-- 	ENTITY:CPPISetOwner( player )
--
--]]--
function ENTITY:CPPISetOwner( ply )
	aegis.SetOwner( self, ply )
	return true
end

--[[--------------------------------------------------------------------------
--
-- 	ENTITY:CPPISetOwnerUID( string )
--
--]]--
function ENTITY:CPPISetOwnerUID( uid )
	aegis.SetOwnerUID( self, uid )
	return true
end

--[[--------------------------------------------------------------------------
--
-- 	ENTITY:CPPIGetFriends()
--
--]]--
function PLAYER:CPPIGetFriends()
	local tbl = {}
	for _, ply in ipairs( player.GetAll() ) do
		if ( ply == self ) then continue end
		if ( self:CPPICanTool( ply ) ) then
			tbl[#tbl+1] = ply
		end
	end
	
	return tbl
end

--[[--------------------------------------------------------------------------
-- Entity Permission Functions
--------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanTool( entity, string )
--]]--
function ENTITY:CPPICanTool( ply, tool ) return aegis.HasAccess( self, ply, AEGIS_ALL_TOOL ) end
--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanDrive( entity )
--]]--
function ENTITY:CPPICanDrive( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_TOOL ) end
--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanProperty( entity, string )
--]]--
function ENTITY:CPPICanProperty( ply, property ) return aegis.HasAccess( self, ply, AEGIS_ALL_TOOL ) end
--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanEditVariable( entity, *, *, table )
--]]--
function ENTITY:CPPICanEditVariable( ply, key, value, tbl ) return aegis.HasAccess( self, ply, AEGIS_ALL_TOOL ) end
--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanPhysgun( entity )
--]]--
function ENTITY:CPPICanPhysgun( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_PHYSGUN ) end
--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanPickup( entity )
--]]--
function ENTITY:CPPICanPickup( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_GRAVGUN ) end
--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanPunt( entity )
--]]--
function ENTITY:CPPICanPunt( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_GRAVGUN ) end
--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanUse( entity )
--]]--
function ENTITY:CPPICanUse( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_USE ) end
--[[--------------------------------------------------------------------------
-- 	ENTITY:CPPICanDamage( entity )
--]]--
function ENTITY:CPPICanDamage( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_DAMAGE ) end
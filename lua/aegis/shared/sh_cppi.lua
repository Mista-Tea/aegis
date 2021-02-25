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

if CLIENT then
    
    function PLAYER:CPPIGetFriends()
        return {}
    end
    
elseif SERVER then
    
    function ENTITY:CPPISetOwner( ply )
        aegis.SetOwner( self, ply )
        return true
    end
    
    function ENTITY:CPPISetOwnerUID( uid )
        aegis.SetOwnerUID( self, uid )
        return true
    end
    
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
end

function ENTITY:CPPIGetOwner()
    --debug.Trace()
    local uid = aegis.GetUID( self )
    --print( "Entity:", self, aegis.GetOwnerUID( self ), aegis.GetPlayer( aegis.GetOwnerUID( self ) ) )
    --print()
    return aegis.GetPlayer( uid ), uid
end

--[[--------------------------------------------------------------------------
-- Entity Permission Functions
--------------------------------------------------------------------------]]--

function ENTITY:CPPICanTool( ply, tool ) return aegis.HasAccess( self, ply, AEGIS_ALL_TOOL ) end
function ENTITY:CPPICanDrive( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_TOOL ) end
function ENTITY:CPPICanProperty( ply, property ) return aegis.HasAccess( self, ply, AEGIS_ALL_TOOL ) end
function ENTITY:CPPICanEditVariable( ply, key, value, tbl ) return aegis.HasAccess( self, ply, AEGIS_ALL_TOOL ) end
function ENTITY:CPPICanPhysgun( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_PHYSGUN ) end
function ENTITY:CPPICanPickup( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_GRAVGUN ) end
function ENTITY:CPPICanPunt( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_GRAVGUN ) end
function ENTITY:CPPICanUse( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_USE ) end
function ENTITY:CPPICanDamage( ply ) return aegis.HasAccess( self, ply, AEGIS_ALL_DAMAGE ) end
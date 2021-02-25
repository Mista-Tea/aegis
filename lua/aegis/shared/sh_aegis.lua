--[[--------------------------------------------------------------------------	
	File name:
		aegis.lua
		
	Author:
		Mista-Tea ([IJWTB] Thomas)
		
	License:
		
		
	Changelog:
		- Created June 5th, 2015

----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

local ENTITY = FindMetaTable( "Entity" )

aegis = aegis or {}

aegis.permission = aegis.permission or {}
aegis.player     = aegis.player     or {}
aegis.cvar       = aegis.cvar       or {}

aegis.cvar.Persist = CreateConVar( "aegis_persist", "1", {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "Keeps a player's permissions even after they disconnect" )

--[[--------------------------------------------------------------------------
-- Localized Functions & Variables
--------------------------------------------------------------------------]]--

local bit = bit
local hook = hook
local unpack = unpack
local IsEntity = IsEntity

--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------
--
-- 	aegis.GetPlayer( * )
--
--]]--
function aegis.GetPlayer( uid )
	return aegis.player[ uid ]
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.Create( entity )
--
--]]--
function aegis.Create( ent )
	ent[ "aegis" ] = {}
end



--[[--------------------------------------------------------------------------
--
-- 	aegis.SetAegis( *, * )
--
--]]--
function ENTITY:SetAegis( key, value )
	if ( not self[ "aegis" ] ) then aegis.Create( self ) end
	
	self[ "aegis" ][ key ] = value
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetAegis( *, * )
--
--]]--
function ENTITY:GetAegis( key, default )
	if ( not self[ "aegis" ] ) then aegis.Create( self ) end
	-- this may error if this entity is NULL
	return self[ "aegis" ][ key ] or default
end



--[[--------------------------------------------------------------------------
--
-- 	aegis.SetOwnerUID( entity, * )
--
--]]--
function aegis.SetOwnerUID( ent, uid )
	ent:SetAegis( "uid", uid )
	hook.Run( "AegisOwnerUIDSet", ent, uid )
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetOwnerUID( entity, * )
--
--]]--
function aegis.GetOwnerUID( ent, default )
	return ent:GetAegis( "uid", default )
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.SetOwner( entity, player )
--	
--	Convenience function for automatically assigning an owner to the 
--	given enttiy.
--]]--
function aegis.SetOwner( ent, ply )
	aegis.SetOwnerUID( ent, aegis.GetUID( ply ) )
	hook.Run( "AegisOwnerSet", ent, ply )
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetOwner( entity )
--
--]]--
function aegis.GetOwner( ent )
    return aegis.player[ aegis.GetOwnerUID( ent ) ]
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.SetupPlayer( player )
--
--]]--
function aegis.SetupPlayer( ply )
	-- retrieve a unique identifier for this player
	-- used when assigning ownership of entities or retrieve permissions
	local uid = aegis.GetUID( ply )
	
	-- place the player entity into a lookup table for quick O(1) retrieval
	aegis.player[ uid ] = ply
	
	-- since players are entities, we must assign themselves as their own owner
	aegis.SetOwner( ply, ply )
	
	-- setup the player's permissions table
	aegis.permission[ uid ] = aegis.permission[ uid ] or {
		[aegis.GLOBAL_ID] = aegis.NO_PERMISSION
	}
end
if SERVER then
    hook.Add( "PlayerInitialSpawn", "AegisSetupPlayer", aegis.SetupPlayer )
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.ClearPlayer( player )
--
--]]--
function aegis.ClearPlayer( ply )
	local uid = aegis.GetUID( ply )
	
	-- clear the player from the lookup table (otherwise the entry will become NULL)
	aegis.player[ uid ] = nil
	
	-- if aegis is set to not persist permissions, clear out the player's data from the table
	if ( not aegis.cvar.Persist:GetBool() ) then
		aegis.permission[ uid ] = nil
	end
end
if SERVER then
    hook.Add( "PlayerDisconnected", "AegisRemovePlayer", aegis.ClearPlayer )
end



--[[--------------------------------------------------------------------------
--
-- 	aegis.AddAccess( player, player, entity )
--
--]]--
function aegis.AddAccess( owner, accessor, access )
	-- return false if the player has already given access
	if ( aegis.HasAccess( owner, accessor, access ) ) then return false end
	
	-- get the unique ID's of both entities
	local ownerUID    = aegis.GetUID( owner )
	local accessorUID = aegis.GetUID( accessor )
	
	-- retrieve the owner's permission granted to the accessor
	local perms = aegis.GetPermission( ownerUID, accessorUID )
	
	-- add the access to the owner's permissions granted to the accessor
	aegis.SetPermission( ownerUID, accessorUID, bit.bor( perms, access ) )
	
	hook.Run( "AegisAccessAdded", owner, accessor, access )
	return true
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.RemoveAccess( player, player, string )
--
--]]--
function aegis.RemoveAccess( owner, accessor, access )
	-- return false if the player hasn't given access yet
	if ( not aegis.HasAccess( owner, accessor, access ) ) then return false end

	-- get the unique ID's of both entities
	local ownerUID    = aegis.GetUID( owner )
	local accessorUID = aegis.GetUID( accessor )
	
	-- retrieve the owner's permission granted to the accessor
	local perms = aegis.GetPermission( ownerUID, accessorUID )

	-- remove the access from the owner's permissions granted to the accessor
	aegis.SetPermission( ownerUID, accessorUID, bit.band( perms, bit.bnot( access ) ) )
	
	hook.Run( "AegisAccessRemoved", owner, accessor, access )
	return true
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.HasAccess( entity, entity, varags )
--
--]]--
function aegis.HasAccess( thisEnt, otherEnt, ... )
	-- if both entities are the same, return true
	if ( thisEnt == otherEnt ) then return true end
	
	local ownerUID    = aegis.GetUID( thisEnt )
	local accessorUID = aegis.GetUID( otherEnt )
	
	-- if both entities have the same owner, return true
	if ( ownerUID == accessorUID ) then return true end
	
	local override = hook.Run( "AegisHasAccess", ownerUID, accessorUID, {...} )
	if ( override ~= nil ) then return override end
	
	-- retrieve the owner's permission granted to the accessor
	local perms  = aegis.GetPermission( ownerUID, accessorUID )
	perms = bit.bor( perms, aegis.GetPermission( ownerUID, aegis.GLOBAL_ID ) )
	
	-- create a bitmask of accesses the player needs to be granted permission
	local mask = bit.bor( unpack( {...} ) )
	-- return true if the player has the corresponding permission
	return bit.band( perms, mask ) > aegis.NO_PERMISSION
end



--[[--------------------------------------------------------------------------
--
-- 	aegis.GetGlobalAccess( string )
--
--]]--
function aegis.GetGlobalAccess( access )
	return aegis.local_to_global[ access ]
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetPermissions( * )
--
--]]--
function aegis.GetPermissions( uid )
	return aegis.permission[ uid ] or {}
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetPermission( *, * )
--
--]]--
function aegis.GetPermission( ownerUID, accessorUID )
	return aegis.permission[ ownerUID ] and aegis.permission[ ownerUID ][ accessorUID ] or aegis.NO_PERMISSION
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.SetPermission( *, *, number )
--
--]]--
function aegis.SetPermission( ownerUID, accessorUID, num )
	aegis.permission[ ownerUID ][ accessorUID ] = aegis.permission[ ownerUID ][ accessorUID ] or aegis.NO_PERMISSION
	aegis.permission[ ownerUID ][ accessorUID ] = num
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.GetLocalByString( string )
--
--]]--
function aegis.GetLocalByString( str )
	return aegis.lookup_local_by_name[ str:lower() ]
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.GetGlobalByString( string )
--
--]]--
function aegis.GetGlobalByString( str )
	return aegis.lookup_global_by_name[ str:lower() ]
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetAccessNameByEnum( number )
--
--]]--
function aegis.GetAccessNameByEnum( enum )
	return aegis.lookup_local_by_enum[ enum ] or aegis.lookup_global_by_enum[ enum ]
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.GetUID( *, * )
--
--]]--
function aegis.GetUID( var, default )
	if ( IsEntity( var ) ) then
		if ( var:IsPlayer() and var:IsValid() ) then
			return aegis.UIDMethod( var )
		else
			return aegis.GetOwnerUID( var, default )
		end
	end
	
	if ( default ~= nil ) then return default else return var end
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.UIDBySteamID( player )
--
--]]--
function aegis.UIDBySteamID( ply )
	return ply:IsBot() and "BOT" or ply:SteamID()
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.UIDBySteamID64( player )
--
--]]--
function aegis.UIDBySteamID64( ply )
	return ply:SteamID64()
end

aegis.UIDMethod = aegis.UIDBySteamID
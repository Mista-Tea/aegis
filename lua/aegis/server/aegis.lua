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

aegis = aegis or {}

aegis.permission = aegis.permission or {}
aegis.player     = aegis.player     or {}

local ENTITY = FindMetaTable( "Entity" )

AEGIS_WHITELIST = 1
AEGIS_PHYSGUN   = 2
AEGIS_TOOL      = 4
AEGIS_USE       = 8
AEGIS_DAMAGE    = 16

AEGIS_GLOBAL_WHITELIST = 32
AEGIS_GLOBAL_PHYSGUN   = 64
AEGIS_GLOBAL_TOOL      = 128
AEGIS_GLOBAL_USE       = 256
AEGIS_GLOBAL_DAMAGE    = 512

AEGIS_ALL_WHITELIST = bit.bor( AEGIS_WHITELIST, AEGIS_GLOBAL_WHITELIST )
AEGIS_ALL_TOOL      = bit.bor( AEGIS_TOOL, AEGIS_GLOBAL_TOOL, AEGIS_ALL_WHITELIST )
AEGIS_ALL_PHYSGUN   = bit.bor( AEGIS_PHYSGUN, AEGIS_GLOBAL_PHYSGUN, AEGIS_ALL_WHITELIST )
AEGIS_ALL_USE       = bit.bor( AEGIS_USE, AEGIS_GLOBAL_USE, AEGIS_ALL_WHITELIST )
AEGIS_ALL_DAMAGE    = bit.bor( AEGIS_DAMAGE, AEGIS_GLOBAL_DAMAGE, AEGIS_ALL_WHITELIST )

aegis.local_to_global = {
	[AEGIS_WHITELIST] = AEGIS_GLOBAL_WHITELIST,
	[AEGIS_PHYSGUN]   = AEGIS_GLOBAL_PHYSGUN,
	[AEGIS_TOOL]      = AEGIS_GLOBAL_TOOL,
	[AEGIS_USE]       = AEGIS_GLOBAL_USE,
	[AEGIS_DAMAGE]    = AEGIS_GLOBAL_DAMAGE,
}

aegis.string_to_local = {
	whitelist = AEGIS_WHITELIST,
	physgun   = AEGIS_PHYSGUN,
	tool      = AEGIS_TOOL,
	use       = AEGIS_USE,
	damage    = AEGIS_DAMAGE,
}

aegis.string_to_global = {
	whitelist = AEGIS_GLOBAL_WHITELIST,
	physgun   = AEGIS_GLOBAL_PHYSGUN,
	tool      = AEGIS_GLOBAL_TOOL,
	use       = AEGIS_GLOBAL_USE,
	damage    = AEGIS_GLOBAL_DAMAGE,
}

aegis.Persist = CreateConVar( "aegis_persist", "1", FCVAR_SERVER_CAN_EXECUTE, "Keeps a player's permissions even after they disconnect" )

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
-- 	aegis.Create( player )
--
--]]--
function aegis.Create( ent )
	ent[ "aegis" ] = {}
end



--[[--------------------------------------------------------------------------
--
-- 	aegis.SetAegis( player )
--
--]]--
function ENTITY:SetAegis( key, value )
	if ( not self[ "aegis" ] ) then aegis.Create( self ) end
	
	self[ "aegis" ][ key ] = value
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetAegis( player )
--
--]]--
function ENTITY:GetAegis( key, default )
	if ( not self[ "aegis" ] ) then aegis.Create( self ) end
	
	return self[ "aegis" ][ key ] or default
end



--[[--------------------------------------------------------------------------
--
-- 	aegis.SetOwnerUID( player )
--
--]]--
function aegis.SetOwnerUID( ent, uid )
	ent:SetAegis( "uid", uid )
	hook.Run( "AegisOwnerUIDSet", ent, uid )
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetOwnerUID( player )
--
--]]--
function aegis.GetOwnerUID( ent, default )
	return ent:GetAegis( "uid", default )
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.SetOwner( player )
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
-- 	aegis.SetupPlayer()
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
	aegis.permission[ uid ] = aegis.permission[ uid ] or { GLOBAL = 0 }
end
hook.Add( "PlayerInitialSpawn", "AegisSetupPlayer", aegis.SetupPlayer )
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
	if ( not aegis.Persist:GetBool() ) then
		aegis.permission[ uid ] = nil
	end
end
hook.Add( "PlayerDisconnected", "AegisRemovePlayer", aegis.ClearPlayer )



--[[--------------------------------------------------------------------------
--
-- 	aegis.AddAccess()
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
-- 	aegis.RemoveAccess()
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
	
	hook.Run( "AegisAccessRemoved", ent, accessor, access )
	return true
end



--[[--------------------------------------------------------------------------
--
-- 	aegis.HasAccess()
--
--]]--
function aegis.HasAccess( thisEnt, otherEnt, ... )
	-- if both entities are the same, return true
	if ( thisEnt == otherEnt ) then return true end
	
	local ownerUID    = aegis.GetUID( thisEnt )
	local accessorUID = aegis.GetUID( otherEnt )
	
	-- if both entities has the same owner, return true
	if ( ownerUID == accessorUID ) then return true end
	
	local override = hook.Run( "AegisHasAccess", ownerUID, accessorUID, {...} )
	if ( override ~= nil ) then return override end
	
	-- retrieve the owner's permission granted to the accessor
	local perms  = aegis.GetPermission( ownerUID, accessorUID )
	perms = bit.bor( perms, aegis.GetPermission( ownerUID, "GLOBAL" ) )
	
	-- create a bitmask of accesses the player needs to be granted permission
	local mask = bit.bor( unpack( {...} ) )
	-- return true if the player has the corresponding permission
	return bit.band( perms, mask ) > 0
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.HasAccesses()
--
--]]--
function aegis.HasAccesses( thisEnt, otherEnt, accesses )
	-- if both entities are the same, return true
	if ( thisEnt == otherEnt ) then return true end
	
	local ownerUID    = aegis.GetUID( thisEnt )
	local accessorUID = aegis.GetUID( otherEnt )

	-- if both entities has the same owner, return true
	if ( ownerUID == accessorUID ) then return true end
	
	local override = hook.Run( "AegisHasAccesses", ownerUID, accessorUID, accesses )
	if ( override ~= nil ) then return override end
	
	-- retrieve the owner's permission granted to the accessor
	local perms  = aegis.GetPermission( ownerUID, accessorUID )
	local gperms = aegis.GetPermission( "GLOBAL", accessorUID )
	
	-- create a bitmask of accesses the player needs to be granted permission
	local mask = bit.bor( unpack( accesses ) )
	
	-- return true if the player has any of the accesses from the mask
	return bit.band( perms, gperms, mask ) > 0
end


--[[--------------------------------------------------------------------------
--
-- 	aegis.GetGlobalAccess()
--
--]]--
function aegis.GetGlobalAccess( access )
	return aegis.local_to_global[ access ]
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetPermissions()
--
--]]--
function aegis.GetPermissions( uid )
	return aegis.permission[ uid ] or {}
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.GetPermission()
--
--]]--
function aegis.GetPermission( ownerUID, accessorUID )
	return aegis.permission[ ownerUID ] and aegis.permission[ ownerUID ][ accessorUID ] or 0
end
--[[--------------------------------------------------------------------------
--
-- 	aegis.SetPermission()
--
--]]--
function aegis.SetPermission( ownerUID, accessorUID, num )
	aegis.permission[ ownerUID ][ accessorUID ] = aegis.permission[ ownerUID ][ accessorUID ] or 0
	aegis.permission[ ownerUID ][ accessorUID ] = num
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.GetLocalByString()
--
--]]--
function aegis.GetLocalByString( str )
	return aegis.string_to_local[ str:lower() ]
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.GetGlobalByString()
--
--]]--
function aegis.GetGlobalByString( str )
	return aegis.string_to_global[ str:lower() ]
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.GetUID()
--
--]]--
function aegis.GetUID( var )
	if ( IsEntity( var ) ) then
		if ( var:IsPlayer() and var:IsValid() ) then
			return aegis.UIDMethod( var )
		else
			return aegis.GetOwnerUID( var )
		end
	end
	
	return var
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.UIDBySteamID()
--
--]]--
function aegis.UIDBySteamID( ply )
	return ply:SteamID()
end

--[[--------------------------------------------------------------------------
--
-- 	aegis.UIDBySteamID64()
--
--]]--
function aegis.UIDBySteamID64( ply )
	return ply:SteamID64()
end

aegis.UIDMethod = aegis.UIDBySteamID

--[[--------------------------------------------------------------------------
-- ENTITY SPAWNING HOOKS
--------------------------------------------------------------------------]]--

hook.Add( "PlayerSpawnedEffect",  "Aegis", function( ply, model, ent ) aegis.SetOwner( ent, ply ) end )
hook.Add( "PlayerSpawnedProp",    "Aegis", function( ply, model, ent ) aegis.SetOwner( ent, ply ) end )
hook.Add( "PlayerSpawnedRagdoll", "Aegis", function( ply, model, ent ) aegis.SetOwner( ent, ply ) end )
hook.Add( "PlayerSpawnedNPC",     "Aegis", function( ply, ent )        aegis.SetOwner( ent, ply ) end )
hook.Add( "PlayerSpawnedSENT",    "Aegis", function( ply, ent )        aegis.SetOwner( ent, ply ) end )
hook.Add( "PlayerSpawnedSWEP",    "Aegis", function( ply, ent )        aegis.SetOwner( ent, ply ) end )
hook.Add( "PlayerSpawnedVehicle", "Aegis", function( ply, ent )        aegis.SetOwner( ent, ply ) end )


--[[--------------------------------------------------------------------------
-- ENTITY PROTECTION HOOKS
--------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------
-- 	Hook :: CanTool( player, table, string )
--]]--
hook.Add( "CanTool", "iam.aegis.cantool", function( ply, tr, tool )
	local ent   = tr.Entity
	if ( !IsValid( ent ) and !ent:IsWorld() ) then return false end
	if ( !IsValid( ply ) ) then return false end
	
	local class = ent:GetClass()
	
	local override = hook.Run( "AegisCanTool", ply, tr, tool )
	if ( override ~= nil ) then return override end
	
	if ( ent:IsWorld() ) then return true end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_TOOL )
end )

--[[--------------------------------------------------------------------------
-- 	Hook :: PhysgunPickup( player, entity )
--]]--
hook.Add( "PhysgunPickup", "Aegis", function( ply, ent )
	if ( ent:IsWorld() ) then return true end
	if ( !IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisPhysgunPickup", ply, ent ) 
	if ( override ~= nil ) then return override end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_PHYSGUN )
end )

--[[--------------------------------------------------------------------------
-- 	Hook :: GravGunPickupAllowed( player, entity )
--]]--
hook.Add( "GravGunPickupAllowed", "Aegis", function( ply, ent )
	if ( ent:IsWorld() ) then return true end
	if ( !IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisGravGunPickupAllowed", ply, ent ) 
	if ( override ~= nil ) then return override end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_PHYSGUN )
end )

--[[--------------------------------------------------------------------------
-- 	Hook :: GravGunPunt( player, entity )
--]]--
hook.Add( "GravGunPunt", "Aegis", function( ply, ent )
	if ( ent:IsWorld() ) then return true end
	if ( !IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisGravGunPunt", ply, ent ) 
	if ( override ~= nil ) then return override end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_PHYSGUN )
end )

--[[--------------------------------------------------------------------------
-- 	Hook :: PlayerUse( player, entity )
--]]--
hook.Add( "PlayerUse", "Aegis", function( ply, ent )
	if ( ent:IsWorld() ) then return true end
	if ( !IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisPlayerUse", ply, ent ) 
	if ( override ~= nil ) then return override end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_USE )
end )

--[[--------------------------------------------------------------------------
-- 	Hook :: EntityTakeDamage( entity, table )
--]]--
hook.Add( "EntityTakeDamage", "Aegis", function( ent, dmg )	
	local override = hook.Run( "AegisEntityTakeDamage", ent, dmg ) 
	if ( override ~= nil ) then 
		dmg:SetDamage( override )
		return
	end
	
	local att = dmg:GetAttacker()
	local inf = dmg:GetInflictor()
	
	if ( att:IsWorld() or inf:IsWorld() ) then dmg:SetDamage( 0 ) return end
	
	local attUID = aegis.GetUID( att ) or aegis.GetUID( inf ) -- get either the inflicter ownerUID or default to the attacker ownerUID

	if ( not aegis.HasAccess( ent, attUID, AEGIS_ALL_DAMAGE ) ) then
		--if ( !ent:GetAegisOwnerID() ) then return end
		dmg:SetDamage( 0 )
	end
end )

--[[--------------------------------------------------------------------------
-- 	Hook :: CanProperty( player, string, entity )
--]]--
hook.Add( "CanProperty", "Aegis", function( ply, property, ent )
	if ( !IsValid( ply ) ) then return false end

	local override = hook.Run( "AegisCanProperty", ply, property, ent ) 
	if ( override ~= nil ) then return override end

	return aegis.HasAccess( ent, ply, AEGIS_ALL_TOOL )
end )

--[[--------------------------------------------------------------------------
-- 	Hook :: CanEditVariable( entity, player, string, *, table )
--]]--
hook.Add( "CanEditVariable", "Aegis", function( ent, ply, key, val, editor )
	if ( !IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisCanEditVariable", ent, ply, key, val, editor ) 
	if ( override ~= nil ) then return override end

	return aegis.HasAccess( ent, ply, AEGIS_ALL_TOOL )
end )

--[[--------------------------------------------------------------------------
-- 	Hook :: OnPhysgunReload( weapon, player )
--]]--
hook.Add( "OnPhysgunReload", "Aegis", function( wep, ply )
	local ent = ply:GetEyeTrace().Entity
	if ( !IsValid( ent ) ) then return false end
	
	local override = hook.Run( "AegisOnPhysgunReload", wep, ply ) 
	if ( override ~= nil ) then return override end
	
	if ( not aegis.HasAccess( ent, ply, AEGIS_ALL_PHYSGUN ) ) then 
		return false
	end
	
	-- to allow the player, don't return anything!
end )

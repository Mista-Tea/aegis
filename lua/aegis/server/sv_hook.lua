--[[--------------------------------------------------------------------------	
	File name:
		hook.lua
		
	Author:
		Mista-Tea ([IJWTB] Thomas)
		
	License:
		
		
	Changelog:
		- Created November 4th, 2016

----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

aegis = aegis or {}

--[[--------------------------------------------------------------------------
-- Localized Functions & Variables
--------------------------------------------------------------------------]]--

local hook = hook
local unpack = unpack
local IsValid = IsValid

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
--
-- 	Hook :: CanTool( player, table, string )
--
--]]--
hook.Add( "CanTool", "Aegis", function( ply, tr, tool )
	local ent   = tr.Entity
	if ( not IsValid( ent ) and not ent:IsWorld() ) then return false end
	if ( not IsValid( ply ) ) then return false end
	
	local class = ent:GetClass()
	
	local override = hook.Run( "AegisCanTool", ply, tr, tool )
	if ( override ~= nil ) then return override end
	
	if ( ent:IsWorld() ) then return true end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_TOOL )
end )

--[[--------------------------------------------------------------------------
--
-- 	Hook :: PhysgunPickup( player, entity )
--
--]]--
hook.Add( "PhysgunPickup", "Aegis", function( ply, ent )
	if ( ent:IsWorld() ) then return true end
	if ( not IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisPhysgunPickup", ply, ent ) 
	if ( override ~= nil ) then return override end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_PHYSGUN )
end )

--[[--------------------------------------------------------------------------
--
-- 	Hook :: GravGunPickupAllowed( player, entity )
--
--]]--
hook.Add( "GravGunPickupAllowed", "Aegis", function( ply, ent )
	if ( ent:IsWorld() ) then return true end
	if ( not IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisGravGunPickupAllowed", ply, ent ) 
	if ( override ~= nil ) then return override end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_GRAVGUN )
end )

--[[--------------------------------------------------------------------------
--
-- 	Hook :: GravGunPunt( player, entity )
--
--]]--
hook.Add( "GravGunPunt", "Aegis", function( ply, ent )
	if ( ent:IsWorld() ) then return true end
	if ( not IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisGravGunPunt", ply, ent ) 
	if ( override ~= nil ) then return override end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_GRAVGUN )
end )

--[[--------------------------------------------------------------------------
--
-- 	Hook :: PlayerUse( player, entity )
--
--]]--
hook.Add( "PlayerUse", "Aegis", function( ply, ent )
	if ( ent:IsWorld() ) then return true end
	if ( not IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisPlayerUse", ply, ent ) 
	if ( override ~= nil ) then return override end
	
	return aegis.HasAccess( ent, ply, AEGIS_ALL_USE )
end )

--[[--------------------------------------------------------------------------
--
-- 	Hook :: EntityTakeDamage( entity, table )
--
--]]--
hook.Add( "EntityTakeDamage", "Aegis", function( ent, dmg )
	if ( ent:IsWorld() ) then return end
	local override = hook.Run( "AegisEntityTakeDamage", ent, dmg )
	if ( override ~= nil ) then dmg:SetDamage( override ) return false end
	
	local att = dmg:GetAttacker()
	local inf = dmg:GetInflictor()

	if ( att:IsWorld() and inf:IsWorld() ) then
		if ( ent:IsPlayer() ) then dmg:SetDamage( 0 ) return false end
	elseif ( not aegis.HasAccess( ent, aegis.GetUID( att, aegis.GetUID( inf ) ), AEGIS_ALL_DAMAGE ) ) then
		dmg:SetDamage( 0 )
		return false
	end
end )

--[[--------------------------------------------------------------------------
--
-- 	Hook :: CanProperty( player, string, entity )
--
--]]--
hook.Add( "CanProperty", "Aegis", function( ply, property, ent )
	if ( not IsValid( ply ) ) then return false end

	local override = hook.Run( "AegisCanProperty", ply, property, ent ) 
	if ( override ~= nil ) then return override end

	return aegis.HasAccess( ent, ply, AEGIS_ALL_TOOL )
end )

--[[--------------------------------------------------------------------------
--
-- 	Hook :: CanEditVariable( entity, player, string, *, table )
--
--]]--
hook.Add( "CanEditVariable", "Aegis", function( ent, ply, key, val, editor )
	if ( not IsValid( ply ) ) then return false end
	
	local override = hook.Run( "AegisCanEditVariable", ent, ply, key, val, editor ) 
	if ( override ~= nil ) then return override end

	return aegis.HasAccess( ent, ply, AEGIS_ALL_TOOL )
end )

--[[--------------------------------------------------------------------------
--
-- 	Hook :: OnPhysgunReload( weapon, player )
--
--]]--
hook.Add( "OnPhysgunReload", "Aegis", function( wep, ply )
	local ent = ply:GetEyeTrace().Entity
	if ( not IsValid( ent ) ) then return false end
	
	local override = hook.Run( "AegisOnPhysgunReload", wep, ply ) 
	if ( override ~= nil ) then return override end
	
	if ( not aegis.HasAccess( ent, ply, AEGIS_ALL_PHYSGUN ) ) then 
		return false
	end
	
	-- to allow the player, don't return anything!
end )

--[[--------------------------------------------------------------------------	
	File name:
		enum.lua
		
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

aegis.LOCAL_ID  = 'local'
aegis.GLOBAL_ID = 'global'

aegis.lookup_local    = aegis.lookup_local    or {}
aegis.lookup_global   = aegis.lookup_global   or {}
aegis.local_to_global = aegis.local_to_global or {}
aegis.access_priority = aegis.access_priority or {
	[aegis.LOCAL_ID]  = {},
	[aegis.GLOBAL_ID] = {},
}

aegis.NO_PERMISSION = 0 -- default value indicating permission has not been given for an action

--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

-- dynamically generate access enumerations so that they can be added/removed freely
aegis.next_enum_bit = aegis.next_enum_bit or aegis.NO_PERMISSION

function aegis.GenerateEnum()
	aegis.next_enum_bit = aegis.next_enum_bit + 1
	return bit.lshift( 1, aegis.next_enum_bit - 1 )
end

local function addAccess( tbl, id, name, description, priority )
	local enum = aegis.GenerateEnum()
	aegis['lookup_'..tbl][id] = enum
	
	local data = {
		id   = id,
		name = name,
		enum = enum,
		desc = description
	}
	
	local index = priority or (#aegis.access_priority[tbl] + 1)
	
	table.insert( aegis.access_priority[tbl], index, data )
	
	return enum
end

function aegis.CreateAccess( id, name, description, priority )
	local localEnum  = addAccess( aegis.LOCAL_ID,   id, name, "Allows this player " .. description, priority )
	local globalEnum = addAccess( aegis.GLOBAL_ID, id, name, "Allows everyone "    .. description, priority )
	
	aegis.local_to_global[localEnum] = globalEnum
	
	return localEnum, globalEnum, bit.bor( localEnum, globalEnum )
end

function aegis.ClearAccesses()
	aegis.next_enum_bit   = aegis.NO_PERMISSION
	aegis.lookup_local    = {}
	aegis.lookup_global   = {}
	aegis.local_to_global = {}
	aegis.access_priority = {
		[aegis.LOCAL_ID]  = {},
		[aegis.GLOBAL_ID] = {},
	}
end

aegis.ClearAccesses()

AEGIS_LOCAL_WHITELIST, AEGIS_GLOBAL_WHITELIST, AEGIS_ALL_WHITELIST = aegis.CreateAccess( 'whitelist', 'Whitelist', 'full permission' )
AEGIS_LOCAL_PHYSGUN,   AEGIS_GLOBAL_PHYSGUN,   AEGIS_ALL_PHYSGUN   = aegis.CreateAccess( 'physgun',   'Physgun',   'to pick up your stuff with the physgun' )
AEGIS_LOCAL_GRAVGUN,   AEGIS_GLOBAL_GRAVGUN,   AEGIS_ALL_GRAVGUN   = aegis.CreateAccess( 'gravgun',   'Grav Gun',  'to pick up your stuff with the gravity cannon' )
AEGIS_LOCAL_TOOL,      AEGIS_GLOBAL_TOOL,      AEGIS_ALL_TOOL      = aegis.CreateAccess( 'tool',      'Tool',      'to use tools on your stuff' )
AEGIS_LOCAL_USE,       AEGIS_GLOBAL_USE,       AEGIS_ALL_USE       = aegis.CreateAccess( 'use',       'Use (E)',   'to sit in seats or press your buttons' )
AEGIS_LOCAL_DAMAGE,    AEGIS_GLOBAL_DAMAGE,    AEGIS_ALL_DAMAGE    = aegis.CreateAccess( 'damage',    'Damage',    'to damage you and your stuff (but NOT with ACF)' )
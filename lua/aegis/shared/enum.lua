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



--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

-- dynamically generate access enumerations so that they can be added/removed freely
local BIT = 0

local function getEnum()
	BIT = BIT + 1
	return bit.lshift( 1, BIT - 1 )
end

-- local enumerations (per player)
AEGIS_WHITELIST = getEnum()
AEGIS_PHYSGUN   = getEnum()
AEGIS_TOOL      = getEnum()
AEGIS_USE       = getEnum()
AEGIS_DAMAGE    = getEnum()

-- global enumerations
AEGIS_GLOBAL_WHITELIST = getEnum()
AEGIS_GLOBAL_PHYSGUN   = getEnum()
AEGIS_GLOBAL_TOOL      = getEnum()
AEGIS_GLOBAL_USE       = getEnum()
AEGIS_GLOBAL_DAMAGE    = getEnum()

-- convenient bit masks that include local, global, and whitelist components
AEGIS_ALL_WHITELIST = bit.bor( AEGIS_WHITELIST, AEGIS_GLOBAL_WHITELIST )
AEGIS_ALL_PHYSGUN   = bit.bor( AEGIS_PHYSGUN,   AEGIS_GLOBAL_PHYSGUN, AEGIS_ALL_WHITELIST )
AEGIS_ALL_TOOL      = bit.bor( AEGIS_TOOL,      AEGIS_GLOBAL_TOOL,    AEGIS_ALL_WHITELIST )
AEGIS_ALL_USE       = bit.bor( AEGIS_USE,       AEGIS_GLOBAL_USE,     AEGIS_ALL_WHITELIST )
AEGIS_ALL_DAMAGE    = bit.bor( AEGIS_DAMAGE,    AEGIS_GLOBAL_DAMAGE,  AEGIS_ALL_WHITELIST )

-- lookup table for local to global enums
aegis.local_to_global = {
	[AEGIS_WHITELIST] = AEGIS_GLOBAL_WHITELIST,
	[AEGIS_PHYSGUN]   = AEGIS_GLOBAL_PHYSGUN,
	[AEGIS_TOOL]      = AEGIS_GLOBAL_TOOL,
	[AEGIS_USE]       = AEGIS_GLOBAL_USE,
	[AEGIS_DAMAGE]    = AEGIS_GLOBAL_DAMAGE,
}

-- lookup table for local names to enums
aegis.lookup_local = {
	whitelist = AEGIS_WHITELIST,
	physgun   = AEGIS_PHYSGUN,
	tool      = AEGIS_TOOL,
	use       = AEGIS_USE,
	damage    = AEGIS_DAMAGE,
}

-- lookup table for global names to enums
aegis.lookup_global = {
	whitelist = AEGIS_GLOBAL_WHITELIST,
	physgun   = AEGIS_GLOBAL_PHYSGUN,
	tool      = AEGIS_GLOBAL_TOOL,
	use       = AEGIS_GLOBAL_USE,
	damage    = AEGIS_GLOBAL_DAMAGE,
}

aegis.access_priority = {
	['local'] = {
		{name = 'whitelist', enum = AEGIS_WHITELIST, desc = "Gives this player full permission" },
		{name = 'physgun',   enum = AEGIS_PHYSGUN,   desc = "Lets this player pick up your stuff"},
		{name = 'tool',      enum = AEGIS_TOOL,      desc = "Lets this player use any tool on your stuff"},
		{name = 'use',       enum = AEGIS_USE,       desc = "Lets this player sit in your seats or push buttons"},
		{name = 'damage',    enum = AEGIS_DAMAGE,    desc = "Lets this player damage you with weapons and props (NOT ACF)"},
	},
	global = {
		{name = 'whitelist', enum = AEGIS_GLOBAL_WHITELIST, desc = "Grants all permissions to all players"},
		{name = 'physgun',   enum = AEGIS_GLOBAL_PHYSGUN,   desc = "Lets all players pick up your stuff"},
		{name = 'tool',      enum = AEGIS_GLOBAL_TOOL,      desc = "Lets all players use any tool on your stuff"},
		{name = 'use',       enum = AEGIS_GLOBAL_USE,       desc = "Lets all players sit in your seats or push buttons"},
		{name = 'damage',    enum = AEGIS_GLOBAL_DAMAGE,    desc = "Lets all players damage you with weapons and props (NOT ACF)"},
	}
}
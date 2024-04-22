-- In luascript.h DIFF
-- 828: +static int luaCreatureGetNextPosition(lua_State* L);
--
-- In luascript.cpp DIFF
-- 29: +#include "tools.h"
-- 2302: +registerMethod("Creature", "getNextPosition", LuaScriptInterface::luaCreatureGetNextPosition);
--[[ 7592: +
int LuaScriptInterface::luaCreatureGetNextPosition(lua_State* L)
{
	const Creature* creature = getUserdata<const Creature>(L, 1);
	if (creature) {
		pushPosition(L, getNextPosition(creature->getDirection(), creature->getPosition()));
	} else {
		lua_pushnil(L);
	}

	return 1;
}
]]

-- I tried and failed to reproduce the shader, but I did manage to deliver the skill.
-- video link: https://youtu.be/zWteooPN2c4
-- shader video link: https://youtu.be/8NUU-UMCOLc

local cnt = 0
local playerId = 0
local SHIFTS = 4 -- amount of tiles player will try to travel, negative or zero means no travel.
local SHIFT_DELAY_MS = 10 -- delay, in milliseconds, between shifts.

local function shift()
  if cnt > (SHIFTS - 1) then
    return true -- all shifts finished.
  end

  cnt = cnt + 1
  addEvent(shift, SHIFT_DELAY_MS) -- queue shifts.

  local player = Player(playerId)
  local nextPosition = player:getNextPosition() -- this function was added to Lua script interface, check the beginning of the file.
  local tile = Tile(nextPosition)

  -- Try to relocate to the desired position.
  if not tile:hasFlag(TILESTATE_BLOCKSOLID) then
    player:teleportTo(nextPosition) -- Alternative: player:move(player:getDirection())
  end
end

-- Skill is triggered by using an item (I picked a random one for the trial).
-- For the production I would use other approach or more complex code to address downsides such as no cooldown, no diagonal shift, etc.
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
  cnt = 0
  playerId = player:getId()
  return shift()
end

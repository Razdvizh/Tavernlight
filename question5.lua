-- Areas
-- 3 for the caster tile, 1 for effect tile, 0 for unused tile.
-- Unfortunately, `createCombatArea` can be called only when the script is being loaded, so we have to prepare multiple areas instead of generating random ones.
-- Reducing amount of 1's for areas 2-5 will help for larger amounts of intervals and lower interval delays.
local AREA_STAR1 = {
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 1, 0, 1, 0, 0},
	{0, 1, 0, 1, 0, 1, 0},
	{1, 0, 1, 3, 1, 0, 1},
	{0, 1, 0, 1, 0, 1, 0},
	{0, 0, 1, 0, 1, 0, 0},
	{0, 0, 0, 1, 0, 0, 0}
}

local AREA_STAR2 = {
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 0, 0, 1, 0, 0},
	{0, 1, 0, 0, 0, 0, 0},
	{0, 0, 1, 3, 1, 0, 1},
	{0, 1, 0, 1, 0, 1, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 1, 0, 0, 0}
}

local AREA_STAR3 = {
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 1, 0, 1, 0, 0},
	{0, 0, 0, 1, 0, 0, 0},
	{1, 0, 1, 3, 1, 0, 1},
	{0, 1, 0, 0, 0, 1, 0},
	{0, 0, 0, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 0, 0}
}

local AREA_STAR4 = {
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 1, 0, 0, 0, 0},
	{0, 1, 0, 0, 0, 1, 0},
	{0, 0, 1, 3, 0, 0, 1},
	{0, 1, 0, 0, 0, 1, 0},
	{0, 0, 1, 0, 1, 0, 0},
	{0, 0, 0, 1, 0, 0, 0}
}

local AREA_STAR5 = {
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 1, 0, 0, 0, 1, 0},
	{0, 0, 1, 3, 1, 0, 0},
	{0, 1, 0, 0, 0, 0, 0},
	{0, 0, 1, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 0, 0}
}

-- Combats
-- Unfortunately, `createCombatArea` can be called only when the script is being loaded, so we have to prepare multiple combats instead of multiple combat areas.
-- More combats and areas equals more randomness.
local combat1 = Combat()
combat1:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat1:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
combat1:setArea(createCombatArea(AREA_STAR1))

local combat2 = Combat()
combat2:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat2:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
combat2:setArea(createCombatArea(AREA_STAR2))

local combat3 = Combat()
combat3:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat3:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
combat3:setArea(createCombatArea(AREA_STAR3))

local combat4 = Combat()
combat4:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat4:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
combat4:setArea(createCombatArea(AREA_STAR4))

local combat5 = Combat()
combat5:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat5:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
combat5:setArea(createCombatArea(AREA_STAR5))

local arrayOfCombats = {combat1, combat2, combat3, combat4, combat5}

-- Fisher-Yates
local function shuffle()
  for i = #arrayOfCombats, 2, -1 do
    local j = math.random(i)
    arrayOfCombats[i], arrayOfCombats[j] = arrayOfCombats[j], arrayOfCombats[i]
  end
end

local function pickRandomCombat()
  return arrayOfCombats[math.random(1, 5)]
end

-- Spell
-- words: 'frigo'
-- Cast ice tornado bursts in a star area.
-- spells.xml: level="60" mana="1050" selftarget="1" premium="1" cooldown="40000" groupcooldown="4000"
-- video link: https://youtu.be/nrV_zjTa2gM
local castSpellArgs = {}
local cnt = 0
local INTERVAL_DELAY_MS = 500 -- delay between skill bursts, in milliseconds.
local INTERVALS = 5	-- amount of skill bursts, negative or zero means no spell cast.

local function castSpell()
  if cnt > (INTERVALS - 1) then
    return true -- spell was casted.
  end

  cnt = cnt + 1
  addEvent(castSpell, INTERVAL_DELAY_MS) -- queue skill bursts.

  -- Cast random skill burst.
  local combat = pickRandomCombat()
  return combat:execute(Creature(castSpellArgs.id), castSpellArgs.variant)
end

-- Damage formula from attack/eternal_winter.lua
function onGetFormulaValues(player, level, magicLevel)
  local min = (level / 5) + (magicLevel * 5.5) + 25
  local max = (level / 5) + (magicLevel * 11) + 50
  return -min, -max
end

-- https://otland.net/threads/tfs-1-x-combat-setcallbackfunction-event-function.283490/
for i = 1, #arrayOfCombats do
  arrayOfCombats[i]:setCallbackFunction(CALLBACK_PARAM_LEVELMAGICVALUE, onGetFormulaValues)
end

function onCastSpell(creature, variant)
  shuffle() -- this can be removed or done once or called in `pickRandomCombat`, depending on how much randomness we want.

  cnt = 0
  castSpellArgs.id = creature:getId() -- it is unsafe to pass the creature itself, using an id instead.
  castSpellArgs.variant = variant

  return castSpell() 
end

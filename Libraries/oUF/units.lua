local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local enableTargetUpdate = Private.enableTargetUpdate

function oUF:HandleUnit(object, unit)
	local unit = object.unit or unit

	if(unit == "target") then
		object:RegisterEvent("PLAYER_TARGET_CHANGED", object.UpdateAllElements)
	elseif(unit == "mouseover") then
		object:RegisterEvent("UPDATE_MOUSEOVER_UNIT", object.UpdateAllElements)
	elseif(unit == "focus") then
		object:RegisterEvent("PLAYER_FOCUS_CHANGED", object.UpdateAllElements)
	elseif(unit:match"(boss)%d?$" == "boss") then
		object:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", object.UpdateAllElements, true)
	elseif(unit:match"%w+target") then
		enableTargetUpdate(object)
	end
end
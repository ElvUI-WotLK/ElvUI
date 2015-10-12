local _, ns = ...
local oUF = ns.oUF or oUF

local playerClass = select(2,UnitClass("player"))
local CanDispel = {
	PRIEST = { Magic = true, Disease = true, },
	SHAMAN = { Poison = true, Disease = true, Curse = true, },
	PALADIN = { Magic = true, Poison = true, Disease = true, },
	MAGE = { Curse = true, },
	DRUID = { Curse = true, Poison = true, }
}
local dispellist = CanDispel[playerClass] or {}
local origColors = {}
local origBorderColors = {}
local origPostUpdateAura = {}

local function GetDebuffType(unit, filter, filterTable)
	if not UnitCanAssist("player", unit) then return nil end
	local i = 1
	while true do
		local name, _, texture, _, debufftype = UnitAura(unit, i, "HARMFUL")
		if not texture then break end
		if(filterTable and filterTable[name] and filterTable[name].enable) then
			return debufftype, texture, true, filterTable[name].style, filterTable[name].color;
		elseif(debufftype and (not filter or (filter and dispellist[debufftype]))) then
			return debufftype, texture;
		end
		i = i + 1
	end
end

local function Update(object, event, unit)
	if(object.unit ~= unit) then return; end
	
	local debuffType, texture, wasFiltered, style, color = GetDebuffType(unit, object.DebuffHighlightFilter, object.DebuffHighlightFilterTable);
	if(wasFiltered) then
		if(style == "GLOW" and object.DBHGlow) then
			object.DBHGlow:Show();
			object.DBHGlow:SetBackdropBorderColor(color.r, color.g, color.b);
		elseif(object.DBHGlow) then
			object.DBHGlow:Hide();
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a or object.DebuffHighlightAlpha or .5);
		end
	elseif(debuffType) then
		color = DebuffTypeColor[debuffType];
		if(object.DebuffHighlightBackdrop and object.DBHGlow) then
			object.DBHGlow:Show();
			object.DBHGlow:SetBackdropBorderColor(color.r, color.g, color.b);
		elseif(object.DebuffHighlightUseTexture) then
			object.DebuffHighlight:SetTexture(texture);
		else
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or .5);
		end
	else
		if(object.DBHGlow) then
			object.DBHGlow:Hide();
		end

		if(object.DebuffHighlightUseTexture) then
			object.DebuffHighlight:SetTexture(nil);
		else
			object.DebuffHighlight:SetVertexColor(0, 0, 0, 0);
		end
	end
end

local function Enable(object)
	-- if we're not highlighting this unit return
	if not object.DebuffHighlightBackdrop and not object.DebuffHighlight and not object.DBHGlow then
		return
	end
	-- if we're filtering highlights and we're not of the dispelling type, return
	if object.DebuffHighlightFilter and not CanDispel[playerClass] then
		return
	end
	
	-- make sure aura scanning is active for this object
	object:RegisterEvent("UNIT_AURA", Update)

	return true
end

local function Disable(object)
	if object.DebuffHighlightBackdrop or object.DebuffHighlight or object.DBHGlow then
		object:UnregisterEvent("UNIT_AURA", Update)
		
		if(object.DBHGlow) then
			object.DBHGlow:Hide();
		end
		
		if(object.DebuffHighlight) then
			local color = origColors[object];
			if(color) then
				object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a);
			end
		end
	end
end

oUF:AddElement('DebuffHighlight', Update, Enable, Disable)

for i, frame in ipairs(oUF.objects) do Enable(frame) end
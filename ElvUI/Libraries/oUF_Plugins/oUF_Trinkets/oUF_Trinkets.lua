local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_Trinkets was unable to locate oUF install")

local GetTime = GetTime
local IsInInstance = IsInInstance
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID

local trinketSpells = {
	[7744] = 45,
	[42292] = 120,
	[59752] = 120,
}

local function GetTrinketIcon(unit)
	if UnitFactionGroup(unit) == "Horde" then
		return "Interface\\Icons\\INV_Jewelry_TrinketPVP_02"
	else
		return "Interface\\Icons\\INV_Jewelry_TrinketPVP_01"
	end
end

local function Update(self, event, ...)
	local element = self.Trinket

	local _, instanceType = IsInInstance()
	if instanceType ~= "arena" then
		element:Hide()
		return
	else
		element:Show()
	end

	if element.PreUpdate then
		element:PreUpdate(event)
	end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, sourceGUID, _, _, _, _, _, spellID = ...

		if eventType == "SPELL_CAST_SUCCESS" and trinketSpells[spellID] and sourceGUID == UnitGUID(self.unit) then
			CooldownFrame_SetTimer(element.cooldownFrame, GetTime(), trinketSpells[spellID], 1)
		end
	elseif event == "ARENA_OPPONENT_UPDATE" then
		local unit, type = ...

		if type == "seen" then
			if UnitExists(unit) and UnitIsPlayer(unit) then
				element.Icon:SetTexture(GetTrinketIcon(unit))
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		CooldownFrame_SetTimer(element.cooldownFrame, 1, 1, 1)
	end

	if element.PostUpdate then
		element:PostUpdate(event)
	end
end

local function Enable(self)
	local element = self.Trinket

	if element then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Update, true)
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", Update, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update, true)

		if not element.cooldownFrame then
			element.cooldownFrame = CreateFrame("Cooldown", nil, element)
			element.cooldownFrame:SetAllPoints(element)
			ElvUI[1]:RegisterCooldown(element.cooldownFrame)
		end

		if not element.Icon then
			element.Icon = element:CreateTexture(nil, "BORDER")
			element.Icon:SetAllPoints(element)
			element.Icon:SetTexture(GetTrinketIcon("player"))
			element.Icon:SetTexCoord(unpack(ElvUI[1].TexCoords))
		end

		return true
	end
end

local function Disable(self)
	local element = self.Trinket

	if element then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Update)
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE", Update)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
		element:Hide()
	end
end

oUF:AddElement("Trinket", Update, Enable, Disable)
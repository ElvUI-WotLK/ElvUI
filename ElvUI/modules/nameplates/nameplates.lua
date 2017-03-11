local E, L, V, P, G = unpack(select(2, ...))
local mod = E:NewModule("NamePlates", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

local _G = _G
local pairs, tonumber = pairs, tonumber
local gsub = string.gsub
local twipe = table.wipe

local CreateFrame = CreateFrame
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local SetCVar = SetCVar
local WorldFrame = WorldFrame
local WorldGetNumChildren, WorldGetChildren = WorldFrame.GetNumChildren, WorldFrame.GetChildren

local numChildren = 0
local OVERLAY = [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=]
local FSPAT = "%s*" .. ((_G.FOREIGN_SERVER_LABEL:gsub("^%s", "")):gsub("[%*()]", "%%%1")) .. "$"

local RaidIconCoordinate = {
	[0] = {[0] = "STAR", [0.25] = "MOON"},
	[0.25] = {[0] = "CIRCLE", [0.25] = "SQUARE"},
	[0.5] = {[0] = "DIAMOND", [0.25] = "CROSS"},
	[0.75] = {[0] = "TRIANGLE", [0.25] = "SKULL"}
}

mod.CreatedPlates = {}
mod.VisiblePlates = {}
mod.Healers = {}

function mod:CheckBGHealers()
	local name, _, damageDone, healingDone
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, _, damageDone, healingDone = GetBattlefieldScore(i)
		if name then
			name = name:match("(.+)%-.+") or name
			if name and healingDone > damageDone then
				self.Healers[name] = true
			elseif name and self.Healers[name] then
				self.Healers[name] = nil
			end
		end
	end
end

function mod:SetFrameScale(frame, scale)
	if frame.HealthBar.currentScale ~= scale then
		if frame.HealthBar.scale:IsPlaying() then
			frame.HealthBar.scale:Stop()
		end
		frame.HealthBar.scale.width:SetChange(self.db.units[frame.UnitType].healthbar.width * scale)
		frame.HealthBar.scale.height:SetChange(self.db.units[frame.UnitType].healthbar.height * scale)
		frame.HealthBar.scale:Play()
		frame.HealthBar.currentScale = scale
	end
end

function mod:SetTargetFrame(frame)
	local targetExists = UnitExists("target") == 1
	if targetExists and frame:GetParent():IsShown() and frame:GetParent():GetAlpha() == 1 and not frame.isTarget then
		if self.db.useTargetScale then
			self:SetFrameScale(frame, self.db.targetScale)
		end
		frame.isTarget = true
		frame.unit = "target"
		frame.guid = UnitGUID("target")

		if frame.UnitType == "FRIENDLY_PLAYER" then
			local _, class = UnitClass("target")
			frame.UnitClass = class
			mod:UpdateElement_Name(frame)
		end
		
		if self.db.units[frame.UnitType].healthbar.enable ~= true then
			frame.Name:ClearAllPoints()
			frame.Level:ClearAllPoints()
			frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = nil, nil, nil
			self:ConfigureElement_HealthBar(frame)
			self:ConfigureElement_CastBar(frame)
			self:ConfigureElement_Glow(frame)
			self:ConfigureElement_Elite(frame)
			self:ConfigureElement_Level(frame)
			self:ConfigureElement_Name(frame)
			self:UpdateElement_All(frame, true)
		end

		frame:SetAlpha(1)

		mod:UpdateElement_AurasByUnitID("target")
	elseif frame.isTarget then
		if self.db.useTargetScale then
			self:SetFrameScale(frame, frame.ThreatScale or 1)
		end
		frame.isTarget = nil
		frame.unit = nil
		frame.guid = nil
		if self.db.units[frame.UnitType].healthbar.enable ~= true then
			self:UpdateAllFrame(frame)
		end

		if targetExists then
			frame:SetAlpha(self.db.nonTargetTransparency)
		else
			frame:SetAlpha(1)
		end
	else
		if targetExists then
			frame:SetAlpha(self.db.nonTargetTransparency)
		else
			frame:SetAlpha(1)
		end
	end

	mod.UpdateElement_HealthOnValueChanged(frame.oldHealthBar, frame.oldHealthBar:GetValue())
	mod:UpdateElement_CPoints(frame)
end

function mod:StyleFrame(parent, noBackdrop, point)
	point = point or parent
	local noscalemult = E.mult * UIParent:GetScale()

	if point.bordertop then return end

	if not noBackdrop then
		point.backdrop = parent:CreateTexture(nil, "BACKGROUND")
		point.backdrop:SetAllPoints(point)
		point.backdrop:SetTexture(unpack(E["media"].backdropfadecolor))
	end

	if E.PixelMode then
		point.bordertop = parent:CreateTexture()
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E["media"].bordercolor))

		point.borderbottom = parent:CreateTexture()
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E["media"].bordercolor))

		point.borderleft = parent:CreateTexture()
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E["media"].bordercolor))

		point.borderright = parent:CreateTexture()
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E["media"].bordercolor))
	else
		point.bordertop = parent:CreateTexture(nil, "OVERLAY")
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult*2)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult*2)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E.media.bordercolor))

		point.bordertop.backdrop = parent:CreateTexture()
		point.bordertop.backdrop:SetPoint("TOPLEFT", point.bordertop, "TOPLEFT", noscalemult, noscalemult)
		point.bordertop.backdrop:SetPoint("TOPRIGHT", point.bordertop, "TOPRIGHT", -noscalemult, noscalemult)
		point.bordertop.backdrop:SetHeight(noscalemult * 3)
		point.bordertop.backdrop:SetTexture(0, 0, 0)

		point.borderbottom = parent:CreateTexture(nil, "OVERLAY")
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult*2)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult*2)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E.media.bordercolor))

		point.borderbottom.backdrop = parent:CreateTexture()
		point.borderbottom.backdrop:SetPoint("BOTTOMLEFT", point.borderbottom, "BOTTOMLEFT", noscalemult, -noscalemult)
		point.borderbottom.backdrop:SetPoint("BOTTOMRIGHT", point.borderbottom, "BOTTOMRIGHT", -noscalemult, -noscalemult)
		point.borderbottom.backdrop:SetHeight(noscalemult * 3)
		point.borderbottom.backdrop:SetTexture(0, 0, 0)

		point.borderleft = parent:CreateTexture(nil, "OVERLAY")
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult*2, -noscalemult*2)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E.media.bordercolor))

		point.borderleft.backdrop = parent:CreateTexture()
		point.borderleft.backdrop:SetPoint("TOPLEFT", point.borderleft, "TOPLEFT", -noscalemult, noscalemult)
		point.borderleft.backdrop:SetPoint("BOTTOMLEFT", point.borderleft, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderleft.backdrop:SetWidth(noscalemult * 3)
		point.borderleft.backdrop:SetTexture(0, 0, 0)

		point.borderright = parent:CreateTexture(nil, "OVERLAY")
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult*2, -noscalemult*2)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E.media.bordercolor))

		point.borderright.backdrop = parent:CreateTexture()
		point.borderright.backdrop:SetPoint("TOPRIGHT", point.borderright, "TOPRIGHT", noscalemult, noscalemult)
		point.borderright.backdrop:SetPoint("BOTTOMRIGHT", point.borderright, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderright.backdrop:SetWidth(noscalemult * 3)
		point.borderright.backdrop:SetTexture(0, 0, 0)
	end
end

function mod:RoundColors(r, g, b)
	return floor(r*100+.5) / 100, floor(g*100+.5) / 100, floor(b*100+.5) / 100
end

function mod:UnitClass(frame, type)
	local r, g, b = self:RoundColors(frame.oldHealthBar:GetStatusBarColor())

	if type == "FRIENDLY_PLAYER" then
		if UnitInParty("player") or UnitInRaid("player") then -- FRIENDLY_PLAYER
			local _, class = UnitClass(frame.UnitName)
			if class then return class end
		end
	elseif type == "ENEMY_PLAYER" then
		for class, _ in pairs(RAID_CLASS_COLORS) do -- ENEMY_PLAYER
			if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == b then
				return class
			end
		end
	end
end

function mod:UnitDetailedThreatSituation(frame)
	if frame.Threat:IsShown() then
		local _, g, b = frame.Threat:GetVertexColor()
		if g + b == 0 then
			return 3
		else
			if self.ThreatReaction == 3 then
				return 2
			else
				return 1
			end
		end
	else
		return false
	end
end

function mod:UnitLevel(frame)
	local level, elite, boss = frame.oldLevel:GetObjectType() == "FontString" and tonumber(frame.oldLevel:GetText()) or false, frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()
	if boss or not level then
		return "??", 0.9, 0, 0
	else
		return level, frame.oldLevel:GetTextColor()
	end
end

function mod:GetUnitInfo(frame)
	local r, g, b = mod:RoundColors(frame.oldHealthBar:GetStatusBarColor())

	if r < .01 then
		if b < .01 and g > .99 then
			return 5, "FRIENDLY_NPC";
		elseif b > .99 and g < .01 then
			return 5, "FRIENDLY_PLAYER";
		end
	elseif r > .99 then
		if b < .01 and g > .99 then
			return 4, "ENEMY_NPC";
		elseif b < .01 and g < .01 then
			return 2, "ENEMY_NPC";
		end
	elseif r > .5 and r < .6 then
		if g > .5 and g < .6 and b > .5 and b < .6 then
			return 1, "ENEMY_NPC";
		end
	end
	return 3, "ENEMY_PLAYER";
end

function mod:OnShow()
	mod.VisiblePlates[self.UnitFrame] = true

	self.UnitFrame.UnitName = gsub(self.UnitFrame.oldName:GetText(), FSPAT, "")
	local unitReaction, unitType = mod:GetUnitInfo(self.UnitFrame)
	self.UnitFrame.UnitType = unitType
	self.UnitFrame.UnitClass = mod:UnitClass(self.UnitFrame, unitType)
	self.UnitFrame.UnitReaction = unitReaction

	if unitType == "ENEMY_PLAYER" then
		mod:UpdateElement_HealerIcon(self.UnitFrame)
	end

	self.UnitFrame.Level:ClearAllPoints()
	self.UnitFrame.Name:ClearAllPoints()

	mod:ConfigureElement_HealthBar(self.UnitFrame)
	if mod.db.units[unitType].healthbar.enable then
		mod:ConfigureElement_CastBar(self.UnitFrame)
		mod:ConfigureElement_Glow(self.UnitFrame)

		if mod.db.units[unitType].buffs.enable then
			self.UnitFrame.Buffs.db = mod.db.units[unitType].buffs
			mod:UpdateAuraIcons(self.UnitFrame.Buffs)
		end

		if mod.db.units[unitType].debuffs.enable then
			self.UnitFrame.Debuffs.db = mod.db.units[unitType].debuffs
			mod:UpdateAuraIcons(self.UnitFrame.Debuffs)
		end
	end

	if mod.db.units[unitType].healthbar.enable then
		mod:ConfigureElement_Name(self.UnitFrame)
		mod:ConfigureElement_Level(self.UnitFrame)
	else
		mod:ConfigureElement_Level(self.UnitFrame)
		mod:ConfigureElement_Name(self.UnitFrame)
	end
	mod:ConfigureElement_Elite(self.UnitFrame)

	mod:UpdateElement_All(self.UnitFrame)

	self.UnitFrame:Show()
end

function mod:OnHide()
	mod.VisiblePlates[self.UnitFrame] = nil

	self.UnitFrame.unit = nil

	mod:HideAuraIcons(self.UnitFrame.Buffs)
	mod:HideAuraIcons(self.UnitFrame.Debuffs)
	self.UnitFrame.Glow.r, self.UnitFrame.Glow.g, self.UnitFrame.Glow.b = nil, nil, nil
	self.UnitFrame.Glow:Hide()
	self.UnitFrame.HealthBar.r, self.UnitFrame.HealthBar.g, self.UnitFrame.HealthBar.b = nil, nil, nil
	self.UnitFrame.HealthBar:Hide()
	self.UnitFrame.CastBar:Hide()
	self.UnitFrame.Level:ClearAllPoints()
	self.UnitFrame.Level:SetText("")
	self.UnitFrame.Name:ClearAllPoints()
	self.UnitFrame.Name:SetText("")
	self.UnitFrame.Elite:Hide()
	self.UnitFrame:Hide()
	self.UnitFrame.isTarget = nil
	self.UnitFrame.displayedUnit = nil
	self.ThreatData = nil
	self.UnitFrame.UnitName = nil
	self.UnitFrame.UnitType = nil

	self.UnitFrame.threatReaction = nil
	self.UnitFrame.guid = nil
	self.UnitFrame.raidIconType = nil
	self.UnitFrame.customColor = nil
	self.UnitFrame.customScale = nil
	self.UnitFrame.allowCheck = nil
end

function mod:UpdateAllFrame(frame)
	mod.OnHide(frame:GetParent())
	mod.OnShow(frame:GetParent())
end

function mod:ConfigureAll()
	if E.private.nameplates.enable ~= true then return end

	self:ForEachPlate("UpdateAllFrame")
	self:UpdateCVars()
end

function mod:ForEachPlate(functionToRun, ...)
	for frame in pairs(self.CreatedPlates) do
		if frame and frame.UnitFrame then
			self[functionToRun](self, frame.UnitFrame, ...)
		end
	end
end

function mod:UpdateElement_All(frame, noTargetFrame)
	if self.db.units[frame.UnitType].healthbar.enable or frame.isTarget then
		mod.UpdateElement_HealthOnValueChanged(frame.oldHealthBar, frame.oldHealthBar:GetValue())
		mod:UpdateElement_Auras(frame)
	end
	mod:UpdateElement_RaidIcon(frame)
	mod:UpdateElement_HealerIcon(frame)
	mod:UpdateElement_Name(frame)
	mod:UpdateElement_Level(frame)
	mod:UpdateElement_Elite(frame)

	if not noTargetFrame then
		mod:ScheduleTimer("SetTargetFrame", 0.01, frame)
	end
end

function mod:OnCreated(frame)
	local HealthBar, CastBar = frame:GetChildren()
	local Threat, Border, CastBarBorder, CastBarShield, CastBarIcon, Highlight, Name, Level, BossIcon, RaidIcon, EliteIcon = frame:GetRegions()

	frame.UnitFrame = CreateFrame("Frame", nil, frame)
	frame.UnitFrame:SetAllPoints()

	frame.UnitFrame.HealthBar = self:ConstructElement_HealthBar(frame.UnitFrame)
	frame.UnitFrame.CastBar = self:ConstructElement_CastBar(frame.UnitFrame)
	frame.UnitFrame.Level = self:ConstructElement_Level(frame.UnitFrame)
	frame.UnitFrame.Name = self:ConstructElement_Name(frame.UnitFrame)
	frame.UnitFrame.Glow = self:ConstructElement_Glow(frame.UnitFrame)
	frame.UnitFrame.Elite = self:ConstructElement_Elite(frame.UnitFrame)
	frame.UnitFrame.Buffs = self:ConstructElement_Auras(frame.UnitFrame, "LEFT")
	frame.UnitFrame.Debuffs = self:ConstructElement_Auras(frame.UnitFrame, "RIGHT")
	frame.UnitFrame.HealerIcon = self:ConstructElement_HealerIcon(frame.UnitFrame)
	frame.UnitFrame.CPoints = self:ConstructElement_CPoints(frame.UnitFrame)

	self:QueueObject(HealthBar)
	self:QueueObject(CastBar)
	self:QueueObject(Level)
	self:QueueObject(Name)
	self:QueueObject(Threat)
	self:QueueObject(Border)
	self:QueueObject(CastBarBorder)
	self:QueueObject(CastBarShield)
	self:QueueObject(Highlight)
	self:QueueObject(CastBarIcon)
	BossIcon:SetAlpha(0)
	EliteIcon:SetAlpha(0)

	frame.UnitFrame.oldHealthBar = HealthBar
	frame.UnitFrame.oldCastBar = CastBar
	frame.UnitFrame.oldCastBar.Shield = CastBarShield
	frame.UnitFrame.oldCastBar.Icon = CastBarIcon
	frame.UnitFrame.oldName = Name
	frame.UnitFrame.oldHighlight = Highlight
	frame.UnitFrame.oldLevel = Level

	frame.UnitFrame.Threat = Threat
	frame.UnitFrame.RaidIcon = RaidIcon

	frame.UnitFrame.BossIcon = BossIcon
	frame.UnitFrame.EliteIcon = EliteIcon

	self.OnShow(frame)

	frame:HookScript("OnShow", self.OnShow)
	frame:HookScript("OnHide", self.OnHide)
	HealthBar:HookScript("OnValueChanged", self.UpdateElement_HealthOnValueChanged)
	CastBar:HookScript("OnShow", self.UpdateElement_CastBarOnShow)
	CastBar:HookScript("OnHide", self.UpdateElement_CastBarOnHide)
	CastBar:HookScript("OnValueChanged", self.UpdateElement_CastBarOnValueChanged)

	self.CreatedPlates[frame] = true
	self.VisiblePlates[frame.UnitFrame] = true
end

function mod:QueueObject(object)
	local objectType = object:GetObjectType()
	if objectType == "Texture" then
		object:SetTexture("")
		object:SetTexCoord(0, 0, 0, 0)
	elseif objectType == "FontString" then
		object:SetWidth(0.001)
	elseif objectType == "StatusBar" then
		object:SetStatusBarTexture("")
	end
	object:Hide()
end

function mod:OnUpdate(elapsed)
	local count = WorldGetNumChildren(WorldFrame)
	if count ~= numChildren then
		for i = numChildren + 1, count do
			local frame = select(i, WorldGetChildren(WorldFrame))
			local region = frame:GetRegions()

			if(not mod.CreatedPlates[frame] and region and region:GetObjectType() == "Texture" and region:GetTexture() == OVERLAY) then
				mod:OnCreated(frame)
			end
		end
		numChildren = count
	end

	for frame in pairs(mod.VisiblePlates) do
		if not frame.isTarget and frame:GetParent():GetAlpha() ~= 1 then
			frame:GetParent():SetAlpha(1)
		end
	end
end

function mod:CheckRaidIcon(frame)
	if frame.RaidIcon:IsShown() then
		local ux, uy = frame.RaidIcon:GetTexCoord()
		frame.raidIconType = RaidIconCoordinate[ux][uy]
	else
		frame.raidIconType = nil
	end
end

function mod:SearchNameplateByGUID(guid)
	for frame in pairs(self.VisiblePlates) do
		if frame and frame:IsShown() and frame.guid == guid then
			return frame
		end
	end
end

function mod:SearchNameplateByName(sourceName)
	if not sourceName then return end
	local SearchFor = strsplit("-", sourceName)
	for frame in pairs(self.VisiblePlates) do
		if frame and frame:IsShown() and frame.UnitName == SearchFor and RAID_CLASS_COLORS[frame.UnitClass] then
			return frame
		end
	end
end

function mod:SearchNameplateByIconName(raidIcon)
	for frame in pairs(self.VisiblePlates) do
		self:CheckRaidIcon(frame)
		if frame and frame:IsShown() and frame.RaidIcon:IsShown() and (frame.raidIconType == raidIcon) then
			return frame
		end
	end
end

function mod:SearchForFrame(guid, raidIcon, name)
	local frame
	if guid then frame = self:SearchNameplateByGUID(guid) end
	if (not frame) and name then frame = self:SearchNameplateByName(name) end
	if (not frame) and raidIcon then frame = self:SearchNameplateByIconName(raidIcon) end

	return frame
end

function mod:UpdateCVars()
	SetCVar("ShowClassColorInNameplate", "1")
	SetCVar("showVKeyCastbar", "1")
	SetCVar("nameplateAllowOverlap", self.db.motionType == "STACKED" and "0" or "1")
end

local function CopySettings(from, to)
	for setting, value in pairs(from) do
		if type(value) == "table" then
			CopySettings(from[setting], to[setting])
		else
			if to[setting] ~= nil then
				to[setting] = from[setting]
			end
		end
	end
end

function mod:ResetSettings(unit)
	CopySettings(P.nameplates.units[unit], self.db.units[unit])
end

function mod:CopySettings(from, to)
	if from == to then return end

	CopySettings(self.db.units[from], self.db.units[to])
end

function mod:PLAYER_ENTERING_WORLD()
	twipe(self.Healers)
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == "pvp" and self.db.units.ENEMY_PLAYER.markHealers then
		self.CheckHealerTimer = self:ScheduleRepeatingTimer("CheckBGHealers", 3)
		self:CheckBGHealers()
	else
		if self.CheckHealerTimer then
			self:CancelTimer(self.CheckHealerTimer)
			self.CheckHealerTimer = nil
		end
	end
end

function mod:PLAYER_TARGET_CHANGED()
	mod:ScheduleTimer("ForEachPlate", 0.01, "SetTargetFrame")
end

function mod:UNIT_AURA(_, unit)
	if unit == "target" then
		self:UpdateElement_AurasByUnitID("target")
	elseif unit == "focus" then
		self:UpdateElement_AurasByUnitID("focus")
	end
end

function mod:UNIT_COMBO_POINTS(_, unit)
	if unit == "player" or unit == "vehicle" then
		self:ForEachPlate("UpdateElement_CPoints")
	end
end

function mod:PLAYER_REGEN_DISABLED()
	if self.db.showFriendlyCombat == "TOGGLE_ON" then
		SetCVar("nameplateShowFriends", 1)
	elseif self.db.showFriendlyCombat == "TOGGLE_OFF" then
		SetCVar("nameplateShowFriends", 0)
	end

	if self.db.showEnemyCombat == "TOGGLE_ON" then
		SetCVar("nameplateShowEnemies", 1)
	elseif self.db.showEnemyCombat == "TOGGLE_OFF" then
		SetCVar("nameplateShowEnemies", 0)
	end
end

function mod:PLAYER_REGEN_ENABLED()
	if self.db.showFriendlyCombat == "TOGGLE_ON" then
		SetCVar("nameplateShowFriends", 0)
	elseif self.db.showFriendlyCombat == "TOGGLE_OFF" then
		SetCVar("nameplateShowFriends", 1)
	end

	if self.db.showEnemyCombat == "TOGGLE_ON" then
		SetCVar("nameplateShowEnemies", 0)
	elseif self.db.showEnemyCombat == "TOGGLE_OFF" then
		SetCVar("nameplateShowEnemies", 1)
	end
end

function mod:Initialize()
	if E.private["nameplates"].enable ~= true then return end
	self.db = E.db["nameplates"]

	self:UpdateCVars()

	self.Frame = CreateFrame("Frame"):SetScript("OnUpdate", self.OnUpdate)

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_COMBO_POINTS")

	E.NamePlates = self
end

E:RegisterModule(mod:GetName())
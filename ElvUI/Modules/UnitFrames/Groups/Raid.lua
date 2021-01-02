local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

function UF:Construct_RaidFrames()
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self.RaisedElementParent = CreateFrame("Frame", nil, self)
	self.RaisedElementParent.TextureParent = CreateFrame("Frame", nil, self.RaisedElementParent)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100)

	self.Health = UF:Construct_HealthBar(self, true, true, "RIGHT")

	self.Power = UF:Construct_PowerBar(self, true, true, "LEFT")
	self.Power.frequentUpdates = false

	self.Portrait3D = UF:Construct_Portrait(self, "model")
	self.Portrait2D = UF:Construct_Portrait(self, "texture")

	self.Name = UF:Construct_NameText(self)
	self.Buffs = UF:Construct_Buffs(self)
	self.Debuffs = UF:Construct_Debuffs(self)
	self.AuraWatch = UF:Construct_AuraWatch(self)
	self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
	self.DebuffHighlight = UF:Construct_DebuffHighlight(self)
	self.ResurrectIndicator = UF:Construct_ResurrectionIcon(self)
	self.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(self)
	self.MouseGlow = UF:Construct_MouseGlow(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)

	self.ThreatIndicator = UF:Construct_Threat(self)
	self.GroupRoleIndicator = UF:Construct_RoleIcon(self)
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
	self.ReadyCheckIndicator = UF:Construct_ReadyCheckIcon(self)
	self.HealCommBar = UF:Construct_HealComm(self)
	self.GPS = UF:Construct_GPS(self)
	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)

	self.customTexts = {}
	self.InfoPanel = UF:Construct_InfoPanel(self)

	self.unitframeType = "raid"
	UF:Update_StatusBars()
	UF:Update_FontStrings()

	self.db = UF.db.units.raid
	self.PostCreate = UF.Update_RaidFrames

	return self
end

function UF:RaidSmartVisibility(event)
	if not self.db or (self.db and not self.db.enable) or (UF.db and not UF.db.smartRaidFilter) or self.isForced then
		self.blockVisibilityChanges = false
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end

	if not InCombatLockdown() then
		self.isInstanceForced = nil
		local _, instanceType, _, _, maxPlayers = GetInstanceInfo()
		if instanceType == "raid" or instanceType == "pvp" then
			local mapID = GetCurrentMapAreaID()
			if UF.instanceMapIDs[mapID] then
				maxPlayers = UF.instanceMapIDs[mapID]
			end

			UnregisterStateDriver(self, "visibility")

			if maxPlayers < 40 then
				self:Show()
				self.isInstanceForced = true
				self.blockVisibilityChanges = false
				if ElvUF_Raid.numGroups ~= E:Round(maxPlayers/5) and event then
					UF:CreateAndUpdateHeaderGroup("raid")
				end
			else
				self.blockVisibilityChanges = true
				self:Hide()
			end
		elseif self.db.visibility then
			RegisterStateDriver(self, "visibility", self.db.visibility)
			self.blockVisibilityChanges = false
			if ElvUF_Raid.numGroups ~= self.db.numGroups then
				UF:CreateAndUpdateHeaderGroup("raid")
			end
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
end

function UF:Update_RaidHeader(header, db)
	header.db = db

	local headerHolder = header:GetParent()
	headerHolder.db = db

	if not headerHolder.positioned then
		headerHolder:ClearAllPoints()
		headerHolder:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 195)

		E:CreateMover(headerHolder, headerHolder:GetName().."Mover", L["Raid Frames"], nil, nil, nil, "ALL,RAID", nil, "unitframe,raid,generalGroup")

		headerHolder:RegisterEvent("PLAYER_LOGIN")
		headerHolder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		headerHolder:SetScript("OnEvent", UF.RaidSmartVisibility)
		headerHolder.positioned = true
	end

	UF.RaidSmartVisibility(headerHolder)
end

function UF:Update_RaidFrames(frame, db)
	if not db then
		db = frame.db
	else
		frame.db = db
	end

	frame.Portrait = frame.Portrait or (db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D)
	frame.colors = ElvUF.colors
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp")

	do
		if self.thinBorders then
			frame.SPACING = 0
			frame.BORDER = E.mult
		else
			frame.BORDER = E.Border
			frame.SPACING = E.Spacing
		end
		frame.SHADOW_SPACING = 3

		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?

		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == "inset" and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == "spaced" and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width

		frame.CLASSBAR_YOFFSET = 0
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

		frame.VARIABLES_SET = true
	end

	if not InCombatLockdown() then
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	else
		frame:SetAttribute("initial-width", frame.UNIT_WIDTH)
		frame:SetAttribute("initial-height", frame.UNIT_HEIGHT)
	end

	UF:Configure_InfoPanel(frame)
	--Health
	UF:Configure_HealthBar(frame)

	--Name
	UF:UpdateNameSettings(frame)

	--Power
	UF:Configure_Power(frame)

	--Portrait
	UF:Configure_Portrait(frame)

	--Threat
	UF:Configure_Threat(frame)

	--Auras
	UF:EnableDisable_Auras(frame)
	UF:Configure_Auras(frame, "Buffs")
	UF:Configure_Auras(frame, "Debuffs")

	--RaidDebuffs
	UF:Configure_RaidDebuffs(frame)

	--Raid Icon
	UF:Configure_RaidIcon(frame)

	--Resurrect Icon
	UF:Configure_ResurrectionIcon(frame)

	--Debuff Highlight
	UF:Configure_DebuffHighlight(frame)

	--OverHealing
	UF:Configure_HealComm(frame)

	--GPS Arrow
	UF:Configure_GPS(frame)

	--Role
	UF:Configure_RoleIcon(frame)

	--Raid Roles
	UF:Configure_RaidRoleIcons(frame)

	--Fader
	UF:Configure_Fader(frame)

	--Cutaway
	UF:Configure_Cutaway(frame)

	--Buff Indicators
	UF:UpdateAuraWatch(frame)

	--ReadyCheck
	UF:Configure_ReadyCheckIcon(frame)

	--CustomTexts
	UF:Configure_CustomTexts(frame)

	frame:UpdateAllElements("ForceUpdate")
end

UF.headerstoload.raid = true

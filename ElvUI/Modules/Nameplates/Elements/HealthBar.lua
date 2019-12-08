local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables

function NP:Update_HealthOnValueChanged()
	local frame = self:GetParent().UnitFrame
	if not frame.UnitType then return end -- Bugs

	NP:Update_Health(frame)
	NP:Update_HealthColor(frame)
	NP:Update_Glow(frame)
	NP:StyleFilterUpdate(frame, "UNIT_HEALTH")
end

function NP:Update_HealthColor(frame)
	if not frame.Health:IsShown() then return end

	local r, g, b
	local scale = 1

	local class = frame.UnitClass
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	local useClassColor = NP.db.units[frame.UnitType].health.useClassColor
	if classColor and ((frame.UnitType == "FRIENDLY_PLAYER" and useClassColor) or (frame.UnitType == "ENEMY_PLAYER" and useClassColor)) then
		r, g, b = classColor.r, classColor.g, classColor.b
	else
		local db = self.db.colors
		local status = frame.ThreatStatus
		if status then
			if status == 3 then
				if E.Role == "Tank" then
					r, g, b = db.threat.goodColor.r, db.threat.goodColor.g, db.threat.goodColor.b
					scale = NP.db.threat.goodScale
				else
					r, g, b = db.threat.badColor.r, db.threat.badColor.g, db.threat.badColor.b
					scale = NP.db.threat.badScale
				end
			elseif status == 2 then
				if E.Role == "Tank" then
					r, g, b = db.threat.badTransition.r, db.threat.badTransition.g, db.threat.badTransition.b
				else
					r, g, b = db.threat.goodTransition.r, db.threat.goodTransition.g, db.threat.goodTransition.b
				end
				scale = 1
			elseif status == 1 then
				if E.Role == "Tank" then
					r, g, b = db.threat.goodTransition.r, db.threat.goodTransition.g, db.threat.goodTransition.b
				else
					r, g, b = db.threat.badTransition.r, db.threat.badTransition.g, db.threat.badTransition.b
				end
				scale = 1
			else
				if E.Role == "Tank" then
					r, g, b = db.threat.badColor.r, db.threat.badColor.g, db.threat.badColor.b
					scale = self.db.threat.badScale
				else
					r, g, b = db.threat.goodColor.r, db.threat.goodColor.g, db.threat.goodColor.b
					scale = self.db.threat.goodScale
				end
			end
		end

		if (not status) or (status and not NP.db.threat.useThreatColor) then
			local reactionType = frame.UnitReaction
			if reactionType == 4 then
				r, g, b = db.reactions.neutral.r, db.reactions.neutral.g, db.reactions.neutral.b
			elseif reactionType and reactionType > 4 then
				if frame.UnitType == "FRIENDLY_PLAYER" then
					r, g, b = db.reactions.friendlyPlayer.r, db.reactions.friendlyPlayer.g, db.reactions.friendlyPlayer.b
				else
					r, g, b = db.reactions.good.r, db.reactions.good.g, db.reactions.good.b
				end
			else
				r, g, b = db.reactions.bad.r, db.reactions.bad.g, db.reactions.bad.b
			end
		end
	end

	if r ~= frame.Health.r or g ~= frame.Health.g or b ~= frame.Health.b then
		if not frame.HealthColorChanged then
			frame.Health:SetStatusBarColor(r, g, b)

			if frame.HealthColorChangeCallbacks then
				for _, cb in ipairs(frame.HealthColorChangeCallbacks) do
					cb(self, frame, r, g, b)
				end
			end
		end
		frame.Health.r, frame.Health.g, frame.Health.b = r, g, b
	end

	if frame.ThreatScale ~= scale then
		frame.ThreatScale = scale
		if frame.isTarget and self.db.useTargetScale then
			scale = scale * self.db.targetScale
		end
		self:SetFrameScale(frame, scale * (frame.ActionScale or 1))
	end
end

function NP:Update_Health(frame)
	local health = frame.oldHealthBar:GetValue()
	local _, maxHealth = frame.oldHealthBar:GetMinMaxValues()
	frame.Health:SetMinMaxValues(0, maxHealth)

	if frame.HealthValueChangeCallbacks then
		for _, cb in ipairs(frame.HealthValueChangeCallbacks) do
			cb(self, frame, health, maxHealth)
		end
	end

	frame.Health:SetValue(health)
	frame.FlashTexture:Point("TOPRIGHT", frame.Health:GetStatusBarTexture(), "TOPRIGHT") --idk why this fixes this

	if self.db.units[frame.UnitType].health.text.enable then
		frame.Health.Text:SetText(E:GetFormattedText(self.db.units[frame.UnitType].health.text.format, health, maxHealth))
	end
end

function NP:RegisterHealthBarCallbacks(frame, valueChangeCB, colorChangeCB)
	if valueChangeCB then
		frame.HealthValueChangeCallbacks = frame.HealthValueChangeCallbacks or {}
		tinsert(frame.HealthValueChangeCallbacks, valueChangeCB)
	end

	if colorChangeCB then
		frame.HealthColorChangeCallbacks = frame.HealthColorChangeCallbacks or {}
		tinsert(frame.HealthColorChangeCallbacks, colorChangeCB)
	end
end

function NP:Update_HealthBar(frame)
	if self.db.units[frame.UnitType].health.enable or (frame.isTarget and self.db.alwaysShowTargetHealth) then
		frame.Health:Show()
	else
		frame.Health:Hide()
	end
end

function NP:Configure_HealthBarScale(frame, scale, noPlayAnimation)
	if noPlayAnimation then
		frame.Health:SetWidth(self.db.units[frame.UnitType].health.width * scale)
		frame.Health:SetHeight(self.db.units[frame.UnitType].health.height * scale)
	else
		if frame.Health.scale:IsPlaying() then
			frame.Health.scale:Stop()
		end

		frame.Health.scale.width:SetChange(self.db.units[frame.UnitType].health.width * scale)
		frame.Health.scale.height:SetChange(self.db.units[frame.UnitType].health.height * scale)
		frame.Health.scale:Play()
	end
end

function NP:Configure_HealthBar(frame, configuring)
	local db = self.db.units[frame.UnitType].health
	local healthBar = frame.Health

	healthBar:SetPoint("TOP", frame, "TOP", 0, 0)

	if configuring then
		healthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar), "BORDER")

		self:Configure_HealthBarScale(frame, frame.currentScale or 1, configuring)

		E:SetSmoothing(healthBar, self.db.smoothbars)

		if db.text.enable then
			healthBar.Text:ClearAllPoints()
			healthBar.Text:Point(E.InversePoints[db.text.position], db.text.parent == "Nameplate" and frame or frame[db.text.parent], db.text.position, db.text.xOffset, db.text.yOffset)
			healthBar.Text:FontTemplate(LSM:Fetch("font", db.text.font), db.text.fontSize, db.text.fontOutline)
			healthBar.Text:Show()
		else
			healthBar.Text:Hide()
		end
	end
end

local function HealthBar_OnSizeChanged(self, width)
	local health = self:GetValue()
	local _, maxHealth = self:GetMinMaxValues()
	self:GetStatusBarTexture():SetPoint("TOPRIGHT", -(width * ((maxHealth - health) / maxHealth)), 0)
end

function NP:Construct_HealthBar(parent)
	local frame = CreateFrame("StatusBar", "$parentHealthBar", parent)
	frame:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar), "BORDER")
	self:StyleFrame(frame)

	frame:SetScript("OnSizeChanged", HealthBar_OnSizeChanged)

	parent.FlashTexture = frame:CreateTexture(nil, "OVERLAY")
	parent.FlashTexture:SetTexture(LSM:Fetch("background", "ElvUI Blank"))
	parent.FlashTexture:Point("BOTTOMLEFT", frame:GetStatusBarTexture(), "BOTTOMLEFT")
	parent.FlashTexture:Point("TOPRIGHT", frame:GetStatusBarTexture(), "TOPRIGHT")
	parent.FlashTexture:Hide()

	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetAllPoints(frame)
	frame.Text:SetWordWrap(false)

	frame.scale = CreateAnimationGroup(frame)
	frame.scale.width = frame.scale:CreateAnimation("Width")
	frame.scale.width:SetDuration(0.2)
	frame.scale.height = frame.scale:CreateAnimation("Height")
	frame.scale.height:SetDuration(0.2)

	frame:Hide()

	return frame
end
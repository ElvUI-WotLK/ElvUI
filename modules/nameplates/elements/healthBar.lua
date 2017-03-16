local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

function mod:UpdateElement_HealthOnValueChanged(health)
	local frame = self:GetParent().UnitFrame
	if not frame.UnitType then return end -- Bugs

	mod:UpdateElement_Health(frame)
	mod:UpdateElement_HealthColor(frame)
	mod:UpdateElement_Glow(frame)
end

function mod:UpdateElement_HealthColor(frame)
	if(not frame.HealthBar:IsShown()) then return end

	local r, g, b
	local scale = 1

	local class = frame.UnitClass
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	local useClassColor = mod.db.units[frame.UnitType].healthbar.useClassColor

	if classColor and ((frame.UnitType == "FRIENDLY_PLAYER" and useClassColor) or (frame.UnitType == "ENEMY_PLAYER" and useClassColor)) then
		r, g, b = classColor.r, classColor.g, classColor.b
	elseif frame.UnitReaction == 1 then
		r, g, b = mod.db.reactions.tapped.r, mod.db.reactions.tapped.g, mod.db.reactions.tapped.b
	else
		local status = mod:UnitDetailedThreatSituation(frame)
		if status then
			if status == 3 then
				if E.Role == "Tank" then
					r, g, b = mod.db.threat.goodColor.r, mod.db.threat.goodColor.g, mod.db.threat.goodColor.b
					scale = mod.db.threat.goodScale
				else
					r, g, b = mod.db.threat.badColor.r, mod.db.threat.badColor.g, mod.db.threat.badColor.b
					scale = mod.db.threat.badScale
				end
			elseif status == 2 then
				if E.Role == "Tank" then
					r, g, b = mod.db.threat.badTransition.r, mod.db.threat.badTransition.g, mod.db.threat.badTransition.b
				else
					r, g, b = mod.db.threat.goodTransition.r, mod.db.threat.goodTransition.g, mod.db.threat.goodTransition.b
				end
				scale = 1
			elseif status == 1 then
				if E.Role == "Tank" then
					r, g, b = mod.db.threat.goodTransition.r, mod.db.threat.goodTransition.g, mod.db.threat.goodTransition.b
				else
					r, g, b = mod.db.threat.badTransition.r, mod.db.threat.badTransition.g, mod.db.threat.badTransition.b
				end
				scale = 1
			else
				if E.Role == "Tank" then
					r, g, b = mod.db.threat.badColor.r, mod.db.threat.badColor.g, mod.db.threat.badColor.b
					scale = mod.db.threat.badScale
				else
					r, g, b = mod.db.threat.goodColor.r, mod.db.threat.goodColor.g, mod.db.threat.goodColor.b
					scale = mod.db.threat.goodScale
				end
			end
		end

		if (not status) or (status and not mod.db.threat.useThreatColor) then
			local reactionType = frame.UnitReaction
			if reactionType == 4 then
				r, g, b = mod.db.reactions.neutral.r, mod.db.reactions.neutral.g, mod.db.reactions.neutral.b
			elseif reactionType > 4 then
				if frame.UnitType == "FRIENDLY_PLAYER" then
					r, g, b = mod.db.reactions.friendlyPlayer.r, mod.db.reactions.friendlyPlayer.g, mod.db.reactions.friendlyPlayer.b
				else
					r, g, b = mod.db.reactions.good.r, mod.db.reactions.good.g, mod.db.reactions.good.b
				end
			else
				r, g, b = mod.db.reactions.bad.r, mod.db.reactions.bad.g, mod.db.reactions.bad.b
			end
		end
	end

	if r ~= frame.HealthBar.r or g ~= frame.HealthBar.g or b ~= frame.HealthBar.b then
		if not frame.CustomColor then
			frame.HealthBar:SetStatusBarColor(r, g, b)
			frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = r, g, b
		else
			local CustomColor = frame.CustomColor
			frame.HealthBar:SetStatusBarColor(CustomColor.r, CustomColor.g, CustomColor.b)
			frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = CustomColor.r, CustomColor.g, CustomColor.b
		end
	end

	if (not frame.isTarget or not mod.db.useTargetScale) and not frame.CustomScale then
		frame.ThreatScale = scale
		mod:SetFrameScale(frame, scale)
	end
end

function mod:UpdateElement_Health(frame)
	local health = frame.oldHealthBar:GetValue()
	local _, maxHealth = frame.oldHealthBar:GetMinMaxValues()
	frame.HealthBar:SetMinMaxValues(0, maxHealth)

	frame.HealthBar:SetValue(health)

	if self.db.units[frame.UnitType].healthbar.text.enable then
		frame.HealthBar.text:SetText(E:GetFormattedText(self.db.units[frame.UnitType].healthbar.text.format, health, maxHealth))
	else
		frame.HealthBar.text:SetText("")
	end
end

function mod:ConfigureElement_HealthBar(frame, configuring)
	local healthBar = frame.HealthBar

	healthBar:SetPoint("TOP", frame, "CENTER", 0, self.db.units[frame.UnitType].castbar.height + 3)
	if frame.isTarget and self.db.useTargetScale then
		healthBar:SetHeight(self.db.units[frame.UnitType].healthbar.height * ((frame.CustomScale and frame.CustomScale * self.db.targetScale) or self.db.targetScale))
		healthBar:SetWidth(self.db.units[frame.UnitType].healthbar.width * ((frame.CustomScale and frame.CustomScale * self.db.targetScale) or self.db.targetScale))
	else
		healthBar:SetHeight((frame.CustomScale and frame.CustomScale * self.db.units[frame.UnitType].healthbar.height) or self.db.units[frame.UnitType].healthbar.height)
		healthBar:SetWidth((frame.CustomScale and frame.CustomScale * self.db.units[frame.UnitType].healthbar.width) or self.db.units[frame.UnitType].healthbar.width)
	end

	healthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar), "BORDER")
	if(not configuring) and (self.db.units[frame.UnitType].healthbar.enable or frame.isTarget) then
		healthBar:Show()
	end

	healthBar.text:SetAllPoints(healthBar)
	healthBar.text:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", nil, parent)
	self:StyleFrame(frame)
	frame:SetFrameLevel(parent:GetFrameLevel())

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetWordWrap(false)
	frame.scale = CreateAnimationGroup(frame)

	frame.scale.width = frame.scale:CreateAnimation("Width")
	frame.scale.width:SetDuration(0.2)
	frame.scale.height = frame.scale:CreateAnimation("Height")
	frame.scale.height:SetDuration(0.2)
	frame:Hide()
	return frame
end
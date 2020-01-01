local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local FAILED = FAILED
local INTERRUPTED = INTERRUPTED

local function resetAttributes(self)
	self.casting = nil
	self.channeling = nil
	self.notInterruptible = nil
	self.spellName = nil
end

function NP:Update_CastBarOnUpdate(elapsed)
	if self.casting then
		self.value = self.value + elapsed
		if self.value >= self.maxValue then
			resetAttributes(self)
			self:SetValue(self.maxValue, "casting")
			self:Hide()
			NP:StyleFilterUpdate(self:GetParent(), "FAKE_Casting")
			return
		end
		self:SetValue(self.value)

		if self.castTimeFormat == "CURRENT" then
			self.Time:SetFormattedText("%.1f", self.value)
		elseif self.castTimeFormat == "CURRENT_MAX" then
			self.Time:SetFormattedText("%.1f / %.1f", self.value, self.maxValue)
		else --REMAINING
			self.Time:SetFormattedText("%.1f", (self.maxValue - self.value))
		end

		if self.Spark then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth()
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0)
		end
	elseif self.channeling then
		self.value = self.value - elapsed
		if self.value <= 0 then
			resetAttributes(self)
			self:Hide()
			NP:StyleFilterUpdate(self:GetParent(), "FAKE_Casting")
			return
		end
		self:SetValue(self.value)

		if self.channelTimeFormat == "CURRENT" then
			self.Time:SetFormattedText("%.1f", (self.maxValue - self.value))
		elseif self.channelTimeFormat == "CURRENT_MAX" then
			self.Time:SetFormattedText("%.1f / %.1f", (self.maxValue - self.value), self.maxValue)
		else --REMAINING
			self.Time:SetFormattedText("%.1f", self.value)
		end
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
	else
		resetAttributes(self)
		self:Hide()
		NP:StyleFilterUpdate(self:GetParent(), "FAKE_Casting")
	end
end

function NP:Update_CastBar(frame, event, unit)
	local castBar = frame.CastBar
	if unit then
		if not event then
			if UnitChannelInfo(unit) then
				event = "UNIT_SPELLCAST_CHANNEL_START"
			elseif UnitCastingInfo(unit) then
				event = "UNIT_SPELLCAST_START"
			end
		end
	elseif castBar:IsShown() then
		resetAttributes(castBar)
		castBar:Hide()
	end

	if self.db.units[frame.UnitType].castbar.enable ~= true then return end
	if self.db.units[frame.UnitType].health.enable ~= true and not (frame.isTarget and self.db.alwaysShowTargetHealth) then return end --Bug

	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
		local name, _, _, texture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
		event = "UNIT_SPELLCAST_START"
		if not name then
			name, _, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
			event = "UNIT_SPELLCAST_CHANNEL_START"
		end

		if not name then
			resetAttributes(castBar)
			castBar:Hide()
			return
		end

		endTime = endTime / 1000
		startTime = startTime / 1000

		castBar.maxValue = endTime - startTime
		castBar.casting = event == "UNIT_SPELLCAST_START"
		castBar.channeling = event == "UNIT_SPELLCAST_CHANNEL_START"
		castBar.notInterruptible = notInterruptible
		castBar.holdTime = 0
		castBar.spellName = name

		if castBar.casting then
			castBar.value = GetTime() - startTime
		else
			castBar.value = endTime - GetTime()
		end

		castBar:SetMinMaxValues(0, castBar.maxValue)
		castBar:SetValue(castBar.value)

		castBar.Icon.texture:SetTexture(texture)
		castBar.Spark:Show()
		castBar.Name:SetText(name)
		castBar.Time:SetText()

		castBar:Show()
	elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		if castBar:IsShown() then
			resetAttributes(castBar)
		end
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		if castBar:IsShown() then
			castBar.Spark:Hide()
			castBar.Name:SetText(event == "UNIT_SPELLCAST_FAILED" and FAILED or INTERRUPTED)

			castBar.holdTime = self.db.units[frame.UnitType].castbar.timeToHold --How long the castbar should stay visible after being interrupted, in seconds

			resetAttributes(castBar)
			castBar:SetValue(castBar.maxValue)
		end
	elseif event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		if frame:IsShown() then
			local name, startTime, endTime, _
			if event == "UNIT_SPELLCAST_DELAYED" then
				name, _, _, _, startTime, endTime = UnitCastingInfo(unit)
			else
				name, _, _, _, startTime, endTime = UnitChannelInfo(unit)
			end

			if not name then
				resetAttributes(castBar)
				castBar:Hide()
				return
			end

			endTime = endTime / 1000
			startTime = startTime / 1000

			if castBar.casting then
				castBar.value = GetTime() - startTime
			elseif castBar.channeling then
				castBar.value = endTime - GetTime()
			else
				resetAttributes(castBar)
			end

			castBar.Name:SetText(name)
			castBar.maxValue = endTime - startTime
			castBar:SetMinMaxValues(0, castBar.maxValue)
			castBar:SetValue(castBar.value)
		end
	elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
		castBar.notInterruptible = event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
	end

	if not castBar.notInterruptible then
		castBar:SetStatusBarColor(self.db.colors.castColor.r, self.db.colors.castColor.g, self.db.colors.castColor.b)
		castBar.Icon.texture:SetDesaturated(false)
	else
		castBar:SetStatusBarColor(self.db.colors.castNoInterruptColor.r, self.db.colors.castNoInterruptColor.g, self.db.colors.castNoInterruptColor.b)

		if self.db.colors.castbarDesaturate then
			castBar.Icon.texture:SetDesaturated(true)
		end
	end

	self:StyleFilterUpdate(frame, "FAKE_Casting")
end

function NP:Configure_CastBarScale(frame, scale, noPlayAnimation)
	if frame.currentScale == scale then return end
	local db = self.db.units[frame.UnitType].castbar
	if not db.enable then return end

	local castBar = frame.CastBar

	if noPlayAnimation then
		castBar:SetSize(db.width * scale, db.height * scale)
		castBar.Icon:SetSize(db.iconSize * scale, db.iconSize * scale)
	else
		if castBar.scale:IsPlaying() or castBar.Icon.scale:IsPlaying() then
			castBar.scale:Stop()
			castBar.Icon.scale:Stop()
		end

		castBar.scale.width:SetChange(db.width * scale)
		castBar.scale.height:SetChange(db.height * scale)
		castBar.scale:Play()

		castBar.Icon.scale.width:SetChange(db.iconSize * scale)
		castBar.Icon.scale.height:SetChange(db.iconSize * scale)
		castBar.Icon.scale:Play()
	end
end

function NP:Configure_CastBar(frame, configuring)
	local db = self.db.units[frame.UnitType].castbar
	local castBar = frame.CastBar

	castBar:SetPoint("TOP", frame.Health, "BOTTOM", db.xOffset, db.yOffset)

	if db.showIcon then
		castBar.Icon:ClearAllPoints()
		castBar.Icon:SetPoint(db.iconPosition == "RIGHT" and "BOTTOMLEFT" or "BOTTOMRIGHT", castBar, db.iconPosition == "RIGHT" and "BOTTOMRIGHT" or "BOTTOMLEFT", db.iconOffsetX, db.iconOffsetY)
		castBar.Icon:Show()
	else
		castBar.Icon:Hide()
	end

	castBar.Time:ClearAllPoints()
	castBar.Name:ClearAllPoints()

	if db.textPosition == "BELOW" then
		castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT")
		castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT")
	elseif db.textPosition == "ABOVE" then
		castBar.Time:SetPoint("BOTTOMRIGHT", castBar, "TOPRIGHT")
		castBar.Name:SetPoint("BOTTOMLEFT", castBar, "TOPLEFT")
	else
		castBar.Time:SetPoint("RIGHT", castBar, "RIGHT", -4, 0)
		castBar.Name:SetPoint("LEFT", castBar, "LEFT", 4, 0)
	end

	if configuring then
		self:Configure_CastBarScale(frame, frame.currentScale or 1, configuring)
	end

	if db.hideSpellName then
		castBar.Name:Hide()
	else
		castBar.Name:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
		castBar.Name:Show()
	end
	if db.hideTime then
		castBar.Time:Hide()
	else
		castBar.Time:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
		castBar.Time:Show()
	end

	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))

	castBar.castTimeFormat = db.castTimeFormat
	castBar.channelTimeFormat = db.channelTimeFormat
end

function NP:Construct_CastBar(parent)
	local frame = CreateFrame("StatusBar", "$parentCastBar", parent)
	NP:StyleFrame(frame)
	frame:SetScript("OnUpdate", NP.Update_CastBarOnUpdate)

	frame.Icon = CreateFrame("Frame", nil, frame)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
	frame.Icon.texture:SetAllPoints()
	frame.Icon.texture:SetTexCoord(unpack(E.TexCoords))
	NP:StyleFrame(frame.Icon)

	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Time:SetJustifyH("RIGHT")
	frame.Time:SetWordWrap(false)

	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetJustifyH("LEFT")
	frame.Name:SetWordWrap(false)

	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)

	frame.scale = CreateAnimationGroup(frame)
	frame.scale.width = frame.scale:CreateAnimation("Width")
	frame.scale.width:SetDuration(0.2)
	frame.scale.height = frame.scale:CreateAnimation("Height")
	frame.scale.height:SetDuration(0.2)

	frame.Icon.scale = CreateAnimationGroup(frame.Icon)
	frame.Icon.scale.width = frame.Icon.scale:CreateAnimation("Width")
	frame.Icon.scale.width:SetDuration(0.2)
	frame.Icon.scale.height = frame.Icon.scale:CreateAnimation("Height")
	frame.Icon.scale.height:SetDuration(0.2)

	frame:Hide()

	return frame
end
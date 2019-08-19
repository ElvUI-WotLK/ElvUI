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

function NP:UpdateElement_CastBarOnUpdate(elapsed)
	if self.casting then
		self.value = self.value + elapsed
		if self.value >= self.maxValue then
			resetAttributes(self)
			self:SetValue(self.maxValue, "casting")
			self:Hide()
			NP:UpdateElement_Filters(self:GetParent(), "FAKE_Casting")
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
			NP:UpdateElement_Filters(self:GetParent(), "FAKE_Casting")
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
		NP:UpdateElement_Filters(self:GetParent(), "FAKE_Casting")
	end
end

function NP:UpdateElement_Cast(frame, event, unit)
	if unit then
		if not event then
			if UnitChannelInfo(unit) then
				event = "UNIT_SPELLCAST_CHANNEL_START"
			elseif UnitCastingInfo(unit) then
				event = "UNIT_SPELLCAST_START"
			end
		end
	elseif frame.CastBar:IsShown() then
		resetAttributes(frame.CastBar)
		frame.CastBar:Hide()
	end

	if self.db.units[frame.UnitType].castbar.enable ~= true then return end
	if self.db.units[frame.UnitType].healthbar.enable ~= true and not (frame.isTarget and self.db.alwaysShowTargetHealth) then return end --Bug

	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
		local name, _, _, texture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
		event = "UNIT_SPELLCAST_START"
		if not name then
			name, _, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
			event = "UNIT_SPELLCAST_CHANNEL_START"
		end

		if not name then
			resetAttributes(frame.CastBar)
			frame.CastBar:Hide()
			return
		end

		endTime = endTime / 1000
		startTime = startTime / 1000

		frame.CastBar.maxValue = endTime - startTime
		frame.CastBar.casting = event == "UNIT_SPELLCAST_START"
		frame.CastBar.channeling = event == "UNIT_SPELLCAST_CHANNEL_START"
		frame.CastBar.notInterruptible = notInterruptible
		frame.CastBar.holdTime = 0
		frame.CastBar.spellName = name

		if frame.CastBar.casting then
			frame.CastBar.value = GetTime() - startTime
		else
			frame.CastBar.value = endTime - GetTime()
		end

		frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue)
		frame.CastBar:SetValue(frame.CastBar.value)

		frame.CastBar.Icon.texture:SetTexture(texture)
		frame.CastBar.Spark:Show()
		frame.CastBar.Name:SetText(name)
		frame.CastBar.Time:SetText()

		frame.CastBar:Show()
	elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		if frame.CastBar:IsShown() then
			resetAttributes(frame.CastBar)
		end
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		if frame.CastBar:IsShown() then
			frame.CastBar.Spark:Hide()
			frame.CastBar.Name:SetText(event == "UNIT_SPELLCAST_FAILED" and FAILED or INTERRUPTED)

			frame.CastBar.holdTime = self.db.units[frame.UnitType].castbar.timeToHold --How long the castbar should stay visible after being interrupted, in seconds

			resetAttributes(frame.CastBar)
			frame.CastBar:SetValue(frame.CastBar.maxValue)
		end
	elseif event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		if frame:IsShown() then
			local name, startTime, endTime, notInterruptible, _
			if event == "UNIT_SPELLCAST_DELAYED" then
				name, _, _, _, startTime, endTime, _, notInterruptible = UnitCastingInfo(unit)
			else
				name, _, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
			end

			if not name then
				resetAttributes(frame.CastBar)
				frame.CastBar:Hide()
				return
			end

			endTime = endTime / 1000
			startTime = startTime / 1000

			if frame.CastBar.casting then
				frame.CastBar.value = GetTime() - startTime
			elseif frame.CastBar.channeling then
				frame.CastBar.value = endTime - GetTime()
			else
				resetAttributes(frame.CastBar)
			end

			frame.CastBar.Name:SetText(name)
			frame.CastBar.maxValue = endTime - startTime
			frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue)
			frame.CastBar:SetValue(frame.CastBar.value)
		end
	elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
		frame.CastBar.notInterruptible = event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
	end

	if not frame.CastBar.notInterruptible then
		frame.CastBar:SetStatusBarColor(self.db.castColor.r, self.db.castColor.g, self.db.castColor.b)
	else
		frame.CastBar:SetStatusBarColor(self.db.castNoInterruptColor.r, self.db.castNoInterruptColor.g, self.db.castNoInterruptColor.b)
	end

	self:UpdateElement_Filters(frame, "FAKE_Casting")
end

function NP:ConfigureElement_CastBar(frame)
	if not frame.UnitType then return end

	local castBar = frame.CastBar

	castBar:ClearAllPoints()
	castBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -self.db.units[frame.UnitType].castbar.offset)
	castBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -self.db.units[frame.UnitType].castbar.offset)
	castBar:SetHeight(self.db.units[frame.UnitType].castbar.height)

	castBar.Icon:ClearAllPoints()
	if self.db.units[frame.UnitType].castbar.iconPosition == "RIGHT" then
		castBar.Icon:SetPoint("TOPLEFT", frame.HealthBar, "TOPRIGHT", self.db.units[frame.UnitType].castbar.offset, 0)
		castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", self.db.units[frame.UnitType].castbar.offset, 0)
	elseif self.db.units[frame.UnitType].castbar.iconPosition == "LEFT" then
		castBar.Icon:SetPoint("TOPRIGHT", frame.HealthBar, "TOPLEFT", -self.db.units[frame.UnitType].castbar.offset, 0)
		castBar.Icon:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMLEFT", -self.db.units[frame.UnitType].castbar.offset, 0)
	end
	castBar.Icon:SetWidth(self.db.units[frame.UnitType].castbar.height + self.db.units[frame.UnitType].healthbar.height + self.db.units[frame.UnitType].castbar.offset)
	castBar.Icon.texture:SetTexCoord(unpack(E.TexCoords))

	castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT", 0, -E.Border*3)
	castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", 0, -E.Border*3)
	castBar.Name:SetPoint("TOPRIGHT", castBar.Time, "TOPLEFT")
	castBar.Name:SetJustifyH("LEFT")
	castBar.Name:SetJustifyV("TOP")
	castBar.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	castBar.Time:SetJustifyH("RIGHT")
	castBar.Time:SetJustifyV("TOP")
	castBar.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)

	if self.db.units[frame.UnitType].castbar.hideSpellName then
		castBar.Name:Hide()
	else
		castBar.Name:Show()
	end
	if self.db.units[frame.UnitType].castbar.hideTime then
		castBar.Time:Hide()
	else
		castBar.Time:Show()
	end

	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))

	castBar.castTimeFormat = self.db.units[frame.UnitType].castbar.castTimeFormat
	castBar.channelTimeFormat = self.db.units[frame.UnitType].castbar.channelTimeFormat
end

function NP:ConstructElement_CastBar(parent)
	local function updateGlowPosition()
		if not parent then return end

		NP:UpdatePosition_Glow(parent)
	end

	local frame = CreateFrame("StatusBar", "$parentCastBar", parent)
	NP:StyleFrame(frame)
	frame:SetScript("OnUpdate", NP.UpdateElement_CastBarOnUpdate)
	frame:SetScript("OnShow", updateGlowPosition)
	frame:SetScript("OnHide", updateGlowPosition)

	frame.Icon = CreateFrame("Frame", nil, frame)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
	frame.Icon.texture:SetAllPoints()
	NP:StyleFrame(frame.Icon)

	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetFont(LSM:Fetch("font", NP.db.font), NP.db.fontSize, NP.db.fontOutline)
	frame.Name:SetWordWrap(false)

	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Time:SetFont(LSM:Fetch("font", NP.db.font), NP.db.fontSize, NP.db.fontOutline)
	frame.Time:SetWordWrap(false)

	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)

	frame:Hide()

	return frame
end
local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

local unpack = unpack

local CreateFrame = CreateFrame

local green = {r = 0, g = 1, b = 0}
function mod:UpdateElement_CastBarOnValueChanged(value)
	local frame = self:GetParent().UnitFrame
	local min, max = self:GetMinMaxValues()
	local isChannel = value < frame.CastBar:GetValue()
	frame.CastBar:SetMinMaxValues(min, max)
	frame.CastBar:SetValue(value)

	if isChannel then
		if frame.CastBar.channelTimeFormat == "CURRENT" then
			frame.CastBar.Time:SetFormattedText("%.1f", (max - value))
		elseif frame.CastBar.channelTimeFormat == "CURRENT_MAX" then
			frame.CastBar.Time:SetFormattedText("%.1f / %.1f", (max - value), max)
		else
			frame.CastBar.Time:SetFormattedText("%.1f", value)
		end
	else
		if frame.CastBar.castTimeFormat == "CURRENT" then
			frame.CastBar.Time:SetFormattedText("%.1f", value)
		elseif frame.CastBar.castTimeFormat == "CURRENT_MAX" then
			frame.CastBar.Time:SetFormattedText("%.1f / %.1f", value, max)
		else
			frame.CastBar.Time:SetFormattedText("%.1f", (max - value))
		end
	end

	if frame.CastBar.Spark then
		local sparkPosition = (value / max) * frame.CastBar:GetWidth()
		frame.CastBar.Spark:SetPoint("CENTER", frame.CastBar, "LEFT", sparkPosition, 0)
	end

	local color
	if self.Shield and self.Shield:IsShown() then
		color = mod.db.castNoInterruptColor
	else
		if value > 0 and (isChannel and (value/max) <= 0.02 or (value/max) >= 0.98) then
			color = green
		else
			color = mod.db.castColor
		end
	end

	local spell, _, spellName = UnitCastingInfo("target")
	if not spell then
		spell, _, spellName = UnitChannelInfo("target")
	end

	frame.CastBar.Name:SetText(spellName)
	frame.CastBar.Icon.texture:SetTexture(self.Icon:GetTexture())
	frame.CastBar:SetStatusBarColor(color.r, color.g, color.b)
end

local function updateGlowPosition(frame)
	if not frame.Glow2 then return end
	local scale = 1
	if mod.db.useTargetScale then
		if mod.db.targetScale >= 0.75 then
			scale = mod.db.targetScale
		else
			scale = 0.75
		end
	end
	local size = (E.Border*10)*scale
	if frame.CastBar:IsShown() then
		frame.Glow2:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT", -E:Scale(2+size*2), E:Scale(2+size))
		frame.Glow2:SetPoint("BOTTOMRIGHT", frame.CastBar, "BOTTOMRIGHT", E:Scale(4+size*2), -E:Scale(4+size))
	else
		frame.Glow2:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT", -E:Scale(size*2), E:Scale(size))
		frame.Glow2:SetPoint("BOTTOMRIGHT", frame.HealthBar, "BOTTOMRIGHT", E:Scale(size*2), -E:Scale(size))
	end
end

function mod:UpdateElement_CastBarOnShow()
	self:GetParent().UnitFrame.CastBar:Show()
	updateGlowPosition(self:GetParent().UnitFrame)
end

function mod:UpdateElement_CastBarOnHide()
	self:GetParent().UnitFrame.CastBar:Hide()
	updateGlowPosition(self:GetParent().UnitFrame)
end

function mod:ConfigureElement_CastBar(frame)
	local castBar = frame.CastBar

	castBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -self.db.units[frame.UnitType].castbar.offset)
	castBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -self.db.units[frame.UnitType].castbar.offset)
	castBar:SetHeight(self.db.units[frame.UnitType].castbar.height)

	castBar.Icon:SetPoint("TOPLEFT", frame.HealthBar, "TOPRIGHT", self.db.units[frame.UnitType].castbar.offset, 0);
	castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", self.db.units[frame.UnitType].castbar.offset, 0);
	castBar.Icon:SetWidth(self.db.units[frame.UnitType].castbar.height + self.db.units[frame.UnitType].healthbar.height + self.db.units[frame.UnitType].castbar.offset)

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

function mod:ConstructElement_CastBar(parent)
	local frame = CreateFrame("StatusBar", nil, parent)
	self:StyleFrame(frame)

	frame.Icon = CreateFrame("Frame", nil, frame)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
	frame.Icon.texture:SetAllPoints()
	frame.Icon.texture:SetTexCoord(unpack(E.TexCoords))
	self:StyleFrame(frame.Icon, true)

	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Time:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -E.Border*3)
	frame.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	frame.Time:SetWordWrap(false)
	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -E.Border*3)
	frame.Name:SetPoint("TOPRIGHT", frame.Time, "TOPLEFT")
	frame.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	frame.Name:SetWordWrap(false)
	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)
	frame:Hide()
	return frame
end
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames");

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local find, sub, gsub = string.find, string.sub, string.gsub

function UF:Configure_ClassBar(frame)
	if(not frame.VARIABLES_SET) then return end
	local bars = frame[frame.ClassBar]
	if(not bars) then return end
	local db = frame.db
	bars.origParent = frame

	if(bars.UpdateAllRuneTypes) then
		bars.UpdateAllRuneTypes(frame)
	end

	if((not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7) then
		frame.CLASSBAR_HEIGHT = 7
		if(db.classbar) then db.classbar.height = 7 end
		UF.ToggleResourceBar(bars)
	elseif((self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3) then
		frame.CLASSBAR_HEIGHT = 3
		if(db.classbar) then db.classbar.height = 3 end
		UF.ToggleResourceBar(bars)
	elseif (not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30) then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
		local overrideVisibility = frame.ClassBar == "AdditionalPower"
		UF.ToggleResourceBar(bars, overrideVisibility)
	end

	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	local color = self.db.colors.classResources.bgColor
	bars.backdrop.ignoreUpdates = true
	bars.backdrop:SetBackdropColor(color.r, color.g, color.b)

	color = E.db.unitframe.colors.borderColor
	bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	if(frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED) then
		bars:ClearAllPoints()
		bars:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)
		if frame.ClassBar == "AdditionalPower" then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		end
		bars:SetFrameLevel(50)

		if(bars.Holder and bars.Holder.mover) then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	elseif(not frame.CLASSBAR_DETACHED) then
		bars:ClearAllPoints()

		if(frame.ORIENTATION == "RIGHT") then
			bars:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -frame.BORDER, frame.SPACING*3)
		else
			bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING*3)
		end
		bars:SetFrameLevel(frame:GetFrameLevel() + 5)

		if(bars.Holder and bars.Holder.mover) then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	else
		CLASSBAR_WIDTH = db.classbar.detachedWidth - ((frame.BORDER + frame.SPACING)*2)
		if(bars.Holder) then bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height) end

		if(not bars.Holder or (bars.Holder and not bars.Holder.mover)) then
			bars.Holder = CreateFrame("Frame", nil, bars)
			bars.Holder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)
			bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)
			bars:Width(CLASSBAR_WIDTH)
			bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER+frame.SPACING)*2))
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(bars.Holder, "ClassBarMover", L["Classbar"], nil, nil, nil, "ALL,SOLO")
		else
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			bars.Holder.mover:SetScale(1)
			bars.Holder.mover:SetAlpha(1)
		end

		if not db.classbar.strataAndLevel.useCustomStrata then
			bars:SetFrameStrata("LOW")
		else
			bars:SetFrameStrata(db.classbar.strataAndLevel.frameStrata)
		end

		if not db.classbar.strataAndLevel.useCustomLevel then
			bars:SetFrameLevel(frame:GetFrameLevel() + 5)
		else
			bars:SetFrameLevel(db.classbar.strataAndLevel.frameLevel)
		end
	end

	bars:Width(CLASSBAR_WIDTH)
	bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

	if(E.myclass ~= "DRUID") then
		for i = 1, (UF.classMaxResourceBar[E.myclass] or 0) do
			bars[i]:Hide()

			if(i <= frame.MAX_CLASS_BAR) then
				bars[i].backdrop.ignoreUpdates = true
				bars[i].backdrop:SetBackdropColor(color.r, color.g, color.b)

				color = E.db.unitframe.colors.borderColor
				bars[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

				bars[i]:Height(bars:GetHeight())
				if(frame.MAX_CLASS_BAR == 1) then
					bars[i]:SetWidth(CLASSBAR_WIDTH)
				elseif(frame.USE_MINI_CLASSBAR) then
					if frame.CLASSBAR_DETACHED and db.classbar.orientation == "VERTICAL" then
						bars[i]:SetWidth(CLASSBAR_WIDTH)
						bars.Holder:SetHeight(((frame.CLASSBAR_HEIGHT + db.classbar.spacing)* frame.MAX_CLASS_BAR) - db.classbar.spacing) -- fix the holder height
					else
						bars[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
						bars.Holder:SetHeight(frame.CLASSBAR_HEIGHT) -- set the holder height to default
					end
				elseif(i ~= frame.MAX_CLASS_BAR) then
					bars[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR)
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if(i == 1) then
					bars[i]:Point("LEFT", bars)
				else
					if(frame.USE_MINI_CLASSBAR) then
						if frame.CLASSBAR_DETACHED and db.classbar.orientation == "VERTICAL" then
							bars[i]:Point("BOTTOM", bars[i-1], "TOP", 0, (db.classbar.spacing + frame.BORDER*2 + frame.SPACING*2))
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", (db.classbar.spacing + frame.BORDER*2 + frame.SPACING*2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
						end
					elseif i == frame.MAX_CLASS_BAR then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
						bars[i]:Point("RIGHT", bars)
					else
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
					end
				end

				if(not frame.USE_MINI_CLASSBAR) then
					bars[i].backdrop:Hide()
				else
					bars[i].backdrop:Show()
				end

				if(E.myclass ~= "DEATHKNIGHT") then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors[frame.ClassBar]))

					if(bars[i].bg) then
						bars[i].bg:SetTexture(unpack(ElvUF.colors[frame.ClassBar]))
					end
				end

				if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
					bars[i]:SetOrientation("VERTICAL")
				else
					bars[i]:SetOrientation("HORIZONTAL")
				end
				bars[i]:Show()
			end
		end

		if not frame.USE_MINI_CLASSBAR then
			bars.backdrop:Show()
		else
			bars.backdrop:Hide()
		end

	elseif frame.ClassBar == "AdditionalPower" then
		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			bars:SetOrientation("VERTICAL")
		else
			bars:SetOrientation("HORIZONTAL")
		end
	end

	if(frame.CLASSBAR_DETACHED and db.classbar.parent == "UIPARENT") then
		bars:SetParent(E.UIParent)
	else
		bars:SetParent(frame)
	end

	if(frame.db.classbar.enable and frame.CAN_HAVE_CLASSBAR and not frame:IsElementEnabled(frame.ClassBar)) then
		frame:EnableElement(frame.ClassBar)
		bars:Show()
	elseif(not frame.USE_CLASSBAR and frame:IsElementEnabled(frame.ClassBar)) then
		frame:DisableElement(frame.ClassBar)
		bars:Hide()
	end
end

local function ToggleResourceBar(bars, overrideVisibility)
	local frame = bars.origParent or bars:GetParent()
	local db = frame.db
	if not db then return end

	frame.CLASSBAR_SHOWN = (not not overrideVisibility) or bars:IsShown()

	local height
	if db.classbar then
		height = db.classbar.height
	elseif frame.AlternativePower then
		height = db.power.height
	end

	if bars.text then
		if frame.CLASSBAR_SHOWN then
			bars.text:SetAlpha(1)
		else
			bars.text:SetAlpha(0)
		end
	end

	frame.CLASSBAR_HEIGHT = (frame.USE_CLASSBAR and (frame.CLASSBAR_SHOWN and height) or 0)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((frame.SPACING+(frame.CLASSBAR_HEIGHT/2))) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)))

	if not frame.CLASSBAR_DETACHED then --Only update when necessary
		UF:Configure_HealthBar(frame)
		UF:Configure_Portrait(frame, true) --running :Hide on portrait makes the frame all funky
		UF:Configure_Threat(frame)
	end
end
UF.ToggleResourceBar = ToggleResourceBar

function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, self["classMaxResourceBar"][E.myclass] do
		runes[i] = CreateFrame("StatusBar", nil, runes)
		self["statusbars"][runes[i]] = true
		runes[i]:SetStatusBarTexture(E["media"].blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)

		runes[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		runes[i].backdrop:SetParent(runes)

		runes[i].bg = runes[i]:CreateTexture(nil, "BORDER")
		runes[i].bg:SetAllPoints()
		runes[i].bg:SetTexture(E["media"].blankTex)
		runes[i].bg.multiplier = 0.2
	end

	runes.PostUpdateVisibility = UF.PostVisibilityRunes
	runes.UpdateColor = E.noop --We handle colors on our own in Configure_ClassBar
	runes:SetScript("OnShow", ToggleResourceBar)
	runes:SetScript("OnHide", ToggleResourceBar)

	return runes
end

function UF:PostVisibilityRunes(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled and stateChanged then
		frame.MAX_CLASS_BAR = #self
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame("StatusBar", "AdditionalPowerBar", frame)
	additionalPower:SetFrameLevel(additionalPower:GetFrameLevel() + 1)
	additionalPower.colorPower = true
	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateVisibility = UF.PostVisibilityAdditionalPower
	additionalPower:CreateBackdrop("Default")
	UF["statusbars"][additionalPower] = true
	additionalPower:SetStatusBarTexture(E["media"].blankTex)

	additionalPower.bg = additionalPower:CreateTexture(nil, "BORDER")
	additionalPower.bg:SetAllPoints(additionalPower)
	additionalPower.bg:SetTexture(E["media"].blankTex)
	additionalPower.bg.multiplier = 0.3

	additionalPower.text = additionalPower:CreateFontString(nil, "OVERLAY")
	UF:Configure_FontString(additionalPower.text)

	additionalPower:SetScript("OnShow", ToggleResourceBar)
	additionalPower:SetScript("OnHide", ToggleResourceBar)

	return additionalPower
end

function UF:PostUpdateAdditionalPower(_, min, max, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if frame.USE_CLASSBAR and ((min ~= max or (not db.classbar.autoHide)) and (event ~= "ElementDisable")) then
		if db.classbar.additionalPowerText then
			local powerValue = frame.Power.value
			local powerValueText = powerValue:GetText()
			local powerValueParent = powerValue:GetParent()
			local powerTextPosition = db.power.position
			local color = ElvUF["colors"].power["MANA"]
			color = E:RGBToHex(color[1], color[2], color[3])

			--Attempt to remove |cFFXXXXXX color codes in order to determine if power text is really empty
			if powerValueText then
				local _, endIndex = find(powerValueText, "|cff")
				if endIndex then
					endIndex = endIndex + 7 --Add hex code
					powerValueText = sub(powerValueText, endIndex)
					powerValueText = gsub(powerValueText, "%s+", "")
				end
			end

			self.text:ClearAllPoints()
			if not frame.CLASSBAR_DETACHED then
				self.text:SetParent(powerValueParent)
				if (powerValueText and (powerValueText ~= "" and powerValueText ~= " ")) then
					if find(powerTextPosition, "RIGHT") then
						self.text:Point("RIGHT", powerValue, "LEFT", 3, 0)
						self.text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
					elseif find(powerTextPosition, "LEFT") then
						self.text:Point("LEFT", powerValue, "RIGHT", -3, 0)
						self.text:SetFormattedText("|cffD7BEA5 -|r"..color.." %d%%|r", floor(min / max * 100))
					else
						if select(4, powerValue:GetPoint()) <= 0 then
							self.text:Point("LEFT", powerValue, "RIGHT", -3, 0)
							self.text:SetFormattedText(" |cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
						else
							self.text:Point("RIGHT", powerValue, "LEFT", 3, 0)
							self.text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
						end
					end
				else
					self.text:Point(powerValue:GetPoint())
					self.text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
				end
			else
				self.text:SetParent(self)
				self.text:Point("CENTER", self)
				self.text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
			end
		else --Text disabled
			self.text:SetText()
		end
		self:Show()
	else --Bar disabled
		self.text:SetText()
		self:Hide()
	end
end

function UF:PostVisibilityAdditionalPower(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end
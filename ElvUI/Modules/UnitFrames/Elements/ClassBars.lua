local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

--Lua functions
local select = select
local strfind, strsub, gsub = strfind, strsub, gsub
local floor, max = floor, max
--WoW API / Variables
local CreateFrame = CreateFrame

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Configure_ClassBar(frame)
	if not frame.VARIABLES_SET then return end
	local bars = frame[frame.ClassBar]
	if not bars then return end

	local db = frame.db
	bars.Holder = frame.ClassBarHolder
	bars.origParent = frame

	--Fix height in case it is lower than the theme allows, or in case it's higher than 30px when not detached
	if (not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.classbar then db.classbar.height = 7 end
		UF.ToggleResourceBar(bars) --Trigger update to health if needed
	elseif (self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.classbar then db.classbar.height = 3 end
		UF.ToggleResourceBar(bars) --Trigger update to health if needed
	elseif (not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30) then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
		--Override visibility if Classbar is Additional Power in order to fix a bug when Auto Hide is enabled, height is higher than 30 and it goes from detached to not detached
		local overrideVisibility = frame.ClassBar == "AdditionalPower"
		UF.ToggleResourceBar(bars, overrideVisibility) --Trigger update to health if needed
	end

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		if frame.MAX_CLASS_BAR == 1 or frame.ClassBar == "AdditionalPower" then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		end
	elseif frame.CLASSBAR_DETACHED then
		CLASSBAR_WIDTH = db.classbar.detachedWidth - ((frame.BORDER + frame.SPACING) * 2)
	end

	bars:Width(CLASSBAR_WIDTH)
	bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING) * 2))

	local color = E.db.unitframe.colors.borderColor
	bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	if frame.ClassBar == "Runes" then
		if (not frame.USE_MINI_CLASSBAR) and frame.USE_CLASSBAR then
			bars.backdrop:Show()
		else
			bars.backdrop:Hide()
		end
		local maxClassBarButtons = max(UF.classMaxResourceBar[E.myclass] or 0)
		for i = 1, maxClassBarButtons do
			bars[i]:Hide()

			if i <= frame.MAX_CLASS_BAR then
				bars[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
				bars[i]:Height(bars:GetHeight())

				if frame.MAX_CLASS_BAR == 1 then
					bars[i]:Width(CLASSBAR_WIDTH)
				elseif frame.USE_MINI_CLASSBAR then
					if frame.CLASSBAR_DETACHED and db.classbar.orientation == "VERTICAL" then
						bars[i]:Width(CLASSBAR_WIDTH)
					else
						bars[i]:Width((CLASSBAR_WIDTH - ((5 + (frame.BORDER * 2 + frame.SPACING * 2)) * (frame.MAX_CLASS_BAR - 1))) / frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
					end
				elseif i ~= frame.MAX_CLASS_BAR then
					bars[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR - 1) * (frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if i == 1 then
					bars[i]:Point("LEFT", bars)
				else
					if frame.USE_MINI_CLASSBAR then
						if frame.CLASSBAR_DETACHED and db.classbar.orientation == "VERTICAL" then
							bars[i]:Point("BOTTOM", bars[i - 1], "TOP", 0, (db.classbar.spacing + frame.BORDER * 2 + frame.SPACING * 2))
						elseif frame.CLASSBAR_DETACHED and db.classbar.orientation == "HORIZONTAL" then
							bars[i]:Point("LEFT", bars[i - 1], "RIGHT", (db.classbar.spacing + frame.BORDER * 2 + frame.SPACING * 2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
						else
							bars[i]:Point("LEFT", bars[i - 1], "RIGHT", (5 + frame.BORDER * 2 + frame.SPACING * 2), 0) --5px spacing between borders of each button
						end
					elseif i == frame.MAX_CLASS_BAR then
						bars[i]:Point("LEFT", bars[i - 1], "RIGHT", frame.BORDER-frame.SPACING, 0)
						bars[i]:Point("RIGHT", bars)
					else
						bars[i]:Point("LEFT", bars[i - 1], "RIGHT", frame.BORDER-frame.SPACING, 0)
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
	elseif frame.ClassBar == "AdditionalPower" then
		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			bars:SetOrientation("VERTICAL")
		else
			bars:SetOrientation("HORIZONTAL")
		end
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)

		bars:SetParent(frame)
		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	elseif frame.CLASSBAR_DETACHED then
		if frame.USE_MINI_CLASSBAR and not (frame.MAX_CLASS_BAR == 1 or frame.ClassBar == "AdditionalPower") then
			local widthMult = UF.classMaxResourceBar[E.myclass] - 1
			if db.classbar.orientation == "HORIZONTAL" then
				bars.Holder:Size(db.classbar.detachedWidth + (db.classbar.spacing * widthMult) - (widthMult * 5), db.classbar.height)
			else
				bars.Holder:Size(db.classbar.detachedWidth, (db.classbar.height * UF.classMaxResourceBar[E.myclass]) + (db.classbar.spacing * widthMult))
			end
		else
			bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)
		end

		if not bars.Holder.mover then
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(bars.Holder, "ClassBarMover", L["Classbar"], nil, nil, nil, "ALL,SOLO", nil, "unitframe,player,classbar")
		else
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			bars.Holder.mover:SetScale(1)
			bars.Holder.mover:SetAlpha(1)
		end

		if db.classbar.parent == "UIPARENT" then
			bars:SetParent(E.UIParent)
		else
			bars:SetParent(frame)
		end

		if not db.classbar.strataAndLevel.useCustomStrata then
			bars:SetFrameStrata("LOW")
		else
			bars:SetFrameStrata(db.classbar.strataAndLevel.frameStrata)
		end

		if not db.classbar.strataAndLevel.useCustomLevel then
			bars:SetFrameLevel(frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached
		else
			bars:SetFrameLevel(db.classbar.strataAndLevel.frameLevel)
		end
	else
		bars:ClearAllPoints()

		if frame.ORIENTATION == "RIGHT" then
			bars:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -frame.BORDER, frame.SPACING*3)
		else
			bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING*3)
		end

		bars:SetParent(frame)
		bars:SetFrameStrata("LOW")
		bars:SetFrameLevel(frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	end

	if frame.USE_CLASSBAR then
		if frame.AdditionalPower and not frame:IsElementEnabled("AdditionalPower") then
			frame:EnableElement("AdditionalPower")
		end
		if frame.Runes and not frame:IsElementEnabled("Runes") then
			frame:EnableElement("Runes")
		end
	else
		if frame.AdditionalPower and frame:IsElementEnabled("AdditionalPower") then
			frame:DisableElement("AdditionalPower")
		end
		if frame.Runes and frame:IsElementEnabled("Runes") then
			frame:DisableElement("Runes")
		end
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
	elseif db.combobar then
		height = db.combobar.height
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
UF.ToggleResourceBar = ToggleResourceBar --Make available to combobar

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------
function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes:CreateBackdrop(nil, nil, nil, self.thinBorders, true)

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		runes[i] = CreateFrame("StatusBar", frame:GetName().."RuneButton"..i, runes)
		runes[i]:SetStatusBarTexture(E.media.blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[runes[i]] = true

		runes[i]:CreateBackdrop(nil, nil, nil, self.thinBorders, true)
		runes[i].backdrop:SetParent(runes)
		runes[i].backdrop:SetFrameLevel(runes[i]:GetFrameLevel() - 1)

		runes[i].bg = runes[i]:CreateTexture(nil, "BORDER")
		runes[i].bg:SetAllPoints()
		runes[i].bg:SetTexture(E.media.blankTex)
		runes[i].bg:SetParent(runes[i].backdrop)
		runes[i].bg.multiplier = 0.35
	end

	runes.PostUpdateType = UF.PostUpdateRuneType
	runes.PostUpdateVisibility = UF.PostVisibilityRunes

	runes:SetScript("OnShow", ToggleResourceBar)
	runes:SetScript("OnHide", ToggleResourceBar)

	return runes
end

function UF:PostUpdateRuneType(rune)
	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop

	if custom_backdrop then
		rune.bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
	end
end

function UF:PostVisibilityRunes(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.MAX_CLASS_BAR = #self
	end

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

-------------------------------------------------------------
-- DRUID
-------------------------------------------------------------
function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame("StatusBar", "AdditionalPowerBar", frame)
	additionalPower:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[additionalPower] = true

	additionalPower.colorPower = true

	additionalPower:CreateBackdrop(nil, nil, nil, self.thinBorders, true)

	additionalPower.BG = additionalPower:CreateTexture(nil, "BORDER")
	additionalPower.BG:SetAllPoints(additionalPower)
	additionalPower.BG:SetTexture(E.media.blankTex)

	additionalPower.text = additionalPower:CreateFontString(nil, "OVERLAY")
	UF:Configure_FontString(additionalPower.text)

	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateVisibility = UF.PostVisibilityAdditionalPower

	additionalPower:SetScript("OnShow", ToggleResourceBar)
	additionalPower:SetScript("OnHide", ToggleResourceBar)

	return additionalPower
end

function UF:PostUpdateAdditionalPower(_, MIN, MAX, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if frame.USE_CLASSBAR and ((MIN ~= MAX or (not db.classbar.autoHide)) and (event ~= "ElementDisable")) then
		if db.classbar.additionalPowerText then
			local powerValue = frame.Power.value
			local powerValueText = powerValue:GetText()
			local powerValueParent = powerValue:GetParent()
			local powerTextPosition = db.power.position
			local color = ElvUF.colors.power.MANA
			color = E:RGBToHex(color[1], color[2], color[3])

			--Attempt to remove |cFFXXXXXX color codes in order to determine if power text is really empty
			if powerValueText then
				local _, endIndex = strfind(powerValueText, "|cff")
				if endIndex then
					endIndex = endIndex + 7 --Add hex code
					powerValueText = strsub(powerValueText, endIndex)
					powerValueText = gsub(powerValueText, "%s+", "")
				end
			end

			self.text:ClearAllPoints()
			if not frame.CLASSBAR_DETACHED then
				self.text:SetParent(powerValueParent)
				if powerValueText and (powerValueText ~= "" and powerValueText ~= " ") then
					if strfind(powerTextPosition, "RIGHT") then
						self.text:Point("RIGHT", powerValue, "LEFT", 3, 0)
						self.text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(MIN / MAX * 100))
					elseif strfind(powerTextPosition, "LEFT") then
						self.text:Point("LEFT", powerValue, "RIGHT", -3, 0)
						self.text:SetFormattedText("|cffD7BEA5 -|r"..color.." %d%%|r", floor(MIN / MAX * 100))
					else
						if select(4, powerValue:GetPoint()) <= 0 then
							self.text:Point("LEFT", powerValue, "RIGHT", -3, 0)
							self.text:SetFormattedText(" |cffD7BEA5-|r"..color.." %d%%|r", floor(MIN / MAX * 100))
						else
							self.text:Point("RIGHT", powerValue, "LEFT", 3, 0)
							self.text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(MIN / MAX * 100))
						end
					end
				else
					self.text:Point(powerValue:GetPoint())
					self.text:SetFormattedText(color.."%d%%|r", floor(MIN / MAX * 100))
				end
			else
				self.text:SetParent(frame.RaisedElementParent) -- needs to be 'frame.RaisedElementParent' otherwise the new PowerPrediction Bar will overlap
				self.text:Point("CENTER", self, 0, 1)
				self.text:SetFormattedText(color.."%d%%|r", floor(MIN / MAX * 100))
			end
		else --Text disabled
			self.text:SetText("")
		end

		local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
		if custom_backdrop then
			self.BG:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self:GetStatusBarColor()
			self.BG:SetVertexColor(r * 0.35, g * 0.35, b * 0.35)
		end

		self:Show()
	else --Bar disabled
		self.text:SetText("")
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
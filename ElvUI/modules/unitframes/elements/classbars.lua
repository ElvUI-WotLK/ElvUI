local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames");

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

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
		UF.ToggleResourceBar(bars)
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
		if(E.myclass == "DRUID") then
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
					bars[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR)
				elseif(i ~= frame.MAX_CLASS_BAR) then
					bars[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR)
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if(i == 1) then
					bars[i]:Point("LEFT", bars)
				else
					if(frame.USE_MINI_CLASSBAR) then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0)
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
	end

	if(E.myclass ~= "DRUID") then
		if(not frame.USE_MINI_CLASSBAR) then
			bars.backdrop:Show()
		else
			bars.backdrop:Hide()
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

local function ToggleResourceBar(bars)
	local frame = bars.origParent or bars:GetParent()
	local db = frame.db
	if(not db) then return end
	frame.CLASSBAR_SHOWN = bars:IsShown()

	local height
	if(db.classbar) then
		height = db.classbar.height
	elseif(db.combobar) then
		height = db.combobar.height
	elseif(frame.AltPowerBar) then
		height = db.power.height
	end

	if(bars.text) then
		if(frame.CLASSBAR_SHOWN) then
			bars.text:SetAlpha(1)
		else
			bars.text:SetAlpha(0)
		end
	end

	frame.CLASSBAR_HEIGHT = (frame.USE_CLASSBAR and (frame.CLASSBAR_SHOWN and height) or 0)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((frame.SPACING+(frame.CLASSBAR_HEIGHT/2))) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)))

	if(not frame.CLASSBAR_DETACHED) then
		UF:Configure_HealthBar(frame)
		UF:Configure_Portrait(frame, true)
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

	return runes
end

function UF:Construct_DruidAltManaBar(frame)
	local dpower = CreateFrame("Frame", nil, frame)
	dpower:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	dpower.colorPower = true
	dpower.PostUpdateVisibility = ToggleResourceBar

	dpower.ManaBar = CreateFrame("StatusBar", nil, dpower)
	UF["statusbars"][dpower.ManaBar] = true
	dpower.ManaBar:SetStatusBarTexture(E["media"].blankTex)
	dpower.ManaBar:SetAllPoints(dpower)

	dpower.bg = dpower:CreateTexture(nil, "BORDER")
	dpower.bg:SetAllPoints(dpower.ManaBar)
	dpower.bg:SetTexture(E["media"].blankTex)
	dpower.bg.multiplier = 0.3

	dpower.Text = dpower:CreateFontString(nil, "OVERLAY")
	UF:Configure_FontString(dpower.Text)

	return dpower
end

function UF:DruidResourceBarVisibilityUpdate()
	local parent = self:GetParent()

	UF:UpdatePlayerFrameAnchors(parent, self:IsShown())
end
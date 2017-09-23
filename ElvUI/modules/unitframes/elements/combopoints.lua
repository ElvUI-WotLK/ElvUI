local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames");

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame
local GetComboPoints = GetComboPoints
local GetShapeshiftForm = GetShapeshiftForm
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function UF:Construct_Combobar(frame)
	local ComboPoints = CreateFrame("Frame", nil, frame)
	ComboPoints:CreateBackdrop("Default", nil, nil, UF.thinBorders, true)
	ComboPoints.Override = UF.UpdateComboDisplay
	ComboPoints.origParent = frame

	for i = 1, MAX_COMBO_POINTS do
		ComboPoints[i] = CreateFrame("StatusBar", frame:GetName() .. "ComboBarButton" .. i, ComboPoints)
		UF["statusbars"][ComboPoints[i]] = true
		ComboPoints[i]:SetStatusBarTexture(E["media"].blankTex)
		ComboPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		ComboPoints[i]:SetAlpha(0.15)
		ComboPoints[i]:CreateBackdrop("Default", nil, nil, UF.thinBorders, true)
		ComboPoints[i].backdrop:SetParent(ComboPoints)
	end

	if E.myclass == "DRUID" then
		frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UF.UpdateComboDisplay)
	end

	ComboPoints:SetScript("OnShow", UF.ToggleResourceBar)
	ComboPoints:SetScript("OnHide", UF.ToggleResourceBar)

	return ComboPoints
end

function UF:Configure_ComboPoints(frame)
	if not frame.VARIABLES_SET then return end

	local ComboPoints = frame.ComboPoints
	ComboPoints:ClearAllPoints()
	local db = frame.db
	if not frame.CLASSBAR_DETACHED then
		ComboPoints:SetParent(frame)
	else
		ComboPoints:SetParent(E.UIParent)
	end

	if (not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7 then
		frame.CLASSBAR_HEIGHT = 7
		if(db.combobar) then db.combobar.height = 7 end
		UF.ToggleResourceBar(ComboPoints)
	elseif (self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3 then
		frame.CLASSBAR_HEIGHT = 3
		if db.combobar then db.combobar.height = 3 end
		UF.ToggleResourceBar(ComboPoints)
	end

	if not frame.USE_CLASSBAR then
		ComboPoints:Hide()
	end

	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH
	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		ComboPoints:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		ComboPoints:SetFrameStrata("MEDIUM")
		if ComboPoints.Holder and ComboPoints.Holder.mover then
			E:DisableMover(ComboPoints.Holder.mover:GetName())
		end
	elseif not frame.CLASSBAR_DETACHED then
		ComboPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, (frame.SPACING*3))
		ComboPoints:SetFrameStrata("LOW")
		if ComboPoints.Holder and ComboPoints.Holder.mover then
			E:DisableMover(ComboPoints.Holder.mover:GetName())
		end
	else
		CLASSBAR_WIDTH = db.combobar.detachedWidth - ((frame.BORDER+frame.SPACING)*2)

		if not ComboPoints.Holder or (ComboPoints.Holder and not ComboPoints.Holder.mover) then
			ComboPoints.Holder = CreateFrame("Frame", nil, ComboPoints)
			ComboPoints.Holder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)
			ComboPoints.Holder:Size(db.combobar.detachedWidth, db.combobar.height)
			ComboPoints:Width(CLASSBAR_WIDTH)
			ComboPoints:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
			ComboPoints:ClearAllPoints()
			ComboPoints:Point("BOTTOMLEFT", ComboPoints.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(ComboPoints.Holder, "ComboBarMover", L["Combobar"], nil, nil, nil, "ALL,SOLO")
		else
			ComboPoints.Holder:Size(db.combobar.detachedWidth, db.combobar.height)
			ComboPoints:ClearAllPoints()
			ComboPoints:Point("BOTTOMLEFT", ComboPoints.Holder.mover, "BOTTOMLEFT", frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING)
			E:EnableMover(ComboPoints.Holder.mover:GetName())
		end

		ComboPoints:SetFrameStrata("LOW")
	end

	ComboPoints:Width(CLASSBAR_WIDTH)
	ComboPoints:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

	local color = E.db.unitframe.colors.borderColor
	ComboPoints.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	for i = 1, frame.MAX_CLASS_BAR do
		local r1, g1, b1 = unpack(ElvUF.colors.ComboPoints[1])
		local r2, g2, b2 = unpack(ElvUF.colors.ComboPoints[2])
		local r3, g3, b3 = unpack(ElvUF.colors.ComboPoints[3])

		local r, g, b = ElvUF.ColorGradient(i, 5, r1, g1, b1, r2, g2, b2, r3, g3, b3)
		ComboPoints[i]:SetStatusBarColor(r, g, b)
		ComboPoints[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		ComboPoints[i]:Height(ComboPoints:GetHeight())

		if frame.USE_MINI_CLASSBAR then
			ComboPoints[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR)
		elseif i ~= MAX_COMBO_POINTS then
			ComboPoints[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR)
		end

		ComboPoints[i]:ClearAllPoints()
		if i == 1 then
			ComboPoints[i]:Point("LEFT", ComboPoints)
		else
			if frame.USE_MINI_CLASSBAR then
				ComboPoints[i]:Point("LEFT", ComboPoints[i-1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0)
			elseif i == frame.MAX_CLASS_BAR then
				ComboPoints[i]:Point("LEFT", ComboPoints[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
				ComboPoints[i]:Point("RIGHT", ComboPoints)
			else
				ComboPoints[i]:Point("LEFT", ComboPoints[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
			end
		end

		if not frame.USE_MINI_CLASSBAR then
			ComboPoints[i].backdrop:Hide()
		else
			ComboPoints[i].backdrop:Show()
		end
	end

	if not frame.USE_MINI_CLASSBAR then
		ComboPoints.backdrop:Show()
	else
		ComboPoints.backdrop:Hide()
	end

	if frame.USE_CLASSBAR and not frame:IsElementEnabled("ComboPoints") then
		frame:EnableElement("ComboPoints")
	elseif not frame.USE_CLASSBAR and frame:IsElementEnabled("ComboPoints") then
		frame:DisableElement("ComboPoints")
		ComboPoints:Hide()
	end

	if not frame:IsShown() then
		ComboPoints:ForceUpdate()
	end
end

function UF:UpdateComboDisplay(event, unit)
	if unit == "pet" then return end
	if event == "UPDATE_SHAPESHIFT_FORM" and GetShapeshiftForm() ~= 3 then return self.ComboPoints:Hide() end
	if E.myclass ~= "ROGUE" and (E.myclass ~= "DRUID" or (E.myclass == "DRUID" and GetShapeshiftForm() ~= 3)) and not (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then return self.ComboPoints:Hide() end

	local db = self.db
	if not db then return end
	local cpoints = self.ComboPoints
	local cp
	if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
		cp = GetComboPoints("vehicle", "target")
	else
		cp = GetComboPoints("player", "target")
	end

	if cp == 0 and db.combobar.autoHide then
		cpoints:Hide()
		UF.ToggleResourceBar(cpoints)
	else
		cpoints:Show()
		for i = 1, MAX_COMBO_POINTS do
			if(i <= cp) then
				cpoints[i]:SetAlpha(1)
			else
				cpoints[i]:SetAlpha(.2)
			end
		end
		UF.ToggleResourceBar(cpoints)
	end
end
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local GetComboPoints = GetComboPoints
local GetShapeshiftForm = GetShapeshiftForm
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local CombobarDetached
function UF:CombobarDetachedUpdate()
	if E.myclass ~= "DRUID" then return end

	if ElvUF_Target.CLASSBAR_DETACHED and UF.db.units.target.combobar.parent == "UIPARENT" then
		if not CombobarDetached then
			CombobarDetached = CreateFrame("Frame", nil, UIParent)

			CombobarDetached:RegisterEvent("PLAYER_ENTERING_WORLD")
			CombobarDetached:RegisterEvent("UNIT_ENTERED_VEHICLE")
			CombobarDetached:RegisterEvent("UNIT_EXITING_VEHICLE")
			CombobarDetached:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

			CombobarDetached:SetScript("OnEvent", function(self, event, unit)
				if (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITING_VEHICLE") and unit ~= "player" then return end

				if event == "PLAYER_ENTERING_WORLD" then
					E:ShapeshiftDelayedUpdate(ElvUF_Target.ComboPoints.Override, ElvUF_Target)
				end

				ElvUF_Target.ComboPoints.Override(ElvUF_Target, event, unit)
			end)
		end

		CombobarDetached:Show()
	elseif CombobarDetached then
		CombobarDetached:Hide()
	end
end

function UF:Construct_Combobar(frame)
	local ComboPoints = CreateFrame("Frame", nil, frame)
	ComboPoints:CreateBackdrop("Default", nil, nil, UF.thinBorders, true)
	ComboPoints.Override = UF.UpdateComboDisplay

	for i = 1, MAX_COMBO_POINTS do
		ComboPoints[i] = CreateFrame("StatusBar", frame:GetName().."ComboBarButton"..i, ComboPoints)
		UF.statusbars[ComboPoints[i]] = true
		ComboPoints[i]:SetStatusBarTexture(E.media.blankTex)
		ComboPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		ComboPoints[i]:SetAlpha(0.15)
		ComboPoints[i]:CreateBackdrop("Default", nil, nil, UF.thinBorders, true)
		ComboPoints[i].backdrop:SetParent(ComboPoints)

		ComboPoints[i].bg = ComboPoints[i]:CreateTexture(nil, "BORDER")
		ComboPoints[i].bg:SetAllPoints()
		ComboPoints[i].bg:SetTexture(E.media.blankTex)
		ComboPoints[i].bg.multiplier = 0.3
	end

	frame:RegisterEvent("UNIT_ENTERED_VEHICLE", UF.UpdateComboDisplay)
	frame:RegisterEvent("UNIT_EXITING_VEHICLE", UF.UpdateComboDisplay)

	if E.myclass == "DRUID" then
		frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UF.UpdateComboDisplay)

		frame:RegisterEvent("PLAYER_ENTERING_WORLD", function()
			E:ShapeshiftDelayedUpdate(ElvUF_Target.ComboPoints.Override, ElvUF_Target)
		end)

		self:CombobarDetachedUpdate()
	end

	ComboPoints:SetScript("OnShow", UF.ToggleResourceBar)
	ComboPoints:SetScript("OnHide", UF.ToggleResourceBar)

	return ComboPoints
end

function UF:Configure_ComboPoints(frame)
	if not frame.VARIABLES_SET then return end
	local ComboPoints = frame.ComboPoints
	if not ComboPoints then return end

	local db = frame.db
	ComboPoints.Holder = frame.ComboPointsHolder
	ComboPoints.origParent = frame

	if (not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.combobar then db.combobar.height = 7 end
		UF.ToggleResourceBar(ComboPoints) --Trigger update to health if needed
	elseif (self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.combobar then db.combobar.height = 3 end
		UF.ToggleResourceBar(ComboPoints) --Trigger update to health if needed
	elseif (not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30) then
		frame.CLASSBAR_HEIGHT = 10
		if db.combobar then db.combobar.height = 10 end
		UF.ToggleResourceBar(ComboPoints) --Trigger update to health if needed
	end

	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	local color = E.db.unitframe.colors.borderColor
	ComboPoints.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		ComboPoints:ClearAllPoints()
		ComboPoints:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR

		ComboPoints:SetParent(frame)
		ComboPoints:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if ComboPoints.Holder and ComboPoints.Holder.mover then
			ComboPoints.Holder.mover:SetScale(0.0001)
			ComboPoints.Holder.mover:SetAlpha(0)
		end
	elseif not frame.CLASSBAR_DETACHED then
		ComboPoints:ClearAllPoints()
		if frame.ORIENTATION == "RIGHT" then
			ComboPoints:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -frame.BORDER, frame.SPACING*3)
		else
			ComboPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING*3)
		end

		ComboPoints:SetParent(frame)
		ComboPoints:SetFrameLevel(frame:GetFrameLevel() + 5)

		if ComboPoints.Holder and ComboPoints.Holder.mover then
			ComboPoints.Holder.mover:SetScale(0.0001)
			ComboPoints.Holder.mover:SetAlpha(0)
		end
	else --Detached
		CLASSBAR_WIDTH = db.combobar.detachedWidth - ((frame.BORDER + frame.SPACING)*2)
		ComboPoints.Holder:Size(db.combobar.detachedWidth, db.combobar.height)

		if not ComboPoints.Holder.mover then
			ComboPoints:Width(CLASSBAR_WIDTH)
			ComboPoints:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
			ComboPoints:ClearAllPoints()
			ComboPoints:Point("BOTTOMLEFT", ComboPoints.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(ComboPoints.Holder, "ComboBarMover", L["Combobar"], nil, nil, nil, "ALL,SOLO", nil, "unitframe,target,combobar")
		else
			ComboPoints:ClearAllPoints()
			ComboPoints:Point("BOTTOMLEFT", ComboPoints.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			ComboPoints.Holder.mover:SetScale(1)
			ComboPoints.Holder.mover:SetAlpha(1)
		end

		if db.combobar.parent == "UIPARENT" then
			ComboPoints:SetParent(E.UIParent)
		else
			ComboPoints:SetParent(frame)
		end

		if not db.combobar.strataAndLevel.useCustomStrata then
			ComboPoints:SetFrameStrata("LOW")
		else
			ComboPoints:SetFrameStrata(db.combobar.strataAndLevel.frameStrata)
		end

		if not db.combobar.strataAndLevel.useCustomLevel then
			ComboPoints:SetFrameLevel(frame:GetFrameLevel() + 5)
		else
			ComboPoints:SetFrameLevel(db.combobar.strataAndLevel.frameLevel)
		end
	end

	ComboPoints:Width(CLASSBAR_WIDTH)
	ComboPoints:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

	for i = 1, frame.MAX_CLASS_BAR do
		ComboPoints[i]:SetStatusBarColor(unpack(ElvUF.colors.ComboPoints[i]))

		color = E.db.unitframe.colors.borderColor
		ComboPoints[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		ComboPoints[i]:Height(ComboPoints:GetHeight())
		ComboPoints[i]:Hide()
		ComboPoints[i].backdrop:Hide()

		if frame.USE_MINI_CLASSBAR then
			if frame.CLASSBAR_DETACHED and db.combobar.orientation == "VERTICAL" then
				ComboPoints[i]:SetWidth(CLASSBAR_WIDTH)
				ComboPoints.Holder:SetHeight(((frame.CLASSBAR_HEIGHT + db.combobar.spacing)* frame.MAX_CLASS_BAR) - db.combobar.spacing) -- fix the holder height
			elseif frame.CLASSBAR_DETACHED and db.combobar.orientation == "HORIZONTAL" then
				ComboPoints[i]:SetWidth((CLASSBAR_WIDTH - ((db.combobar.spacing + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR)
				ComboPoints.Holder:SetHeight(frame.CLASSBAR_HEIGHT)
			else
				ComboPoints[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
				ComboPoints.Holder:SetHeight(frame.CLASSBAR_HEIGHT) -- set the holder height to default
			end
		elseif i ~= MAX_COMBO_POINTS then
			ComboPoints[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR - 1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR) --combobar width minus total width of dividers between each button, divided by number of buttons
		end

		ComboPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		ComboPoints[i]:ClearAllPoints()

		if i == 1 then
			ComboPoints[i]:Point("LEFT", ComboPoints)
		else
			if frame.USE_MINI_CLASSBAR then
				if frame.CLASSBAR_DETACHED and db.combobar.orientation == "VERTICAL" then
					ComboPoints[i]:Point("BOTTOM", ComboPoints[i - 1], "TOP", 0, (db.combobar.spacing + frame.BORDER*2 + frame.SPACING*2))
				elseif frame.CLASSBAR_DETACHED and db.combobar.orientation == "HORIZONTAL" then
					ComboPoints[i]:Point("LEFT", ComboPoints[i - 1], "RIGHT", (db.combobar.spacing + frame.BORDER*2 + frame.SPACING*2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
				else
					ComboPoints[i]:Point("LEFT", ComboPoints[i - 1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0) --5px spacing between borders of each button
				end
			elseif i == frame.MAX_CLASS_BAR then
				ComboPoints[i]:Point("LEFT", ComboPoints[i - 1], "RIGHT", frame.BORDER-frame.SPACING, 0)
				ComboPoints[i]:Point("RIGHT", ComboPoints)
			else
				ComboPoints[i]:Point("LEFT", ComboPoints[i - 1], "RIGHT", frame.BORDER-frame.SPACING, 0)
			end
		end

		if not frame.USE_MINI_CLASSBAR then
			ComboPoints[i].backdrop:Hide()
		else
			ComboPoints[i].backdrop:Show()
		end

		ComboPoints[i]:SetOrientation("HORIZONTAL")
		ComboPoints[i]:Show()
	end

	if not frame.USE_MINI_CLASSBAR then
		ComboPoints.backdrop:Show()
	else
		ComboPoints.backdrop:Hide()
	end

	self:CombobarDetachedUpdate()

	if frame.USE_CLASSBAR and not frame:IsElementEnabled("ComboPoints") then
		frame:EnableElement("ComboPoints")
		ComboPoints:Show()
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
	if unit ~= "player" and (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITING_VEHICLE") then return end

	local db = self.db
	if not db then return end

	local element = self.ComboPoints

	if db.combobar.enable then
		local inVehicle = UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")

		if not inVehicle and E.myclass ~= "ROGUE" and (E.myclass ~= "DRUID" or (E.myclass == "DRUID" and GetShapeshiftForm() ~= 3)) then
			element:Hide()
			UF.ToggleResourceBar(element)
		else
			local cp
			if inVehicle then
				cp = GetComboPoints("vehicle", "target")
			else
				cp = GetComboPoints("player", "target")
			end

			local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
			if cp == 0 and db.combobar.autoHide then
				element:Hide()
				UF.ToggleResourceBar(element)
			else
				element:Show()
				for i = 1, MAX_COMBO_POINTS do
					if i <= cp then
						element[i]:SetAlpha(1)
					else
						element[i]:SetAlpha(0.2)
					end

					if custom_backdrop then
						element[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
					else
						local r, g, b = element[i]:GetStatusBarColor()
						element[i].bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3)
					end
				end
				UF.ToggleResourceBar(element)
			end
		end
	else
		element:Hide()
		UF.ToggleResourceBar(element)
	end
end
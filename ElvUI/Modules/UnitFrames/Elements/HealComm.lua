local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame

function UF.HealthClipFrame_HealComm(frame)
	local pred = frame.HealCommBar
	if pred then
		UF:SetAlpha_HealComm(pred, true)
		UF:SetVisibility_HealComm(pred)
	end
end

function UF:SetAlpha_HealComm(obj, show)
	obj.myBar:SetAlpha(show and 1 or 0)
	obj.otherBar:SetAlpha(show and 1 or 0)
end

function UF:SetVisibility_HealComm(obj)
	-- the first update is from `HealthClipFrame_HealComm`
	-- we set this variable to allow `Configure_HealComm` to
	-- update the elements overflow lock later on by option
	if not obj.allowClippingUpdate then
		obj.allowClippingUpdate = true
	end

	if obj.maxOverflow > 1 then
		obj.myBar:SetParent(obj.health)
		obj.otherBar:SetParent(obj.health)
	else
		obj.myBar:SetParent(obj.parent)
		obj.otherBar:SetParent(obj.parent)
	end
end

function UF:Construct_HealComm(frame)
	local health = frame.Health
	local parent = health.ClipFrame

	local myBar = CreateFrame("StatusBar", nil, parent)
	local otherBar = CreateFrame("StatusBar", nil, parent)

	myBar:SetFrameLevel(11)
	otherBar:SetFrameLevel(11)

	UF.statusbars[myBar] = true
	UF.statusbars[otherBar] = true

	local texture = (not health.isTransparent and health:GetStatusBarTexture()) or E.media.blankTex
	UF:Update_StatusBar(myBar, texture)
	UF:Update_StatusBar(otherBar, texture)

	local healPrediction = {
		myBar = myBar,
		otherBar = otherBar,
		PostUpdate = UF.UpdateHealComm,
		maxOverflow = 1,
		health = health,
		parent = parent,
		frame = frame
	}

	UF:SetAlpha_HealComm(healPrediction)

	return healPrediction
end

function UF:Configure_HealComm(frame)
	if frame.db.healPrediction and frame.db.healPrediction.enable then
		local healPrediction = frame.HealCommBar
		local myBar = healPrediction.myBar
		local otherBar = healPrediction.otherBar
		local c = self.db.colors.healPrediction
		healPrediction.maxOverflow = 1 + (c.maxOverflow or 0)

		if healPrediction.allowClippingUpdate then
			UF:SetVisibility_HealComm(healPrediction)
		end

		if not frame:IsElementEnabled("HealComm4") then
			frame:EnableElement("HealComm4")
		end

		if frame.db.health then
			local health = frame.Health
			local orientation = frame.db.health.orientation or health:GetOrientation()

			myBar:SetOrientation(orientation)
			otherBar:SetOrientation(orientation)

			if orientation == "HORIZONTAL" then
				local width = health:GetWidth()
				width = (width > 0 and width) or health.WIDTH
				local healthTexture = health:GetStatusBarTexture()

				myBar:Size(width, 0)
				myBar:ClearAllPoints()
				myBar:Point("TOP", health, "TOP")
				myBar:Point("BOTTOM", health, "BOTTOM")
				myBar:Point("LEFT", healthTexture, "RIGHT")

				otherBar:Size(width, 0)
				otherBar:ClearAllPoints()
				otherBar:Point("TOP", health, "TOP")
				otherBar:Point("BOTTOM", health, "BOTTOM")
				otherBar:Point("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
			else
				local height = health:GetHeight()
				height = (height > 0 and height) or health.HEIGHT
				local healthTexture = health:GetStatusBarTexture()

				myBar:Size(0, height)
				myBar:ClearAllPoints()
				myBar:Point("LEFT", health, "LEFT")
				myBar:Point("RIGHT", health, "RIGHT")
				myBar:Point("BOTTOM", healthTexture, "TOP")

				otherBar:Size(0, height)
				otherBar:ClearAllPoints()
				otherBar:Point("LEFT", health, "LEFT")
				otherBar:Point("RIGHT", health, "RIGHT")
				otherBar:Point("BOTTOM", myBar:GetStatusBarTexture(), "TOP")
			end
		end

		myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
		otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
	elseif frame:IsElementEnabled("HealComm4") then
		frame:DisableElement("HealComm4")
	end
end

local function UpdateFillBar(frame, previousTexture, bar, amount)
	if amount == 0 then
		bar:Hide()
		return previousTexture
	end

	local orientation = frame:GetOrientation()
	bar:ClearAllPoints()
	if orientation == "HORIZONTAL" then
		bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT")
		bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT")
	else
		bar:SetPoint("BOTTOMRIGHT", previousTexture, "TOPRIGHT")
		bar:SetPoint("BOTTOMLEFT", previousTexture, "TOPLEFT")
	end

	local totalWidth, totalHeight = frame:GetSize()
	if orientation == "HORIZONTAL" then
		bar:Width(totalWidth)
	else
		bar:Height(totalHeight)
	end

	return bar:GetStatusBarTexture()
end

function UF:UpdateHealComm(_, myIncomingHeal, allIncomingHeal)
	local health = self.health
	local previousTexture = health:GetStatusBarTexture()

	previousTexture = UpdateFillBar(health, previousTexture, self.myBar, myIncomingHeal)
	UpdateFillBar(health, previousTexture, self.otherBar, allIncomingHeal)
end
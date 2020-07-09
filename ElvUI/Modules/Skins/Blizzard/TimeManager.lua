local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_TimeManager", "Skin_Blizzard_TimeManager", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.timemanager then return end

	TimeManagerFrame:StripTextures()
	TimeManagerFrame:SetTemplate("Transparent")

	E:CreateMover(TimeManagerFrame, "TimeManagerFrameMover", TIMEMANAGER_TITLE)
	TimeManagerFrame.mover:SetFrameLevel(TimeManagerFrame:GetFrameLevel() + 4)

	S:HandleCloseButton(TimeManagerCloseButton, TimeManagerFrame)

	TimeManagerStopwatchFrameBackground:SetTexture(nil)

	TimeManagerStopwatchCheck:SetTemplate("Default")
	TimeManagerStopwatchCheck:StyleButton(nil, true)

	TimeManagerStopwatchCheck:GetNormalTexture():SetInside()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

	S:HandleDropDownBox(TimeManagerAlarmHourDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmMinuteDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmAMPMDropDown, 80)

	S:HandleEditBox(TimeManagerAlarmMessageEditBox)

	TimeManagerAlarmEnabledButton:SetNormalTexture(nil)
	TimeManagerAlarmEnabledButton.SetNormalTexture = E.noop
	TimeManagerAlarmEnabledButton:SetPushedTexture(nil)
	TimeManagerAlarmEnabledButton.SetPushedTexture = E.noop
	S:HandleButton(TimeManagerAlarmEnabledButton)

	S:HandleCheckBox(TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(TimeManagerLocalTimeCheck)

	TimeManagerFrame:Size(186, 221)

	select(7, TimeManagerFrame:GetRegions()):Point("TOP", 0, -5)

	TimeManagerFrameTicker:Point("CENTER", TimeManagerGlobe, -4, 12)

	TimeManagerStopwatchFrame:Point("TOPRIGHT", 9, -13)

	TimeManagerAlarmTimeFrame:Point("TOPLEFT", 8, -56)

	TimeManagerAlarmHourDropDown:Point("TOPLEFT", TimeManagerAlarmTimeLabel, "BOTTOMLEFT", -20, -3)
	TimeManagerAlarmMinuteDropDown:Point("LEFT", TimeManagerAlarmHourDropDown, "RIGHT", -21, 0)
	TimeManagerAlarmAMPMDropDown:Point("LEFT", TimeManagerAlarmMinuteDropDown, "RIGHT", -21, 0)

	TimeManagerAlarmMessageEditBox:Width(168)
	TimeManagerAlarmMessageEditBox:Point("TOPLEFT", TimeManagerAlarmMessageLabel, "BOTTOMLEFT", 1, -7)

	TimeManagerAlarmEnabledButton:Size(170, 22)
	TimeManagerAlarmEnabledButton:Point("LEFT", 8, -50)

	TimeManagerMilitaryTimeCheck:Point("TOPLEFT", 158, -175)

	-- StopwatchFrame
	StopwatchFrame:CreateBackdrop("Transparent")
	StopwatchFrame.backdrop:Point("TOPLEFT", 0, -20)
	StopwatchFrame.backdrop:Point("BOTTOMRIGHT", 0, 0)

	StopwatchFrame:StripTextures()
	StopwatchTabFrame:StripTextures()

	S:HandleCloseButton(StopwatchCloseButton)

	S:HandleButton(StopwatchResetButton)

	StopwatchTicker:Point("BOTTOMRIGHT", -49, 0)

	StopwatchResetButton:Size(16)
	StopwatchResetButton:Point("BOTTOMRIGHT", -4, 4)
	StopwatchResetButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\reset")

	StopwatchPlayPauseButton:Size(12)
	StopwatchPlayPauseButton:Point("RIGHT", StopwatchResetButton, "LEFT", -5, 0)
	StopwatchPlayPauseButton:CreateBackdrop("Default", true)
	StopwatchPlayPauseButton.backdrop:SetOutside(StopwatchPlayPauseButton, 2, 2)
	StopwatchPlayPauseButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\play")
	StopwatchPlayPauseButton:SetHighlightTexture("")
	StopwatchPlayPauseButton:HookScript("OnEnter", S.SetModifiedBackdrop)
	StopwatchPlayPauseButton:HookScript("OnLeave", S.SetOriginalBackdrop)

	local function SetPlayTexture()
		StopwatchPlayPauseButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\play")
	end
	local function SetPauseTexture()
		StopwatchPlayPauseButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\pause")
	end

	hooksecurefunc("Stopwatch_Play", SetPauseTexture)
	hooksecurefunc("Stopwatch_Pause", SetPlayTexture)
	hooksecurefunc("Stopwatch_Clear", SetPlayTexture)
end)
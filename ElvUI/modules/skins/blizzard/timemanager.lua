local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

S:RegisterSkin('Blizzard_TimeManager', function()
	if(E.private.skins.blizzard.enable ~= true
		or E.private.skins.blizzard.timemanager ~= true)
	then
		return;
	end
	
	-- TimeManagerFrame
	TimeManagerFrame:CreateBackdrop('Transparent');
	TimeManagerFrame.backdrop:Point('TOPLEFT', 14, -11);
	TimeManagerFrame.backdrop:Point('BOTTOMRIGHT', -49, 9);
	
	TimeManagerFrame:StripTextures();
	
	S:HandleCloseButton(TimeManagerCloseButton);
	
	TimeManagerStopwatchFrameBackground:SetTexture(nil);
	
	TimeManagerStopwatchCheck:SetTemplate('Default');
	TimeManagerStopwatchCheck:StyleButton(nil, true);
	
	TimeManagerStopwatchCheck:GetNormalTexture():SetInside();
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
	
	S:HandleDropDownBox(TimeManagerAlarmHourDropDown, 80);
	S:HandleDropDownBox(TimeManagerAlarmMinuteDropDown, 80);
	S:HandleDropDownBox(TimeManagerAlarmAMPMDropDown, 80);
	
	S:HandleEditBox(TimeManagerAlarmMessageEditBox);
	
	TimeManagerAlarmEnabledButton:SetNormalTexture(nil);
	TimeManagerAlarmEnabledButton.SetNormalTexture = E.noop;
	TimeManagerAlarmEnabledButton:SetPushedTexture(nil);
	TimeManagerAlarmEnabledButton.SetPushedTexture = E.noop;
	S:HandleButton(TimeManagerAlarmEnabledButton);
	
	S:HandleCheckBox(TimeManagerMilitaryTimeCheck);
	S:HandleCheckBox(TimeManagerLocalTimeCheck);
	
	-- StopwatchFrame
	StopwatchFrame:CreateBackdrop('Transparent');
	StopwatchFrame.backdrop:Point('TOPLEFT', 0, -16);
	StopwatchFrame.backdrop:Point('BOTTOMRIGHT', 0, 2);
	
	StopwatchFrame:StripTextures();
	
	StopwatchTabFrame:StripTextures();
	
	S:HandleCloseButton(StopwatchCloseButton);
	
	S:HandleNextPrevButton(StopwatchResetButton);
	StopwatchResetButton:Point('BOTTOMRIGHT', StopwatchFrame, 'BOTTOMRIGHT', -4, 6);
	S:HandleNextPrevButton(StopwatchPlayPauseButton);
	StopwatchPlayPauseButton:Point('RIGHT', StopwatchResetButton, 'LEFT', -4, 0);
end);
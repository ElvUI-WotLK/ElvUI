local E, L, V, P, G = unpack(select(2, ...));
local AB = E:GetModule("ActionBars");

local _G = _G;

local CreateFrame = CreateFrame;

local MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"SocialsMicroButton",
	"PVPMicroButton",
	"LFDMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton"
};

local function Button_OnEnter()
	if(AB.db.microbar.mouseover) then
		E:UIFrameFadeIn(ElvUI_MicroBar, .2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha);
	end
end

local function Button_OnLeave()
	if(AB.db.microbar.mouseover) then
		E:UIFrameFadeOut(ElvUI_MicroBar, .2, ElvUI_MicroBar:GetAlpha(), 0);
	end
end

function AB:MainMenuMicroButton_SetNormal()
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36);
end

function AB:MainMenuMicroButton_SetPushed()
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 8, -37);
end

function AB:HandleMicroButton(button)
	local pushed = button:GetPushedTexture();
	local normal = button:GetNormalTexture();
	local disabled = button:GetDisabledTexture();

	button:SetParent(ElvUI_MicroBar);

	button:GetHighlightTexture():Kill();
	button:HookScript("OnEnter", Button_OnEnter);
	button:HookScript("OnLeave", Button_OnLeave);

	local f = CreateFrame("Frame", nil, button);
	f:SetFrameLevel(1);
	f:SetFrameStrata("BACKGROUND");
	f:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 0);
	f:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2, -28);
	f:SetTemplate("Default", true);
	button.backdrop = f;

	pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908);
	pushed:SetInside(f);

	normal:SetTexCoord(0.17, 0.87, 0.5, 0.908);
	normal:SetInside(f);

	if(disabled) then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908);
		disabled:SetInside(f);
	end
end

function AB:UpdateMicroButtonsParent()
	if(CharacterMicroButton:GetParent() == ElvUI_MicroBar) then return; end

	for i = 1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(ElvUI_MicroBar);
	end

	AB:UpdateMicroPositionDimensions()
end

function AB:UpdateMicroPositionDimensions()
	if(not ElvUI_MicroBar) then return; end

	local numRows = 1;
	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]];
		local prevButton = _G[MICRO_BUTTONS[i-1]] or ElvUI_MicroBar;
		local lastColumnButton = _G[MICRO_BUTTONS[i-self.db.microbar.buttonsPerRow]];

		button:ClearAllPoints();

		if(prevButton == ElvUI_MicroBar) then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", -2 + E.Border, 28 - E.Border);
		elseif((i - 1) % self.db.microbar.buttonsPerRow == 0) then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, 28 - self.db.microbar.yOffset);
			numRows = numRows + 1;
		else
			button:Point("LEFT", prevButton, "RIGHT", - 4 + self.db.microbar.xOffset, 0);
		end
	end

	if(AB.db.microbar.mouseover) then
		ElvUI_MicroBar:SetAlpha(0);
	else
		ElvUI_MicroBar:SetAlpha(self.db.microbar.alpha);
	end

	AB.MicroWidth = ((_G["CharacterMicroButton"]:GetWidth() - 4) * self.db.microbar.buttonsPerRow) + (self.db.microbar.xOffset * (self.db.microbar.buttonsPerRow - 1)) + E.Border * 2
	AB.MicroHeight = ((_G["CharacterMicroButton"]:GetHeight() - 28) * numRows) + (self.db.microbar.yOffset * (numRows - 1)) + E.Border * 2
	ElvUI_MicroBar:Width(AB.MicroWidth)
	ElvUI_MicroBar:Height(AB.MicroHeight)

	if(self.db.microbar.enabled) then
		ElvUI_MicroBar:Show();
		if(ElvUI_MicroBar.mover) then
			E:EnableMover(ElvUI_MicroBar.mover:GetName());
		end
	else
		ElvUI_MicroBar:Hide();
		if(ElvUI_MicroBar.mover) then
			E:DisableMover(ElvUI_MicroBar.mover:GetName());
		end
	end
end

function AB:SetupMicroBar()
	local microBar = CreateFrame("Frame", "ElvUI_MicroBar", E.UIParent);
	microBar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -48);
	for i = 1, #MICRO_BUTTONS do
		self:HandleMicroButton(_G[MICRO_BUTTONS[i]]);
	end

	MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop);

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateMicroButtonsParent")
	self:SecureHook("VehicleMenuBar_MoveMicroButtons", "UpdateMicroButtonsParent")

	self:SecureHook("MainMenuMicroButton_SetPushed");
	self:SecureHook("MainMenuMicroButton_SetNormal");

	self:MainMenuMicroButton_SetNormal();

	self:UpdateMicroPositionDimensions();
	E:CreateMover(microBar, "MicrobarMover", L["Micro Bar"], nil, nil, nil, "ALL,ACTIONBARS");
end
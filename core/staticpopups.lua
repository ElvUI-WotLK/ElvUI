local E, L, V, P, G = unpack(select(2, ...));

local _G = _G;
local pairs, type, unpack, assert = pairs, type, unpack, assert;
local tremove, tContains, tinsert, wipe = tremove, tContains, tinsert, table.wipe;
local lower = string.lower;

local CreateFrame = CreateFrame;
local UnitIsDeadOrGhost, InCinematic = UnitIsDeadOrGhost, InCinematic;
local GetBindingFromClick, RunBinding = GetBindingFromClick, RunBinding;
local PurchaseSlot, GetBankSlotCost = PurchaseSlot, GetBankSlotCost;
local MoneyFrame_Update = MoneyFrame_Update;
local SetCVar, DisableAddOn = SetCVar, DisableAddOn;
local ReloadUI, PlaySound, StopMusic = ReloadUI, PlaySound, StopMusic;
local StaticPopup_Resize = StaticPopup_Resize;
local AutoCompleteEditBox_OnEnterPressed = AutoCompleteEditBox_OnEnterPressed;
local AutoCompleteEditBox_OnTextChanged = AutoCompleteEditBox_OnTextChanged;
local ChatEdit_FocusActiveWindow = ChatEdit_FocusActiveWindow;
local STATICPOPUP_TEXTURE_ALERT = STATICPOPUP_TEXTURE_ALERT;
local STATICPOPUP_TEXTURE_ALERTGEAR = STATICPOPUP_TEXTURE_ALERTGEAR;

E.PopupDialogs = {};
E.StaticPopup_DisplayedFrames = {};

E.PopupDialogs["ELVUI_UPDATE_AVAILABLE"] = {
	text = L["ElvUI is five or more revisions out of date. You can download the newest version from https://github.com/ElvUI-WotLK/ElvUI/"],
	hasEditBox = 1,
	OnShow = function(self)
		self.editBox:SetAutoFocus(false);
		self.editBox.width = self.editBox:GetWidth();
		self.editBox:SetWidth(220);
		self.editBox:SetText("https://github.com/ElvUI-WotLK/ElvUI");
		self.editBox:HighlightText();
		ChatEdit_FocusActiveWindow();
	end,
	OnHide = function(self)
		self.editBox:SetWidth(self.editBox.width or 50);
		self.editBox.width = nil;
	end,
	hideOnEscape = 1,
	button1 = OKAY,
	OnAccept = E.noop,
	EditBoxOnEnterPressed = function(self)
		ChatEdit_FocusActiveWindow();
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		ChatEdit_FocusActiveWindow();
		self:GetParent():Hide();
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= "https://github.com/ElvUI-WotLK/ElvUI") then
			self:SetText("https://github.com/ElvUI-WotLK/ElvUI");
		end
		self:HighlightText();
		self:ClearFocus();
		ChatEdit_FocusActiveWindow();
	end,
	OnEditFocusGained = function(self)
		self:HighlightText();
	end,
	showAlert = 1
};

E.PopupDialogs["CLIQUE_ADVERT"] = {
	text = L["Using the healer layout it is highly recommended you download the addon Clique if you wish to have the click-to-heal function."],
	button1 = YES,
	OnAccept = E.noop,
	showAlert = 1
};

E.PopupDialogs["CONFIRM_LOSE_BINDING_CHANGES"] = {
	text = CONFIRM_LOSE_BINDING_CHANGES,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		E:GetModule("ActionBars"):ChangeBindingProfile();
		E:GetModule("ActionBars").bindingsChanged = nil;
	end,
	OnCancel = function(self)
		if(ElvUIBindPopupWindowCheckButton:GetChecked()) then
			ElvUIBindPopupWindowCheckButton:SetChecked();
		else
			ElvUIBindPopupWindowCheckButton:SetChecked(1);
		end
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1
};

E.PopupDialogs["TUKUI_ELVUI_INCOMPATIBLE"] = {
	text = L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."],
	OnAccept = function() DisableAddOn("ElvUI"); ReloadUI(); end,
	OnCancel = function() DisableAddOn("Tukui"); ReloadUI(); end,
	button1 = "ElvUI",
	button2 = "Tukui",
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["DISABLE_INCOMPATIBLE_ADDON"] = {
	text = L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"],
	OnAccept = function() E.global.ignoreIncompatible = true; end,
	OnCancel = function() E:StaticPopup_Hide("DISABLE_INCOMPATIBLE_ADDON"); E:StaticPopup_Show("INCOMPATIBLE_ADDON", E.PopupDialogs["INCOMPATIBLE_ADDON"].addon, E.PopupDialogs["INCOMPATIBLE_ADDON"].module); end,
	button1 = L["I Swear"],
	button2 = DECLINE,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["INCOMPATIBLE_ADDON"] = {
	text = L["INCOMPATIBLE_ADDON"],
	OnAccept = function(self) DisableAddOn(E.PopupDialogs["INCOMPATIBLE_ADDON"].addon); ReloadUI(); end,
	OnCancel = function(self) E.private[lower(E.PopupDialogs["INCOMPATIBLE_ADDON"].module)].enable = false; ReloadUI(); end,
	button3 = L["Disable Warning"],
	OnAlt = function ()
		E:StaticPopup_Hide("INCOMPATIBLE_ADDON");
		E:StaticPopup_Show("DISABLE_INCOMPATIBLE_ADDON");
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["PIXELPERFECT_CHANGED"] = {
	text = L["You have changed the Thin Border Theme option. You will have to complete the installation process to remove any graphical bugs."],
	button1 = ACCEPT,
	OnAccept = E.noop,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["CONFIGAURA_SET"] = {
	text = L["Because of the mass confusion caused by the new aura system I've implemented a new step to the installation process. This is optional. If you like how your auras are setup go to the last step and click finished to not be prompted again. If for some reason you are prompted repeatedly please restart your game."],
	button1 = ACCEPT,
	OnAccept = E.noop,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["QUEUE_TAINT"] = {
	text = L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["FAILED_UISCALE"] = {
	text = L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() E.global.general.autoScale = false; ReloadUI(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["CONFIG_RL"] = {
	text = L["One or more of the changes you have made require a ReloadUI."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["GLOBAL_RL"] = {
	text = L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["PRIVATE_RL"] = {
	text = L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["KEYBIND_MODE"] = {
	text = L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."],
	button1 = L["Save"],
	button2 = L["Discard"],
	OnAccept = function() local AB = E:GetModule("ActionBars"); AB:DeactivateBindMode(true); end,
	OnCancel = function() local AB = E:GetModule("ActionBars"); AB:DeactivateBindMode(false); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

E.PopupDialogs["DELETE_GRAYS"] = {
	text = L["Are you sure you want to delete all your gray items?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function() local B = E:GetModule("Bags"); B:VendorGrays(true); end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, E.PopupDialogs["DELETE_GRAYS"].Money);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	hasMoneyFrame = 1
};

E.PopupDialogs["BUY_BANK_SLOT"] = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		PurchaseSlot();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetBankSlotCost());
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

E.PopupDialogs["CANNOT_BUY_BANK_SLOT"] = {
	text = L["Can't buy anymore slots!"],
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1
};

E.PopupDialogs["NO_BANK_BAGS"] = {
	text = L["You must purchase a bank slot first!"],
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1
};

E.PopupDialogs["RESETUI_CHECK"] = {
	text = L["Are you sure you want to reset every mover back to it's default position?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		E:ResetAllUI();
	end,
	timeout = 0,
	whileDead = 1
};

E.PopupDialogs["HARLEM_SHAKE"] = {
	text = L["ElvUI needs to perform database optimizations please be patient."],
	button1 = OKAY,
	OnAccept = function()
		if(E.isMassiveShaking) then
			E:StopHarlemShake();
		else
			E:BeginHarlemShake();
			return true;
		end
	end,
	timeout = 0,
	whileDead = 1
};

E.PopupDialogs["HELLO_KITTY"] = {
	text = L["ElvUI needs to perform database optimizations please be patient."],
	button1 = OKAY,
	OnAccept = function()
		E:SetupHelloKitty();
	end,
	timeout = 0,
	whileDead = 1
};

E.PopupDialogs["HELLO_KITTY_END"] = {
	text = L["Do you enjoy the new ElvUI?"],
	button1 = L["Yes, Keep Changes!"],
	button2 = L["No, Revert Changes!"],
	OnAccept = function()
		E:Print(L["Type /hellokitty to revert to old settings."]);
		StopMusic();
		SetCVar("Sound_EnableAllSound", E.oldEnableAllSound);
		SetCVar("Sound_EnableMusic", E.oldEnableMusic);
	end,
	OnCancel = function()
		E:RestoreHelloKitty();
		StopMusic();
		SetCVar("Sound_EnableAllSound", E.oldEnableAllSound);
		SetCVar("Sound_EnableMusic", E.oldEnableMusic);
	end,
	timeout = 0,
	whileDead = 1
};

E.PopupDialogs["DISBAND_RAID"] = {
	text = L["Are you sure you want to disband the group?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() E:GetModule("Misc"):DisbandRaidGroup(); end,
	timeout = 0,
	whileDead = 1
}

E.PopupDialogs["CONFIRM_LOOT_DISTRIBUTION"] = {
	text = CONFIRM_LOOT_DISTRIBUTION,
	button1 = YES,
	button2 = NO,
	timeout = 0,
	hideOnEscape = 1
};

E.PopupDialogs["RESET_PROFILE_PROMPT"] = {
	text = L["Are you sure you want to reset all the settings on this profile?"],
	button1 = YES,
	button2 = NO,
	timeout = 0,
	hideOnEscape = 1,
	OnAccept = function() E:ResetProfile(); end
};

E.PopupDialogs["APPLY_FONT_WARNING"] = {
	text = L["Are you sure you want to apply this font to all ElvUI elements?"],
	OnAccept = function()
		local font = E.db.general.font;
		local fontSize = E.db.general.fontSize;

		E.db.bags.itemLevelFont = font;
		E.db.bags.itemLevelFontSize = fontSize;
		E.db.bags.countFont = font;
		E.db.bags.countFontSize = fontSize;
		E.db.nameplates.font = font;
		--E.db.nameplates.fontSize = fontSize;
		E.db.actionbar.font = font
		--E.db.actionbar.fontSize = fontSize
		E.db.auras.font = font;
		E.db.auras.fontSize = fontSize;
		E.db.general.reminder.font = font;
		--E.db.general.reminder.fontSize = fontSize;
		E.db.chat.font = font;
		E.db.chat.fontSize = fontSize;
		E.db.chat.tabFont = font;
		E.db.chat.tapFontSize = fontSize;
		E.db.datatexts.font = font;
		E.db.datatexts.fontSize = fontSize;
		E.db.tooltip.font = font;
		E.db.tooltip.fontSize = fontSize;
		E.db.tooltip.headerFontSize = fontSize;
		E.db.tooltip.textFontSize = fontSize;
		E.db.tooltip.smallTextFontSize = fontSize;
		E.db.tooltip.healthBar.font = font;
		--E.db.tooltip.healthbar.fontSize = fontSize;
		E.db.unitframe.font = font;
		--E.db.unitframe.fontSize = fontSize;
		--E.db.unitframe.units.party.rdebuffs.font = font;
		E.db.unitframe.units.raid.rdebuffs.font = font;
		E.db.unitframe.units.raid40.rdebuffs.font = font;

		E:UpdateAll(true);
	end,
	OnCancel = function() E:StaticPopup_Hide("APPLY_FONT_WARNING"); end,
	button1 = YES,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
};

local MAX_STATIC_POPUPS = 4;

function E:StaticPopup_OnShow()
	PlaySound("igMainMenuOpen");

	local dialog = E.PopupDialogs[self.which];
	local OnShow = dialog.OnShow;

	if(OnShow) then
		OnShow(self, self.data);
	end
	if(dialog.hasMoneyInputFrame) then
		_G[self:GetName() .. "MoneyInputFrameGold"]:SetFocus();
	end
	if(dialog.enterClicksFirstButton) then
		self:SetScript("OnKeyDown", E.StaticPopup_OnKeyDown);
	end
end

function E:StaticPopup_EscapePressed()
	local closed = nil;
	for _, frame in pairs(E.StaticPopup_DisplayedFrames) do
		if(frame:IsShown() and frame.hideOnEscape) then
			local standardDialog = E.PopupDialogs[frame.which];
			if(standardDialog) then
				local OnCancel = standardDialog.OnCancel;
				local noCancelOnEscape = standardDialog.noCancelOnEscape;
				if(OnCancel and not noCancelOnEscape) then
					OnCancel(frame, frame.data, "clicked");
				end
				frame:Hide();
			else
				E:StaticPopupSpecial_Hide(frame);
			end
			closed = 1;
		end
	end
	return closed;
end

function E:StaticPopupSpecial_Hide(frame)
	frame:Hide();
	E:StaticPopup_CollapseTable();
end

function E:StaticPopup_CollapseTable()
	local displayedFrames = E.StaticPopup_DisplayedFrames;
	local index = #displayedFrames;
	while((index >= 1) and (not displayedFrames[index]:IsShown())) do
		tremove(displayedFrames, index);
		index = index - 1;
	end
end

function E:StaticPopup_SetUpPosition(dialog)
	if(not tContains(E.StaticPopup_DisplayedFrames, dialog)) then
		local lastFrame = E.StaticPopup_DisplayedFrames[#E.StaticPopup_DisplayedFrames];
		if(lastFrame) then
			dialog:SetPoint("TOP", lastFrame, "BOTTOM", 0, -4);
		else
			dialog:SetPoint("TOP", E.UIParent, "TOP", 0, -100);
		end
		tinsert(E.StaticPopup_DisplayedFrames, dialog);
	end
end

function E:StaticPopupSpecial_Show(frame)
	if(frame.exclusive) then
		E:StaticPopup_HideExclusive();
	end
	E:StaticPopup_SetUpPosition(frame);
	frame:Show();
end

function E:StaticPopupSpecial_Hide(frame)
	frame:Hide();
	E:StaticPopup_CollapseTable();
end

function E:StaticPopup_IsLastDisplayedFrame(frame)
	for i = #E.StaticPopup_DisplayedFrames, 1, -1 do
		local popup = E.StaticPopup_DisplayedFrames[i];
		if(popup:IsShown()) then
			return frame == popup;
		end
	end
	return false;
end

function E:StaticPopup_OnKeyDown(key)
	if(GetBindingFromClick(key) == "TOGGLEGAMEMENU") then
		return E:StaticPopup_EscapePressed();
	elseif(GetBindingFromClick(key) == "SCREENSHOT") then
		RunBinding("SCREENSHOT");
		return;
	end

	local dialog = E.PopupDialogs[self.which];
	if(dialog) then
		if(key == "ENTER" and dialog.enterClicksFirstButton) then
			local frameName = self:GetName();
			local button;
			local i = 1;
			while(true) do
				button = _G[frameName.."Button"..i];
				if(button) then
					if(button:IsShown()) then
						E:StaticPopup_OnClick(self, i);
						return;
					end
					i = i + 1;
				else
					break;
				end
			end
		end
	end
end

function E:StaticPopup_OnHide()
	PlaySound("igMainMenuClose");

	E:StaticPopup_CollapseTable();

	local dialog = E.PopupDialogs[self.which];
	local OnHide = dialog.OnHide;
	if(OnHide) then
		OnHide(self, self.data);
	end
	self.extraFrame:Hide();
	if(dialog.enterClicksFirstButton) then
		self:SetScript("OnKeyDown", nil);
	end
end

function E:StaticPopup_OnUpdate(elapsed)
	if(self.timeleft and self.timeleft > 0) then
		local which = self.which;
		local timeleft = self.timeleft - elapsed;
		if(timeleft <= 0) then
			if(not E.PopupDialogs[which].timeoutInformationalOnly) then
				self.timeleft = 0;
				local OnCancel = E.PopupDialogs[which].OnCancel;
				if(OnCancel) then
					OnCancel(self, self.data, "timeout");
				end
				self:Hide();
			end
			return;
		end
		self.timeleft = timeleft;
	end

	if(self.startDelay) then
		local which = self.which;
		local timeleft = self.startDelay - elapsed;
		if(timeleft <= 0) then
			self.startDelay = nil;
			local text = _G[self:GetName() .. "Text"];
			text:SetFormattedText(E.PopupDialogs[which].text, text.text_arg1, text.text_arg2);
			local button1 = _G[self:GetName() .. "Button1"];
			button1:Enable();
			StaticPopup_Resize(self, which);
			return;
		end
		self.startDelay = timeleft;
	end

	local onUpdate = E.PopupDialogs[self.which].OnUpdate;
	if(onUpdate) then
		onUpdate(self, elapsed);
	end
end

function E:StaticPopup_OnClick(index)
	if(not self:IsShown()) then
		return;
	end
	local which = self.which;
	local info = E.PopupDialogs[which];
	if(not info) then
		return nil;
	end
	local hide = true;
	if(index == 1) then
		local OnAccept = info.OnAccept;
		if(OnAccept) then
			hide = not OnAccept(self, self.data, self.data2);
		end
	elseif(index == 3) then
		local OnAlt = info.OnAlt;
		if(OnAlt) then
			OnAlt(self, self.data, "clicked");
		end
	else
		local OnCancel = info.OnCancel;
		if(OnCancel) then
			hide = not OnCancel(self, self.data, "clicked");
		end
	end

	if(hide and (which == self.which) and (index ~= 3 or not info.noCloseOnAlt)) then
		self:Hide();
	end
end

function E:StaticPopup_EditBoxOnEnterPressed()
	local EditBoxOnEnterPressed, which, dialog;
	local parent = self:GetParent();
	if(parent.which) then
		which = parent.which;
		dialog = parent;
	elseif(parent:GetParent().which) then
		which = parent:GetParent().which;
		dialog = parent:GetParent();
	end
	if(not self.autoCompleteParams or not AutoCompleteEditBox_OnEnterPressed(self)) then
		EditBoxOnEnterPressed = E.PopupDialogs[which].EditBoxOnEnterPressed;
		if(EditBoxOnEnterPressed) then
			EditBoxOnEnterPressed(self, dialog.data);
		end
	end
end

function E:StaticPopup_EditBoxOnEscapePressed()
	local EditBoxOnEscapePressed = E.PopupDialogs[self:GetParent().which].EditBoxOnEscapePressed;
	if(EditBoxOnEscapePressed) then
		EditBoxOnEscapePressed(self, self:GetParent().data);
	end
end

function E:StaticPopup_EditBoxOnTextChanged(userInput)
	if(not self.autoCompleteParams or not AutoCompleteEditBox_OnTextChanged(self, userInput)) then
		local EditBoxOnTextChanged = E.PopupDialogs[self:GetParent().which].EditBoxOnTextChanged;
		if(EditBoxOnTextChanged) then
			EditBoxOnTextChanged(self, self:GetParent().data);
		end
	end
end

function E:StaticPopup_FindVisible(which, data)
	local info = E.PopupDialogs[which];
	if(not info) then
		return nil;
	end
	for index = 1, MAX_STATIC_POPUPS, 1 do
		local frame = _G["ElvUI_StaticPopup" .. index];
		if(frame:IsShown() and (frame.which == which) and (not info.multiple or (frame.data == data))) then
			return frame;
		end
	end
	return nil;
end

function E:StaticPopup_Resize(dialog, which)
	local info = E.PopupDialogs[which];
	if(not info) then
		return nil;
	end

	local name = dialog:GetName();
	local text = _G[name .. "Text"];
	local editBox = _G[name .. "EditBox"];
	local button1 = _G[name .. "Button1"];

	local maxHeightSoFar, maxWidthSoFar = (dialog.maxHeightSoFar or 0), (dialog.maxWidthSoFar or 0);
	local width = 320;

	if(dialog.numButtons == 3) then
		width = 440;
	elseif(info.showAlert or info.showAlertGear or info.closeButton) then
		width = 420;
	elseif(info.editBoxWidth and info.editBoxWidth > 260) then
		width = width + (info.editBoxWidth - 260);
	end

	if(width > maxWidthSoFar) then
		dialog:SetWidth(width);
		dialog.maxWidthSoFar = width;
	end

	local height = 32 + text:GetHeight() + 8 + button1:GetHeight();
	if(info.hasEditBox) then
		height = height + 8 + editBox:GetHeight();
	elseif(info.hasMoneyFrame) then
		height = height + 16;
	elseif(info.hasMoneyInputFrame) then
		height = height + 22;
	end
	if(info.hasItemFrame) then
		height = height + 64;
	end

	if(height > maxHeightSoFar) then
		dialog:SetHeight(height);
		dialog.maxHeightSoFar = height;
	end
end

function E:StaticPopup_OnEvent()
	self.maxHeightSoFar = 0;
	E:StaticPopup_Resize(self, self.which);
end

local tempButtonLocs = {};
function E:StaticPopup_Show(which, text_arg1, text_arg2, data)
	local info = E.PopupDialogs[which];
	if(not info) then
		return nil;
	end

	if(UnitIsDeadOrGhost("player") and not info.whileDead) then
		if(info.OnCancel) then
			info.OnCancel();
		end
		return nil;
	end

	if(InCinematic() and not info.interruptCinematic) then
		if(info.OnCancel) then
			info.OnCancel();
		end
		return nil;
	end

	if(info.cancels) then
		for index = 1, MAX_STATIC_POPUPS, 1 do
			local frame = _G["ElvUI_StaticPopup" .. index];
			if(frame:IsShown() and (frame.which == info.cancels)) then
				frame:Hide();
				local OnCancel = E.PopupDialogs[frame.which].OnCancel;
				if(OnCancel) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	local dialog = nil;
	dialog = E:StaticPopup_FindVisible(which, data);
	if(dialog) then
		if(not info.noCancelOnReuse) then
			local OnCancel = info.OnCancel;
			if(OnCancel) then
				OnCancel(dialog, dialog.data, "override");
			end
		end
		dialog:Hide();
	end
	if(not dialog) then
		local index = 1;
		if(info.preferredIndex) then
			index = info.preferredIndex;
		end
		for i = index, MAX_STATIC_POPUPS do
			local frame = _G["ElvUI_StaticPopup" .. i];
			if(not frame:IsShown()) then
				dialog = frame;
				break;
			end
		end
		if(not dialog and info.preferredIndex) then
			for i = 1, info.preferredIndex do
				local frame = _G["ElvUI_StaticPopup" .. i];
				if(not frame:IsShown()) then
					dialog = frame;
					break;
				end
			end
		end
	end
	if(not dialog) then
		if(info.OnCancel) then
			info.OnCancel();
		end
		return nil;
	end

	dialog.maxHeightSoFar, dialog.maxWidthSoFar = 0, 0;

	local name = dialog:GetName();
	local text = _G[name .. "Text"];
	text:SetFormattedText(info.text, text_arg1, text_arg2);

	if(info.closeButton) then
		local closeButton = _G[name .. "CloseButton"];
		if(info.closeButtonIsHide) then
			closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-HideButton-Up");
			closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-HideButton-Down");
		else
			closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up");
			closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down");
		end
		closeButton:Show();
	else
		_G[name .. "CloseButton"]:Hide();
	end

	local editBox = _G[name .. "EditBox"];
	if(info.hasEditBox) then
		editBox:Show();

		if(info.maxLetters) then
			editBox:SetMaxLetters(info.maxLetters);
			editBox:SetCountInvisibleLetters(info.countInvisibleLetters);
		end
		if(info.maxBytes) then
			editBox:SetMaxBytes(info.maxBytes);
		end
		editBox:SetText("");
		if(info.editBoxWidth) then
			editBox:SetWidth(info.editBoxWidth);
		else
			editBox:SetWidth(130);
		end
	else
		editBox:Hide();
	end

	if(info.hasMoneyFrame) then
		_G[name .. "MoneyFrame"]:Show();
		_G[name .. "MoneyInputFrame"]:Hide();
	elseif(info.hasMoneyInputFrame) then
		local moneyInputFrame = _G[name .. "MoneyInputFrame"];
		moneyInputFrame:Show();
		_G[name .. "MoneyFrame"]:Hide();
		if(info.EditBoxOnEnterPressed) then
			moneyInputFrame.gold:SetScript("OnEnterPressed", E.StaticPopup_EditBoxOnEnterPressed);
			moneyInputFrame.silver:SetScript("OnEnterPressed", E.StaticPopup_EditBoxOnEnterPressed);
			moneyInputFrame.copper:SetScript("OnEnterPressed", E.StaticPopup_EditBoxOnEnterPressed);
		else
			moneyInputFrame.gold:SetScript("OnEnterPressed", nil);
			moneyInputFrame.silver:SetScript("OnEnterPressed", nil);
			moneyInputFrame.copper:SetScript("OnEnterPressed", nil);
		end
	else
		_G[name .. "MoneyFrame"]:Hide();
		_G[name .. "MoneyInputFrame"]:Hide();
	end

	if(info.hasItemFrame) then
		_G[name .. "ItemFrame"]:Show();
		if(data and type(data) == "table") then
			_G[name .. "ItemFrame"].link = data.link;
			_G[name .. "ItemFrameIconTexture"]:SetTexture(data.texture);
			local nameText = _G[name .. "ItemFrameText"];
			nameText:SetTextColor(unpack(data.color or {1, 1, 1, 1}));
			nameText:SetText(data.name);
			if(data.count and data.count > 1) then
				_G[name .. "ItemFrameCount"]:SetText(data.count);
				_G[name .. "ItemFrameCount"]:Show();
			else
				_G[name .. "ItemFrameCount"]:Hide();
			end
		end
	else
		_G[name .. "ItemFrame"]:Hide();
	end

	dialog.which = which;
	dialog.timeleft = info.timeout;
	dialog.hideOnEscape = info.hideOnEscape;
	dialog.exclusive = info.exclusive;
	dialog.enterClicksFirstButton = info.enterClicksFirstButton;
	dialog.data = data;

	local button1 = _G[name .. "Button1"];
	local button2 = _G[name .. "Button2"];
	local button3 = _G[name .. "Button3"];

	do
		assert(#tempButtonLocs == 0);

		tinsert(tempButtonLocs, button1);
		tinsert(tempButtonLocs, button2);
		tinsert(tempButtonLocs, button3);

		for i = #tempButtonLocs, 1, -1 do
			tempButtonLocs[i]:SetText(info["button"..i]);
			tempButtonLocs[i]:Hide();
			tempButtonLocs[i]:ClearAllPoints();
			if(not (info["button"..i] and ( not info["DisplayButton"..i] or info["DisplayButton"..i](dialog)))) then
				tremove(tempButtonLocs, i);
			end
		end

		local numButtons = #tempButtonLocs;
		dialog.numButtons = numButtons;
		if(numButtons == 3) then
			tempButtonLocs[1]:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -72, 16);
		elseif(numButtons == 2) then
			tempButtonLocs[1]:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -6, 16);
		elseif(numButtons == 1) then
			tempButtonLocs[1]:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 16);
		end

		for i = 1, numButtons do
			if(i > 1) then
				tempButtonLocs[i]:SetPoint("LEFT", tempButtonLocs[i-1], "RIGHT", 13, 0);
			end

			local width = tempButtonLocs[i]:GetTextWidth();
			if(width > 110) then
				tempButtonLocs[i]:SetWidth(width + 20);
			else
				tempButtonLocs[i]:SetWidth(120);
			end
			tempButtonLocs[i]:Enable();
			tempButtonLocs[i]:Show();
		end

		wipe(tempButtonLocs);
	end

	local alertIcon = _G[name .. "AlertIcon"];
	if(info.showAlert) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT);
		if(button3:IsShown())then
			alertIcon:SetPoint("LEFT", 24, 10);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	elseif(info.showAlertGear) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERTGEAR);
		if(button3:IsShown())then
			alertIcon:SetPoint("LEFT", 24, 0);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	else
		alertIcon:SetTexture();
		alertIcon:Hide();
	end

	if(info.StartDelay) then
		dialog.startDelay = info.StartDelay();
		button1:Disable();
	else
		dialog.startDelay = nil;
		button1:Enable();
	end

	editBox.autoCompleteParams = info.autoCompleteParams;
	editBox.autoCompleteRegex = info.autoCompleteRegex;
	editBox.autoCompleteFormatRegex = info.autoCompleteFormatRegex;

	editBox.addHighlightedText = true;

	E:StaticPopup_SetUpPosition(dialog);
	dialog:Show();

	E:StaticPopup_Resize(dialog, which);

	if(info.sound) then
		PlaySound(info.sound);
	end

	return dialog;
end

function E:StaticPopup_Hide(which, data)
	for index = 1, MAX_STATIC_POPUPS, 1 do
		local dialog = _G["ElvUI_StaticPopup" .. index];
		if((dialog.which == which) and (not data or (data == dialog.data))) then
			dialog:Hide();
		end
	end
end

function E:StaticPopup_CombineTables()
	if(not tContains(E.StaticPopup_DisplayedFrames, dialog)) then
		local lastFrame = E.StaticPopup_DisplayedFrames[#StaticPopup_DisplayedFrames];
		if(lastFrame) then
			dialog:SetPoint("TOP", lastFrame, "BOTTOM", 0, -4);
		else
			dialog:SetPoint("TOP", E.UIParent, "TOP", 0, -135);
		end
		tinsert(E.StaticPopup_DisplayedFrames, dialog);
	end
end

function E:Contruct_StaticPopups()
	E.StaticPopupFrames = {};

	local S = self:GetModule("Skins");
	for index = 1, MAX_STATIC_POPUPS do
		E.StaticPopupFrames[index] = CreateFrame("Frame", "ElvUI_StaticPopup" .. index, E.UIParent, "StaticPopupTemplate");
		E.StaticPopupFrames[index]:SetID(index);

		E.StaticPopupFrames[index]:SetScript("OnShow", E.StaticPopup_OnShow);
		E.StaticPopupFrames[index]:SetScript("OnHide", E.StaticPopup_OnHide);
		E.StaticPopupFrames[index]:SetScript("OnUpdate", E.StaticPopup_OnUpdate);
		E.StaticPopupFrames[index]:SetScript("OnEvent", E.StaticPopup_OnEvent);

		local name = E.StaticPopupFrames[index]:GetName();
		for i = 1, 3 do
			_G[name .. "Button" .. i]:SetScript("OnClick", function(self)
				E.StaticPopup_OnClick(self:GetParent(), self:GetID());
			end);
		end

		_G[name .. "EditBox"]:SetScript("OnEnterPressed", E.StaticPopup_EditBoxOnEnterPressed);
		_G[name .. "EditBox"]:SetScript("OnEscapePressed", E.StaticPopup_EditBoxOnEscapePressed);
		_G[name .. "EditBox"]:SetScript("OnTextChanged", E.StaticPopup_EditBoxOnTextChanged);

		E.StaticPopupFrames[index]:SetTemplate("Transparent");

		for i = 1, 3 do
			S:HandleButton(_G[name .. "Button" .. i]);
		end

		S:HandleEditBox(_G[name .. "EditBox"]);
		for k = 1, _G[name .. "EditBox"]:GetNumRegions() do
			local region = select(k, _G[name .. "EditBox"]:GetRegions())
			if(region and region:IsObjectType("Texture")) then
				if(region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right") then
					region:Kill();
				end
			end
		end
		S:HandleEditBox(_G[name .. "MoneyInputFrameGold"]);
		S:HandleEditBox(_G[name .. "MoneyInputFrameSilver"]);
		S:HandleEditBox(_G[name .. "MoneyInputFrameCopper"]);
		_G[name .. "EditBox"].backdrop:Point("TOPLEFT", -2, -4);
		_G[name .. "EditBox"].backdrop:Point("BOTTOMRIGHT", 2, 4);
		_G[name .. "ItemFrameNameFrame"]:Kill();
		_G[name .. "ItemFrame"]:GetNormalTexture():Kill();
		_G[name .. "ItemFrame"]:SetTemplate("Default");
		_G[name .. "ItemFrame"]:StyleButton();
		_G[name .. "ItemFrameIconTexture"]:SetTexCoord(unpack(E.TexCoords));
		_G[name .. "ItemFrameIconTexture"]:SetInside();
	end

	E:SecureHook("StaticPopup_SetUpPosition");
	E:SecureHook("StaticPopup_CollapseTable");
end
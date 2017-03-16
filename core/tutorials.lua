local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local _G = _G;

local CreateFrame = CreateFrame;
local DISABLE = DISABLE;
local HIDE = HIDE;

E.TutorialList = {
	L["For technical support visit us at https://github.com/ElvUI-WotLK/ElvUI"],
	L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."],
	L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."],
	L["You can set your keybinds quickly by typing /kb."],
	L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."],
	L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."],
	L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."],
	L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."],
	L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."],
	L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."],
	L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"],
	L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."],
	L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."]
}

function E:SetNextTutorial()
	self.db.currentTutorial = self.db.currentTutorial or 0
	self.db.currentTutorial = self.db.currentTutorial + 1

	if self.db.currentTutorial > #E.TutorialList then
		self.db.currentTutorial = 1
	end

	ElvUITutorialWindow.desc:SetText(E.TutorialList[self.db.currentTutorial])
end

function E:SetPrevTutorial()
	self.db.currentTutorial = self.db.currentTutorial or 0
	self.db.currentTutorial = self.db.currentTutorial - 1

	if self.db.currentTutorial <= 0 then
		self.db.currentTutorial = #E.TutorialList
	end

	ElvUITutorialWindow.desc:SetText(E.TutorialList[self.db.currentTutorial])
end

function E:SpawnTutorialFrame()
	local f = CreateFrame("Frame", "ElvUITutorialWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(110)
	f:SetTemplate("Transparent")
	f:Hide()

	local S = E:GetModule("Skins")

	local header = CreateFrame("Button", nil, f)
	header:SetTemplate("Default", true)
	header:SetWidth(120); header:SetHeight(25)
	header:SetPoint("CENTER", f, "TOP")
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText("ElvUI")

	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 30)
	f.desc = desc

	f.disableButton = CreateFrame("CheckButton", f:GetName().."DisableButton", f, "OptionsCheckButtonTemplate")
	_G[f.disableButton:GetName() .. "Text"]:SetText(DISABLE)
	f.disableButton:SetPoint("BOTTOMLEFT")
	S:HandleCheckBox(f.disableButton)
	f.disableButton:SetScript("OnShow", function(self) self:SetChecked(E.db.hideTutorial) end)

	f.disableButton:SetScript("OnClick", function(self) E.db.hideTutorial = self:GetChecked() end)

	f.hideButton = CreateFrame("Button", f:GetName().."HideButton", f, "OptionsButtonTemplate")
	f.hideButton:SetPoint("BOTTOMRIGHT", -5, 5)
	S:HandleButton(f.hideButton)
	_G[f.hideButton:GetName() .. "Text"]:SetText(HIDE)
	f.hideButton:SetScript("OnClick", function(self) E:StaticPopupSpecial_Hide(self:GetParent()) end)

	f.nextButton = CreateFrame("Button", f:GetName().."NextButton", f, "OptionsButtonTemplate")
	f.nextButton:SetPoint("RIGHT", f.hideButton, "LEFT", -4, 0)
	f.nextButton:Width(20)
	S:HandleButton(f.nextButton)
	_G[f.nextButton:GetName() .. "Text"]:SetText(">")
	f.nextButton:SetScript("OnClick", function() E:SetNextTutorial() end)

	f.prevButton = CreateFrame("Button", f:GetName().."PrevButton", f, "OptionsButtonTemplate")
	f.prevButton:SetPoint("RIGHT", f.nextButton, "LEFT", -4, 0)
	f.prevButton:Width(20)
	S:HandleButton(f.prevButton)
	_G[f.prevButton:GetName() .. "Text"]:SetText("<")
	f.prevButton:SetScript("OnClick", function() E:SetPrevTutorial() end)

	return f
end

function E:Tutorials(forceShow)
	if (not forceShow and self.db.hideTutorial) or (not forceShow and not self.private.install_complete) then return; end
	local f = ElvUITutorialWindow
	if not f then
		f = E:SpawnTutorialFrame()
	end

	E:StaticPopupSpecial_Show(f)

	self:SetNextTutorial()
end
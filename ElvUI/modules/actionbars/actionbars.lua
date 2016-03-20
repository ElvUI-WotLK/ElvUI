local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:NewModule('ActionBars', 'AceHook-3.0', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0")
local gsub = string.gsub
local split = string.split;
local KEY_MOUSEBUTTON = KEY_BUTTON10;
KEY_MOUSEBUTTON = gsub(KEY_MOUSEBUTTON, '10', '');
local KEY_NUMPAD = KEY_NUMPAD0;
KEY_NUMPAD = gsub(KEY_NUMPAD, '0', '');

local hooksecurefunc = hooksecurefunc;
local CreateFrame = CreateFrame;
local VehicleExit = VehicleExit;
local RegisterStateDriver = RegisterStateDriver;
local UnregisterStateDriver = UnregisterStateDriver;
local InCombatLockdown = InCombatLockdown;
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS;

AB["handledBars"] = {};
AB["handledbuttons"] = {};
AB["barDefaults"] = {
	["bar1"] = {
		["page"] = 1,
		["conditions"] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
		["position"] = "BOTTOM,ElvUIParent,BOTTOM,0,4"
	},
	["bar2"] = {
		["page"] = 5,
		["conditions"] = "",
		["position"] = "BOTTOM,ElvUI_Bar1,TOP,0,2"
	},
	["bar3"] = {
		["page"] = 6,
		["conditions"] = "",
		["position"] = "LEFT,ElvUI_Bar1,RIGHT,4,0"
	},
	["bar4"] = {
		["page"] = 4,
		["conditions"] = "",
		["position"] = "RIGHT,ElvUIParent,RIGHT,-4,0"
	},
	["bar5"] = {
		["page"] = 3,
		["conditions"] = "",
		["position"] = "RIGHT,ElvUI_Bar1,LEFT,-4,0"
	}
};

function AB:CreateActionBars()
	self:CreateBar1()
	self:CreateBar2()
	self:CreateBar3()
	self:CreateBar4()
	self:CreateBar5()
	self:CreateBarPet()
	self:CreateBarShapeShift()
	
	if ( E.myclass == 'SHAMAN' ) then
		self:CreateTotemBar();
	end
end

function AB:PLAYER_REGEN_ENABLED()
	self:UpdateButtonSettings()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function AB:PositionAndSizeBar(barName)
	local buttonSpacing = E:Scale(self.db[barName].buttonspacing);
	local backdropSpacing = E:Scale((self.db[barName].backdropSpacing or self.db[barName].buttonspacing));
	local buttonsPerRow = self.db[barName].buttonsPerRow;
	local numButtons = self.db[barName].buttons;
	local size = E:Scale(self.db[barName].buttonsize);
	local point = self.db[barName].point;
	local numColumns = ceil(numButtons / buttonsPerRow);
	local widthMult = self.db[barName].widthMult;
	local heightMult = self.db[barName].heightMult;
	local bar = self["handledBars"][barName];
	
	bar.db = self.db[barName];
	bar.db.position = nil;
	
	if(numButtons < buttonsPerRow) then
		buttonsPerRow = numButtons;
	end
	
	if(numColumns < 1) then
		numColumns = 1;
	end
	
	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult-1)) + (backdropSpacing*2) + ((self.db[barName].backdrop == true and E.Border or E.Spacing)*2);
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult-1)) + (backdropSpacing*2) + ((self.db[barName].backdrop == true and E.Border or E.Spacing)*2);
	bar:Width(barWidth);
	bar:Height(barHeight);
	
	bar.mouseover = self.db[barName].mouseover;
	
	if(self.db[barName].backdrop == true) then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();
	end

	local horizontalGrowth, verticalGrowth;
	if(point == "TOPLEFT" or point == "TOPRIGHT") then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end
	
	if(point == "BOTTOMLEFT" or point == "TOPLEFT") then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end
	
	if(self.db[barName].mouseover) then
		bar:SetAlpha(0);
	else
		bar:SetAlpha(self.db[barName].alpha);
	end
	
	if(self.db[barName].inheritGlobalFade) then
		bar:SetParent(self.fadeParent);
	else
		bar:SetParent(E.UIParent);
	end
	
	local button, lastButton, lastColumnButton;
	local firstButtonSpacing = backdropSpacing + (self.db[barName].backdrop == true and E.Border or E.Spacing);
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i];
		lastButton = bar.buttons[i-1];
		lastColumnButton = bar.buttons[i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:Size(size);
		button:SetAttribute("showgrid", 1);
		ActionButton_ShowGrid(button);
		
		if(i == 1) then
			local x, y;
			if(point == "BOTTOMLEFT") then
				x, y = firstButtonSpacing, firstButtonSpacing;
			elseif(point == "TOPRIGHT") then
				x, y = -firstButtonSpacing, -firstButtonSpacing;
			elseif(point == "TOPLEFT") then
				x, y = firstButtonSpacing, -firstButtonSpacing;
			else
				x, y = -firstButtonSpacing, firstButtonSpacing;
			end
			
			button:Point(point, bar, point, x, y);
		elseif((i - 1) % buttonsPerRow == 0) then
			local x = 0;
			local y = -buttonSpacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if(verticalGrowth == "UP") then
				y = buttonSpacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = buttonSpacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if(horizontalGrowth == "LEFT") then
				x = -buttonSpacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end
			
			button:Point(buttonPoint, lastButton, anchorPoint, x, y);
		end
		
		if(i > numButtons) then
			button:SetScale(0.000001);
			button:SetAlpha(0);
		else
			button:SetScale(1);
			button:SetAlpha(1);
		end
	end
	
	if(self.db[barName].enabled or not bar.initialized) then
		if not self.db[barName].mouseover then
			bar:SetAlpha(self.db[barName].alpha);
		end

		local page = self:GetPage(barName, self['barDefaults'][barName].page, self['barDefaults'][barName].conditions);
		bar:Show();
		RegisterStateDriver(bar, "visibility", self.db[barName].visibility);
		RegisterStateDriver(bar, "page", page);
		
		if(not bar.initialized) then
			bar.initialized = true;
			AB:PositionAndSizeBar(barName);
			return;
		end
		E:EnableMover(bar.mover:GetName());
	else
		E:DisableMover(bar.mover:GetName());
		bar:Hide();
		UnregisterStateDriver(bar, "visibility");
	end
	
	E:SetMoverSnapOffset("ElvAB_" .. bar.id, bar.db.buttonspacing / 2);
end

function AB:CreateVehicleLeave()
	local vehicle = CreateFrame("Button", 'LeaveVehicleButton', E.UIParent, "SecureHandlerClickTemplate")
	vehicle:Size(26)
	vehicle:Point("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2)
	vehicle:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetTemplate("Default")
	vehicle:RegisterForClicks("AnyUp")
	vehicle:SetScript("OnClick", function() VehicleExit() end)
	RegisterStateDriver(vehicle, "visibility", "[vehicleui] show;[target=vehicle,exists] show;hide")
end

function AB:UpdateButtonSettings()
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return; end
	for button, _ in pairs(self["handledbuttons"]) do
		if button then
			self:StyleButton(button, button.noBackdrop)
		else
			self["handledbuttons"][button] = nil
		end
	end
	
	for i = 1, 5 do
		self:PositionAndSizeBar("bar" .. i);
	end
	self:PositionAndSizeBarPet();
	self:PositionAndSizeBarShapeShift();
end

function AB:GetPage(bar, defaultPage, condition)
	local page = self.db[bar]['paging'][E.myclass]
	if not condition then condition = '' end
	if not page then page = '' end
	if page then
		condition = condition.." "..page
	end
	condition = condition.." "..defaultPage
	return condition
end

function AB:StyleButton(button, noBackdrop)	
	local name = button:GetName();
	local icon = _G[name.."Icon"];
	local count = _G[name.."Count"];
	local flash	 = _G[name.."Flash"];
	local hotkey = _G[name.."HotKey"];
	local border = _G[name.."Border"];
	local macroName = _G[name.."Name"];
	local normal = _G[name.."NormalTexture"];
	local buttonCooldown = _G[name.."Cooldown"];
	local normal2 = button:GetNormalTexture()
	local combat = InCombatLockdown()
	
	if flash then flash:SetTexture(nil); end
	if normal then normal:SetTexture(nil); normal:Hide(); normal:SetAlpha(0); end
	if normal2 then normal2:SetTexture(nil); normal2:Hide(); normal2:SetAlpha(0); end
	if border then border:Kill(); end
	
	if not button.noBackdrop then
		button.noBackdrop = noBackdrop;
	end
	
	if count then
		count:ClearAllPoints();
		count:SetPoint("BOTTOMRIGHT", 0, 2);
		count:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end
	
	if macroName then
		if self.db.macrotext then
			macroName:Show()
			macroName:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
			macroName:ClearAllPoints()
			macroName:Point('BOTTOM', 2, 2)
			macroName:SetJustifyH('CENTER')
		else
			macroName:Hide()
		end
	end
	
	if not button.noBackdrop and not button.backdrop then
		button:CreateBackdrop('Default', true)
		button.backdrop:SetAllPoints()
	end
	
	if icon then
		icon:SetTexCoord(unpack(E.TexCoords));
		icon:SetInside()
	end
	
	if self.db.hotkeytext then
		hotkey:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end
	
	self:FixKeybindText(button);
	button:StyleButton();
	
	if(not self.handledbuttons[button]) then
		E:RegisterCooldown(buttonCooldown);
		
		self.handledbuttons[button] = true;
	end
end

function AB:Bar_OnEnter(bar)
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.lockTarget and not self.fadeParent.lockCombat) then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1);
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha);
	end
end

function AB:Bar_OnLeave(bar)
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.lockTarget and not self.fadeParent.lockCombat) then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha);
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0);
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.lockTarget and not self.fadeParent.lockCombat) then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1);
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha);
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if(bar:GetParent() == self.fadeParent) then
		if(not self.fadeParent.lockTarget and not self.fadeParent.lockCombat) then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha);
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0);
	end
end

function AB:FadeParent_OnEvent(event, unit)
	if(event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_HEALTH") then
		if(not unit or unit ~= "player") then return; end
	end
	local cur, max = UnitHealth("player"), UnitHealthMax("player");
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player");
	local target, focus = UnitExists("target"), UnitExists("focus");
	local combat = UnitAffectingCombat("player");
	if((cast or channel) or (cur ~= max) or (target or focus) or combat) then
		self.mouseLock = true;
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1);
	else
		self.mouseLock = false;
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 1 - AB.db.globalFadeAlpha);
	end
end

function AB:DisableBlizzard()
	MainMenuBar:SetScale(0.00001);
	MainMenuBar:EnableMouse(false);
	VehicleMenuBar:SetScale(0.00001);
	PetActionBarFrame:EnableMouse(false);
	ShapeshiftBarFrame:EnableMouse(false);
	
	local elements = {
		MainMenuBar, 
		MainMenuBarArtFrame, 
		BonusActionBarFrame, 
		VehicleMenuBar,
		PossessBarFrame, 
		PetActionBarFrame, 
		ShapeshiftBarFrame,
		ShapeshiftBarLeft, 
		ShapeshiftBarMiddle, 
		ShapeshiftBarRight,
	};
	for _, element in pairs(elements) do
		if element:GetObjectType() == "Frame" then
			element:UnregisterAllEvents();
			
			if element == MainMenuBarArtFrame then
				element:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
			end
		end
		
		if element ~= MainMenuBar then
			element:Hide();
		end
		element:SetAlpha(0);
	end
	elements = nil;
	
	local uiManagedFrames = {
		"MultiBarLeft",
		"MultiBarRight",
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"ShapeshiftBarFrame",
		"PossessBarFrame",
		"PETACTIONBAR_YPOS",
		"MultiCastActionBarFrame",
		"MULTICASTACTIONBAR_YPOS",
	};
	for _, frame in pairs(uiManagedFrames) do
		UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil;
	end
	uiManagedFrames = nil;

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function AB:FixKeybindText(button, type)
	local hotkey = _G[button:GetName()..'HotKey'];
	local text = hotkey:GetText();
	
	if text then
		text = gsub(text, 'SHIFT%-', L['KEY_SHIFT']);
		text = gsub(text, 'ALT%-', L['KEY_ALT']);
		text = gsub(text, 'CTRL%-', L['KEY_CTRL']);
		text = gsub(text, 'BUTTON', L['KEY_MOUSEBUTTON']);
		text = gsub(text, 'MOUSEWHEELUP', L['KEY_MOUSEWHEELUP']);
		text = gsub(text, 'MOUSEWHEELDOWN', L['KEY_MOUSEWHEELDOWN']);
		text = gsub(text, 'NUMPAD', L['KEY_NUMPAD']);
		text = gsub(text, 'PAGEUP', L['KEY_PAGEUP']);
		text = gsub(text, 'PAGEDOWN', L['KEY_PAGEDOWN']);
		text = gsub(text, 'SPACE', L['KEY_SPACE']);
		text = gsub(text, 'INSERT', L['KEY_INSERT']);
		text = gsub(text, 'HOME', L['KEY_HOME']);
		text = gsub(text, 'DELETE', L['KEY_DELETE']);
		text = gsub(text, 'NMULTIPLY', "*");
		text = gsub(text, 'NMINUS', "N-");
		text = gsub(text, 'NPLUS', "N+");
		
		if hotkey:GetText() == _G['RANGE_INDICATOR'] then
			hotkey:SetText('');
		else
			hotkey:SetText(text);
		end
	end
	
	if self.db.hotkeytext == true then
		hotkey:Show();
	else
		hotkey:Hide();
	end
	
	hotkey:ClearAllPoints();
	hotkey:Point("TOPRIGHT", 0, -3);	
end

function AB:Initialize()
	self.db = E.db.actionbar
	if E.private.actionbar.enable ~= true then return; end
	E.ActionBars = AB;
	
	self.fadeParent = CreateFrame("Frame", "Elv_ABFade", UIParent);
	self.fadeParent:SetAlpha(1 - self.db.globalFadeAlpha);
	self.fadeParent:RegisterEvent("PLAYER_REGEN_DISABLED");
	self.fadeParent:RegisterEvent("PLAYER_REGEN_ENABLED");
	self.fadeParent:RegisterEvent("PLAYER_TARGET_CHANGED");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_START");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_STOP");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self.fadeParent:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self.fadeParent:RegisterEvent("UNIT_HEALTH");
	self.fadeParent:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self.fadeParent:SetScript("OnEvent", self.FadeParent_OnEvent);
	
	self:DisableBlizzard()
	
	self:SetupMicroBar()
	
	self:CreateActionBars()
	self:CreateVehicleLeave()
	
	self:UpdateButtonSettings()
	self:LoadKeyBinder()
	
	self:SecureHook('ActionButton_Update', 'StyleButton')
	self:SecureHook('PetActionBar_Update', 'UpdatePet')
	self:SecureHook("ActionButton_UpdateHotkeys", "FixKeybindText");
	
	if not GetCVarBool('lockActionBars') then
		SetCVar('lockActionBars', 1)
	end
end

E:RegisterModule(AB:GetName())
local E, L, V, P, G = unpack(select(2, ...));
local S = E:NewModule("Skins", "AceHook-3.0", "AceEvent-3.0");

local _G = _G;
local unpack, assert, pairs, ipairs, select, type, pcall = unpack, assert, pairs, ipairs, select, type, pcall;
local tinsert, wipe = table.insert, table.wipe;

local CreateFrame = CreateFrame;
local SetDesaturation = SetDesaturation;
local hooksecurefunc = hooksecurefunc;
local IsAddOnLoaded = IsAddOnLoaded;
local GetCVarBool = GetCVarBool;

E.Skins = S;
S.addonsToLoad = {};
S.nonAddonsToLoad = {};
S.allowBypass = {};
S.addonCallbacks = {};
S.nonAddonCallbacks = {["CallPriority"] = {}};

local find = string.find;

S.SQUARE_BUTTON_TEXCOORDS = {
	["UP"] = {     0.45312500,    0.64062500,     0.01562500,     0.20312500};
	["DOWN"] = {   0.45312500,    0.64062500,     0.20312500,     0.01562500};
	["LEFT"] = {   0.23437500,    0.42187500,     0.01562500,     0.20312500};
	["RIGHT"] = {  0.42187500,    0.23437500,     0.01562500,     0.20312500};
	["DELETE"] = { 0.01562500,    0.20312500,     0.01562500,     0.20312500}
};

function S:SquareButton_SetIcon(self, name)
	local coords = S.SQUARE_BUTTON_TEXCOORDS[strupper(name)];
	if(coords) then
		self.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	end
end

function S:SetModifiedBackdrop()
	if(self.backdrop) then self = self.backdrop; end
	self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor));
end

function S:SetOriginalBackdrop()
	if(self.backdrop) then self = self.backdrop; end
	self:SetBackdropBorderColor(unpack(E["media"].bordercolor));
end

function S:HandleButton(f, strip)
	local name = f:GetName();
	if(name) then
		local left = _G[name .. "Left"];
		local middle = _G[name .. "Middle"];
		local right = _G[name .. "Right"];

		if(left) then left:Kill(); end
		if(middle) then middle:Kill(); end
		if(right) then right:Kill(); end
	end

	if(f.Left) then f.Left:Kill(); end
	if(f.Middle) then f.Middle:Kill(); end
	if(f.Right) then f.Right:Kill(); end

	if(f.SetNormalTexture) then f:SetNormalTexture(""); end
	if(f.SetHighlightTexture) then f:SetHighlightTexture(""); end
	if(f.SetPushedTexture) then f:SetPushedTexture(""); end
	if(f.SetDisabledTexture) then f:SetDisabledTexture(""); end

	if(strip) then f:StripTextures(); end

	f:SetTemplate("Default", true);
	f:HookScript("OnEnter", S.SetModifiedBackdrop);
	f:HookScript("OnLeave", S.SetOriginalBackdrop);
end

function S:HandleScrollBar(frame, thumbTrim)
	local name = frame:GetName();
	if(_G[name .. "BG"]) then _G[name .. "BG"]:SetTexture(nil); end
	if(_G[name .. "Track"]) then _G[name .. "Track"]:SetTexture(nil); end
	if(_G[name .. "Top"]) then _G[name .. "Top"]:SetTexture(nil); end
	if(_G[name .. "Bottom"]) then _G[name .. "Bottom"]:SetTexture(nil); end
	if(_G[name .. "Middle"]) then _G[name .. "Middle"]:SetTexture(nil); end

	if(_G[name .. "ScrollUpButton"] and _G[name .. "ScrollDownButton"]) then
		_G[name .. "ScrollUpButton"]:StripTextures();
		if(not _G[name .. "ScrollUpButton"].icon) then
			S:HandleNextPrevButton(_G[name .. "ScrollUpButton"]);
			S:SquareButton_SetIcon(_G[name .. "ScrollUpButton"], "UP");
			_G[name .. "ScrollUpButton"]:Size(_G[name .. "ScrollUpButton"]:GetWidth() + 7, _G[name .. "ScrollUpButton"]:GetHeight() + 7);
		end

		_G[name .. "ScrollDownButton"]:StripTextures();
		if(not _G[name .. "ScrollDownButton"].icon) then
			S:HandleNextPrevButton(_G[name .. "ScrollDownButton"]);
			S:SquareButton_SetIcon(_G[name .. "ScrollDownButton"], "DOWN");
			_G[name .. "ScrollDownButton"]:Size(_G[name .. "ScrollDownButton"]:GetWidth() + 7, _G[name .. "ScrollDownButton"]:GetHeight() + 7);
		end

		if(not frame.trackbg) then
			frame.trackbg = CreateFrame("Frame", nil, frame);
			frame.trackbg:Point("TOPLEFT", _G[name .. "ScrollUpButton"], "BOTTOMLEFT", 0, -1);
			frame.trackbg:Point("BOTTOMRIGHT", _G[name .. "ScrollDownButton"], "TOPRIGHT", 0, 1);
			frame.trackbg:SetTemplate("Transparent");
		end

		if(frame:GetThumbTexture()) then
			if(not thumbTrim) then thumbTrim = 3; end
			frame:GetThumbTexture():SetTexture(nil);
			if(not frame.thumbbg) then
				frame.thumbbg = CreateFrame("Frame", nil, frame);
				frame.thumbbg:Point("TOPLEFT", frame:GetThumbTexture(), "TOPLEFT", 2, -thumbTrim);
				frame.thumbbg:Point("BOTTOMRIGHT", frame:GetThumbTexture(), "BOTTOMRIGHT", -2, thumbTrim);
				frame.thumbbg:SetTemplate("Default", true, true);
				frame.thumbbg:SetBackdropColor(0.6, 0.6, 0.6);
				if(frame.trackbg) then
					frame.thumbbg:SetFrameLevel(frame.trackbg:GetFrameLevel()+1);
				end
			end
		end
	end
end

local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right"
};

function S:HandleTab(tab)
	local name = tab:GetName();
	for _, object in pairs(tabs) do
		local tex = _G[name .. object];
		if(tex) then
			tex:SetTexture(nil);
		end
	end

	if(tab.GetHighlightTexture and tab:GetHighlightTexture()) then
		tab:GetHighlightTexture():SetTexture(nil);
	else
		tab:StripTextures();
	end

	tab.backdrop = CreateFrame("Frame", nil, tab);
	tab.backdrop:SetTemplate("Default");
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1);
	tab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -1 or -3);
	tab.backdrop:Point("BOTTOMRIGHT", -10, 3);
end

function S:HandleNextPrevButton(btn, buttonOverride)
	local inverseDirection = btn:GetName() and (find(btn:GetName():lower(), "left") or find(btn:GetName():lower(), "prev") or find(btn:GetName():lower(), "decrement") or find(btn:GetName():lower(), "promote"));

	btn:StripTextures();
	btn:SetNormalTexture(nil);
	btn:SetPushedTexture(nil);
	btn:SetHighlightTexture(nil);
	btn:SetDisabledTexture(nil);

	if(not btn.icon) then
		btn.icon = btn:CreateTexture(nil, "ARTWORK");
		btn.icon:Size(13);
		btn.icon:SetPoint("CENTER");
		btn.icon:SetTexture([[Interface\AddOns\ElvUI\media\textures\SquareButtonTextures.blp]]);
		btn.icon:SetTexCoord(0.01562500, 0.20312500, 0.01562500, 0.20312500);

		btn:SetScript("OnMouseDown", function(self)
			if(btn:IsEnabled() == 1) then
				self.icon:SetPoint("CENTER", -1, -1);
			end
		end);

		btn:SetScript("OnMouseUp", function(self)
			self.icon:SetPoint("CENTER", 0, 0);
		end);

		btn:SetScript("OnDisable", function(self)
			SetDesaturation(self.icon, true);
			self.icon:SetAlpha(0.5);
		end);

		btn:SetScript("OnEnable", function(self)
			SetDesaturation(self.icon, false);
			self.icon:SetAlpha(1.0);
		end);

		if(btn:IsEnabled() == 0) then
			btn:GetScript("OnDisable")(btn);
		end
	end

	if(buttonOverride) then
		if(inverseDirection) then
			S:SquareButton_SetIcon(btn, "UP");
		else
			S:SquareButton_SetIcon(btn, "DOWN");
		end
	else
		if(inverseDirection) then
			S:SquareButton_SetIcon(btn, "LEFT");
		else
			S:SquareButton_SetIcon(btn, "RIGHT");
		end
	end

	S:HandleButton(btn);
	btn:Size(btn:GetWidth() - 7, btn:GetHeight() - 7);
end

function S:HandleRotateButton(btn)
	btn:SetTemplate("Default");
	btn:Size(btn:GetWidth() - 14, btn:GetHeight() - 14);

	btn:GetNormalTexture():SetTexCoord(0.27, 0.73, 0.27, 0.68);
	btn:GetPushedTexture():SetTexCoord(0.27, 0.73, 0.27, 0.68);

	btn:GetHighlightTexture():SetTexture(1, 1, 1, 0.3);

	btn:GetNormalTexture():SetInside();
	btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture());
	btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture());
end

function S:HandleEditBox(frame)
	frame:CreateBackdrop("Default");
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel());

	if(frame:GetName()) then
		if(_G[frame:GetName() .. "Left"]) then _G[frame:GetName() .. "Left"]:Kill(); end
		if(_G[frame:GetName() .. "Middle"]) then _G[frame:GetName() .. "Middle"]:Kill(); end
		if(_G[frame:GetName() .. "Right"]) then _G[frame:GetName() .. "Right"]:Kill(); end
		if(_G[frame:GetName() .. "Mid"]) then _G[frame:GetName() .. "Mid"]:Kill(); end

		if(frame:GetName():find("Silver") or frame:GetName():find("Copper")) then
			frame.backdrop:Point("BOTTOMRIGHT", -12, -2);
		end
	end
end

function S:HandleDropDownBox(frame, width)
	local button = _G[frame:GetName() .. "Button"];
	if(not button) then return; end

	if(not width) then width = 155; end

	frame:StripTextures();
	frame:Width(width);

	if(_G[frame:GetName() .. "Text"]) then
		_G[frame:GetName() .. "Text"]:ClearAllPoints();
		_G[frame:GetName() .. "Text"]:Point("RIGHT", button, "LEFT", -2, 0);
	end

	if(button) then
		button:ClearAllPoints();
		button:Point("RIGHT", frame, "RIGHT", -10, 3);
		hooksecurefunc(button, "SetPoint", function(_, _, _, _, _, _, noReset)
			if(not noReset) then
				button:ClearAllPoints();
				button:SetPoint("RIGHT", frame, "RIGHT", E:Scale(-10), E:Scale(3), true);
			end
		end);

		self:HandleNextPrevButton(button, true);
	end
	frame:CreateBackdrop("Default");
	frame.backdrop:Point("TOPLEFT", 20, -2);
	frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2);
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel());
end

function S:HandleCheckBox(frame, noBackdrop)
	assert(frame, "does not exist.");
	frame:StripTextures();
	if(noBackdrop) then
		frame:SetTemplate("Default");
		frame:Size(16);
	else
		frame:CreateBackdrop("Default");
		frame.backdrop:SetInside(nil, 4, 4);
	end

	if(frame.SetCheckedTexture) then
		frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		if(noBackdrop) then
			frame:GetCheckedTexture():SetInside(nil, -4, -4);
		end
	end

	if(frame.SetDisabledTexture) then
		frame:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
		if(noBackdrop) then
			frame:GetDisabledTexture():SetInside(nil, -4, -4);
		end
	end

	frame:HookScript("OnDisable", function(self)
		if(not self.SetDisabledTexture) then return; end
		if(self:GetChecked()) then
			self:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
		else
			self:SetDisabledTexture("");
		end
	end);

	hooksecurefunc(frame, "SetNormalTexture", function(self, texPath)
		if(texPath ~= "") then
			self:SetNormalTexture("");
		end
	end);

	hooksecurefunc(frame, "SetPushedTexture", function(self, texPath)
		if(texPath ~= "") then
			self:SetPushedTexture("");
		end
	end);

	hooksecurefunc(frame, "SetHighlightTexture", function(self, texPath)
		if(texPath ~= "") then
			self:SetHighlightTexture("");
		end
	end);
end

function S:HandleIcon(icon, parent)
	parent = parent or icon:GetParent();

	icon:SetTexCoord(unpack(E.TexCoords));
	parent:CreateBackdrop("Default");
	icon:SetParent(parent.backdrop);
	parent.backdrop:SetOutside(icon);
end

function S:HandleItemButton(b, shrinkIcon)
	if(b.isSkinned) then return; end

	local icon = b.icon or b.IconTexture or b.iconTexture;
	local texture;
	if(b:GetName() and _G[b:GetName() .. "IconTexture"]) then
		icon = _G[b:GetName() .. "IconTexture"];
	elseif(b:GetName() and _G[b:GetName() .. "Icon"]) then
		icon = _G[b:GetName() .. "Icon"];
	end

	if(icon and icon:GetTexture()) then
		texture = icon:GetTexture();
	end

	b:StripTextures();
	b:CreateBackdrop("Default", true);
	b:StyleButton();

	if(icon) then
		icon:SetTexCoord(unpack(E.TexCoords));

		if(shrinkIcon) then
			b.backdrop:SetAllPoints();
			icon:SetInside(b);
		else
			b.backdrop:SetOutside(icon);
		end
		icon:SetParent(b.backdrop);

		if(texture) then
			icon:SetTexture(texture);
		end
	end
	b.isSkinned = true;
end

function S:HandleCloseButton(f, point, text)
	f:StripTextures();

	if(f:GetNormalTexture()) then f:SetNormalTexture(""); f.SetNormalTexture = E.noop; end
	if(f:GetPushedTexture()) then f:SetPushedTexture(""); f.SetPushedTexture = E.noop; end

	if(not f.backdrop) then
		f:CreateBackdrop("Default", true);
		f.backdrop:Point("TOPLEFT", 7, -8);
		f.backdrop:Point("BOTTOMRIGHT", -8, 8);
		f:HookScript("OnEnter", S.SetModifiedBackdrop);
		f:HookScript("OnLeave", S.SetOriginalBackdrop);
	end
	if(not text) then text = "x"; end
	if(not f.text) then
		f.text = f:CreateFontString(nil, "OVERLAY");
		f.text:SetFont([[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], 16, "OUTLINE");
		f.text:SetText(text);
		f.text:SetJustifyH("CENTER");
		f.text:SetPoint("CENTER", f, "CENTER", -1, 1);
	end

	if(point) then
		f:Point("TOPRIGHT", point, "TOPRIGHT", 2, 2);
	end
end

function S:HandleSliderFrame(frame)
	local orientation = frame:GetOrientation();
	local SIZE = 12;
	frame:StripTextures();
	frame:CreateBackdrop("Default");
	frame.backdrop:SetAllPoints();
	hooksecurefunc(frame, "SetBackdrop", function(_, backdrop)
		if(backdrop ~= nil) then
			frame:SetBackdrop(nil);
		end
	end);
	frame:SetThumbTexture(E["media"].blankTex);
	frame:GetThumbTexture():SetVertexColor(0.3, 0.3, 0.3);
	frame:GetThumbTexture():Size(SIZE-2,SIZE-2);
	if(orientation == "VERTICAL") then
		frame:Width(SIZE);
	else
		frame:Height(SIZE);

		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions());
			if(region and region:GetObjectType() == "FontString") then
				local point, anchor, anchorPoint, x, y = region:GetPoint();
				if(anchorPoint:find("BOTTOM")) then
					region:Point(point, anchor, anchorPoint, x, y - 4);
				end
			end
		end
	end
end

function S:HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, frameNameOverride)
	assert(frame, "HandleIconSelectionFrame: frame argument missing");
	assert(numIcons and type(numIcons) == "number", "HandleIconSelectionFrame: numIcons argument missing or not a number");
	assert(buttonNameTemplate and type(buttonNameTemplate) == "string", "HandleIconSelectionFrame: buttonNameTemplate argument missing or not a string");

	local frameName = frameNameOverride or frame:GetName(); --We need override in case Blizzard fucks up the naming (guild bank)
	local scrollFrame = _G[frameName .. "ScrollFrame"];
	local editBox = _G[frameName .. "EditBox"];
	local okayButton = _G[frameName .. "OkayButton"] or _G[frameName .. "Okay"];
	local cancelButton = _G[frameName .. "CancelButton"] or _G[frameName .. "Cancel"];

	frame:StripTextures();
	scrollFrame:StripTextures();
	editBox:DisableDrawLayer("BACKGROUND"); --Removes textures around it

	frame:CreateBackdrop("Transparent");
	frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", 10, -12);
	frame.backdrop:Point("BOTTOMRIGHT", cancelButton, "BOTTOMRIGHT", 5, -5);

	S:HandleButton(okayButton);
	S:HandleButton(cancelButton);
	S:HandleEditBox(editBox);

	for i = 1, numIcons do
		local button = _G[buttonNameTemplate .. i];
		local icon = _G[button:GetName() .. "Icon"];
		button:StripTextures();
		button:SetTemplate("Default");
		button:StyleButton(nil, true);
		icon:SetInside();
		icon:SetTexCoord(unpack(E.TexCoords));
	end
end

function S:ADDON_LOADED(event, addon)
	if(self.allowBypass[addon]) then
		if(self.addonsToLoad[addon]) then
			--Load addons using the old deprecated register method
			self.addonsToLoad[addon]();
			self.addonsToLoad[addon] = nil;
		elseif(self.addonCallbacks[addon]) then
			--Fire events to the skins that rely on this addon
			for index, event in ipairs(self.addonCallbacks[addon]["CallPriority"]) do
				self.addonCallbacks[addon][event] = nil;
				self.addonCallbacks[addon]["CallPriority"][index] = nil;
				E.callbacks:Fire(event);
			end
		end
		return;
	end

	if(not E.initialized) then return; end

	if(self.addonsToLoad[addon]) then
		self.addonsToLoad[addon]();
		self.addonsToLoad[addon] = nil;
	elseif self.addonCallbacks[addon] then
		for index, event in ipairs(self.addonCallbacks[addon]["CallPriority"]) do
			self.addonCallbacks[addon][event] = nil;
			self.addonCallbacks[addon]["CallPriority"][index] = nil;
			E.callbacks:Fire(event);
		end
	end
end

--Old deprecated register function. Keep it for the time being for any plugins that may need it.
function S:RegisterSkin(name, loadFunc, forceLoad, bypass)
	if(bypass) then
		self.allowBypass[name] = true;
	end

	if(forceLoad) then
		loadFunc();
		self.addonsToLoad[name] = nil;
	elseif(name == "ElvUI") then
		tinsert(self.nonAddonsToLoad, loadFunc);
	else
		self.addonsToLoad[name] = loadFunc;
	end
end

--Add callback for skin that relies on another addon.
--These events will be fired when the addon is loaded.
function S:AddCallbackForAddon(addonName, eventName, loadFunc, forceLoad, bypass)
	if(not addonName or type(addonName) ~= "string") then
		E:Print("Invalid argument #1 to S:AddCallbackForAddon (string expected)");
		return
	elseif(not eventName or type(eventName) ~= "string") then
		E:Print("Invalid argument #2 to S:AddCallbackForAddon (string expected)");
		return
	elseif(not loadFunc or type(loadFunc) ~= "function") then
		E:Print("Invalid argument #3 to S:AddCallbackForAddon (function expected)");
		return;
	end

	if(bypass) then
		self.allowBypass[addonName] = true;
	end

	--Create an event registry for this addon, so that we can fire multiple events when this addon is loaded
	if(not self.addonCallbacks[addonName]) then
		self.addonCallbacks[addonName] = {["CallPriority"] = {}};
	end

	if self.addonCallbacks[addonName][eventName] or E.ModuleCallbacks[eventName] or E.InitialModuleCallbacks[eventName] then
		--Don't allow a registered callback to be overwritten
		E:Print("Invalid argument #2 to S:AddCallbackForAddon (event name:", eventName, "is already registered, please use a unique event name)")
		return;
	end

	--Register loadFunc to be called when event is fired
	E.RegisterCallback(E, eventName, loadFunc);

	if(forceLoad) then
		E.callbacks:Fire(eventName);
	else
		--Insert eventName in this addons' registry
		self.addonCallbacks[addonName][eventName] = true;
		self.addonCallbacks[addonName]["CallPriority"][#self.addonCallbacks[addonName]["CallPriority"] + 1] = eventName;
	end
end

--Add callback for skin that does not rely on a another addon.
--These events will be fired when the Skins module is initialized.
function S:AddCallback(eventName, loadFunc)
	if(not eventName or type(eventName) ~= "string") then
		E:Print("Invalid argument #1 to S:AddCallback (string expected)");
		return
	elseif(not loadFunc or type(loadFunc) ~= "function") then
		E:Print("Invalid argument #2 to S:AddCallback (function expected)");
		return;
	end

	if self.nonAddonCallbacks[eventName] or E.ModuleCallbacks[eventName] or E.InitialModuleCallbacks[eventName] then
		--Don't allow a registered callback to be overwritten
		E:Print("Invalid argument #1 to S:AddCallback (event name:", eventName, "is already registered, please use a unique event name)")
		return;
	end

	--Add event name to registry
	self.nonAddonCallbacks[eventName] = true;
	self.nonAddonCallbacks["CallPriority"][#self.nonAddonCallbacks["CallPriority"] + 1] = eventName;

	--Register loadFunc to be called when event is fired
	E.RegisterCallback(E, eventName, loadFunc);
end

function S:Initialize()
	self.db = E.private.skins;

	--Fire events for Blizzard addons that are already loaded
	for addon in pairs(self.addonCallbacks) do
		if(IsAddOnLoaded(addon)) then
			for index, event in ipairs(self.addonCallbacks[addon]["CallPriority"]) do
				self.addonCallbacks[addon][event] = nil;
				self.addonCallbacks[addon]["CallPriority"][index] = nil;
				E.callbacks:Fire(event);
			end
		end
	end
	--Fire event for all skins that doesn't rely on a Blizzard addon
	for index, event in ipairs(self.nonAddonCallbacks["CallPriority"]) do
		self.nonAddonCallbacks[event] = nil;
		self.nonAddonCallbacks["CallPriority"][index] = nil;
		E.callbacks:Fire(event);
	end

	--Old deprecated load functions. We keep this for the time being in case plugins make use of it.
	for addon, loadFunc in pairs(self.addonsToLoad) do
		if(IsAddOnLoaded(addon)) then
			self.addonsToLoad[addon] = nil;
			local _, catch = pcall(loadFunc);
			if(catch and GetCVarBool("scriptErrors") == true) then
				ScriptErrorsFrame_OnError(catch, false);
			end
		end
	end

	for _, loadFunc in pairs(self.nonAddonsToLoad) do
		local _, catch = pcall(loadFunc)
		if(catch and GetCVarBool("scriptErrors") == true) then
			ScriptErrorsFrame_OnError(catch, false);
		end
	end
	wipe(self.nonAddonsToLoad);
end

S:RegisterEvent("ADDON_LOADED");

local function InitializeCallback()
	S:Initialize()
end

E:RegisterModule(S:GetName(), InitializeCallback)
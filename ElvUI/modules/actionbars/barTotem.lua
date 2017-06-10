local E, L, V, P, G = unpack(select(2, ...));
local AB = E:GetModule("ActionBars");

local _G = _G;
local unpack = unpack;
local ipairs, pairs = ipairs, pairs;
local tonumber = tonumber;
local match = string.match;

local HasMultiCastActionBar = HasMultiCastActionBar;

if(E.myclass ~= "SHAMAN") then return; end

local bar = CreateFrame("Frame", "ElvUI_BarTotem", E.UIParent, "SecureHandlerStateTemplate");
bar:SetFrameLevel(115);

local bordercolors = {
	{.23, .45, .13},
	{.58, .23, .10},
	{.19, .48, .60},
	{.42, .18, .74},
	{.39, .39, .12}
};

local SLOT_EMPTY_TCOORDS = {
	[EARTH_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 3 / 256,
		bottom	= 33 / 256
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 67 / 128,
		right	= 97 / 128,
		top		= 100 / 256,
		bottom	= 130 / 256
	},
	[WATER_TOTEM_SLOT] = {
		left	= 39 / 128,
		right	= 69 / 128,
		top		= 209 / 256,
		bottom	= 239 / 256
	},
	[AIR_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 36 / 256,
		bottom	= 66 / 256
	}
};

function AB:MultiCastFlyoutFrameOpenButton_Show(button, _, parent)
	button.backdrop:SetBackdropBorderColor(parent:GetBackdropBorderColor());
end

function AB:MultiCastActionButton_Update(button, _, index)
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 5) + 1]));
	if(InCombatLockdown()) then bar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end
	button:ClearAllPoints();
	button:SetAllPoints(button.slotButton);
end

function AB:StyleTotemSlotButton(button, index)
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 5) + 1]));
end

function AB:SkinSummonButton(button)
	local name = button:GetName();
	local icon = _G[name .. "Icon"];
	local highlight = _G[name .. "Highlight"];
	local normal = _G[name .. "NormalTexture"];

	button:SetTemplate("Default");
	button:StyleButton();

	icon:SetTexCoord(unpack(E.TexCoords));
	icon:SetDrawLayer("ARTWORK");
	icon:SetInside(button);

	highlight:SetTexture(nil);
	normal:SetTexture(nil);
end

function AB:MultiCastFlyoutFrame_ToggleFlyout(self, type, parent)
	self.top:SetTexture(nil);
	self.middle:SetTexture(nil);

	local numButtons = 0;
	for i, button in ipairs(self.buttons) do
		if(not button.isSkinned) then
			button:SetTemplate("Default");
			button:StyleButton();

			button.icon:SetTexCoord(unpack(E.TexCoords));
			button.icon:SetDrawLayer("ARTWORK");
			button.icon:SetInside(button);
			bar.buttons[button] = true;
			AB:AdjustTotemSettings();
		end

		if(button:IsShown()) then
			numButtons = numButtons + 1;
			button:Size(AB.db["barTotem"].buttonsize);
			if(i == 1) then
				button:Point("BOTTOM", parent, "TOP", 0, AB.db["barTotem"].buttonspacing);
			else
				button:Point("BOTTOM", self.buttons[i-1], "TOP", 0, AB.db["barTotem"].buttonspacing);
			end

			button:SetBackdropBorderColor(parent:GetBackdropBorderColor());
		end
	end

	if(type == "slot") then
		local tCoords = SLOT_EMPTY_TCOORDS[parent:GetID()];
		self.buttons[1].icon:SetTexCoord(tCoords.left, tCoords.right, tCoords.top, tCoords.bottom);
	end

	MultiCastFlyoutFrameCloseButton.backdrop:SetBackdropBorderColor(parent:GetBackdropBorderColor());
	self:Height(((AB.db["barTotem"].buttonsize + AB.db["barTotem"].buttonspacing) * numButtons) + MultiCastFlyoutFrameCloseButton:GetHeight());
end

function AB:MultiCastRecallSpellButton_Update(self)
	if(InCombatLockdown()) then bar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end
	if(HasMultiCastActionBar()) then
		local activeSlots = MultiCastActionBarFrame.numActiveSlots;
		if(activeSlots > 0) then
			self:ClearAllPoints();
			self:SetPoint("LEFT", _G["MultiCastSlotButton" .. activeSlots], "RIGHT", AB.db["barTotem"].buttonspacing, 0);
		end
	end
end

function AB:TotemOnEnter()
	E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), self.db["barTotem"].alpha)
end

function AB:TotemOnLeave()
	E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
end

function AB:AdjustTotemSettings()
	local combat = InCombatLockdown()

	if self.db["barTotem"].enabled and not combat then
		bar:Show()
	elseif not combat then
		bar:Hide()
	end

	if(self.db["barTotem"].inheritGlobalFade) then
		bar:SetParent(self.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end

	for button, _ in pairs(bar.buttons) do
		if self.db["barTotem"].mouseover == true then
			bar:SetAlpha(0)
			if not self.hooks[bar] then
				self:HookScript(bar, "OnEnter", "TotemOnEnter")
				self:HookScript(bar, "OnLeave", "TotemOnLeave")
			end

			if not self.hooks[button] then
				self:HookScript(button, "OnEnter", "TotemOnEnter")
				self:HookScript(button, "OnLeave", "TotemOnLeave")
			end
		else
			bar:SetAlpha(self.db["barTotem"].alpha)
			if self.hooks[bar] then
				self:Unhook(bar, "OnEnter")
				self:Unhook(bar, "OnLeave")
			end

			if self.hooks[button] then
				self:Unhook(button, "OnEnter")
				self:Unhook(button, "OnLeave")
			end
		end
	end
end

function AB:ShowMultiCastActionBar()
	self:PositionAndSizeBarTotem();
end

function AB:PositionAndSizeBarTotem()
	local buttonSpacing = E:Scale(self.db["barTotem"].buttonspacing);
	local size = E:Scale(self.db["barTotem"].buttonsize);
	local numActiveSlots = MultiCastActionBarFrame.numActiveSlots;

	bar:Width((size * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1)));
	MultiCastActionBarFrame:Width((size * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1)));
	bar:Height(size);
	MultiCastActionBarFrame:Height(size);
	bar.db = self.db["barTotem"];

	MultiCastSummonSpellButton:ClearAllPoints();
	MultiCastSummonSpellButton:Size(size);
	MultiCastSummonSpellButton:Point("BOTTOMLEFT", E.Border*2, E.Border*2);

	for i = 1, numActiveSlots do
		local button = _G["MultiCastSlotButton" .. i];
		local lastButton = _G["MultiCastSlotButton" .. i-1];
		button:ClearAllPoints();
		button:Size(size);

		if(i == 1) then
			button:Point("LEFT", MultiCastSummonSpellButton, "RIGHT", buttonSpacing, 0);
		else
			button:Point("LEFT", lastButton, "RIGHT", buttonSpacing, 0);
		end
	end

	MultiCastRecallSpellButton:SetSize(size, size);
	self:MultiCastRecallSpellButton_Update(MultiCastRecallSpellButton);

	MultiCastFlyoutFrameCloseButton:Width(size);

	MultiCastFlyoutFrameOpenButton:Width(size);
end

function AB:CreateTotemBar()
	bar:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 250);
	bar.buttons = {};

	bar.eventFrame = CreateFrame("Frame");
	bar.eventFrame:Hide();
	bar.eventFrame:SetScript("OnEvent", function(self)
		AB:PositionAndSizeBarTotem();
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	end);

	MultiCastActionBarFrame:SetParent(bar);
	MultiCastActionBarFrame:ClearAllPoints();
	MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -E.Border, -E.Border);
	MultiCastActionBarFrame:SetScript("OnUpdate", nil);
	MultiCastActionBarFrame:SetScript("OnShow", nil);
	MultiCastActionBarFrame:SetScript("OnHide", nil);
	MultiCastActionBarFrame.SetParent = E.noop;
	MultiCastActionBarFrame.SetPoint = E.noop;

	local closeButton = MultiCastFlyoutFrameCloseButton;
	bar.buttons[MultiCastFlyoutFrameCloseButton] = true;
	closeButton:CreateBackdrop("Default", true, true);
	closeButton.backdrop:SetPoint("TOPLEFT", 0, -(E.Border + E.Spacing));
	closeButton.backdrop:SetPoint("BOTTOMRIGHT", 0, E.Border + E.Spacing);

	closeButton.normalTexture:SetTexture("");

	closeButton:StyleButton();
	closeButton.hover:SetInside(closeButton.backdrop);
	closeButton.pushed:SetInside(closeButton.backdrop);

	local openButton = MultiCastFlyoutFrameOpenButton;
	bar.buttons[openButton] = true;
	openButton:CreateBackdrop("Default", true, true);
	openButton.backdrop:SetPoint("TOPLEFT", 0, -(E.Border + E.Spacing));
	openButton.backdrop:SetPoint("BOTTOMRIGHT", 0, E.Border + E.Spacing);

	openButton.normalTexture:SetTexture("");

	openButton:StyleButton();
	openButton.hover:SetInside(openButton.backdrop);
	openButton.pushed:SetInside(openButton.backdrop);

	self:SkinSummonButton(MultiCastSummonSpellButton);
	bar.buttons[MultiCastSummonSpellButton] = true;

	for i = 1, 4 do
		local button = _G["MultiCastSlotButton" .. i];
		button:StyleButton();
		button:SetTemplate("Default");
		button.background:SetTexCoord(unpack(E.TexCoords));
		button.background:SetDrawLayer("ARTWORK");
		button.background:SetInside(button);
		button.overlay:SetTexture(nil);
		bar.buttons[button] = true;
	end

	for i = 1, 12 do
		local button = _G["MultiCastActionButton" .. i];
		local icon = _G["MultiCastActionButton" .. i .. "Icon"];
		local normal = _G["MultiCastActionButton" .. i .. "NormalTexture"];
		local cooldown = _G["MultiCastActionButton" .. i .. "Cooldown"];
		button:StyleButton();
		button:SetTemplate("Default");
		icon:SetTexCoord(unpack(E.TexCoords));
		icon:SetDrawLayer("ARTWORK");
		icon:SetInside();
		button.overlay:SetTexture(nil);
		normal:Size(1)
		E:RegisterCooldown(cooldown);
		bar.buttons[button] = true;
	end

	self:SkinSummonButton(MultiCastRecallSpellButton);
	bar.buttons[MultiCastRecallSpellButton] = true;

	self:SecureHook("MultiCastFlyoutFrameOpenButton_Show");
	self:SecureHook("MultiCastActionButton_Update");

	self:SecureHook("MultiCastSlotButton_Update", function(self) AB:StyleTotemSlotButton(self, tonumber(match(self:GetName(), "MultiCastSlotButton(%d)"))); end);
	self:SecureHook("MultiCastFlyoutFrame_ToggleFlyout");
	self:SecureHook("MultiCastRecallSpellButton_Update");
	self:SecureHook("ShowMultiCastActionBar");

	E:CreateMover(bar, "ElvBar_Totem", L["Totems"], nil, nil, nil,"ALL,ACTIONBARS");
	self:AdjustTotemSettings();
end
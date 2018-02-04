local E, L, V, P, G = unpack(select(2, ...));
local AB = E:GetModule("ActionBars");

local _G = _G;
local unpack = unpack;
local ipairs, pairs = ipairs, pairs;
local tonumber = tonumber;
local match = string.match;

local HasMultiCastActionBar = HasMultiCastActionBar;
local RegisterStateDriver = RegisterStateDriver

if(E.myclass ~= "SHAMAN") then return; end

local bar = CreateFrame("Frame", "ElvUI_BarTotem", E.UIParent, "SecureHandlerStateTemplate");
bar:SetFrameLevel(115);

local SLOT_BORDER_COLORS = {
	["summon"]			= {r = 0, g = 0, b = 0},
	[EARTH_TOTEM_SLOT]	= {r = 0.23, g = 0.45, b = 0.13},
	[FIRE_TOTEM_SLOT]	= {r = 0.58, g = 0.23, b = 0.10},
	[WATER_TOTEM_SLOT]	= {r = 0.19, g = 0.48, b = 0.60},
	[AIR_TOTEM_SLOT]	= {r = 0.42, g = 0.18, b = 0.74}
}

local SLOT_EMPTY_TCOORDS = {
	[EARTH_TOTEM_SLOT]	= {left = 66/128, right = 96/128, top = 3/256, bottom = 33/256},
	[FIRE_TOTEM_SLOT]	= {left = 67/128, right = 97/128, top = 100/256, bottom = 130/256},
	[WATER_TOTEM_SLOT]	= {left = 39/128, right = 69/128, top = 209/256, bottom = 239/256},
	[AIR_TOTEM_SLOT]	= {left = 66/128, right = 96/128, top = 36/256, bottom = 66/256}
};

function AB:MultiCastFlyoutFrameOpenButton_Show(button, type, parent)
	local color
	if type == "page" then
		color = SLOT_BORDER_COLORS["summon"]
	else
		color = SLOT_BORDER_COLORS[parent:GetID()]
	end

	button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b);

	button:ClearAllPoints()
	if AB.db["barTotem"].flyoutDirection == "UP" then
		button:Point("BOTTOM", parent, "TOP")
		button.icon:SetTexCoord(0.45312500, 0.64062500, 0.01562500, 0.20312500)
	elseif AB.db["barTotem"].flyoutDirection == "DOWN" then
		button:Point("TOP", parent, "BOTTOM")
		button.icon:SetTexCoord(0.45312500, 0.64062500, 0.20312500, 0.01562500)
	end
end

function AB:MultiCastActionButton_Update(button, _, index, slot)
	local color = SLOT_BORDER_COLORS[slot]
	if color then
		button:SetBackdropBorderColor(color.r, color.g, color.b);
	end

	if(InCombatLockdown()) then bar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end
	button:ClearAllPoints();
	button:SetAllPoints(button.slotButton);
end

function AB:StyleTotemSlotButton(button, slot)
    local color = SLOT_BORDER_COLORS[slot]
	if color then
		button:SetBackdropBorderColor(color.r, color.g, color.b);
		button.ignoreBorderColors = true
	end
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

	local color
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
			button:ClearAllPoints()

			if AB.db["barTotem"].flyoutDirection == "UP" then
				if i == 1 then
					button:Point("BOTTOM", parent, "TOP", 0, AB.db["barTotem"].flyoutSpacing)
				else
					button:Point("BOTTOM", self.buttons[i - 1], "TOP", 0, AB.db["barTotem"].flyoutSpacing)
				end
			elseif AB.db["barTotem"].flyoutDirection == "DOWN" then
				if i == 1 then
					button:Point("TOP", parent, "BOTTOM", 0, -AB.db["barTotem"].flyoutSpacing)
				else
					button:Point("TOP", self.buttons[i - 1], "BOTTOM", 0, -AB.db["barTotem"].flyoutSpacing)
				end
			end

 			if type == "page" then
				color = SLOT_BORDER_COLORS["summon"]
			else
				color = SLOT_BORDER_COLORS[parent:GetID()]
			end
			button:SetBackdropBorderColor(color.r, color.g, color.b);
		end
	end

	if type == "slot" then
		local tCoords = SLOT_EMPTY_TCOORDS[parent:GetID()];
		self.buttons[1].icon:SetTexCoord(tCoords.left, tCoords.right, tCoords.top, tCoords.bottom);

		color = SLOT_BORDER_COLORS[parent:GetID()];
		self.buttons[1]:SetBackdropBorderColor(color.r, color.g, color.b);
	elseif type == "page" then
		color = SLOT_BORDER_COLORS["summon"]
	end

	MultiCastFlyoutFrameCloseButton.backdrop:SetBackdropBorderColor(color.r, color.g, color.b);

	self:ClearAllPoints()
	MultiCastFlyoutFrameCloseButton:ClearAllPoints()
	if AB.db["barTotem"].flyoutDirection == "UP" then
		self:Point("BOTTOM", parent, "TOP")
		MultiCastFlyoutFrameCloseButton:Point("TOP", self, "TOP")
		MultiCastFlyoutFrameCloseButton.icon:SetTexCoord(0.45312500, 0.64062500, 0.20312500, 0.01562500)
	elseif AB.db["barTotem"].flyoutDirection == "DOWN" then
		self:Point("TOP", parent, "BOTTOM")
		MultiCastFlyoutFrameCloseButton:Point("BOTTOM", self, "BOTTOM")
		MultiCastFlyoutFrameCloseButton.icon:SetTexCoord(0.45312500, 0.64062500, 0.01562500, 0.20312500)
	end

	self:Height(((AB.db["barTotem"].buttonsize + AB.db["barTotem"].flyoutSpacing) * numButtons) + MultiCastFlyoutFrameCloseButton:GetHeight());
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
	if self.db["barTotem"].enabled and not InCombatLockdown() then
		bar:Show()
	elseif not InCombatLockdown() then
		bar:Hide()
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
	if InCombatLockdown() then
		AB.NeedsPositionAndSizeBarTotem = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local buttonSpacing = E:Scale(self.db["barTotem"].buttonspacing);
	local size = E:Scale(self.db["barTotem"].buttonsize);
	local numActiveSlots = MultiCastActionBarFrame.numActiveSlots;

	bar:Width((size * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1)));
	MultiCastActionBarFrame:Width((size * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1)));
	bar:Height(size);
	MultiCastActionBarFrame:Height(size);
	bar.db = self.db["barTotem"];

	local visibility = bar.db.visibility
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]","")
	end

	RegisterStateDriver(bar, "visibility", visibility)

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

	closeButton.icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.icon:SetSize(14, 14)
	closeButton.icon:SetPoint("CENTER")
	closeButton.icon:SetTexture([[Interface\AddOns\ElvUI\media\textures\SquareButtonTextures.blp]])

	closeButton.normalTexture:SetTexture("");

	closeButton:StyleButton();
	closeButton.hover:SetInside(closeButton.backdrop);
	closeButton.pushed:SetInside(closeButton.backdrop);

	local openButton = MultiCastFlyoutFrameOpenButton;
	bar.buttons[openButton] = true;
	openButton:CreateBackdrop("Default", true, true);
	openButton.backdrop:SetPoint("TOPLEFT", 0, -(E.Border + E.Spacing));
	openButton.backdrop:SetPoint("BOTTOMRIGHT", 0, E.Border + E.Spacing);

	openButton.icon = openButton:CreateTexture(nil, "ARTWORK")
	openButton.icon:SetSize(14, 14)
	openButton.icon:SetPoint("CENTER")
	openButton.icon:SetTexture([[Interface\AddOns\ElvUI\media\textures\SquareButtonTextures.blp]])

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

	self:SecureHook("MultiCastSlotButton_Update", "StyleTotemSlotButton")
	self:SecureHook("MultiCastFlyoutFrame_ToggleFlyout");
	self:SecureHook("MultiCastRecallSpellButton_Update");
	self:SecureHook("ShowMultiCastActionBar");

	E:CreateMover(bar, "ElvBar_Totem", TUTORIAL_TITLE47, nil, nil, nil,"ALL,ACTIONBARS");
	self:AdjustTotemSettings();
end
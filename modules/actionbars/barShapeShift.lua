local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars");

local _G = _G;
local ceil = math.ceil;
local lower = string.lower;

local CreateFrame = CreateFrame;
local GetShapeshiftForm = GetShapeshiftForm;
local GetNumShapeshiftForms = GetNumShapeshiftForms;
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown;
local GetShapeshiftFormInfo = GetShapeshiftFormInfo;
local GetSpellInfo = GetSpellInfo;
local InCombatLockdown = InCombatLockdown;
local GetBindingKey = GetBindingKey;
local NUM_SHAPESHIFT_SLOTS = NUM_SHAPESHIFT_SLOTS;

local bar = CreateFrame("Frame", "ElvUI_StanceBar", E.UIParent, "SecureHandlerStateTemplate");

function AB:UPDATE_SHAPESHIFT_COOLDOWN()
	local numForms = GetNumShapeshiftForms();
	local start, duration, enable, cooldown
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		if i <= numForms then
			cooldown = _G["ElvUI_StanceBarButton"..i.."Cooldown"];
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
		end
	end

	self:StyleShapeShift("UPDATE_SHAPESHIFT_COOLDOWN")
end

function AB:StyleShapeShift()
	local numForms = GetNumShapeshiftForms();
	local texture, name, isActive, isCastable, _;
	local buttonName, button, icon, cooldown;
	local stance = GetShapeshiftForm();

	for i = 1, NUM_SHAPESHIFT_SLOTS do
		buttonName = "ElvUI_StanceBarButton"..i;
		button = _G[buttonName];
		icon = _G[buttonName.."Icon"];
		cooldown = _G[buttonName.."Cooldown"];

		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);

			if not texture then
				texture = "Interface\\Icons\\Spell_Nature_WispSplode"
			end

			if (type(texture) == "string" and (lower(texture) == "interface\\icons\\spell_nature_wispsplode" or lower(texture) == "interface\\icons\\ability_rogue_envelopingshadows")) and self.db.barShapeShift.style == "darkenInactive" then
				_, _, texture = GetSpellInfo(name)
			end

			icon:SetTexture(texture);

			if texture then
				cooldown:SetAlpha(1);
			else
				cooldown:SetAlpha(0);
			end

			if isActive then
				ShapeshiftBarFrame.lastSelected = button:GetID();
				if numForms == 1 then
					button:GetCheckedTexture():SetTexture(1, 1, 1, 0.5)
					button:SetChecked(true);
				else
					button:GetCheckedTexture():SetTexture(1, 1, 1, 0.5)
					button:SetChecked(self.db.barShapeShift.style ~= "darkenInactive");
				end
			else
				if numForms == 1 or stance == 0 then
					button:SetChecked(false);
				else
					button:SetChecked(self.db.barShapeShift.style == "darkenInactive");
					button:GetCheckedTexture():SetAlpha(1)
					if self.db.barShapeShift.style == "darkenInactive" then
						button:GetCheckedTexture():SetTexture(0, 0, 0, 0.5)
					else
						button:GetCheckedTexture():SetTexture(1, 1, 1, 0.5)
					end
				end
			end

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
			end
		end
	end
end

function AB:PositionAndSizeBarShapeShift()
	local buttonSpacing = E:Scale(self.db["barShapeShift"].buttonspacing);
	local backdropSpacing = E:Scale((self.db["barShapeShift"].backdropSpacing or self.db["barShapeShift"].buttonspacing));
	local buttonsPerRow = self.db["barShapeShift"].buttonsPerRow;
	local numButtons = self.db["barShapeShift"].buttons;
	local size = E:Scale(self.db["barShapeShift"].buttonsize);
	local point = self.db["barShapeShift"].point;
	local widthMult = self.db["barShapeShift"].widthMult;
	local heightMult = self.db["barShapeShift"].heightMult;
	if bar.mover then
		bar.mover.positionOverride = point;
		E:UpdatePositionOverride(bar.mover:GetName())
	end
	bar.db = self.db["barShapeShift"]
	bar.db.position = nil; --Depreciated
	bar.mouseover = self.db["barShapeShift"].mouseover

	if bar.LastButton and numButtons > bar.LastButton then
		numButtons = bar.LastButton;
	end

	if bar.LastButton and buttonsPerRow > bar.LastButton then
		buttonsPerRow = bar.LastButton;
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end

	local numColumns = ceil(numButtons / buttonsPerRow);
	if numColumns < 1 then
		numColumns = 1;
	end

	if self.db["barShapeShift"].backdrop == true then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();

		widthMult = 1
		heightMult = 1
	end

	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult-1)) + ((self.db["barShapeShift"].backdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult-1)) + ((self.db["barShapeShift"].backdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2)
	bar:Width(barWidth);
	bar:Height(barHeight);

	if self.db["barShapeShift"].enabled then
		bar:SetScale(1);
		bar:SetAlpha(bar.db.alpha);
		E:EnableMover(bar.mover:GetName());
	else
		bar:SetScale(0.000001);
		bar:SetAlpha(0);
		E:DisableMover(bar.mover:GetName());
	end

	local horizontalGrowth, verticalGrowth;
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end

	if(self.db["barShapeShift"].inheritGlobalFade) then
		bar:SetParent(self.fadeParent);
	else
		bar:SetParent(E.UIParent);
	end

	local button, lastButton, lastColumnButton;
	local firstButtonSpacing = (self.db["barShapeShift"].backdrop == true and (E.Border + backdropSpacing) or E.Spacing)
	for i=1, NUM_SHAPESHIFT_SLOTS do
		button = _G["ElvUI_StanceBarButton"..i];
		lastButton = _G["ElvUI_StanceBarButton"..i-1];
		lastColumnButton = _G["ElvUI_StanceBarButton"..i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:Size(size);

		if self.db["barShapeShift"].mouseover == true then
			bar:SetAlpha(0);
		else
			bar:SetAlpha(bar.db.alpha);
		end

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

		if i > numButtons then
			button:SetScale(0.000001);
			button:SetAlpha(0);
		else
			button:SetScale(1);
			button:SetAlpha(bar.db.alpha);
		end

		if(not button.FlyoutUpdateFunc) then
			self:StyleButton(button, nil, self.LBFGroup and E.private.actionbar.lbf.enable and true or nil);
		end
	end

	if(self.LBFGroup and E.private.actionbar.lbf.enable) then self.LBFGroup:Skin(E.private.actionbar.lbf.skin); end
end

function AB:AdjustMaxStanceButtons(event)
	if InCombatLockdown() then return; end

	for i=1, #bar.buttons do
		bar.buttons[i]:Hide()
	end
	local numButtons = GetNumShapeshiftForms()
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		if not bar.buttons[i] then
			bar.buttons[i] = CreateFrame("CheckButton", format(bar:GetName().."Button%d", i), bar, "ShapeshiftButtonTemplate")
			bar.buttons[i]:SetID(i)
			if(self.LBFGroup and E.private.actionbar.lbf.enable) then
				self.LBFGroup:AddButton(bar.buttons[i])
			end
			self:HookScript(bar.buttons[i], "OnEnter", "Button_OnEnter");
			self:HookScript(bar.buttons[i], "OnLeave", "Button_OnLeave");
		end

		if ( i <= numButtons ) then
			bar.buttons[i]:Show();
			bar.LastButton = i;
		else
			bar.buttons[i]:Hide();
		end
	end

	self:PositionAndSizeBarShapeShift();

	if event == "UPDATE_SHAPESHIFT_FORMS" then
		self:StyleShapeShift()
	end
end

function AB:UpdateStanceBindings()
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		if self.db.hotkeytext then
			_G["ElvUI_StanceBarButton"..i.."HotKey"]:Show()
			_G["ElvUI_StanceBarButton"..i.."HotKey"]:SetText(GetBindingKey("SHAPESHIFTBUTTON" .. i))
			self:FixKeybindText(_G["ElvUI_StanceBarButton"..i])
		else
			_G["ElvUI_StanceBarButton"..i.."HotKey"]:Hide()
		end
	end
end


function AB:CreateBarShapeShift()
	bar:CreateBackdrop("Default");
	bar.backdrop:SetAllPoints();
	bar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -4);
	bar.buttons = {};
	bar:SetAttribute("_onstate-show", [[
		if newstate == "hide" then
			self:Hide();
		else
			self:Show();
		end
	]]);

	self:HookScript(bar, "OnEnter", "Bar_OnEnter");
	self:HookScript(bar, "OnLeave", "Bar_OnLeave");

	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", "AdjustMaxStanceButtons");
	self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
	self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", "StyleShapeShift");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "StyleShapeShift");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", "StyleShapeShift");

	E:CreateMover(bar, "ShiftAB", L["Stance Bar"], nil, -3, nil, "ALL,ACTIONBARS");
	self:AdjustMaxStanceButtons();
	self:PositionAndSizeBarShapeShift();
	self:StyleShapeShift();
	self:UpdateStanceBindings()
end
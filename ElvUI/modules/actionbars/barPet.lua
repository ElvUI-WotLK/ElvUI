local E, L, V, P, G = unpack(select(2, ...)); -- Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars");

local _G = _G;
local ceil = math.ceil;

local RegisterStateDriver = RegisterStateDriver;
local GetBindingKey = GetBindingKey;
local PetHasActionBar = PetHasActionBar;
local GetPetActionInfo = GetPetActionInfo;
local IsPetAttackAction = IsPetAttackAction;
local PetActionButton_StartFlash = PetActionButton_StartFlash;
local PetActionButton_StopFlash = PetActionButton_StopFlash;
local AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart;
local AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop;
local GetPetActionSlotUsable = GetPetActionSlotUsable;
local SetDesaturation = SetDesaturation;
local PetActionBar_ShowGrid = PetActionBar_ShowGrid;
local PetActionBar_UpdateCooldowns = PetActionBar_UpdateCooldowns;
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS;

local bar = CreateFrame("Frame", "ElvUI_BarPet", E.UIParent, "SecureHandlerStateTemplate");
bar:SetFrameStrata("LOW");

function AB:UpdatePet(event, unit)
	if ((event == "UNIT_FLAGS" or event == "UNIT_AURA") and unit ~= "pet") then return; end
	if (event == "UNIT_PET" and unit ~= "player") then return; end

	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine;
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton" .. i;
		petActionButton = _G[buttonName];
		petActionIcon = _G[buttonName .. "Icon"];
		petAutoCastableTexture = _G[buttonName .. "AutoCastable"];
		petAutoCastShine = _G[buttonName .. "Shine"];
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i);
		if(not isToken) then
			petActionIcon:SetTexture(texture);
			petActionButton.tooltipName = name;
		else
			petActionIcon:SetTexture(_G[texture]);
			petActionButton.tooltipName = _G[name];
		end
		petActionButton.isToken = isToken;
		petActionButton.tooltipSubtext = subtext;
		if(isActive and name ~= "PET_ACTION_FOLLOW") then
			petActionButton:SetChecked(true);
			if(IsPetAttackAction(i)) then
				PetActionButton_StartFlash(petActionButton);
			end
		else
			petActionButton:SetChecked(false);
			if(IsPetAttackAction(i)) then
				PetActionButton_StopFlash(petActionButton);
			end
		end
		if(autoCastAllowed) then
			petAutoCastableTexture:Show();
		else
			petAutoCastableTexture:Hide();
		end
		if(autoCastEnabled) then
			AutoCastShine_AutoCastStart(petAutoCastShine);
		else
			AutoCastShine_AutoCastStop(petAutoCastShine);
		end
		if(texture) then
			if(GetPetActionSlotUsable(i)) then
				SetDesaturation(petActionIcon, nil);
			else
				SetDesaturation(petActionIcon, 1);
			end
			petActionIcon:Show();
		else
			petActionIcon:Hide();
		end
		if(not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW") then
			PetActionButton_StopFlash(petActionButton);
			SetDesaturation(petActionIcon, 1);
			petActionButton:SetChecked(false);
		end
	end
end

function AB:PositionAndSizeBarPet()
	local buttonSpacing = E:Scale(self.db["barPet"].buttonspacing);
	local backdropSpacing = E:Scale((self.db["barPet"].backdropSpacing or self.db["barPet"].buttonspacing));
	local buttonsPerRow = self.db["barPet"].buttonsPerRow;
	local numButtons = self.db["barPet"].buttons;
	local size = E:Scale(self.db["barPet"].buttonsize);
	local point = self.db["barPet"].point;
	local numColumns = ceil(numButtons / buttonsPerRow);
	local widthMult = self.db["barPet"].widthMult;
	local heightMult = self.db["barPet"].heightMult;

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end

	if numColumns < 1 then
		numColumns = 1;
	end

	if self.db["barPet"].backdrop == true then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();

		widthMult = 1
		heightMult = 1
	end

	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult-1)) + ((self.db["barPet"].backdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult-1)) + ((self.db["barPet"].backdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2)
	bar:Width(barWidth);
	bar:Height(barHeight);

	bar.mover:SetSize(bar:GetSize());

	if self.db["barPet"].enabled then
		bar:SetScale(1);
		bar:SetAlpha(self.db["barPet"].alpha);
		E:EnableMover(bar.mover:GetName());
	else
		bar:SetScale(0.0001);
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

	bar.mouseover = self.db["barPet"].mouseover;
	if(bar.mouseover) then
		bar:SetAlpha(0);
	else
		bar:SetAlpha(self.db["barPet"].alpha);
	end

	if(self.db["barPet"].inheritGlobalFade) then
		bar:SetParent(self.fadeParent);
	else
		bar:SetParent(E.UIParent);
	end

	local button, lastButton, lastColumnButton;
	local firstButtonSpacing = (self.db["barPet"].backdrop == true and (E.Border + backdropSpacing) or E.Spacing);
	for i = 1, NUM_PET_ACTION_SLOTS do
		button = _G["PetActionButton"..i];
		lastButton = _G["PetActionButton"..i-1];
		lastColumnButton = _G["PetActionButton"..i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:Size(size);
		button:SetAttribute("showgrid", 1);

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
			button:SetScale(0.0001);
			button:SetAlpha(0);
		else
			button:SetScale(1);
			button:SetAlpha(1);
		end

		self:StyleButton(button, nil, self.LBFGroup and E.private.actionbar.lbf.enable and true or nil);
	end

	RegisterStateDriver(bar, "visibility", self.db["barPet"].visibility);

	bar:GetScript("OnSizeChanged")(bar)

	if(self.LBFGroup and E.private.actionbar.lbf.enable) then self.LBFGroup:Skin(E.private.actionbar.lbf.skin); end
end

function AB:UpdatePetBindings()
	for i=1, NUM_PET_ACTION_SLOTS do
		if self.db.hotkeytext then
			local key = GetBindingKey("BONUSACTIONBUTTON"..i)
			_G["PetActionButton"..i.."HotKey"]:Show()
			_G["PetActionButton"..i.."HotKey"]:SetText(key)
			self:FixKeybindText(_G["PetActionButton"..i])
		else
			_G["PetActionButton"..i.."HotKey"]:Hide()
		end
	end
end

function AB:CreateBarPet()
	bar:CreateBackdrop("Default");
	bar.backdrop:SetAllPoints();
	if self.db["bar4"].enabled then
		bar:Point("RIGHT", ElvUI_Bar4, "LEFT", -4, 0);
	else
		bar:Point("RIGHT", E.UIParent, "RIGHT", -4, 0);
	end

	bar:SetAttribute("_onstate-show", [[
		if newstate == "hide" then
			self:Hide();
		else
			self:Show();
		end
	]]);

	PetActionBarFrame.showgrid = 1;
	PetActionBar_ShowGrid();

	self:HookScript(bar, "OnEnter", "Bar_OnEnter");
	self:HookScript(bar, "OnLeave", "Bar_OnLeave");
	for i = 1, NUM_PET_ACTION_SLOTS do
		self:HookScript(_G["PetActionButton" .. i], "OnEnter", "Button_OnEnter");
		self:HookScript(_G["PetActionButton" .. i], "OnLeave", "Button_OnLeave");
	end

	self:RegisterEvent("SPELLS_CHANGED", "UpdatePet");
	self:RegisterEvent("PLAYER_CONTROL_GAINED", "UpdatePet");
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePet");
	self:RegisterEvent("PLAYER_CONTROL_LOST", "UpdatePet");
	self:RegisterEvent("PET_BAR_UPDATE", "UpdatePet");
	self:RegisterEvent("UNIT_PET", "UpdatePet");
	self:RegisterEvent("UNIT_FLAGS", "UpdatePet");
	self:RegisterEvent("UNIT_AURA", "UpdatePet");
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", "UpdatePet");
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", PetActionBar_UpdateCooldowns);

	E:CreateMover(bar, "ElvBar_Pet", L["Pet Bar"], nil, nil, nil,"ALL,ACTIONBARS");

	self:PositionAndSizeBarPet();
	self:UpdatePetBindings();

	if(self.LBFGroup and E.private.actionbar.lbf.enable) then
		for i = 1, NUM_PET_ACTION_SLOTS do
			local button = _G["PetActionButton" .. i];
			self.LBFGroup:AddButton(button);
		end
	end
end
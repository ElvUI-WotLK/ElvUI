local E, L, V, P, G = unpack(select(2, ...));
local AB = E:GetModule('ActionBars');

if ( E.myclass ~= 'SHAMAN' ) then return; end

local bar = CreateFrame('Frame', 'ElvUI_BarTotem', E.UIParent);
bar.buttons = {};

local bordercolors = {
	{.23,.45,.13},	-- Earth;
	{.58,.23,.10},	-- Fire;
	{.19,.48,.60},	-- Water;
	{.42,.18,.74},	-- Air;
	{.39,.39,.12}	-- Summon / Recall;
}

local SLOT_EMPTY_TCOORDS = {
	[EARTH_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 3 / 256,
		bottom	= 33 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 67 / 128,
		right	= 97 / 128,
		top		= 100 / 256,
		bottom	= 130 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 39 / 128,
		right	= 69 / 128,
		top		= 209 / 256,
		bottom	= 239 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 36 / 256,
		bottom	= 66 / 256,
	},
}

function AB:MultiCastFlyoutFrameOpenButton_Show(button, _, parent)
	button:GetHighlightTexture():SetAlpha(0);
	button:GetNormalTexture():SetAlpha(0);

	button:Height(20);
	button:ClearAllPoints();
	button:Point('BOTTOMLEFT', parent, 'TOPLEFT', 0, -3);
	button:Point('BOTTOMRIGHT', parent, 'TOPRIGHT', 0, -3);
	
	if ( not button.visibleBut ) then
		button.visibleBut = CreateFrame('Frame', nil, button);
		button.visibleBut:Height(8);
		button.visibleBut:Width(parent:GetWidth());
		button.visibleBut:SetPoint('CENTER');
		button.visibleBut:SetTemplate('Default');
	end	

	bar.buttons[button] = true;
	
	button.visibleBut:SetBackdropBorderColor(parent:GetBackdropBorderColor());
	
	self:AdjustTotemSettings();
end

function AB:MultiCastActionButton_Update(button, _, index)
	button:SetTemplate('Default');
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 5) + 1]))
	button:SetBackdropColor(0, 0, 0, 0);
	button:ClearAllPoints();
	button:SetAllPoints(button.slotButton);
	button.overlay:SetTexture(nil);
	button:GetRegions():SetDrawLayer('ARTWORK');
	
	bar.buttons[button] = true;
end

function AB:StyleTotemSlotButton(button, index)
	button:SetTemplate('Default');
	button:StyleButton();
	
	if ( button.actionButton ) then
		button.actionButton:SetTemplate('Default');
		button.actionButton:StyleButton();
	end
	
	button.background:SetDrawLayer('ARTWORK');
	button.background:SetInside(button);
	
	button.overlay:SetTexture(nil);
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 5) + 1]));
	
	bar.buttons[button] = true;
end

function AB:SkinSummonButton(button, index)
	if not ( button ) then return; end
	
	local buttonIcon = select(1, button:GetRegions());
	local buttonHighlight = _G[button:GetName()..'Highlight'];
	local buttonNormalTexture = _G[button:GetName()..'NormalTexture'];
	
	button:SetTemplate('Default');
	button:StyleButton();
	
	buttonIcon:SetTexCoord(unpack(E.TexCoords));
	buttonIcon:SetDrawLayer('ARTWORK');
	buttonIcon:SetInside(button);
	
	buttonHighlight:SetTexture(nil);
	buttonNormalTexture:SetTexture(nil);
	
	bar.buttons[button] = true;
	
	self:AdjustTotemSettings();
end

function AB:MultiCastFlyoutFrame_ToggleFlyout(tray)
	tray.top:SetTexture(nil);
	tray.middle:SetTexture(nil);
	tray:SetFrameStrata('MEDIUM');
	
	local parent = tray.parent;

	local last
	for _,button in ipairs(tray.buttons) do
		button:SetTemplate('Default');
		
		bar.buttons[button] = true;
		
		local buttonIcon = select(1,button:GetRegions());
		buttonIcon:SetTexCoord(unpack(E.TexCoords));
		buttonIcon:SetDrawLayer('ARTWORK');
		buttonIcon:SetInside(button);
		
		if ( not InCombatLockdown() ) then
			button:ClearAllPoints();
			button:Point('BOTTOM', last, 'TOP', 0, 4);
		end
		
		if ( button:IsVisible() ) then last = button; end
		
		button:SetBackdropBorderColor(parent:GetBackdropBorderColor());
		button:StyleButton();
	end
	
	tray.buttons[1]:SetPoint('BOTTOM', tray, 'BOTTOM');
	
	if ( tray.type == 'slot' ) then
		local tCoords = SLOT_EMPTY_TCOORDS[parent:GetID()];
		
		tray.buttons[1].icon:SetTexCoord(tCoords.left, tCoords.right, tCoords.top, tCoords.bottom);
	end
	
	local close = MultiCastFlyoutFrameCloseButton;
	close:SetTemplate('Default');
	close:GetHighlightTexture():SetTexture(1, 1, 1, .3);
	close:GetHighlightTexture():SetInside(close);
	
	close:GetNormalTexture():SetTexture(nil);
	close:ClearAllPoints();
	close:Point('BOTTOMLEFT', last,'TOPLEFT', 0, 4);
	close:Point('BOTTOMRIGHT', last,'TOPRIGHT', 0, 4);
	close:SetBackdropBorderColor(last:GetBackdropBorderColor());
	close:Height(8);
	
	tray:ClearAllPoints();
	tray:Point('BOTTOM', parent, 'TOP', 0, 4);
	
	bar.buttons[close] = true;
	bar.buttons[tray] = true;
	
	self:AdjustTotemSettings();
end

function AB:TotemOnEnter()
	E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), 1);
end

function AB:TotemOnLeave()
	E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0);
end

function AB:AdjustTotemSettings()
	local combat = InCombatLockdown();
	
	if ( self.db['barTotem'].enabled ) and ( not combat ) then
		bar:Show();
	elseif ( not combat ) then
		bar:Hide();
	end
	
	for button, _ in pairs(bar.buttons) do
		if ( self.db['barTotem'].mouseover == true ) then
			bar:SetAlpha(0)
			if ( not self.hooks[bar] ) then
				self:HookScript(bar, 'OnEnter', 'TotemOnEnter');
				self:HookScript(bar, 'OnLeave', 'TotemOnLeave');
			end
			
			if ( not self.hooks[button] ) then
				self:HookScript(button, 'OnEnter', 'TotemOnEnter');
				self:HookScript(button, 'OnLeave', 'TotemOnLeave');
			end			
		else
			bar:SetAlpha(1)
			if ( self.hooks[bar] ) then
				self:Unhook(bar, 'OnEnter');
				self:Unhook(bar, 'OnLeave');
			end
			
			if ( self.hooks[button] ) then
				self:Unhook(button, 'OnEnter');
				self:Unhook(button, 'OnLeave');
			end		
		end
	end
end

function AB:CreateTotemBar()
	bar:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 250);
	
	MultiCastActionBarFrame:SetParent(bar);
	MultiCastActionBarFrame:ClearAllPoints();
	MultiCastActionBarFrame:SetPoint('BOTTOMLEFT', bar, 'BOTTOMLEFT', -2, -2);
	MultiCastActionBarFrame:SetScript('OnUpdate', nil);
	MultiCastActionBarFrame:SetScript('OnShow', nil);
	MultiCastActionBarFrame:SetScript('OnHide', nil);
	MultiCastActionBarFrame.SetParent = E.noop;
	MultiCastActionBarFrame.SetPoint = E.noop;
	MultiCastRecallSpellButton.SetPoint = E.noop;
	
	bar:Width(MultiCastActionBarFrame:GetWidth());
	bar:Height(MultiCastActionBarFrame:GetHeight());
	
	self:SecureHook('MultiCastFlyoutFrameOpenButton_Show');
	self:SecureHook('MultiCastActionButton_Update');
	self:SecureHook('MultiCastSummonSpellButton_Update', function(self) AB:SkinSummonButton(self, 0); end);
	self:SecureHook('MultiCastRecallSpellButton_Update', function(self) AB:SkinSummonButton(self, 5); end);
	
	self:SecureHook('MultiCastSlotButton_Update', function(self, slot)
		AB:StyleTotemSlotButton(self, tonumber( string.match(self:GetName(), 'MultiCastSlotButton(%d)')));
	end);
	
	self:SecureHook('MultiCastFlyoutFrame_ToggleFlyout');
	
	bar.buttons[MultiCastActionBarFrame] = true;
	E:CreateMover(bar, 'ElvBar_Totem', L['Totems'], nil, nil, nil,'ALL,ACTIONBARS');
	
	self:AdjustTotemSettings();
end
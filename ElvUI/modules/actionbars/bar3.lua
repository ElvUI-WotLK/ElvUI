﻿local E, L, V, P, G = unpack(select(2, ...));
local AB = E:GetModule('ActionBars');

local ceil = math.ceil;

local condition = '';
local bar = CreateFrame('Frame', 'ElvUI_Bar3', E.UIParent, 'SecureHandlerStateTemplate');

function AB:PositionAndSizeBar3()
	local spacing = E:Scale(self.db['bar3'].buttonspacing);
	local buttonsPerRow = self.db['bar3'].buttonsPerRow;
	local numButtons = self.db['bar3'].buttons;
	local size = E:Scale(self.db['bar3'].buttonsize);
	local point = self.db['bar3'].point;
	local numColumns = ceil(numButtons / buttonsPerRow);
	local widthMult = self.db['bar3'].widthMult;
	local heightMult = self.db['bar3'].heightMult;
	
	if(numButtons < buttonsPerRow) then
		buttonsPerRow = numButtons;
	end

	if(numColumns < 1) then
		numColumns = 1;
	end

	bar:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	bar.mover:SetSize(bar:GetSize());
	
	if(self.db['bar3'].backdrop == true) then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();
	end
	
	local horizontalGrowth, verticalGrowth;
	do
		if(point == 'TOPLEFT' or point == 'TOPRIGHT') then
			verticalGrowth = 'DOWN';
		else
			verticalGrowth = 'UP';
		end
	
		if point == 'BOTTOMLEFT' or point == 'TOPLEFT' then
			horizontalGrowth = 'RIGHT';
		else
			horizontalGrowth = 'LEFT';
		end
	end
	
	local button, lastButton, lastColumnButton;
	do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			button = _G['MultiBarBottomLeftButton'..i];
			lastButton = _G['MultiBarBottomLeftButton'..i-1];
			lastColumnButton = _G['MultiBarBottomLeftButton'..i-buttonsPerRow];
			button:SetParent(bar);
			button:ClearAllPoints();
			button:Size(size);
			button:SetAttribute('showgrid', 1);
			ActionButton_ShowGrid(button);
			
			if(self.db['bar3'].mouseover == true) then
				bar:SetAlpha(0);
				
				if(not self.hooks[bar]) then
					self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
					self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');	
				end
				
				if(not self.hooks[button]) then
					self:HookScript(button, 'OnEnter', 'Button_OnEnter');
					self:HookScript(button, 'OnLeave', 'Button_OnLeave');					
				end
			else
				bar:SetAlpha(self.db['bar3'].alpha);
				
				if(self.hooks[bar]) then
					self:Unhook(bar, 'OnEnter');
					self:Unhook(bar, 'OnLeave');	
				end
				
				if(self.hooks[button]) then
					self:Unhook(button, 'OnEnter');	
					self:Unhook(button, 'OnLeave');		
				end
			end
			
			if(i == 1) then
				local x, y;
				do
					if(point == 'BOTTOMLEFT') then
						x, y = spacing, spacing;
					elseif(point == 'TOPRIGHT') then
						x, y = -spacing, -spacing;
					elseif(point == 'TOPLEFT') then
						x, y = spacing, -spacing;
					else
						x, y = -spacing, spacing;
					end
				end

				button:Point(point, bar, point, x, y);
			elseif((i - 1) % buttonsPerRow == 0) then
				local x = 0;
				local y = -spacing;
				local buttonPoint, anchorPoint = 'TOP', 'BOTTOM';
				
				if(verticalGrowth == 'UP') then
					y = spacing;
					buttonPoint = 'BOTTOM';
					anchorPoint = 'TOP';
				end
				
				button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y);		
			else
				local x = spacing;
				local y = 0;
				local buttonPoint, anchorPoint = 'LEFT', 'RIGHT';
				
				if(horizontalGrowth == 'LEFT') then
					x = -spacing;
					buttonPoint = 'RIGHT';
					anchorPoint = 'LEFT';
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
	end
	
	if self.db['bar3'].enabled or not bar.initialized then
		if(not self.db['bar3'].mouseover) then
			bar:SetAlpha(self.db['bar3'].alpha);
		end
		
		bar:Show()
		RegisterStateDriver(bar, 'visibility', self.db['bar3'].visibility);
		RegisterStateDriver(bar, 'page', self:GetPage('bar3', 6, condition));
		
		if(not bar.initialized) then
			bar.initialized = true;
			
			AB:PositionAndSizeBar3();
			
			return;
		end
	else
		bar:Hide();
		UnregisterStateDriver(bar, 'visibility');
	end
end

function AB:CreateBar3()
	bar:CreateBackdrop('Default');
	bar.backdrop:SetAllPoints();
	bar:Point('LEFT', ElvUI_Bar1, 'RIGHT', 3, 0);

	local button;
	for i=1, NUM_ACTIONBAR_BUTTONS do
		button = _G['MultiBarBottomLeftButton'..i];
		bar:SetFrameRef('MultiBarBottomLeftButton'..i, button);
	end
	
	bar:Execute([[
		buttons = table.new();
		for i = 1, 12 do
			table.insert(buttons, self:GetFrameRef('MultiBarBottomLeftButton'..i));
		end
	]]);
	
	bar:SetAttribute('_onstate-page', [[ 
		for i, button in ipairs(buttons) do
			button:SetAttribute('actionpage', tonumber(newstate));
		end
	]]);
	
	bar:SetAttribute('_onstate-show', [[		
		if newstate == 'hide' then
			self:Hide();
		else
			self:Show();
		end
	]])
	
	E:CreateMover(bar, 'ElvAB_3', L['Bar 3'], nil, nil, nil, 'ALL,ACTIONBARS');
	self:PositionAndSizeBar3();
end
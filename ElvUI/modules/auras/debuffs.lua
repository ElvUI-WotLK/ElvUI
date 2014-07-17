local E, L, V, P, G = unpack(select(2, ...));
local A = E:GetModule('Auras');
local LSM = LibStub('LibSharedMedia-3.0');

local debuffUnit = 'player';

local floor = math.floor;

local debuffs = {};

local inversePoints = {
	TOP = 'BOTTOM',
	BOTTOM = 'TOP',
	LEFT = 'RIGHT',
	RIGHT = 'LEFT'
};

local DebuffFrame = CreateFrame('Frame', 'ElvUIPlayerDebuffs', E.UIParent);

local UpdateTooltip = function(self)
	local debuff = debuffs[self:GetID()];
	
	if(not debuff) then
		return;
	end
	
	GameTooltip:SetUnitAura(debuffUnit, debuff.index, 'HARMFUL')
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', -5, -5);
	self:UpdateTooltip();
end

local function OnLeave()
	GameTooltip:Hide();
end

local buttons = setmetatable({ }, { __index = function(t, i)
	if(type(i) ~= 'number') then
		return;
	end

	local button = CreateFrame('Button', 'ElvUIPlayerDebuffs'..i..'Button', DebuffFrame);
	button:SetID(i);
	button:SetWidth(A.db.debuffs.size);
	button:SetHeight(A.db.debuffs.size);
	button:Show();
	
	button:SetTemplate('Default');
	
	button:EnableMouse(true);
	button.UpdateTooltip = UpdateTooltip;
	button:SetScript('OnEnter', OnEnter);
	button:SetScript('OnLeave', OnLeave);

	button.texture = button:CreateTexture(nil, 'BORDER');
	button.texture:SetInside();
	button.texture:SetTexCoord(unpack(E.TexCoords));

	button.count = button:CreateFontString(nil, 'OVERLAY');
	
	button.timer = button:CreateFontString(nil, 'OVERLAY')
	
	button.highlight = button:CreateTexture(nil, 'HIGHLIGHT');
	button.highlight:SetTexture(1, 1, 1, 0.45);
	button.highlight:SetInside();
	
	button.holder = CreateFrame('Frame', 'ElvUIPlayerDebuffs'..i..'ButtonHolder', button);
	button.holder:SetTemplate('Default');
	
	button.bar = CreateFrame('StatusBar', 'ElvUIPlayerDebuffs'..i..'ButtonStatusBar', button.holder);
	button.bar:SetInside(button.holder);
	button.bar:SetStatusBarTexture(E['media'].glossTex);
	
	E:SetUpAnimGroup(button)
	
	t[i] = button;

	DebuffFrame:UpdateLayout();

	return button;
end })

DebuffFrame.buttons = buttons

function DebuffFrame:UpdateLayout()
	local db = A.db.debuffs;
	local size = db.size;
	local point = A.DIRECTION_TO_POINT[db.growthDirection];
	
	local xOffset;
	local yOffset;
	local wrapXOffset;
	local wrapYOffset;
	local wrapAfter = db.wrapAfter;
	local maxWraps = db.maxWraps;
	
	local minWidth;
	local minHeight;
	
	if(A.IS_HORIZONTAL_GROWTH[db.growthDirection]) then
		minWidth = ((wrapAfter == 1 and 0 or db.horizontalSpacing) + size) * wrapAfter;
		minHeight = (db.verticalSpacing + size) * db.maxWraps;
		xOffset = A.DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + size);
		yOffset = 0;
		wrapXOffset = 0;
		wrapYOffset = A.DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + size);
	else
		minWidth = (db.horizontalSpacing + size) * db.maxWraps;
		minHeight = ((wrapAfter == 1 and 0 or db.verticalSpacing) + size) * wrapAfter;
		xOffset = 0;
		yOffset = A.DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + size);
		wrapXOffset = A.DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + size);
		wrapYOffset = 0;
	end
	
	local font = LSM:Fetch('font', A.db.font)
	
	local display = #buttons
	if(wrapAfter and maxWraps) then
		display = min(display, wrapAfter * maxWraps);
	end
	
	local left, right, top, bottom = math.huge, -math.huge, -math.huge, math.huge;
	--local numEnchants = PhanxTempEnchantFrame.numEnchants or 0
	for i, button in ipairs(buttons) do
		local j = i --+ numEnchants
		
		button:ClearAllPoints();
		button:SetWidth(size);
		button:SetHeight(size);
		
		local wrapAfter = wrapAfter or j;
		local tick, cycle = floor((j - 1) % wrapAfter), floor((j - 1) / wrapAfter);
		
		button:SetPoint(point, self, cycle * wrapXOffset + tick * xOffset, cycle * wrapYOffset + tick * yOffset);
		
		left = min(left, button:GetLeft() or math.huge);
		right = max(right, button:GetRight() or -math.huge);
		top = max(top, button:GetTop() or -math.huge);
		bottom = min(bottom, button:GetBottom() or math.huge);
		
		button.count:SetPoint('BOTTOMRIGHT', -1 + A.db.countXOffset, 1 + A.db.countYOffset);
		button.count:FontTemplate(font, A.db.fontSize, A.db.fontOutline);
		
		button.timer:SetPoint('TOP', button, 'BOTTOM', 1 + A.db.timeXOffset, 0 + A.db.timeYOffset);
		button.timer:FontTemplate(font, A.db.fontSize, A.db.fontOutline);
		
		local pos = db.barPosition;
		local spacing = db.barSpacing;
		local isOnTop = pos == 'TOP' and true or false;
		local isOnBottom = pos == 'BOTTOM' and true or false;
		local isOnLeft = pos == 'LEFT' and true or false;
		local isOnRight = pos == 'RIGHT' and true or false;
		
		button.holder:ClearAllPoints();
		button.holder:Width((isOnTop or isOnBottom) and size or (db.barWidth + (E.PixelMode and 0 or 2)))
		button.holder:Height((isOnLeft or isOnRight) and size or (db.barHeight + (E.PixelMode and 0 or 2)))
		button.holder:Point(inversePoints[pos], button, pos, (isOnTop or isOnBottom) and 0 or ((isOnLeft and -((E.PixelMode and 1 or 3) + spacing)) or ((E.PixelMode and 1 or 3) + spacing)), (isOnLeft or isOnRight) and 0 or ((isOnTop and ((E.PixelMode and 1 or 3) + spacing) or -((E.PixelMode and 1 or 3) + spacing))))
		
		if(isOnLeft or isOnRight) then
			button.bar:SetOrientation('VERTICAL');
		else
			button.bar:SetOrientation('HORIZONTAL');
		end
	end
	
	if(display >= 1) then
		self:SetWidth(max(right - left, minWidth));
		self:SetHeight(max(top - bottom, minHeight));
	else
		self:SetWidth(minWidth);
		self:SetHeight(minHeight);
	end
end

local tablePool = {};

local function newTable()
	local t = next(tablePool) or {};
	
	tablePool[t] = nil
	
	return t;
end

local function remTable(t)
	if(type(t) == 'table') then
		for k, v in pairs(t) do
			t[k] = nil;
		end
		
		t[true] = true;
		t[true] = nil;
		
		tablePool[t] = true;
	end
	
	return nil;
end

local sorters = {};

local function sortFactory(key, separateOwn, reverse)
	if(separateOwn ~= 0) then
		if(reverse) then
			return function(a, b)
				if(a.filter == b.filter) then
					local ownA, ownB = a.caster == "player", b.caster == "player";
					
					if(ownA ~= ownB) then
						return ownA == (separateOwn > 0);
					end
					return a[key] > b[key];
				else
					return a.filter < b.filter;
				end
			end;
		else
			return function(a, b)
				if(a.filter == b.filter) then
					local ownA, ownB = a.caster == "player", b.caster == "player";
					
					if(ownA ~= ownB) then
						return ownA == (separateOwn > 0);
					end
					
					return a[key] < b[key];
				else
					return a.filter < b.filter;
				end
			end;
		end
	else
		if(reverse ) then
			return function(a, b)
				if(a.filter == b.filter) then
					return a[key] > b[key];
				else
					return a.filter < b.filter;
				end
			end;
		else
			return function(a, b)
				if(a.filter == b.filter) then
					return a[key] < b[key];
				else
					return a.filter < b.filter;
				end
			end;
		end
	end
end

for i, key in ipairs{"index", "name", "expires"} do
	local label = key:upper();
	
	sorters[label] = {};
	
	for bool in pairs{[true] = true, [false] = false} do
		sorters[label][bool] = {};
		
		for sep = -1, 1 do
			sorters[label][bool][sep] = sortFactory(key, sep, bool);
		end
	end
end
sorters.TIME = sorters.EXPIRES;

function DebuffFrame:Update()
	for i, t in ipairs(debuffs) do
		debuffs[i] = remTable(t);
	end
	
	local index = 1;
	while true do
		local name, _, icon, count, kind, duration, expires, caster, _, _, spellID = UnitAura(debuffUnit, index, 'HARMFUL');
		
		if not icon or icon == '' then
			break;
		end
		
		local t = newTable();
		
		t.filter = 'HARMFUL';
		t.name = name;
		t.texture = icon;
		t.count = count;
		t.kind = kind;
		t.duration = duration or 0;
		t.expires = expires;
		t.caster = caster;
		t.spellID = spellID;
		t.index = index;
		
		debuffs[#debuffs + 1] = t;
		index = index + 1;
	end
	
	local db = A.db.debuffs;
	local separateOwn = db.seperateOwn;
	if ( separateOwn > 0 ) then
		separateOwn = 1;
	elseif (separateOwn < 0 ) then
		separateOwn = -1;
	end
	local sortMethod = (sorters[db.sortMethod])[db.sortDir == '-'][separateOwn];
	
	table.sort(debuffs, sortMethod);

	for i, debuff in ipairs(debuffs) do
		local f = buttons[i];
		
		f.texture:SetTexture(debuff.texture);

		if(debuff.count > 1) then
			f.count:SetText(debuff.count);
		else
			f.count:SetText();
		end
		
		local color = DebuffTypeColor[debuff.kind or ''];
		f:SetBackdropBorderColor(color.r, color.g, color.b);
		f.holder:SetBackdropBorderColor(color.r, color.g, color.b);
		
		f:Show();
	end
	
	if(#buttons > #debuffs) then
		for i = #debuffs + 1, #buttons do
			local f = buttons[i];
			
			f.texture:SetTexture();
			f.count:SetText();
			f:Hide();
		end
	end
end

local dirty;

local timerGroup = DebuffFrame:CreateAnimationGroup();
local timer = timerGroup:CreateAnimation();
timer:SetOrder(1);
timer:SetDuration(.5);
timerGroup:SetScript('OnFinished', function(self, requested)
	if(dirty) then
		DebuffFrame:Update();
		
		dirty = false;
	end
	
	for i, button in ipairs(buttons) do
		if(not button:IsShown()) then
			break;
		end
		
		local debuff = debuffs[ button:GetID() ];
		
		if(debuff) then
			if(debuff.duration > 0 and debuff.expires) then
				local timeLeft = debuff.expires - GetTime();
				
				if(not button.timeLeft) then
					button.timeLeft = timeLeft;
					button:SetScript("OnUpdate", A.UpdateTime);
				else
					button.timeLeft = timeLeft;
				end
				
				button.nextUpdate = -1;
				A.UpdateTime(button, 0);
			else
				button.timeLeft = nil;
				button.timer:SetText('');
				button:SetScript('OnUpdate', nil);
			end
			
			if(button.bar and debuff.duration > 0 and debuff.expires) then
				button.bar:SetMinMaxValues(0, debuff.duration);
			else
				local min, max  = button.bar:GetMinMaxValues();
				button.bar:SetValue(max);
				button.bar:SetStatusBarColor(0, 0.8, 0);
			end
			
			local timeLeft = button.timeLeft;
			
			if(not timeLeft) then
				button.holder:Hide();
			else
				if(timeLeft <= A.db.fadeThreshold and debuff.duration > 0) then
					button.holder:Hide();
					button.timer:Show();
				else
					button.holder:Show();
					button.timer:Hide();
				end
				
				button.bar:SetValue(timeLeft);
				
				local r, g, b = ElvUF.ColorGradient(timeLeft, debuff.duration or 0, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0);
				button.bar:SetStatusBarColor(r, g, b);
			end
		end
	end
	
	self:Play();
end);

DebuffFrame:SetScript('OnEvent', function( self, event, unit )
	if(event == 'UNIT_AURA') then
		if(unit == debuffUnit) then
			dirty = true;
		end
	elseif(event == 'PLAYER_ENTERING_WORLD') then
		if(UnitHasVehicleUI('player')) then
			debuffUnit = 'vehicle';
		else
			debuffUnit = 'player';
		end
		
		dirty = true;
	elseif(event == 'UNIT_ENTERED_VEHICLE') then
		if(UnitHasVehicleUI('player')) then
			debuffUnit = 'vehicle';
		end
		
		dirty = true;
	elseif(event == 'UNIT_EXITED_VEHICLE') then
		debuffUnit = 'player';
		dirty = true;
	end
end);

function DebuffFrame:Load()
	self:GetScript('OnEvent')(self, 'PLAYER_ENTERING_WORLD');
	
	dirty = true;
	timerGroup:Play();
	
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
	self:RegisterEvent('UNIT_ENTERED_VEHICLE');
	self:RegisterEvent('UNIT_EXITED_VEHICLE');
	self:RegisterEvent('UNIT_AURA');
	
	self:UpdateLayout();
	self:SetPoint('BOTTOMRIGHT', LeftMiniPanel, 'BOTTOMLEFT', -(6 + E.Border), 0);
	E:CreateMover(self, 'DebuffsMover', L['Player Debuffs']);
	
	A.DebuffFrame = DebuffFrame;
end
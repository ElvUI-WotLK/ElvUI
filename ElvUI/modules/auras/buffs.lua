local E, L, V, P, G = unpack(select(2, ...));
local A = E:GetModule('Auras');
local LSM = LibStub('LibSharedMedia-3.0');

local buffUnit = 'player';

local MAX_BUFFS = 40;

local floor = math.floor;

local buffs = {};

local BuffFrame = CreateFrame('Frame', 'ElvUIPlayerBuffs', E.UIParent);

local function OnEnter(self)
	local buff = buffs[self:GetID()];
	
	if(not buff) then
		return;
	end

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', -5, -5);
	GameTooltip:SetUnitAura(buffUnit, buff.index, 'HELPFUL');
end

local function OnLeave()
	GameTooltip:Hide();
end

local function OnClick(self)
	local buff = buffs[self:GetID()];
	
	if(not buff) then
		return;
	end
	
	CancelUnitBuff(buffUnit, buff.index, 'HELPFUL');
end

local buttons = setmetatable({ }, { __index = function(t, i)
	if(type(i) ~= 'number') then
		return;
	end

	local button = CreateFrame('Button', 'ElvUIPlayerBuffs'..i..'Button', BuffFrame);
	button:SetID(i);
	button:SetWidth(A.db.buffs.size);
	button:SetHeight(A.db.buffs.size);
	button:Show();
	
	button:SetTemplate('Default');
	
	button:EnableMouse(true);
	button:SetScript('OnEnter', OnEnter);
	button:SetScript('OnLeave', OnLeave);

	button:RegisterForClicks('RightButtonUp');
	button:SetScript('OnClick', OnClick);

	button.texture = button:CreateTexture(nil, 'BORDER');
	button.texture:SetInside();
	button.texture:SetTexCoord(unpack(E.TexCoords));

	button.count = button:CreateFontString(nil, 'OVERLAY');
	
	button.timer = button:CreateFontString(nil, 'OVERLAY')
	
	button.highlight = button:CreateTexture(nil, 'HIGHLIGHT');
	button.highlight:SetTexture(1, 1, 1, 0.45);
	button.highlight:SetInside();
	
	E:SetUpAnimGroup(button)
	
	t[i] = button;

	BuffFrame:UpdateLayout();

	return button;
end })

BuffFrame.buttons = buttons

function BuffFrame:UpdateLayout()
	local db = A.db.buffs;
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
		
		button:ClearAllPoints()
		button:SetWidth(size)
		button:SetHeight(size)
		
		local wrapAfter = wrapAfter or j;
		local tick, cycle = floor((j - 1) % wrapAfter), floor((j - 1) / wrapAfter);
		
		button:SetPoint(point, self, cycle * wrapXOffset + tick * xOffset, cycle * wrapYOffset + tick * yOffset);
		
		left = min(left, button:GetLeft() or math.huge);
		right = max(right, button:GetRight() or -math.huge);
		top = max(top, button:GetTop() or -math.huge);
		bottom = min(bottom, button:GetBottom() or math.huge);
		
		button.count:SetPoint('BOTTOMRIGHT', -1 + A.db.countXOffset, 1 + A.db.countYOffset)
		button.count:FontTemplate(font, A.db.fontSize, A.db.fontOutline)
		
		button.timer:SetPoint('TOP', button, 'BOTTOM', 1 + A.db.timeXOffset, 0 + A.db.timeYOffset)
		button.timer:FontTemplate(font, A.db.fontSize, A.db.fontOutline)
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

function BuffFrame:Update()
	for i, t in ipairs(buffs) do
		buffs[i] = remTable(t);
	end
	
	local index = 1;
	repeat
		local name, _, icon, count, kind, duration, expires, caster, _, _, spellID = UnitAura(buffUnit, index, 'HELPFUL');
		
		if not name or not icon or icon == '' then
			break;
		end
		
		local t = newTable();
		
		t.filter = 'HELPFUL';
		t.name = name;
		t.texture = icon;
		t.count = count;
		t.kind = kind;
		t.duration = duration or 0;
		t.expires = expires;
		t.caster = caster;
		t.spellID = spellID;
		t.index = index;
		
		buffs[#buffs + 1] = t;
		index = index + 1;
	until ( not t.name );
	
	local db = A.db.buffs;
	local separateOwn = db.seperateOwn;
	if ( separateOwn > 0 ) then
		separateOwn = 1;
	elseif (separateOwn < 0 ) then
		separateOwn = -1;
	end
	local sortMethod = (sorters[db.sortMethod])[db.sortDir == '-'][separateOwn];
	
	table.sort(buffs, sortMethod);

	for i, buff in ipairs(buffs) do
		local f = buttons[i];
		
		f.texture:SetTexture(buff.texture);

		if(buff.count > 1) then
			f.count:SetText(buff.count);
		else
			f.count:SetText();
		end

		f:Show();
	end
	
	if(#buttons > #buffs) then
		for i = #buffs + 1, #buttons do
			local f = buttons[i];
			
			f.texture:SetTexture();
			f.count:SetText();
			f:Hide();
		end
	end
end

local dirty;

local timerGroup = BuffFrame:CreateAnimationGroup();
local timer = timerGroup:CreateAnimation();
timer:SetOrder(1);
timer:SetDuration(.5);
timerGroup:SetScript('OnFinished', function(self, requested)
	if(dirty) then
		BuffFrame:Update();
		
		dirty = false;
	end
	
	for i, button in ipairs(buttons) do
		if(not button:IsShown()) then
			break;
		end
		
		local buff = buffs[ button:GetID() ];
		
		if(buff) then
			if(buff.duration > 0 and buff.expires) then
				local timeLeft = buff.expires - GetTime();
				
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
		end
	end
	
	self:Play();
end);

BuffFrame:SetScript('OnEvent', function( self, event, unit )
	if(event == 'UNIT_AURA') then
		if(unit == buffUnit) then
			dirty = true;
		end
	elseif(event == 'PLAYER_ENTERING_WORLD') then
		if(UnitHasVehicleUI('player')) then
			buffUnit = 'vehicle';
		else
			buffUnit = 'player';
		end
		
		dirty = true;
	elseif(event == 'UNIT_ENTERED_VEHICLE') then
		if(UnitHasVehicleUI('player')) then
			buffUnit = 'vehicle';
		end
		
		dirty = true;
	elseif(event == 'UNIT_EXITED_VEHICLE') then
		buffUnit = 'player';
		dirty = true;
	end
end);

function BuffFrame:Load()
	self:GetScript('OnEvent')(self, 'PLAYER_ENTERING_WORLD');
	
	dirty = true;
	timerGroup:Play();
	
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
	self:RegisterEvent('UNIT_ENTERED_VEHICLE');
	self:RegisterEvent('UNIT_EXITED_VEHICLE');
	self:RegisterEvent('UNIT_AURA');
	
	self:UpdateLayout();
	self:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -8, 0);
	E:CreateMover(self, 'BuffsMover', L['Player Buffs']);
	
	A.BuffFrame = BuffFrame;
end
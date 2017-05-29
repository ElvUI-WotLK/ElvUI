local E, L, V, P, G = unpack(select(2, ...));
local A = E:NewModule("Auras", "AceEvent-3.0");
local LSM = LibStub("LibSharedMedia-3.0");

local GetTime = GetTime;
local _G = _G
local select, unpack, pairs, ipairs, tostring = select, unpack, pairs, ipairs, tostring;
local floor, min, max, huge = math.floor, math.min, math.max, math.huge;
local format = string.format;
local wipe, tinsert, tsort, tremove = table.wipe, table.insert, table.sort, table.remove;

local CreateFrame = CreateFrame;
local UnitAura = UnitAura;
local CancelItemTempEnchantment = CancelItemTempEnchantment;
local CancelUnitBuff = CancelUnitBuff;
local GetInventoryItemQuality = GetInventoryItemQuality;
local GetItemQualityColor = GetItemQualityColor;
local GetWeaponEnchantInfo = GetWeaponEnchantInfo;
local GetInventoryItemTexture = GetInventoryItemTexture;

local LBF = LibStub("LibButtonFacade", true);

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT"
};

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1
};

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1
};

local IS_HORIZONTAL_GROWTH = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true
};

function A:UpdateTime(elapsed)
	self.timeLeft = self.timeLeft - elapsed;

	if(self.nextUpdate > 0) then
		self.nextUpdate = self.nextUpdate - elapsed;
		return;
	end

	local timerValue, formatID;
	timerValue, formatID, self.nextUpdate = E:GetTimeInfo(self.timeLeft, A.db.fadeThreshold);
	self.time:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatID], E.TimeFormats[formatID][1]), timerValue);

	if(self.timeLeft > E.db.auras.fadeThreshold) then
		E:StopFlash(self);
	else
		E:Flash(self, 1);
	end
end

local UpdateTooltip = function(self)
	if(self.isWeapon) then
		GameTooltip:SetInventoryItem("player", self:GetID());
	else
		GameTooltip:SetUnitAura("player", self:GetID(), self:GetParent().filter);
	end
end

local OnEnter = function(self)
	if(not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5);
	self:UpdateTooltip();
end

local OnLeave = function()
	GameTooltip:Hide();
end

local OnClick = function(self)
	if(self.isWeapon) then
		if(self:GetID() == 16) then
			CancelItemTempEnchantment(1);
		elseif(self:GetID() == 17) then
			CancelItemTempEnchantment(2);
		end
	else
		CancelUnitBuff("player", self:GetID(), self:GetParent().filter);
	end
end

function A:CreateIcon(button)
	local font = LSM:Fetch("font", self.db.font);
	button:RegisterForClicks("RightButtonUp");

	button.texture = button:CreateTexture(nil, "BORDER");
	button.texture:SetInside();
	button.texture:SetTexCoord(unpack(E.TexCoords));

	button.count = button:CreateFontString(nil, "ARTWORK");
	button.count:SetPoint("BOTTOMRIGHT", -1 + self.db.countXOffset, 1 + self.db.countYOffset);
	button.count:FontTemplate(font, self.db.fontSize, self.db.fontOutline);

	button.time = button:CreateFontString(nil, "ARTWORK");
	button.time:SetPoint("TOP", button, "BOTTOM", 1 + self.db.timeXOffset, 0 + self.db.timeYOffset);
	button.time:FontTemplate(font, self.db.fontSize, self.db.fontOutline);

	button.highlight = button:CreateTexture(nil, "HIGHLIGHT");
	button.highlight:SetTexture(1, 1, 1, 0.45);
	button.highlight:SetInside();

	E:SetUpAnimGroup(button);

	button.UpdateTooltip = UpdateTooltip;
	button:SetScript("OnEnter", OnEnter);
	button:SetScript("OnLeave", OnLeave);
	button:SetScript("OnClick", OnClick);

	if(self.LBFGroup and E.private.auras.lbf.enable) then
		local ButtonData = {
			Icon = button.texture,
			Flash = nil,
			Cooldown = nil,
			AutoCast = nil,
			AutoCastable = nil,
			HotKey = nil,
			Count = false,
			Name = nil,
			Highlight = button.highlight,
		};

		self.LBFGroup:AddButton(button, ButtonData);
	else
		button:SetTemplate("Default");
	end
end

local buttons = {};
function A:ConfigureAuras(header, auraTable)
	local headerName = header:GetName()

	local db = self.db.debuffs;
	if(header.filter == "HELPFUL") then
		db = self.db.buffs;
	end

	local size = db.size;
	local point = DIRECTION_TO_POINT[db.growthDirection];
	local xOffset = 0;
	local yOffset = 0;
	local wrapXOffset = 0;
	local wrapYOffset = 0;
	local wrapAfter = db.wrapAfter;
	local maxWraps = db.maxWraps;
	local minWidth = 0;
	local minHeight = 0;

	if(IS_HORIZONTAL_GROWTH[db.growthDirection]) then
		minWidth = ((wrapAfter == 1 and 0 or db.horizontalSpacing) + size) * wrapAfter;
		minHeight = (db.verticalSpacing + size) * maxWraps;
		xOffset = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + size);
		yOffset = 0;
		wrapXOffset = 0;
		wrapYOffset = DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + size);
	else
		minWidth = (db.horizontalSpacing + size) * maxWraps;
		minHeight = ((wrapAfter == 1 and 0 or db.verticalSpacing) + size) * wrapAfter;
		xOffset = 0;
		yOffset = DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + size);
		wrapXOffset = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + size);
		wrapYOffset = 0;
	end

	wipe(buttons);
	for i = 1, #auraTable do
		local button = _G[headerName.."AuraButton"..i]
		if(button) then
			if(button:IsShown()) then button:Hide(); end
		else
			button = CreateFrame("Button", "$parentAuraButton" .. i, header);
			self:CreateIcon(button);
		end
		local buffInfo = auraTable[i];
		button:SetID(buffInfo.index);

		if(buffInfo.duration > 0 and buffInfo.expires) then
			local timeLeft = buffInfo.expires - GetTime();
			if(not button.timeLeft) then
				button.timeLeft = timeLeft;
				button:SetScript("OnUpdate", self.UpdateTime);
			else
				button.timeLeft = timeLeft;
			end

			button.nextUpdate = -1;
			self.UpdateTime(button, 0);
		else
			button.timeLeft = nil;
			button.time:SetText("");
			button:SetScript("OnUpdate", nil);
		end

		if(buffInfo.count > 1) then
			button.count:SetText(buffInfo.count);
		else
			button.count:SetText("");
		end

		if(buffInfo.filter == "HARMFUL") then
			local color = DebuffTypeColor[buffInfo.dispelType or ""];
			button:SetBackdropBorderColor(color.r, color.g, color.b);
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor));
		end

		button.texture:SetTexture(buffInfo.icon);

		buttons[i] = button;
	end

	local display = #buttons;
	if(wrapAfter and maxWraps) then
		display = min(display, wrapAfter * maxWraps);
	end

	local left, right, top, bottom = huge, -huge, -huge, huge;
	for index = 1, display do
		local button = buttons[index];
		local wrapAfter = wrapAfter or index;
		local tick, cycle = floor((index - 1) % wrapAfter), floor((index - 1) / wrapAfter);
		button:ClearAllPoints();
		button:SetPoint(point, header, cycle * wrapXOffset + tick * xOffset, cycle * wrapYOffset + tick * yOffset);

		button:SetSize(size, size);

		if(button.time) then
			local font = LSM:Fetch("font", self.db.font);
			button.time:ClearAllPoints();
			button.time:SetPoint("TOP", button, "BOTTOM", 1 + self.db.timeXOffset, 0 + self.db.timeYOffset);
			button.time:FontTemplate(font, self.db.fontSize, self.db.fontOutline);

			button.count:ClearAllPoints();
			button.count:SetPoint("BOTTOMRIGHT", -1 + self.db.countXOffset, 0 + self.db.countYOffset);
			button.count:FontTemplate(font, self.db.fontSize, self.db.fontOutline);
		end

		button:Show();
		left = min(left, button:GetLeft() or huge);
		right = max(right, button:GetRight() or -huge);
		top = max(top, button:GetTop() or -huge);
		bottom = min(bottom, button:GetBottom() or huge);
	end
	local deadIndex = #(auraTable) + 1;
	local button = _G[headerName.."AuraButton"..deadIndex]
	while(button) do
		if(button:IsShown()) then button:Hide(); end
		deadIndex = deadIndex + 1;
		button = _G[headerName.."AuraButton"..deadIndex]
	end

	if(display >= 1) then
		header:SetWidth(max(right - left, minWidth));
		header:SetHeight(max(top - bottom, minHeight));
	else
		header:SetWidth(minWidth);
		header:SetHeight(minHeight);
	end
end

local freshTable;
local releaseTable;
do
	local tableReserve = {};
	freshTable = function ()
		local t = next(tableReserve) or {};
		tableReserve[t] = nil;
		return t;
	end
	releaseTable = function (t)
		tableReserve[t] = wipe(t);
	end
end

local function sortFactory(key, separateOwn, reverse)
	if(separateOwn ~= 0) then
		if(reverse) then
			return function(a, b)
				if(a.filter == b.filter) then
					local ownA, ownB = a.caster == "player", b.caster == "player";
					if(ownA ~= ownB) then
						return ownA == (separateOwn > 0)
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
		if(reverse) then
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

local sorters = {};
for i, key in ipairs{"index", "name", "expires"} do
	local label = key:upper();
	sorters[label] = {};
	for bool in pairs{[true] = true, [false] = false} do
		sorters[label][bool] = {}
		for sep = -1, 1 do
			sorters[label][bool][sep] = sortFactory(key, sep, bool);
		end
	end
end
sorters.TIME = sorters.EXPIRES;

local sortingTable = {};
function A:UpdateHeader(header)
	local filter = header.filter;
	local db = self.db.debuffs;
	if(filter == "HELPFUL") then
		db = self.db.buffs;
	end

	wipe(sortingTable);

	local i = 1;
	repeat
		local aura, _ = freshTable();
		aura.name, _, aura.icon, aura.count, aura.dispelType, aura.duration, aura.expires, aura.caster = UnitAura("player", i, filter);
		if(aura.name) then
			aura.filter = filter;
			aura.index = i;

			tinsert(sortingTable, aura);
		else
			releaseTable(aura);
		end
		i = i + 1;
	until(not aura.name);

	local sortMethod = (sorters[db.sortMethod] or sorters["INDEX"])[db.sortDir == "-"][db.seperateOwn];
	tsort(sortingTable, sortMethod);

	self:ConfigureAuras(header, sortingTable);
	while(sortingTable[1]) do
		releaseTable(tremove(sortingTable));
	end

	if(self.LBFGroup) then
		self.LBFGroup:Skin(E.private.auras.lbf.skin);
	end
end

function A:UpdateWeapon(button)
	local id = button:GetID();
	local quality = GetInventoryItemQuality("player", id);
	if(quality) then
		button:SetBackdropBorderColor(GetItemQualityColor(quality));
	end

	if(button.duration) then
		button.timeLeft = button.duration / 1e3;
		button.nextUpdate = -1;
		button:SetScript("OnUpdate", A.UpdateTime);
		A.UpdateTime(button, 0);
	else
		button.timeLeft = nil;
		button:SetScript("OnUpdate", nil);
		button.time:SetText("");
	end

	local enchantIndex = self.WeaponFrame.enchantIndex;
	if(enchantIndex ~= nil) then
		self.WeaponFrame:Width((enchantIndex * A.db.buffs.size) + (enchantIndex == 2 and A.db.buffs.horizontalSpacing or 0));
	end
end

function A:CreateAuraHeader(filter)
	local name = "ElvUIPlayerDebuffs";
	if(filter == "HELPFUL") then
		name = "ElvUIPlayerBuffs";
	end

	local header = CreateFrame("Frame", name, UIParent);
	header:SetClampedToScreen(true);
	header.filter = filter;

	header:RegisterEvent("UNIT_AURA");
	header:SetScript("OnEvent", function(self, event, unit)
		if(event == "UNIT_AURA" and unit == "player") then
			A:UpdateHeader(self);
		end
	end);

	self:UpdateHeader(header);

	return header;
end

function A:Initialize()
	if(self.db) then return; end

	if(E.private.auras.disableBlizzard) then
		BuffFrame:Kill()
		ConsolidatedBuffs:Kill()
		TemporaryEnchantFrame:Kill();
	end

	if(not E.private.auras.enable) then return; end

	self.db = E.db.auras;

	if(LBF) then
		self.LBFGroup = LBF and LBF:Group("ElvUI", "Auras");
	end

	self.BuffFrame = self:CreateAuraHeader("HELPFUL")
	self.BuffFrame:Point("TOPRIGHT", MMHolder, "TOPLEFT", -(6 + E.Border), -E.Border - E.Spacing);
	E:CreateMover(self.BuffFrame, "BuffsMover", L["Player Buffs"]);

	self.DebuffFrame = self:CreateAuraHeader("HARMFUL");
	self.DebuffFrame:Point("BOTTOMRIGHT", MMHolder, "BOTTOMLEFT", -(6 + E.Border), E.Border + E.Spacing);
	E:CreateMover(self.DebuffFrame, "DebuffsMover", L["Player Debuffs"]);

	self.WeaponFrame = CreateFrame("Frame", "ElvUIPlayerWeapons", UIParent);
	self.WeaponFrame:Point("TOPRIGHT", MMHolder, "BOTTOMRIGHT", 0, -E.Border - E.Spacing);
	self.WeaponFrame:Size(A.db.buffs.size);

	self.WeaponFrame.buttons = {};
	for i = 1, 2 do
		self.WeaponFrame.buttons[i] = CreateFrame("Button", "$parentButton" .. i, self.WeaponFrame);
		self.WeaponFrame.buttons[i]:Size(A.db.buffs.size);

		if(i == 1) then
			self.WeaponFrame.buttons[i]:SetPoint("RIGHT", self.WeaponFrame);
		else
			self.WeaponFrame.buttons[i]:SetPoint("RIGHT", self.WeaponFrame.buttons[1], "LEFT", -A.db.buffs.horizontalSpacing, 0);
		end

		A:CreateIcon(self.WeaponFrame.buttons[i]);
		self.WeaponFrame.buttons[i].isWeapon = true;
	end

	self.WeaponFrame:SetScript("OnUpdate", function(self)
		if(self:IsVisible()) then
			local hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo();
			if(not hasMainHandEnchant and not hasOffHandEnchant) then
				for i = 1, 2 do
					self.buttons[i]:Hide();
				end
				return;
			end

			local enchantButton;
			local textureName;
			local enchantIndex = 0;
			if(hasOffHandEnchant) then
				enchantIndex = enchantIndex + 1;
				textureName = GetInventoryItemTexture("player", 17);
				self.buttons[1]:SetID(17);
				self.buttons[1].texture:SetTexture(textureName);
				self.buttons[1].duration = offHandExpiration;
				self.buttons[1]:Show();

				A:UpdateWeapon(self.buttons[1]);
			end

			if(hasMainHandEnchant) then
				enchantIndex = enchantIndex + 1;
				enchantButton = self.buttons[enchantIndex];
				textureName = GetInventoryItemTexture("player", 16);
				enchantButton:SetID(16);
				enchantButton.texture:SetTexture(textureName);
				enchantButton.duration = mainHandExpiration;
				enchantButton:Show();

				A:UpdateWeapon(enchantButton);
			end
			self.enchantIndex = enchantIndex;

			for i = enchantIndex+1, 2 do
				self.buttons[i]:Hide();
			end
		end
	end);
	E:CreateMover(self.WeaponFrame, "WeaponsMover", L["Weapons"]);
end

local function InitializeCallback()
	A:Initialize()
end

E:RegisterModule(A:GetName(), InitializeCallback)
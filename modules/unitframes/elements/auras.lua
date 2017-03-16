local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");
local LSM = LibStub("LibSharedMedia-3.0");

local unpack, type = unpack, type;
local tsort = table.sort;
local format = format;

local GetTime = GetTime;
local CreateFrame = CreateFrame;
local IsShiftKeyDown = IsShiftKeyDown;
local IsAltKeyDown = IsAltKeyDown;
local IsControlKeyDown = IsControlKeyDown;
local UnitAura = UnitAura;
local UnitIsFriend = UnitIsFriend;

function UF:Construct_Buffs(frame)
	local buffs = CreateFrame("Frame", frame:GetName() .. "Buffs", frame);
	buffs.spacing = E.Spacing;
	buffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil;
	buffs.PostCreateIcon = self.Construct_AuraIcon;
	buffs.PostUpdateIcon = self.PostUpdateAura;
	buffs.CustomFilter = self.AuraFilter;
	buffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10);
	buffs.type = "buffs";
	buffs:Width(100);

	return buffs;
end

function UF:Construct_Debuffs(frame)
	local debuffs = CreateFrame("Frame", frame:GetName() .. "Debuffs", frame);
	debuffs.spacing = E.Spacing;
	debuffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil;
	debuffs.PostCreateIcon = self.Construct_AuraIcon;
	debuffs.PostUpdateIcon = self.PostUpdateAura;
	debuffs.CustomFilter = self.AuraFilter;
	debuffs.type = "debuffs";
	debuffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10);
	debuffs:Width(100);

	return debuffs;
end

function UF:Construct_AuraIcon(button)
	local offset = UF.thinBorders and E.mult or E.Border;

	button.text = button.cd:CreateFontString(nil, "OVERLAY");
	button.text:Point("CENTER", 1, 1);
	button.text:SetJustifyH("CENTER");

	button:SetTemplate("Default", nil, nil, UF.thinBorders);

	button.cd.noOCC = true;
	button.cd.noCooldownCount = true;
	button.cd:SetReverse(true);
	button.cd:SetInside(button, offset, offset);

	button.icon:SetInside(button, offset, offset);
	button.icon:SetTexCoord(unpack(E.TexCoords));
	button.icon:SetDrawLayer("ARTWORK");

	button.count:ClearAllPoints();
	button.count:Point("BOTTOMRIGHT", 1, 1);
	button.count:SetJustifyH("RIGHT");

	button.overlay:SetTexture(nil);
	button.stealable:SetTexture(nil);

	button:RegisterForClicks("RightButtonUp");
	button:SetScript("OnClick", function(self)
		if(E.db.unitframe.auraBlacklistModifier == "NONE" or not ((E.db.unitframe.auraBlacklistModifier == "SHIFT" and IsShiftKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "ALT" and IsAltKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "CTRL" and IsControlKeyDown()))) then return; end
		local auraName = self.name;

		if(auraName) then
			E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName));
			E.global["unitframe"]["aurafilters"]["Blacklist"]["spells"][auraName] = {
				["enable"] = true,
				["priority"] = 0
			};

			UF:Update_AllFrames();
		end
	end);

	UF:UpdateAuraIconSettings(button, true);
end

function UF:EnableDisable_Auras(frame)
	if(frame.db.debuffs.enable or frame.db.buffs.enable) then
		if(not frame:IsElementEnabled("Aura")) then
			frame:EnableElement("Aura");
		end
	else
		if(frame:IsElementEnabled("Aura")) then
			frame:DisableElement("Aura");
		end
	end
end

local function ReverseUpdate(frame)
	UF:Configure_Auras(frame, "Debuffs");
	UF:Configure_Auras(frame, "Buffs");
end

function UF:Configure_Auras(frame, auraType)
	if(not frame.VARIABLES_SET) then return; end
	local db = frame.db;

	local auras = frame[auraType];
	auraType = auraType:lower();
	local rows = db[auraType].numrows;

	local totalWidth = frame.UNIT_WIDTH - frame.SPACING*2
	if(frame.USE_POWERBAR_OFFSET) then
		local powerOffset = ((frame.ORIENTATION == "MIDDLE" and 2 or 1) * frame.POWERBAR_OFFSET);
		if not (db[auraType].attachTo == "POWER" and frame.ORIENTATION == "MIDDLE") then
			totalWidth = totalWidth - powerOffset;
		end
	end
	auras:Width(totalWidth);

	auras.forceShow = frame.forceShowAuras;
	auras.num = db[auraType].perrow * rows;
	auras.size = db[auraType].sizeOverride ~= 0 and db[auraType].sizeOverride or ((((auras:GetWidth() - (auras.spacing*(auras.num/rows - 1))) / auras.num)) * rows);

	if(db[auraType].sizeOverride and db[auraType].sizeOverride > 0) then
		auras:Width((db[auraType].perrow * db[auraType].sizeOverride));
	end

	local attachTo = self:GetAuraAnchorFrame(frame, db[auraType].attachTo, db.debuffs.attachTo == "BUFFS" and db.buffs.attachTo == "DEBUFFS");
	local x, y = E:GetXYOffset(db[auraType].anchorPoint, frame.SPACING);

	if(db[auraType].attachTo == "FRAME") then
		y = 0;
	elseif(db[auraType].attachTo == "HEALTH" or db[auraType].attachTo == "POWER") then
		local newX = E:GetXYOffset(db[auraType].anchorPoint, -frame.BORDER);
		local _, newY = E:GetXYOffset(db[auraType].anchorPoint, (frame.BORDER + frame.SPACING));
		x = newX;
		y = newY;
	else
		x = 0;
	end

	if(auraType == "buffs" and frame.Debuffs.attachTo and frame.Debuffs.attachTo == frame.Buffs and db[auraType].attachTo == "DEBUFFS") then
		ReverseUpdate(frame);
		return;
	end

	auras:ClearAllPoints();
	auras:Point(E.InversePoints[db[auraType].anchorPoint], attachTo, db[auraType].anchorPoint, x + db[auraType].xOffset, y + db[auraType].yOffset);
	auras:Height((auras.size * rows));
	auras["growth-y"] = db[auraType].anchorPoint:find("TOP") and "UP" or "DOWN";
	auras["growth-x"] = db[auraType].anchorPoint == "LEFT" and "LEFT" or db[auraType].anchorPoint == "RIGHT" and "RIGHT" or (db[auraType].anchorPoint:find("LEFT") and "RIGHT" or "LEFT");
	auras.initialAnchor = E.InversePoints[db[auraType].anchorPoint];

	auras.attachTo = attachTo;
	auras.point = E.InversePoints[db[auraType].anchorPoint];
	auras.anchorPoint = db[auraType].anchorPoint;
	auras.xOffset = x + db[auraType].xOffset;
	auras.yOffset = y + db[auraType].yOffset;

	if(db[auraType].enable) then
		auras:Show();
		UF:UpdateAuraIconSettings(auras);
	else
		auras:Hide();
	end

	local position = db.smartAuraPosition;
	if(position == "BUFFS_ON_DEBUFFS") then
		if(db.debuffs.attachTo == "BUFFS") then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]));
			db.debuffs.attachTo = "FRAME";
			frame.Debuffs.attachTo = frame;
		end
		frame.Buffs.PostUpdate = nil;
		frame.Debuffs.PostUpdate = UF.UpdateBuffsHeaderPosition;
	elseif(position == "DEBUFFS_ON_BUFFS") then
		if(db.buffs.attachTo == "DEBUFFS") then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]));
			db.buffs.attachTo = "FRAME";
			frame.Buffs.attachTo = frame;
		end
		frame.Buffs.PostUpdate = UF.UpdateDebuffsHeaderPosition;
		frame.Debuffs.PostUpdate = nil;
	else
		frame.Buffs.PostUpdate = nil;
		frame.Debuffs.PostUpdate = nil;
	end
end

local function SortAurasByTime(a, b)
	if(a and b and a:GetParent().db) then
		if(a:IsShown() and b:IsShown()) then
			local sortDirection = a:GetParent().db.sortDirection;
			local aTime = a.expiration or -1;
			local bTime = b.expiration or -1;
			if(aTime and bTime) then
				if(sortDirection == "DESCENDING") then
					return aTime < bTime;
				else
					return aTime > bTime;
				end
			end
		elseif(a:IsShown()) then
			return true;
		end
	end
end

local function SortAurasByName(a, b)
	if(a and b and a:GetParent().db) then
		if(a:IsShown() and b:IsShown()) then
			local sortDirection = a:GetParent().db.sortDirection;
			local aName = a.spell or "";
			local bName = b.spell or "";
			if(aName and bName) then
				if(sortDirection == "DESCENDING") then
					return aName < bName;
				else
					return aName > bName;
				end
			end
		elseif(a:IsShown()) then
			return true;
		end
	end
end

local function SortAurasByDuration(a, b)
	if(a and b and a:GetParent().db) then
		if(a:IsShown() and b:IsShown()) then
			local sortDirection = a:GetParent().db.sortDirection;
			local aTime = a.duration or -1;
			local bTime = b.duration or -1;
			if(aTime and bTime) then
				if(sortDirection == "DESCENDING") then
					return aTime < bTime;
				else
					return aTime > bTime;
				end
			end
		elseif(a:IsShown()) then
			return true;
		end
	end
end

local function SortAurasByCaster(a, b)
	if(a and b and a:GetParent().db) then
		if(a:IsShown() and b:IsShown()) then
			local sortDirection = a:GetParent().db.sortDirection;
			local aPlayer = a.isPlayer or false;
			local bPlayer = b.isPlayer or false;
			if(sortDirection == "DESCENDING") then
				return (aPlayer and not bPlayer);
			else
				return (not aPlayer and bPlayer);
			end
		elseif(a:IsShown()) then
			return true;
		end
	end
end

function UF:SortAuras()
	if(not self.db) then return; end

	if(self.db.sortMethod == "TIME_REMAINING") then
		tsort(self, SortAurasByTime);
	elseif(self.db.sortMethod == "NAME") then
		tsort(self, SortAurasByName);
	elseif(self.db.sortMethod == "DURATION") then
		tsort(self, SortAurasByDuration);
	elseif (self.db.sortMethod == "PLAYER") then
		tsort(self, SortAurasByCaster);
	end

	return 1, #self;
end

function UF:UpdateAuraIconSettings(auras, noCycle)
	local frame = auras:GetParent();
	local type = auras.type;
	if(noCycle) then
		frame = auras:GetParent():GetParent();
		type = auras:GetParent().type;
	end
	if(not frame.db) then return; end

	local db = frame.db[type];
	local unitframeFont = LSM:Fetch("font", E.db["unitframe"].font);
	local unitframeFontOutline = E.db["unitframe"].fontOutline;
	local index = 1;
	auras.db = db;
	if(db) then
		if(not noCycle) then
			while(auras[index]) do
				local button = auras[index];
				button.text:FontTemplate(unitframeFont, db.fontSize, unitframeFontOutline);
				button.count:FontTemplate(unitframeFont, db.countFontSize or db.fontSize, unitframeFontOutline);

				if(db.clickThrough and button:IsMouseEnabled()) then
					button:EnableMouse(false)
				elseif(not db.clickThrough and not button:IsMouseEnabled()) then
					button:EnableMouse(true);
				end
				index = index + 1;
			end
		else
			auras.text:FontTemplate(unitframeFont, db.fontSize, unitframeFontOutline);
			auras.count:FontTemplate(unitframeFont, db.countFontSize or db.fontSize, unitframeFontOutline);

			if(db.clickThrough and auras:IsMouseEnabled()) then
				auras:EnableMouse(false);
			elseif(not db.clickThrough and not auras:IsMouseEnabled()) then
				auras:EnableMouse(true);
			end
		end
	end
end

local unstableAffliction = GetSpellInfo(30108);
local vampiricTouch = GetSpellInfo(34914);
function UF:PostUpdateAura(unit, button, index)
	local name, _, _, _, dtype, duration, expiration, _, isStealable = UnitAura(unit, index, button.filter);
	local isFriend = UnitIsFriend("player", unit) == 1 and true or false;

	local auras = button:GetParent();
	local frame = auras:GetParent();
	local type = auras.type;
	local db = frame.db and frame.db[type];

	if(db) then
		if(db.clickThrough and button:IsMouseEnabled()) then
			button:EnableMouse(false);
		elseif(not db.clickThrough and not button:IsMouseEnabled()) then
			button:EnableMouse(true);
		end
	end

	if(button.isDebuff) then
		if(not isFriend and button.owner ~= "player" and button.owner ~= "vehicle") --[[and (not E.isDebuffWhiteList[name])]] then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1);
			button.icon:SetDesaturated((unit and not unit:find("arena%d")) and true or false);
		else
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none;
			if((name == unstableAffliction or name == vampiricTouch) and E.myclass ~= "WARLOCK") then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94);
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6);
			end
			button.icon:SetDesaturated(false);
		end
	else
		if((isStealable) and not isFriend) then
			button:SetBackdropBorderColor(237/255, 234/255, 142/255);
		else
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor));
		end
	end

	local size = button:GetParent().size;
	if(size) then
		button:SetSize(size, size);
	end

	button.spell = name;
	button.isStealable = isStealable;
	button.duration = duration;

	if(expiration and duration ~= 0) then
		if(not button:GetScript("OnUpdate")) then
			button.expirationTime = expiration;
			button.expiration = expiration - GetTime();
			button.nextupdate = -1;
			button:SetScript("OnUpdate", UF.UpdateAuraTimer);
		end
		if((button.expirationTime ~= expiration) or (button.expiration ~= (expiration - GetTime()))) then
			button.expirationTime = expiration;
			button.expiration = expiration - GetTime();
			button.nextupdate = -1;
		end
	end
	if(duration == 0 or expiration == 0) then
		button.expirationTime = nil;
		button.expiration = nil;
		button.priority = nil;
		button.duration = nil;
		button:SetScript("OnUpdate", nil);
		if(button.text:GetFont()) then
			button.text:SetText("");
		end
	end
end

function UF:UpdateAuraTimer(elapsed)
	self.expiration = self.expiration - elapsed;
	if(self.nextupdate > 0) then
		self.nextupdate = self.nextupdate - elapsed;
		return;
	end

	if(self.expiration <= 0) then
		self:SetScript("OnUpdate", nil);

		if(self.text:GetFont()) then
			self.text:SetText("");
		end

		return;
	end

	local timervalue, formatid;
	timervalue, formatid, self.nextupdate = E:GetTimeInfo(self.expiration, 4);
	if(self.text:GetFont()) then
		self.text:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatid], E.TimeFormats[formatid][2]), timervalue);
	elseif(self:GetParent():GetParent().db) then
		self.text:FontTemplate(LSM:Fetch("font", E.db["unitframe"].font), self:GetParent():GetParent().db[self:GetParent().type].fontSize, E.db["unitframe"].fontOutline);
		self.text:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatid], E.TimeFormats[formatid][2]), timervalue);
	end
end

function UF:CheckFilter(filterType, isFriend)
	local FRIENDLY_CHECK, ENEMY_CHECK = false, false;
	if(type(filterType) == "boolean") then
		FRIENDLY_CHECK = filterType;
		ENEMY_CHECK = filterType;
	elseif(filterType) then
		FRIENDLY_CHECK = filterType.friendly;
		ENEMY_CHECK = filterType.enemy;
	end

	if((FRIENDLY_CHECK and isFriend) or (ENEMY_CHECK and not isFriend)) then
		return true;
	end

	return false;
end

function UF:AuraFilter(unit, icon, name, _, _, _, dtype, duration, _, _, isStealable, shouldConsolidate, spellID)
	local db = self:GetParent().db;
	if(not db or not db[self.type]) then return true; end

	db = db[self.type];

	local returnValue = true;
	local passPlayerOnlyCheck = true;
	local anotherFilterExists = false;
	local playerOnlyFilter = false;
	local isFriend = UnitIsFriend("player", unit) == 1 and true or false;

	icon.name = name;
	icon.priority = 0;

	local turtleBuff = (E.global["unitframe"]["aurafilters"]["TurtleBuffs"].spells[spellID] or E.global["unitframe"]["aurafilters"]["TurtleBuffs"].spells[name]);
	if(turtleBuff and turtleBuff.enable) then
		icon.priority = turtleBuff.priority;
	end

	if(UF:CheckFilter(db.playerOnly, isFriend)) then
		if(icon.isPlayer) then
			returnValue = true;
		else
			returnValue = false;
		end

		if(not db.additionalFilterAllowNonPersonal) then
			passPlayerOnlyCheck = returnValue;
		end
		playerOnlyFilter = true;
	end

	if(UF:CheckFilter(db.onlyDispellable, isFriend)) then
		if((self.type == "buffs" and not isStealable) or (self.type == "debuffs" and dtype and not E:IsDispellableByMe(dtype)) or dtype == nil) then
			returnValue = false;
		end
		anotherFilterExists = true;
	end

	if(UF:CheckFilter(db.noConsolidated, isFriend)) then
		if(shouldConsolidate == 1) then
			returnValue = false;
		end

		anotherFilterExists = true;
	end

	if(UF:CheckFilter(db.noDuration, isFriend)) then
		if(duration == 0 or not duration) then
			returnValue = false;
		end

		anotherFilterExists = true;
	end

	if(UF:CheckFilter(db.useBlacklist, isFriend)) then
		local blackList = (E.global["unitframe"]["aurafilters"]["Blacklist"].spells[spellID] or E.global["unitframe"]["aurafilters"]["Blacklist"].spells[name]);
		if(blackList and blackList.enable) then
			returnValue = false;
		end

		anotherFilterExists = true;
	end

	if(UF:CheckFilter(db.useWhitelist, isFriend)) then
		local whiteList = (E.global["unitframe"]["aurafilters"]["Whitelist"].spells[spellID] or E.global["unitframe"]["aurafilters"]["Whitelist"].spells[name]);
		if(whiteList and whiteList.enable) then
			returnValue = true;
			icon.priority = whiteList.priority;
		elseif(not anotherFilterExists and not playerOnlyFilter) then
			returnValue = false;
		end

		anotherFilterExists = true;
	end

	if(db.useFilter and E.global["unitframe"]["aurafilters"][db.useFilter]) then
		local type = E.global["unitframe"]["aurafilters"][db.useFilter].type;
		local spellList = E.global["unitframe"]["aurafilters"][db.useFilter].spells;
		local spell = (spellList[spellID] or spellList[name]);

		if(type == "Whitelist") then
			if(spell and spell.enable and passPlayerOnlyCheck) then
				returnValue = true;
				icon.priority = spell.priority;
			elseif not anotherFilterExists then
				returnValue = false;
			end
		elseif(type == "Blacklist" and spell and spell.enable) then
			returnValue = false;
		end
	end

	return returnValue;
end

function UF:UpdateBuffsHeaderPosition()
	local parent = self:GetParent();
	local buffs = parent.Buffs;
	local debuffs = parent.Debuffs;
	local numDebuffs = self.visibleDebuffs;

	if(numDebuffs == 0) then
		buffs:ClearAllPoints();
		buffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset);
	else
		buffs:ClearAllPoints();
		buffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset);
	end
end

function UF:UpdateDebuffsHeaderPosition()
	local parent = self:GetParent();
	local debuffs = parent.Debuffs;
	local buffs = parent.Buffs;
	local numBuffs = self.visibleBuffs;

	if(numBuffs == 0) then
		debuffs:ClearAllPoints();
		debuffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset);
	else
		debuffs:ClearAllPoints();
		debuffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset);
	end
end
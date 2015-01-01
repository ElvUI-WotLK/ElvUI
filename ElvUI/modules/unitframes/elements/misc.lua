local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule('UnitFrames');

local random, floor, ceil = math.random, math.floor, math.ceil
local format = string.format

local LSM = LibStub("LibSharedMedia-3.0");

function UF:Construct_TargetGlow(frame)
	frame:CreateShadow('Default')
	local x = frame.shadow
	frame.shadow = nil
	x:Hide();
	
	return x
end

function UF:Construct_RestingIndicator(frame)
	local resting = frame:CreateTexture(nil, "OVERLAY")
	resting:Size(22)
	resting:Point("CENTER", frame.Health, "TOPLEFT", -3, 6)
	
	return resting
end

function UF:Construct_CombatIndicator(frame)
	local combat = frame:CreateTexture(nil, "OVERLAY")
	combat:Size(19)
	combat:Point("CENTER", frame.Health, "CENTER", 0,6)
	combat:SetVertexColor(0.69, 0.31, 0.31)
	
	return combat
end

function UF:Construct_PvPIndicator(frame)
	local pvp = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(pvp)

	return pvp
end

function UF:Construct_Combobar(frame)
	local CPoints = CreateFrame("Frame", nil, frame)
	CPoints:CreateBackdrop('Default')
	CPoints.Override = UF.UpdateComboDisplay

	for i = 1, MAX_COMBO_POINTS do
		CPoints[i] = CreateFrame("StatusBar", nil, CPoints)
		UF['statusbars'][CPoints[i]] = true
		CPoints[i]:SetStatusBarTexture(E['media'].blankTex)
		CPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		CPoints[i]:SetAlpha(0.15)
		CPoints[i]:CreateBackdrop('Default')
		CPoints[i].backdrop:SetParent(CPoints)
	end

	return CPoints
end

function UF:Construct_AuraWatch(frame)
	local auras = CreateFrame("Frame", nil, frame)
	auras:SetFrameLevel(frame:GetFrameLevel() + 25)
	auras:SetInside(frame.Health)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.strictMatching = true;
	auras.icons = {}
	
	return auras
end

function UF:Construct_RaidDebuffs(frame)
	local rdebuff = CreateFrame('Frame', nil, frame.RaisedElementParent)
	rdebuff:SetTemplate("Default")
	
	if E.PixelMode then
		rdebuff.border = rdebuff:CreateTexture(nil, "BACKGROUND");
		rdebuff.border:Point("TOPLEFT", -E.mult, E.mult);
		rdebuff.border:Point("BOTTOMRIGHT", E.mult, -E.mult);
		rdebuff.border:SetTexture(E["media"].blankTex);
		rdebuff.border:SetVertexColor(0, 0, 0);
	end	
	
	rdebuff.icon = rdebuff:CreateTexture(nil, 'OVERLAY')
	rdebuff.icon:SetTexCoord(unpack(E.TexCoords))
	rdebuff.icon:SetInside()
	
	rdebuff.count = rdebuff:CreateFontString(nil, 'OVERLAY')
	rdebuff.count:FontTemplate(nil, 10, 'OUTLINE')
	rdebuff.count:SetPoint('BOTTOMRIGHT', 0, 2)
	rdebuff.count:SetTextColor(1, .9, 0)
	
	rdebuff.time = rdebuff:CreateFontString(nil, 'OVERLAY')
	rdebuff.time:FontTemplate(nil, 10, 'OUTLINE')
	rdebuff.time:SetPoint('CENTER')
	rdebuff.time:SetTextColor(1, .9, 0)
	
	return rdebuff
end

function UF:Construct_DebuffHighlight(frame)
	local dbh = frame:CreateTexture(nil, "OVERLAY")
	dbh:SetInside(frame.Health.backdrop)
	dbh:SetTexture(E['media'].blankTex)
	dbh:SetVertexColor(0, 0, 0, 0)
	dbh:SetBlendMode("ADD")
	frame.DebuffHighlightFilter = true
	frame.DebuffHighlightAlpha = 0.45
	
	if frame.Health then
		dbh:SetParent(frame.Health)
	end
	
	return dbh
end

function UF:Construct_ReadyCheckIcon(frame)
	local f = CreateFrame("FRAME", nil, frame)
	f:SetFrameStrata("HIGH")
	f:SetFrameLevel(100)
	
	local tex = f:CreateTexture(nil, "OVERLAY", nil, 7)
	tex:Size(12)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)
	
	return tex
end

function UF:Construct_Trinket(frame)
	local trinket = CreateFrame("Frame", nil, frame)
	trinket.bg = CreateFrame("Frame", nil, trinket)
	trinket.bg:SetTemplate("Default")
	trinket.bg:SetFrameLevel(trinket:GetFrameLevel() - 1)
	trinket:SetInside(trinket.bg)
	
	return trinket
end

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame)
	frame.Leader = anchor:CreateTexture(nil, 'OVERLAY')
	frame.MasterLooter = anchor:CreateTexture(nil, 'OVERLAY')
	
	anchor:Size(24, 12)
	frame.Leader:Size(12)
	frame.MasterLooter:Size(11)
	
	frame.Leader.PostUpdate = UF.RaidRoleUpdate
	frame.MasterLooter.PostUpdate = UF.RaidRoleUpdate
	
	return anchor
end

function UF:Construct_Range(frame)
	return {insideAlpha = 1, outsideAlpha = E.db.unitframe.OORAlpha}
end

function UF:UpdateTargetGlow(event)
	if not self.unit then return; end
	local unit = self.unit
	
	if UnitIsUnit(unit, 'target') then
		self.TargetGlow:Show()
		local reaction = UnitReaction(unit, 'player')
		
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			if class then
				local color = RAID_CLASS_COLORS[class]
				self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
			end
		elseif reaction then
			local color = FACTION_BAR_COLORS[reaction]
			self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
		end
	else
		self.TargetGlow:Hide()
	end
end

function UF:UpdateComboDisplay(event, unit)
	if (unit == 'pet') then return end
	local db = UF.player.db
	local cpoints = self.CPoints
	local cp = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and GetComboPoints('vehicle', 'target') or GetComboPoints('player', 'target')

	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			cpoints[i]:SetAlpha(1)
		else
			cpoints[i]:SetAlpha(.15)	
		end	
	end
	
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local db = E.db['unitframe']['units'].target
	local USE_COMBOBAR = db.combobar.enable
	local USE_MINI_COMBOBAR = db.combobar.fill == "spaced" and USE_COMBOBAR and not db.combobar.detachFromFrame
	local COMBOBAR_HEIGHT = db.combobar.height
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local PORTRAIT_OFFSET_Y = ((COMBOBAR_HEIGHT/2) + SPACING - BORDER)
	local HEALTH_OFFSET_Y
	local DETACHED = db.combobar.detachFromFrame
	
	if not self.Portrait then
		self.Portrait = db.portrait.style == '2D' and self.Portrait2D or self.Portrait3D
	end

	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0
	end

	if DETACHED then
		PORTRAIT_OFFSET_Y = 0
	end
	
	if cpoints[1]:GetAlpha() == 1 or not db.combobar.autoHide then
		cpoints:Show()
		if USE_MINI_COMBOBAR then
			HEALTH_OFFSET_Y = DETACHED and 0 or (SPACING + (COMBOBAR_HEIGHT/2))
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -PORTRAIT_OFFSET_Y)
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -HEALTH_OFFSET_Y)
		else
			HEALTH_OFFSET_Y = DETACHED and 0 or (SPACING + COMBOBAR_HEIGHT)
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(BORDER + HEALTH_OFFSET_Y))
		end
	else
		cpoints:Hide()
		self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT")
		self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -BORDER)
	end
end

local counterOffsets = {
	['TOPLEFT'] = {6, 1},
	['TOPRIGHT'] = {-6, 1},
	['BOTTOMLEFT'] = {6, 1},
	['BOTTOMRIGHT'] = {-6, 1},
	['LEFT'] = {6, 1},
	['RIGHT'] = {-6, 1},
	['TOP'] = {0, 0},
	['BOTTOM'] = {0, 0},
}

local textCounterOffsets = {
	['TOPLEFT'] = {"LEFT", "RIGHT", -2, 0},
	['TOPRIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['BOTTOMLEFT'] = {"LEFT", "RIGHT", -2, 0},
	['BOTTOMRIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['LEFT'] = {"LEFT", "RIGHT", -2, 0},
	['RIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['TOP'] = {"RIGHT", "LEFT", 2, 0},
	['BOTTOM'] = {"RIGHT", "LEFT", 2, 0},
}

function UF:UpdateAuraWatchFromHeader(group)
	assert(self[group], "Invalid group specified.")
	for i=1, self[group]:GetNumChildren() do
		local frame = select(i, self[group]:GetChildren())
		if frame and frame.Health then
			UF:UpdateAuraWatch(frame)
		end
	end
end

function UF:UpdateAuraWatch(frame)
	local buffs = {};
	local auras = frame.AuraWatch;
	local db = frame.db.buffIndicator;

	if not db.enable then
		auras:Hide()
		return;
	else
		auras:Show()
	end
	
	local buffWatch = E.global['unitframe'].buffwatch[E.myclass] or {}
	for _, value in pairs(buffWatch) do
		if value.style == 'text' then value.style = 'NONE' end --depreciated
		tinsert(buffs, value);
	end
	
	--CLEAR CACHE
	if auras.icons then
		for i=1, #auras.icons do
			local matchFound = false;
			for j=1, #buffs do
				if #buffs[j].id and #buffs[j].id == auras.icons[i] then
					matchFound = true;
					break;
				end
			end
			
			if not matchFound then
				auras.icons[i]:Hide()
				auras.icons[i] = nil;
			end
		end
	end
	
	local unitframeFont = LSM:Fetch("font", E.db['unitframe'].font)
	
	for i=1, #buffs do
		if buffs[i].id then
			local name, _, image = GetSpellInfo(buffs[i].id);
			if name then
				local icon
				if not auras.icons[buffs[i].id] then
					icon = CreateFrame("Frame", nil, auras);
				else
					icon = auras.icons[buffs[i].id];
				end
				icon.name = name
				icon.image = image
				icon.spellID = buffs[i].id;
				icon.anyUnit = buffs[i].anyUnit;
				icon.style = buffs[i].style;
				icon.onlyShowMissing = buffs[i].onlyShowMissing;
				icon.presentAlpha = icon.onlyShowMissing and 0 or 1;
				icon.missingAlpha = icon.onlyShowMissing and 1 or 0;
				icon.textThreshold = buffs[i].textThreshold or -1
				icon.displayText = buffs[i].displayText
				
				icon:Width(db.size);
				icon:Height(db.size);
				icon:ClearAllPoints()
				icon:SetPoint(buffs[i].point, frame.Health, buffs[i].point, buffs[i].xOffset, buffs[i].yOffset);
				

				if not icon.icon then
					icon.icon = icon:CreateTexture(nil, "BORDER");
					icon.icon:SetAllPoints(icon);
				end
				
				if not icon.text then
					local f = CreateFrame('Frame', nil, icon)
					f:SetFrameLevel(icon:GetFrameLevel() + 50)
					icon.text = f:CreateFontString(nil, 'BORDER');
				end
				
				if not icon.border then
					icon.border = icon:CreateTexture(nil, "BACKGROUND");
					icon.border:Point("TOPLEFT", -E.mult, E.mult);
					icon.border:Point("BOTTOMRIGHT", E.mult, -E.mult);
					icon.border:SetTexture(E["media"].blankTex);
					icon.border:SetVertexColor(0, 0, 0);
				end
				
				if not icon.cd then
					icon.cd = CreateFrame("Cooldown", nil, icon)
					icon.cd:SetAllPoints(icon)
					icon.cd:SetReverse(true)
					icon.cd:SetFrameLevel(icon:GetFrameLevel())
				end			

				if icon.style == 'coloredIcon' then
					icon.icon:SetTexture(E["media"].blankTex);
					
					if (buffs[i]["color"]) then
						icon.icon:SetVertexColor(buffs[i]["color"].r, buffs[i]["color"].g, buffs[i]["color"].b);
					else
						icon.icon:SetVertexColor(0.8, 0.8, 0.8);
					end		
					icon.icon:Show()
					icon.border:Show()
					icon.cd:SetAlpha(1)
				elseif icon.style == 'texturedIcon' then
					icon.icon:SetVertexColor(1, 1, 1)
					icon.icon:SetTexCoord(.18, .82, .18, .82);
					icon.icon:SetTexture(icon.image);
					icon.icon:Show()
					icon.border:Show()
					icon.cd:SetAlpha(1)
				else
					icon.border:Hide()
					icon.icon:Hide()
					icon.cd:SetAlpha(0)
				end
				
				if icon.displayText then
					icon.text:Show()
					local r, g, b = 1, 1, 1
					if buffs[i].textColor then
						r, g, b = buffs[i].textColor.r, buffs[i].textColor.g, buffs[i].textColor.b
					end
					
					icon.text:SetTextColor(r, g, b)
				else
					icon.text:Hide()
				end
	
				if not icon.count then
					icon.count = icon:CreateFontString(nil, "OVERLAY");
				end
				
				icon.count:ClearAllPoints();
				if(icon.displayText) then
					local point, anchorPoint, x, y = unpack(textCounterOffsets[buffs[i].point]);
					icon.count:SetPoint(point, icon.text, anchorPoint, x, y);
				else
					icon.count:SetPoint("CENTER", unpack(counterOffsets[buffs[i].point]));
				end
				
				icon.count:FontTemplate(unitframeFont, db.fontSize, 'OUTLINE');
				icon.text:FontTemplate(unitframeFont, db.fontSize, 'OUTLINE');
				icon.text:ClearAllPoints();
				icon.text:SetPoint(buffs[i].point, icon, buffs[i].point);
				
				if(buffs[i].enabled) then
					auras.icons[buffs[i].id] = icon;
					if auras.watched then
						auras.watched[buffs[i].id] = icon;
					end
				else	
					auras.icons[buffs[i].id] = nil;
					if(auras.watched) then
						auras.watched[buffs[i].id] = nil;
					end
					
					icon:Hide();
					icon = nil;
				end
			end
		end
	end
	
	if(frame.AuraWatch.Update) then
		frame.AuraWatch.Update(frame);
	end
	
	buffs = nil;
end

function UF:Construct_RoleIcon(frame)
	local f = CreateFrame('Frame', nil, frame);
	
	local tex = f:CreateTexture(nil, 'ARTWORK');
	tex:Size(17);
	tex:Point('BOTTOM', frame.Health, 'BOTTOM', 0, 2);
	
	return tex;
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent();
	local Leader = anchor:GetParent().Leader;
	local MasterLooter = anchor:GetParent().MasterLooter;
	
	if(not Leader or not MasterLooter) then
		return;
	end
	
	local unit = anchor:GetParent().unit;
	local db = anchor:GetParent().db;
	local isLeader = Leader:IsShown();
	local isMasterLooter = MasterLooter:IsShown();
	
	Leader:ClearAllPoints();
	MasterLooter:ClearAllPoints();
	
	if(db and db.raidRoleIcons) then
		if(isLeader and db.raidRoleIcons.position == 'TOPLEFT') then
			Leader:Point('LEFT', anchor, 'LEFT');
			MasterLooter:Point('RIGHT', anchor, 'RIGHT');
		elseif(isLeader and db.raidRoleIcons.position == 'TOPRIGHT') then
			Leader:Point('RIGHT', anchor, 'RIGHT');
			MasterLooter:Point('LEFT', anchor, 'LEFT');
		elseif(isMasterLooter and db.raidRoleIcons.position == 'TOPLEFT') then
			MasterLooter:Point('LEFT', anchor, 'LEFT');
		else
			MasterLooter:Point('RIGHT', anchor, 'RIGHT');
		end
	end
end
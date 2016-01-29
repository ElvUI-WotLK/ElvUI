local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local tinsert = table.insert;

local RegisterStateDriver = RegisterStateDriver;
local InCombatLockdown = InCombatLockdown

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_TankFrames(unitGroup)
	self:SetScript("OnEnter", UnitFrame_OnEnter);
	self:SetScript("OnLeave", UnitFrame_OnLeave);
	
	self.Health = UF:Construct_HealthBar(self, true);
	self.Name = UF:Construct_NameText(self);
	self.Threat = UF:Construct_Threat(self);
	self.RaidIcon = UF:Construct_RaidIcon(self);
	self.Range = UF:Construct_Range(self);
	
	if(not self.isChild) then
		self.Buffs = UF:Construct_Buffs(self);
		self.Debuffs = UF:Construct_Debuffs(self);
		self.AuraWatch = UF:Construct_AuraWatch(self);
		self.DebuffHighlight = UF:Construct_DebuffHighlight(self);
	end
	
	UF:Update_TankFrames(self, E.db["unitframe"]["units"]["tank"]);
	UF:Update_StatusBars();
	UF:Update_FontStrings();
	
	self.originalParent = self:GetParent();
	
	return self;
end

function UF:Update_TankHeader(header, db)
	header:Hide();
	header.db = db;
	
	UF:ClearChildPoints(header:GetChildren());
	
	header:SetAttribute("startingIndex", -1);
	RegisterStateDriver(header, "visibility", "show")
	header.dirtyWidth, header.dirtyHeight = header:GetSize();
	RegisterStateDriver(header, "visibility", "[@raid1,exists] show;hide");
	header:SetAttribute("startingIndex", 1);
	
	header:SetAttribute("point", "BOTTOM");
	header:SetAttribute("columnAnchorPoint", "LEFT");
	
	UF:ClearChildPoints(header:GetChildren());
	header:SetAttribute("yOffset", 7);
	
	if(not header.positioned) then
		header:ClearAllPoints();
		header:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -186);
		
		E:CreateMover(header, header:GetName().."Mover", L["MT Frames"], nil, nil, nil, "ALL,RAID10,RAID25,RAID40");
		header.mover.positionOverride = "TOPLEFT";
		header:SetAttribute("minHeight", header.dirtyHeight);
		header:SetAttribute("minWidth", header.dirtyWidth);
		header.positioned = true;
	end
end

function UF:Update_TankFrames(frame, db)
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local SHADOW_SPACING = SPACING+3;
	local UNIT_WIDTH = db.width;
	frame.colors = ElvUF.colors;
	frame.Range.outsideAlpha = E.db.unitframe.OORAlpha;
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp");
	if(frame.isChild and frame.originalParent) then
		local childDB = db.targetsGroup;
		frame.db = db.targetsGroup;
		if(not frame.originalParent.childList) then
			frame.originalParent.childList = {};
		end
		frame.originalParent.childList[frame] = true;
		
		if(not InCombatLockdown()) then
			if(childDB.enable) then
				frame:SetParent(frame.originalParent);
				frame:Size(childDB.width, childDB.height);
				frame:ClearAllPoints();
				frame:Point(E.InversePoints[childDB.anchorPoint], frame.originalParent, childDB.anchorPoint, childDB.xOffset, childDB.yOffset);
			else
				frame:SetParent(E.HiddenFrame);
			end
		end
	elseif(not InCombatLockdown()) then
		frame.db = db;
		frame:SetAttribute("initial-height", db.height);
		frame:SetAttribute("initial-width", db.width);
	end
	
	do
		local health = frame.Health;
		health.Smooth = self.db.smoothbars;
		
		health.colorSmooth = nil;
		health.colorHealth = nil;
		health.colorClass = nil;
		health.colorReaction = nil;
		if(self.db["colors"].healthclass ~= true) then
			if(self.db["colors"].colorhealthbyvalue == true) then
				health.colorSmooth = true;
			else
				health.colorHealth = true;
			end
		else
			health.colorClass = (not self.db["colors"].forcehealthreaction);
			health.colorReaction = true;
		end
		
		health:ClearAllPoints();
		health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, -BORDER);
		health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER);
	end
	
	do
		local name = frame.Name;
		name:Point("CENTER", frame.Health, "CENTER");
		if(UF.db.colors.healthclass) then
			frame:Tag(name, "[name:medium]");
		else
			frame:Tag(name, "[namecolor][name:medium]");
		end
	end
	
	do
		local threat = frame.Threat;
		if(db.threatStyle ~= "NONE" and db.threatStyle ~= nil) then
			if(not frame:IsElementEnabled("Threat")) then
				frame:EnableElement("Threat");
			end

			if(db.threatStyle == "GLOW") then
				threat:SetFrameStrata("BACKGROUND");
				threat.glow:ClearAllPoints();
				threat.glow:SetBackdropBorderColor(0, 0, 0, 0);
				threat.glow:Point("TOPLEFT", frame.Health.backdrop, "TOPLEFT", -SHADOW_SPACING, SHADOW_SPACING);
				threat.glow:Point("TOPRIGHT", frame.Health.backdrop, "TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING);
				threat.glow:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING);
				threat.glow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING);
			elseif(db.threatStyle == "ICONTOPLEFT" or db.threatStyle == "ICONTOPRIGHT" or db.threatStyle == "ICONBOTTOMLEFT" or db.threatStyle == "ICONBOTTOMRIGHT" or db.threatStyle == "ICONTOP" or db.threatStyle == "ICONBOTTOM" or db.threatStyle == "ICONLEFT" or db.threatStyle == "ICONRIGHT") then
				threat:SetFrameStrata("HIGH");
				local point = db.threatStyle;
				point = point:gsub("ICON", "");
				
				threat.texIcon:ClearAllPoints();
				threat.texIcon:SetPoint(point, frame.Health, point);
			end
		elseif(frame:IsElementEnabled("Threat")) then
			frame:DisableElement("Threat");
		end
	end
	
	do
		local range = frame.Range;
		if(db.rangeCheck) then
			if(not frame:IsElementEnabled("Range")) then
				frame:EnableElement("Range");
			end
			
			range.outsideAlpha = E.db.unitframe.OORAlpha;
		else
			if(frame:IsElementEnabled("Range")) then
				frame:DisableElement("Range");
			end
		end
	end
	
	if(not frame.isChild) then
		do
			if(db.debuffs.enable or db.buffs.enable) then
				frame:EnableElement("Aura");
			else
				frame:DisableElement("Aura");
			end
			
			frame.Buffs:ClearAllPoints();
			frame.Debuffs:ClearAllPoints();
		end
		
		do
			local buffs = frame.Buffs;
			local rows = db.buffs.numrows;
			
			buffs:Width(UNIT_WIDTH);
			buffs.forceShow = frame.forceShowAuras;
			buffs.num = db.buffs.perrow * rows;
			buffs.size = db.buffs.sizeOverride ~= 0 and db.buffs.sizeOverride or ((((buffs:GetWidth() - (buffs.spacing*(buffs.num/rows - 1))) / buffs.num)) * rows);
			
			if(db.buffs.sizeOverride and db.buffs.sizeOverride > 0) then
				buffs:Width(db.buffs.perrow * db.buffs.sizeOverride);
			end
			
			local x, y = E:GetXYOffset(db.buffs.anchorPoint);
			local attachTo = self:GetAuraAnchorFrame(frame, db.buffs.attachTo);
			
			buffs:Point(E.InversePoints[db.buffs.anchorPoint], attachTo, db.buffs.anchorPoint, x + db.buffs.xOffset, y + db.buffs.yOffset);
			buffs:Height(buffs.size * rows);
			buffs["growth-y"] = db.buffs.anchorPoint:find("TOP") and "UP" or "DOWN";
			buffs["growth-x"] = db.buffs.anchorPoint == "LEFT" and "LEFT" or db.buffs.anchorPoint == "RIGHT" and "RIGHT" or (db.buffs.anchorPoint:find("LEFT") and "RIGHT" or "LEFT");
			buffs.initialAnchor = E.InversePoints[db.buffs.anchorPoint];
			
			if(db.buffs.enable) then
				buffs:Show();
				UF:UpdateAuraIconSettings(buffs);
			else
				buffs:Hide();
			end
		end
		
		do
			local debuffs = frame.Debuffs;
			local rows = db.debuffs.numrows;
			
			debuffs:Width(UNIT_WIDTH);
			debuffs.forceShow = frame.forceShowAuras;
			debuffs.num = db.debuffs.perrow * rows;
			debuffs.size = db.debuffs.sizeOverride ~= 0 and db.debuffs.sizeOverride or ((((debuffs:GetWidth() - (debuffs.spacing*(debuffs.num/rows - 1))) / debuffs.num)) * rows);
			
			if(db.debuffs.sizeOverride and db.debuffs.sizeOverride > 0) then
				debuffs:Width(db.debuffs.perrow * db.debuffs.sizeOverride);
			end
			
			local x, y = E:GetXYOffset(db.debuffs.anchorPoint);
			local attachTo = self:GetAuraAnchorFrame(frame, db.debuffs.attachTo, db.debuffs.attachTo == "BUFFS" and db.buffs.attachTo == "DEBUFFS");
			
			debuffs:Point(E.InversePoints[db.debuffs.anchorPoint], attachTo, db.debuffs.anchorPoint, x + db.debuffs.xOffset, y + db.debuffs.yOffset);
			debuffs:Height(debuffs.size * rows);
			debuffs["growth-y"] = db.debuffs.anchorPoint:find("TOP") and "UP" or "DOWN";
			debuffs["growth-x"] = db.debuffs.anchorPoint == "LEFT" and "LEFT" or db.debuffs.anchorPoint == "RIGHT" and "RIGHT" or (db.debuffs.anchorPoint:find("LEFT") and "RIGHT" or "LEFT");
			debuffs.initialAnchor = E.InversePoints[db.debuffs.anchorPoint];
			
			if(db.debuffs.enable) then
				debuffs:Show();
				UF:UpdateAuraIconSettings(debuffs);
			else
				debuffs:Hide();
			end
		end
		
		do
			local dbh = frame.DebuffHighlight;
			if(E.db.unitframe.debuffHighlighting ~= "NONE" and not db.disableDebuffHighlight) then
				frame:EnableElement("DebuffHighlight");
				frame.DebuffHighlightFilterTable = E.global.unitframe.DebuffHighlightColors;
				if(E.db.unitframe.debuffHighlighting == "GLOW") then
					frame.DebuffHighlightBackdrop = true;
					frame.DBHGlow:SetAllPoints(frame.Threat.glow);
				else
					frame.DebuffHighlightBackdrop = false;
				end		
			else
				frame:DisableElement("DebuffHighlight");
			end
		end
		
		UF:UpdateAuraWatch(frame);
	end
	
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentHealth, frame.Health, frame.Health.bg, true);

	frame:UpdateAllElements();
end

UF["headerstoload"]["tank"] = { "MAINTANK", "ELVUI_UNITTARGET" };
local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local _G = _G;
local pairs, unpack = pairs, unpack;
local tinsert = table.insert;
local format = format;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

local ArenaHeader = CreateFrame("Frame", "ArenaHeader", UIParent);

function UF:Construct_ArenaFrames(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, "RIGHT");
	frame.Name = self:Construct_NameText(frame);
	
	frame.Power = self:Construct_PowerBar(frame, true, true, "LEFT", false);
	frame.Portrait3D = self:Construct_Portrait(frame, "model");
	frame.Portrait2D = self:Construct_Portrait(frame, "texture");
	frame.Buffs = self:Construct_Buffs(frame);
	frame.Debuffs = self:Construct_Debuffs(frame);
	frame.Castbar = self:Construct_Castbar(frame, "RIGHT");
	frame.Trinket = self:Construct_Trinket(frame);
	frame.Range = UF:Construct_Range(frame);
	frame:SetAttribute("type2", "focus");
	
	frame.TargetGlow = UF:Construct_TargetGlow(frame);
	tinsert(frame.__elements, UF.UpdateTargetGlow);
	frame:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetGlow);
	frame:RegisterEvent("PLAYER_ENTERING_WORLD", UF.UpdateTargetGlow);
	frame:RegisterEvent("GROUP_ROSTER_UPDATE", UF.UpdateTargetGlow);
	frame.HealCommBar = UF:Construct_HealComm(frame);
	
	frame.customTexts = {};
	ArenaHeader:Point("BOTTOMRIGHT", E.UIParent, "RIGHT", -105, -165);
	E:CreateMover(ArenaHeader, ArenaHeader:GetName().."Mover", L["Arena Frames"], nil, nil, nil, "ALL,ARENA");
end

function UF:Update_ArenaFrames(frame, db)
	frame.db = db;
	if(frame.Portrait) then
		frame.Portrait:Hide();
		frame.Portrait:ClearAllPoints();
		frame.Portrait.backdrop:Hide();
	end
	
	frame.Portrait = db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D;
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local INDEX = frame.index;
	local UNIT_WIDTH = db.width;
	local UNIT_HEIGHT = db.height;
	local SHADOW_SPACING = E.PixelMode and 3 or 4;
	local USE_POWERBAR = db.power.enable;
	local USE_MINI_POWERBAR = db.power.width == "spaced" and USE_POWERBAR;
	local USE_INSET_POWERBAR = db.power.width == "inset" and USE_POWERBAR;
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR;
	local POWERBAR_OFFSET = db.power.offset;
	local POWERBAR_HEIGHT = db.power.height;
	local POWERBAR_WIDTH = db.width - (BORDER*2);
	
	local USE_PORTRAIT = db.portrait.enable;
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT;
	local PORTRAIT_WIDTH = db.portrait.width;
	
	local unit = self.unit;
	frame.colors = ElvUF.colors;
	frame:Size(UNIT_WIDTH, UNIT_HEIGHT);
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp");
	
	do
		if(not USE_POWERBAR) then
			POWERBAR_HEIGHT = 0;
		end
		
		if(USE_PORTRAIT_OVERLAY or not USE_PORTRAIT) then
			PORTRAIT_WIDTH = 0;	
		end
		
		if(USE_MINI_POWERBAR) then
			POWERBAR_WIDTH = POWERBAR_WIDTH / 2;
		end
	end
	
	do
		local health = frame.Health;
		health.Smooth = self.db.smoothbars;
		
		local x, y = self:GetPositionOffset(db.health.position);
		health.value:ClearAllPoints();
		health.value:Point(db.health.position, health, db.health.position, x + db.health.xOffset, y + db.health.yOffset);
		frame:Tag(health.value, db.health.text_format);
		
		health.colorSmooth = nil;
		health.colorHealth = nil;
		health.colorClass = nil;
		health.colorReaction = nil;
		if(db.colorOverride == "FORCE_ON") then
			health.colorClass = true;
			health.colorReaction = true;
		elseif(db.colorOverride == "FORCE_OFF") then
			if(self.db["colors"].colorhealthbyvalue == true) then
				health.colorSmooth = true;
			else
				health.colorHealth = true;
			end
		else
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
		end
		
		health:ClearAllPoints();
		health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, -BORDER);
		
		if(USE_POWERBAR_OFFSET) then
			health:Point("TOPRIGHT", frame, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER);
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER+POWERBAR_OFFSET);
		elseif(USE_INSET_POWERBAR or POWERBAR_DETACHED) then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER);
		elseif(USE_MINI_POWERBAR) then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2));
		else
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, (USE_POWERBAR and ((BORDER + SPACING)*2) or BORDER) + POWERBAR_HEIGHT);
		end
		
		health.bg:ClearAllPoints();
		if(not USE_PORTRAIT_OVERLAY) then
			health:Point("TOPLEFT", PORTRAIT_WIDTH+BORDER, -BORDER);
			health.bg:SetParent(health);
			health.bg:SetAllPoints();
		else
			health.bg:Point("BOTTOMLEFT", health:GetStatusBarTexture(), "BOTTOMRIGHT");
			health.bg:Point("TOPRIGHT", health);
			health.bg:SetParent(frame.Portrait.overlay);
		end
	end
	
	UF:UpdateNameSettings(frame);
	
	do
		local power = frame.Power;
		if(USE_POWERBAR) then
			if(not frame:IsElementEnabled("Power")) then
				frame:EnableElement("Power");
				power:Show();
			end
			power.Smooth = self.db.smoothbars;
			
			local x, y = self:GetPositionOffset(db.power.position);
			power.value:ClearAllPoints();
			power.value:Point(db.power.position, frame.Health, db.power.position, x + db.power.xOffset, y + db.power.yOffset);
			frame:Tag(power.value, db.power.text_format);
			
			power.colorClass = nil;
			power.colorReaction = nil;
			power.colorPower = nil;
			if(self.db["colors"].powerclass) then
				power.colorClass = true;
				power.colorReaction = true;
			else
				power.colorPower = true;
			end
			
			power:ClearAllPoints();
			if(USE_POWERBAR_OFFSET) then
				power:Point("TOPRIGHT", frame.Health, "TOPRIGHT", POWERBAR_OFFSET, -POWERBAR_OFFSET);
				power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", POWERBAR_OFFSET, -POWERBAR_OFFSET);
				power:SetFrameStrata("LOW");
				power:SetFrameLevel(2);
			elseif(USE_MINI_POWERBAR) then
				power:Width(POWERBAR_WIDTH - BORDER*2);
				power:Height(POWERBAR_HEIGHT);
				power:Point("RIGHT", frame, "BOTTOMRIGHT", -(BORDER*2 + 4), BORDER + (POWERBAR_HEIGHT/2));
				power:SetFrameStrata("MEDIUM");
				power:SetFrameLevel(frame:GetFrameLevel() + 3);
			elseif(USE_INSET_POWERBAR) then
				power:Height(POWERBAR_HEIGHT);
				power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", BORDER + (BORDER*2), BORDER + (BORDER*2));
				power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -(BORDER + (BORDER*2)), BORDER + (BORDER*2));
				power:SetFrameStrata("MEDIUM");
				power:SetFrameLevel(frame:GetFrameLevel() + 3);
			else
				power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", BORDER, -(E.PixelMode and 0 or (BORDER + SPACING)));
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -BORDER, BORDER);
			end
		elseif(frame:IsElementEnabled("Power")) then
			frame:DisableElement("Power");
			power:Hide();
		end
	end
	
	do
		local portrait = frame.Portrait;
		if(USE_PORTRAIT) then
			if(not frame:IsElementEnabled("Portrait")) then
				frame:EnableElement("Portrait");
			end
			
			portrait:ClearAllPoints();
			if(USE_PORTRAIT_OVERLAY) then
				if(db.portrait.style == "3D") then
					portrait:SetFrameLevel(frame.Health:GetFrameLevel() + 1);
				end
				
				portrait:SetAllPoints(frame.Health);
				portrait:SetAlpha(0.3);
				portrait:Show();
				portrait.backdrop:Hide();
			else
				portrait:SetAlpha(1);
				portrait:Show();
				portrait.backdrop:Show();
				portrait.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT");
				
				if(db.portrait.style == "3D") then
					portrait:SetFrameLevel(frame:GetFrameLevel() + 5);
				end
				
				if(USE_MINI_POWERBAR or USE_POWERBAR_OFFSET or not USE_POWERBAR or USE_INSET_POWERBAR or POWERBAR_DETACHED) then
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMLEFT", E.PixelMode and 1 or -SPACING, 0);
				else
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMLEFT", E.PixelMode and 1 or -SPACING, 0);
				end
				
				portrait:Point("BOTTOMLEFT", portrait.backdrop, "BOTTOMLEFT", BORDER, BORDER);
				portrait:Point("TOPRIGHT", portrait.backdrop, "TOPRIGHT", -BORDER, -BORDER);			
			end
		else
			if(frame:IsElementEnabled("Portrait")) then
				frame:DisableElement("Portrait");
				portrait:Hide();
				portrait.backdrop:Hide();
			end
		end
	end
	
	do
		local tGlow = frame.TargetGlow;
		tGlow:ClearAllPoints();
		
		tGlow:Point("TOPLEFT", -SHADOW_SPACING, SHADOW_SPACING);
		tGlow:Point("TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING);
		
		if(USE_MINI_POWERBAR) then
			tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING + (POWERBAR_HEIGHT/2));
			tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING + (POWERBAR_HEIGHT/2));
		else
			tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING);
			tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING);
		end
		
		if(USE_POWERBAR_OFFSET) then
			tGlow:Point("TOPLEFT", -SHADOW_SPACING, SHADOW_SPACING);
			tGlow:Point("TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING);
			tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING+POWERBAR_OFFSET, -SHADOW_SPACING+POWERBAR_OFFSET);
			tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING+POWERBAR_OFFSET);
		end
	end
	
	do
		if(db.debuffs.enable or db.buffs.enable) then
			if(not frame:IsElementEnabled("Aura")) then
				frame:EnableElement("Aura");
			end
		else
			if(frame:IsElementEnabled("Aura")) then
				frame:DisableElement("Aura");
			end
		end
		
		frame.Buffs:ClearAllPoints();
		frame.Debuffs:ClearAllPoints();
	end
	
	do
		local buffs = frame.Buffs;
		local rows = db.buffs.numrows;
		
		if(USE_POWERBAR_OFFSET) then
			buffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET);
		else
			buffs:SetWidth(UNIT_WIDTH);
		end
		
		buffs.forceShow = frame.forceShowAuras;
		buffs.num = db.buffs.perrow * rows;
		buffs.size = db.buffs.sizeOverride ~= 0 and db.buffs.sizeOverride or ((((buffs:GetWidth() - (buffs.spacing*(buffs.num/rows - 1))) / buffs.num)) * rows);
		
		if(db.buffs.sizeOverride and db.buffs.sizeOverride > 0) then
			buffs:SetWidth(db.buffs.perrow * db.buffs.sizeOverride);
		end
		
		local x, y = E:GetXYOffset(db.buffs.anchorPoint);
		local attachTo = self:GetAuraAnchorFrame(frame, db.buffs.attachTo);
		
		buffs:Point(E.InversePoints[db.buffs.anchorPoint], attachTo, db.buffs.anchorPoint, x + db.buffs.xOffset, y + db.buffs.yOffset + (E.PixelMode and (db.buffs.anchorPoint:find("TOP") and -1 or 1) or 0));
		buffs:Height(buffs.size * rows);
		buffs["growth-y"] = db.buffs.anchorPoint:find("TOP") and "UP" or "DOWN"
		buffs["growth-x"] = db.buffs.anchorPoint == "LEFT" and "LEFT" or  db.buffs.anchorPoint == "RIGHT" and "RIGHT" or (db.buffs.anchorPoint:find("LEFT") and "RIGHT" or "LEFT");
		buffs["spacing-x"] = db.buffs.xSpacing;
		buffs["spacing-y"] = db.buffs.ySpacing;
		buffs.initialAnchor = E.InversePoints[db.buffs.anchorPoint];
		
		buffs.attachTo = attachTo;
		buffs.point = E.InversePoints[db.buffs.anchorPoint];
		buffs.anchorPoint = db.buffs.anchorPoint;
		buffs.xOffset = x + db.buffs.xOffset;
		buffs.yOffset = y + db.buffs.yOffset + (E.PixelMode and (db.buffs.anchorPoint:find("TOP") and -1 or 1) or 0);
		
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
		
		if(USE_POWERBAR_OFFSET) then
			debuffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET);
		else
			debuffs:SetWidth(UNIT_WIDTH);
		end
		
		debuffs.forceShow = frame.forceShowAuras;
		debuffs.num = db.debuffs.perrow * rows;
		debuffs.size = db.debuffs.sizeOverride ~= 0 and db.debuffs.sizeOverride or ((((debuffs:GetWidth() - (debuffs.spacing*(debuffs.num/rows - 1))) / debuffs.num)) * rows);
		
		if(db.debuffs.sizeOverride and db.debuffs.sizeOverride > 0) then
			debuffs:SetWidth(db.debuffs.perrow * db.debuffs.sizeOverride);
		end
		
		local x, y = E:GetXYOffset(db.debuffs.anchorPoint);
		local attachTo = self:GetAuraAnchorFrame(frame, db.debuffs.attachTo, db.debuffs.attachTo == "BUFFS" and db.buffs.attachTo == "DEBUFFS");
		
		debuffs:Point(E.InversePoints[db.debuffs.anchorPoint], attachTo, db.debuffs.anchorPoint, x + db.debuffs.xOffset, y + db.debuffs.yOffset);
		debuffs:Height(debuffs.size * rows);
		debuffs["growth-y"] = db.debuffs.anchorPoint:find("TOP") and "UP" or "DOWN";
		debuffs["growth-x"] = db.debuffs.anchorPoint == "LEFT" and "LEFT" or  db.debuffs.anchorPoint == "RIGHT" and "RIGHT" or (db.debuffs.anchorPoint:find("LEFT") and "RIGHT" or "LEFT");
		debuffs["spacing-x"] = db.debuffs.xSpacing;
		debuffs["spacing-y"] = db.debuffs.ySpacing;
		debuffs.initialAnchor = E.InversePoints[db.debuffs.anchorPoint];
		
		debuffs.attachTo = attachTo;
		debuffs.point = E.InversePoints[db.debuffs.anchorPoint];
		debuffs.anchorPoint = db.debuffs.anchorPoint;
		debuffs.xOffset = x + db.debuffs.xOffset;
		debuffs.yOffset = y + db.debuffs.yOffset;
		
		if(db.debuffs.enable) then
			debuffs:Show();
			UF:UpdateAuraIconSettings(debuffs);
		else
			debuffs:Hide();
		end
	end
	
	do
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
	
	do
		local castbar = frame.Castbar;
		castbar:Width(db.castbar.width - (BORDER * 2))
		castbar:Height(db.castbar.height);
		
		if(db.castbar.icon) then
			castbar.Icon = castbar.ButtonIcon;
			castbar.Icon.bg:Width(db.castbar.height + (E.Border * 2));
			castbar.Icon.bg:Height(db.castbar.height + (E.Border * 2));
			
			castbar:Width(db.castbar.width - castbar.Icon.bg:GetWidth() - (E.PixelMode and 1 or 5));
			castbar.Icon.bg:Show();
		else
			castbar.ButtonIcon.bg:Hide();
			castbar.Icon = nil;
		end
		
		if(db.castbar.spark) then
			castbar.Spark:Show();
		else
			castbar.Spark:Hide();
		end
		
		castbar:ClearAllPoints();
		castbar:Point("TOPLEFT", frame, "BOTTOMLEFT", BORDER, -(BORDER*2+BORDER));
		
		if(db.castbar.enable and not frame:IsElementEnabled("Castbar")) then
			frame:EnableElement("Castbar");
		elseif(not db.castbar.enable and frame:IsElementEnabled("Castbar")) then
			frame:DisableElement("Castbar");
		end
	end
	
	do
		local trinket = frame.Trinket;
		trinket.bg:Size(db.pvpTrinket.size);
		trinket.bg:ClearAllPoints();
		if(db.pvpTrinket.position == "RIGHT") then
			trinket.bg:Point("LEFT", frame, "RIGHT", db.pvpTrinket.xOffset, db.pvpTrinket.yOffset);
		else
			trinket.bg:Point("RIGHT", frame, "LEFT", db.pvpTrinket.xOffset, db.pvpTrinket.yOffset);
		end
		
		if(db.pvpTrinket.enable and not frame:IsElementEnabled("Trinket")) then
			frame:EnableElement("Trinket");
		elseif(not db.pvpTrinket.enable and frame:IsElementEnabled("Trinket")) then
			frame:DisableElement("Trinket");
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
	
	do
		local healCommBar = frame.HealCommBar;
		local c = UF.db.colors.healPrediction;
		if(db.healPrediction) then
			if(not frame:IsElementEnabled("HealComm4")) then
				frame:EnableElement("HealComm4");
			end
			
			if(not USE_PORTRAIT_OVERLAY) then
				healCommBar.myBar:SetParent(frame.Health);
				healCommBar.otherBar:SetParent(frame.Health);
			else
				healCommBar.myBar:SetParent(frame.Portrait.overlay);
				healCommBar.otherBar:SetParent(frame.Portrait.overlay);
			end
			
			healCommBar.myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a);
			healCommBar.otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a);
		else
			if(frame:IsElementEnabled("HealComm4")) then
				frame:DisableElement("HealComm4");
			end
		end
	end
	
	for objectName, object in pairs(frame.customTexts) do
		if((not db.customTexts) or (db.customTexts and not db.customTexts[objectName])) then
			object:Hide();
			frame.customTexts[objectName] = nil;
		end
	end
	
	if(db.customTexts) then
		local customFont = UF.LSM:Fetch("font", UF.db.font);
		for objectName, _ in pairs(db.customTexts) do
			if(not frame.customTexts[objectName]) then
				frame.customTexts[objectName] = frame.RaisedElementParent:CreateFontString(nil, "OVERLAY");
			end
			
			local objectDB = db.customTexts[objectName];
			if(objectDB.font) then
				customFont = UF.LSM:Fetch("font", objectDB.font);
			end
			
			frame.customTexts[objectName]:FontTemplate(customFont, objectDB.size or UF.db.fontSize, objectDB.fontOutline or UF.db.fontOutline);
			frame:Tag(frame.customTexts[objectName], objectDB.text_format or "");
			frame.customTexts[objectName]:SetJustifyH(objectDB.justifyH or "CENTER");
			frame.customTexts[objectName]:ClearAllPoints();
			frame.customTexts[objectName]:SetPoint(objectDB.justifyH or "CENTER", frame, objectDB.justifyH or "CENTER", objectDB.xOffset, objectDB.yOffset);
		end
	end
	
	frame:ClearAllPoints();
	
	if(INDEX == 1) then
		if(db.growthDirection == "UP") then
			frame:SetPoint("BOTTOMRIGHT", ArenaHeaderMover, "BOTTOMRIGHT");
		elseif(db.growthDirection == "RIGHT") then
			frame:SetPoint("LEFT", ArenaHeaderMover, "LEFT");
		elseif(db.growthDirection == "LEFT") then
			frame:SetPoint("RIGHT", ArenaHeaderMover, "RIGHT");
		else --Down
			frame:SetPoint("TOPRIGHT", ArenaHeaderMover, "TOPRIGHT");
		end
	else
		if(db.growthDirection == "UP") then
			frame:SetPoint("BOTTOMRIGHT", _G["ElvUF_Arena"..INDEX-1], "TOPRIGHT", 0, db.spacing);
		elseif(db.growthDirection == "RIGHT") then
			frame:SetPoint("LEFT", _G["ElvUF_Arena"..INDEX-1], "RIGHT", db.spacing, 0);
		elseif(db.growthDirection == "LEFT") then
			frame:SetPoint("RIGHT", _G["ElvUF_Arena"..INDEX-1], "LEFT", -db.spacing, 0);
		else --Down
			frame:SetPoint("TOPRIGHT", _G["ElvUF_Arena"..INDEX-1], "BOTTOMRIGHT", 0, -db.spacing);
		end
	end
	
	if(db.growthDirection == "UP" or db.growthDirection == "DOWN") then
		ArenaHeader:SetWidth(UNIT_WIDTH);
		ArenaHeader:SetHeight(UNIT_HEIGHT + ((UNIT_HEIGHT + db.spacing) * 4));
	elseif(db.growthDirection == "LEFT" or db.growthDirection == "RIGHT") then
		ArenaHeader:SetWidth(UNIT_WIDTH + ((UNIT_WIDTH + db.spacing) * 4));
		ArenaHeader:SetHeight(UNIT_HEIGHT);
	end
	
	if(UF.db.colors.transparentHealth) then
		UF:ToggleTransparentStatusBar(true, frame.Health, frame.Health.bg);
	else
		UF:ToggleTransparentStatusBar(false, frame.Health, frame.Health.bg, (USE_PORTRAIT and USE_PORTRAIT_OVERLAY) ~= true);
	end
	
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.bg);
	
	frame:UpdateAllElements();
end

UF["unitgroupstoload"]["arena"] = { 5 };
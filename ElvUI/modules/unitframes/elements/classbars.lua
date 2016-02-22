local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local select = select;
local ceil, floor = math.ceil, math.floor;

local CreateFrame = CreateFrame;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame);
	runes:CreateBackdrop("Default");
	
	for i = 1, self["classMaxResourceBar"][E.myclass] do
		runes[i] = CreateFrame("StatusBar", nil, runes);
		self["statusbars"][runes[i]] = true;
		runes[i]:SetStatusBarTexture(E["media"].blankTex);
		runes[i]:GetStatusBarTexture():SetHorizTile(false);
		
		runes[i]:CreateBackdrop("Default");
		runes[i].backdrop:SetParent(runes);
		
		runes[i].bg = runes[i]:CreateTexture(nil, "BORDER");
		runes[i].bg:SetAllPoints();
		runes[i].bg:SetTexture(E["media"].blankTex);
		runes[i].bg.multiplier = 0.2;
	end
	
	return runes;
end

function UF:Construct_MageResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame);
	bars:CreateBackdrop("Default");

	for i = 1, UF["classMaxResourceBar"][E.myclass] do
		bars[i] = CreateFrame("StatusBar", nil, bars);
		bars[i]:SetStatusBarTexture(E["media"].blankTex);
		bars[i]:GetStatusBarTexture():SetHorizTile(false);
		
		bars[i].bg = bars[i]:CreateTexture(nil, "ARTWORK");
		
		UF["statusbars"][bars[i]] = true;

		bars[i]:CreateBackdrop("Default");
		bars[i].backdrop:SetParent(bars);
	end
	
	bars.PostUpdate = UF.UpdateArcaneCharges;
	
	return bars;
end

function UF:UpdateArcaneCharges(event, unit, arcaneCharges, maxCharges)
	local frame = self:GetParent();
	local db = frame.db;
	
	local point, _, anchorPoint, x, y = frame.Health:GetPoint();
	if(self:IsShown() and point) then
		if(db.classbar.fill == "spaced") then
			frame.Health:SetPoint(point, frame, anchorPoint, x, -7);
		else
			frame.Health:SetPoint(point, frame, anchorPoint, x, -13);
		end
	elseif(point) then
		frame.Health:SetPoint(point, frame, anchorPoint, x, -2);
	end
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown());
end

function UF:Construct_DruidAltManaBar(frame)
	local dpower = CreateFrame("Frame", nil, frame);
	dpower:SetFrameStrata("LOW");
	--dpower:SetAllPoints(frame.EclipseBar.backdrop);
	dpower:CreateBackdrop("Default");
	dpower:SetFrameLevel(dpower:GetFrameLevel() + 1);
	dpower.colorPower = true;
	dpower.PostUpdateVisibility = UF.DruidResourceBarVisibilityUpdate;
	dpower.PostUpdatePower = UF.DruidPostUpdateAltPower;

	dpower.ManaBar = CreateFrame("StatusBar", nil, dpower);
	UF["statusbars"][dpower.ManaBar] = true;
	dpower.ManaBar:SetStatusBarTexture(E["media"].blankTex);
	dpower.ManaBar:SetAllPoints(dpower);

	dpower.bg = dpower:CreateTexture(nil, "BORDER");
	dpower.bg:SetAllPoints(dpower.ManaBar);
	dpower.bg:SetTexture(E["media"].blankTex);
	dpower.bg.multiplier = 0.3;

	dpower.Text = dpower:CreateFontString(nil, "OVERLAY");
	UF:Configure_FontString(dpower.Text);

	return dpower;
end

function UF:DruidResourceBarVisibilityUpdate(unit)
	local parent = self:GetParent();
	
	UF:UpdatePlayerFrameAnchors(parent, self:IsShown());
end

function UF:DruidPostUpdateAltPower(unit, min, max)
	local powerText = self:GetParent().Power.value;

	if(min ~= max) then
		local color = ElvUF["colors"].power["MANA"];
		color = E:RGBToHex(color[1], color[2], color[3]);

		self.Text:ClearAllPoints();
		if(powerText:GetText()) then
			if(select(4, powerText:GetPoint()) < 0) then
				self.Text:SetPoint("RIGHT", powerText, "LEFT", 3, 0);
				self.Text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100));
			else
				self.Text:SetPoint("LEFT", powerText, "RIGHT", -3, 0)
				self.Text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100));
			end
		else
			self.Text:SetPoint(powerText:GetPoint());
			self.Text:SetFormattedText(color.."%d%%|r", floor(min / max * 100));
		end
	else
		self.Text:SetText();
	end
end
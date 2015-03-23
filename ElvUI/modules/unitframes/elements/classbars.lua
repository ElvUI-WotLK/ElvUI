local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

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
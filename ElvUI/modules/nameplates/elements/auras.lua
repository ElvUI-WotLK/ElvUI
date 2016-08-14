local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

local select, unpack = select, unpack;
local tinsert = table.insert;

local CreateFrame = CreateFrame;

local auraCache = {};

function mod:SetAura(aura, icon, count, duration, expirationTime)
	if(aura and icon and expirationTime) then
		aura.icon:SetTexture(icon);
		if(count > 1) then
			aura.count:SetText(count);
		else
			aura.count:SetText("");
		end
		aura:Show();
		mod.PolledHideIn(aura, expirationTime);
	else 
		mod.PolledHideIn(aura, 0);
	end
end

function mod:HideAuraIcons(auras)
	for i=1, #auras.icons do
		auras.icons[i]:Hide();
	end
end

function mod:CreateAuraIcon(parent)
	local aura = CreateFrame("Frame", nil, parent);
	self:CreateBackdrop(aura);

	aura.icon = aura:CreateTexture(nil, "OVERLAY");
	aura.icon:SetAllPoints();
	aura.icon:SetTexCoord(unpack(E.TexCoords));

	aura.timeLeft = aura:CreateFontString(nil, "OVERLAY");
	aura.timeLeft:SetPoint("TOPLEFT", 2, 2);
	aura.timeLeft:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);

	aura.count = aura:CreateFontString(nil, "OVERLAY");
	aura.count:SetPoint("BOTTOMRIGHT");
	aura.count:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
	aura.Poll = parent.PollFunction;

	return aura;
end

function mod:Auras_SizeChanged(width, height)
	local numAuras = #self.icons;
	for i = 1, numAuras do
		self.icons[i]:SetWidth((width - (E.mult*numAuras)) / numAuras);
		self.icons[i]:SetHeight((self.db.baseHeight or 18) * --[[self:GetParent().HealthBar.currentScale or ]] 1);
	end
end

function mod:UpdateAuraIcons(auras)
	local maxAuras = auras.db.numAuras;
	local numCurrentAuras = #auras.icons;
	if(numCurrentAuras > maxAuras) then
		for i = maxAuras, numCurrentAuras do
			tinsert(auraCache, auras.icons[i]);
			auras.icons[i]:Hide();
			auras.icons[i] = nil;
		end
	end

	if(numCurrentAuras ~= maxAuras) then
		self.Auras_SizeChanged(auras, auras:GetWidth(), auras:GetHeight());
	end

	for i = 1, maxAuras do
		auras.icons[i] = auras.icons[i] or tremove(auraCache) or mod:CreateAuraIcon(auras);
		auras.icons[i]:SetParent(auras);
		auras.icons[i]:ClearAllPoints();
		auras.icons[i]:Hide();
		auras.icons[i]:SetHeight(auras.db.baseHeight or 18);

		if(auras.side == "LEFT") then
			if(i == 1) then
				auras.icons[i]:SetPoint("LEFT", auras, "LEFT");
			else
				auras.icons[i]:SetPoint("LEFT", auras.icons[i-1], "RIGHT", E.Border + E.Spacing*3, 0);
			end
		else
			if(i == 1) then
				auras.icons[i]:SetPoint("RIGHT", auras, "RIGHT");
			else
				auras.icons[i]:SetPoint("RIGHT", auras.icons[i-1], "LEFT", -(E.Border + E.Spacing*3), 0);
			end
		end
	end
end

function mod:ConstructElement_Auras(frame, maxAuras, side)
	local auras = CreateFrame("Frame", nil, frame);

	auras:SetScript("OnSizeChanged", mod.Auras_SizeChanged);
	auras:SetHeight(18);
	auras.side = side;
	auras.PollFunction = mod.UpdateAuraTime;
	auras.icons = {};

	return auras;
end
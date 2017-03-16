local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local CreateFrame = CreateFrame;

function UF:Construct_Portrait(frame, type)
	local portrait;
	if(type == "texture") then
		local backdrop = CreateFrame("Frame", nil, frame);
		portrait = frame:CreateTexture(nil, "OVERLAY");
		portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85);
		backdrop:SetOutside(portrait);
		backdrop:SetFrameLevel(frame:GetFrameLevel());
		backdrop:SetTemplate("Default");
		portrait.backdrop = backdrop;
	else
		portrait = CreateFrame("PlayerModel", nil, frame);
		portrait:CreateBackdrop("Default", nil, nil, self.thinBorders);
	end

	portrait.PostUpdate = self.PortraitUpdate;

	portrait.overlay = CreateFrame("Frame", nil, frame);
	portrait.overlay:SetFrameLevel(frame.Health:GetFrameLevel() + 5);

	return portrait;
end

function UF:Configure_Portrait(frame, dontHide)
	if(not frame.VARIABLES_SET) then return; end
	local db = frame.db;
	if(frame.Portrait and not dontHide) then
		frame.Portrait:Hide();
		frame.Portrait:ClearAllPoints();
		frame.Portrait.backdrop:Hide();
	end
	frame.Portrait = db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D;

	local portrait = frame.Portrait;
	if(frame.USE_PORTRAIT) then
		if(not frame:IsElementEnabled("Portrait")) then
			frame:EnableElement("Portrait");
		end

		portrait:ClearAllPoints();
		portrait.backdrop:ClearAllPoints();
		if(frame.USE_PORTRAIT_OVERLAY) then
			if(db.portrait.style == "3D") then
				portrait:SetFrameLevel(frame.Health:GetFrameLevel());
			else
				portrait:SetParent(frame.Health);
			end

			portrait:SetAllPoints(frame.Health);
			portrait:SetAlpha(0.35);
			if(not dontHide) then
				portrait:Show();
			end
			portrait.backdrop:Hide();
		else
			portrait:SetAlpha(1);
			if(not dontHide) then
				portrait:Show();
			end
			portrait.backdrop:Show();
			if(db.portrait.style == "3D") then
				portrait:SetFrameLevel(frame.Health:GetFrameLevel() - 4);
			else
				portrait:SetParent(frame.Health);
			end

			if(frame.ORIENTATION == "LEFT") then
				portrait.backdrop:Point("TOPLEFT", frame, "TOPLEFT", frame.SPACING, frame.USE_MINI_CLASSBAR and -(frame.CLASSBAR_YOFFSET+frame.SPACING) or -frame.SPACING);

				if(frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR or frame.POWERBAR_DETACHED) then
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER - frame.SPACING*3, 0);
				else
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMLEFT", frame.BORDER - frame.SPACING*3, 0);
				end
			elseif(frame.ORIENTATION == "RIGHT") then
				portrait.backdrop:Point("TOPRIGHT", frame, "TOPRIGHT", -frame.SPACING, frame.USE_MINI_CLASSBAR and -(frame.CLASSBAR_YOFFSET+frame.SPACING) or -frame.SPACING);

				if(frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR or frame.POWERBAR_DETACHED) then
					portrait.backdrop:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMRIGHT", -frame.BORDER + frame.SPACING*3, 0);
				else
					portrait.backdrop:Point("BOTTOMLEFT", frame.Power.backdrop, "BOTTOMRIGHT", -frame.BORDER + frame.SPACING*3, 0);
				end
			end

			portrait:SetInside(portrait.backdrop, frame.BORDER);
		end
	else
		if(frame:IsElementEnabled("Portrait")) then
			frame:DisableElement("Portrait");
			portrait:Hide();
			portrait.backdrop:Hide();
		end
	end
end

function UF:PortraitUpdate()
	local db = self:GetParent().db;
	if(not db) then return; end

	local portrait = db.portrait;
	if(portrait.enable and self:GetParent().USE_PORTRAIT_OVERLAY) then
		self:SetAlpha(0);
		self:SetAlpha(0.35);
	else
		self:SetAlpha(1)
	end
end
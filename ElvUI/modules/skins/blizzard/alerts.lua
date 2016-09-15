local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, select = unpack, select;

local CreateFrame = CreateFrame;
local MAX_ACHIEVEMENT_ALERTS = MAX_ACHIEVEMENT_ALERTS;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.alertframes ~= true) then return; end

	local function AchievementFixAnchors()
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame" .. i];
			if(frame) then
				local frameName = frame:GetName();

				if(not frame.backdrop) then
					frame:CreateBackdrop("Transparent");
					frame.backdrop:Point("TOPLEFT", _G[frameName .. "Background"], "TOPLEFT", -2, -6);
					frame.backdrop:Point("BOTTOMRIGHT", _G[frameName .. "Background"], "BOTTOMRIGHT", -2, 6);
				end

				_G[frameName .. "Background"]:SetTexture(nil);
				_G[frameName .. "Glow"]:Kill();
				_G[frameName .. "Shine"]:Kill();

				_G[frameName .. "Unlocked"]:FontTemplate(nil, 12);
				_G[frameName .. "Unlocked"]:SetTextColor(1, 1, 1);
				_G[frameName .. "Name"]:FontTemplate(nil, 12);

				select(8, _G[frameName .. "Icon"]:GetRegions()):Hide();

				_G[frameName .. "IconTexture"]:SetTexCoord(unpack(E.TexCoords));
				_G[frameName .. "IconOverlay"]:Kill();

				_G[frameName .. "IconTexture"]:ClearAllPoints();
				_G[frameName .. "IconTexture"]:Point("LEFT", frame, 7, 0);

				if(not _G[frameName .. "IconTexture"].b) then
					_G[frameName .. "IconTexture"].b = CreateFrame("Frame", frameName .. "IconBackground", frame);
					_G[frameName .. "IconTexture"].b:SetTemplate("Default");
					_G[frameName .. "IconTexture"].b:SetOutside(_G[frameName .. "IconTexture"]);
				end
			end
		end
	end
	hooksecurefunc("AchievementAlertFrame_FixAnchors", AchievementFixAnchors);

	local function DungeonCompletionFixAnchors()
		for i = 1, DUNGEON_COMPLETION_MAX_REWARDS do
			local frame = _G["DungeonCompletionAlertFrame"..i];
			if(frame) then
				local frameName = frame:GetName();

				if(not frame.backdrop) then
					frame:CreateBackdrop("Transparent");
					frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6);
					frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6);
				end

				for i = 1, frame:GetNumRegions() do
					local region = select(i, frame:GetRegions());
					if(region and region:IsObjectType("Texture")) then
						if(region:GetTexture() == "Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST") then
							region:Kill();
						end
					end
				end

				_G[frameName .. "Shine"]:Kill();
				_G[frameName .. "GlowFrame"]:Kill();
				_G[frameName .. "GlowFrame"].glow:Kill();
				_G[frameName .. "DungeonTexture"]:SetTexCoord(unpack(E.TexCoords));
				_G[frameName .. "DungeonTexture"]:ClearAllPoints();
				_G[frameName .. "DungeonTexture"]:Point("LEFT", frame, 7, 0);

				if(not _G[frameName .. "DungeonTexture"].b) then
					_G[frameName .. "DungeonTexture"].b = CreateFrame("Frame", frameName .. "DungeonBackground", frame);
					_G[frameName .. "DungeonTexture"].b:SetFrameLevel(0);
					_G[frameName .. "DungeonTexture"].b:SetTemplate("Default");
					_G[frameName .. "DungeonTexture"].b:SetOutside(_G[frameName .. "DungeonTexture"]);
				end
			end
		end
	end
	hooksecurefunc("DungeonCompletionAlertFrame_FixAnchors", DungeonCompletionFixAnchors);
end

S:AddCallback("Alerts", LoadSkin);
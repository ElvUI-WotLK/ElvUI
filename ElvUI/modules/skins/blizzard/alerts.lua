local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.alertframes ~= true then return end
	
	hooksecurefunc('AchievementAlertFrame_FixAnchors', function(anchorFrame)
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G['AchievementAlertFrame'..i]
			
			if frame then
				if not frame.backdrop then
					frame:CreateBackdrop('Transparent')
					frame.backdrop:Point('TOPLEFT', _G[frame:GetName()..'Background'], 'TOPLEFT', -2, -6);
					frame.backdrop:Point('BOTTOMRIGHT', _G[frame:GetName()..'Background'], 'BOTTOMRIGHT', -2, 6);
				end
				
				_G['AchievementAlertFrame'..i..'Background']:SetTexture(nil);
				_G['AchievementAlertFrame'..i..'Glow']:Kill();
				_G['AchievementAlertFrame'..i..'Shine']:Kill();
				
				_G['AchievementAlertFrame'..i..'Unlocked']:FontTemplate(nil, 12);
				_G['AchievementAlertFrame'..i..'Unlocked']:SetTextColor(1, 1, 1);
				_G['AchievementAlertFrame'..i..'Name']:FontTemplate(nil, 12);
				
				select(8, _G['AchievementAlertFrame'..i..'Icon']:GetRegions()):Hide();
				
				_G['AchievementAlertFrame'..i..'IconTexture']:SetTexCoord(unpack(E.TexCoords));
				_G['AchievementAlertFrame'..i..'IconOverlay']:Kill();
				
				_G['AchievementAlertFrame'..i..'IconTexture']:ClearAllPoints();
				_G['AchievementAlertFrame'..i..'IconTexture']:Point('LEFT', frame, 7, 0);
				
				if not _G['AchievementAlertFrame'..i..'IconTexture'].b then
					_G['AchievementAlertFrame'..i..'IconTexture'].b = CreateFrame('Frame', nil, _G['AchievementAlertFrame'..i]);
					_G['AchievementAlertFrame'..i..'IconTexture'].b:SetTemplate('Default');
					_G['AchievementAlertFrame'..i..'IconTexture'].b:SetOutside(_G['AchievementAlertFrame'..i..'IconTexture']);
				end
			end
		end	
	end)

	hooksecurefunc('DungeonCompletionAlertFrame_FixAnchors', function()
		for i = 1, DUNGEON_COMPLETION_MAX_REWARDS do
			local frame = _G['DungeonCompletionAlertFrame'..i];
			if frame then
				if not frame.backdrop then
					frame:CreateBackdrop('Transparent');
					frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', -2, -6);
					frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 6);
				end
				
				for i=1, frame:GetNumRegions() do
					local region = select(i, frame:GetRegions());
					if region:GetObjectType() == 'Texture' then
						if region:GetTexture() == 'Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST' then
							region:Kill();
						end
					end
				end
				
				_G['DungeonCompletionAlertFrame'..i..'Shine']:Kill();
				_G['DungeonCompletionAlertFrame'..i..'GlowFrame']:Kill();
				_G['DungeonCompletionAlertFrame'..i..'GlowFrame'].glow:Kill();
				_G['DungeonCompletionAlertFrame'..i..'DungeonTexture']:SetTexCoord(unpack(E.TexCoords));
				_G['DungeonCompletionAlertFrame'..i..'DungeonTexture']:ClearAllPoints();
				_G['DungeonCompletionAlertFrame'..i..'DungeonTexture']:Point('LEFT', frame, 7, 0);
				
				if not _G['DungeonCompletionAlertFrame'..i..'DungeonTexture'].b then
					_G['DungeonCompletionAlertFrame'..i..'DungeonTexture'].b = CreateFrame('Frame', nil, _G['DungeonCompletionAlertFrame'..i]);
					_G['DungeonCompletionAlertFrame'..i..'DungeonTexture'].b:SetFrameLevel(0);
					_G['DungeonCompletionAlertFrame'..i..'DungeonTexture'].b:SetTemplate('Default');
					_G['DungeonCompletionAlertFrame'..i..'DungeonTexture'].b:SetOutside(_G['DungeonCompletionAlertFrame'..i..'DungeonTexture']);
				end
			end
		end
	end)
end

S:RegisterSkin('ElvUI', LoadSkin);
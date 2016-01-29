local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.raid ~= true then return end

	local StripAllTextures = {
		'RaidGroup1',
		'RaidGroup2',
		'RaidGroup3',
		'RaidGroup4',
		'RaidGroup5',
		'RaidGroup6',
		'RaidGroup7',
		'RaidGroup8',
	}

	for _, object in pairs(StripAllTextures) do
		if not _G[object] then print(object) end
		
		if _G[object] then
			_G[object]:StripTextures()
		end
	end
	
	S:HandleButton(RaidFrameRaidBrowserButton)
	S:HandleButton(RaidFrameReadyCheckButton)
	S:HandleButton(RaidFrameRaidInfoButton)
	
	for i=1, MAX_RAID_GROUPS*5 do
		S:HandleButton(_G['RaidGroupButton'..i], true)
	end
	
	for i=1,8 do
		for j=1,5 do
			_G['RaidGroup'..i..'Slot'..j]:StripTextures()
			_G['RaidGroup'..i..'Slot'..j]:SetTemplate('Transparent')
		end
	end
	
	hooksecurefunc('RaidClassButton_Update', function()
		local button, icon, count;
		for index, value in pairs(RAID_CLASS_BUTTONS) do
			button = _G['RaidClassButton'..value.button];
			count = _G['RaidClassButton'..value.button..'Count'];
			icon = _G['RaidClassButton'..value.button..'IconTexture'];
			
			button:StripTextures();
			
			if not button.backdrop then
				button:CreateBackdrop('Default');
				button.backdrop:Point('TOPLEFT', 1, -7);
				button.backdrop:Point('BOTTOMRIGHT', 3, -9);
			end
			
			if(button:GetID() == value.button) then
				button.class = index;
				if ( index == 'PETS' ) then
					icon:SetTexture('Interface\\RaidFrame\\UI-RaidFrame-Pets');
				elseif ( index == 'MAINTANK' ) then
					icon:SetTexture('Interface\\RaidFrame\\UI-RaidFrame-MainTank');
				elseif ( index == 'MAINASSIST' ) then
					icon:SetTexture('Interface\\RaidFrame\\UI-RaidFrame-MainAssist');
				else
					icon:SetTexture('Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes');
				end
				icon:SetTexCoord(value.coords[1] + 0.015, value.coords[2] - 0.02, value.coords[3] + 0.018, value.coords[4] - 0.02);
			end
		end
	end)
	
	local function skinPulloutFrames()
		for i = 1, NUM_RAID_PULLOUT_FRAMES 	do
			local rp = _G['RaidPullout'..i]
			if not rp.backdrop then
				_G['RaidPullout'..i..'MenuBackdrop']:SetBackdrop(nil)
				rp:CreateBackdrop('Transparent')
				rp.backdrop:Point('TOPLEFT', 3, -8)
				rp.backdrop:Point('BOTTOMRIGHT', -1, 1)
			end
		end
	end
	
	hooksecurefunc('RaidPullout_GetFrame', function(...)
		skinPulloutFrames()
	end)
	
	hooksecurefunc('RaidPullout_Update', function(pullOutFrame)
		local pfName = pullOutFrame:GetName()
		for i = 1, pullOutFrame.numPulloutButtons do
			local pfBName = pfName..'Button'..i
			local pfBObj = _G[pfBName]
			if not pfBObj.backdrop then
				for _, v in pairs{'HealthBar', 'ManaBar', 'Target', 'TargetTarget'} do
					local sBar = pfBName..v
					_G[sBar]:SetStatusBarTexture(E['media'].normTex)
				end
				_G[pfBName..'TargetTargetFrame']:CreateBackdrop('Default')
				_G[pfBName..'TargetTargetFrame'].backdrop:Point('TOPLEFT', 4, 0)
				_G[pfBName..'TargetTargetFrame'].backdrop:Point('BOTTOMRIGHT', -4, 2)
				pfBObj:CreateBackdrop('Default')
				pfBObj.backdrop:Point('TOPLEFT', -4, -6)
				pfBObj.backdrop:Point('BOTTOMRIGHT', 4, -6)
			end
		end
	end)
end

S:RegisterSkin('Blizzard_RaidUI', LoadSkin)
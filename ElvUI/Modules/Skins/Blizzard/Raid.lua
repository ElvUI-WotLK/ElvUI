local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local pairs = pairs
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.raid ~= true then return; end

	local StripAllTextures = {
		RaidGroup1,
		RaidGroup2,
		RaidGroup3,
		RaidGroup4,
		RaidGroup5,
		RaidGroup6,
		RaidGroup7,
		RaidGroup8
	}

	for _, object in pairs(StripAllTextures) do
		object:StripTextures()
	end

	S:HandleButton(RaidFrameRaidBrowserButton)
	S:HandleButton(RaidFrameReadyCheckButton)
	S:HandleButton(RaidFrameRaidInfoButton)

	for i = 1, MAX_RAID_GROUPS * 5 do
		S:HandleButton(_G["RaidGroupButton"..i], true)
	end

	for i = 1, 8 do
		for j = 1, 5 do
			_G["RaidGroup"..i.."Slot"..j]:StripTextures()
			_G["RaidGroup"..i.."Slot"..j]:SetTemplate("Transparent")
		end
	end

	local prevButton
	for index = 1, 13 do
		local button = _G["RaidClassButton"..index]
		local icon = _G["RaidClassButton"..index.."IconTexture"]
		local count = _G["RaidClassButton"..index.."Count"]

		button:StripTextures()
		button:SetTemplate("Default")
		button:Size(22)

		button:ClearAllPoints()
		if index == 1 then
			button:Point("TOPLEFT", RaidFrame, "TOPRIGHT", -34, -37)
		elseif index == 11 then
			button:Point("TOP", prevButton, "BOTTOM", 0, -20)
		else
			button:Point("TOP", prevButton, "BOTTOM", 0, -6)
		end
		prevButton = button

		icon:SetInside()

		if index == 11 then
			icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-Pets")
			icon:SetTexCoord(unpack(E.TexCoords))
		elseif index == 12 then
			icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-MainTank")
			icon:SetTexCoord(unpack(E.TexCoords))
		elseif index == 13 then
			icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-MainAssist")
			icon:SetTexCoord(unpack(E.TexCoords))
		else
			local coords = CLASS_ICON_TCOORDS[CLASS_SORT_ORDER[index]]
			icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
			icon:SetTexCoord(coords[1] + 0.015, coords[2] - 0.02, coords[3] + 0.018, coords[4] - 0.02)
		end

		count:FontTemplate(nil, 12, "OUTLINE")
	end

	local function skinPulloutFrames()
		for i = 1, NUM_RAID_PULLOUT_FRAMES do
			local rp = _G["RaidPullout"..i]
			if not rp.backdrop then
				_G["RaidPullout"..i.."MenuBackdrop"]:SetBackdrop(nil)
				rp:CreateBackdrop("Transparent")
				rp.backdrop:Point("TOPLEFT", 9, -17)
				rp.backdrop:Point("BOTTOMRIGHT", -7, 10)
			end
		end
	end

	hooksecurefunc("RaidPullout_GetFrame", function()
		skinPulloutFrames()
	end)

	hooksecurefunc("RaidPullout_Update", function(pullOutFrame)
		local pfName = pullOutFrame:GetName()
		for i = 1, pullOutFrame.numPulloutButtons do
			local pfBName = pfName.."Button"..i
			local pfBObj = _G[pfBName]
			if not pfBObj.backdrop then
				for _, v in pairs{"HealthBar", "ManaBar", "Target", "TargetTarget"} do
					local sBar = pfBName..v
					_G[sBar]:StripTextures()
					_G[sBar]:SetStatusBarTexture(E.media.normTex)
				end

				_G[pfBName.."ManaBar"]:Point("TOP", "$parentHealthBar", "BOTTOM", 0, 0)
				_G[pfBName.."Target"]:Point("TOP", "$parentManaBar", "BOTTOM", 0, -1)

				pfBObj:CreateBackdrop("Default")
				pfBObj.backdrop:Point("TOPLEFT", E.PixelMode and 0 or -1, -(E.PixelMode and 10 or 9))
				pfBObj.backdrop:Point("BOTTOMRIGHT", E.PixelMode and 0 or 1, E.PixelMode and 1 or 0)
			end

			if not _G[pfBName.."TargetTargetFrame"].backdrop then
				_G[pfBName.."TargetTargetFrame"]:StripTextures()
				_G[pfBName.."TargetTargetFrame"]:CreateBackdrop("Default")
				_G[pfBName.."TargetTargetFrame"].backdrop:Point("TOPLEFT", E.PixelMode and 10 or 9, -(E.PixelMode and 15 or 14))
				_G[pfBName.."TargetTargetFrame"].backdrop:Point("BOTTOMRIGHT", -(E.PixelMode and 10 or 9), E.PixelMode and 8 or 7)
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_RaidUI", "RaidUI", LoadSkin)
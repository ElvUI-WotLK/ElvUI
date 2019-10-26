local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs = ipairs
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable and E.private.skins.blizzard.friends then
		RaidClassButton1:HookScript("OnShow", function()
			S:SetUIPanelWindowInfo(FriendsFrame, "width", nil, 21)
		end)
		RaidClassButton1:HookScript("OnHide", function()
			S:SetUIPanelWindowInfo(FriendsFrame, "width")
		end)
	end

	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.raid then return end

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

	for _, object in ipairs(StripAllTextures) do
		object:StripTextures()
	end

	RaidFrameRaidBrowserButton:Point("TOPLEFT", RaidFrame, 45, -33)

	S:HandleButton(RaidFrameRaidBrowserButton)
	S:HandleButton(RaidFrameReadyCheckButton)
	S:HandleButton(RaidFrameRaidInfoButton)

	for i = 1, MAX_RAID_GROUPS * 5 do
		S:HandleButton(_G["RaidGroupButton"..i], true)
	end

	for i = 1, 8 do
		for j = 1, 5 do
			local slot = _G["RaidGroup"..i.."Slot"..j]
			slot:StripTextures()
			slot:SetTemplate("Transparent")
		end
	end

	do
		local prevButton
		local button, icon, count, coords

		for index = 1, 13 do
			button = _G["RaidClassButton"..index]
			icon = _G["RaidClassButton"..index.."IconTexture"]
			count = _G["RaidClassButton"..index.."Count"]

			button:StripTextures()
			button:SetTemplate("Default")
			button:Size(22)

			button:ClearAllPoints()
			if index == 1 then
				button:Point("TOPLEFT", RaidFrame, "TOPRIGHT", -33, -37)
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
				coords = CLASS_ICON_TCOORDS[CLASS_SORT_ORDER[index]]
				icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
				icon:SetTexCoord(coords[1] + 0.02, coords[2] - 0.02, coords[3] + 0.02, coords[4] - 0.02)
			end

			count:FontTemplate(nil, 12, "OUTLINE")
		end
	end

	local function skinPulloutFrames()
		local rp
		for i = 1, NUM_RAID_PULLOUT_FRAMES do
			rp = _G["RaidPullout"..i]
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
		local pfBName, pfBObj, pfTot

		for i = 1, pullOutFrame.numPulloutButtons do
			pfBName = pfName.."Button"..i
			pfBObj = _G[pfBName]
			pfTot = _G[pfBName.."TargetTargetFrame"]

			if not pfBObj.backdrop then
				local sBar

				for _, v in ipairs({"HealthBar", "ManaBar", "Target", "TargetTarget"}) do
					sBar = _G[pfBName..v]
					sBar:StripTextures()
					sBar:SetStatusBarTexture(E.media.normTex)
				end

				_G[pfBName.."ManaBar"]:Point("TOP", "$parentHealthBar", "BOTTOM", 0, 0)
				_G[pfBName.."Target"]:Point("TOP", "$parentManaBar", "BOTTOM", 0, -1)

				pfBObj:CreateBackdrop("Default")
				pfBObj.backdrop:Point("TOPLEFT", E.PixelMode and 0 or -1, -(E.PixelMode and 10 or 9))
				pfBObj.backdrop:Point("BOTTOMRIGHT", E.PixelMode and 0 or 1, E.PixelMode and 1 or 0)
			end

			if not pfTot.backdrop then
				pfTot:StripTextures()
				pfTot:CreateBackdrop("Default")
				pfTot.backdrop:Point("TOPLEFT", E.PixelMode and 10 or 9, -(E.PixelMode and 15 or 14))
				pfTot.backdrop:Point("BOTTOMRIGHT", -(E.PixelMode and 10 or 9), E.PixelMode and 8 or 7)
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_RaidUI", "Skin_Blizzard_RaidUI", LoadSkin)
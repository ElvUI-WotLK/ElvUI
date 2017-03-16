local E, L, V, P, G = unpack(select(2, ...)); -- Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local function LoadSkin()
	if(not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect) then return; end

	InspectFrame:StripTextures(true)
	InspectFrame:CreateBackdrop("Transparent")
	InspectFrame.backdrop:Point("TOPLEFT", 10, -12)
	InspectFrame.backdrop:Point("BOTTOMRIGHT", -31, 75)

	S:HandleCloseButton(InspectFrameCloseButton)

	for i = 1, 3 do
		S:HandleTab(_G["InspectFrameTab"..i])
	end

	InspectPaperDollFrame:StripTextures()

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
		"RangedSlot"
	}

	for _, slot in pairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		local slot = _G["Inspect"..slot]
		slot:StripTextures()
		slot:StyleButton()
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:CreateBackdrop("Default")
		slot.backdrop:SetAllPoints()
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		if(button.hasItem) then
			local itemID = GetInventoryItemID(InspectFrame.unit, button:GetID())
			if(itemID) then
				local _, _, quality = GetItemInfo(itemID)
				if(not quality) then
					E:Delay(0.1, function()
						if(InspectFrame.unit) then
							InspectPaperDollItemSlotButton_Update(button);
						end
					end);
					return
				elseif(quality and quality > 1) then
					button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality));
					return
				end
			end
		end
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor));
	end)

	S:HandleRotateButton(InspectModelRotateLeftButton)
	S:HandleRotateButton(InspectModelRotateRightButton)

	InspectPVPFrame:StripTextures()

	for i = 1, MAX_ARENA_TEAMS do
		_G["InspectPVPTeam"..i]:StripTextures()
		_G["InspectPVPTeam"..i]:CreateBackdrop("Transparent")
		_G["InspectPVPTeam"..i].backdrop:Point("TOPLEFT", 9, -6)
		_G["InspectPVPTeam"..i].backdrop:Point("BOTTOMRIGHT", -24, -5)
	--	_G["InspectPVPTeam"..i.."StandardBar"]:Kill()
	end

	InspectTalentFrame:StripTextures()

	S:HandleCloseButton(InspectTalentFrameCloseButton)

	for i = 1, MAX_TALENT_TABS do
		_G["InspectTalentFrameTab"..i]:StripTextures()
	end

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["InspectTalentFrameTalent"..i];
		local icon = _G["InspectTalentFrameTalent"..i.."IconTexture"];
		local rank = _G["InspectTalentFrameTalent"..i.."Rank"];

		if (talent) then
			talent:StripTextures();
			talent:SetTemplate("Default");
			talent:StyleButton();

			icon:SetInside();
			icon:SetTexCoord(unpack(E.TexCoords));
			icon:SetDrawLayer("ARTWORK");

			rank:SetFont(E.LSM:Fetch("font", E.db["general"].font), 12, "OUTLINE");
		end
	end

	InspectTalentFrameScrollFrame:StripTextures()
	InspectTalentFrameScrollFrame:CreateBackdrop("Transparent")
	InspectTalentFrameScrollFrame.backdrop:Point("TOPLEFT", -1, 1)
	InspectTalentFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", 5, -4)
	S:HandleScrollBar(InspectTalentFrameScrollFrameScrollBar)
	InspectTalentFrameScrollFrameScrollBar:Point("TOPLEFT", InspectTalentFrameScrollFrame, "TOPRIGHT", 8, -19)

	InspectTalentFramePointsBar:StripTextures()
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect", LoadSkin);
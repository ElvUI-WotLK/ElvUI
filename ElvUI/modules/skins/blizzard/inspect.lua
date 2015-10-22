local E, L, V, P, G = unpack(select(2, ...)); -- Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.inspect ~= true then return end
	
	InspectFrame:StripTextures(true)
	InspectFrame:CreateBackdrop('Transparent')
	InspectFrame.backdrop:Point('TOPLEFT', 10, -12)
	InspectFrame.backdrop:Point('BOTTOMRIGHT', -31, 75)
	
	S:HandleCloseButton(InspectFrameCloseButton)
	
	for i=1, 3 do
		S:HandleTab(_G['InspectFrameTab'..i])
	end
	
	InspectPaperDollFrame:StripTextures()

	local slots = {'HeadSlot', 'NeckSlot', 'ShoulderSlot', 'BackSlot', 'ChestSlot', 'ShirtSlot', 'TabardSlot', 'WristSlot', 'HandsSlot', 'WaistSlot', 'LegsSlot', 'FeetSlot', 'Finger0Slot', 'Finger1Slot', 'Trinket0Slot', 'Trinket1Slot', 'MainHandSlot', 'SecondaryHandSlot', 'RangedSlot'}
	for _, slot in pairs(slots) do
		local icon = _G['Inspect'..slot..'IconTexture']
		local slot = _G['Inspect'..slot]
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
		slot:StripTextures()
		slot:StyleButton()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:CreateBackdrop('Default')
		slot.backdrop:SetAllPoints()
	end
	
	local CheckItemBorderColor = CreateFrame("Frame")
	local function ScanSlots()
		local notFound
		for _, slot in pairs(slots) do
			-- Colour the equipment slots by rarity
			local target = _G["Inspect"..slot]
			local slotId, _, _ = GetInventorySlotInfo(slot)
			local itemId = GetInventoryItemID("target", slotId)

			if itemId then
				local _, _, rarity, _, _, _, _, _, _, _, _ = GetItemInfo(itemId)
				if not rarity then notFound = true end
				if rarity and rarity > 1 then
					target.backdrop:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					target.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				target.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
		
		if notFound == true then
			return false
		else
			CheckItemBorderColor:SetScript('OnUpdate', nil) --Stop updating
			return true
		end
	end
	
	local function ColorItemBorder(self)
		if self and not ScanSlots() then
			self:SetScript("OnUpdate", ScanSlots) --Run function until all items borders are colored, sometimes when you have never seen an item before GetItemInfo will return nil, when this happens we have to wait for the server to send information.
		end 
	end

	CheckItemBorderColor:RegisterEvent("PLAYER_TARGET_CHANGED")
	CheckItemBorderColor:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	CheckItemBorderColor:RegisterEvent("PARTY_MEMBERS_CHANGED")
	CheckItemBorderColor:SetScript("OnEvent", ColorItemBorder)	
	InspectFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder(CheckItemBorderColor)
	
	S:HandleRotateButton(InspectModelRotateLeftButton)
	S:HandleRotateButton(InspectModelRotateRightButton)
	
	InspectPVPFrame:StripTextures()

	for i=1, MAX_ARENA_TEAMS do
		_G['InspectPVPTeam'..i]:StripTextures()
		_G['InspectPVPTeam'..i]:CreateBackdrop('Transparent')
		_G['InspectPVPTeam'..i].backdrop:Point('TOPLEFT', 9, -6)
		_G['InspectPVPTeam'..i].backdrop:Point('BOTTOMRIGHT', -24, -5)
		-- _G['InspectPVPTeam'..i..'StandardBar']:Kill()
	end
	
	InspectTalentFrame:StripTextures()
	
	S:HandleCloseButton(InspectTalentFrameCloseButton)
	
	for i=1, MAX_TALENT_TABS do
		_G['InspectTalentFrameTab'..i]:StripTextures()
	end
	
	for i=1, MAX_NUM_TALENTS do
		local button = _G['InspectTalentFrameTalent'..i];
		local icon = _G['InspectTalentFrameTalent'..i..'IconTexture'];
		local rank = _G['InspectTalentFrameTalent'..i..'Rank'];
		
		if ( button ) then
			button:StripTextures()
			button:SetTemplate('Default', true)
			button:StyleButton()
			
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')
			icon:ClearAllPoints()
			icon:SetInside()
			
			rank:SetFont(E.LSM:Fetch("font", E.db['general'].font), 12, 'OUTLINE')
			rank:Point('BOTTOMRIGHT', -1, 1)
		end
	end
	
	InspectTalentFrameScrollFrame:StripTextures()
	InspectTalentFrameScrollFrame:CreateBackdrop('Transparent')
	InspectTalentFrameScrollFrame.backdrop:Point('TOPLEFT', -1, 1)
	InspectTalentFrameScrollFrame.backdrop:Point('BOTTOMRIGHT', 5, -4)
	S:HandleScrollBar(InspectTalentFrameScrollFrameScrollBar)
	InspectTalentFrameScrollFrameScrollBar:Point('TOPLEFT', InspectTalentFrameScrollFrame, 'TOPRIGHT', 8, -19)
	
	InspectTalentFramePointsBar:StripTextures()
end

S:RegisterSkin('Blizzard_InspectUI', LoadSkin)
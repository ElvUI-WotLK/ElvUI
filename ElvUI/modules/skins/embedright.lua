local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

skadaWindows = {}
S.AddonPoints = {
	['Recount'] = {},
	['Omen'] = {},
	["Skada"] = {}
}

function S:EmbedSkadaWindow(window, width, height, point, relativeFrame, relativePoint, ofsx, ofsy)
	local barheight = 22;
	window.db.barwidth = width;
	window.db.barheight = 12;
	if(window.db.enabletitle) then 
		height = height - barheight;
	end
	window.db.background.height = height;
	window.db.enablebackground = true;
	window.db.spark = false
	window.db.barslocked = true;
	window.bargroup:ClearAllPoints();
	window.bargroup:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy);
	window.bargroup:SetFrameLevel(relativeFrame:GetFrameLevel() + 30);
	
	Skada.displays["bar"].ApplySettings(Skada.displays["bar"], window);
end

function S:SaveEmbeddedAddonPoints(addon)
	if not IsAddOnLoaded(addon) then return; end
	
	if addon == 'Recount' then
		local point, _, anchor, x, y = Recount_MainWindow:GetPoint()
		S.AddonPoints[addon] = {point, UIParent, anchor, x, y}
	elseif addon == 'Omen' then
		local point, _, anchor, x, y = OmenAnchor:GetPoint()
		S.AddonPoints[addon] = {point, UIParent, anchor, x, y}
	end	
end

--Reset points of previous addon
function S:RemovePrevious(current)
	local lastAddon = self.lastAddon

	if lastAddon == 'Recount' then
		Recount_MainWindow:ClearAllPoints()
		local point, attachTo, anchor, x, y = unpack(S.AddonPoints[lastAddon])
		Recount_MainWindow:SetPoint(point, attachTo, anchor, x, y)
		Recount:LockWindows(false)
		Recount_MainWindow:SetParent(UIParent)
	elseif lastAddon == 'Omen' then
		OmenAnchor:ClearAllPoints()
		local point, attachTo, anchor, x, y = unpack(S.AddonPoints[lastAddon])
		OmenAnchor:SetPoint(point, attachTo, anchor, x, y)
		OmenAnchor:SetParent(UIParent)	
		OmenAnchor.SetFrameStrata = OmenAnchor.SetFrameStrataOld
		
		if Omen.db.profile.Locked ~= true then
			Omen.Grip:Show()
			Omen.VGrip1:Show()
			if Omen.db.profile.Bar.ShowTPS then
				Omen.VGrip2:Show()
			else
				Omen.VGrip2:Hide()
			end			
		end
	elseif(lastAddon == "Skada") then
		if not Skada.CreateWindow_ then
			Skada.CreateWindow_ = Skada.CreateWindow;
			Skada.DeleteWindow_ = Skada.DeleteWindow;
		end
		
		for _, window in pairs(skadaWindows) do
			window.bargroup:SetParent(UIParent);
		end		
	end
end

function S:EmbedSkada()
	local borderWidth = E.PixelMode and 1 or 2;
	local widthOffset = E.PixelMode and 8 or 14;
	local heightOffset = E.PixelMode and 13 or 19;
	
	if(E.db.chat.panelBackdrop == "'SHOWBOTH" or E.db.chat.panelBackdrop == "SHOWRIGHT") then
		widthOffset = E.PixelMode and 8 or 14;
		heightOffset = E.PixelMode and 16 or 24;
	end

	for _, window in pairs(skadaWindows) do
		window.bargroup:SetParent(RightChatToggleButton);
	end
	
	local panelWidthRight = E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth;
	local panelHeightRight = E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight;
	
	if(#skadaWindows == 1) then
		self:EmbedSkadaWindow(skadaWindows[1], panelWidthRight - widthOffset, panelHeightRight - heightOffset, "TOPLEFT", RightChatPanel, "TOPLEFT", E.PixelMode and 4 or 7, -(E.PixelMode and 4 or 7));
	elseif(#skadaWindows == 2) then
		self:EmbedSkadaWindow(skadaWindows[1], ((panelWidthRight - widthOffset) / 2) - (borderWidth + E.mult) + 1, panelHeightRight - heightOffset,  "TOPLEFT", RightChatPanel, "TOPLEFT", E.PixelMode and 4 or 6, -(E.PixelMode and 4 or 6));
		self:EmbedSkadaWindow(skadaWindows[2], ((panelWidthRight - widthOffset) / 2) - (borderWidth + E.mult), panelHeightRight - heightOffset,  "LEFT", skadaWindows[1].bargroup, "RIGHT", E.PixelMode and 3 or 7, 0);
	end	
end

function S:SetEmbedRight(addon)
	self:RemovePrevious(addon)
	if not IsAddOnLoaded(addon) then return; end
	if self.lastAddon == nil then self.lastAddon = addon; end

	if addon == 'Recount' then
		Recount:LockWindows(true)
		
		Recount_MainWindow:ClearAllPoints()
		Recount_MainWindow:SetPoint("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 0, (E.PixelMode and 1 or 3))

		if E.db.chat.panelBackdrop == 'SHOWBOTH' or E.db.chat.panelBackdrop == 'SHOWRIGHT' then
			Recount_MainWindow:SetWidth(E.db.chat.panelWidth - (E.PixelMode and 6 or 10))
			Recount_MainWindow:SetHeight(E.db.chat.panelHeight - (E.PixelMode and 20 or 26))
		else
			Recount_MainWindow:SetWidth(E.db.chat.panelWidth)
			Recount_MainWindow:SetHeight(E.db.chat.panelHeight - 20)		
		end		
		Recount_MainWindow:SetParent(RightChatPanel)	
		self.lastAddon = addon
	elseif addon == 'Omen' then
		Omen.db.profile.Locked = true
		Omen:UpdateGrips()
		if not Omen.oldUpdateGrips then
			Omen.oldUpdateGrips = Omen.UpdateGrips
		end
		Omen.UpdateGrips = function(...)
			local db = Omen.db.profile
			if S.db.embedRight == 'Omen' then
				Omen.VGrip1:ClearAllPoints()
				Omen.VGrip1:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip1, 0)
				Omen.VGrip1:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip1, 0)
				Omen.VGrip2:ClearAllPoints()
				Omen.VGrip2:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip2, 0)
				Omen.VGrip2:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip2, 0)
				Omen.Grip:Hide()
				if db.Locked then
					Omen.VGrip1:Hide()
					Omen.VGrip2:Hide()
				else
					Omen.VGrip1:Show()
					if db.Bar.ShowTPS then
						Omen.VGrip2:Show()
					else
						Omen.VGrip2:Hide()
					end
				end			
			else
				Omen.oldUpdateGrips(...)
			end
		end
		
		if not Omen.oldSetAnchors then
			Omen.oldSetAnchors = Omen.SetAnchors
		end
		Omen.SetAnchors = function(...)
			if S.db.embedRight == 'Omen' then return; end
			Omen.oldSetAnchors(...)
		end
		
		OmenAnchor:ClearAllPoints()
		OmenAnchor:SetPoint("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 0, (E.PixelMode and 1 or 3))
		
		if E.db.chat.panelBackdrop == 'SHOWBOTH' or E.db.chat.panelBackdrop == 'SHOWRIGHT' then
			OmenAnchor:SetWidth(E.db.chat.panelWidth - (E.PixelMode and 6 or 10))
			OmenAnchor:SetHeight(E.db.chat.panelHeight - (E.PixelMode and 31 or 35))
		else
			OmenAnchor:SetWidth(E.db.chat.panelWidth)
			OmenAnchor:SetHeight(E.db.chat.panelHeight - 29)		
		end
		
		OmenAnchor:SetParent(RightChatPanel)
		OmenAnchor:SetFrameStrata('LOW')
		if not OmenAnchor.SetFrameStrataOld then
			OmenAnchor.SetFrameStrataOld = OmenAnchor.SetFrameStrata
		end
		OmenAnchor.SetFrameStrata = E.noop
		
		local StartMoving = Omen.Title:GetScript('OnMouseDown')
		local StopMoving = Omen.Title:GetScript('OnMouseUp')
		Omen.Title:SetScript("OnMouseDown", function()
			if S.db.embedRight == 'Omen' then return end
			StartMoving()
		end)
		
		Omen.Title:SetScript("OnMouseUp", function()
			if S.db.embedRight == 'Omen' then return end
			StopMoving()
		end)	

		Omen.BarList:SetScript("OnMouseDown", function()
			if S.db.embedRight == 'Omen' then return end
			StartMoving()
		end)
		
		Omen.BarList:SetScript("OnMouseUp", function()
			if S.db.embedRight == 'Omen' then return end
			StopMoving()
		end)				
		
		self.lastAddon = addon
	elseif(addon == "Skada") then
		table.wipe(skadaWindows);
		for _, window in ipairs(Skada:GetWindows()) do
			window:UpdateDisplay()
			tinsert(skadaWindows, window);
		end
		
		self:RemovePrevious(addon);

		function Skada:CreateWindow(name, db)
			Skada:CreateWindow_(name, db);
			
			table.wipe(skadaWindows);
			for _, window in ipairs(Skada:GetWindows()) do
				tinsert(skadaWindows, window);
			end	
			
			--if(S.db.embedRight == "Skada") then
				S:EmbedSkada();
			--end
		end
		
		function Skada:DeleteWindow(name)
			Skada:DeleteWindow_(name);
			
			table.wipe(skadaWindows);
			for _, window in ipairs(Skada:GetWindows()) do
				tinsert(skadaWindows, window);
			end	
			
			--if(S.db.embedRight == "Skada") then
				S:EmbedSkada();
			--end
		end
		
		self:EmbedSkada();
		self.lastAddon = addon;
	end
end
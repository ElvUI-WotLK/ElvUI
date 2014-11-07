local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if(E.private.skins.addons.enable ~= true
		or E.private.skins.addons.recount ~= true)
	then
		return;
	end
	
	Recount_MainWindow:SetBackdrop(nil);
	
	local backdrop = CreateFrame('Frame', nil, Recount_MainWindow);
	backdrop:SetFrameLevel(Recount_MainWindow:GetFrameLevel() - 1);
	backdrop:Point('BOTTOMLEFT', Recount_MainWindow, 1, 1);
	backdrop:Point('TOPRIGHT', Recount_MainWindow, -1, -11);
	backdrop:SetTemplate('Default');
	
	local header = CreateFrame('Frame', nil, backdrop);
	header:Height(21);
	header:Point('TOPLEFT', backdrop);
	header:Point('TOPRIGHT', backdrop);
	header:SetTemplate('Default', true);
	
	Recount.SetupBarOriginal = Recount.SetupBar;
	
	function Recount:UpdateBarTextures()
		for _, row in pairs(Recount.MainWindow.Rows) do
			row.StatusBar:SetStatusBarTexture(E.media.glossTex);
			
			row.LeftText:FontTemplate();
			row.RightText:FontTemplate();
		end
	end
	
	function Recount:SetupBar(bar)
		self:SetupBarOriginal(bar);
		
		bar.StatusBar:SetStatusBarTexture(E.media.glossTex);
		
		bar.LeftText:FontTemplate();
		bar.RightText:FontTemplate();
	end
	
	Recount:UpdateBarTextures();
	
	for i = 1, Recount_MainWindow:GetNumRegions() do
		local region = select(i, Recount_MainWindow:GetRegions());
		if(region:GetObjectType() == 'FontString') then
			region:FontTemplate();
			region:SetTextColor(unpack(E.media.rgbvaluecolor));
		end
	end
	
	S:HandleScrollBar(Recount_MainWindow_ScrollBarScrollBar);
	
	Recount_MainWindow.DragBottomLeft:SetNormalTexture(nil);
	Recount_MainWindow.DragBottomRight:SetNormalTexture(nil);
	
	local buttons = {
		Recount.MainWindow.CloseButton,
		Recount.MainWindow.RightButton,
		Recount.MainWindow.LeftButton,
		Recount.MainWindow.ResetButton,
		Recount.MainWindow.FileButton,
		Recount.MainWindow.ConfigButton,
		Recount.MainWindow.ReportButton
	};

	for i = 1, getn(buttons) do
		local button = buttons[i];
		if(button) then
			button:GetNormalTexture():SetDesaturated(true);
			button:GetHighlightTexture():SetDesaturated(true);
		end
	end
end

S:RegisterSkin('Recount', LoadSkin);
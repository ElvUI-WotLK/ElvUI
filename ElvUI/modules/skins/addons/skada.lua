local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if(E.private.skins.addons.enable ~= true or E.private.skins.addons.skada ~= true) then return; end
	local Skada = Skada;
	local displayBar = Skada.displays["bar"];
	
	S:SecureHook(displayBar, "ApplySettings", function(self, win)
		local skada = win.bargroup;
		if(win.db.enabletitle) then
			skada.button:SetBackdrop(nil);
			
			if(not skada.button.backdrop) then
				skada.button:CreateBackdrop("Default", true);
			end
		end
		
		if(skada.bgframe) then
			skada.bgframe:SetBackdrop(nil);
			
			if(not skada.bgframe.backdrop) then
				skada.bgframe:CreateBackdrop("Default");
			end
			
			if(skada.bgframe.backdrop) then
				skada.bgframe.backdrop:ClearAllPoints();
				if(win.db.enabletitle) then
					skada.bgframe.backdrop:SetPoint("TOPLEFT", -E.Border, E.Border);
					skada.bgframe.backdrop:SetPoint("BOTTOMRIGHT", E.Border, -(E.PixelMode and 6 or 8));
				else
					skada.bgframe.backdrop:SetPoint("TOPLEFT", -E.Border, E.PixelMode and 16 or 18);
					skada.bgframe.backdrop:SetPoint("BOTTOMRIGHT", E.Border, E.PixelMode and 14 or 16);
				end
				
				
				if(E.db.chat.panelBackdrop == "HIDEBOTH" or E.db.chat.panelBackdrop == "LEFT") then
					skada.bgframe.backdrop:Show();
				else
					skada.bgframe.backdrop:Hide();
				end
			end
		end
	end);
	
	for _, window in ipairs(Skada:GetWindows()) do
		window:UpdateDisplay();
	end
end

S:RegisterSkin("Skada", LoadSkin);
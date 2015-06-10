local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if(E.private.skins.addons.enable ~= true or E.private.skins.addons.skada ~= true) then return; end
	local Skada = Skada;
	local barmod = Skada.displays["bar"];

	barmod.ApplySettings_ = barmod.ApplySettings
	barmod.ApplySettings = function(self, win)
		barmod.ApplySettings_(self, win);
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
				if(win.db.reversegrowth) then
					skada.bgframe.backdrop:Point('TOPLEFT', -E.Border, E.Border);
					skada.bgframe.backdrop:Point('BOTTOMRIGHT', E.Border, -(E.PixelMode and 7 or 9));
				else
					skada.bgframe.backdrop:Point('TOPLEFT', -E.Border, E.PixelMode and 7 or 9);
					skada.bgframe.backdrop:Point('BOTTOMRIGHT', E.Border, -E.Border);
				end
			end
		end
	end	
	
	-- Update pre-existing displays
	for _, window in ipairs(Skada:GetWindows()) do
		window:UpdateDisplay()
	end	
end

S:RegisterSkin("Skada", LoadSkin)
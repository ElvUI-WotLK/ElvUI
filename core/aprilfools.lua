local E, L, V, P, G = unpack(select(2, ...));

local _G = _G;
local pairs = pairs;
local twipe, tinsert = table.wipe, table.insert;

local CreateFrame = CreateFrame;
local PlayMusic, StopMusic = PlayMusic, StopMusic;
local GetCVar, SetCVar = GetCVar, SetCVar;
local DoEmote = DoEmote;
local SendChatMessage = SendChatMessage;
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS;

do
	function E:StopHarlemShake()
		E.isMassiveShaking = nil;
		StopMusic();
		SetCVar("Sound_EnableAllSound", self.oldEnableAllSound);
		SetCVar("Sound_EnableMusic", self.oldEnableMusic);

		self:StopShakeHorizontal(ElvUI_StaticPopup1)
		for _, object in pairs(self["massiveShakeObjects"]) do
			if(object) then
				self:StopShake(object);
			end
		end

		if(E.massiveShakeTimer) then
			E:CancelTimer(E.massiveShakeTimer);
		end

		E.global.aprilFools = true;
		E:StaticPopup_Hide("HARLEM_SHAKE");
		twipe(self.massiveShakeObjects);
		DoEmote("Dance");
	end

	function E:DoTheHarlemShake()
		E.isMassiveShaking = true;
		ElvUI_StaticPopup1Button1:Enable();

		for _, object in pairs(self["massiveShakeObjects"]) do
			if(object and object:IsShown()) then
				self:Shake(object);
			end
		end

		E.massiveShakeTimer = E:ScheduleTimer("StopHarlemShake", 42.5);
		SendChatMessage("DO THE HARLEM SHAKE!", "YELL");
	end

	function E:BeginHarlemShake()
		DoEmote("Dance");
		ElvUI_StaticPopup1Button1:Disable();
		self:ShakeHorizontal(ElvUI_StaticPopup1);
		self.oldEnableAllSound = GetCVar("Sound_EnableAllSound");
		self.oldEnableMusic = GetCVar("Sound_EnableMusic");

		SetCVar("Sound_EnableAllSound", 1);
		SetCVar("Sound_EnableMusic", 1);
		PlayMusic([[Interface\AddOns\ElvUI\media\sounds\harlemshake.ogg]]);
		E:ScheduleTimer("DoTheHarlemShake", 15.5);

		local UF = E:GetModule("UnitFrames");
		local AB = E:GetModule("ActionBars");
		self.massiveShakeObjects = {};
		tinsert(self.massiveShakeObjects, GameTooltip);
		tinsert(self.massiveShakeObjects, Minimap);
		tinsert(self.massiveShakeObjects, WatchFrame);
		tinsert(self.massiveShakeObjects, LeftChatPanel);
		tinsert(self.massiveShakeObjects, RightChatPanel);
		tinsert(self.massiveShakeObjects, LeftChatToggleButton);
		tinsert(self.massiveShakeObjects, RightChatToggleButton);

		for unit in pairs(UF["units"]) do
			tinsert(self.massiveShakeObjects, UF[unit]);
		end

		for _, header in pairs(UF["headers"]) do
			tinsert(self.massiveShakeObjects, header);
		end

		for button, _ in pairs(AB["handledbuttons"]) do
			if(button) then
				tinsert(self.massiveShakeObjects, button);
			end
		end

		if(ElvUI_StanceBar) then
			for i = 1, #ElvUI_StanceBar.buttons do
				tinsert(self.massiveShakeObjects, ElvUI_StanceBar.buttons[i]);
			end
		end

		for i = 1, NUM_PET_ACTION_SLOTS do
			local button = _G["PetActionButton"..i];
			if(button) then
				tinsert(self.massiveShakeObjects, button);
			end
		end
	end

	function E:HarlemShakeToggle()
		self:StaticPopup_Show("HARLEM_SHAKE");
	end
end

do
	local function OnDragStart(self)
		self:StartMoving();
	end

	local function OnDragStop(self)
		self:StopMovingOrSizing();
	end

	local function OnUpdate(self, elapsed)
		if(self.elapsed and self.elapsed > 0.1) then
			self.tex:SetTexCoord((self.curFrame - 1) * 0.1, 0, (self.curFrame - 1) * 0.1, 1, self.curFrame * 0.1, 0, self.curFrame * 0.1, 1);

			if(self.countUp) then
				self.curFrame = self.curFrame + 1;
			else
				self.curFrame = self.curFrame - 1;
			end

			if(self.curFrame > 10) then
				self.countUp = false;
				self.curFrame = 9;
			elseif(self.curFrame < 1) then
				self.countUp = true;
				self.curFrame = 2;
			end
			self.elapsed = 0;
		else
			self.elapsed = (self.elapsed or 0) + elapsed;
		end
	end

	function E:SetupHelloKitty()
		if(not self.db.tempSettings) then
			self.db.tempSettings = {};
		end

		local t = self.db.tempSettings;
		local c = self.db.general.backdropcolor;
		if(self:HelloKittyFixCheck()) then
			E:HelloKittyFix();
		else
			self.oldEnableAllSound = GetCVar("Sound_EnableAllSound");
			self.oldEnableMusic = GetCVar("Sound_EnableMusic");

			t.backdropcolor = {r = c.r, g = c.g, b = c.b};
			c = self.db.general.backdropfadecolor;
			t.backdropfadecolor = {r = c.r, g = c.g, b = c.b, a = c.a};
			c = self.db.general.bordercolor;
			t.bordercolor = {r = c.r, g = c.g, b = c.b};
			c = self.db.general.valuecolor;
			t.valuecolor = {r = c.r, g = c.g, b = c.b};

			t.panelBackdropNameLeft = self.db.chat.panelBackdropNameLeft;
			t.panelBackdropNameRight = self.db.chat.panelBackdropNameRight;

			c = self.db.unitframe.colors.health;
			t.health = {r = c.r, g = c.g, b = c.b};
			t.healthclass = self.db.unitframe.colors.healthclass;

			c = self.db.unitframe.colors.castColor;
			t.castColor = {r = c.r, g = c.g, b = c.b};
			t.transparentCastbar = self.db.unitframe.colors.transparentCastbar;

			c = self.db.unitframe.colors.auraBarBuff;
			t.auraBarBuff = {r = c.r, g = c.g, b = c.b};
			t.transparentAurabars = self.db.unitframe.colors.transparentAurabars;

			self.db.general.backdropfadecolor = {r =131/255, g =36/255, b = 130/255, a = 0.36};
			self.db.general.backdropcolor = {r = 223/255, g = 76/255, b = 188/255};
			self.db.general.bordercolor = {r = 223/255, g = 217/255, b = 47/255};
			self.db.general.valuecolor = {r = 223/255, g = 217/255, b = 47/255};

			self.db.chat.panelBackdropNameLeft = [[Interface\AddOns\ElvUI\media\textures\helloKittyChat1.tga]];
			self.db.chat.panelBackdropNameRight = [[Interface\AddOns\ElvUI\media\textures\helloKittyChat1.tga]];

			self.db.unitframe.colors.castColor = {r = 223/255, g = 76/255, b = 188/255};
			self.db.unitframe.colors.transparentCastbar = true;

			self.db.unitframe.colors.auraBarBuff = {r = 223/255, g = 76/255, b = 188/255};
			self.db.unitframe.colors.transparentAurabars = true;

			self.db.unitframe.colors.health = {r = 223/255, g = 76/255, b = 188/255};
			self.db.unitframe.colors.healthclass = false;

			SetCVar("Sound_EnableAllSound", 1);
			SetCVar("Sound_EnableMusic", 1);
			PlayMusic([[Interface\AddOns\ElvUI\media\sounds\helloKitty.ogg]]);
			E:StaticPopup_Show("HELLO_KITTY_END");

			self.db.general.kittys = true;
			self:CreateKittys();

			self:UpdateAll();
		end
	end

	function E:RestoreHelloKitty()
		self.db.general.kittys = false;
		if(HelloKittyLeft) then
			HelloKittyLeft:Hide();
			HelloKittyRight:Hide();
		end

		if not(self.db.tempSettings) then return; end
		if(self:HelloKittyFixCheck()) then
			self:HelloKittyFix();
			self.db.tempSettings = nil;
			return;
		end
		local c = self.db.tempSettings.backdropcolor;
		self.db.general.backdropcolor = {r = c.r, g = c.g, b = c.b};

		c = self.db.tempSettings.backdropfadecolor;
		self.db.general.backdropfadecolor = {r = c.r, g = c.g, b = c.b, a = (c.a or 0.8)};

		c = self.db.tempSettings.bordercolor;
		self.db.general.bordercolor = {r = c.r, g = c.g, b = c.b};

		c = self.db.tempSettings.valuecolor;
		self.db.general.valuecolor = {r = c.r, g = c.g, b = c.b};

		self.db.chat.panelBackdropNameLeft = self.db.tempSettings.panelBackdropNameLeft;
		self.db.chat.panelBackdropNameRight = self.db.tempSettings.panelBackdropNameRight;

		c = self.db.tempSettings.health;
		self.db.unitframe.colors.health = {r = c.r, g = c.g, b = c.b};
		self.db.unitframe.colors.healthclass = self.db.tempSettings.healthclass;

		c = self.db.tempSettings.castColor;
		self.db.unitframe.colors.castColor = {r = c.r, g = c.g, b = c.b};
		self.db.unitframe.colors.transparentCastbar = self.db.tempSettings.transparentCastbar;

		c = self.db.tempSettings.auraBarBuff;
		self.db.unitframe.colors.auraBarBuff = {r = c.r, g = c.g, b = c.b};
		self.db.unitframe.colors.transparentAurabars = self.db.tempSettings.transparentAurabars;

		self.db.tempSettings = nil;

		self:UpdateAll();
	end

	function E:CreateKittys()
		if(HelloKittyLeft) then
			HelloKittyLeft:Show();
			HelloKittyRight:Show();
			return;
		end
		local helloKittyLeft = CreateFrame("Frame", "HelloKittyLeft", UIParent);
		helloKittyLeft:SetSize(120, 128);
		helloKittyLeft:SetMovable(true);
		helloKittyLeft:EnableMouse(true);
		helloKittyLeft:RegisterForDrag("LeftButton");
		helloKittyLeft:SetPoint("BOTTOMLEFT", LeftChatPanel, "BOTTOMRIGHT", 2, -4);
		helloKittyLeft.tex = helloKittyLeft:CreateTexture(nil, "OVERLAY");
		helloKittyLeft.tex:SetAllPoints();
		helloKittyLeft.tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\hello_kitty.tga");
		helloKittyLeft.tex:SetTexCoord(0, 0, 0, 1, 0, 0, 0, 1);
		helloKittyLeft.curFrame = 1;
		helloKittyLeft.countUp = true;
		helloKittyLeft:SetClampedToScreen(true);
		helloKittyLeft:SetScript("OnDragStart", OnDragStart);
		helloKittyLeft:SetScript("OnDragStop", OnDragStop);
		helloKittyLeft:SetScript("OnUpdate", OnUpdate);

		local helloKittyRight = CreateFrame("Frame", "HelloKittyRight", UIParent);
		helloKittyRight:SetSize(120, 128);
		helloKittyRight:SetMovable(true);
		helloKittyRight:EnableMouse(true);
		helloKittyRight:RegisterForDrag("LeftButton");
		helloKittyRight:SetPoint("BOTTOMRIGHT", RightChatPanel, "BOTTOMLEFT", -2, -4);
		helloKittyRight.tex = helloKittyRight:CreateTexture(nil, "OVERLAY");
		helloKittyRight.tex:SetAllPoints();
		helloKittyRight.tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\hello_kitty.tga");
		helloKittyRight.tex:SetTexCoord(0, 0, 0, 1, 0, 0, 0, 1);
		helloKittyRight.curFrame = 10;
		helloKittyRight.countUp = false;
		helloKittyRight:SetClampedToScreen(true);
		helloKittyRight:SetScript("OnDragStart", OnDragStart);
		helloKittyRight:SetScript("OnDragStop", OnDragStop);
		helloKittyRight:SetScript("OnUpdate", OnUpdate);
	end

	function E:HelloKittyFixCheck(secondCheck)
		local t = self.db.tempSettings;
		if(not t and not secondCheck) then t = self.db.general; end
		if(t and t.backdropcolor)then
			return self:Round(t.backdropcolor.r, 2) == 0.87 and self:Round(t.backdropcolor.g, 2) == 0.3 and self:Round(t.backdropcolor.b, 2) == 0.74;
		end
	end

	function E:HelloKittyFix()
		local c = P.general.backdropcolor;
		self.db.general.backdropcolor = {r = c.r, g = c.g, b = c.b};

		c = P.general.backdropfadecolor;
		self.db.general.backdropfadecolor = {r = c.r, g = c.g, b = c.b, a = (c.a or 0.8)};

		c = P.general.bordercolor;
		self.db.general.bordercolor = {r = c.r, g = c.g, b = c.b};

		c = P.general.valuecolor;
		self.db.general.valuecolor = {r = c.r, g = c.g, b = c.b};

		self.db.chat.panelBackdropNameLeft = "";
		self.db.chat.panelBackdropNameRight = "";

		c = P.unitframe.colors.health;
		self.db.unitframe.colors.health = {r = c.r, g = c.g, b = c.b};

		c = P.unitframe.colors.castColor;
		self.db.unitframe.colors.castColor = {r = c.r, g = c.g, b = c.b};
		self.db.unitframe.colors.transparentCastbar = false;

		c = P.unitframe.colors.castColor;
		self.db.unitframe.colors.auraBarBuff = {r = c.r, g = c.g, b = c.b};
		self.db.unitframe.colors.transparentAurabars = false;

		if(HelloKittyLeft) then
			HelloKittyLeft:Hide();
			HelloKittyRight:Hide();
			self.db.general.kittys = nil;
			return;
		end

		self.db.tempSettings = nil;
		self:UpdateAll();
	end

	function E:HelloKittyToggle()
		if(HelloKittyLeft and HelloKittyLeft:IsShown()) then
			self:RestoreHelloKitty();
		else
			self:StaticPopup_Show("HELLO_KITTY");
		end
	end
end
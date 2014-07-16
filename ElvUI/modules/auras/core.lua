local E, L, V, P, G = unpack(select(2, ...));
local A = E:NewModule('Auras', 'AceHook-3.0', 'AceEvent-3.0');

A.DIRECTION_TO_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT",
};

A.DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1,
};

A.DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1,
};

A.IS_HORIZONTAL_GROWTH = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true,
};

function A:UpdateTime(elapsed)
	if(self.offset) then
		self.timeLeft = 0;
	else
		self.timeLeft = self.timeLeft - elapsed;
	end
	
	if(self.nextUpdate > 0) then
		self.nextUpdate = self.nextUpdate - elapsed;
		
		return;
	end
	
	local timerValue, formatID;
	
	timerValue, formatID, self.nextUpdate = E:GetTimeInfo(self.timeLeft, A.db.fadeThreshold);
	self.timer:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatID], E.TimeFormats[formatID][1]), timerValue);
	
	if(self.timeLeft > E.db.auras.fadeThreshold) then
		E:StopFlash(self);
	else
		E:Flash(self, 1);
	end
end

function A:Initialize()
	if(self.db) then
		return;
	end

	if(E.private.auras.disableBlizzard) then
		BuffFrame:Kill()
		ConsolidatedBuffs:Kill()
		TemporaryEnchantFrame:Kill();
	end

	if(not E.private.auras.enable) then
		return;
	end

	self.db = E.db.auras;
	
	ElvUIPlayerBuffs:Load();
	ElvUIPlayerDebuffs:Load();
end

E:RegisterModule(A:GetName());
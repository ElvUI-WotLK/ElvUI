local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local UnitIsPlayer = UnitIsPlayer;

function UF:Construct_NameText(frame)
	local name = frame.RaisedElementParent:CreateFontString(nil, "OVERLAY");
	UF:Configure_FontString(name);
	name:Point("CENTER", frame.Health);

	return name;
end

function UF:UpdateNameSettings(frame, childType)
	local db = frame.db
	if(childType == "pet") then
		db = frame.db.petsGroup
	elseif(childType == "target") then
		db = frame.db.targetsGroup;
	end

	local name = frame.Name;
	if(not db.power or not db.power.hideonnpc) then
		local attachPoint = self:GetObjectAnchorPoint(frame, db.name.attachTextTo);
		name:ClearAllPoints();
		name:Point(db.name.position, attachPoint, db.name.position, db.name.xOffset, db.name.yOffset);
	end

	frame:Tag(name, db.name.text_format);
end

function UF:PostNamePosition(frame, unit)
	if(not frame.Power.value:IsShown()) then return; end
	local db = frame.db;
	if(UnitIsPlayer(unit)) then
		local position = db.name.position;
		local attachPoint = self:GetObjectAnchorPoint(frame, db.name.attachTextTo)
		frame.Power.value:SetAlpha(1);

		frame.Name:ClearAllPoints();
		frame.Name:Point(position, attachPoint, position, db.name.xOffset, db.name.yOffset);
	else
		frame.Power.value:SetAlpha(db.power.hideonnpc and 0 or 1);

		frame.Name:ClearAllPoints();
		frame.Name:Point(frame.Power.value:GetPoint());
	end
end
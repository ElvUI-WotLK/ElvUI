local E, L, V, P, G = unpack(select(2, ...));

G["general"] = {
	["autoScale"] = true,
	["minUiScale"] = 0.64,
	["eyefinity"] = false,
	["smallerWorldMap"] = true,
	["mapAlphaWhenMoving"] = 0.35,
	["WorldMapCoordinates"] = {
		["enable"] = true,
		["position"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = 0
	},
	["animateConfig"] = true,
	["versionCheck"] = true
};

G["classtimer"] = {};

G["nameplate"] = {};

G["unitframe"] = {
	["aurafilters"] = {},
	["buffwatch"] = {}
};

G["bags"] = {
	["ignoredItems"] = {}
};
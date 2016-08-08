local E, L, V, P, G = unpack(select(2, ...));

G["general"] = {
	["autoScale"] = true,
	["eyefinity"] = false,
	["smallerWorldMap"] = true,
	["worldMapCoordinates"] = {
		["enable"] = true,
		["position"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = 0
	},
	["animateConfig"] = true
};

G["classtimer"] = {};

G["nameplate"] = {};

G["unitframe"] = {
	["aurafilters"] = {},
	["buffwatch"] = {}
};

local LSM = LibStub('LibSharedMedia-3.0')

if LSM == nil then return end

LSM:Register('statusbar','ElvUI Gloss', [[Interface\AddOns\ElvUI\media\textures\normTex.tga]])
LSM:Register('statusbar','ElvUI Norm', [[Interface\AddOns\ElvUI\media\textures\normTex2.tga]])
LSM:Register('statusbar','Minimalist', [[Interface\AddOns\ElvUI\media\textures\Minimalist.tga]])
LSM:Register('background','ElvUI Blank', [[Interface\BUTTONS\WHITE8X8]])
LSM:Register('border', 'ElvUI GlowBorder', [[Interface\AddOns\ElvUI\media\textures\glowTex.tga]])
LSM:Register('font','ElvUI Font', [[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
LSM:Register('font', 'ElvUI Pixel', [[Interface\AddOns\ElvUI\media\fonts\Homespun.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
LSM:Register('font','ElvUI Combat', [[Interface\AddOns\ElvUI\media\fonts\DieDieDie.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
LSM:Register('sound', 'ElvUI Aska', [[Interface\AddOns\ElvUI\media\sounds\sndIncMsg.wav]])
-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale("ElvUI", "enUS", true, true);
if not L then return; end

-- *_DESC locales
L['AURAS_DESC'] = 'Configure the aura icons that appear near the minimap.'
L["BAGS_DESC"] = "Adjust bag settings for ElvUI."
L["CHAT_DESC"] = "Adjust chat settings for ElvUI."
L["DATATEXT_DESC"] = "Setup the on-screen display of info-texts."
L["ELVUI_DESC"] = "ElvUI is a complete User Interface replacement addon for World of Warcraft."
L["NAMEPLATE_DESC"] = "Modify the nameplate settings."
L['PANEL_DESC'] = "Adjust the size of your left and right panels, this will effect your chat and bags."
L["SKINS_DESC"] = "Adjust Skin settings."
L["TOGGLESKIN_DESC"] = "Enable/Disable this skin."
L["TOOLTIP_DESC"] = "Setup options for the Tooltip."
L["SEARCH_SYNTAX_DESC"] = [=[With the new addition of LibItemSearch, you now have access to much more advanced item searches. The following is a documentation of the search syntax. See the full explanation at: https://github.com/Jaliborc/LibItemSearch-1.2/wiki/Search-Syntax.

Specific Searching:
    • q:[quality] or quality:[quality]. For instance, q:epic will find all epic items.
    • l:[level], lvl:[level] or level:[level]. For example, l:30 will find all items with level 30.
    • t:[search], type:[search] or slot:[search]. For instance, t:weapon will find all weapons.
    • n:[name] or name:[name]. For instance, typing n:muffins will find all items with names containing "muffins".
    • s:[set] or set:[set]. For example, s:fire will find all items in equipment sets you have with names that start with fire.
    • tt:[search], tip:[search] or tooltip:[search]. For instance, tt:binds will find all items that can be bound to account, on equip, or on pickup.


Search Operators:
    • ! : Negates a search. For example, !q:epic will find all items that are NOT epic.
    • | : Joins two searches. Typing q:epic | t:weapon will find all items that are either epic OR weapons.
    • & : Intersects two searches. For instance, q:epic & t:weapon will find all items that are epic AND weapons
    • >, <, <=, => : Performs comparisons on numerical searches. For example, typing lvl: >30 will find all items with level HIGHER than 30.


The following search keywords can also be used:
    • soulbound, bound, bop : Bind on pickup items.
    • bou : Bind on use items.
    • boe : Bind on equip items.
    • boa : Bind on account items.
    • quest : Quest bound items.]=];
L['TEXT_FORMAT_DESC'] = [=[Provide a string to change the text format.

Examples:
[namecolor][name] [difficultycolor][smartlevel] [shortclassification]
[healthcolor][health:current-max]
[powercolor][power:current]

Health / Power Formats:
'current' - current amount
'percent' - percentage amount
'current-max' - current amount followed by maximum amount, will display only max if current is equal to max
'current-percent' - current amount followed by percentage amount, will display only max if current is equal to max
'current-max-percent' - current amount, max amount, followed by percentage amount, will display only max if current is equal to max
'deficit' - display the deficit value, will display nothing if there is no deficit

Name Formats:
'name-short' - Name restricted to 10 characters
'name-medium' - Name restricted to 15 characters
'name-long' - Name restricted to 20 characters

To disable leave the field blank, if you need more information visit http://www.tukui.org]=];

-- Action Bars
L['Darken Inactive'] = true;
L["This setting will be updated upon changing stances."] = true;
L["Action Paging"] = true;
L["ActionBars"] = true;
L['Alpha'] = true;
L["Anchor Point"] = true; --also in unitframes
L['Animation snake :D'] = true;
L["Backdrop"] = true;
L["Button Size"] = true; --Also used in Bags
L["Button Spacing"] = true; --Also used in Bags
L["Buttons Per Row"] = true;
L["Buttons"] = true;
L['Change the alpha level of the frame.'] = true;
L["Color when the text is about to expire"] = true;
L["Color when the text is in the days format."] = true;
L["Color when the text is in the hours format."] = true;
L["Color when the text is in the minutes format."] = true;
L["Color when the text is in the seconds format."] = true;
L["Cooldown Text"] = true;
L["Days"] = true;
L["Display bind names on action buttons."] = true;
L["Display cooldown text on anything with the cooldown spiril."] = true;
L["Display macro names on action buttons."] = true;
L["Expiring"] = true;
L["Height Multiplier"] = true;
L["Hours"] = true;
L['Key Down'] = true;
L["Keybind Mode"] = true;
L["Keybind Text"] = true;
L["Low Threshold"] = true;
L["Macro Text"] = true;
L["Minutes"] = true;
L["Mouse Over"] = true; --Also used in Bags
L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."] = true;
L['Out of Power'] = true;
L['Out of Range'] = true;
L["Restore Bar"] = true;
L["Restore the actionbars default settings"] = true;
L["Scale"] = true;
L["Seconds"] = true;
L['Speed of the animation when you hover'] = true;
L["Set the font size of the action buttons."] = true;
L["The amount of buttons to display per row."] = true;
L["The amount of buttons to display."] = true;
L['The button you must hold down in order to drag an ability to another action button.'] = true;
L["The first button anchors itself to this point on the bar."] = true;
L["The size of the action buttons."] = true;
L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"] = true;
L["Toggles the display of the actionbars backdrop."] = true;
L["Visibility State"] = true;
L["Width Multiplier"] = true;
L[ [=[This works like a macro, you can run different situations to get the actionbar to page differently.
 Example: '[combat] 2;']=] ] = true;
L[ [=[This works like a macro, you can run different situations to get the actionbar to show/hide differently.
 Example: '[combat] show;hide']=] ] = true;

-- Bags
L["Adjust the width of the bag frame."] = true;
L["Adjust the width of the bank frame."] = true;
L["Align the width of the bag frame to fit inside the chat box."] = true;
L["Align To Chat"] = true;
L["Ascending"] = true;
L["Bag-Bar"] = true;
L["Bar Direction"] = true;
L["Blizzard Style"] = true;
L["Bottom to Top"] = true;
L["Button Size (Bag)"] = true;
L["Button Size (Bank)"] = true;
L["Condensed"] = true;
L["Currency Format"] = true;
L["Descending"] = true;
L["Direction the bag sorting will use to allocate the items."] = true;
L["Display Item Level"] = true;
L["Displays item level on equippable items."] = true;
L["Enable/Disable the all-in-one bag."] = true;
L["Enable/Disable the Bag-Bar."] = true;
L["Full"] = true;
L["Icons and Text"] = true;
L["Ignore Items"] = true;
L["Item Count Font"] = true;
L["Item Level Threshold"] = true;
L["Item Level"] = true;
L["List of items to ignore when sorting. If you wish to add multiple items you must seperate the word with a comma."] = true;
L["Money Format"] = true;
L["Panel Width (Bags)"] = true;
L["Panel Width (Bank)"] = true;
L["Search Syntax"] = true;
L["Set the size of your bag buttons."] = true;
L["Short (Whole Numbers)"] = true;
L["Short"] = true;
L["Show Coins"] = true;
L["Smart"] = true;
L["Sort Direction"] = true; -- Also used in Buffs and Debuffs
L["Sort Inverted"] = true;
L["The direction that the bag frames be (Horizontal or Vertical)."] = true;
L["The direction that the bag frames will grow from the anchor."] = true;
L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"] = true;
L["The display format of the money text that is shown at the top of the main bag."] = true;
L["The frame is not shown unless you mouse over the frame."] = true;
L["The minimum item level required for it to be shown."] = true;
L["The size of the individual buttons on the bag frame."] = true;
L["The size of the individual buttons on the bank frame."] = true;
L["The spacing between buttons."] = true;
L["Top to Bottom"] = true;
L["Use coin icons instead of colored text."] = true;
L["X Offset Bags"] = true;
L["X Offset Bank"] = true;
L["Y Offset Bags"] = true;
L["Y Offset Bank"] = true;

--Buffs and Debuffs
L['Begin a new row or column after this many auras.'] = true;
L['Count xOffset'] = true;
L['Count yOffset'] = true;
L['Defines how the group is sorted.'] = true;
L['Defines the sort order of the selected sort method.'] = true;
L['Disabled Blizzard'] = true;
L["Fade Threshold"] = true;
L['Index'] = true;
L['Indicate whether buffs you cast yourself should be separated before or after.'] = true;
L['Limit the number of rows or columns.'] = true;
L['Max Wraps'] = true;
L['No Sorting'] = true;
L["Other's First"] = true;
L['Seperate'] = true;
L['Set the size of the individual auras.'] = true;
L['Sort Method'] = true;
L['The direction the auras will grow and then the direction they will grow after they reach the wrap after limit.'] = true;
L['Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable.'] = true;
L['Time xOffset'] = true;
L['Time yOffset'] = true;
L['Time'] = true;
L['Wrap After'] = true;
L['Your Auras First'] = true;

--Chat
L['Above Chat'] = true;
L["Attempt to create URL links inside the chat."] = true;
L['Attempt to lock the left and right chat frame positions. Disabling this option will allow you to move the main chat frame anywhere you wish.'] = true;
L['Below Chat'] = true;
L['Chat EditBox Position'] = true;
L['Chat History'] = true;
L["Copy Text"] = true;
L["Display the hyperlink tooltip while hovering over a hyperlink."] = true;
L['Fade Chat'] = true;
L["Fade Tabs No Backdrop"] = true;
L['Fade the chat text when there is no activity.'] = true;
L["Fade Undocked Tabs"] = true;
L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."] = true;
L["Fades the text on chat tabs that are not docked at the left or right chat panel."] = true;
L["Font Outline"] = true; --Also used in UnitFrames section
L["Font"] = true;
L['Hide Both'] = true;
L["Hyperlink Hover"] = true;
L["Keyword Alert"] = true;
L['Keywords'] = true;
L['Left Only'] = true;
L['List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank'] = true;
L['Lock Positions'] = true;
L['Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session.'] = true;
L["No Alert In Combat"] = true;
L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."] = true;
L["Panel Backdrop"] = true;
L["Panel Height"] = true;
L["Panel Texture (Left)"] = true;
L["Panel Texture (Right)"] = true;
L['Panel Width'] = true;
L['Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat.'] = true;
L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."] = true;
L['Right Only'] = true;
L['Right Panel Height'] = true;
L['Right Panel Width'] = true;
L["Scroll Interval"] = true;
L["Separate Panel Sizes"] = true;
L["Set the font outline."] = true; --Also used in UnitFrames section
L["Short Channels"] = true;
L["Shorten the channel names in chat."] = true;
L['Show Both'] = true;
L["Spam Interval"] = true;
L["Sticky Chat"] = true;
L["Tab Font Outline"] = true;
L["Tab Font Size"] = true;
L["Tab Font"] = true;
L['Tab Panel Transparency'] = true;
L['Tab Panel'] = true;
L['Toggle showing of the left and right chat panels.'] = true;
L['Toggle the chat tab panel backdrop.'] = true;
L["URL Links"] = true;
L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."] = true;
L["Whisper Alert"] = true;
L[ [=[Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.

Please Note:
-The image size recommended is 256x128
-You must do a complete game restart after adding a file to the folder.
-The file type must be tga format.

Example: Interface\AddOns\ElvUI\media\textures\copy

Or for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here.]=] ] = true;

--Credits
L["Coding:"] = true;
L["Credits"] = true;
L["Donations:"] = true;
L["ELVUI_CREDITS"] = "I would like to give out a special shout out to the following people for helping me maintain this addon with testing and coding and people who also have helped me through donations. Please note for donations I'm only posting the names of people who PM'd me on the forums, if your name is missing and you wish to have your name added please PM me."
L["Testing:"] = true;

--DataTexts
L["24-Hour Time"] = true;
L['Always Display'] = true;
L['Battleground Texts'] = true;
L['Change settings for the display of the location text that is on the minimap.'] = true;
L['Datatext Panel (Left)'] = true;
L['Datatext Panel (Right)'] = true;
L["DataTexts"] = true;
L['Display data panels below the chat, used for datatexts.'] = true;
L['Display minimap panels below the minimap, used for datatexts.'] = true;
L["If not set to true then the server time will be displayed instead."] = true;
L["left"] = "Left"
L["LeftChatDataPanel"] = "Left Chat"
L["LeftMiniPanel"] = "Minimap Left"
L["Local Time"] = true;
L['Location Text'] = true;
L["middle"] = "Middle"
L['Minimap Mouseover'] = true;
L['Minimap Panels'] = true;
L['Panel Transparency'] = true;
L["Panels"] = true;
L["right"] = "Right"
L["RightChatDataPanel"] = "Right Chat"
L["RightMiniPanel"] = "Minimap Right"
L["Toggle 24-hour mode for the time datatext."] = true;
L['When inside a battleground display personal scoreboard information on the main datatext bars.'] = true;

--Distributor
L["Must be in group with the player if he isn't on the same server as you."] = true;
L["Sends your current profile to your target."] = true;
L["Sends your filter settings to your target."] = true;
L["Share Current Profile"] = true;
L["Share Filters"] = true;
L["This feature will allow you to transfer, settings to other characters."] = true;
L["You must be targeting a player."] = true;

--General
L["Accept Invites"] = true;
L['Adjust the position of the threat bar to either the left or right datatext panels.'] = true;
L['Adjust the size of the minimap.'] = true;
L["Announce Interrupts"] = true;
L["Announce when you interrupt a spell to the specified chat channel."] = true;
L['Auto Greed/DE'] = true;
L["Auto Repair"] = true;
L["Auto Scale"] = true;
L["Automatically accept invites from guild/friends."] = true;
L["Automatically repair using the following method when visiting a merchant."] = true;
L["Automatically scale the User Interface based on your screen resolution"] = true;
L['Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level.'] = true;
L["Automatically vendor gray items when visiting a vendor."] = true;
L['Bottom Panel'] = true;
L['Chat Bubbles Style'] = true;
L["Controls what the transparency of the worldmap will be set to when you are moving."] = true;
L['Display a panel across the bottom of the screen. This is for cosmetic only.'] = true;
L['Display a panel across the top of the screen. This is for cosmetic only.'] = true;
L['Display emotion icons in chat.'] = true;
L['Emotion Icons'] = true;
L["Enable/Disable the loot frame."] = true;
L["Enable/Disable the loot roll frame."] = true;
L['Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r'] = true;
L["General"] = true;
L["Hide Error Text"] = true;
L["Hides the red error text at the top of the screen while in combat."] = true;
L['Left'] = true;
L["Log Taints"] = true;
L["Login Message"] = true;
L["Loot Roll"] = true;
L["Loot"] = true;
L["Make the world map smaller."] = true;
L["Map Alpha While Moving"] = true;
L["Name Font"] = true;
L["Party / Raid"] = true;
L["Party Only"] = true;
L["Puts coordinates on the world map."] = true;
L["Raid Only"] = true;
L['Remaining Time'] = true;
L['Remove Backdrop'] = true;
L["Reset all frames to their original positions."] = true;
L["Reset Anchors"] = true;
L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."] = true;
L['Skin Backdrop'] = true;
L["Skin the blizzard chat bubbles."] = true;
L["Smaller World Map"] = true;
L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = true;
L['Toggle Tutorials'] = true;
L['Top Panel'] = true;
L["When you go AFK display the AFK screen."] = true;
L["World Map Coordinates"] = true;

--Media
L["Backdrop color of transparent frames"] = true;
L["Backdrop Color"] = true;
L["Backdrop Faded Color"] = true;
L["Border Color"] = true;
L["Color some texts use."] = true;
L["Colors"] = true; --Also used in UnitFrames
L["CombatText Font"] = true;
L["Default Font"] = true;
L["Font Size"] = true; --Also used in UnitFrames
L["Fonts"] = true;
L["Main backdrop color of the UI."] = true;
L["Main border color of the UI. |cffFF0000This is disabled if you are using the pixel perfect theme.|r"] = true;
L["Media"] = true;
L["Primary Texture"] = true;
L["Secondary Texture"] = true;
L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = true;
L["Textures"] = true;
L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = true;
L["The font that the core of the UI will use."] = true;
L["The texture that will be used mainly for statusbars."] = true;
L["This texture will get used on objects like chat windows and dropdown menus."] = true;
L["Value Color"] = true;

--Misc
L['Install'] = true;
L["Run the installation process."] = true;
L["Toggle Anchors"] = true;
L["Unlock various elements of the UI to be repositioned."] = true;
L["Version"] = true;

--NamePlates
L["Add Name"] = true;
L["Adjust nameplate size on low health"] = true;
L["All"] = true;
L["Alpha of current target nameplate."] = true;
L["Alpha of nameplates that are not your current target."] = true;
L["Always display your personal auras over the nameplate."] = true;
L["Bad Transition"] = true;
L["Bring nameplate to front on low health"] = true;
L["Bring to front on low health"] = true;
L["Can Interrupt"] = true;
L["Cast Bar"] = true;
L["Castbar Height"] = true;
L["Change color on low health"] = true;
L["Color By Healthbar"]  = true;
L["Color By Raid Icon"] = true;
L["Color Name By Health Value"] = true;
L["Color on low health"] = true;
L["Color the border of the nameplate yellow when it reaches this point, it will be colored red when it reaches half this value."] = true;
L["Combat Toggle"] = true;
L["Combo Points"] = true;
L["Configure Selected Filter"] = true;
L["Controls the height of the nameplate on low health"] = true;
L["Controls the height of the nameplate"] = true;
L["Controls the width of the nameplate on low health"] = true;
L["Controls the width of the nameplate"] = true;
L["Custom Color"] = true;
L["Custom Scale"] = true;
L["Disable threat coloring for this plate and use the custom color."] = true;
L["Display combo points on nameplates."] = true;
L["Enemy"] = true; --Also used in UnitFrames
L["Filter already exists!"] = true;
L["Filters"] = true; --Also used in UnitFrames
L["Friendly NPC"] = true;
L["Friendly Player"] = true;
L["Good Transition"] = true;
L["Hide"] = true; --Also used in DataTexts
L["Horrizontal Arrows (Inverted)"] = true;
L["Horrizontal Arrows"] = true;
L["Low Health Threshold"] = true;
L["Low HP Height"] = true;
L["Low HP Width"] = true;
L["Match the color of the healthbar."] = true;
L["NamePlates"] = true;
L["No Interrupt"] = true;
L["Non-Target Alpha"] = true;
L["Number of Auras"] = true;
L["Prevent any nameplate with this unit name from showing."] = true;
L["Raid Icon"] = true;
L["Reaction Coloring"] = true;
L["Remove Name"] = true;
L["Scale if Low Health"] = true;
L["Scaling"] = true;
L["Set the scale of the nameplate."] = true;
L["Show Level"] = true;
L["Show Name"] = true;
L["Show Personal Auras"] = true;
L["Stretch Texture"] = true;
L["Stretch the icon texture, intended for icons that don't have the same width/height."] = true;
L["Tagged NPC"] = true;
L["Target Alpha"] = true;
L["Target Indicator"] = true;
L["Threat"] = true;
L["Toggle the nameplates to be visible outside of combat and visible inside combat."] = true;
L["Use this filter."] = true;
L["Vertical Arrow"] = true;
L["Wrap Name"] = true;
L["Wraps name instead of truncating it."] = true;
L["X-Offset"] = true;
L["Y-Offset"] = true;
L["You can't remove a default name from the filter, disabling the name."] = true;

--Profiles Export/Import
L["Choose Export Format"] = true;
L["Choose What To Export"] = true;
L["Decode Text"] = true;
L["Error decoding data. Import string may be corrupted!"] = true;
L["Error exporting profile!"] = true;
L["Export Now"] = true;
L["Export Profile"] = true;
L["Exported"] = true;
L["Filters (All)"] = true;
L["Filters (NamePlates)"] = true;
L["Filters (UnitFrames)"] = true;
L["Global (Account Settings)"] = true;
L["Import Now"] = true;
L["Import Profile"] = true;
L["Importing"] = true;
L["Plugin"] = true;
L["Private (Character Settings)"] = true;
L["Profile imported successfully!"] = true;
L["Profile Name"] = true;
L["Profile"] = true;
L["Table"] = true;

--Skins
L["Achievement Frame"] = true;
L['Alert Frames'] = true;
L["Archaeology Frame"] = true;
L["Auction Frame"] = true;
L["Barbershop Frame"] = true;
L["BG Map"] = true;
L["BG Score"] = true;
L['Black Market AH'] = true;
L["Calendar Frame"] = true;
L["Character Frame"] = true;
L["Debug Tools"] = true;
L["Dressing Room"] = true;
L["Encounter Journal"] = true;
L["Glyph Frame"] = true;
L["Gossip Frame"] = true;
L["Greeting Frame"] = true;
L["Guild Bank"] = true;
L["Guild Control Frame"] = true;
L["Guild Frame"] = true;
L["Guild Registrar"] = true;
L["Help Frame"] = true;
L["Inspect Frame"] = true;
L['Item Upgrade'] = true;
L["KeyBinding Frame"] = true;
L["LF Guild Frame"] = true;
L["LFG Frame"] = true;
L["Loot Frames"] = true;
L['Loss Control'] = true;
L["Macro Frame"] = true;
L["Mail Frame"] = true;
L["Merchant Frame"] = true;
L["Misc Frames"] = true;
L["Mounts & Pets"] = true;
L["Non-Raid Frame"] = true;
L["Pet Battle"] = true;
L["Petition Frame"] = true;
L["PvP Frames"] = true;
L["Quest Frames"] = true;
L["Raid Frame"] = true;
L["Reforge Frame"] = true;
L["Skins"] = true;
L["Socket Frame"] = true;
L["Spellbook"] = true;
L["Stable"] = true;
L["Tabard Frame"] = true;
L["Talent Frame"] = true;
L["Taxi Frame"] = true;
L["Time Manager"] = true;
L["Trade Frame"] = true;
L["TradeSkill Frame"] = true;
L["Trainer Frame"] = true;
L['Transmogrify Frame'] = true;
L['Void Storage'] = true;
L["World Map"] = true;

--Static Popups
L["Are you sure you want to reset all the settings on this profile?"] = true;
L["Enabling/Disabling Bar #6 will toggle a paging option from your main actionbar to prevent duplicating bars, are you sure you want to do this?"] = true;

--Tooltip
L['Always Hide'] = true;
L["Anchor Mode"] = true;
L["Anchor"] = true;
L["Bags Only"] = true;
L["Bags/Bank"] = true;
L["Bank Only"] = true;
L["Both"] = true;
L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."] = true;
L["Cursor"] = true;
L['Display guild ranks if a unit is guilded.'] = true;
L['Display how many of a certain item you have in your possession.'] = true;
L['Display player titles.'] = true;
L['Display the health text on the tooltip.'] = true;
L['Display the players talent spec in the tooltip, this may not immediately update when mousing over a unit.'] = true;
L['Display the spell or item ID when mousing over a spell or item tooltip.'] = true;
L["Don't display the tooltip when mousing over a unitframe."] = true;
L['Guild Ranks'] = true;
L['Health Height'] = true;
L["Hide tooltip while in combat."] = true;
L['Item Count'] = true;
L['Never Hide'] = true;
L['Player Titles'] = true;
L['Set the height of the tooltip healthbar.'] = true;
L["Set the type of anchor mode the tooltip should use."] = true;
L["Smart"] = true;
L['Spell/Item IDs'] = true;
L['Talent Spec'] = true;
L["UF Hide"] = true;
L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."] = true;
L["Who's targeting who?"] = true;

--UnitFrames
L['%s and then %s'] = true;
L['2D'] = true;
L['3D'] = true;
L['Above'] = true;
L["Absorbs"] = true;
L["Add a spell to the filter."] = true;
L["Add Spell Name"] = true;
L["Add Spell or spellID"] = true;
L["Add Spell"] = true;
L["Add SpellID"] = true;
L["Additional Filter"] = true;
L["Affliction"] = true;
L["Allow Whitelisted Auras"] = true;
L["Ascending or Descending order."] = true;
L['Arcane Charges'] = true;
L['Ascending'] = true;
L["Assist Frames"] = true;
L['Assist Target'] = true;
L['At what point should the text be displayed. Set to -1 to disable.'] = true;
L['Attach Text to Power'] = true;
L["Attach To"] = true;
L['Aura Bars'] = true;
L['Auto-Hide'] = true;
L["Bad"] = true;
L["Bars will transition smoothly."] = true;
L['Below'] = true;
L["Blacklist"] = true;
L["Block Auras Without Duration"] = true;
L["Block Blacklisted Auras"] = true;
L['Block Non-Dispellable Auras'] = true;
L["Block Non-Personal Auras"] = true;
L["Block Raid Buffs"] = true;
L['Blood'] = true;
L['Borders'] = true;
L["Buff Indicator"] = true;
L["Buffs"] = true;
L['By Type'] = true;
L["Camera Distance Scale"] = true;
L["Castbar"] = true;
L['Center'] = true;
L["Check if you are in range to cast spells on this specific unit."] = true;
L["Class Backdrop"] = true;
L['Class Castbars'] = true;
L['Class Color Override'] = true;
L["Class Health"] = true;
L["Class Power"] = true;
L['Class Resources'] = true;
L["Classbar"] = true;
L['Click Through'] = true;
L["Color all buffs that reduce the unit's incoming damage."] = true;
L['Color aurabar debuffs by type.'] = true;
L['Color castbars by the class or reaction type of the unit.'] = true;
L["Color health by amount remaining."] = true;
L["Color health by classcolor or reaction."] = true;
L["Color power by classcolor or reaction."] = true;
L["Color the health backdrop by class or reaction."] = true;
L["Color the unit healthbar if there is a debuff that can be dispelled by you."] = true;
L['Color Turtle Buffs'] = true;
L["Color"] = true;
L['Colored Icon'] = true;
L['Coloring (Specific)'] = true
L['Coloring'] = true
L["Combat Fade"] = true;
L["Combobar"] = true;
L['Configure Auras'] = true;
L["Copy From"] = true;
L["Count Font Size"] = true;
L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'] = true;
L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."] = true;
L["Create Filter"] = true;
L['Current - Max | Percent'] = true;
L["Current - Max"] = true;
L["Current - Percent"] = true;
L["Current / Max"] = true;
L["Current"] = true;
L["Custom Dead Backdrop"] = true;
L["Custom Health Backdrop"] = true;
L['Custom Texts'] = true;
L['Death'] = true;
L["Debuff Highlighting"] = true;
L["Debuffs"] = true;
L["Decimal Threshold"] = true;
L["Deficit"] = true;
L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."] = true;
L["Delete Filter"] = true;
L["Demonology"] = true;
L['Descending'] = true;
L["Destruction"] = true;
L['Detach From Frame'] = true;
L['Detached Width'] = true;
L["Direction the health bar moves when gaining/losing health."] = true;
L["Disable Blizzard"] = true;
L['Disabled'] = true;
L["Disables the blizzard party/raid frames."] = true;
L["Disconnected"] = true;
L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."] = true;
L['Display Frames'] = true;
L["Display Player"] = true;
L['Display Target'] = true;
L['Display Text'] = true;
L["Display the rested icon on the unitframe."] = true;
L['Display the target of your current cast. Useful for mouseover casts.'] = true;
L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."] = true;
L["Don't display any auras found on the 'Blacklist' filter."] = true;
L["Don't display auras that are not yours."] = true;
L["Don't display auras that cannot be purged or dispelled by your class."] = true;
L["Don't display auras that have no duration."] = true;
L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."] = true;
L["Down"] = true;
L['Duration Reverse'] = true;
L['Duration'] = true;
L['Enemy Aura Type'] = true;
L['Faction Icon'] = true;
L["Fade the unitframe when out of combat, not casting, no target exists."] = true;
L["Fill"] = true;
L["Filled"] = true;
L["Filter Type"] = true;
L['Force Off'] = true;
L['Force On'] = true;
L['Force Reaction Color'] = true;
L['Force the frames to show, they will act as if they are the player frame.'] = true;
L['Forces reaction color instead of class color on units controlled by players.'] = true;
L["Format"] = true;
L["Frame"] = true;
L["Frequent Updates"] = true;
L['Friendlies: Show Buffs'] = true;
L['Friendlies: Show Debuffs'] = true;
L['Friendly Aura Type'] = true;
L['Friendly'] = true;
L['Frost'] = true;
L['Glow'] = true;
L["Good"] = true;
L["Group By"] = true;
L['Group Size'] = true;
L['Growth direction from the first unitframe.'] = true;
L['Growth Direction'] = true;
L['Harmony'] = true;
L["Heal Prediction"] = true;
L["Health Backdrop"] = true;
L['Health Border'] = true;
L["Health By Value"] = true;
L["Health Text"] = true;
L["Health"] = true;
L["Height"] = true;
L['Holy Power'] = true;
L['Horizontal Spacing'] = true;
L["Horizontal"] = true; --Also used in bags module
L["How far away the portrait is from the camera."] = true;
L["Icon"] = true;
L['Icon: BOTTOM'] = true;
L['Icon: BOTTOMLEFT'] = true;
L['Icon: BOTTOMRIGHT'] = true;
L['Icon: LEFT'] = true;
L['Icon: RIGHT'] = true;
L['Icon: TOP'] = true;
L['Icon: TOPLEFT'] = true;
L['Icon: TOPRIGHT'] = true;
L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = true;
L['If not set to 0 then override the size of the aura icon to this.'] = true;
L["If the unit is an enemy to you."] = true;
L["If the unit is friendly to you."] = true;
L['Ignore mouse events.'] = true;
L['Inset'] = true;
L['Interruptable'] = true;
L['Invert Grouping Order'] = true;
L['JustifyH'] = true;
L["Latency"] = true;
L["Left to Right"] = true;
L["Low Mana Threshold"] = true;
L['Lunar'] = true;
L["Main statusbar texture."] = true;
L['Main Tanks / Main Assist'] = true;
L['Make textures transparent.'] = true;
L["Match Frame Width"] = true;
L["Maximum Duration"] = true;
L["Method to sort by."] = true;
L['Middle Click - Set Focus'] = true;
L['Middle clicking the unit frame will cause your focus to match the unit.'] = true;
L['Model Rotation'] = true;
L['Mouseover'] = true;
L['Name (Entire Group)'] = true;
L["Name"] = true; --Also used in Buffs and Debuffs
L["Neutral"] = true;
L['Non-Interruptable'] = true;
L["None"] = true; --Also used in chat
L["Not valid spell id"] = true;
L["Num Rows"] = true;
L['Number of Groups'] = true;
L['Number of units in a group.'] = true;
L["Offset of the powerbar to the healthbar, set to 0 to disable."] = true;
L['Offset position for text.'] = true;
L["Offset"] = true;
L['Only show when the unit is not in range.'] = true;
L['Only show when you are mousing over a frame.'] = true;
L["OOR Alpha"] = true;
L["Orientation"] = true;
L["Others"] = true;
L["Overlay the healthbar"] = true;
L["Overlay"] = true;
L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."] = true;
L['Override the default class color setting.'] = true;
L["Party Pets"] = true;
L["Party Targets"] = true;
L["Per Row"] = true;
L["Percent"] = true;
L["Personal"] = true;
L['Player Frame Aura Bars'] = true;
L["Portrait"] = true;
L["Position"] = true;
L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."] = true;
L["Power"] = true;
L["Powers"] = true;
L["Priority"] = true;
L['PVP Trinket'] = true;
L['Raid Icon'] = true;
L['Raid-10 Frames'] = true;
L['Raid-25 Frames'] = true;
L['Raid-40 Frames'] = true;
L["RaidDebuff Indicator"] = true;
L["Range Check"] = true
L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."] = true;
L["Reactions"] = true;
L["Remaining"] = true;
L["Remove a spell from the filter."] = true;
L["Remove Spell or spellID"] = true;
L["Remove Spell"] = true;
L["Remove SpellID"] = true;
L["Rest Icon"] = true;
L["Restore Defaults"] = true; --Also used in Media and ActionBars sections
L['Reverses the grouping order. For example if your group is to grow right than up by default the first group is always at the bottom. With this option set then the first group will start at the bottom but as the number of groups grow it will always be near the top.'] = true;
L["Right to Left"] = true;
L['RL / ML Icons'] = true;
L["Role Icon"] = true;
L["Seconds remaining on the aura duration before the bar starts moving. Set to 0 to disable."] = true;
L["Select a filter to use."] = true; --Also used in NamePlates
L["Select a unit to copy settings from."] = true;
L['Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings.'] = true;
L["Select Filter"] = true;
L["Select Spell"] = true;
L['Select the display method of the portrait.'] = true;
L["Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else."] = true;
L["Set the font size for unitframes."] = true;
L["Set the order that the group will sort."] = true;
L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."] = true;
L['Set the type of auras to show when a unit is a foe.'] = true;
L['Set the type of auras to show when a unit is friendly.'] = true;
L["Sets the font instance's horizontal text alignment style."] = true;
L['Shadow Orbs'] = true;
L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."] = true;
L["Show Aura From Other Players"] = true;
L['Show Auras'] = true;
L["Show When Not Active"] = true;
L["Show"] = true;
L["Size of the indicator icon."] = true;
L['Size Override'] = true;
L["Size"] = true;
L['Smart Auras'] = true;
L["Smart Raid Filter"] = true;
L["Smooth Bars"] = true;
L["Sort By"] = true;
L["Spaced"] = true;
L["Spacing"] = true;
L["Spark"] = true;
L["Spell not found in list."] = true;
L['Spells'] = true;
L["Stack Threshold"] = true;
L['Start near Center'] = true;
L["StatusBar Texture"] = true;
L['Style'] = true;
L["Tank Frames"] = true;
L['Tank Target'] = true;
L["Tapped"] = true;
L["Target On Mouse-Down"] = true;
L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon 'Clique' you may have to adjust your clique settings when changing this."] = true;
L['Text Color'] = true;
L["Text Format"] = true;
L['Text Position'] = true
L['Text Threshold'] = true;
L["Text Toggle On NPC"] = true;
L['Text xOffset'] = true
L['Text yOffset'] = true
L['Text'] = true;
L['Textured Icon'] = true;
L["The alpha to set units that are out of range to."] = true;
L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."] = true;
L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."] = true;
L["The font that the unitframes will use."] = true;
L['The initial group will start near the center and grow out. Corrosponding groups will behave normally.'] = true;
L['The name you have selected is already in use by another element.'] = true;
L['The object you want to attach to.'] = true;
L["This filter is meant to be used when you only want to whitelist specific spellIDs which share names with unwanted spells."] = true;
L['This filter is used for both aura bars and aura icons no matter what. Its purpose is to block out specific spellids from being shown. For example a paladin can have two sacred shield buffs at once, we block out the short one.'] = true;
L['Threat Display Mode'] = true;
L["Threshold before text goes into decimal form. Set to -1 to disable decimals."] = true;
L["Ticks"] = true;
L['Time Remaining Reverse'] = true;
L['Time Remaining'] = true;
L["Toggles health text display"] = true;
L['Transparent'] = true;
L['Turtle Color'] = true;
L['Unholy'] = true;
L["Uniform Threshold"] = true;
L["UnitFrames"] = true;
L["Up"] = true;
L['Use Default'] = true;
L["Use the custom health backdrop color instead of a multiple of the main health color."] = true;
L["Use this backdrop color for units that are dead or ghosts."] = true;
L["Value must be a number"] = true;
L['Vertical Spacing'] = true;
L["Vertical"] = true; --Also used in bags section
L["Visibility"] = true;
L["What point to anchor to the frame you set to attach to."] = true;
L["What to attach the buff anchor frame to."] = true;
L["What to attach the debuff anchor frame to."] = true;
L['When set the Buffs and Debuffs will toggle being displayed depending on if the unit is friendly or an enemy. This will not effect the aurabars module.'] = true;
L["When true, the header includes the player when not in a raid."] = true;
L["When you mana falls below this point, text will flash on the player frame."] = true;
L["Whitelist"] = true;
L["Width"] = true; --Also used in NamePlates module
L["xOffset"] = true;
L["yOffset"] = true;
L["You can't remove a pre-existing filter."] = true;
L["You cannot copy settings from the same unit."] = true;
L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."] = true;
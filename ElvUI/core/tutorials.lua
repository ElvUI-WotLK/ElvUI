local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local _G = _G;

local CreateFrame = CreateFrame;
local DISABLE = DISABLE;
local HIDE = HIDE;

E.TutorialList = {
	L["Nearby questgivers that are awaiting your return are shown as a question mark on your mini-map."],
	L["Your spell casting can be cancelled by moving, jumping or hitting the escape key."],
	L["Clicking on a player name in the chat window lets you send a private message to them."],
	L["If you <Shift>Click on a player name in the chat window it tells you additional information about them."],
	L["You can <Control>Click on an item to see how you would look wearing that item."],
	L["An item with its name in gray is a poor quality item and generally can be sold to a vendor."],
	L["An item with its name in white is useful to players in some way and can be used or sold at the auction house."],
	L["You can send mail to other players or even to your other characters from any mailbox in game."],
	L["You can <Shift>Click on an item to place an item link into a chat message."],
	L["You can remove a friendly spell enhancement on yourself by right-clicking on the spell effect icon."],
	L["When you learn a profession or secondary skill the button that allows you to perform that skill is found in the general tab of your spellbook."],
	L["All of your action bars can have their hotkeys remapped in the key bindings interface."],
	L["On your character sheet is a reputation tab that tells you your status with different groups."],
	L["You can use the Tab key to select nearby enemies in front of you."],
	L["If you are having trouble finding something in a capital city, try asking a guard for directions."],
	L["You can use the V key to show enemy name plates above the enemy's head.  Name plates may help you keep track of enemy health or spell casting, or may make it easier to quickly change targets."],
	L["You can track many things, such as low-level quests or vendors by clicking on the magnifying glass near your mini map."],
	L["You can perform many fun actions with the emote system, for instance you can type /dance to dance."],
	L["A Blizzard employee will NEVER ask for your password."],
	L["You can only know two professions at a time, but you can learn all of the secondary skills (fishing, cooking and first-aid)."],
	L["The interface options menu <ESC> has lots of ways to customize your game play."],
	L["You can turn on slow scrolling of quest text in the interface options menu."],
	L["Spend your talent points carefully as once your talents are chosen, you must spend gold to unlearn them."],
	L["A mail icon next to the minimap means you have new mail.  Visit a mailbox to retrieve it."],
	L["You can add additional action bars to your game interface from the interface options menu."],
	L["If you hold down <Shift> while right-clicking on a target to loot, you will automatically loot all items on the target."],
	L["Your character can eat and drink at the same time."],
	L["If you enjoyed playing with someone from your realm, put them on your friends list!"],
	L["Use the Dungeon Finder tool to quickly travel to dungeons or to find more players for your dungeon group."],
	L["There are a number of different loot options when in a group. The group leader can right-click their own portrait to change the options."],
	L["If you never want to hear from another player again, you can /ignore them. You can always change your mind later."],
	L["You can target members of your party with the function keys.  F1 targets you; F2 targets the second party member."],
	L["Being polite while in a group with others will get you invited back!"],
	L["Remember to take all things in moderation (even World of Warcraft!)"],
	L["You can click on a faction in the reputation pane to get additional information and options about that faction."],
	L["A monster with a silver dragon around its portrait is a rare monster with better than average treasure."],
	L["If you mouse over a chat pane it will become visible and you can Right Click on the chat pane tab for options."],
	L["Sharing an account with someone else can compromise its security."],
	L["You can display the duration of beneficial spells on you from the interface options menu."],
	L["You can lock your action bar so you don't accidentally move spells. This is done using the interface options menu."],
	L["You can change which buffs or debuffs are displayed on yourself or targets in order to get the information you need."],
	L["You can cast a spell on yourself without deselecting your current target by holding down <Alt> while pressing your hotkey."],
	L["Ensure that all party members are on the same stage of an escort quest before beginning it."],
	L["You're much less likely to encounter wandering monsters while following a road."],
	L["Killing guards gives no honor."],
	L["You can hide your interface with <Alt>Z and take screenshots with <Print Screen>."],
	L["Typing /macro will bring up the interface to create macros."],
	L["Enemy players whose names appear in gray are much lower level than you are and will not give honor when killed."],
	L["From the Raid UI you can drag a player to the game field to see their status or drag a class icon to see all members of that class."],
	L["A blue question mark above a quest giver means the quest is repeatable."],
	L["Use the assist button (F key) while targeting another player, and it will target the same target as that player."],
	L["<Shift>Clicking on an item being sold by a vendor will let you select how many of that item you wish to purchase."],
	L["Playing in a battleground on its holiday weekend increases your honor gained."],
	L["If you are having trouble fishing in an area, try attaching a lure to your fishing pole."],
	L["You can view messages you previously sent in chat by pressing <Alt> and the up arrow key."],
	L["You can Shift-Click on an item stack to split it into smaller stacks."],
	L["Pressing both mouse buttons simultaneously will make your character run."],
	L["When replying to a tell from a player (Default 'R'), the <TAB> key cycles through people you have recently replied to."],
	L["Clicking an item name that appears bracketed in chat will tell you more about the item."],
	L["It's considered polite to talk to someone before inviting them into a group, or opening a trade window."],
	L["Your items do not suffer durability damage when you are killed by an enemy player."],
	L["<Shift>click on a quest in your quest log to toggle quest tracking for that quest."],
	L["The auction houses in each of your faction's major cities are linked together."],
	L["Nearby questgivers that are awaiting your return are shown as a yellow question mark on your mini-map."],
	L["Quests completed at maximum level award money instead of experience."],
	L["<Shift>-B will open all your bags at once."],
	L["When interacting with other players a little kindness goes a long way!"],
	L["Bring your friends to Azeroth, but don't forget to go outside Azeroth with them as well."],
	L["If you keep an empty mailbox, the mail icon will let you know when you have new mail waiting!"],
	L["Never give another player your account information."],
	L["When a player not in your group damages a monster before you do, it will display a gray health bar and you will get no loot or experience from killing it."],
	L["You can see the spell that your current target is casting by turning on the 'Cast Bars' options in the combat interface options tab."],
	L["You can access the map either by clicking the map button in the upper right of the mini-map or by hitting the 'M' key. The map can help you locate where you need to go to complete a quest."],
	L["Many high level dungeons have a heroic mode setting. Heroic mode dungeons are tuned for higher level players and have improved loot."],
	L["Spend your honor points for powerful rewards at the Champion's Hall (Alliance) or Hall of Legends (Horde)."],
	L["The honor points you earn each day become available immediately. Check the PvP interface to see how many points you have to spend."],
	L["You can turn these tips off in the Interface menu."],
	L["Dungeon meeting stones can be used to summon absent party members.  It requires two players at the stone to do a summoning."],
	L["The Parental Controls section of the Account Management site offers tools to help you manage your play time."],
	L["Quest items that are in the bank cannot be used to complete quests."],
	L["A quest marked as (Failed) in the quest log can be reacquired from the quest giver."],
	L["The number next to the quest name in your log is how many other party members are on that quest."],
	L["You cannot advance quests other than (Raid) quests while you are in a raid group."],
	L["You cannot cancel your bids in the auction house so bid carefully."],
	L["To enter a chat channel, type /join [channel name] and /leave [channel name] to exit."],
	L["Mail will be kept for a maximum of 30 days before it disappears."],
	L["Once you get a key, they can be found in a special key ring bag that is to the left of your bags."],
	L["City Guards will often give you directions to other locations of note in the city."],
	L["You can repurchase items you have recently sold to a vendor from the buyback tab."],
	L["A group leader can reset their instances or change dungeon difficulty by Right Clicking on their character portrait."],
	L["You can always get a new hearthstone from any innkeeper."],
	L["You can open a small map of the current zone either with Shift-M or as an option from the world map."],
	L["Players cannot dodge, parry, or block attacks that come from behind them."],
	L["You can replace a gem that is already socketed into your item by dropping a new gem on top of it in the socketing interface."],
	L["If you Right Click on a name in the combat log a list of options will appear."],
	L["You can only have one Battle Elixir and one Guardian Elixir on you at a time."],
	L["When you are mousing over an item, you can hold down the shift key and it will also show you the item of that type you have equipped."],
	L["You can have up to 10 characters per realm, with a maximum of 50 characters total across all realms."],
	L["You can reuse text that you have recently typed. Press Enter, then use <Alt> + Up Arrow to scroll through your previous messages."],
	L["You can use the Calendar to see upcoming holidays or plan events with your guild or friends."],
	L["You can Right Click on the Clock to set an alarm or display a stopwatch."],
	L["Your mounts and non-combat companions can be accessed from the Pets tab on your character page."],
	L["Currencies, such as the ones collected from Battlegrounds or Heroic dungeons, are stored in the Currency Page."],
	L["Some vehicles can carry multiple passengers."],
	L["Characters with the Inscription profession can inscribe glyphs to improve some of your favorite spells and abilities."],
	L["If you're looking for something different to do, try to complete some of the more unusual Achievements."],
	L["You can link quests, items, spells and achievements to chat messages by Shift-Left Clicking in your log."],
	L["You can track progress on current quests or achievements."],
	L["Flying mounts can be used in Outland once you attain the appropriate skill level of Riding and in Northrend after training Cold Weather Flying."],
	L["Completing some Achievements may grant unique non-combat items as rewards."],
	L["Items with bonus spell power improve both spell damage and healing."],
	L["Dealing damage, healing or casting spells can generate Threat against a creature.  Most creatures will attack the player with the highest Threat against them."],
	L["Creatures four levels above you can hit you with a Crushing Blow for extra damage."],
	L["Statistics track some interesting numbers related to your character, such as total food eaten and highest critical hit."],
	L["You can have your hair cut, colored or styled in a Barber Shop located in many cities."],
	L["Recruiting a friend to World of Warcraft can provide rewards for both of you."],
	L["You can set a Focus Frame by Right Clicking on a unit frame.  You can unlock a Focus Frame to move it anywhere around your screen."],
	L["You can compare your Achievements to those of another player."],
	L["You can set an option to cast spells on yourself or on your Focus target by looking in Interface Options, Combat."],
	L["A sanctuary is a town in which Player vs. Player combat is prohibited, such as Shattrath and Dalaran."],
	L["Improving your reputation with a faction can grant access to new quests or items."],
	L["The Calendar can tell you when raids reset."],
	L["Creatures cannot make critical hits with spells, but players can."],
	L["Creatures can dodge attacks from behind, but players cannot.  Neither creatures nor players can parry attacks from behind."],
	L["You can activate the Equipment Manager feature under Interface Controls to let you quickly swap to sets of gear that you find yourself using often."],
	L["Once you reach level 40, your class trainer can instruct you in Dual Talent Specialization. This feature allows you to swap out your talents, glyphs and action bars between two commonly used configurations."],
	L["You can enable Arena Enemy Frames to display the unit frames of the enemy team when in Arena matches."],
	L["Under Interface Display is an option to Preview Talent Changes. If you select this option, you can try out various ways to spend talent points before saving the changes."],
	L["If you press <Alt> while your cursor is over an item slot on your character, you can produce a list of items that can be equipped in that slot."],
	L["If an enemy cast bar has a shield icon around it, that means you cannot interrupt the spell with your abilities."],
	L["Your guild can schedule Guild Events using the in-game calendar. You choose to sign up for these events rather than waiting for an invitation."],
	L["When the autocomplete feature suggests character names, you can use Tab or <Shift> Tab to select a name from the list."],
	L["Always verify that you are accessing an official Blizzard website whenever submitting account information."],
	L["Emails from Blizzard will always end in either blizzard.com or battle.net."],
	L["You can download free programs to regularly scan your machine for malicious software including keyloggers."],
	L["For additional features and functionality, merge your World of Warcraft account into a Blizzard Battle.net account."],
	L["Using a Blizzard Authenticator or Battle.net Mobile Authenticator will help protect your World of Warcraft account from theft."],
	L["To avoid account theft, do not login to World of Warcraft on a computer that is shared with the general public. These machines can be infected with malicious software."],
	L["Be wary of unofficial sites advertising paid World of Warcraft services. These may contain malicious software that can lead to account theft."],
	L["To avoid account theft, do not use browser add-ons or features that allow scripts to be run in the background."],
	L["Quest locations and questgivers can be seen on your map."],
	L["You can earn rewards for running random dungeons using the Dungeon Finder tool. You can go with a group of friends or use Dungeon Finder to find a dungeon group."]
}

function E:SetNextTutorial()
	self.db.currentTutorial = self.db.currentTutorial or 0
	self.db.currentTutorial = self.db.currentTutorial + 1
	
	if self.db.currentTutorial > #E.TutorialList then
		self.db.currentTutorial = 1
	end
	
	ElvUITutorialWindow.desc:SetText(E.TutorialList[self.db.currentTutorial])
end

function E:SetPrevTutorial()
	self.db.currentTutorial = self.db.currentTutorial or 0
	self.db.currentTutorial = self.db.currentTutorial - 1
	
	if self.db.currentTutorial <= 0 then
		self.db.currentTutorial = #E.TutorialList
	end
	
	ElvUITutorialWindow.desc:SetText(E.TutorialList[self.db.currentTutorial])
end

function E:SpawnTutorialFrame()
	local f = CreateFrame("Frame", "ElvUITutorialWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(110)
	f:SetTemplate("Transparent")
	f:Hide()

	local S = E:GetModule("Skins")

	local header = CreateFrame("Button", nil, f)
	header:SetTemplate("Default", true)
	header:SetWidth(120); header:SetHeight(25)
	header:SetPoint("CENTER", f, "TOP")
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText("ElvUI")
		
	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 30)
	f.desc = desc
	
	f.disableButton = CreateFrame("CheckButton", f:GetName().."DisableButton", f, "OptionsCheckButtonTemplate")
	_G[f.disableButton:GetName() .. "Text"]:SetText(DISABLE)
	f.disableButton:SetPoint("BOTTOMLEFT")
	S:HandleCheckBox(f.disableButton)
	f.disableButton:SetScript("OnShow", function(self) self:SetChecked(E.db.hideTutorial) end)

	f.disableButton:SetScript("OnClick", function(self) E.db.hideTutorial = self:GetChecked() end)

	f.hideButton = CreateFrame("Button", f:GetName().."HideButton", f, "OptionsButtonTemplate")
	f.hideButton:SetPoint("BOTTOMRIGHT", -5, 5)	
	S:HandleButton(f.hideButton)	
	_G[f.hideButton:GetName() .. "Text"]:SetText(HIDE)
	f.hideButton:SetScript("OnClick", function(self) E:StaticPopupSpecial_Hide(self:GetParent()) end)
	
	f.nextButton = CreateFrame("Button", f:GetName().."NextButton", f, "OptionsButtonTemplate")
	f.nextButton:SetPoint("RIGHT", f.hideButton, "LEFT", -4, 0)	
	f.nextButton:Width(20)
	S:HandleButton(f.nextButton)	
	_G[f.nextButton:GetName() .. "Text"]:SetText(">")
	f.nextButton:SetScript("OnClick", function(self) E:SetNextTutorial() end)

	f.prevButton = CreateFrame("Button", f:GetName().."PrevButton", f, "OptionsButtonTemplate")
	f.prevButton:SetPoint("RIGHT", f.nextButton, "LEFT", -4, 0)	
	f.prevButton:Width(20)
	S:HandleButton(f.prevButton)	
	_G[f.prevButton:GetName() .. "Text"]:SetText("<")
	f.prevButton:SetScript("OnClick", function(self) E:SetPrevTutorial() end)

	return f
end

function E:Tutorials(forceShow)
	if (not forceShow and self.db.hideTutorial) or (not forceShow and not self.private.install_complete) then return; end
	local f = ElvUITutorialWindow
	if not f then
		f = E:SpawnTutorialFrame()
	end

	E:StaticPopupSpecial_Show(f)
	
	self:SetNextTutorial()
end
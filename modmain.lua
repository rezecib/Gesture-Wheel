Assets = {
	Asset("IMAGE", "images/gesture_bg.tex"),
	Asset("ATLAS", "images/gesture_bg.xml"),
}

KEYBOARDTOGGLEKEY = GetModConfigData("KEYBOARDTOGGLEKEY") or "G"
if type(KEYBOARDTOGGLEKEY) == "string" then
	KEYBOARDTOGGLEKEY = KEYBOARDTOGGLEKEY:lower():byte()
end
local SCALEFACTOR = GetModConfigData("SCALEFACTOR") or 1
local CENTERWHEEL = GetModConfigData("CENTERWHEEL")
--Gross way of handling the default behavior, but I don't see a better option
if CENTERWHEEL == nil then CENTERWHEEL = true end
local RESTORECURSOROPTIONS = GetModConfigData("RESTORECURSOR") or 3
if not CENTERWHEEL and RESTORECURSOROPTIONS == 3 then
	--if the wheel isn't centered, then restoring basically just puts it where it was already
	-- so turn that off to prevent jitter
	RESTORECURSOROPTIONS = 0
end
--0 means don't center or restore, even if the wheel is centered
local CENTERCURSOR  = CENTERWHEEL and (RESTORECURSOROPTIONS >= 1)
local RESTORECURSOR = RESTORECURSOROPTIONS >= 2
local ADJUSTCURSOR  = RESTORECURSOROPTIONS >= 3
local IMAGETEXT = GetModConfigData("IMAGETEXT") or 2
local SHOWIMAGE = IMAGETEXT > 1
local SHOWTEXT = IMAGETEXT%2 == 1
local RIGHTSTICK = GetModConfigData("RIGHTSTICK")
--Backward-compatibility if they had changed the option
if GetModConfigData("LEFTSTICK") == false then RIGHTSTICK = true end
-- ONLYEIGHT isn't compatible with multiple rings; it will disable Party and Old emotes
local ONLYEIGHT = GetModConfigData("ONLYEIGHT")
local EIGHTS = {}
for i=1,8 do
	EIGHTS[i] = GetModConfigData("EIGHT"..i)
end

--Constants for the emote definitions; name is used for display text, anim for puppet animation

local DEFAULT_EMOTES = {
	{name = "rude",		anim = {anim="emoteXL_waving4", randomanim=true}},
	{name = "annoyed",	anim = {anim="emoteXL_annoyed"}},
	{name = "sad",		anim = {anim="emoteXL_sad", fx="tears", fxoffset={0.25,3.25,0}, fxdelay=17*GLOBAL.FRAMES}},
	{name = "joy",		anim = {anim="research", fx=false}},
	{name = "facepalm",	anim = {anim="emoteXL_facepalm"}},
	{name = "wave",		anim = {anim={"emoteXL_waving1", "emoteXL_waving2", "emoteXL_waving3"}, randomanim=true}},
	{name = "dance",	anim = {anim ={ "emoteXL_pre_dance0", "emoteXL_loop_dance0" }, loop = true, fx = false, beaver = true }},
	{name = "pose",		anim = {anim = "emote_strikepose", zoom = true, soundoverride = "/pose"}},
	{name = "kiss",		anim = {anim="emoteXL_kiss"}},
	{name = "bonesaw",	anim = {anim="emoteXL_bonesaw"}},
	{name = "happy",	anim = {anim="emoteXL_happycheer"}},
	{name = "angry",	anim = {anim="emoteXL_angry"}},
	{name = "sit",		anim = {anim={{"emote_pre_sit2", "emote_loop_sit2"}, {"emote_pre_sit4", "emote_loop_sit4"}}, randomanim = true, loop = true, fx = false}},
	{name = "squat",	anim = {anim={{"emote_pre_sit1", "emote_loop_sit1"}, {"emote_pre_sit3", "emote_loop_sit3"}}, randomanim = true, loop = true, fx = false}},
	{name = "toast",	anim = {anim={ "emote_pre_toast", "emote_loop_toast" }, loop = true, fx = false }},
	-- TODO: make sure this list stays up to date
}
--These emotes are unlocked by certain cosmetic Steam/skin items
local EMOTE_ITEMS = {
	{name = "sleepy",	anim = {anim="emote_sleepy"},		item = "emote_sleepy"},
	{name = "yawn",		anim = {anim="emote_yawn"},			item = "emote_yawn"},
	{name = "swoon",	anim = {anim="emote_swoon"},		item = "emote_swoon"},
	{name = "chicken",	anim = {anim="emoteXL_loop_dance6"},item = "emote_dance_chicken"},
	{name = "robot",	anim = {anim="emoteXL_loop_dance8"},item = "emote_dance_robot"},
	{name = "step",		anim = {anim="emoteXL_loop_dance7"},item = "emote_dance_step"},
	{name = "fistshake",anim = {anim="emote_fistshake"},	item = "emote_fistshake"},
	{name = "flex",		anim = {anim="emote_flex"},			item = "emote_flex"},
	{name = "impatient",anim = {anim="emote_impatient"},	item = "emote_impatient"},
	{name = "cheer",	anim = {anim="emote_jumpcheer"},	item = "emote_jumpcheer"},
	{name = "laugh",	anim = {anim="emote_laugh"},		item = "emote_laugh"},
	{name = "shrug",	anim = {anim="emote_shrug"},		item = "emote_shrug"},
	{name = "slowclap",	anim = {anim="emote_slowclap"},		item = "emote_slowclap"},
	{name = "carol",	anim = {anim="emote_loop_carol"},	item = "emote_carol"},
}

--Checking for other emote mods
local PARTY_ADDED = GLOBAL.KnownModIndex:IsModEnabled("workshop-437521942")
local OLD_ADDED = GLOBAL.KnownModIndex:IsModEnabled("workshop-732180082")
for k,v in pairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
	PARTY_ADDED = PARTY_ADDED or v == "workshop-437521942"
	OLD_ADDED = OLD_ADDED or v == "workshop-732180082"
end

local PARTY_EMOTES = nil
if PARTY_ADDED and not ONLYEIGHT then
	PARTY_EMOTES = 
		{
			name = "party",
			emotes = 
			{
				{name = "dance2",	anim = {anim = "idle_onemanband1_loop"}},
				{name = "dance3",	anim = {anim = "idle_onemanband2_loop"}},
				{name = "run",		anim = {anim = {"run_pre", "run_loop", "run_loop", "run_loop", "run_pst"}}},
				{name = "thriller",	anim = {anim = "mime2"}},
				{name = "choochoo",	anim = {anim = "mime3"}},
				{name = "plsgo",	anim = {anim = "mime4"}},
				{name = "ez",		anim = {anim = "mime5"}},
				{name = "box",		anim = {anim = "mime6"}},
				{name = "bicycle",	anim = {anim = "mime8"}},
				{name = "comehere",	anim = {anim = "mime7"}},
				{name = "wasted",	anim = {anim = "sleep_loop"}},
				{name = "buffed",	anim = {anim = "powerup"}},
				{name = "pushup",	anim = {anim = "powerdown"}},
				{name = "fakebed",	anim = {anim = "bedroll_sleep_loop"}},
				{name = "shocked",	anim = {anim = "shock"}},
				{name = "dead",		anim = {anim = {"death", "wakeup"}}},
				{name = "spooked",	anim = {anim = "distress_loop"}},
			},
			radius = 375,
			color = GLOBAL.PLAYERCOLOURS.FUSCHIA,
		}
end

local OLD_EMOTES = nil
if OLD_ADDED and not ONLYEIGHT then
	OLD_EMOTES = 
		{
			name = "old",
			emotes = 
			{
				{name = "angry2",	anim = {anim = "emote_angry"}},
				{name = "annoyed2",	anim = {anim = "emote_annoyed_palmdown"}},
				{name = "gdi",		anim = {anim = "emote_annoyed_facepalm"}},
				{name = "pose2",	anim = {anim = "emote_feet"}},
				{name = "pose3",	anim = {anim = "emote_hands"}},
				{name = "pose4",	anim = {anim = "emote_hat"}},
				{name = "pose5",	anim = {anim = "emote_pants"}},
				{name = "grats",	anim = {anim = "emote_happycheer"}},
				{name = "sigh",		anim = {anim = "emote_sad"}},
				{name = "heya",		anim = {anim = "emote_waving"}},
			},
			radius = 175,
			color = GLOBAL.DARKGREY,
		}
end

local emote_sets = {}

local function BuildEmoteSets()
	emote_sets = {}
	
	if PARTY_EMOTES ~= nil then
		table.insert(emote_sets, PARTY_EMOTES)
	end

	if OLD_EMOTES ~= nil then
		table.insert(emote_sets, OLD_EMOTES)
	end
	
	--Add in all the default emotes
	local EMOTES = {}
	--Check if we have some of the emote items
	local EMOTE_ITEMS_OWNED = {}
	local TheInventory = GLOBAL.TheInventory
	for _,item in pairs(EMOTE_ITEMS) do
		if TheInventory:CheckOwnership(item.item) then
			table.insert(EMOTE_ITEMS_OWNED, item)
		end
	end

	if ONLYEIGHT then
		-- Build a lookup table for emotes that are allowable here
		EIGHTABLE_EMOTES = {}
		for _,e in pairs(DEFAULT_EMOTES) do
			EIGHTABLE_EMOTES[e.name] = e
		end
		for _,e in pairs(EMOTE_ITEMS_OWNED) do
			EIGHTABLE_EMOTES[e.name] = e
		end
		for _,v in ipairs(EIGHTS) do
			table.insert(EMOTES, EIGHTABLE_EMOTES[v])
		end
	else
		for _,v in ipairs(DEFAULT_EMOTES) do
			table.insert(EMOTES, v)
		end
		-- If we have only two emotes, put them in the normal wheel; a 2-item wheel is... not round
		-- Otherwise, we can make an inner wheel for them
		if #EMOTE_ITEMS_OWNED > 2 then
			table.insert(emote_sets, {
				name = "unlockable",
				emotes = EMOTE_ITEMS_OWNED,
				radius = 260, -- will need to be adjusted if number of emotes changes
				color = GLOBAL.PLAYERCOLOURS.PERU,
			})
		elseif #EMOTE_ITEMS_OWNED > 0 then
			for _,v in pairs(EMOTE_ITEMS_OWNED) do
				table.insert(EMOTES, v)
			end
		end
	end
	
	table.insert(
		emote_sets, 
		{
			name = "default",
			emotes = EMOTES,
			radius = ONLYEIGHT and 250 or 325,
			color = GLOBAL.BROWN,
		}
	)
end

--All code below is for handling the wheel

local GestureWheel = GLOBAL.require("widgets/gesturewheel")

--Variables to control the display of the wheel
local cursorx = 0
local cursory = 0
local centerx = 0
local centery = 0
local controls = nil
local gesturewheel = nil
local keydown = false
local NORMSCALE = nil
local STARTSCALE = nil

local function IsDefaultScreen()
	local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
	return ((screen and type(screen.name) == "string") and screen.name or ""):find("HUD") ~= nil
		and not(GLOBAL.ThePlayer.HUD:IsControllerCraftingOpen() or GLOBAL.ThePlayer.HUD:IsControllerInventoryOpen())
end

local function ResetTransform()
	local screenwidth, screenheight = GLOBAL.TheSim:GetScreenSize()
	centerx = math.floor(screenwidth/2 + 0.5)
	centery = math.floor(screenheight/2 + 0.5)
	local screenscalefactor = math.min(screenwidth/1920, screenheight/1080) --normalize by my testing setup, 1080p
	gesturewheel.screenscalefactor = SCALEFACTOR*screenscalefactor
	NORMSCALE = SCALEFACTOR*screenscalefactor
	STARTSCALE = 0
	gesturewheel:SetPosition(centerx, centery, 0)
	gesturewheel.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)
end

local function ShowGestureWheel(controller_mode)
	if keydown then return end
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	if not IsDefaultScreen() then return end
	
	keydown = true
	SetModHUDFocus("GestureWheel", true)
	
	ResetTransform()
	
    if SHOWIMAGE then
        for _,gesturebadge in pairs(gesturewheel.gestures) do
            gesturebadge:RefreshSkins()
        end
    end
	
	if RESTORECURSOR then
		cursorx, cursory = GLOBAL.TheInputProxy:GetOSCursorPos()
	end
	
	if CENTERCURSOR then
		GLOBAL.TheInputProxy:SetOSCursorPos(centerx, centery)
	end
	if CENTERWHEEL then
		gesturewheel:SetPosition(centerx, centery, 0)
	else
		gesturewheel:SetPosition(GLOBAL.TheInput:GetScreenPosition():Get())
	end
	gesturewheel:SetControllerMode(controller_mode)
	gesturewheel:Show()
	gesturewheel:ScaleTo(STARTSCALE, NORMSCALE, .25)
end

local function HideGestureWheel(delay_focus_loss)
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	keydown = false
	if delay_focus_loss and gesturewheel.activegesture then
		--delay a little on controllers to prevent canceling the emote by moving
		GLOBAL.ThePlayer:DoTaskInTime(0.5, function() SetModHUDFocus("GestureWheel", false) end)
	else
		SetModHUDFocus("GestureWheel", false)
	end
	
	gesturewheel:Hide()
	gesturewheel.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)
	
	if not IsDefaultScreen() then return end
	
	if RESTORECURSOR then
		if ADJUSTCURSOR then
			local x,y = GLOBAL.TheInputProxy:GetOSCursorPos()
			local gx, gy = gesturewheel:GetPosition():Get()
			local dx, dy = x-gx, y-gy
			cursorx = cursorx + dx
			cursory = cursory + dy
		end
		GLOBAL.TheInputProxy:SetOSCursorPos(cursorx, cursory)
	end
	
	if gesturewheel.activegesture then
		GLOBAL.TheNet:SendSlashCmdToServer(gesturewheel.activegesture, true)
	end
end

local handlers_applied = false
local function AddGestureWheel(self)
	BuildEmoteSets() --delay this so that the account item checks are more likely to work
	controls = self -- this just makes controls available in the rest of the modmain's functions
	if gesturewheel then
		gesturewheel:Kill()
	end
	gesturewheel = controls:AddChild(GestureWheel(emote_sets, SHOWIMAGE, SHOWTEXT, RIGHTSTICK))
	controls.gesturewheel = gesturewheel
	ResetTransform()
	gesturewheel:Hide()
	
	if not handlers_applied then
		-- Keyboard controls
		GLOBAL.TheInput:AddKeyDownHandler(KEYBOARDTOGGLEKEY, ShowGestureWheel)
		GLOBAL.TheInput:AddKeyUpHandler(KEYBOARDTOGGLEKEY, HideGestureWheel)
		
		-- Controller controls
		-- This is pressing the left stick in
		-- CONTROL_MENU_MISC_3 is the same thing as CONTROL_OPEN_DEBUG_MENU
		-- CONTROL_MENU_MISC_4 is the right stick click
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_3, function(down)
			if down then
				ShowGestureWheel(true)
			else
				HideGestureWheel(true)
			end
		end)
		
		-- this is just a lock system to make it only register one shift at a time
		local rotate_left_free = true
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_ROTATE_LEFT, function(down)
			if down then
				if keydown and rotate_left_free then
					gesturewheel:SwitchWheel(-1)
					rotate_left_free = false
				end
			else
				rotate_left_free = true
			end
		end)
		local rotate_right_free = true
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_ROTATE_RIGHT, function(down)
			if down then
				if keydown and rotate_right_free then
					gesturewheel:SwitchWheel(1)
					rotate_right_free = false
				end
			else
				rotate_right_free = true
			end
		end)
		
		handlers_applied = true
	end
end
AddClassPostConstruct( "widgets/controls", AddGestureWheel )

--Patch the class definition directly instead of each new instance
local Controls = GLOBAL.require("widgets/controls")
local OldOnUpdate = Controls.OnUpdate
local function OnUpdate(self, ...)
	OldOnUpdate(self, ...)
	if keydown then
		self.gesturewheel:OnUpdate()
	end
end
Controls.OnUpdate = OnUpdate

--In order to update the emote set when a skin is received, hook into the giftitempopup
AddClassPostConstruct("screens/giftitempopup", function(self)
	local function ScheduleRebuild()
		--give it a little time to update the skin inventory
		controls.owner:DoTaskInTime(5, function() AddGestureWheel(controls) end)
	end
	local OldOnClose = self.OnClose
	function self:OnClose(...)
		OldOnClose(self, ...)
		ScheduleRebuild()
	end
	local OldApplySkin = self.ApplySkin
	function self:ApplySkin(...)
		OldApplySkin(self, ...)
		ScheduleRebuild()
	end
end)
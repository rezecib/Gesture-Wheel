name = "Gesture Wheel"
description = "Adds a wheel selection interface for emotes, making it easier to emote."
author = "rezecib"
version = "1.6.1"

forumthread = "/files/file/980-dst-gesture-wheel/"

api_version = 10

priority = -1 -- to make it load after Party Dance

-- Compatible with the base game & ROG
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true

icon_atlas = "gesturewheelicon.xml"
icon = "gesturewheelicon.tex"

--These let clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = false

--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = true

--This lets people search for servers with this mod by these tags
server_filter_tags = {}

local KEY_A = 65
local keyslist = {}
local string = "" -- can't believe I have to do this... -____-
for i = 1, 26 do
	local ch = string.char(KEY_A + i - 1)
	keyslist[i] = {description = ch, data = ch}
end
local scalefactors = {}
for i = 1, 20 do
	scalefactors[i] = {description = i/10, data = i/10}
end

--TODO: Make sure this stays in sync with the modmain and emote file
local eight_options =
{
	{description = "/wave",		data = "wave"},
	{description = "/bye",		data = "bye"},
	{description = "/happy",	data = "happy"},
	{description = "/angry",	data = "angry"},
	{description = "/sad",		data = "sad"},
	{description = "/annoyed",	data = "annoyed"},
	{description = "/joy",		data = "joy"},
	{description = "/dance",	data = "dance"},
	{description = "/bonesaw",	data = "bonesaw"},
	{description = "/facepalm",	data = "facepalm"},
	{description = "/kiss",		data = "kiss"},
	{description = "/pose",		data = "pose"},
	{description = "/sit",		data = "sit"},
	{description = "/squat",	data = "squat"},
	{description = "/sleepy",	data = "sleepy"},
	{description = "/yawn",		data = "yawn"},
	{description = "/swoon",	data = "swoon"},
}

configuration_options =
{
	{
		name = "KEYBOARDTOGGLEKEY",
		label = "Toggle Button",
		hover = "The key you need to hold to bring up the gesture wheel.",
		options = keyslist,
		default = "G", --G
	},    
	{
		name = "SCALEFACTOR",
		label = "Wheel Size",
		hover = "How big to make the wheel.",
		options = scalefactors,
		default = 1, --G
	},    
	{
		name = "IMAGETEXT",
		label = "Show Picture/Text",
		options = {
			{description = "Both", data = 3},
			{description = "Picture Only", data = 2},
			{description = "Text Only", data = 1},
		},
		default = 3,
	},    
	{
		name = "CENTERWHEEL",
		label = "Center Wheel",
		options = {
			{description = "On", data = true},
			{description = "Off", data = false},
		},
		default = true,
	},    
	{
		name = "RESTORECURSOR",
		label = "Restore cursor position",
		options = {
			{description = "Relative", data = 3},
			{description = "Absolute", data = 2},
			{description = "Off", data = 1},
		},
		default = 3,
	},    
	{
		name = "LEFTSTICK",
		label = "Controller Stick",
		hover = "Which controller analog stick to use to select emotes on the wheel.",
		options = {
			{description = "Left", data = true},
			{description = "Right", data = false},
		},
		default = true,
	},    
	{
		name = "ONLYEIGHT",
		label = "Limit to 8",
		hover = "Limits the wheel to 8 emotes, determined by the selections in the options below.",
		options = {
			{description = "On", data = true},
			{description = "Off", data = false},
		},
		default = false,
	},    
	{
		name = "EIGHT1",
		label = "Right Emote",
		hover = "This will be shown directly to the right.",
		options = eight_options,
		default = "hi",
	},    
	{
		name = "EIGHT2",
		label = "Up-Right Emote",
		hover = "This will be shown diagonally up-right.",
		options = eight_options,
		default = "dance",
	},    
	{
		name = "EIGHT3",
		label = "Up Emote",
		hover = "This will be shown directly up.",
		options = eight_options,
		default = "happy",
	},    
	{
		name = "EIGHT4",
		label = "Up-Left Emote",
		hover = "This will be shown diagonally up-left.",
		options = eight_options,
		default = "bonesaw",
	},    
	{
		name = "EIGHT5",
		label = "Left Emote",
		hover = "This will be shown directly to the left.",
		options = eight_options,
		default = "bye",
	},    
	{
		name = "EIGHT6",
		label = "Down-Left Emote",
		hover = "This will be shown diagonally down-left.",
		options = eight_options,
		default = "facepalm",
	},    
	{
		name = "EIGHT7",
		label = "Down Emote",
		hover = "This will be shown directly down.",
		options = eight_options,
		default = "sad",
	},    
	{
		name = "EIGHT8",
		label = "Down-Right Emote",
		hover = "This will be shown diagonally down-right.",
		options = eight_options,
		default = "kiss",
	},    
}
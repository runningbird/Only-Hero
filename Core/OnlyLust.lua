local ADDON_NAME = ...

local addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local CLASS_TO_SPELL = {
	SHAMAN = { 2825, 32182 },   -- Bloodlust / Heroism
	MAGE = { 80353 },           -- Time Warp
	HUNTER = { 264667 },        -- Primal Rage
	EVOKER = { 390386 },        -- Fury of the Aspects
}

local CLASS_COLOR = {
	SHAMAN = "|cff0070de",      -- blue
	MAGE = "|cff68ccef",        -- light blue
	HUNTER = "|cffaad372",      -- green
	EVOKER = "|cff33937f",      -- teal
}

local defaults = {
	profile = {
		enabled = true,
		showPopup = true,
		warnIfOnly = true,
		warnIfNone = false,
		countHunters = true,
		announceInRaid = false,
		minLevel = 10,
	},
}

local function groupUnits()
	local units = {}
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			units[#units + 1] = ("raid%d"):format(i)
		end
	elseif IsInGroup() then
		for i = 1, GetNumSubgroupMembers() do
			units[#units + 1] = ("party%d"):format(i)
		end
	end
	return units
end

local function isLustClass(class)
	if not class then
		return false
	end
	if class == "HUNTER" then
		return addon.db.profile.countHunters
	end
	return CLASS_TO_SPELL[class] ~= nil
end

local function unitCanLust(unit)
	local level = UnitLevel(unit)
	if level and level < addon.db.profile.minLevel then
		return false
	end
	return isLustClass(select(2, UnitClass(unit)))
end

-- Returns selfCanLust, count, capablenames
local function assessGroup()
	local selfCanLust = isLustClass(select(2, UnitClass("player")))
	local selfName = UnitName("player")
	local count = 0
	local capable = {}
	for _, unit in ipairs(groupUnits()) do
		if unitCanLust(unit) then
			count = count + 1
			local name = UnitName(unit)
			if name and name ~= selfName then
				local _, class = UnitClass(unit)
				local color = CLASS_COLOR[class] or "|cffffffff"
				capable[#capable + 1] = ("%s%s|r"):format(color, name)
			end
		end
	end
	return selfCanLust, count, capable, selfName
end

local popup = nil

local function closePopup()
	if popup then
		popup:Release()
		popup = nil
	end
end

local function showPopup(bodyLines)
	if not addon.db.profile.showPopup or popup then
		return
	end
	if addon.db.profile.announceInRaid and IsInRaid() then
		for _, line in ipairs(bodyLines) do
			SendChatMessage(line, "RAID")
		end
		return
	end

	popup = AceGUI:Create("Window")
	popup:SetTitle("Only-Lust")
	popup:SetStatusText("Bloodlust availability")
	popup:SetLayout("Flow")
	popup:SetWidth(380)
	popup:SetHeight(40 + (#bodyLines * 20))

	for _, line in ipairs(bodyLines) do
		local label = AceGUI:Create("Label")
		label:SetFullWidth(true)
		label:SetText(line)
		popup:AddChild(label)
	end

	local button = AceGUI:Create("Button")
	button:SetText("Close")
	button:SetFullWidth(true)
	button:SetCallback("OnClick", function()
		closePopup()
	end)
	popup:AddChild(button)

	popup:DoLayout()
	popup:Show()
end

local function formatClass(name, class)
	local color = CLASS_COLOR[class] or "|cffffffff"
	return ("%s%s|r"):format(color, name)
end

local function evaluate()
	if not addon.db.profile.enabled then
		return
	end
	if not (IsInRaid() or IsInGroup()) then
		return
	end

	local selfLust, count, capable, selfName = assessGroup()
	local bodyLines = {}

	if count == 0 then
		if addon.db.profile.warnIfNone then
			bodyLines[#bodyLines + 1] = "Nobody in this group can cast a bloodlust effect (Lust/Hero/Time Warp)."
		end
	elseif count == 1 and selfLust and addon.db.profile.warnIfOnly then
		bodyLines[#bodyLines + 1] = "You, " .. formatClass(selfName, select(2, UnitClass("player")))
			.. ", are the ONLY member of this group who can cast a bloodlust effect!"
		bodyLines[#bodyLines + 1] = "Make sure to use Lust/Hero/Time Warp for the group."
	else
		bodyLines[#bodyLines + 1] = "Bloodlust availability in this group:"
		if selfLust then
			bodyLines[#bodyLines + 1] = "  * " .. formatClass(selfName, select(2, UnitClass("player"))) .. " (you)"
		end
		for _, name in ipairs(capable) do
			bodyLines[#bodyLines + 1] = "  * " .. name
		end
	end

	if #bodyLines == 0 then
		return
	end

	if addon.db.profile.showPopup then
		showPopup(bodyLines)
	else
		for _, line in ipairs(bodyLines) do
			addon:Print(line)
		end
	end
end

local options = {
	type = "group",
	name = "Only-Lust",
	args = {
		header = {
			type = "header",
			name = "Bloodlust Warning",
			order = 1,
		},
		enabled = {
			type = "toggle",
			name = "Enabled",
			desc = "Enable the Only-Lust warning system.",
			order = 2,
		},
		showPopup = {
			type = "toggle",
			name = "Popup window",
			desc = "Show a popup window when the group forms. If off, print to chat instead.",
			order = 3,
		},
		warnIfOnly = {
			type = "toggle",
			name = "Warn if you are the only one",
			desc = "Show a warning when you are the only group member able to cast a bloodlust effect.",
			order = 4,
		},
		warnIfNone = {
			type = "toggle",
			name = "Warn if nobody can",
			desc = "Show a warning when no one in the group can cast a bloodlust effect.",
			order = 5,
		},
		countHunters = {
			type = "toggle",
			name = "Count Hunters",
			desc = "Count hunters as bloodlust-capable (they need a Ferocity pet).",
			order = 6,
		},
		announceInRaid = {
			type = "toggle",
			name = "Announce in raid chat",
			desc = "Post the warning to raid chat instead of a popup.",
			order = 7,
		},
		minLevel = {
			type = "range",
			name = "Min level",
			desc = "Minimum group member level to be considered.",
			min = 1,
			max = 70,
			step = 1,
			order = 8,
		},
		check = {
			type = "execute",
			name = "Check now",
			desc = "Manually run the bloodlust check.",
			order = 9,
			func = function()
				evaluate()
			end,
		},
	},
}

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("OnlyLustDB", defaults, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(ADDON_NAME, options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, "Only-Lust")

	self:RegisterChatCommand("onlylust", function(input)
		if input and input:trim():lower() == "options" then
			LibStub("AceConfigDialog-3.0"):Open(ADDON_NAME)
		else
			evaluate()
		end
	end)
	self:RegisterChatCommand("lust", function()
		evaluate()
	end)
end

function addon:OnEnable()
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupUpdate")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnGroupUpdate")
	self:RegisterEvent("LFG_PROPOSAL_SHOW", "OnLfgProposal")
	self:RegisterEvent("LFG_PROPOSAL_FAILED", "OnLfgFailed")
	self:RegisterEvent("LFG_LIST_JOINED_GROUP", "OnLfgListJoined")
end

function addon:OnLfgProposal()
	self.lfgGroupFilled = true
end

function addon:OnLfgFailed()
	self.lfgGroupFilled = false
end

function addon:OnLfgListJoined()
	self.lfgGroupFilled = true
end

function addon:OnGroupUpdate()
	self:ScheduleTimer("DelayedEval", 2)
end

function addon:DelayedEval()
	if InCombatLockdown() then
		return
	end

	if self.lfgGroupFilled and self.db.profile.showPopup then
		-- Only fire once the group actually has members (LFG has fully filled).
		if IsInGroup() and GetNumGroupMembers() >= 1 then
			self.lfgGroupFilled = false
			evaluate()
		end
		return
	end

	self.lfgGroupFilled = false

	if not self.db.profile.showPopup then
		evaluate()
	end
end

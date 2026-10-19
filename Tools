local soundserv = game:GetService("SoundService")

local GuiHandler = require(script.Parent:WaitForChild("GuiHandler"))
local ToolsEquip = require(script.Parent:WaitForChild('ToolsEquip'))

local player = game.Players.LocalPlayer

local ToolSelected = 0
local ToolSelectTimeOut = tick()


local guiCooldown
local MAXTOOLS
local EvenNumber
local PreviousToolGui = 1

local Clicked = false
local GuiEnabled = false
local Selected = false
local Scrolling = false

local Show = true  --// show INVENTORY GUI
local Hide = true  --// hide INVENTORY GUI

--// SETTINGS \\-------

local TOOLGIVERCOOLDOWN = 1

local Tools = {
	'Crowbar_weapon',  --// 1
	'GravityGun_weapon',  ---// 2
	'AR2_weapon',  ----// 3
	'Revolver_weapon',  -----// 4
	'Shotgun_weapon',  ------// 5
	'RocketLauncher_weapon',  -------// 6
	'Toolgun_weapon',  --------// 7
	'Camera_weapon',  ---------// 8
}



local module = {}



local function ShowandHideToolGui(Tool,Show,Hide)
	if Show then
		Tool.Visible = true

	elseif Hide then
		Tool.Visible = false
	end
end

local function DisableGui(Tools)
	print('DISABLE GUI')
	local PlayerGui = player.PlayerGui
	local ToolSelectionGui = PlayerGui.ToolSelectionGUI

	for _,Tools in ToolSelectionGui:GetChildren() do
		if Tools.Visible == true then
			Tools.Visible = false
		end
	end
	ToolSelected = 0
	PreviousToolGui = 1
	GuiEnabled = false
end

local function HideGuiWhileScrolling()
	local PlayerGui = player.PlayerGui
	local ToolSelectionGui = PlayerGui.ToolSelectionGUI
	
	for _,Tools in ToolSelectionGui:GetChildren() do
		if Tools.Visible == true then
			Tools.Visible = false
		end
	end
end

local function HideGuiDirection(Tool,ToolNumber,Tools,PreviousToolGui,Back)
	if Back then
		if PreviousToolGui then
			Tools.ImageTransparency = .5
			if not module.IsOddNumber(PreviousToolGui) then
				ShowandHideToolGui(Tools,Show,false)
			elseif module.IsOddNumber(PreviousToolGui) then
				ShowandHideToolGui(Tools,false,Hide)
			end
		else
			Tools.ImageTransparency = 0
			if not module.IsOddNumber(ToolNumber) then
				HideGuiWhileScrolling()
				ShowandHideToolGui(Tools,Show,false)
			else
				ShowandHideToolGui(Tools,Show,false)
			end
		end
	else
		if PreviousToolGui then
			Tools.ImageTransparency = .5
			if module.IsOddNumber(PreviousToolGui) then
				ShowandHideToolGui(Tools,Show,false)
			elseif not module.IsOddNumber(PreviousToolGui) then
				ShowandHideToolGui(Tools,false,Hide)
			end
		else
			Tools.ImageTransparency = 0
			if module.IsOddNumber(ToolNumber) then
				HideGuiWhileScrolling()
				ShowandHideToolGui(Tools,Show,false)
			else
				ShowandHideToolGui(Tools,Show,false)
			end
		end
	end
end

function module.ToolSelector(Tool,ToolNumber,PreviousToolGui,Backward)
	local PlayerGui = player.PlayerGui
	local ToolSelectionGui = PlayerGui.ToolSelectionGUI

	for _,Tools in ToolSelectionGui:GetChildren() do
		if Tool == Tools.Name then
			if Backward then
				HideGuiDirection(Tool,ToolNumber,Tools,PreviousToolGui,Backward)
			else
				HideGuiDirection(Tool,ToolNumber,Tools,PreviousToolGui,false)
			end
		end
	end
end

function module.DisableGuiTimer()
	ToolSelectTimeOut = tick()

	task.spawn(function()
		task.wait(TOOLGIVERCOOLDOWN)
		module.ToolSelectionTimeOut(ToolSelectTimeOut)
	end)
end

local function GivePlayerTool(Tool,ToolNumber) ---// GIVE PLAYER TOOL
	local toolname = Tool:gsub('_weapon','')
	
	soundserv.Toolselecting_sfx.ToolSelected_sfx:Play()
	if ToolsEquip[toolname] then
		ToolsEquip[toolname](Tool,ToolNumber)
	end
	DisableGui(Tool)
end

local function FindToolNumber(ToolSelected,Scrolling,Selected,PreviousToolGui,Backward) ---// CHECK WHAT TOOL BELONGS TO TOOL SELECTED NUM
	for ToolNumber,Tool in ipairs(Tools) do
		if ToolNumber == ToolSelected then
			if Selected then
				GivePlayerTool(Tool,ToolSelected)
			elseif Scrolling then
				if Backward then
					module.ToolSelector(Tool,ToolNumber,false,Backward)
				else
					module.ToolSelector(Tool,ToolNumber,false,false)
				end
			end
		end
		if ToolNumber == PreviousToolGui then
			if Selected then
				--GivePlayerTool(Tool)
			elseif Scrolling then
				if Backward then
					module.ToolSelector(Tool,ToolNumber,PreviousToolGui,Backward)
				else
					module.ToolSelector(Tool,ToolNumber,PreviousToolGui,false)
				end
			end
		end
	end
end

function module.ToolSelection(Forward, Backward, Reset)  --// TOOL SELECTION(mover)
	Scrolling = true
	GuiEnabled = true
	module.DisableGuiTimer()
	
	if Reset then
		ToolSelected = 0
		print(ToolSelected)
	end
	if Forward then
		if ToolSelected == table.maxn(Tools) then return end
		soundserv.Toolselecting_sfx.Scrolling_sfx:Play()
		PreviousToolGui = ToolSelected
		ToolSelected += 1
		FindToolNumber(ToolSelected,Scrolling,false,PreviousToolGui,false)
		print(ToolSelected)
		
	elseif Backward then
		if ToolSelected <= 1 then return end
		soundserv.Toolselecting_sfx.Scrolling_sfx:Play()
		PreviousToolGui = ToolSelected
		ToolSelected -= 1
		
		FindToolNumber(ToolSelected,Scrolling,false,PreviousToolGui,Backward)
		print('PreviousToolGui: '..tostring(PreviousToolGui))
		print(ToolSelected)
	end
end

function module.ToolSelectionGui(ToolSelected)
	if ToolSelected and not Clicked then
		DisableGui()
	elseif ToolSelected and Clicked then
		DisableGui()
	end
end

function module.ToolSelectionTimeOut(ToolSelectTimeOut)  --------// DISABLE GUI AFTER NOT SELECTING TOOL
	if tick() - ToolSelectTimeOut > 1 and ToolSelected ~= 0 then
		module.ToolSelectionGui(ToolSelected)
	end
end

function module.PlayerClicked()
	if ToolSelected and GuiEnabled then
		Selected = true
		Clicked = true
		
		FindToolNumber(ToolSelected,false,Selected)  ---// PASS IN THE TOOL SELECTED
		DisableGui()
		task.spawn(function()
			task.wait(1.5)
			Clicked = false
		end)
	end
end

function module.IsOddNumber(Number)
	if Number % 2 == 1 then
		return true  -------// ODD NUMBER ex:1
	else
		return false  -------// EVEN NUMBER ex:2
	end
end


return module

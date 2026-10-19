local uis = game:GetService("UserInputService")
local runserv = game:GetService("RunService")
local soundserv = game:GetService("SoundService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local Modules = replicatedstorage:WaitForChild('Modules')

local ToolsModule = require(Modules:WaitForChild("Tools"))
local ToolsEquipModule = require(Modules:WaitForChild('ToolsEquip'))
local QMenu = require(Modules:WaitForChild("QMenu"))

local player = game.Players.LocalPlayer

local ClientChecks = replicatedstorage.ClientChecks
local OnPlayerDeathCheck = ClientChecks.OnPlayerDeath
local FetchData = ClientChecks.FetchData
local PassData = ClientChecks.PassData

local mouse = player:GetMouse()

local inputconnections = {}

local ToolScrollForward = false
local ToolScrollBackward = false

local OpenMenu = false
local CloseMenu = false

local selectedMap = nil
local MapSpawnLocation = nil

PassData.SelectedMap.Event:Connect(function(Map,SpawnPoint)
	MapSpawnLocation = SpawnPoint
end)

player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	local Deathgui = player.PlayerGui:WaitForChild("Death")
	if MapSpawnLocation ~= nil then
		char:MoveTo(MapSpawnLocation.Position)
	end
	if Deathgui.DeathScreen.Visible == true then
		Deathgui.DeathScreen.Visible = false
	end
	for _,connection in ipairs(inputconnections) do
		connection:Disconnect()
	end
	local scrollForward = mouse.WheelForward:Connect(function()
		if hum.Health <= 0 then 
			warn('Player is Dead')
		else
			ToolScrollForward = true
			ToolsEquipModule.DisableTool()
			ToolsModule.ToolSelection(ToolScrollForward,ToolScrollBackward)
			ToolScrollForward = false
		end
	end)
	table.insert(inputconnections,scrollForward)
	local scrollBackward = mouse.WheelBackward:Connect(function()
		if hum.Health <= 0 then 
			warn('Player is Dead')
		else
			ToolScrollBackward = true
			ToolsEquipModule.DisableTool()
			ToolsModule.ToolSelection(ToolScrollForward,ToolScrollBackward)
			ToolScrollBackward = false
		end
	end)
	table.insert(inputconnections,scrollBackward)
	local presskey = uis.InputBegan:Connect(function(input,gpe)
		if hum.Health <= 0 then 
			warn('Player is Dead')
		else
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				ToolsModule.PlayerClicked()
			elseif input.KeyCode == Enum.KeyCode.Q then  ---// Open Menu
				OpenMenu = true
				ToolsEquipModule.DisableTool()
				QMenu._OpenMenu(OpenMenu,CloseMenu)
			elseif input.KeyCode == Enum.KeyCode.T then
				replicatedstorage.ServerUpdates.DeleteAsset:FireServer()
			end
		end
	end)
	table.insert(inputconnections,presskey)
	local releasekey = uis.InputEnded:Connect(function(input,gpe)
		if hum.Health <= 0 then 
			warn('Player is Dead')
		else
			if input.KeyCode == Enum.KeyCode.Q then
				OpenMenu = false
				CloseMenu = true
				ToolsEquipModule.EnableTool()
				QMenu._OpenMenu(OpenMenu,CloseMenu)
				CloseMenu = false
			end
		end
	end)
	table.insert(inputconnections,releasekey)
	local died = hum.Died:Connect(function()
		print('DIED')
		OnPlayerDeathCheck.HideGui:Fire()
		ToolsModule.ToolSelection(false,false,true)
	end)
	table.insert(inputconnections,died)
end)

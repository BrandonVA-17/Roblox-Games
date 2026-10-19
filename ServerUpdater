local replicatedstorage = game:GetService('ReplicatedStorage')
local Modules = replicatedstorage:WaitForChild('Modules')

local ServerUpdate = replicatedstorage:WaitForChild('ServerUpdates')

----// MODULES \\----------------------------------------------------

local QMenu = require(Modules:WaitForChild('QMenu'))
local ToolsEquip = require(Modules:WaitForChild('ToolsEquip'))



---// SERVER UPDATES \\----------------------------------------------


ServerUpdate.SpawnAsset.OnServerEvent:Connect(function(player,Assetid,MenuType)
	QMenu.SpawnAsset(player,Assetid,MenuType)
end)

ServerUpdate.DeleteAsset.OnServerEvent:Connect(function(player)
	QMenu.CheckDespawnObject(player)
end)

ServerUpdate.CreateViewModel.OnServerEvent:Connect(function(player,Tool)
	ToolsEquip.CreateViewModel_server(Tool)
end)

--WEAPONS

ServerUpdate.GravityGunBeam.OnServerEvent:Connect(function(player,Tool,mousehit)
	ToolsEquip.CreateGravityGunRaycast(Tool,mousehit)
end)

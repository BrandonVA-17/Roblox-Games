local replicatedstorage = game:GetService('ReplicatedStorage')
local soundserv = game:GetService('SoundService')
local uis = game:GetService('UserInputService')

local player = game.Players.LocalPlayer

local ServerUpdate = replicatedstorage:WaitForChild('ServerUpdates')

local ButtonEvent = {}
local ClickedAsset = {}
local LastFrame = nil

local RightClick = true


local Prop_MenuTable = {
	'prop_Barrel',
	'prop_Fence',
	'prop_Crate',
	'prop_Tire',
	'prop_Chair',
	'prop_Table',
	'prop_Computer',
	'prop_Toilet',
	'prop_Stove',
	'prop_WashingMachine',
}

local NPCs_MenuTable = {
	'Nextbot_OIIA',
	'Nextbot_Siren',
	'Nextbot_Cheeseburger',
	'Nextbot_Rock'
}

local Vehicles_MenuTable = {
	'A',
	'B',
	'C',
}

local MISC_MenuTable = {
	'A',
	'B',
	'C',
}

local ActivePlayers = {}

local ClipBoard = {}

local PhysicalPropertiesTable = {
	DENSITY = .5,
	ELASTICITY = 1,
	ELASTICITYWEIGHT = .5,
	FRICTION = 1,
	FRICTIONWEIGHT = 1,
}


local module = {}


module.SpawnedAssets = {}

local function DisconnectTable(Table)
	for _,Connection in ipairs(Table) do
		Connection:Disconnect()
	end
	Table = {}
end

local function EnableMouseMovement()
	local screengui = Instance.new('ScreenGui')
	screengui.Name = 'MouseMovementEnabled'
	screengui.Parent = player.PlayerGui
	
	local button = Instance.new('TextButton')
	button.BackgroundTransparency = 1
	button.Size = UDim2.new(0,0,0,0)
	button.Modal = true
	
	button.Parent = screengui
end

local function DisableMouseMovement()
	local locked = player.PlayerGui:FindFirstChild('MouseMovementEnabled')
	if locked then
		locked:Destroy()
	end
end

local function OnButtonClicked(Button,MenuType)
	local Frame = Button:FindFirstChild(Button.Name..'Frame')
	if Frame then
		if LastFrame then
			LastFrame.Visible = false
		end
		Frame.Visible = true
		LastFrame = Frame
		module.CheckForInstanceClick(Frame,MenuType)
	end
end

function module.GetClipBoardAsset()
	return ClipBoard[1]
end

local function OnCopyAssetClick(Asset)
	table.remove(ClipBoard,1)
	table.insert(ClipBoard,Asset)
	local Clip = module.GetClipBoardAsset()
	print('COPIED '..tostring(Clip))
end

local function CreateCopyAssetGui(Asset)
	local mouse = player:GetMouse()
	
	local CopyButton = Instance.new('TextButton')
	CopyButton.TextScaled = true
	CopyButton.Visible = true
	CopyButton.Text = 'Copy Asset to ToolGun'
	CopyButton.BackgroundTransparency = 0
	CopyButton.BackgroundColor = BrickColor.Green()
	CopyButton.Position = UDim2.new(0,mouse.X,0,mouse.Y)
	CopyButton.Size = UDim2.new(0,200,0,50)
	CopyButton.Parent = player.PlayerGui.CopyAssetGui
	
	CopyButton.Activated:Connect(function()
		OnCopyAssetClick(Asset)
	end)
end

local function DeleteCopyAssetGui()
	for _,Button in player.PlayerGui.CopyAssetGui:GetChildren() do
		Button:Destroy()
	end
end

local function CheckAssetid(AssetName,MenuType_Table,MenuType,RightClick,Asset)
	print('CHECKING ASSET ID')
	for Assetid,Assets in ipairs(MenuType_Table) do
		if AssetName == Assets then
			if RightClick then
				CreateCopyAssetGui(Asset)
			else
				ServerUpdate.SpawnAsset:FireServer(Assetid,MenuType)
			end
		end
	end
end

local function CheckAssetMenuLocation(Asset,MenuType,RightClick)
	local AssetName = Asset.Name
	if MenuType == 'Props' then
		CheckAssetid(AssetName,Prop_MenuTable,MenuType,RightClick,Asset)
		
	elseif MenuType == 'NPCs' then
		CheckAssetid(AssetName,NPCs_MenuTable,MenuType,RightClick,Asset)
		
	elseif MenuType == 'Vehicles' then
		CheckAssetid(AssetName,Vehicles_MenuTable,MenuType,RightClick,Asset)
		
	elseif MenuType == 'MISC' then
		CheckAssetid(AssetName,MISC_MenuTable,MenuType,RightClick,Asset)
	end
end

function module.CheckForInstanceClick(Frame,MenuType)
	DisconnectTable(ClickedAsset)
	
	for _,Asset in ipairs(Frame:GetChildren()) do
		if not Asset:IsA('TextLabel') then
			Asset.MouseButton2Click:Connect(function()
				DeleteCopyAssetGui()
				CheckAssetMenuLocation(Asset,MenuType,RightClick)
			end)
			local conn = Asset.Activated:Connect(function()
				soundserv.Qmenu_sfx.PressedButton_sfx:Play()
				DeleteCopyAssetGui()
				CheckAssetMenuLocation(Asset,MenuType)
			end)
			table.insert(ClickedAsset,conn)
		end
	end
end

function module.CheckForClickedButton(QMenu_Frame)
	for _,Button in ipairs(QMenu_Frame:GetChildren()) do
		local conn = Button.Activated:Connect(function()
			local MenuType = Button.Name
			DeleteCopyAssetGui()
			OnButtonClicked(Button,MenuType)
		end)
		table.insert(ButtonEvent,conn)
	end
end

local function DetectPlayerClicks()
	uis.InputBegan:Connect(function(input,gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			DeleteCopyAssetGui()
		end
	end)
end

function module._OpenMenu(OpenMenu,CloseMenu)  -----// OPEN MENU FUNCTION
	local PlayerGui = player.PlayerGui
	local QMenu = PlayerGui.QMenu
	local QMenu_Frame = QMenu.Frame
	
	if OpenMenu then
		print('MENU OPENED')
		
		QMenu_Frame.Visible = true
		EnableMouseMovement()
		DetectPlayerClicks()
		module.CheckForClickedButton(QMenu_Frame)
		
	elseif CloseMenu then
		print('MENU CLOSED')
		
		QMenu_Frame.Visible = false
		DisableMouseMovement()
		DeleteCopyAssetGui()
		DisconnectTable(ButtonEvent)
	end
end

local function UnAnchor(Asset)
	for _,child in Asset:GetChildren() do
		if child:IsA('Part') or child:IsA('MeshPart') then
			child.Anchored = false
		end
	end
end

local function AddTag(Asset)
	for _,child in Asset:GetChildren() do
		if child:IsA('Part') or child:IsA('MeshPart') then
			child:AddTag('Asset')
			child.CustomPhysicalProperties = PhysicalProperties.new(PhysicalPropertiesTable)
		end
	end
end

local LastSpawnedAsset = 0

local function GetAssetFromSpawnedAssetsTable(player)
	print('Before if then check')
	if module.SpawnedAssets[player.Name] then
		print('After if then check')
		
		local Asset = module.SpawnedAssets[player.Name]
		return Asset[#Asset]
	end
	return nil
end

local numbers = {}
function module.CheckDespawnObject(player)
	
	if GetAssetFromSpawnedAssetsTable(player) then
		local SpawnedAssetsTable = module.SpawnedAssets[player.Name]
		local removingAsset = SpawnedAssetsTable[#SpawnedAssetsTable]
		local SpawnedAssetsFolder = workspace.PlayersFolders.SpawnedAssets
		local PlrSpawnAssetsFolder = SpawnedAssetsFolder:FindFirstChild(player.Name..'SpawnedAssets')
		
		if PlrSpawnAssetsFolder:FindFirstChild(removingAsset) then
			soundserv.Qmenu_sfx.DeleteAssets_sfx:play()
			PlrSpawnAssetsFolder:FindFirstChild(removingAsset):Destroy()
		end
		table.remove(SpawnedAssetsTable,tonumber(removingAsset))
	end
end

local function CheckPlayersTable(player)
	if not module.SpawnedAssets[player.Name] then
		module.SpawnedAssets[player.Name] = {}
	end
end

local function CreateAsset(Asset,player,hrp,PlayerSpawnedAssetsFolder)
	local AssetVariable = Asset:Clone()
	AssetVariable:PivotTo(hrp.CFrame * CFrame.new(0,0,-10))
	UnAnchor(AssetVariable)
	AddTag(AssetVariable)
	LastSpawnedAsset = LastSpawnedAsset + 1
	AssetVariable.Name = Asset.Name..`{LastSpawnedAsset}`
	AssetVariable.Parent = PlayerSpawnedAssetsFolder
	
	table.insert(module.SpawnedAssets[player.Name],AssetVariable.Name)
	print(module.SpawnedAssets[player.Name])
end

function module.SpawnAsset(player,Assetid,MenuType)
	warn('SPAWNING ASSET: '..tostring(Assetid))
	local hrp = player.Character.HumanoidRootPart
	local SpawnedAssetsFolder = workspace.PlayersFolders.SpawnedAssets
	local PlayerSpawnedAssetsFolder = SpawnedAssetsFolder:FindFirstChild(player.Name..'SpawnedAssets')
	CheckPlayersTable(player)
	
	if MenuType == 'Props' then -------------// PROP ASSETS
		local PropAssets = replicatedstorage.Assets.Props
		if Assetid == 1 then
			local barrel = PropAssets.Barrel	
			CreateAsset(barrel,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 2 then
			local Fence = PropAssets.Fence
			CreateAsset(Fence,player,hrp,PlayerSpawnedAssetsFolder)

		elseif Assetid == 3 then
			local Crate = PropAssets.Crate
			CreateAsset(Crate,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 4 then
			local Tire = PropAssets.Tire
			CreateAsset(Tire,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 5 then
			local Chair = PropAssets.Chair
			CreateAsset(Chair,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 6 then
			local Table = PropAssets.Table
			CreateAsset(Table,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 7 then
			local Computer = PropAssets.Computer
			CreateAsset(Computer,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 8 then
			local Toilet = PropAssets.Toilet
			CreateAsset(Toilet,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 9 then
			local Stove = PropAssets.Stove
			CreateAsset(Stove,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 10 then
			local WashingMachine = PropAssets.WashingMachine
			CreateAsset(WashingMachine,player,hrp,PlayerSpawnedAssetsFolder)
		end
	elseif MenuType == 'NPCs' then -------------------// NPC'S
		local NPCs = replicatedstorage.Assets.NPCs
		if Assetid == 1 then
			local OIIA = NPCs.Nextbot_OIIA
			CreateAsset(OIIA,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 2 then
			local Siren = NPCs.Nextbot_Siren
			CreateAsset(Siren,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 3 then
			local Cheeseburger = NPCs.Nextbot_Cheeseburger
			CreateAsset(Cheeseburger,player,hrp,PlayerSpawnedAssetsFolder)
			
		elseif Assetid == 4 then
			local Rock = NPCs.Nextbot_Rock
			CreateAsset(Rock,player,hrp,PlayerSpawnedAssetsFolder)
			
		end
	elseif MenuType == 'Vehicles' then
		
		
	elseif MenuType == 'MISC'  then
		
		
	end
end

return module

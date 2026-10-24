local pathfindserv = game:GetService('PathfindingService')
local runserv = game:GetService('RunService')
local Players = game:GetService('Players')


local npc = script.Parent
local npcHRP = npc.HumanoidRootPart
local npcHUM = npc.Humanoid
local nextbotframe = npc.Nextbot_Frame

local PlayersPosition = {}

npc.PrimaryPart:SetNetworkOwner(nil)

local function GetPath(target)
	local path = pathfindserv:CreatePath({
		AgentRadius = 4,
		AgentHeight = 5.5,
		AgentCanJump = true,
		AgentCanClimb = true,
	})
	
	if target.Character and target.Character:FindFirstChild('HumanoidRootPart') then
		path:ComputeAsync(npcHRP.Position,target.Character.HumanoidRootPart.Position)
	end
	
	return path
end

local function GetClosestPlayer()
	local closestPlayer = nil
	local closestDistance = math.huge

	for _,player in ipairs(Players:GetPlayers()) do
		local plrChar = player.Character
		if plrChar and plrChar:FindFirstChild("HumanoidRootPart") and plrChar:FindFirstChild("Humanoid") then
			if plrChar.Humanoid.Health > 0 then
				local distance = (plrChar.HumanoidRootPart.Position - npcHRP.Position).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end

local function ChaseTarget(target)
	local target = GetClosestPlayer()
	
	while task.wait(.2) do
		target = GetClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local path = GetPath(target)
			if path.Status == Enum.PathStatus.Success then
				local waypoints = path:GetWaypoints()
				if #waypoints > 1 then
					local waypoint = waypoints[3]
					if waypoint and waypoint.Action == Enum.PathWaypointAction.Jump then
						npcHUM.Jump = true
					end
					if waypoint then
						npcHUM:MoveTo(waypoint.Position)
					end
				end
			end
		end
	end
end

task.spawn(ChaseTarget)
nextbotframe.CheeseBurger:Play()

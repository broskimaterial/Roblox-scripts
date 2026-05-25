local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Natural Disaster Survival",
   Icon = 0,
   LoadingTitle = "NDS Script",
   LoadingSubtitle = "by script",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NDSScript",
      FileName = "Config"
   },
   Discord = { Enabled = false, Invite = "", RememberJoins = true },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local ToolsTab = Window:CreateTab("Tools", 4483362458)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

-- ===== INFINITE JUMP =====
MainTab:CreateSection("Movement")

local jumpConnection = nil

MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v)
      if jumpConnection then jumpConnection:Disconnect(); jumpConnection = nil end
      if v then
         jumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            local humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
               humanoid:ChangeState("Jumping")
            end
         end)
      end
   end,
})

-- ===== FLING FUNCTION =====
local function flingTarget(targetPlayer)
   if not targetPlayer or not targetPlayer.Character then return end
   local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end

   pcall(function()
      sethiddenproperty(LP, "SimulationRadius", 1000)
      sethiddenproperty(LP, "MaxSimulationRadius", 1000)
   end)

   local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
   if humanoid then
      humanoid.PlatformStand = true
      humanoid:ChangeState(Enum.HumanoidStateType.Physics)
   end

   hrp.Velocity = Vector3.new(0, 200, 0)
   hrp.RotVelocity = Vector3.new(100, 100, 100)

   local bt = Instance.new("BodyThrust")
   bt.Force = Vector3.new(99999, 99999 * 10, 99999)
   bt.Location = hrp.Position
   bt.Parent = hrp
   game:GetService("Debris"):AddItem(bt, 1)

   local bv = Instance.new("BodyVelocity")
   bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   bv.Velocity = Vector3.new(0, 150, 0)
   bv.Parent = hrp
   game:GetService("Debris"):AddItem(bv, 2)
end

local function getNearestPlayer()
   local origin = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
   if not origin then return nil end
   local closest, closestDist = nil, math.huge
   for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LP and p.Character then
         local hrp = p.Character:FindFirstChild("HumanoidRootPart")
         if hrp then
            local d = (origin.Position - hrp.Position).Magnitude
            if d < closestDist then closestDist = d; closest = p end
         end
      end
   end
   return closest
end

-- ===== TOOL LISTENER =====
local function setupToolListener()
   local function hookTool(tool)
      if tool.Name == "Fling" then
         tool.Activated:Connect(function()
            flingTarget(getNearestPlayer())
         end)
      end
   end

   local function onChar(char)
      char.ChildAdded:Connect(function(c)
         if c:IsA("Tool") then hookTool(c) end
      end)
      for _, c in ipairs(char:GetChildren()) do
         if c:IsA("Tool") then hookTool(c) end
      end
   end

   LP.CharacterAdded:Connect(onChar)
   if LP.Character then onChar(LP.Character) end
end

setupToolListener()

-- ===== TOOL MAKER =====
local function makeTool(name)
   local tool = Instance.new("Tool")
   tool.Name = name
   tool.ToolTip = name
   tool.RequiresHandle = false
   tool.CanBeDropped = true
   return tool
end

local function giveTool(tool)
   local backpack = LP:FindFirstChild("Backpack")
   if backpack then
      tool.Parent = backpack
      if LP.Character then
         LP.Character.Humanoid:EquipTool(tool)
      end
   end
end

-- ===== TOOLS TAB =====
ToolsTab:CreateSection("Tools")

ToolsTab:CreateButton({
   Name = "Give Fling Tool",
   Callback = function() giveTool(makeTool("Fling")) end,
})

ToolsTab:CreateSection("Actions")

ToolsTab:CreateButton({
   Name = "Fling Nearest Player",
   Callback = function() flingTarget(getNearestPlayer()) end,
})

ToolsTab:CreateButton({
   Name = "Fling All Players",
   Callback = function()
      for _, p in ipairs(Players:GetPlayers()) do
         if p ~= LP then
            task.wait(0.05)
            flingTarget(p)
         end
      end
   end,
})

Rayfield:LoadConfiguration()

task.spawn(function()
   task.wait(1)
   pcall(function()
      for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
         if v:IsA("ScreenGui") and v:FindFirstChild("Main", true) then
            v.Parent = LP:WaitForChild("PlayerGui")
         end
      end
   end)
end)

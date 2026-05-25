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

-- ===== TOOL LISTENER =====
local function setupToolListener()
   local function hookTool(tool)
      if tool.Name == "Fling" then
         tool.Activated:Connect(function()
            local origin = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not origin then return end
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
            if closest and closest.Character then
               local hrp = closest.Character:FindFirstChild("HumanoidRootPart")
               if hrp then
                  local dir = (hrp.Position - origin.Position).Unit
                  local bv = Instance.new("BodyVelocity")
                  bv.Velocity = dir * 150 + Vector3.new(0, 75, 0)
                  bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                  bv.Parent = hrp
                  game:GetService("Debris"):AddItem(bv, 1)
               end
            end
         end)
      elseif tool.Name == "Sniper" then
         tool.Activated:Connect(function()
            local ray = Ray.new(Camera.CFrame.Position, (Mouse.Hit.Position - Camera.CFrame.Position).Unit * 1000)
            local hit, pos, normal = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character})
            if not hit then return end

            local hitPlayer
            for _, p in ipairs(Players:GetPlayers()) do
               if p ~= LP and p.Character and hit:IsDescendantOf(p.Character) then
                  hitPlayer = p; break
               end
            end

            if hitPlayer and hitPlayer.Character then
               local hrp = hitPlayer.Character:FindFirstChild("HumanoidRootPart")
               if hrp then
                  local bv = Instance.new("BodyVelocity")
                  bv.Velocity = Vector3.new(0, 150, 0)
                  bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                  bv.Parent = hrp
                  game:GetService("Debris"):AddItem(bv, 1)
               end
            end
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
ToolsTab:CreateSection("Give Tools")

ToolsTab:CreateButton({
   Name = "Give Fling Tool",
   Callback = function() giveTool(makeTool("Fling")) end,
})

ToolsTab:CreateButton({
   Name = "Give Sniper Tool",
   Callback = function() giveTool(makeTool("Sniper")) end,
})

Rayfield:LoadConfiguration()

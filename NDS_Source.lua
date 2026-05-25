local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "NDS",
   Icon = 0,
   LoadingTitle = "NDS Script",
   LoadingSubtitle = "by script",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = true,
   ConfigurationSaving = { Enabled = true, FolderName = "NDSScript", FileName = "Config" },
   Discord = { Enabled = false, Invite = "", RememberJoins = true },
   KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateSection("Movement")
local jumpConn = nil
Tab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v)
      if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
      if v then
         jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hum:ChangeState("Jumping") end
         end)
      end
   end,
})

Tab:CreateSection("Fling")
local function doFling(p)
   if not p or not p.Character then return end
   local hrp = p.Character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end
   pcall(function() sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", 1000) end)
   pcall(function() sethiddenproperty(game.Players.LocalPlayer, "MaxSimulationRadius", 1000) end)
   local hum = p.Character:FindFirstChildOfClass("Humanoid")
   if hum then hum.PlatformStand = true end
   hrp.Velocity = Vector3.new(0, 200, 0)
   local bv = Instance.new("BodyVelocity")
   bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new(0, 150, 0); bv.Parent = hrp
   game:GetService("Debris"):AddItem(bv, 2)
   local bt = Instance.new("BodyThrust")
   bt.Force = Vector3.new(99999, 99999 * 10, 99999); bt.Location = hrp.Position; bt.Parent = hrp
   game:GetService("Debris"):AddItem(bt, 1)
end

local function nearest()
   local ori = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
   if not ori then return nil end
   local c, cd = nil, math.huge
   for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
      if p ~= game.Players.LocalPlayer and p.Character then
         local h = p.Character:FindFirstChild("HumanoidRootPart")
         if h then
            local d = (ori.Position - h.Position).Magnitude
            if d < cd then cd = d; c = p end
         end
      end
   end
   return c
end

local toolListener
toolListener = function()
   game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
      char.ChildAdded:Connect(function(c)
         if c:IsA("Tool") and c.Name == "Fling" then
            c.Activated:Connect(function() doFling(nearest()) end)
         end
      end)
   end)
   if game.Players.LocalPlayer.Character then
      for _, c in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
         if c:IsA("Tool") and c.Name == "Fling" then
            c.Activated:Connect(function() doFling(nearest()) end)
         end
      end
   end
end
toolListener()

local function give(n)
   local t = Instance.new("Tool"); t.Name = n; t.RequiresHandle = false; t.CanBeDropped = true
   local bp = game.Players.LocalPlayer:FindFirstChild("Backpack")
   if bp then t.Parent = bp end
end

Tab:CreateButton({ Name = "Give Fling Tool", Callback = function() give("Fling") end })
Tab:CreateButton({ Name = "Fling Nearest", Callback = function() doFling(nearest()) end })
Tab:CreateButton({ Name = "Fling All", Callback = function() for _, p in ipairs(game:GetService("Players"):GetPlayers()) do if p ~= game.Players.LocalPlayer then task.wait(0.05); doFling(p) end end end })

Rayfield:LoadConfiguration()

task.spawn(function()
   task.wait(1)
   pcall(function()
      for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
         if v:IsA("ScreenGui") and v:FindFirstChild("Main", true) then
            v.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
         end
      end
   end)
end)

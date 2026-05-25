local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Untitled Tag Game",
   Icon = 0,
   LoadingTitle = "UTG Script",
   LoadingSubtitle = "by script",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = true,
   ConfigurationSaving = { Enabled = true, FolderName = "UTGScript", FileName = "Config" },
   Discord = { Enabled = false, Invite = "", RememberJoins = true },
   KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateSection("Hitbox")

local hitboxOn = false
local hitboxSize = 15
local hitboxTrans = 0.85

Tab:CreateToggle({
   Name = "Expand Hitbox",
   CurrentValue = false,
   Callback = function(v) hitboxOn = v end,
})

Tab:CreateSlider({
   Name = "Hitbox Size",
   Min = 5,
   Max = 30,
   Default = 15,
   Callback = function(v) hitboxSize = v end,
})

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

local wsVal = 16
Tab:CreateSlider({
   Name = "Walk Speed",
   Min = 16,
   Max = 120,
   Default = 16,
   Callback = function(v) wsVal = v end,
})

local jpVal = 50
Tab:CreateSlider({
   Name = "Jump Power",
   Min = 50,
   Max = 200,
   Default = 50,
   Callback = function(v) jpVal = v end,
})

game:GetService("RunService").RenderStepped:Connect(function()
   pcall(function()
      if hitboxOn then
         for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
               p.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
               p.Character.HumanoidRootPart.Transparency = hitboxTrans
               p.Character.HumanoidRootPart.Material = Enum.Material.Neon
               p.Character.HumanoidRootPart.Color = Color3.fromRGB(0, 150, 255)
            end
         end
      end
   end)
   pcall(function()
      local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then
         hum.WalkSpeed = wsVal
         hum.JumpPower = jpVal
      end
   end)
end)

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

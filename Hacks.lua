local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Settings = {
    ESP = false,
    Noclip = false,
    Aimbot = false,
    Flight = false,
    Spin = false,
    WalkSpeedToggle = false,
    JumpPowerToggle = false,
    InvisMode = false,
    -- Oletusarvot (ilman slidereitä)
    FlightSpeed = 100,
    WalkSpeed = 100,
    JumpPower = 150,
    SpinSpeed = 100
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernSwitchMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.9 -- 90% läpinäkyvä tausta
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 420)
MainFrame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Otsikko
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "CHEAT MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- FUNKTIO KYTKIMEN LUOMISELLE
local function CreateToggle(name, parent, defaultState, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(0, 200, 0, 45)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ButtonFrame.BackgroundTransparency = 0.75 -- 75% läpinäkyvä nappi
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ButtonFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ButtonFrame

    -- Switch Tausta
    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
    SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(100, 100, 100)
    SwitchBg.Parent = ButtonFrame

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(1, 0)
    BgCorner.Parent = SwitchBg

    -- Switch Nuppi (Liukuva osa)
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.Parent = SwitchBg

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.Parent = ButtonFrame

    local state = defaultState
    ClickBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(100, 100, 100)

        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        callback(state)
    end)
end

-- LUODAAN NAPIT
CreateToggle("ESP", MainFrame, Settings.ESP, function(v) Settings.ESP = v end)
CreateToggle("Aimbot", MainFrame, Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("Noclip", MainFrame, Settings.Noclip, function(v) Settings.Noclip = v end)
CreateToggle("Flight", MainFrame, Settings.Flight, function(v) Settings.Flight = v end)
CreateToggle("Spinbot", MainFrame, Settings.Spin, function(v) Settings.Spin = v end)
CreateToggle("WalkSpeed", MainFrame, Settings.WalkSpeedToggle, function(v) Settings.WalkSpeedToggle = v end)
CreateToggle("JumpPower", MainFrame, Settings.JumpPowerToggle, function(v) Settings.JumpPowerToggle = v end)
CreateToggle("Invis Mode", MainFrame, Settings.InvisMode, function(v) Settings.InvisMode = v end)

-- LOGIIKKA (Lyhyesti esimerkkeinä)
RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if Settings.WalkSpeedToggle then hum.WalkSpeed = Settings.WalkSpeed else hum.WalkSpeed = 16 end
        if Settings.JumpPowerToggle then hum.JumpPower = Settings.JumpPower else hum.JumpPower = 50 end
    end
end)

-- Vedettävä paneeli
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

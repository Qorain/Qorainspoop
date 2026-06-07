local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Settings = {
    TargetPlayer = "",
    TP = false,
    Weld = false,
    Bang = false,
    ESP = false,
    Noclip = false,
    Aimbot = false,
    Flight = false,
    Spin = false,
    WalkSpeedToggle = false,
    JumpPowerToggle = false,
    
    -- Oletusarvot modeille
    FlightSpeed = 100,
    WalkSpeed = 100,
    JumpPower = 150,
    SpinSpeed = 100
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateSwitchMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- PÄÄPANEELI (90% läpinäkyvä background)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.9 
MainFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 550)
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- SULKEMISRASTI (X-painike oikeassa yläkulmassa)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BackgroundTransparency = 0.5
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- SKROLLAAVA ALUE
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
end)

-- Otsikko
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MAIN UTILITY MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Taulukko kytkimien päivitysfunktioille, jotta ne voidaan resetoida ulkopuolelta
local ToggleRegistry = {}

-- FUNKTIO KAIKEN RESETOIMISELLE JA SAMMUTTAMISELLE
local function DisableAndResetAll()
    Settings.TargetPlayer = ""
    local NameBox = ScrollFrame:FindFirstChildOfClass("TextBox")
    if NameBox then NameBox.Text = "" end
    
    -- Tyhjennetään kohdepelaajan lukitus välittömästi
    Settings.TP = false
    Settings.Weld = false
    Settings.Bang = false
    Settings.ESP = false
    Settings.Noclip = false
    Settings.Aimbot = false
    Settings.Flight = false
    Settings.Spin = false
    Settings.WalkSpeedToggle = false
    Settings.JumpPowerToggle = false
    
    -- Käännetään kaikki visuaaliset kytkimet OFF-asentoon animaatiolla
    for _, resetFunc in pairs(ToggleRegistry) do
        resetFunc()
    end
    
    -- Palautetaan hahmon fysiikat välittömästi normaaleiksi
    local character = LocalPlayer.Character
    if character then
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
         Museum = character:GetDescendants()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- RASTIN KLIKKAUS (Sammuttaa kaiken ja tuhoaa UI:n)
CloseButton.MouseButton1Click:Connect(function()
    DisableAndResetAll()
    ScreenGui:Destroy()
end)

-- DISABLE ALL -PAINIKE (75% läpinäkyvä)
local DisableAllBtn = Instance.new("TextButton")
DisableAllBtn.Size = UDim2.new(0, 230, 0, 38)
DisableAllBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
DisableAllBtn.BackgroundTransparency = 0.75
DisableAllBtn.BorderSizePixel = 0
DisableAllBtn.Text = "DISABLE & RESET ALL"
DisableAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DisableAllBtn.Font = Enum.Font.SourceSansBold
DisableAllBtn.TextSize = 13
DisableAllBtn.Parent = ScrollFrame

local DisableCorner = Instance.new("UICorner")
DisableCorner.CornerRadius = UDim.new(0, 6)
DisableCorner.Parent = DisableAllBtn

DisableAllBtn.MouseButton1Click:Connect(DisableAndResetAll)

-- NIMITEKSTIKENTTÄ (75% läpinäkyvä)
local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(0, 230, 0, 38)
NameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NameBox.BackgroundTransparency = 0.75
NameBox.BorderSizePixel = 0
NameBox.Text = ""
NameBox.PlaceholderText = "Syötä pelaajan nimi..."
NameBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
NameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NameBox.Font = Enum.Font.SourceSansBold
NameBox.TextSize = 14
NameBox.Parent = ScrollFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = NameBox

NameBox:GetPropertyChangedSignal("Text"):Connect(function()
    Settings.TargetPlayer = NameBox.Text
end)

-- FUNKTIO LIUKUKYTKIMEN LUOMISELLE (75% läpinäkyvät napit)
local function CreateToggle(name, settingKey)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(0, 230, 0, 40)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ButtonFrame.BackgroundTransparency = 0.75
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = ScrollFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ButtonFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ButtonFrame

    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 36, 0, 18)
    SwitchBg.Position = UDim2.new(1, -46, 0.5, -9)
    SwitchBg.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
    SwitchBg.Parent = ButtonFrame

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(1, 0)
    BgCorner.Parent = SwitchBg

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = Settings[settingKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
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

    -- Rekisteröidään ulkoinen resetointifunktio tälle kytkimelle
    ToggleRegistry[settingKey] = function()
        TweenService:Create(Dot, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
    end

    ClickBtn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        local targetPos = Settings[settingKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetColor = Settings[settingKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)

        TweenService:Create(Dot, TweenInfo.new(0.15), {Position = targetPos}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end)
end

-- Apufunktio kohdepelaajan löytämiseen nimen perusteella
local function GetTarget()
    if Settings.TargetPlayer == "" then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.lower(p.Name):sub(1, #Settings.TargetPlayer) == string.lower(Settings.TargetPlayer) then
            return p
        end
    end
    return nil
end

-- LUODAAN KAIKKI LIUKUKYTKIMET JÄRJESTYKSESSÄ
CreateToggle("TP to Them", "TP")
CreateToggle("Weld to Them", "Weld")
CreateToggle("Bang to Them", "Bang")
CreateToggle("ESP", "ESP")
CreateToggle("Aimbot", "Aimbot")
CreateToggle("Noclip", "Noclip")
CreateToggle("Flight", "Flight")
CreateToggle("Spinbot", "Spin")
CreateToggle("WalkSpeed", "WalkSpeedToggle")
CreateToggle("JumpPower", "JumpPowerToggle")

-- DO-LOOP (Jatkuva logiikka)
local bangAnimStep = 0
RunService.Heartbeat:Connect(function()
    local target = GetTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHRP = LocalPlayer.Character.HumanoidRootPart
        local targetHRP = target.Character.HumanoidRootPart
        
        if Settings.TP then
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
        elseif Settings.Weld then
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 0.5)
            myHRP.Velocity = Vector3.new(0, 0, 0)
        elseif Settings.Bang then
            bangAnimStep = bangAnimStep + 0.5
            local bangOffset = math.sin(bangAnimStep) * 0.75
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1 + bangOffset)
        end
    end
    
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

-- Paneelin raahauslogiikka hiirellä
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

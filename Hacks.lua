local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Tiedoston nimi tallennusta varten
local SAVE_FILE = "CheatMenu_Settings.json"

local Settings = {
    ESP = false,
    Noclip = false,
    Aimbot = false,
    Flight = false,
    Spin = false,
    WalkSpeedToggle = false,
    JumpPowerToggle = false,
    BangActive = false,
    FlightSpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    SpinSpeed = 100,
    BangSpeed = 20,
    CharacterScale = 1,
    Binds = {
        ESP = "F",
        Noclip = "V",
        Aimbot = "E",
        Flight = "G",
        Spin = "H",
        WalkSpeedToggle = "J",
        JumpPowerToggle = "K"
    }
}

-- Funktiot asetusten tallentamiseen ja lataamiseen kiintolevyltä
local function SaveSettings()
    if writefile then
        local success, encoded = pcall(function()
            return HttpService:JSONEncode({
                FlightSpeed = Settings.FlightSpeed,
                WalkSpeed = Settings.WalkSpeed,
                JumpPower = Settings.JumpPower,
                SpinSpeed = Settings.SpinSpeed,
                BangSpeed = Settings.BangSpeed,
                CharacterScale = Settings.CharacterScale,
                Binds = Settings.Binds
            })
        end)
        if success then
            writefile(SAVE_FILE, encoded)
        end
    end
end

local function LoadSettings()
    if readfile and isfile and isfile(SAVE_FILE) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end)
        if success and decoded then
            if decoded.FlightSpeed then Settings.FlightSpeed = decoded.FlightSpeed end
            if decoded.WalkSpeed then Settings.WalkSpeed = decoded.WalkSpeed end
            if decoded.JumpPower then Settings.JumpPower = decoded.JumpPower end
            if decoded.SpinSpeed then Settings.SpinSpeed = decoded.SpinSpeed end
            if decoded.BangSpeed then Settings.BangSpeed = decoded.BangSpeed end
            if decoded.CharacterScale then Settings.CharacterScale = decoded.CharacterScale end
            if decoded.Binds then
                for k, v in pairs(decoded.Binds) do
                    Settings.Binds[k] = v
                end
            end
        end
    end
end

LoadSettings()

local function GetUserInputTypeOrKeyCode(bindName)
    local bind = Settings.Binds[bindName]
    if bind == "None" then return nil end
    
    if string.find(bind, "MouseButton") then
        return Enum.UserInputType[bind]
    else
        return Enum.KeyCode[bind]
    end
end

local Connections = {}
local IsRunning = true
local SpinBodyAngularVelocity = nil
local SpinBlockForce = nil
local CurrentWeld = nil 
local IsMinimized = false
local FullSizeY = 530
local IsAtBottom = false
local TargetBangPlayer = nil

-- --- ANTI DISCONNECT / ANTI-AFK SCRIPT ---
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    local success, err = pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
        end)
    end)
    if success then
        print("Anti-AFK (Server Disconnect Protection) aktivoitu onnistuneesti!")
    else
        print("Anti-AFK virhe: " .. tostring(err))
    end
end)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")

ScreenGui.Name = "CheatMenu_Persistent"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 200, 0, FullSizeY)
MainFrame.ClipsDescendants = true

-- Liikuteltava ikkuna
local dragToggle, dragStart, startPos
local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then if dragToggle then updateInput(input) end end end)

Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.BackgroundTransparency = 0.1
Title.Text = "MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = Title
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.BackgroundTransparency = 0.1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18

local function ToggleMinimize()
    IsMinimized = not IsMinimized
    if IsMinimized then
        MainFrame.Size = UDim2.new(0, 200, 0, 40)
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 200, 0, FullSizeY)
        MinimizeBtn.Text = "-"
    end
end
MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)

ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1370)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

local function CreateButton(name, text, pos, parent, color)
    local btn = Instance.new("TextButton")
    btn.Name = name btn.Parent = parent btn.Size = UDim2.new(0, 180, 0, 40) btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60) btn.BackgroundTransparency = 0.1
    btn.Text = text btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.TextSize = 14
    return btn
end

-- Painikkeet
local ESPBtn = CreateButton("ESPBtn", "", UDim2.new(0, 10, 0, 10), ScrollFrame)
local NoclipBtn = CreateButton("NoclipBtn", "", UDim2.new(0, 10, 0, 60), ScrollFrame)
local AimbotBtn = CreateButton("AimbotBtn", "", UDim2.new(0, 10, 0, 110), ScrollFrame)
local FlightBtn = CreateButton("FlightBtn", "", UDim2.new(0, 10, 0, 160), ScrollFrame)
local SpinBtn = CreateButton("SpinBtn", "", UDim2.new(0, 10, 0, 210), ScrollFrame)
local WalkToggleBtn = CreateButton("WalkToggleBtn", "", UDim2.new(0, 10, 0, 260), ScrollFrame)
local JumpToggleBtn = CreateButton("JumpToggleBtn", "", UDim2.new(0, 10, 0, 310), ScrollFrame)

-- --- PLAYER INTERACTIONS ---
local WeldLabel = Instance.new("TextLabel")
WeldLabel.Name = "WeldLabel" WeldLabel.Parent = ScrollFrame WeldLabel.Size = UDim2.new(0, 180, 0, 20) WeldLabel.Position = UDim2.new(0, 10, 0, 360)
WeldLabel.BackgroundTransparency = 1 WeldLabel.Text = "PLAYER INTERACTIONS" WeldLabel.TextColor3 = Color3.fromRGB(255, 255, 255) WeldLabel.TextSize = 12 WeldLabel.Font = Enum.Font.SourceSansBold

local WeldTextBox = Instance.new("TextBox")
WeldTextBox.Name = "WeldTextBox" WeldTextBox.Parent = ScrollFrame WeldTextBox.Size = UDim2.new(0, 180, 0, 30) WeldTextBox.Position = UDim2.new(0, 10, 0, 385)
WeldTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45) WeldTextBox.BackgroundTransparency = 0.1 WeldTextBox.Text = "" WeldTextBox.PlaceholderText = "Username..."
WeldTextBox.TextColor3 = Color3.fromRGB(255, 255, 255) WeldTextBox.TextSize = 14

local WeldBtn = CreateButton("WeldBtn", "Weld to Me", UDim2.new(0, 10, 0, 420), ScrollFrame, Color3.fromRGB(40, 100, 40))
local BangBtn = CreateButton("BangBtn", "Bang Player", UDim2.new(0, 10, 0, 465), ScrollFrame, Color3.fromRGB(110, 80, 30))
local TPToMeBtn = CreateButton("TPToMeBtn", "TP to Me", UDim2.new(0, 10, 0, 510), ScrollFrame, Color3.fromRGB(40, 80, 110))
local TPToThemBtn = CreateButton("TPToThemBtn", "TP to Them", UDim2.new(0, 10, 0, 555), ScrollFrame, Color3.fromRGB(90, 40, 110))
local UnweldBtn = CreateButton("UnweldBtn", "Stop Weld / Bang", UDim2.new(0, 10, 0, 600), ScrollFrame, Color3.fromRGB(100, 40, 40))


-- --- SLIDERIT ---
local SliderFrame = Instance.new("Frame")
local SliderBar = Instance.new("Frame")
local SliderDot = Instance.new("TextButton")
local SliderValueLabel = Instance.new("TextLabel")

SliderFrame.Parent = ScrollFrame SliderFrame.Size = UDim2.new(0, 180, 0, 50) SliderFrame.Position = UDim2.new(0, 10, 0, 660) SliderFrame.BackgroundTransparency = 1
SliderValueLabel.Parent = SliderFrame SliderValueLabel.Size = UDim2.new(1, 0, 0, 20) SliderValueLabel.BackgroundTransparency = 1 SliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderBar.Parent = SliderFrame SliderBar.Size = UDim2.new(1, 0, 0, 6) SliderBar.Position = UDim2.new(0, 0, 0, 25) SliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SliderDot.Parent = SliderBar SliderDot.Size = UDim2.new(0, 16, 0, 16) SliderDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200) SliderDot.Text = ""

local startingPercent = math.clamp((Settings.FlightSpeed - 10) / 240, 0, 1)
SliderDot.Position = UDim2.new(startingPercent, -8, 0.5, -8)
SliderValueLabel.Text = "Fly Speed: " .. Settings.FlightSpeed

local dragging = false
local function UpdateSlider(input)
    local relativeX = input.Position.X - SliderBar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / SliderBar.AbsoluteSize.X, 0, 1)
    SliderDot.Position = UDim2.new(percentage, -8, 0.5, -8)
    Settings.FlightSpeed = math.floor(10 + (percentage * 240))
    SliderValueLabel.Text = "Fly Speed: " .. Settings.FlightSpeed
    SaveSettings()
end
SliderDot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end end)


local WSliderFrame = Instance.new("Frame")
local WSliderBar = Instance.new("Frame")
local WSliderDot = Instance.new("TextButton")
local WSliderValueLabel = Instance.new("TextLabel")

WSliderFrame.Parent = ScrollFrame WSliderFrame.Size = UDim2.new(0, 180, 0, 50) WSliderFrame.Position = UDim2.new(0, 10, 0, 715) WSliderFrame.BackgroundTransparency = 1
WSliderValueLabel.Parent = WSliderFrame WSliderValueLabel.Size = UDim2.new(1, 0, 0, 20) WSliderValueLabel.BackgroundTransparency = 1 WSliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WSliderBar.Parent = WSliderFrame WSliderBar.Size = UDim2.new(1, 0, 0, 6) WSliderBar.Position = UDim2.new(0, 0, 0, 25) WSliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
WSliderDot.Parent = WSliderBar WSliderDot.Size = UDim2.new(0, 16, 0, 16) WSliderDot.BackgroundColor3 = Color3.fromRGB(150, 200, 255) WSliderDot.Text = ""

local wStartingPercent = math.clamp((Settings.WalkSpeed - 16) / 234, 0, 1)
WSliderDot.Position = UDim2.new(wStartingPercent, -8, 0.5, -8)
WSliderValueLabel.Text = "Walk Speed: " .. Settings.WalkSpeed

local wDragging = false
local function UpdateWalkSlider(input)
    local relativeX = input.Position.X - WSliderBar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / WSliderBar.AbsoluteSize.X, 0, 1)
    WSliderDot.Position = UDim2.new(percentage, -8, 0.5, -8)
    Settings.WalkSpeed = math.floor(16 + (percentage * 234))
    WSliderValueLabel.Text = "Walk Speed: " .. Settings.WalkSpeed
    SaveSettings()
end
WSliderDot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then wDragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then wDragging = false end end)
UserInputService.InputChanged:Connect(function(input) if wDragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateWalkSlider(input) end end)


local JSliderFrame = Instance.new("Frame")
local JSliderBar = Instance.new("Frame")
local JSliderDot = Instance.new("TextButton")
local JSliderValueLabel = Instance.new("TextLabel")

JSliderFrame.Parent = ScrollFrame JSliderFrame.Size = UDim2.new(0, 180, 0, 50) JSliderFrame.Position = UDim2.new(0, 10, 0, 770) JSliderFrame.BackgroundTransparency = 1
JSliderValueLabel.Parent = JSliderFrame JSliderValueLabel.Size = UDim2.new(1, 0, 0, 20) JSliderValueLabel.BackgroundTransparency = 1 JSliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JSliderBar.Parent = JSliderFrame JSliderBar.Size = UDim2.new(1, 0, 0, 6) JSliderBar.Position = UDim2.new(0, 0, 0, 25) JSliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
JSliderDot.Parent = JSliderBar JSliderDot.Size = UDim2.new(0, 16, 0, 16) JSliderDot.BackgroundColor3 = Color3.fromRGB(255, 200, 150) JSliderDot.Text = ""

local jStartingPercent = math.clamp((Settings.JumpPower - 50) / 450, 0, 1)
JSliderDot.Position = UDim2.new(jStartingPercent, -8, 0.5, -8)
JSliderValueLabel.Text = "Jump Power: " .. Settings.JumpPower

local jDragging = false
local function UpdateJumpSlider(input)
    local relativeX = input.Position.X - JSliderBar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / JSliderBar.AbsoluteSize.X, 0, 1)
    JSliderDot.Position = UDim2.new(percentage, -8, 0.5, -8)
    Settings.JumpPower = math.floor(50 + (percentage * 450))
    JSliderValueLabel.Text = "Jump Power: " .. Settings.JumpPower
    SaveSettings()
end
JSliderDot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then jDragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then jDragging = false end end)
UserInputService.InputChanged:Connect(function(input) if jDragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateJumpSlider(input) end end)


local BangSliderFrame = Instance.new("Frame")
local BangSliderBar = Instance.new("Frame")
local BangSliderDot = Instance.new("TextButton")
local BangSliderValueLabel = Instance.new("TextLabel")

BangSliderFrame.Parent = ScrollFrame BangSliderFrame.Size = UDim2.new(0, 180, 0, 50) BangSliderFrame.Position = UDim2.new(0, 10, 0, 825) BangSliderFrame.BackgroundTransparency = 1
BangSliderValueLabel.Parent = BangSliderFrame BangSliderValueLabel.Size = UDim2.new(1, 0, 0, 20) BangSliderValueLabel.BackgroundTransparency = 1 BangSliderValueLabel.TextColor3 = Color3.fromRGB(240, 180, 80)
BangSliderBar.Parent = BangSliderFrame BangSliderBar.Size = UDim2.new(1, 0, 0, 6) BangSliderBar.Position = UDim2.new(0, 0, 0, 25) BangSliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BangSliderDot.Parent = BangSliderBar BangSliderDot.Size = UDim2.new(0, 16, 0, 16) BangSliderDot.BackgroundColor3 = Color3.fromRGB(240, 180, 80) BangSliderDot.Text = ""

local bangStartingPercent = math.clamp((Settings.BangSpeed - 5) / 45, 0, 1)
BangSliderDot.Position = UDim2.new(bangStartingPercent, -8, 0.5, -8)
BangSliderValueLabel.Text = "Bang Speed: " .. Settings.BangSpeed

local bangDragging = false
local function UpdateBangSlider(input)
    local relativeX = input.Position.X - BangSliderBar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / BangSliderBar.AbsoluteSize.X, 0, 1)
    BangSliderDot.Position = UDim2.new(percentage, -8, 0.5, -8)
    Settings.BangSpeed = math.floor(5 + (percentage * 45))
    BangSliderValueLabel.Text = "Bang Speed: " .. Settings.BangSpeed
    SaveSettings()
end
BangSliderDot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then bangDragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then bangDragging = false end end)
UserInputService.InputChanged:Connect(function(input) if bangDragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateBangSlider(input) end end)


local SSliderFrame = Instance.new("Frame")
local SSliderBar = Instance.new("Frame")
local SSliderDot = Instance.new("TextButton")
local SSliderValueLabel = Instance.new("TextLabel")

SSliderFrame.Parent = ScrollFrame SSliderFrame.Size = UDim2.new(0, 180, 0, 50) SSliderFrame.Position = UDim2.new(0, 10, 0, 880) SSliderFrame.BackgroundTransparency = 1
SSliderValueLabel.Parent = SSliderFrame SSliderValueLabel.Size = UDim2.new(1, 0, 0, 20) SSliderValueLabel.BackgroundTransparency = 1 SSliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SSliderBar.Parent = SSliderFrame SSliderBar.Size = UDim2.new(1, 0, 0, 6) SSliderBar.Position = UDim2.new(0, 0, 0, 25) SSliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SSliderDot.Parent = SSliderBar SSliderDot.Size = UDim2.new(0, 16, 0, 16) SSliderDot.BackgroundColor3 = Color3.fromRGB(200, 150, 255) SSliderDot.Text = ""

local sStartingPercent = math.clamp((Settings.SpinSpeed - 10) / 2490, 0, 1)
SSliderDot.Position = UDim2.new(sStartingPercent, -8, 0.5, -8)
SSliderValueLabel.Text = "Spin Speed: " .. Settings.SpinSpeed

local sDragging = false
local function UpdateSpinSlider(input)
    local relativeX = input.Position.X - SSliderBar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / SSliderBar.AbsoluteSize.X, 0, 1)
    SSliderDot.Position = UDim2.new(percentage, -8, 0.5, -8)
    Settings.SpinSpeed = math.floor(10 + (percentage * 2490))
    SSliderValueLabel.Text = "Spin Speed: " .. Settings.SpinSpeed
    
    if Settings.Spin and SpinBodyAngularVelocity then
        SpinBodyAngularVelocity.AngularVelocity = Vector3.new(0, Settings.SpinSpeed, 0)
    end
    SaveSettings()
end
SSliderDot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = false end end)
UserInputService.InputChanged:Connect(function(input) if sDragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSpinSlider(input) end end)


local SizeSliderFrame = Instance.new("Frame")
local SizeSliderBar = Instance.new("Frame")
local SizeSliderDot = Instance.new("TextButton")
local SizeSliderValueLabel = Instance.new("TextLabel")

SizeSliderFrame.Parent = ScrollFrame SizeSliderFrame.Size = UDim2.new(0, 180, 0, 50) SizeSliderFrame.Position = UDim2.new(0, 10, 0, 935) SizeSliderFrame.BackgroundTransparency = 1
SizeSliderValueLabel.Parent = SizeSliderFrame SizeSliderValueLabel.Size = UDim2.new(1, 0, 0, 20) SizeSliderValueLabel.BackgroundTransparency = 1 SizeSliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeSliderBar.Parent = SizeSliderFrame SizeSliderBar.Size = UDim2.new(1, 0, 0, 6) SizeSliderBar.Position = UDim2.new(0, 0, 0, 25) SizeSliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SizeSliderDot.Parent = SizeSliderBar SizeSliderDot.Size = UDim2.new(0, 16, 0, 16) SizeSliderDot.BackgroundColor3 = Color3.fromRGB(150, 255, 150) SizeSliderDot.Text = ""

local function UpdateCharacterScale()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local hs = humanoid:FindFirstChild("BodyHeightScale")
        local ws = humanoid:FindFirstChild("BodyWidthScale")
        local ds = humanoid:FindFirstChild("BodyDepthScale")
        local hds = humanoid:FindFirstChild("HeadScale")
        
        if hs then hs.Value = Settings.CharacterScale end
        if ws then ws.Value = Settings.CharacterScale end
        if ds then ds.Value = Settings.CharacterScale end
        if hds then hds.Value = Settings.CharacterScale end
    end
end

local sizeStartingPercent = math.clamp((Settings.CharacterScale - 0.5) / 4.5, 0, 1)
SizeSliderDot.Position = UDim2.new(sizeStartingPercent, -8, 0.5, -8)
SizeSliderValueLabel.Text = "Character Scale: " .. string.format("%.1fx", Settings.CharacterScale)

local sizeDragging = false
local function UpdateSizeSlider(input)
    local relativeX = input.Position.X - SizeSliderBar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / SizeSliderBar.AbsoluteSize.X, 0, 1)
    SizeSliderDot.Position = UDim2.new(percentage, -8, 0.5, -8)
    Settings.CharacterScale = 0.5 + (percentage * 4.5)
    SizeSliderValueLabel.Text = "Character Scale: " .. string.format("%.1fx", Settings.CharacterScale)
    UpdateCharacterScale()
    SaveSettings()
end
SizeSliderDot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sizeDragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sizeDragging = false end end)
UserInputService.InputChanged:Connect(function(input) if sizeDragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSizeSlider(input) end end)


-- --- LASKIN (CALCULATOR) ---
local CalcLabel = Instance.new("TextLabel")
CalcLabel.Name = "CalcLabel" CalcLabel.Parent = ScrollFrame CalcLabel.Size = UDim2.new(0, 180, 0, 20) CalcLabel.Position = UDim2.new(0, 10, 0, 995)
CalcLabel.BackgroundTransparency = 1 CalcLabel.Text = "CALCULATOR" CalcLabel.TextColor3 = Color3.fromRGB(255, 255, 255) CalcLabel.TextSize = 12 CalcLabel.Font = Enum.Font.SourceSansBold

local CalcTextBox = Instance.new("TextBox")
CalcTextBox.Name = "CalcTextBox" CalcTextBox.Parent = ScrollFrame CalcTextBox.Size = UDim2.new(0, 180, 0, 30) CalcTextBox.Position = UDim2.new(0, 10, 0, 1020)
CalcTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45) CalcTextBox.BackgroundTransparency = 0.1 CalcTextBox.Text = "" CalcTextBox.PlaceholderText = "e.g. 50 * 2.5"
CalcTextBox.TextColor3 = Color3.fromRGB(255, 255, 255) CalcTextBox.TextSize = 14

local CalcResultLabel = Instance.new("TextLabel")
CalcResultLabel.Name = "CalcResultLabel" CalcResultLabel.Parent = ScrollFrame CalcResultLabel.Size = UDim2.new(0, 180, 0, 25) CalcResultLabel.Position = UDim2.new(0, 10, 0, 1055)
CalcResultLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25) CalcResultLabel.BackgroundTransparency = 0.3 CalcResultLabel.Text = "Result: -" CalcResultLabel.TextColor3 = Color3.fromRGB(150, 255, 150) CalcResultLabel.TextSize = 13

local CalcBtn = CreateButton("CalcBtn", "Calculate", UDim2.new(0, 10, 0, 1085), ScrollFrame, Color3.fromRGB(60, 80, 90))

local function SafeCalculate(expression)
    local cleaned = string.gsub(expression, "[^%d%.%+%-%*%/%^%(%)]", "")
    if cleaned == "" then return nil end
    local func, err = loadstring("return " .. cleaned)
    if func then
        local success, result = pcall(func)
        if success then return result end
    end
    return nil
end

CalcBtn.MouseButton1Click:Connect(function()
    local result = SafeCalculate(CalcTextBox.Text)
    if result then
        CalcResultLabel.Text = "Result: " .. tostring(result)
        CalcResultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        CalcResultLabel.Text = "Invalid Expression!"
        CalcResultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)


-- Pohjapainikkeet
local DisableAllBtn = CreateButton("DisableAllBtn", "Disable All", UDim2.new(0, 10, 0, 1140), ScrollFrame, Color3.fromRGB(120, 40, 40))
local ShutDownBtn = CreateButton("ShutDownBtn", "Shut Down GUI", UDim2.new(0, 10, 0, 1190), ScrollFrame, Color3.fromRGB(45, 45, 45))

local function UpdateTexts()
    if not IsRunning then return end 
    ESPBtn.Text = "ESP: " .. (Settings.ESP and "ON" or "OFF") .. " (" .. Settings.Binds.ESP .. ")"
    NoclipBtn.Text = "Noclip: " .. (Settings.Noclip and "ON" or "OFF") .. " (" .. Settings.Binds.Noclip .. ")"
    AimbotBtn.Text = "Aimbot: " .. (Settings.Aimbot and "ON" or "OFF") .. " (" .. Settings.Binds.Aimbot .. ")"
    FlightBtn.Text = "Flight: " .. (Settings.Flight and "ON" or "OFF") .. " (" .. Settings.Binds.Flight .. ")"
    SpinBtn.Text = "Spinbot: " .. (Settings.Spin and "ON" or "OFF") .. " (" .. Settings.Binds.Spin .. ")"
    WalkToggleBtn.Text = "WalkSpeed: " .. (Settings.WalkSpeedToggle and "ON" or "OFF") .. " (" .. Settings.Binds.WalkSpeedToggle .. ")"
    JumpToggleBtn.Text = "JumpPower: " .. (Settings.JumpPowerToggle and "ON" or "OFF") .. " (" .. Settings.Binds.JumpPowerToggle .. ")"
end
UpdateTexts()

local function RemoveSpin()
    if SpinBodyAngularVelocity then SpinBodyAngularVelocity:Destroy() SpinBodyAngularVelocity = nil end
    if SpinBlockForce then SpinBlockForce:Destroy() SpinBlockForce = nil end
end

local function UnweldPlayer()
    if CurrentWeld then CurrentWeld:Destroy() CurrentWeld = nil end
    Settings.BangActive = false TargetBangPlayer = nil
    if IsRunning then
        if WeldBtn then WeldBtn.Text = "Weld to Me" end
        if BangBtn then BangBtn.Text = "Bang Player" end
    end
end

local function GetPlayerByString(text)
    local cleaned = string.lower(text)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.sub(string.lower(p.Name), 1, #cleaned) == cleaned then
            return p
        end
    end
    return nil
end

local function WeldToMe()
    UnweldPlayer() 
    local targetPlayer = GetPlayerByString(WeldTextBox.Text)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        local myCharacter = LocalPlayer.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if myHRP then
            targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -3)
            CurrentWeld = Instance.new("WeldConstraint")
            CurrentWeld.Name = "PlayerWeldLockToMe"
            CurrentWeld.Part0 = targetHRP CurrentWeld.Part1 = myHRP CurrentWeld.Parent = targetHRP
            WeldBtn.Text = "Hitsattu sinuun!"
        else
            WeldBtn.Text = "Oma HRP puuttuu!"
            task.delay(1.5, function() if IsRunning and WeldBtn.Text == "Oma HRP puuttuu!" then WeldBtn.Text = "Weld to Me" end end)
        end
    else
        WeldBtn.Text = "Ei löytynyt!"
        task.delay(1.5, function() if IsRunning and WeldBtn.Text == "Ei löytynyt!" then WeldBtn.Text = "Weld to Me" end end)
    end
end

local function BangPlayer()
    UnweldPlayer()
    local targetPlayer = GetPlayerByString(WeldTextBox.Text)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        TargetBangPlayer = targetPlayer Settings.BangActive = true
        BangBtn.Text = "Banging: " .. targetPlayer.Name
    else
        BangBtn.Text = "Ei löytynyt!"
        task.delay(1.5, function() if IsRunning and BangBtn.Text == "Ei löytynyt!" then BangBtn.Text = "Bang Player" end end)
    end
end

local function TeleportPlayerToMe()
    local targetPlayer = GetPlayerByString(WeldTextBox.Text)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        local myCharacter = LocalPlayer.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if myHRP then
            TPToMeBtn.Text = "Siirretään..."
            task.spawn(function()
                while IsRunning and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                    local currentTargetPos = targetHRP.Position
                    local desiredPos = (myHRP.CFrame * CFrame.new(0, 0, -3)).Position
                    local direction = (desiredPos - currentTargetPos)
                    local distance = direction.Magnitude
                    if distance <= 1 then
                        targetHRP.CFrame = CFrame.new(desiredPos) * (targetHRP.CFrame - targetHRP.Position)
                        break
                    end
                    local moveStep = direction.Unit * 1
                    targetHRP.CFrame = CFrame.new(currentTargetPos + moveStep) * (targetHRP.CFrame - targetHRP.Position)
                    task.wait(0.25)
                end
                if IsRunning then TPToMeBtn.Text = "Valmis!" task.delay(1.5, function() if IsRunning and TPToMeBtn.Text == "Valmis!" then TPToMeBtn.Text = "TP to Me" end end) end
            end)
        else
            TPToMeBtn.Text = "Oma HRP puuttuu!"
            task.delay(1.5, function() if IsRunning and TPToMeBtn.Text == "Oma HRP puuttuu!" then TPToMeBtn.Text = "TP to Me" end end)
        end
    else
        TPToMeBtn.Text = "Ei löytynyt!"
        task.delay(1.5, function() if IsRunning and TPToMeBtn.Text == "Ei löytynyt!" then TPToMeBtn.Text = "TP to Me" end end)
    end
end

local function TeleportMeToPlayer()
    local targetPlayer = GetPlayerByString(WeldTextBox.Text)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        local myCharacter = LocalPlayer.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        
        if myHRP then
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 2, 3)
            TPToThemBtn.Text = "Kaukosiirretty!"
            task.delay(1.5, function() if IsRunning and TPToThemBtn.Text == "Kaukosiirretty!" then TPToThemBtn.Text = "TP to Them" end end)
        else
            TPToThemBtn.Text = "Oma HRP puuttuu!"
            task.delay(1.5, function() if IsRunning and TPToThemBtn.Text == "Oma HRP puuttuu!" then TPToThemBtn.Text = "TP to Them" end end)
        end
    else
        TPToThemBtn.Text = "Ei löytynyt!"
        task.delay(1.5, function() if IsRunning and TPToThemBtn.Text == "Ei löytynyt!" then TPToThemBtn.Text = "TP to Them" end end)
    end
end

local function UpdateSpinbotState()
    if not IsRunning then return end
    if Settings.Spin then
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not SpinBodyAngularVelocity or SpinBodyAngularVelocity.Parent ~= hrp then
                RemoveSpin()
                local attachment = hrp:FindFirstChild("SpinAttachment") or Instance.new("Attachment", hrp)
                attachment.Name = "SpinAttachment"
                SpinBodyAngularVelocity = Instance.new("AngularVelocity")
                SpinBodyAngularVelocity.Name = "SpinVelocity" SpinBodyAngularVelocity.Attachment0 = attachment SpinBodyAngularVelocity.MaxTorque = math.huge SpinBodyAngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.World SpinBodyAngularVelocity.Parent = hrp
                SpinBlockForce = Instance.new("BodyGyro")
                SpinBlockForce.Name = "SpinLock" SpinBlockForce.MaxTorque = Vector3.new(math.huge, 0, math.huge) SpinBlockForce.P = 500000 SpinBlockForce.CFrame = hrp.CFrame SpinBlockForce.Parent = hrp
            end
            SpinBodyAngularVelocity.AngularVelocity = Vector3.new(0, Settings.SpinSpeed, 0)
        end
    else RemoveSpin() end
end

local function ToggleESP() Settings.ESP = not Settings.ESP UpdateTexts() end
local function ToggleNoclip() Settings.Noclip = not Settings.Noclip UpdateTexts() end
local function ToggleAimbot() Settings.Aimbot = not Settings.Aimbot UpdateTexts() end
local function ToggleSpin() Settings.Spin = not Settings.Spin UpdateTexts() UpdateSpinbotState() end
local function ToggleWalkSpeed() Settings.WalkSpeedToggle = not Settings.WalkSpeedToggle UpdateTexts() end
local function ToggleJumpPower() Settings.JumpPowerToggle = not Settings.JumpPowerToggle UpdateTexts() end

local function ToggleFlight()
    Settings.Flight = not Settings.Flight UpdateTexts()
    if Settings.Flight then
        task.spawn(function()
            while Settings.Flight and IsRunning and task.wait() do
                if LocalPlayer.Character then
                    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    local targetPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("BasePart") then targetPart = humanoid.SeatPart end
                    if targetPart then
                        local moveDir = Vector3.new(0,0,0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                        if moveDir.Magnitude > 0 then targetPart.CFrame = targetPart.CFrame + (moveDir.Unit * (Settings.FlightSpeed / 10)) end
                        targetPart.AssemblyLinearVelocity = Vector3.new(0,0,0) targetPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    end
                end
            end
        end)
    end
end

local function DisableAll()
    Settings.ESP = false Settings.Noclip = false Settings.Aimbot = false Settings.Flight = false Settings.Spin = false Settings.WalkSpeedToggle = false Settings.JumpPowerToggle = false
    Settings.WalkSpeed = 16 Settings.JumpPower = 50 Settings.BangSpeed = 20 Settings.CharacterScale = 1
    RemoveSpin() UnweldPlayer() UpdateCharacterScale()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.UseJumpPower = true humanoid.JumpPower = 50 end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then local highlight = player.Character:FindFirstChildOfClass("Highlight") if highlight then highlight:Destroy() end end
    end
    if IsRunning then
        WSliderDot.Position = UDim2.new(0, -8, 0.5, -8) WSliderValueLabel.Text = "Walk Speed: 16"
        JSliderDot.Position = UDim2.new(0, -8, 0.5, -8) JSliderValueLabel.Text = "Jump Power: 50"
        BangSliderDot.Position = UDim2.new(0.333, -8, 0.5, -8) BangSliderValueLabel.Text = "Bang Speed: 20"
        SizeSliderDot.Position = UDim2.new(0.111, -8, 0.5, -8) SizeSliderValueLabel.Text = "Character Scale: 1.0x"
        CalcTextBox.Text = "" CalcResultLabel.Text = "Result: -" CalcResultLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        UpdateTexts()
    end
end

local function ShutDownGUI()
    IsRunning = false for _, connection in pairs(Connections) do if connection then connection:Disconnect() end end
    DisableAll() ScreenGui:Destroy()
end

ESPBtn.MouseButton1Click:Connect(ToggleESP)
NoclipBtn.MouseButton1Click:Connect(ToggleNoclip)
AimbotBtn.MouseButton1Click:Connect(ToggleAimbot)
FlightBtn.MouseButton1Click:Connect(ToggleFlight)
SpinBtn.MouseButton1Click:Connect(ToggleSpin)
WalkToggleBtn.MouseButton1Click:Connect(ToggleWalkSpeed)
JumpToggleBtn.MouseButton1Click:Connect(ToggleJumpPower)
WeldBtn.MouseButton1Click:Connect(WeldToMe)
BangBtn.MouseButton1Click:Connect(BangPlayer)
TPToMeBtn.MouseButton1Click:Connect(TeleportPlayerToMe)
TPToThemBtn.MouseButton1Click:Connect(TeleportMeToPlayer)
UnweldBtn.MouseButton1Click:Connect(UnweldPlayer)
DisableAllBtn.MouseButton1Click:Connect(DisableAll)
ShutDownBtn.MouseButton1Click:Connect(ShutDownGUI)

local listeningForBind = nil
local function RegisterBindChange(button, feature)
    button.MouseButton2Click:Connect(function() button.Text = "Paina näppäintä..." listeningForBind = feature end)
end
RegisterBindChange(ESPBtn, "ESP") RegisterBindChange(NoclipBtn, "Noclip") RegisterBindChange(AimbotBtn, "Aimbot") RegisterBindChange(FlightBtn, "Flight") RegisterBindChange(SpinBtn, "Spin") RegisterBindChange(WalkToggleBtn, "WalkSpeedToggle") RegisterBindChange(JumpToggleBtn, "JumpPowerToggle")

local function CheckBind(feature, input)
    local expected = GetUserInputTypeOrKeyCode(feature) if not expected then return false end
    if expected.ClassName == "UserInputType" then return input.UserInputType == expected else return input.KeyCode == expected end
end

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton3 and not listeningForBind then
        IsAtBottom = not IsAtBottom
        if IsAtBottom then
            local currentHeight = IsMinimized and 40 or FullSizeY
            MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1, -currentHeight - 40)
        else MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 0.1, 0) end
        return
    end
    if gameProcessed then return end
    if listeningForBind then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Backspace then Settings.Binds[listeningForBind] = "None" else Settings.Binds[listeningForBind] = input.KeyCode.Name end
            listeningForBind = nil UpdateTexts() SaveSettings() return
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            Settings.Binds[listeningForBind] = "MouseButton3" listeningForBind = nil UpdateTexts() SaveSettings() return
        end
    end
    if CheckBind("ESP", input) then ToggleESP() end
    if CheckBind("Noclip", input) then ToggleNoclip() end
    if CheckBind("Aimbot", input) then ToggleAimbot() end
    if CheckBind("Flight", input) then ToggleFlight() end
    if CheckBind("Spin", input) then ToggleSpin() end
    if CheckBind("WalkSpeedToggle", input) then ToggleWalkSpeed() end
    if CheckBind("JumpPowerToggle", input) then ToggleJumpPower() end
end))

table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) if IsRunning then UpdateSpinbotState() UpdateCharacterScale() end end))

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if IsRunning and LocalPlayer.Character then
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local targetSpeed = Settings.WalkSpeedToggle and Settings.WalkSpeed or 16
            if humanoid.WalkSpeed ~= targetSpeed then humanoid.WalkSpeed = targetSpeed end
            humanoid.UseJumpPower = true
            local targetJump = Settings.JumpPowerToggle and Settings.JumpPower or 50
            if humanoid.JumpPower ~= targetJump then humanoid.JumpPower = targetJump end
        end
        if Settings.BangActive and TargetBangPlayer and TargetBangPlayer.Character then
            local targetHRP = TargetBangPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then local timeScale = tick() * Settings.BangSpeed local moveOffset = math.sin(timeScale) * 6 myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1.5 + moveOffset) end
        elseif Settings.BangActive then UnweldPlayer() end
        if Settings.Spin and not SpinBodyAngularVelocity then UpdateSpinbotState() end
    end
end))

table.insert(Connections, RunService.Stepped:Connect(function()
    if (Settings.Noclip or Settings.BangActive) and IsRunning and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end))

local function IsVisible(targetPart)
    local character = LocalPlayer.Character if not character then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    local ray = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, raycastParams)
    return ray == nil
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not IsRunning then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if Settings.ESP then
                if not highlight then highlight = Instance.new("Highlight", player.Character) highlight.FillColor = Color3.fromRGB(255, 0, 0) end
            else if highlight then highlight:Destroy() end end
        end
    end
end))

local function GetClosestPlayer()
    local closest, shortest = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            if head and IsVisible(head) then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if dist < shortest then closest = head shortest = dist end
                end
            end
        end
    end
    return closest
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and IsRunning then local t = GetClosestPlayer() if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position) end end
end))

task.spawn(UpdateCharacterScale)

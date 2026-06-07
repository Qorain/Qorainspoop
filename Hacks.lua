local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local SAVE_FILE = "CheatMenu_Settings.json"

local Settings = {
    ESP = false,
    ESP_Boxes = true,
    ESP_Lines = true,
    ESP_TeamCheck = false,
    ESP_Color = Color3.fromRGB(255, 0, 50),
    
    Noclip = false,
    
    Aimbot = false,
    Aimbot_FOV = 100,
    Aimbot_Smoothness = 1,
    Aimbot_TargetPart = "Head",
    Aimbot_ShowFOV = true,
    
    Flight = false,
    FlightSpeed = 50,
    
    Spin = false,
    SpinSpeed = 100,
    
    WalkSpeedToggle = false,
    WalkSpeed = 16,
    
    JumpPowerToggle = false,
    JumpPower = 50,
    
    InvisMode = false,
    BangActive = false,
    BangSpeed = 20,
    CharacterScale = 1,
    Binds = {
        ESP = "F",
        Noclip = "V",
        Aimbot = "E",
        Flight = "G",
        Spin = "H",
        WalkSpeedToggle = "J",
        JumpPowerToggle = "K",
        InvisMode = "L"
    }
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

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
                ESP_Boxes = Settings.ESP_Boxes,
                ESP_Lines = Settings.ESP_Lines,
                ESP_TeamCheck = Settings.ESP_TeamCheck,
                Aimbot_FOV = Settings.Aimbot_FOV,
                Aimbot_Smoothness = Settings.Aimbot_Smoothness,
                Aimbot_TargetPart = Settings.Aimbot_TargetPart,
                Aimbot_ShowFOV = Settings.Aimbot_ShowFOV,
                Binds = Settings.Binds
            })
        end)
        if success then writefile(SAVE_FILE, encoded) end
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
            if decoded.ESP_Boxes ~= nil then Settings.ESP_Boxes = decoded.ESP_Boxes end
            if decoded.ESP_Lines ~= nil then Settings.ESP_Lines = decoded.ESP_Lines end
            if decoded.ESP_TeamCheck ~= nil then Settings.ESP_TeamCheck = decoded.ESP_TeamCheck end
            if decoded.Aimbot_FOV then Settings.Aimbot_FOV = decoded.Aimbot_FOV end
            if decoded.Aimbot_Smoothness then Settings.Aimbot_Smoothness = decoded.Aimbot_Smoothness end
            if decoded.Aimbot_TargetPart then Settings.Aimbot_TargetPart = decoded.Aimbot_TargetPart end
            if decoded.Aimbot_ShowFOV ~= nil then Settings.Aimbot_ShowFOV = decoded.Aimbot_ShowFOV end
            if decoded.Binds then
                for k, v in pairs(decoded.Binds) do Settings.Binds[k] = v end
            end
        end
    end
end

LoadSettings()

local function GetUserInputTypeOrKeyCode(bindName)
    local bind = Settings.Binds[bindName]
    if bind == "None" then return nil end
    return string.find(bind, "MouseButton") and Enum.UserInputType[bind] or Enum.KeyCode[bind]
end

local Connections = {}
local IsRunning = true
local SpinBodyAngularVelocity = nil
local SpinBlockForce = nil
local CurrentWeld = nil 
local IsMinimized = false
local FullSizeY = 480
local TargetBangPlayer = nil
local InvisClone = nil

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")

-- Luodaan uusi asetustiedostoikkuna (avautuu oikeaklikkauksella)
local SettingsFrame = Instance.new("Frame")
local SettingsTitle = Instance.new("TextLabel")
local SettingsCloseBtn = Instance.new("TextButton")
local SettingsScroll = Instance.new("ScrollingFrame")

ScreenGui.Name = "CheatMenu_Persistent"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Raahauslogiikka molemmille ikkunoille
local function MakeDraggable(frame)
    local dragToggle, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- PÄÄVALIKKO
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.75
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 200, 0, FullSizeY)
MainFrame.ClipsDescendants = true
MakeDraggable(MainFrame)

Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.BackgroundTransparency = 0.75
Title.Text = "  Paskaclient v3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = Title
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.BackgroundTransparency = 0.6
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    MainFrame.Size = IsMinimized and UDim2.new(0, 200, 0, 40) or UDim2.new(0, 200, 0, FullSizeY)
    MinimizeBtn.Text = IsMinimized and "+" or "-"
    if IsMinimized then SettingsFrame.Visible = false end
end)

ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

-- ERILLINEN ASETUSIKKUNA (Aukeaa sivulle)
SettingsFrame.Name = "SettingsFrame"
SettingsFrame.Parent = ScreenGui
SettingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SettingsFrame.BackgroundTransparency = 0.75
SettingsFrame.Position = UDim2.new(0.1, 210, 0.1, 0)
SettingsFrame.Size = UDim2.new(0, 200, 0, 250)
SettingsFrame.Visible = false
SettingsFrame.ClipsDescendants = true
MakeDraggable(SettingsFrame)

SettingsTitle.Name = "SettingsTitle"
SettingsTitle.Parent = SettingsFrame
SettingsTitle.Size = UDim2.new(1, 0, 0, 35)
SettingsTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsTitle.BackgroundTransparency = 0.75
SettingsTitle.Text = "  Asetukset"
SettingsTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
SettingsTitle.TextSize = 12
SettingsTitle.Font = Enum.Font.SourceSansBold
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left

SettingsCloseBtn.Name = "SettingsCloseBtn"
SettingsCloseBtn.Parent = SettingsTitle
SettingsCloseBtn.Size = UDim2.new(0, 25, 0, 25)
SettingsCloseBtn.Position = UDim2.new(1, -30, 0, 5)
SettingsCloseBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
SettingsCloseBtn.BackgroundTransparency = 0.6
SettingsCloseBtn.Text = "X"
SettingsCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsCloseBtn.TextSize = 12
SettingsCloseBtn.MouseButton1Click:Connect(function() SettingsFrame.Visible = false end)

SettingsScroll.Name = "SettingsScroll"
SettingsScroll.Parent = SettingsFrame
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.Position = UDim2.new(0, 0, 0, 35)
SettingsScroll.Size = UDim2.new(1, 0, 1, -35)
SettingsScroll.ScrollBarThickness = 4
SettingsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

-- APUFUNKTIOT ELEMENTEILLE
local function CreateButton(name, text, pos, parent, color)
    local btn = Instance.new("TextButton")
    btn.Name = name btn.Parent = parent btn.Size = UDim2.new(0, 180, 0, 35) btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    btn.BackgroundTransparency = 0.6
    btn.Text = text btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.TextSize = 12 btn.Font = Enum.Font.SourceSansBold
    return btn
end

local function CreateSubLabel(text, pos, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 180, 0, 15) lbl.Position = pos lbl.Parent = parent
    lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.fromRGB(200, 200, 200) lbl.TextSize = 11 lbl.Font = Enum.Font.SourceSans
    return lbl
end

local function CreateSlider(pos, parent, dotColor)
    local frame = Instance.new("Frame")
    local bar = Instance.new("Frame")
    local dot = Instance.new("TextButton")
    local label = Instance.new("TextLabel")
    
    frame.Size = UDim2.new(0, 180, 0, 40) frame.Position = pos frame.Parent = parent frame.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 15) label.BackgroundTransparency = 1 label.TextColor3 = Color3.fromRGB(255, 255, 255) label.TextSize = 11 label.Parent = frame
    bar.Size = UDim2.new(1, 0, 0, 4) bar.Position = UDim2.new(0, 0, 0, 22) bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80) bar.BackgroundTransparency = 0.6 bar.Parent = frame
    dot.Size = UDim2.new(0, 12, 0, 12) dot.BackgroundColor3 = dotColor dot.BackgroundTransparency = 0.6 dot.Text = "" dot.Parent = bar
    
    return dot, bar, label
end

-- --- PÄÄVALIKON ELEMENTIT ---
local mainY = 10
local ESPBtn = CreateButton("ESPBtn", "", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 40
local NoclipBtn = CreateButton("NoclipBtn", "", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 40
local AimbotBtn = CreateButton("AimbotBtn", "", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 40
local FlightBtn = CreateButton("FlightBtn", "", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 40
local SpinBtn = CreateButton("SpinBtn", "", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 40
local WalkToggleBtn = CreateButton("WalkToggleBtn", "", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 40
local JumpToggleBtn = CreateButton("JumpToggleBtn", "", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 40
local InvisBtn = CreateButton("InvisBtn", "", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 50

local InteractionLabel = CreateSubLabel("PLAYER INTERACTIONS", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 20
local WeldTextBox = Instance.new("TextBox")
WeldTextBox.Size = UDim2.new(0, 180, 0, 30) WeldTextBox.Position = UDim2.new(0, 10, 0, mainY) WeldTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45) WeldTextBox.BackgroundTransparency = 0.6 WeldTextBox.TextColor3 = Color3.fromRGB(255, 255, 255) WeldTextBox.TextSize = 14 WeldTextBox.PlaceholderText = "Username..." WeldTextBox.Parent = ScrollFrame mainY = mainY + 35

local WeldBtn = CreateButton("WeldBtn", "Weld to Me", UDim2.new(0, 10, 0, mainY), ScrollFrame, Color3.fromRGB(40, 100, 40)) mainY = mainY + 40
local BangBtn = CreateButton("BangBtn", "Bang Player", UDim2.new(0, 10, 0, mainY), ScrollFrame, Color3.fromRGB(110, 80, 30)) mainY = mainY + 40
local TPToMeBtn = CreateButton("TPToMeBtn", "TP to Me", UDim2.new(0, 10, 0, mainY), ScrollFrame, Color3.fromRGB(40, 80, 110)) mainY = mainY + 40
local TPToThemBtn = CreateButton("TPToThemBtn", "TP to Them", UDim2.new(0, 10, 0, mainY), ScrollFrame, Color3.fromRGB(90, 40, 110)) mainY = mainY + 40
local UnweldBtn = CreateButton("UnweldBtn", "Stop Weld / Bang", UDim2.new(0, 10, 0, mainY), ScrollFrame, Color3.fromRGB(100, 40, 40)) mainY = mainY + 50

local CalcLabel = CreateSubLabel("CALCULATOR", UDim2.new(0, 10, 0, mainY), ScrollFrame) mainY = mainY + 20
local CalcTextBox = Instance.new("TextBox")
CalcTextBox.Size = UDim2.new(0, 180, 0, 30) CalcTextBox.Position = UDim2.new(0, 10, 0, mainY) CalcTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45) CalcTextBox.BackgroundTransparency = 0.6 CalcTextBox.TextColor3 = Color3.fromRGB(255, 255, 255) CalcTextBox.TextSize = 14 CalcTextBox.PlaceholderText = "e.g. 50 * 2.5" CalcTextBox.Parent = ScrollFrame mainY = mainY + 35
local CalcResultLabel = Instance.new("TextLabel")
CalcResultLabel.Size = UDim2.new(0, 180, 0, 25) CalcResultLabel.Position = UDim2.new(0, 10, 0, mainY) CalcResultLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25) CalcResultLabel.BackgroundTransparency = 0.6 CalcResultLabel.TextColor3 = Color3.fromRGB(150, 255, 150) CalcResultLabel.TextSize = 13 CalcResultLabel.Text = "Result: -" CalcResultLabel.Parent = ScrollFrame mainY = mainY + 30
local CalcBtn = CreateButton("CalcBtn", "Calculate", UDim2.new(0, 10, 0, mainY), ScrollFrame, Color3.fromRGB(60, 80, 90)) mainY = mainY + 50

local DisableAllBtn = CreateButton("DisableAllBtn", "Disable All", UDim2.new(0, 10, 0, mainY), ScrollFrame, Color3.fromRGB(120, 40, 40)) mainY = mainY + 40
local ShutDownBtn = CreateButton("ShutDownBtn", "Shut Down GUI", UDim2.new(0, 10, 0, mainY), ScrollFrame, Color3.fromRGB(45, 45, 45)) mainY = mainY + 40

ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, mainY + 10)

-- --- SLIDERIEN HOOKKAUSFUNKTIO ---
local function HookSlider(dot, bar, label, prefix, min, max, settingKey, isFloat)
    local dragging = false
    local function update(input)
        local relativeX = input.Position.X - bar.AbsolutePosition.X
        local percentage = math.clamp(relativeX / bar.AbsoluteSize.X, 0, 1)
        dot.Position = UDim2.new(percentage, -6, 0.5, -6)
        local val = min + (percentage * (max - min))
        if not isFloat then val = math.floor(val) end
        Settings[settingKey] = val
        label.Text = prefix .. ": " .. (isFloat and string.format("%.1f", val) or tostring(val))
        SaveSettings()
    end
    dot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
    
    local startPercent = math.clamp((Settings[settingKey] - min) / (max - min), 0, 1)
    dot.Position = UDim2.new(startPercent, -6, 0.5, -6)
    label.Text = prefix .. ": " .. (isFloat and string.format("%.1f", Settings[settingKey]) or tostring(Settings[settingKey]))
end

-- --- DYNAAMINEN ASETUSIKKUNAN RAKENTAMINEN (OIKEAKLIKKAUS) ---
local function OpenSettingsFor(featureName)
    SettingsScroll:ClearAllChildren()
    SettingsTitle.Text = "  " .. featureName .. " Asetukset"
    
    local subY = 10
    
    if featureName == "ESP" then
        SettingsFrame.Size = UDim2.new(0, 200, 0, 180)
        local ESPBoxBtn = CreateButton("ESPBoxBtn", "", UDim2.new(0, 10, 0, subY), SettingsScroll) subY = subY + 40
        local ESPLineBtn = CreateButton("ESPLineBtn", "", UDim2.new(0, 10, 0, subY), SettingsScroll) subY = subY + 40
        local ESPTeamBtn = CreateButton("ESPTeamBtn", "", UDim2.new(0, 10, 0, subY), SettingsScroll) subY = subY + 40
        
        local function UpdateESPSub()
            ESPBoxBtn.Text = "Box: " .. (Settings.ESP_Boxes and "ON" or "OFF")
            ESPLineBtn.Text = "Line: " .. (Settings.ESP_Lines and "ON" or "OFF")
            ESPTeamBtn.Text = "Team Check: " .. (Settings.ESP_TeamCheck and "ON" or "OFF")
        end
        
        ESPBoxBtn.MouseButton1Click:Connect(function() Settings.ESP_Boxes = not Settings.ESP_Boxes SaveSettings() UpdateESPSub() end)
        ESPLineBtn.MouseButton1Click:Connect(function() Settings.ESP_Lines = not Settings.ESP_Lines SaveSettings() UpdateESPSub() end)
        ESPTeamBtn.MouseButton1Click:Connect(function() Settings.ESP_TeamCheck = not Settings.ESP_TeamCheck SaveSettings() UpdateESPSub() end)
        UpdateESPSub()
        
    elseif featureName == "Aimbot" then
        SettingsFrame.Size = UDim2.new(0, 200, 0, 230)
        local AimPartBtn = CreateButton("AimPartBtn", "Target: " .. Settings.Aimbot_TargetPart, UDim2.new(0, 10, 0, subY), SettingsScroll) subY = subY + 40
        local AimFOVBtn = CreateButton("AimFOVBtn", "Show FOV: " .. (Settings.Aimbot_ShowFOV and "ON" or "OFF"), UDim2.new(0, 10, 0, subY), SettingsScroll) subY = subY + 45
        
        AimPartBtn.MouseButton1Click:Connect(function()
            Settings.Aimbot_TargetPart = (Settings.Aimbot_TargetPart == "Head") and "HumanoidRootPart" or "Head"
            AimPartBtn.Text = "Target: " .. Settings.Aimbot_TargetPart
            SaveSettings()
        end)
        AimFOVBtn.MouseButton1Click:Connect(function()
            Settings.Aimbot_ShowFOV = not Settings.Aimbot_ShowFOV
            AimFOVBtn.Text = "Show FOV: " .. (Settings.Aimbot_ShowFOV and "ON" or "OFF")
            SaveSettings()
        end)
        
        local fovDot, fovBar, fovLabel = CreateSlider(UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(50, 150, 255)) subY = subY + 45
        local smDot, smBar, smLabel = CreateSlider(UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(150, 150, 255)) subY = subY + 45
        HookSlider(fovDot, fovBar, fovLabel, "Aimbot FOV", 10, 600, "Aimbot_FOV")
        HookSlider(smDot, smBar, smLabel, "Aimbot Smooth", 1, 20, "Aimbot_Smoothness")
        
    elseif featureName == "Flight" then
        SettingsFrame.Size = UDim2.new(0, 200, 0, 110)
        local flyDot, flyBar, flyLabel = CreateSlider(UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(200, 200, 200)) subY = subY + 45
        HookSlider(flyDot, flyBar, flyLabel, "Fly Speed", 10, 1000, "FlightSpeed")
        
    elseif featureName == "Spinbot" then
        SettingsFrame.Size = UDim2.new(0, 200, 0, 110)
        local spinDot, spinBar, spinLabel = CreateSlider(UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(200, 150, 255)) subY = subY + 45
        HookSlider(spinDot, spinBar, spinLabel, "Spin Speed", 10, 2500, "SpinSpeed")
        
    elseif featureName == "WalkSpeed" then
        SettingsFrame.Size = UDim2.new(0, 200, 0, 110)
        local wDot, wBar, wLabel = CreateSlider(UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(150, 200, 255)) subY = subY + 45
        HookSlider(wDot, wBar, wLabel, "Walk Speed", 1, 1000, "WalkSpeed")
        
    elseif featureName == "JumpPower" then
        SettingsFrame.Size = UDim2.new(0, 200, 0, 110)
        local jDot, jBar, jLabel = CreateSlider(UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(255, 200, 150)) subY = subY + 45
        HookSlider(jDot, jBar, jLabel, "Jump Power", 50, 1000, "JumpPower")
        
    elseif featureName == "Invis Mode" then
        SettingsFrame.Size = UDim2.new(0, 200, 0, 150)
        local scaleDot, scaleBar, scaleLabel = CreateSlider(UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(150, 255, 150)) subY = subY + 45
        HookSlider(scaleDot, scaleBar, scaleLabel, "Char Scale", 0.5, 5, "CharacterScale", true)
        local TPToolBtn = CreateButton("TPToolBtn", "Get TP Tool", UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(40, 90, 90)) subY = subY + 40
        TPToolBtn.MouseButton1Click:Connect(function()
            local tool = Instance.new("Tool") tool.Name = "Teleport Tool" tool.RequiresHandle = false
            tool.Activated:Connect(function()
                local mouse = LocalPlayer:GetMouse()
                if mouse and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end)
            tool.Parent = LocalPlayer:WaitForChild("Backpack")
        end)
        
    elseif featureName == "Bang Player" then
        SettingsFrame.Size = UDim2.new(0, 200, 0, 110)
        local bangDot, bangBar, bangLabel = CreateSlider(UDim2.new(0, 10, 0, subY), SettingsScroll, Color3.fromRGB(240, 180, 80)) subY = subY + 45
        HookSlider(bangDot, bangBar, bangLabel, "Bang Speed", 5, 50, "BangSpeed")
    else
        return -- Jos klikatulla nollalla ei ole asetuksia, ei avata mitään
    end
    
    SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, subY + 10)
    SettingsFrame.Visible = true
end

-- --- HOOKATAAN OIKEAKLIKKAUKSET (MouseButton2Click) ---
local function BindRightClick(button, featureName)
    button.MouseButton2Click:Connect(function()
        OpenSettingsFor(featureName)
    end)
end

BindRightClick(ESPBtn, "ESP")
BindRightClick(AimbotBtn, "Aimbot")
BindRightClick(FlightBtn, "Flight")
BindRightClick(SpinBtn, "Spinbot")
BindRightClick(WalkToggleBtn, "WalkSpeed")
BindRightClick(JumpToggleBtn, "JumpPower")
BindRightClick(InvisBtn, "Invis Mode")
BindRightClick(BangBtn, "Bang Player")


-- --- TEKSTIEN PÄIVITYKSET ---
local function UpdateTexts()
    if not IsRunning then return end 
    ESPBtn.Text = "ESP: " .. (Settings.ESP and "ON" or "OFF") .. " (" .. Settings.Binds.ESP .. ")"
    NoclipBtn.Text = "Noclip: " .. (Settings.Noclip and "ON" or "OFF") .. " (" .. Settings.Binds.Noclip .. ")"
    AimbotBtn.Text = "Aimbot: " .. (Settings.Aimbot and "ON" or "OFF") .. " (" .. Settings.Binds.Aimbot .. ")"
    FlightBtn.Text = "Flight: " .. (Settings.Flight and "ON" or "OFF") .. " (" .. Settings.Binds.Flight .. ")"
    SpinBtn.Text = "Spinbot: " .. (Settings.Spin and "ON" or "OFF") .. " (" .. Settings.Binds.Spin .. ")"
    WalkToggleBtn.Text = "WalkSpeed: " .. (Settings.WalkSpeedToggle and "ON" or "OFF") .. " (" .. Settings.Binds.WalkSpeedToggle .. ")"
    JumpToggleBtn.Text = "JumpPower: " .. (Settings.JumpPowerToggle and "ON" or "OFF") .. " (" .. Settings.Binds.JumpPowerToggle .. ")"
    InvisBtn.Text = "Invis Mode: " .. (Settings.InvisMode and "ON" or "OFF") .. " (" .. Settings.Binds.InvisMode .. ")"
end

-- --- ESP LOGIIKKA ---
local ActiveVisuals = {}
local function ClearVisuals()
    for _, vis in pairs(ActiveVisuals) do
        if vis.Box then vis.Box:Destroy() end
        if vis.Line then vis.Line:Destroy() end
    end
    table.clear(ActiveVisuals)
end

local function ConstructESP(player)
    if ActiveVisuals[player] then return end
    local container = { Box = Drawing.new("Square"), Line = Drawing.new("Line") }
    container.Box.Thickness = 1.5 container.Box.Filled = false container.Box.Visible = false
    container.Line.Thickness = 1.5 container.Line.Visible = false
    ActiveVisuals[player] = container
end

local function UpdateESPVisuals()
    if not Settings.ESP then ClearVisuals() return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if Settings.ESP_TeamCheck and p.Team == LocalPlayer.Team then
                if ActiveVisuals[p] then ActiveVisuals[p].Box.Visible = false ActiveVisuals[p].Line.Visible = false end
                continue
            end
            local char = p.Character local hrp = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                ConstructESP(p) local vis = ActiveVisuals[p]
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local scale = (1 / hrpPos.Z) * 1000 local boxWidth = 2.5 * scale local boxHeight = 4.5 * scale
                    if Settings.ESP_Boxes then
                        vis.Box.Size = Vector2.new(boxWidth, boxHeight) vis.Box.Position = Vector2.new(hrpPos.X - boxWidth/2, hrpPos.Y - boxHeight/2) vis.Box.Color = Settings.ESP_Color vis.Box.Visible = true
                    else vis.Box.Visible = false end
                    if Settings.ESP_Lines then
                        vis.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) vis.Line.To = Vector2.new(hrpPos.X, hrpPos.Y) vis.Line.Color = Settings.ESP_Color vis.Line.Visible = true
                    else vis.Line.Visible = false end
                else vis.Box.Visible = false vis.Line.Visible = false end
            else
                if ActiveVisuals[p] then ActiveVisuals[p].Box.Visible = false ActiveVisuals[p].Line.Visible = false end
            end
        end
    end
end

-- --- AIMBOT LOGIIKKA ---
local function GetClosestPlayerToMouse()
    local target = nil local maxDist = Settings.Aimbot_FOV local mousePos = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if Settings.ESP_TeamCheck and p.Team == LocalPlayer.Team then continue end
            local part = p.Character:FindFirstChild(Settings.Aimbot_TargetPart) local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < maxDist then maxDist = dist target = part end
                end
            end
        end
    end
    return target
end

local function RemoveSpin()
    if SpinBodyAngularVelocity then SpinBodyAngularVelocity:Destroy() SpinBodyAngularVelocity = nil end
    if SpinBlockForce then SpinBlockForce:Destroy() SpinBlockForce = nil end
end

local function UnweldPlayer()
    if CurrentWeld then CurrentWeld:Destroy() CurrentWeld = nil end
    Settings.BangActive = false TargetBangPlayer = nil
    if IsRunning then WeldBtn.Text = "Weld to Me" BangBtn.Text = "Bang Player" end
end

local function GetPlayerByString(text)
    local cleaned = string.lower(text)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.sub(string.lower(p.Name), 1, #cleaned) == cleaned then return p end
    end
    return nil
end

local function ToggleInvis()
    Settings.InvisMode = not Settings.InvisMode UpdateTexts()
    local char = LocalPlayer.Character if not char then return end
    if Settings.InvisMode then
        char:MoveTo(Vector3.new(char.PrimaryPart.Position.X, char.PrimaryPart.Position.Y + 99999, char.PrimaryPart.Position.Z))
        task.wait(0.2) local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            InvisClone = hrp:Clone() InvisClone.Name = "InvisRoot" InvisClone.Transparency = 0.5 InvisClone.Anchored = true InvisClone.Parent = workspace
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 1 elseif v:IsA("Decal") then v.Transparency = 1 end
            end
        end
    else
        if InvisClone then InvisClone:Destroy() InvisClone = nil end LocalPlayer:LoadCharacter()
    end
end

-- --- VASEN-KLIKKAUS LOGIIKKA (PÄÄTOIMINNOT) ---
ESPBtn.MouseButton1Click:Connect(function() Settings.ESP = not Settings.ESP UpdateTexts() end)
NoclipBtn.MouseButton1Click:Connect(function() Settings.Noclip = not Settings.Noclip UpdateTexts() end)
AimbotBtn.MouseButton1Click:Connect(function() Settings.Aimbot = not Settings.Aimbot UpdateTexts() end)
FlightBtn.MouseButton1Click:Connect(function() Settings.Flight = not Settings.Flight UpdateTexts() end)
SpinBtn.MouseButton1Click:Connect(function() Settings.Spin = not Settings.Spin UpdateTexts() if not Settings.Spin then RemoveSpin() end end)
WalkToggleBtn.MouseButton1Click:Connect(function() Settings.WalkSpeedToggle = not Settings.WalkSpeedToggle UpdateTexts() end)
JumpToggleBtn.MouseButton1Click:Connect(function() Settings.JumpPowerToggle = not Settings.JumpPowerToggle UpdateTexts() end)
InvisBtn.MouseButton1Click:Connect(ToggleInvis)

WeldBtn.MouseButton1Click:Connect(function()
    UnweldPlayer() local p = GetPlayerByString(WeldTextBox.Text)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
        CurrentWeld = Instance.new("WeldConstraint") CurrentWeld.Part0 = p.Character.HumanoidRootPart CurrentWeld.Part1 = LocalPlayer.Character.HumanoidRootPart CurrentWeld.Parent = p.Character.HumanoidRootPart
        WeldBtn.Text = "Hitsattu!"
    else WeldBtn.Text = "Virhe!" end
end)

BangBtn.MouseButton1Click:Connect(function()
    UnweldPlayer() local p = GetPlayerByString(WeldTextBox.Text)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then TargetBangPlayer = p Settings.BangActive = true BangBtn.Text = "Banging..." else BangBtn.Text = "Virhe!" end
end)

TPToMeBtn.MouseButton1Click:Connect(function()
    local p = GetPlayerByString(WeldTextBox.Text)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
    end
end)

TPToThemBtn.MouseButton1Click:Connect(function()
    local p = GetPlayerByString(WeldTextBox.Text)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,2,3)
    end
end)
UnweldBtn.MouseButton1Click:Connect(UnweldPlayer)

CalcBtn.MouseButton1Click:Connect(function()
    local cleaned = string.gsub(CalcTextBox.Text, "[^%d%.%+%-%*%/%^%(%)]", "") local func = loadstring("return " .. cleaned)
    if func then local success, result = pcall(func) if success and result then CalcResultLabel.Text = "Result: " .. tostring(result) return end end
    CalcResultLabel.Text = "Invalid Expression!"
end)

DisableAllBtn.MouseButton1Click:Connect(function()
    Settings.ESP = false Settings.Noclip = false Settings.Aimbot = false Settings.Flight = false Settings.Spin = false Settings.WalkSpeedToggle = false Settings.JumpPowerToggle = false Settings.InvisMode = false
    if InvisClone then InvisClone:Destroy() InvisClone = nil end UnweldPlayer() RemoveSpin() ClearVisuals() UpdateTexts() SettingsFrame.Visible = false
end)

ShutDownBtn.MouseButton1Click:Connect(function()
    IsRunning = false RemoveSpin() UnweldPlayer() ClearVisuals() FOVCircle:Destroy()
    if InvisClone then InvisClone:Destroy() InvisClone = nil end
    for _, c in pairs(Connections) do c:Disconnect() end ScreenGui:Destroy()
end)

-- --- RENDERING LOOP ---
table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not IsRunning then return end
    local char = LocalPlayer.Character local humanoid = char and char:FindFirstChildOfClass("Humanoid") local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    UpdateESPVisuals()
    
    if Settings.Aimbot and Settings.Aimbot_ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation() FOVCircle.Radius = Settings.Aimbot_FOV FOVCircle.Visible = true
    else FOVCircle.Visible = false end
    
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPart = GetClosestPlayerToMouse()
        if targetPart then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPart.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / Settings.Aimbot_Smoothness)
        end
    end
    
    if Settings.InvisMode and hrp and InvisClone then InvisClone.CFrame = hrp.CFrame end
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = (not Settings.Noclip and not Settings.InvisMode) or part.Name == "HumanoidRootPart" end
        end
    end
    if Settings.Flight and hrp and humanoid then
        local moveDir = humanoid.MoveDirection local flyVel = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyVel = flyVel + Vector3.new(0, Settings.FlightSpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then flyVel = flyVel - Vector3.new(0, Settings.FlightSpeed, 0) end
        hrp.Velocity = (moveDir * Settings.FlightSpeed) + flyVel
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end
    if humanoid then
        if Settings.WalkSpeedToggle then humanoid.WalkSpeed = Settings.WalkSpeed end
        if Settings.JumpPowerToggle then humanoid.JumpPower = Settings.JumpPower end
    end
    if Settings.Spin and hrp and not SpinBodyAngularVelocity then
        local attachment = hrp:FindFirstChild("SpinAttachment") or Instance.new("Attachment", hrp) attachment.Name = "SpinAttachment"
        SpinBodyAngularVelocity = Instance.new("AngularVelocity") SpinBodyAngularVelocity.Attachment0 = attachment SpinBodyAngularVelocity.MaxTorque = math.huge SpinBodyAngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.World SpinBodyAngularVelocity.Parent = hrp
        SpinBlockForce = Instance.new("BodyGyro") SpinBlockForce.MaxTorque = Vector3.new(math.huge, 0, math.huge) SpinBlockForce.P = 500000 SpinBlockForce.CFrame = hrp.CFrame SpinBlockForce.Parent = hrp
    end
    if SpinBodyAngularVelocity then SpinBodyAngularVelocity.AngularVelocity = Vector3.new(0, Settings.SpinSpeed, 0) end
    if Settings.BangActive and TargetBangPlayer and TargetBangPlayer.Character and TargetBangPlayer.Character:FindFirstChild("HumanoidRootPart") and hrp then
        hrp.CFrame = TargetBangPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1 + (math.sin(tick() * Settings.BangSpeed) * 2))
    elseif Settings.BangActive then UnweldPlayer() end
end))

Players.PlayerRemoving:Connect(function(p) if ActiveVisuals[p] then ActiveVisuals[p].Box:Destroy() ActiveVisuals[p].Line:Destroy() ActiveVisuals[p] = nil end end)

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == GetUserInputTypeOrKeyCode("ESP") then Settings.ESP = not Settings.ESP UpdateTexts()
    elseif input.KeyCode == GetUserInputTypeOrKeyCode("Noclip") then Settings.Noclip = not Settings.Noclip UpdateTexts()
    elseif input.KeyCode == GetUserInputTypeOrKeyCode("Aimbot") then Settings.Aimbot = not Settings.Aimbot UpdateTexts()
    elseif input.KeyCode == GetUserInputTypeOrKeyCode("Flight") then Settings.Flight = not Settings.Flight UpdateTexts()
    elseif input.KeyCode == GetUserInputTypeOrKeyCode("Spin") then Settings.Spin = not Settings.Spin UpdateTexts() if not Settings.Spin then RemoveSpin() end
    elseif input.KeyCode == GetUserInputTypeOrKeyCode("WalkSpeedToggle") then Settings.WalkSpeedToggle = not Settings.WalkSpeedToggle UpdateTexts()
    elseif input.KeyCode == GetUserInputTypeOrKeyCode("JumpPowerToggle") then Settings.JumpPowerToggle = not Settings.JumpPowerToggle UpdateTexts()
    elseif input.KeyCode == GetUserInputTypeOrKeyCode("InvisMode") then ToggleInvis() end
end))

UpdateTexts()

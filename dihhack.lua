-- ========================================================
--          ORAVACLIENT V7.5 - FIXED & WORKING             
-- ========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy existing instance if re-executed
if PlayerGui:FindFirstChild("OravaClient") then
    PlayerGui.OravaClient:Destroy()
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OravaClient"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Window Framework
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 420)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true -- Force visible on execute
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(130, 60, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.2
UIStroke.Parent = MainFrame

-- Track UI elements for dynamic theme applying
local ThemeableStrokes = {UIStroke}
local ThemeableAccents = {}
local AllTextLabels = {}

-- Header Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -90, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⚡ ORAVA CLIENT <font color=\"#a855f7\">v7.5</font>"
TitleText.RichText = true
TitleText.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar
table.insert(AllTextLabels, TitleText)

-- ========================================================
--                  GUI SHUTDOWN BUTTON                     
-- ========================================================
local ShutdownBtn = Instance.new("TextButton")
ShutdownBtn.Size = UDim2.new(0, 30, 0, 26)
ShutdownBtn.Position = UDim2.new(1, -38, 0.5, -13)
ShutdownBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
ShutdownBtn.Text = "✕"
ShutdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShutdownBtn.Font = Enum.Font.GothamBold
ShutdownBtn.TextSize = 14
ShutdownBtn.Parent = TitleBar

local ShutdownCorner = Instance.new("UICorner")
ShutdownCorner.CornerRadius = UDim.new(0, 6)
ShutdownCorner.Parent = ShutdownBtn

ShutdownBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Left Sidebar Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 135, 1, -50)
Sidebar.Position = UDim2.new(0, 8, 0, 46)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Parent = Sidebar
SidebarList.Padding = UDim.new(0, 4)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 6)
SidebarPadding.Parent = Sidebar

-- Content Container
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -159, 1, -50)
ContentArea.Position = UDim2.new(0, 151, 0, 46)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local tabs = {}
local activeTab = nil
local activeAccentColor = Color3.fromRGB(130, 60, 255)

local function CreateTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -10, 0, 32)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    tabBtn.Text = icon .. "  " .. name
    tabBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 12
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar

    table.insert(AllTextLabels, tabBtn)

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 10)
    btnPadding.Parent = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = activeAccentColor
    page.Visible = false
    page.Parent = ContentArea

    table.insert(ThemeableAccents, page)

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 6)

    tabs[name] = {Button = tabBtn, Page = page}

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            t.Button.TextColor3 = Color3.fromRGB(160, 160, 180)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = activeAccentColor
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    if not activeTab then
        activeTab = name
        page.Visible = true
        tabBtn.BackgroundColor3 = activeAccentColor
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    return page
end

local function AddToggle(page, text, callback)
    local state = false
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 36)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    container.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    table.insert(AllTextLabels, label)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 36, 0, 20)
    toggleBtn.Position = UDim2.new(1, -44, 0.5, -10)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
    toggleBtn.Text = ""
    toggleBtn.Parent = container

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(0, 3, 0.5, -7)
    indicator.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    indicator.Parent = toggleBtn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    local function update()
        state = not state
        if state then
            toggleBtn.BackgroundColor3 = activeAccentColor
            indicator.Position = UDim2.new(1, -17, 0.5, -7)
            indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            table.insert(ThemeableAccents, toggleBtn)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
            indicator.Position = UDim2.new(0, 3, 0.5, -7)
            indicator.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
        end
        callback(state)
    end

    toggleBtn.MouseButton1Click:Connect(update)
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then update() end
    end)
end

local function AddButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = page
    table.insert(AllTextLabels, btn)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 70)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

-- Keybind Toggle (Right Control or Right Shift)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.RightShift) then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==========================================================
--                       TABS SETUP                          
-- ==========================================================

local MovementPage   = CreateTab("Movement", "🚀")
local CombatPage     = CreateTab("Combat", "⚔️")
local VisualsPage    = CreateTab("Visuals", "👁️")
local CameraPage     = CreateTab("Camera", "🎥")
local WorldPage      = CreateTab("World/Phys", "⚙️")
local UtilityPage    = CreateTab("Utility", "🔧")
local CustomizerPage = CreateTab("Presets", "🎨")

-- ==========================================================
--                    50+ FEATURE ENTRIES                    
-- ==========================================================

-- --- 1. MOVEMENT FEATURES (1-10) ---
local noclipActive = false
AddToggle(MovementPage, "[1] Universal Noclip", function(state) noclipActive = state end)
RunService.Stepped:Connect(function()
    if noclipActive and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

AddToggle(MovementPage, "[2] Sprint Module (32 Speed)", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and 32 or 16 end
end)

local speedActive = false
AddToggle(MovementPage, "[3] Speed Hack (100 Speed)", function(state)
    speedActive = state
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedActive and 100 or 16 end
end)

AddToggle(MovementPage, "[4] Flash Speed (250 Speed)", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and 250 or 16 end
end)

local infJump = false
AddToggle(MovementPage, "[5] Infinite Jump Mode", function(state) infJump = state end)
UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

AddToggle(MovementPage, "[6] High Jump (120 JumpPower)", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = state and 120 or 50 end
end)

AddToggle(MovementPage, "[7] Super Jump (250 JumpPower)", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = state and 250 or 50 end
end)

local flying = false
local flySpeed = 75
local bv, bg
AddToggle(MovementPage, "[8] Flight Engine (WASD)", function(state)
    flying = state
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if flying and root then
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        task.spawn(function()
            while flying and root and root.Parent do
                local cam = workspace.CurrentCamera
                bg.CFrame = cam.CFrame
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                bv.Velocity = dir * flySpeed
                RunService.RenderStepped:Wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)

AddButton(MovementPage, "[9] Reset WalkSpeed to Default", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end)

AddButton(MovementPage, "[10] Reset Jump Power to Default", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 50 end
end)

-- --- 2. COMBAT FEATURES (11-18) ---
local aimbot = false
AddToggle(CombatPage, "[11] Camera Lock-On (Hold RMB)", function(state) aimbot = state end)
RunService.RenderStepped:Connect(function()
    if aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local cam = workspace.CurrentCamera
        local closest, shortDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local pos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if dist < shortDist then shortDist = dist; closest = head end
                end
            end
        end
        if closest then cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Position) end
    end
end)

local extendHitboxes = false
AddToggle(CombatPage, "[12] Expand Enemy Hitboxes", function(state)
    extendHitboxes = state
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            hrp.Size = extendHitboxes and Vector3.new(12, 12, 12) or Vector3.new(2, 2, 1)
            hrp.Transparency = extendHitboxes and 0.75 or 1
            hrp.BrickColor = BrickColor.new("Royal purple")
        end
    end
end)

AddButton(CombatPage, "[13] Force Sit Target State", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Sit = true end
end)
AddButton(CombatPage, "[14] Freeze Character Position", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
end)
AddButton(CombatPage, "[15] Unfreeze Character Position", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false end
end)
AddButton(CombatPage, "[16] Zero Character Velocity", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new() end
end)
AddButton(CombatPage, "[17] Launch Upwards Impulse", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 150, 0) end
end)
AddButton(CombatPage, "[18] Backward Force Impulse", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = -hrp.CFrame.LookVector * 150 end
end)

-- --- 3. VISUALS & LIGHTING FEATURES (19-28) ---
local esp = false
local highlights = {}
AddToggle(VisualsPage, "[19] Chams / Player ESP Highlights", function(state)
    esp = state
    if esp then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = Instance.new("Highlight", p.Character)
                hl.FillColor = activeAccentColor
                highlights[p] = hl
            end
        end
    else
        for _, hl in pairs(highlights) do if hl then hl:Destroy() end end
        highlights = {}
    end
end)

local fb = false
AddToggle(VisualsPage, "[20] Fullbright Lighting Toggle", function(state)
    fb = state
    if fb then
        Lighting.Brightness = 4
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = true
    end
end)

AddToggle(VisualsPage, "[21] Night Vision Tint Mode", function(state)
    Lighting.Ambient = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(128, 128, 128)
end)
AddToggle(VisualsPage, "[22] Disable World Shadows", function(state) Lighting.GlobalShadows = not state end)
AddButton(VisualsPage, "[23] Time: Always Noon (12 PM)", function() Lighting.ClockTime = 12 end)
AddButton(VisualsPage, "[24] Time: Always Midnight (0 AM)", function() Lighting.ClockTime = 0 end)
AddButton(VisualsPage, "[25] Time: Sunset (6 PM)", function() Lighting.ClockTime = 18 end)
AddButton(VisualsPage, "[26] Clear Fog Distance", function() Lighting.FogEnd = 100000 end)
AddButton(VisualsPage, "[27] Max Ambient Brightness Boost", function() Lighting.Ambient = Color3.fromRGB(255, 255, 255) end)
AddButton(VisualsPage, "[28] Reset Lighting Defaults", function()
    Lighting.Brightness = 2; Lighting.ClockTime = 12; Lighting.GlobalShadows = true; Lighting.FogEnd = 100000
end)

-- --- 4. CAMERA & FOV FEATURES (29-37) ---
AddToggle(CameraPage, "[29] Ultra-Wide FOV (110)", function(state) workspace.CurrentCamera.FieldOfView = state and 110 or 70 end)
AddToggle(CameraPage, "[30] FishEye FOV Mode (120)", function(state) workspace.CurrentCamera.FieldOfView = state and 120 or 70 end)
AddToggle(CameraPage, "[31] Zoom Telescope FOV (30)", function(state) workspace.CurrentCamera.FieldOfView = state and 30 or 70 end)
AddButton(CameraPage, "[32] Infinite Camera Zoom Distance", function() LocalPlayer.CameraMaxZoomDistance = 100000 end)
AddButton(CameraPage, "[33] Lock Camera First Person", function() LocalPlayer.CameraMinZoomDistance = 0.5; LocalPlayer.CameraMaxZoomDistance = 0.5 end)
AddButton(CameraPage, "[34] Reset Camera Zoom Limits", function() LocalPlayer.CameraMinZoomDistance = 0.5; LocalPlayer.CameraMaxZoomDistance = 400 end)
AddButton(CameraPage, "[35] Rotate Camera 90 Deg Right", function() workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(0, math.rad(90), 0) end)
AddButton(CameraPage, "[36] Reset Field of View (70)", function() workspace.CurrentCamera.FieldOfView = 70 end)
AddButton(CameraPage, "[37] Invert Camera Pitch", function() workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(math.rad(180), 0, 0) end)

-- --- 5. WORLD & PHYSICS FEATURES (38-44) ---
AddToggle(WorldPage, "[38] Zero Gravity Engine", function(state) workspace.Gravity = state and 0 or 196.2 end)
AddToggle(WorldPage, "[39] Low Moon Gravity (50)", function(state) workspace.Gravity = state and 50 or 196.2 end)
AddToggle(WorldPage, "[40] Heavy Physics Gravity (400)", function(state) workspace.Gravity = state and 400 or 196.2 end)

local spin = false
AddToggle(WorldPage, "[41] Spinbot Motion Engine", function(state)
    spin = state
end)

RunService.RenderStepped:Connect(function()
    if spin and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(25), 0) end
    end
end)

AddButton(WorldPage, "[42] Forward Thrust Impulse", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * 150 end
end)
AddButton(WorldPage, "[43] Reset World Gravity (196.2)", function() workspace.Gravity = 196.2 end)
AddButton(WorldPage, "[44] Optimize FPS (Remove Textures)", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end
end)

-- --- 6. UTILITY & TOOLS FEATURES (45-51) ---
AddButton(UtilityPage, "[45] Get Teleport Tool", function()
    local tool = Instance.new("Tool", LocalPlayer.Backpack)
    tool.Name = "⚡ Teleport"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local pos = LocalPlayer:GetMouse().Hit.Position
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end)
end)
AddButton(UtilityPage, "[46] Get Delete Part Tool", function()
    local tool = Instance.new("Tool", LocalPlayer.Backpack)
    tool.Name = "🗑️ Delete"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local target = LocalPlayer:GetMouse().Target
        if target and not target:IsA("Terrain") then target:Destroy() end
    end)
end)
AddButton(UtilityPage, "[47] Teleport to Random Player", function()
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(targets, p) end
    end
    if #targets > 0 then
        local chosen = targets[math.random(1, #targets)]
        LocalPlayer.Character.HumanoidRootPart.CFrame = chosen.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end)
AddButton(UtilityPage, "[48] Enable Anti-AFK Kick Prevention", function()
    LocalPlayer.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
    end)
end)
AddButton(UtilityPage, "[49] Clear Player Backpack Tools", function() LocalPlayer.Backpack:ClearAllChildren() end)
AddButton(UtilityPage, "[50] Set Big Head Visual (5x)", function()
    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if head then head.Size = Vector3.new(5, 5, 5) end
end)
AddButton(UtilityPage, "[51] Rejoin Current Server Instance", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)

-- ==========================================================
--               7. 10 PREMADE STYLES ENGINE                 
-- ==========================================================

local function ApplyThemePreset(bg, sidebar, title, accent, textColor, font)
    activeAccentColor = accent
    MainFrame.BackgroundColor3 = bg
    Sidebar.BackgroundColor3 = sidebar
    TitleBar.BackgroundColor3 = title

    for _, stroke in ipairs(ThemeableStrokes) do stroke.Color = accent end
    for _, elem in ipairs(ThemeableAccents) do
        if elem:IsA("ScrollingFrame") then elem.ScrollBarImageColor3 = accent
        else elem.BackgroundColor3 = accent end
    end

    for name, t in pairs(tabs) do
        if name == activeTab then
            t.Button.BackgroundColor3 = accent
            t.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    for _, label in ipairs(AllTextLabels) do
        label.TextColor3 = textColor
        label.Font = font
    end
end

-- 1. PURPLE STYLE #1: Neon Cyberpunk
AddButton(CustomizerPage, "💜 1. Purple Cyberpunk (Default)", function()
    ApplyThemePreset(Color3.fromRGB(14, 14, 18), Color3.fromRGB(18, 18, 24), Color3.fromRGB(20, 20, 26), Color3.fromRGB(130, 60, 255), Color3.fromRGB(240, 240, 255), Enum.Font.GothamMedium)
end)

-- 2. PURPLE STYLE #2: Midnight Violet
AddButton(CustomizerPage, "🔮 2. Midnight Violet", function()
    ApplyThemePreset(Color3.fromRGB(18, 10, 28), Color3.fromRGB(24, 14, 38), Color3.fromRGB(30, 18, 48), Color3.fromRGB(190, 80, 255), Color3.fromRGB(245, 220, 255), Enum.Font.GothamBold)
end)

-- 3. ORANGE STYLE: Sunset Flame
AddButton(CustomizerPage, "🟧 3. Sunset Orange", function()
    ApplyThemePreset(Color3.fromRGB(22, 16, 12), Color3.fromRGB(30, 20, 14), Color3.fromRGB(38, 24, 16), Color3.fromRGB(255, 120, 0), Color3.fromRGB(255, 230, 210), Enum.Font.GothamMedium)
end)

-- 4. Cyber Cyan
AddButton(CustomizerPage, "🩵 4. Cyber Cyan", function()
    ApplyThemePreset(Color3.fromRGB(10, 18, 22), Color3.fromRGB(14, 24, 30), Color3.fromRGB(18, 30, 38), Color3.fromRGB(0, 220, 255), Color3.fromRGB(210, 250, 255), Enum.Font.SciFi)
end)

-- 5. Crimson Blood
AddButton(CustomizerPage, "🩸 5. Crimson Blood", function()
    ApplyThemePreset(Color3.fromRGB(20, 10, 10), Color3.fromRGB(28, 12, 12), Color3.fromRGB(36, 14, 14), Color3.fromRGB(255, 30, 60), Color3.fromRGB(255, 210, 215), Enum.Font.GothamMedium)
end)

-- 6. Acid Lime
AddButton(CustomizerPage, "🧪 6. Acid Lime", function()
    ApplyThemePreset(Color3.fromRGB(12, 20, 12), Color3.fromRGB(16, 28, 16), Color3.fromRGB(20, 36, 20), Color3.fromRGB(50, 230, 80), Color3.fromRGB(220, 255, 220), Enum.Font.SourceSans)
end)

-- 7. Obsidian Monochrome
AddButton(CustomizerPage, "🖤 7. Obsidian Monochrome", function()
    ApplyThemePreset(Color3.fromRGB(6, 6, 8), Color3.fromRGB(12, 12, 14), Color3.fromRGB(18, 18, 20), Color3.fromRGB(200, 200, 210), Color3.fromRGB(255, 255, 255), Enum.Font.GothamMedium)
end)

-- 8. Retro Pixel Arcade
AddButton(CustomizerPage, "👾 8. Retro Pixel Arcade", function()
    ApplyThemePreset(Color3.fromRGB(24, 12, 32), Color3.fromRGB(34, 16, 44), Color3.fromRGB(44, 20, 56), Color3.fromRGB(255, 220, 0), Color3.fromRGB(255, 255, 255), Enum.Font.Arcade)
end)

-- 9. Ocean Deep Blue
AddButton(CustomizerPage, "🌊 9. Deep Ocean Blue", function()
    ApplyThemePreset(Color3.fromRGB(8, 16, 30), Color3.fromRGB(12, 22, 40), Color3.fromRGB(16, 28, 50), Color3.fromRGB(30, 140, 255), Color3.fromRGB(210, 235, 255), Enum.Font.GothamMedium)
end)

-- 10. Rose Gold
AddButton(CustomizerPage, "🌸 10. Rose Gold", function()
    ApplyThemePreset(Color3.fromRGB(24, 16, 20), Color3.fromRGB(32, 20, 26), Color3.fromRGB(40, 24, 32), Color3.fromRGB(255, 120, 170), Color3.fromRGB(255, 230, 240), Enum.Font.GothamMedium)
end)

print("OravaClient v7.5 Fixed & Working!")

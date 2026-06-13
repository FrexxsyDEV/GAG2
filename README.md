-- GUI optimizado para móvil
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Crear el ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- ========== BOTÓN FLOTANTE (aparece al minimizar) ==========
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Position = UDim2.new(0.85, 0, 0.85, 0)
FloatingButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FloatingButton.BackgroundTransparency = 1
FloatingButton.Text = "X"
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.TextSize = 24
FloatingButton.Font = Enum.Font.SourceSansBold
FloatingButton.Visible = false
FloatingButton.AutoButtonColor = false
FloatingButton.Parent = ScreenGui

-- Borde del botón flotante
local FloatingBorder = Instance.new("Frame")
FloatingBorder.Size = UDim2.new(1, 10, 1, 10)
FloatingBorder.Position = UDim2.new(0, -5, 0, -5)
FloatingBorder.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FloatingBorder.BackgroundTransparency = 0.8
FloatingBorder.BorderSizePixel = 0
FloatingBorder.ZIndex = 0
FloatingBorder.Parent = FloatingButton

local FloatingInner = Instance.new("Frame")
FloatingInner.Size = UDim2.new(1, -10, 1, -10)
FloatingInner.Position = UDim2.new(0, 5, 0, 5)
FloatingInner.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FloatingInner.BorderSizePixel = 0
FloatingInner.Parent = FloatingButton

local FloatingText = Instance.new("TextLabel")
FloatingText.Size = UDim2.new(1, 0, 1, 0)
FloatingText.BackgroundTransparency = 1
FloatingText.Text = "XENO"
FloatingText.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingText.TextSize = 14
FloatingText.Font = Enum.Font.SourceSansBold
FloatingText.Parent = FloatingInner

-- Hacer el botón flotante movible en móvil
local floatingDragging = false
local floatingDragStart = nil
local floatingStartPos = nil

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        floatingDragging = true
        floatingDragStart = input.Position
        floatingStartPos = FloatingButton.Position
    end
end)

FloatingButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        floatingDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if floatingDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - floatingDragStart
        local newX = floatingStartPos.X.Offset + delta.X
        local newY = floatingStartPos.Y.Offset + delta.Y
        
        -- Limitar a los bordes de la pantalla
        local maxX = game:GetService("GuiService").ScreenResolution.X - FloatingButton.AbsoluteSize.X
        local maxY = game:GetService("GuiService").ScreenResolution.Y - FloatingButton.AbsoluteSize.Y
        newX = math.clamp(newX, 0, maxX)
        newY = math.clamp(newY, 0, maxY)
        
        FloatingButton.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- ========== VENTANA PRINCIPAL ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Sombra
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.5
Shadow.BorderSizePixel = 0
Shadow.Parent = MainFrame

-- Barra de título (más grande para móvil)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "XENO GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.Parent = TitleBar

-- Botón minimizar (en la ventana)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 50, 1, 0)
MinimizeButton.Position = UDim2.new(1, -55, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 30
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = TitleBar

-- Contenedor de contenido (scrollable para móvil)
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, 0, 1, -50)
ContentContainer.Position = UDim2.new(0, 0, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ScrollBarThickness = 5
ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 350)
ContentContainer.Parent = MainFrame

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 15)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Parent = ContentContainer

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 15)
ContentPadding.PaddingBottom = UDim.new(0, 15)
ContentPadding.Parent = ContentContainer

-- Variables
local minimized = false
local dragging = false
local dragStart = nil
local startPos = nil
local flyEnabled = false
local flyBodyVelocity = nil
local flyConnection = nil

-- Función para mover la ventana (táctil)
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Función para minimizar/restaurar
local function Minimize()
    minimized = true
    MainFrame.Visible = false
    FloatingButton.Visible = true
    FloatingButton.BackgroundTransparency = 0
    TweenService:Create(FloatingButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end

local function Restore()
    minimized = false
    MainFrame.Visible = true
    FloatingButton.Visible = false
    FloatingButton.BackgroundTransparency = 1
end

MinimizeButton.MouseButton1Click:Connect(Minimize)
MinimizeButton.TouchTap:Connect(Minimize)

FloatingButton.MouseButton1Click:Connect(Restore)
FloatingButton.TouchTap:Connect(Restore)

-- ========== WALKSPEED (móvil) ==========
local WalkspeedCard = Instance.new("Frame")
WalkspeedCard.Size = UDim2.new(0, 310, 0, 80)
WalkspeedCard.Position = UDim2.new(0.5, -155, 0, 0)
WalkspeedCard.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
WalkspeedCard.BorderSizePixel = 0
WalkspeedCard.Parent = ContentContainer

local WalkspeedLabel = Instance.new("TextLabel")
WalkspeedLabel.Size = UDim2.new(1, 0, 0, 30)
WalkspeedLabel.BackgroundTransparency = 1
WalkspeedLabel.Text = "🏃 Walkspeed: 16"
WalkspeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkspeedLabel.TextSize = 18
WalkspeedLabel.Font = Enum.Font.SourceSansBold
WalkspeedLabel.Parent = WalkspeedCard

local WalkspeedValue = Instance.new("TextBox")
WalkspeedValue.Size = UDim2.new(0, 80, 0, 35)
WalkspeedValue.Position = UDim2.new(1, -90, 0, 35)
WalkspeedValue.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
WalkspeedValue.Text = "16"
WalkspeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkspeedValue.TextSize = 18
WalkspeedValue.Font = Enum.Font.SourceSans
WalkspeedValue.Parent = WalkspeedCard

local WalkspeedSliderBar = Instance.new("Frame")
WalkspeedSliderBar.Size = UDim2.new(1, -100, 0, 6)
WalkspeedSliderBar.Position = UDim2.new(0, 0, 0, 45)
WalkspeedSliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
WalkspeedSliderBar.Parent = WalkspeedCard

local WalkspeedFill = Instance.new("Frame")
WalkspeedFill.Size = UDim2.new(0.16, 0, 1, 0)
WalkspeedFill.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
WalkspeedFill.Parent = WalkspeedSliderBar

local WalkspeedButton = Instance.new("TextButton")
WalkspeedButton.Size = UDim2.new(0, 25, 0, 25)
WalkspeedButton.Position = UDim2.new(0.16, -12, -0.5, 0)
WalkspeedButton.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
WalkspeedButton.Text = ""
WalkspeedButton.AutoButtonColor = false
WalkspeedButton.Parent = WalkspeedSliderBar

-- Slider táctil
local function updateWalkspeed(percent)
    percent = math.clamp(percent, 0, 1)
    local value = math.floor(percent * 100)
    WalkspeedFill.Size = UDim2.new(percent, 0, 1, 0)
    WalkspeedButton.Position = UDim2.new(percent, -12, -0.5, 0)
    WalkspeedValue.Text = tostring(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
    WalkspeedLabel.Text = "🏃 Walkspeed: " .. value
end

WalkspeedSliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local percent = (input.Position.X - WalkspeedSliderBar.AbsolutePosition.X) / WalkspeedSliderBar.AbsoluteSize.X
        updateWalkspeed(percent)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragging == false then
        if WalkspeedSliderBar and input.Position.X >= WalkspeedSliderBar.AbsolutePosition.X and input.Position.X <= WalkspeedSliderBar.AbsolutePosition.X + WalkspeedSliderBar.AbsoluteSize.X then
            local percent = (input.Position.X - WalkspeedSliderBar.AbsolutePosition.X) / WalkspeedSliderBar.AbsoluteSize.X
            updateWalkspeed(percent)
        end
    end
end)

WalkspeedValue.FocusLost:Connect(function()
    local num = tonumber(WalkspeedValue.Text)
    if num then
        num = math.clamp(num, 16, 250)
        updateWalkspeed(num / 100)
    else
        updateWalkspeed(0.16)
    end
end)

-- ========== JUMP POWER (móvil) ==========
local JumpCard = Instance.new("Frame")
JumpCard.Size = UDim2.new(0, 310, 0, 80)
JumpCard.Position = UDim2.new(0.5, -155, 0, 0)
JumpCard.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
JumpCard.BorderSizePixel = 0
JumpCard.Parent = ContentContainer

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, 0, 0, 30)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "🦘 Jump Power: 50"
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpLabel.TextSize = 18
JumpLabel.Font = Enum.Font.SourceSansBold
JumpLabel.Parent = JumpCard

local JumpValue = Instance.new("TextBox")
JumpValue.Size = UDim2.new(0, 80, 0, 35)
JumpValue.Position = UDim2.new(1, -90, 0, 35)
JumpValue.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
JumpValue.Text = "50"
JumpValue.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpValue.TextSize = 18
JumpValue.Font = Enum.Font.SourceSans
JumpValue.Parent = JumpCard

local JumpSliderBar = Instance.new("Frame")
JumpSliderBar.Size = UDim2.new(1, -100, 0, 6)
JumpSliderBar.Position = UDim2.new(0, 0, 0, 45)
JumpSliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
JumpSliderBar.Parent = JumpCard

local JumpFill = Instance.new("Frame")
JumpFill.Size = UDim2.new(0.2, 0, 1, 0)
JumpFill.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
JumpFill.Parent = JumpSliderBar

local JumpButton = Instance.new("TextButton")
JumpButton.Size = UDim2.new(0, 25, 0, 25)
JumpButton.Position = UDim2.new(0.2, -12, -0.5, 0)
JumpButton.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
JumpButton.Text = ""
JumpButton.AutoButtonColor = false
JumpButton.Parent = JumpSliderBar

local function updateJump(percent)
    percent = math.clamp(percent, 0, 1)
    local value = math.floor(percent * 250)
    JumpFill.Size = UDim2.new(percent, 0, 1, 0)
    JumpButton.Position = UDim2.new(percent, -12, -0.5, 0)
    JumpValue.Text = tostring(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
    JumpLabel.Text = "🦘 Jump Power: " .. value
end

JumpSliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local percent = (input.Position.X - JumpSliderBar.AbsolutePosition.X) / JumpSliderBar.AbsoluteSize.X
        updateJump(percent)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragging == false then
        if JumpSliderBar and input.Position.X >= JumpSliderBar.AbsolutePosition.X and input.Position.X <= JumpSliderBar.AbsolutePosition.X + JumpSliderBar.AbsoluteSize.X then
            local percent = (input.Position.X - JumpSliderBar.AbsolutePosition.X) / JumpSliderBar.AbsoluteSize.X
            updateJump(percent)
        end
    end
end)

JumpValue.FocusLost:Connect(function()
    local num = tonumber(JumpValue.Text)
    if num then
        num = math.clamp(num, 50, 500)
        updateJump(num / 250)
    else
        updateJump(0.2)
    end
end)

-- ========== FLY TOGGLE (móvil) ==========
local FlyCard = Instance.new("Frame")
FlyCard.Size = UDim2.new(0, 310, 0, 70)
FlyCard.Position = UDim2.new(0.5, -155, 0, 0)
FlyCard.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
FlyCard.BorderSizePixel = 0
FlyCard.Parent = ContentContainer

local FlyLabel = Instance.new("TextLabel")
FlyLabel.Size = UDim2.new(1, 0, 0, 30)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "🕊️ Fly Mode"
FlyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyLabel.TextSize = 18
FlyLabel.Font = Enum.Font.SourceSansBold
FlyLabel.Parent = FlyCard

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 280, 0, 35)
FlyButton.Position = UDim2.new(0.5, -140, 0, 35)
FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
FlyButton.Text = "OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 20
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.Parent = FlyCard

-- Función de Fly
local function startFly()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not character or not humanoid or not rootPart then return end
    
    flyEnabled = true
    FlyButton.Text = "ON"
    FlyButton.BackgroundColor3 = Color3.fromRGB(100, 120, 100)
    
    humanoid.PlatformStand = true
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = rootPart
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not character or not rootPart then
            stopFly()
            return
        end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new()
        
        -- Controles móvil/teclado
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
        
        local spaceDown = UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonX)
        local shiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonR2)
        
        if spaceDown then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if shiftDown then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * 50
        end
        
        flyBodyVelocity.Velocity = moveDirection
    end)
end

local function stopFly()
    flyEnabled = false
    FlyButton.Text = "OFF"
    FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
end

FlyButton.MouseButton1Click:Connect(function()
    if flyEnabled then stopFly() else startFly() end
end)

FlyButton.TouchTap:Connect(function()
    if flyEnabled then stopFly() else startFly() end
end)

-- Reset al morir
LocalPlayer.CharacterAdded:Connect(function()
    if flyEnabled then
        stopFly()
    end
end)

-- Ajustar CanvasSize del Scroll
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
end)

-- Notificación de bienvenida
local welcomeNotif = Instance.new("TextLabel")
welcomeNotif.Size = UDim2.new(0, 250, 0, 50)
welcomeNotif.Position = UDim2.new(0.5, -125, 0.8, 0)
welcomeNotif.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
welcomeNotif.BackgroundTransparency = 0.2
welcomeNotif.Text = "GUI para móvil listo ✓"
welcomeNotif.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeNotif.TextSize = 16
welcomeNotif.Font = Enum.Font.SourceSansBold
welcomeNotif.Parent = ScreenGui

game:GetService("TweenService"):Create(welcomeNotif, TweenInfo.new(1, Enum.EasingStyle.Quad), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
game:GetService("Debris"):AddItem(welcomeNotif, 2)

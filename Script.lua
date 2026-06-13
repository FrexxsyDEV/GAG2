-- GUI pequeño y funcional para móvil/PC
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")

-- Crear el ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- ========== VENTANA PRINCIPAL (MUY PEQUEÑA) ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Borde redondeado
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "XENO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothomBold
Title.Parent = TitleBar

-- Botón minimizar
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothomBold
MinimizeButton.Parent = TitleBar

-- Contenedor
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -30)
ContentContainer.Position = UDim2.new(0, 0, 0, 30)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = ContentContainer

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 8)
UIPadding.PaddingLeft = UDim.new(0, 8)
UIPadding.PaddingRight = UDim.new(0, 8)
UIPadding.Parent = ContentContainer

-- ========== BOTÓN FLOTANTE AL MINIMIZAR ==========
local FloatingButton = Instance.new("TextButton")
FloatingButton.Size = UDim2.new(0, 45, 0, 45)
FloatingButton.Position = UDim2.new(0.85, 0, 0.85, 0)
FloatingButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
FloatingButton.Text = "X"
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.TextSize = 18
FloatingButton.Font = Enum.Font.GothomBold
FloatingButton.Visible = false
FloatingButton.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(1, 0)
FloatingCorner.Parent = FloatingButton

-- Mover botón flotante
local floatingDrag = false
local floatStartPos = nil
local floatDragStart = nil

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        floatingDrag = true
        floatDragStart = input.Position
        floatStartPos = FloatingButton.Position
    end
end)

FloatingButton.InputEnded:Connect(function()
    floatingDrag = false
end)

UserInputService.InputChanged:Connect(function(input)
    if floatingDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - floatDragStart
        local newX = floatStartPos.X.Offset + delta.X
        local newY = floatStartPos.Y.Offset + delta.Y
        local maxX = game:GetService("GuiService").ScreenResolution.X - 45
        local maxY = game:GetService("GuiService").ScreenResolution.Y - 45
        FloatingButton.Position = UDim2.new(0, math.clamp(newX, 0, maxX), 0, math.clamp(newY, 0, maxY))
    end
end)

-- Mover ventana principal
local drag = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function()
    drag = false
end)

UserInputService.InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Minimizar/Restaurar
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = true
    MainFrame.Visible = false
    FloatingButton.Visible = true
end)

FloatingButton.MouseButton1Click:Connect(function()
    minimized = false
    MainFrame.Visible = true
    FloatingButton.Visible = false
end)

FloatingButton.TouchTap:Connect(function()
    minimized = false
    MainFrame.Visible = true
    FloatingButton.Visible = false
end)

-- ========== WALKSPEED ==========
local WSCard = Instance.new("Frame")
WSCard.Size = UDim2.new(1, 0, 0, 65)
WSCard.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WSCard.BorderSizePixel = 0
WSCard.Parent = ContentContainer

local WSCorner = Instance.new("UICorner")
WSCorner.CornerRadius = UDim.new(0, 6)
WSCorner.Parent = WSCard

local WSLabel = Instance.new("TextLabel")
WSLabel.Size = UDim2.new(1, 0, 0, 20)
WSLabel.BackgroundTransparency = 1
WSLabel.Text = "Velocidad: 16"
WSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WSLabel.TextSize = 12
WSLabel.TextXAlignment = Enum.TextXAlignment.Left
WSLabel.Font = Enum.Font.Gothom
WSLabel.Parent = WSCard

local WSValue = Instance.new("TextBox")
WSValue.Size = UDim2.new(0, 45, 0, 25)
WSValue.Position = UDim2.new(1, -50, 0, 18)
WSValue.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
WSValue.Text = "16"
WSValue.TextColor3 = Color3.fromRGB(255, 255, 255)
WSValue.TextSize = 12
WSValue.Font = Enum.Font.Gothom
WSValue.Parent = WSCard

local WSBar = Instance.new("Frame")
WSBar.Size = UDim2.new(1, -55, 0, 4)
WSBar.Position = UDim2.new(0, 0, 0, 45)
WSBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
WSBar.BorderSizePixel = 0
WSBar.Parent = WSCard

local WSFill = Instance.new("Frame")
WSFill.Size = UDim2.new(0.16, 0, 1, 0)
WSFill.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
WSFill.BorderSizePixel = 0
WSFill.Parent = WSBar

local WSButton = Instance.new("TextButton")
WSButton.Size = UDim2.new(0, 12, 0, 12)
WSButton.Position = UDim2.new(0.16, -6, -0.5, 0)
WSButton.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
WSButton.Text = ""
WSButton.AutoButtonColor = false
WSButton.Parent = WSBar

local WSButtonCorner = Instance.new("UICorner")
WSButtonCorner.CornerRadius = UDim.new(1, 0)
WSButtonCorner.Parent = WSButton

local wsDragging = false

local function updateWS(percent)
    percent = math.clamp(percent, 0, 1)
    local val = math.floor(percent * 100)
    WSFill.Size = UDim2.new(percent, 0, 1, 0)
    WSButton.Position = UDim2.new(percent, -6, -0.5, 0)
    WSValue.Text = tostring(val)
    WSLabel.Text = "Velocidad: " .. val
    pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = val end)
end

WSBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        wsDragging = true
        local percent = (input.Position.X - WSBar.AbsolutePosition.X) / WSBar.AbsoluteSize.X
        updateWS(percent)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if wsDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local percent = (input.Position.X - WSBar.AbsolutePosition.X) / WSBar.AbsoluteSize.X
        updateWS(percent)
    end
end)

UserInputService.InputEnded:Connect(function()
    wsDragging = false
end)

WSValue.FocusLost:Connect(function()
    local num = tonumber(WSValue.Text)
    if num then
        num = math.clamp(num, 16, 250)
        updateWS(num / 100)
    else
        updateWS(0.16)
    end
end)

-- ========== JUMP POWER ==========
local JPCard = Instance.new("Frame")
JPCard.Size = UDim2.new(1, 0, 0, 65)
JPCard.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JPCard.BorderSizePixel = 0
JPCard.Parent = ContentContainer

local JPCorner = Instance.new("UICorner")
JPCorner.CornerRadius = UDim.new(0, 6)
JPCorner.Parent = JPCard

local JPLabel = Instance.new("TextLabel")
JPLabel.Size = UDim2.new(1, 0, 0, 20)
JPLabel.BackgroundTransparency = 1
JPLabel.Text = "Salto: 50"
JPLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JPLabel.TextSize = 12
JPLabel.TextXAlignment = Enum.TextXAlignment.Left
JPLabel.Font = Enum.Font.Gothom
JPLabel.Parent = JPCard

local JPValue = Instance.new("TextBox")
JPValue.Size = UDim2.new(0, 45, 0, 25)
JPValue.Position = UDim2.new(1, -50, 0, 18)
JPValue.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
JPValue.Text = "50"
JPValue.TextColor3 = Color3.fromRGB(255, 255, 255)
JPValue.TextSize = 12
JPValue.Font = Enum.Font.Gothom
JPValue.Parent = JPCard

local JPBar = Instance.new("Frame")
JPBar.Size = UDim2.new(1, -55, 0, 4)
JPBar.Position = UDim2.new(0, 0, 0, 45)
JPBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
JPBar.BorderSizePixel = 0
JPBar.Parent = JPCard

local JPFill = Instance.new("Frame")
JPFill.Size = UDim2.new(0.2, 0, 1, 0)
JPFill.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
JPFill.BorderSizePixel = 0
JPFill.Parent = JPBar

local JPButton = Instance.new("TextButton")
JPButton.Size = UDim2.new(0, 12, 0, 12)
JPButton.Position = UDim2.new(0.2, -6, -0.5, 0)
JPButton.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
JPButton.Text = ""
JPButton.AutoButtonColor = false
JPButton.Parent = JPBar

local JPButtonCorner = Instance.new("UICorner")
JPButtonCorner.CornerRadius = UDim.new(1, 0)
JPButtonCorner.Parent = JPButton

local jpDragging = false

local function updateJP(percent)
    percent = math.clamp(percent, 0, 1)
    local val = math.floor(percent * 250)
    JPFill.Size = UDim2.new(percent, 0, 1, 0)
    JPButton.Position = UDim2.new(percent, -6, -0.5, 0)
    JPValue.Text = tostring(val)
    JPLabel.Text = "Salto: " .. val
    pcall(function() LocalPlayer.Character.Humanoid.JumpPower = val end)
end

JPBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        jpDragging = true
        local percent = (input.Position.X - JPBar.AbsolutePosition.X) / JPBar.AbsoluteSize.X
        updateJP(percent)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if jpDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local percent = (input.Position.X - JPBar.AbsolutePosition.X) / JPBar.AbsoluteSize.X
        updateJP(percent)
    end
end)

UserInputService.InputEnded:Connect(function()
    jpDragging = false
end)

JPValue.FocusLost:Connect(function()
    local num = tonumber(JPValue.Text)
    if num then
        num = math.clamp(num, 50, 500)
        updateJP(num / 250)
    else
        updateJP(0.2)
    end
end)

-- ========== FLY AVANZADO (móvil/PC) ==========
local FlyCard = Instance.new("Frame")
FlyCard.Size = UDim2.new(1, 0, 0, 55)
FlyCard.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyCard.BorderSizePixel = 0
FlyCard.Parent = ContentContainer

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 6)
FlyCorner.Parent = FlyCard

local FlyLabel = Instance.new("TextLabel")
FlyLabel.Size = UDim2.new(1, 0, 0, 25)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "🕊️ Fly"
FlyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyLabel.TextSize = 12
FlyLabel.TextXAlignment = Enum.TextXAlignment.Left
FlyLabel.Font = Enum.Font.Gothom
FlyLabel.Parent = FlyCard

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(1, -16, 0, 30)
FlyButton.Position = UDim2.new(0, 8, 0, 22)
FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
FlyButton.Text = "OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 14
FlyButton.Font = Enum.Font.GothomBold
FlyButton.Parent = FlyCard

local FlyCorner2 = Instance.new("UICorner")
FlyCorner2.CornerRadius = UDim.new(0, 4)
FlyCorner2.Parent = FlyButton

-- Variables de Fly
local flying = false
local bodyVel = nil
local flyConnection = nil
local flySpeed = 60

-- Controles táctiles para móvil (botones virtuales)
local TouchControls = Instance.new("Frame")
TouchControls.Size = UDim2.new(0, 120, 0, 120)
TouchControls.Position = UDim2.new(0, 10, 1, -130)
TouchControls.BackgroundTransparency = 1
TouchControls.Visible = false
TouchControls.Parent = ScreenGui

local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0, 50, 0, 50)
UpBtn.Position = UDim2.new(0.5, -25, 0, 0)
UpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
UpBtn.Text = "⬆️"
UpBtn.TextSize = 20
UpBtn.Font = Enum.Font.Gothom
UpBtn.Parent = TouchControls
local UpCorner = Instance.new("UICorner")
UpCorner.CornerRadius = UDim.new(1, 0)
UpCorner.Parent = UpBtn

local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0, 50, 0, 50)
DownBtn.Position = UDim2.new(0.5, -25, 1, -50)
DownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DownBtn.Text = "⬇️"
DownBtn.TextSize = 20
DownBtn.Font = Enum.Font.Gothom
DownBtn.Parent = TouchControls
local DownCorner = Instance.new("UICorner")
DownCorner.CornerRadius = UDim.new(1, 0)
DownCorner.Parent = DownBtn

local LeftBtn = Instance.new("TextButton")
LeftBtn.Size = UDim2.new(0, 50, 0, 50)
LeftBtn.Position = UDim2.new(0, 0, 0.5, -25)
LeftBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
LeftBtn.Text = "⬅️"
LeftBtn.TextSize = 20
LeftBtn.Font = Enum.Font.Gothom
LeftBtn.Parent = TouchControls
local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(1, 0)
LeftCorner.Parent = LeftBtn

local RightBtn = Instance.new("TextButton")
RightBtn.Size = UDim2.new(0, 50, 0, 50)
RightBtn.Position = UDim2.new(1, -50, 0.5, -25)
RightBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RightBtn.Text = "➡️"
RightBtn.TextSize = 20
RightBtn.Font = Enum.Font.Gothom
RightBtn.Parent = TouchControls
local RightCorner = Instance.new("UICorner")
RightCorner.CornerRadius = UDim.new(1, 0)
RightCorner.Parent = RightBtn

-- Estados táctiles
local touchUp = false
local touchDown = false
local touchLeft = false
local touchRight = false

UpBtn.MouseButton1Down:Connect(function() touchUp = true end)
UpBtn.MouseButton1Up:Connect(function() touchUp = false end)
UpBtn.TouchTap:Connect(function() touchUp = true end)
UpBtn.TouchEnd:Connect(function() touchUp = false end)

DownBtn.MouseButton1Down:Connect(function() touchDown = true end)
DownBtn.MouseButton1Up:Connect(function() touchDown = false end)
DownBtn.TouchTap:Connect(function() touchDown = true end)
DownBtn.TouchEnd:Connect(function() touchDown = false end)

LeftBtn.MouseButton1Down:Connect(function() touchLeft = true end)
LeftBtn.MouseButton1Up:Connect(function() touchLeft = false end)
LeftBtn.TouchTap:Connect(function() touchLeft = true end)
LeftBtn.TouchEnd:Connect(function() touchLeft = false end)

RightBtn.MouseButton1Down:Connect(function() touchRight = true end)
RightBtn.MouseButton1Up:Connect(function() touchRight = false end)
RightBtn.TouchTap:Connect(function() touchRight = true end)
RightBtn.TouchEnd:Connect(function() touchRight = false end)

-- Función Fly
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    flying = true
    FlyButton.Text = "ON"
    FlyButton.BackgroundColor3 = Color3.fromRGB(100, 130, 100)
    TouchControls.Visible = true
    
    hum.PlatformStand = true
    
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(10000, 10000, 10000)
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.Parent = hrp
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not char or not hrp then
            stopFly()
            return
        end
        
        local move = Vector3.new()
        local cam = workspace.CurrentCamera
        
        -- Controles teclado
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        
        -- Controles táctiles
        if touchUp then move = move + Vector3.new(0, 1, 0) end
        if touchDown then move = move - Vector3.new(0, 1, 0) end
        if touchLeft then move = move - cam.CFrame.RightVector end
        if touchRight then move = move + cam.CFrame.RightVector end
        
        if move.Magnitude > 0 then
            move = move.Unit * flySpeed
        end
        
        bodyVel.Velocity = move
    end)
end

local function stopFly()
    flying = false
    FlyButton.Text = "OFF"
    FlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    TouchControls.Visible = false
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
    if bodyVel then bodyVel:Destroy() bodyVel = nil end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
end

FlyButton.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

FlyButton.TouchTap:Connect(function()
    if flying then stopFly() else startFly() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if flying then stopFly() end
end)

-- Ajuste de CanvasSize
local function updateCanvas()
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 16)
end
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.wait(0.1)
updateCanvas()

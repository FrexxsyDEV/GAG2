-- Cargar Tofu Lib (compatible con Delta)
local Tofu = loadstring(game:HttpGet("https://raw.githubusercontent.com/guilherme-paiva/TofuLib/main/TofuLib.lua"))()

-- Crear la ventana
local Window = Tofu:CreateWindow({
    Name = "Xeno GUI",
    Size = UDim2.new(0, 250, 0, 300),
    Theme = "Dark",
    Minimizable = true,
    Movable = true
})

-- Variables
local flyEnabled = false
local flyBodyVelocity = nil
local flyConnection = nil
local flySpeed = 50

-- Controles táctiles para móvil
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tab principal
local MainTab = Window:CreateTab("Principal")

-- Sección de Movimiento
local MovementSection = MainTab:CreateSection("Movimiento")

-- Walkspeed Slider
local WalkspeedSlider = MainTab:CreateSlider({
    Name = "Walkspeed",
    Text = "Velocidad",
    Range = {16, 250},
    Default = 16,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- Jump Power Slider
local JumpSlider = MainTab:CreateSlider({
    Name = "JumpPower",
    Text = "Altura de salto",
    Range = {50, 500},
    Default = 50,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

-- Fly Toggle
local FlyToggle = MainTab:CreateToggle({
    Name = "Fly",
    Text = "Volar",
    Default = false,
    Callback = function(State)
        flyEnabled = State
        if flyEnabled then
            StartFly()
        else
            StopFly()
        end
    end
})

-- Funciones de Fly avanzado
local function StartFly()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    hum.PlatformStand = true
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = hrp
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not LocalPlayer.Character or not hrp then
            StopFly()
            return
        end
        
        local moveDirection = Vector3.new()
        local camera = workspace.CurrentCamera
        
        -- Teclado (PC)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        
        -- Controles móvil (si hay pantalla táctil)
        if UserInputService.TouchEnabled then
            -- Controles en la pantalla
            local screenSize = game:GetService("GuiService").ScreenResolution
            for _, touch in ipairs(UserInputService:GetTouches()) do
                local pos = touch.Position
                local midX = screenSize.X / 2
                local midY = screenSize.Y / 2
                
                if pos.Y < midY - 100 then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0) -- Arriba
                elseif pos.Y > midY + 100 then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0) -- Abajo
                end
                
                if pos.X < midX - 100 then
                    moveDirection = moveDirection - camera.CFrame.RightVector -- Izquierda
                elseif pos.X > midX + 100 then
                    moveDirection = moveDirection + camera.CFrame.RightVector -- Derecha
                end
            end
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * flySpeed
        end
        
        flyBodyVelocity.Velocity = moveDirection
    end)
end

local function StopFly()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
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

-- Resetear cuando el personaje muere
LocalPlayer.CharacterAdded:Connect(function()
    if flyEnabled then
        StopFly()
        flyEnabled = false
        FlyToggle:Set(false)
    end
end)

-- Notificación de bienvenida
Tofu:Notify({
    Title = "Xeno GUI",
    Content = "¡GUI cargado correctamente!",
    Duration = 3
})

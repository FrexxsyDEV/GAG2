-- OP GROW A GARDEN 2 - VERSION FINAL (FLY + ANTI RAGDOLL + ESP)
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local teleportService = game:GetService("TeleportService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local camera = workspace.CurrentCamera

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OPGrowAGarden2"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFont = Enum.Font.FredokaOne

-- VARIABLES
local instantStealActive = false
local autoFarmActive = false
local speedAnchorActive = false
local jumpAnchorActive = false
local currentSpeed = 100
local currentJump = 100
local savedPos = nil
local autoFarmRunning = false
local currentGoldIndex = 1
local speedConnection = nil
local jumpConnection = nil

-- FLY VARIABLES
local isFlying = false
local flySpeed = 50
local flyBodyVelocity = nil
local flyConnection = nil
local flyPlatformStand = false

-- ANTI RAGDOLL (Evita salir volando al ser golpeado)
local antiRagdollActive = true
local antiRagdollConnection = nil

-- ESP VARIABLES
local espActive = false
local espFrames = {}
local espColor = Color3.fromRGB(0, 255, 0) -- Verde
local espUpdateConnection = nil

-- ========== AUTO FARM (GOLD) ==========
local function getGoldList()
    local golds = {}
    local seed = workspace:FindFirstChild("SeedPackSpawnClient")
    if seed then
        local model = seed:FindFirstChild("Model")
        if model then
            for _, child in pairs(model:GetChildren()) do
                if child.Name == "Gold" and child:IsA("BasePart") then
                    table.insert(golds, child)
                end
            end
        end
    end
    return golds
end

local function interactWithGold(gold)
    for _, child in pairs(gold:GetChildren()) do
        if child:IsA("ProximityPrompt") then
            pcall(function()
                child:InputHoldBegin()
                wait(0.05)
                child:InputHoldEnd()
            end)
            break
        end
    end
end

local function farmLoop()
    while autoFarmRunning and autoFarmActive do
        local golds = getGoldList()
        if #golds > 0 then
            if currentGoldIndex > #golds then currentGoldIndex = 1 end
            local target = golds[currentGoldIndex]
            if target and target.Parent then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function()
                        hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        wait(0.05)
                        interactWithGold(target)
                    end)
                end
            end
            currentGoldIndex = currentGoldIndex + 1
            wait(0.2)
        else
            wait(1)
        end
    end
end

local function startAutoFarm()
    if autoFarmRunning then return end
    autoFarmRunning = true
    task.spawn(farmLoop)
end

local function stopAutoFarm()
    autoFarmRunning = false
end

-- INSTANT STEAL
local function setInstantSteal(enabled)
    instantStealActive = enabled
    local duration = enabled and 0 or 1
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function() obj.HoldDuration = duration end)
        end
    end
end

-- ========== ANTI RAGDOLL (BYPASS) ==========
local function antiRagdollLoop()
    while antiRagdollActive and player.Character do
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            -- Prevenir caída o ser lanzado
            if humanoid.PlatformStand then
                humanoid.PlatformStand = false
            end
            -- Resetear velocidad si es extremadamente alta (golpe)
            if hrp and hrp.Velocity and (hrp.Velocity.magnitude > 80) then
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
            -- Mantener estado normal
            if humanoid.Sit then
                humanoid.Sit = false
            end
        end
        wait(0.1)
    end
end

local function setAntiRagdoll(enabled)
    antiRagdollActive = enabled
    if enabled then
        task.spawn(antiRagdollLoop)
        print("[Anti-Ragdoll] Activated")
    else
        print("[Anti-Ragdoll] Deactivated")
    end
end

-- ========== FLY SYSTEM (BYPASS) ==========
local function startFly()
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    
    -- Guardar estado
    flyPlatformStand = humanoid.PlatformStand
    humanoid.PlatformStand = true
    
    -- Crear BodyVelocity
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = hrp
    
    -- Conectar movimiento
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = runService.RenderStepped:Connect(function()
        if not isFlying or not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local moveDirection = Vector3.new()
        local camera = workspace.CurrentCamera
        
        if userInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection + Vector3.new(0, -1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        
        if flyBodyVelocity then
            flyBodyVelocity.Velocity = moveDirection * flySpeed
        end
    end)
    
    print("[Fly] Activated")
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = flyPlatformStand
        end
    end
    print("[Fly] Deactivated")
end

local function setFly(enabled)
    isFlying = enabled
    if enabled then
        startFly()
    else
        stopFly()
    end
end

local function setFlySpeed(value)
    flySpeed = tonumber(value) or 50
    if flySpeed < 10 then flySpeed = 10 end
    if flySpeed > 500 then flySpeed = 500 end
    print("[FlySpeed] " .. flySpeed)
end

-- ========== ESP BOXES (para detectar camuflados) ==========
local function createEspFrame(targetPlayer)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = espColor
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 2
    frame.BorderColor3 = espColor
    frame.Visible = true
    frame.Parent = screenGui
    return frame
end

local function updateEsp()
    if not espActive then
        -- Limpiar frames si esp se desactiva
        for _, frame in pairs(espFrames) do
            if frame then pcall(function() frame:Destroy() end) end
        end
        espFrames = {}
        return
    end
    
    local players = game:GetService("Players"):GetPlayers()
    for _, plr in pairs(players) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToScreenPoint(hrp.Position)
            if onScreen then
                -- Crear frame si no existe
                if not espFrames[plr] then
                    espFrames[plr] = createEspFrame(plr)
                end
                -- Calcular tamaño del box (aproximado por altura del personaje)
                local height = 5 -- altura estimada en studs
                local width = 2
                -- Convertir a píxeles en pantalla
                local topPos = camera:WorldToScreenPoint(hrp.Position + Vector3.new(0, height/2, 0))
                local bottomPos = camera:WorldToScreenPoint(hrp.Position - Vector3.new(0, height/2, 0))
                local screenHeight = math.abs(topPos.Y - bottomPos.Y)
                local screenWidth = screenHeight * 0.5
                
                espFrames[plr].Size = UDim2.new(0, screenWidth, 0, screenHeight)
                espFrames[plr].Position = UDim2.new(0, pos.X - screenWidth/2, 0, pos.Y - screenHeight/2)
                espFrames[plr].Visible = true
            else
                if espFrames[plr] then
                    espFrames[plr].Visible = false
                end
            end
        else
            if espFrames[plr] then
                espFrames[plr]:Destroy()
                espFrames[plr] = nil
            end
        end
    end
end

local function setEsp(enabled)
    espActive = enabled
    if enabled then
        if espUpdateConnection then espUpdateConnection:Disconnect() end
        espUpdateConnection = runService.RenderStepped:Connect(updateEsp)
        print("[ESP] Activated")
    else
        if espUpdateConnection then espUpdateConnection:Disconnect() end
        espUpdateConnection = nil
        -- Limpiar frames
        for _, frame in pairs(espFrames) do
            pcall(function() frame:Destroy() end)
        end
        espFrames = {}
        print("[ESP] Deactivated")
    end
end

local function setEspColor(color)
    espColor = color
    for _, frame in pairs(espFrames) do
        if frame then
            frame.BackgroundColor3 = color
            frame.BorderColor3 = color
        end
    end
end

-- MOVEMENT
local function applySpeed()
    if speedAnchorActive and player.Character and player.Character:FindFirstChild("Humanoid") then
        pcall(function() player.Character.Humanoid.WalkSpeed = currentSpeed end)
    end
end

local function applyJump()
    if jumpAnchorActive and player.Character and player.Character:FindFirstChild("Humanoid") then
        pcall(function() player.Character.Humanoid.JumpPower = currentJump end)
    end
end

if speedConnection then speedConnection:Disconnect() end
speedConnection = runService.Heartbeat:Connect(function()
    if speedAnchorActive and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        if humanoid.WalkSpeed ~= currentSpeed then
            pcall(function() humanoid.WalkSpeed = currentSpeed end)
        end
    end
end)

if jumpConnection then jumpConnection:Disconnect() end
jumpConnection = runService.Heartbeat:Connect(function()
    if jumpAnchorActive and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        if humanoid.JumpPower ~= currentJump then
            pcall(function() humanoid.JumpPower = currentJump end)
        end
    end
end)

-- FUNCIONES
local function savePos()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedPos = player.Character.HumanoidRootPart.CFrame
    end
end

local function teleport()
    if savedPos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            player.Character.HumanoidRootPart.CFrame = savedPos
            player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end)
    end
end

local function turnNight()
    local night = replicatedStorage:FindFirstChild("Night")
    if night then pcall(function() night.Value = true end) end
    for _, remote in pairs(replicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer("Night", true)
                remote:FireServer("SetNight", true)
            end)
        end
    end
end

local function rejoin()
    wait(1)
    pcall(function() teleportService:Teleport(game.PlaceId) end)
end

-- TECLA F
userInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.F and not gp then
        teleport()
    end
end)

-- RESPAWN
player.CharacterAdded:Connect(function()
    wait(0.5)
    applySpeed()
    applyJump()
    if instantStealActive then setInstantSteal(true) end
    if autoFarmActive then startAutoFarm() end
    if isFlying then
        startFly()
    end
end)

-- GUI PRINCIPAL (igual que antes pero con nuevas pestañas)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 550) -- altura extra para más opciones
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- BARRA TITULO
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ OP GROW A GARDEN 2 ⚡"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = mainFont
titleText.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 1, 0)
minBtn.Position = UDim2.new(1, -65, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = mainFont
minBtn.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 18
closeBtn.Font = mainFont
closeBtn.Parent = titleBar

-- TABS
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -90)
contentFrame.Position = UDim2.new(0, 10, 0, 80)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = contentFrame

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 10)
scrollLayout.Parent = scroll

-- Helper functions
local function createSection(parent, title, icon, order)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, 0)
    s.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    s.BorderSizePixel = 0
    s.LayoutOrder = order
    s.AutomaticSize = Enum.AutomaticSize.Y
    s.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = s
    
    local titleL = Instance.new("TextLabel")
    titleL.Size = UDim2.new(1, -15, 0, 30)
    titleL.Position = UDim2.new(0, 8, 0, 5)
    titleL.BackgroundTransparency = 1
    titleL.Text = icon .. " " .. title
    titleL.TextColor3 = Color3.fromRGB(0, 200, 255)
    titleL.TextSize = 13
    titleL.Font = mainFont
    titleL.Parent = s
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = s
    
    return s
end

local function createToggle(parent, label, desc, getState, setState, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -15, 0, 50)
    f.Position = UDim2.new(0, 8, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = f
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -70, 0, 25)
    labelText.Position = UDim2.new(0, 8, 0, 5)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.TextSize = 12
    labelText.Font = mainFont
    labelText.Parent = f
    
    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(1, -70, 0, 18)
    descText.Position = UDim2.new(0, 8, 0, 28)
    descText.BackgroundTransparency = 1
    descText.Text = desc
    descText.TextColor3 = Color3.fromRGB(160, 160, 160)
    descText.TextSize = 10
    descText.Font = mainFont
    descText.Parent = f
    
    local toggleF = Instance.new("Frame")
    toggleF.Size = UDim2.new(0, 45, 0, 22)
    toggleF.Position = UDim2.new(1, -53, 0, 14)
    toggleF.BackgroundColor3 = getState() and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
    toggleF.BorderSizePixel = 0
    toggleF.Parent = f
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleF
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = getState() and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = toggleF
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggleF
    
    btn.MouseButton1Click:Connect(function()
        local newState = not getState()
        setState(newState)
        if newState then
            toggleF.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            circle.Position = UDim2.new(1, -20, 0, 2)
        else
            toggleF.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            circle.Position = UDim2.new(0, 2, 0, 2)
        end
    end)
    
    return btn
end

local function createInputButton(parent, label, desc, getVal, setVal, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -15, 0, 50)
    f.Position = UDim2.new(0, 8, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = f
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -140, 0, 22)
    labelText.Position = UDim2.new(0, 8, 0, 5)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.TextSize = 12
    labelText.Font = mainFont
    labelText.Parent = f
    
    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(1, -140, 0, 18)
    descText.Position = UDim2.new(0, 8, 0, 25)
    descText.BackgroundTransparency = 1
    descText.Text = desc
    descText.TextColor3 = Color3.fromRGB(160, 160, 160)
    descText.TextSize = 10
    descText.Font = mainFont
    descText.Parent = f
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 60, 0, 30)
    input.Position = UDim2.new(1, -130, 0, 10)
    input.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    input.BorderSizePixel = 0
    input.Text = tostring(getVal())
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 13
    input.Font = mainFont
    input.Parent = f
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 5)
    inputCorner.Parent = input
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 30)
    btn.Position = UDim2.new(1, -65, 0, 10)
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    btn.BackgroundTransparency = 0.1
    btn.Text = "APPLY"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = mainFont
    btn.Parent = f
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local val = tonumber(input.Text)
        if val then
            setVal(val)
            input.Text = tostring(getVal())
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            wait(0.2)
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        end
    end)
    
    return input, btn
end

local function createActionButton(parent, label, desc, callback, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -15, 0, 50)
    f.Position = UDim2.new(0, 8, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = f
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -90, 0, 25)
    labelText.Position = UDim2.new(0, 8, 0, 5)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.TextSize = 12
    labelText.Font = mainFont
    labelText.Parent = f
    
    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(1, -90, 0, 18)
    descText.Position = UDim2.new(0, 8, 0, 25)
    descText.BackgroundTransparency = 1
    descText.Text = desc
    descText.TextColor3 = Color3.fromRGB(160, 160, 160)
    descText.TextSize = 10
    descText.Font = mainFont
    descText.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 30)
    btn.Position = UDim2.new(1, -75, 0, 10)
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    btn.BackgroundTransparency = 0.1
    btn.Text = "ACTIVATE"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = mainFont
    btn.Parent = f
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.1 end)
    
    return btn
end

-- Scroll helpers
local function clearScroll()
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("Frame") and child ~= scrollLayout then
            child:Destroy()
        end
    end
end

local function updateScrollSize()
    wait(0.1)
    local h = 0
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            h = h + child.AbsoluteSize.Y + 10
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, h + 50)
end

-- TABS CONTENT
local function loadSteal()
    clearScroll()
    local s = createSection(scroll, "INSTANT STEAL", "⚡", 1)
    createToggle(s, "Instant Steal", "Set all ProximityPrompts to 0", 
        function() return instantStealActive end, 
        function(v) setInstantSteal(v) end, 1)
    
    local s2 = createSection(scroll, "POSITION", "📍", 2)
    createActionButton(s2, "Set My Base Position", "Save position (F key)", savePos, 1)
    createActionButton(s2, "Teleport To Base", "Teleport to saved", teleport, 2)
    updateScrollSize()
end

local function loadMovement()
    clearScroll()
    local s = createSection(scroll, "WALKSPEED", "🏃", 1)
    createInputButton(s, "Speed", "Range: 16-500", 
        function() return currentSpeed end, 
        function(v) currentSpeed = v; applySpeed() end, 1)
    createToggle(s, "Speed Anchor", "Anti-reset", 
        function() return speedAnchorActive end, 
        function(v) speedAnchorActive = v; if v then applySpeed() end end, 2)
    
    local s2 = createSection(scroll, "JUMP POWER", "🦘", 2)
    createInputButton(s2, "Jump Power", "Range: 40-300", 
        function() return currentJump end, 
        function(v) currentJump = v; applyJump() end, 1)
    createToggle(s2, "Jump Anchor", "Anti-reset", 
        function() return jumpAnchorActive end, 
        function(v) jumpAnchorActive = v; if v then applyJump() end end, 2)
    
    local s3 = createSection(scroll, "FLY", "✈️", 3)
    createToggle(s3, "Fly", "Activate flight (WASD+Space+Ctrl)", 
        function() return isFlying end, 
        function(v) setFly(v) end, 1)
    createInputButton(s3, "Fly Speed", "Range: 10-500", 
        function() return flySpeed end, 
        function(v) setFlySpeed(v) end, 2)
    
    updateScrollSize()
end

local function loadAutoFarm()
    clearScroll()
    local s = createSection(scroll, "AUTO FARM", "🤖", 1)
    createToggle(s, "Auto Farm Gold", "Teleport to Gold", 
        function() return autoFarmActive end, 
        function(v) 
            autoFarmActive = v
            if v then startAutoFarm() else stopAutoFarm() end
        end, 1)
    
    local s2 = createSection(scroll, "TURN NIGHT", "🌙", 2)
    createActionButton(s2, "Turn Night", "Activate night mode", turnNight, 1)
    updateScrollSize()
end

local function loadVisuals()
    clearScroll()
    local s = createSection(scroll, "ANTI RAGDOLL", "🛡️", 1)
    createToggle(s, "Anti Ragdoll", "Prevent being thrown when hit", 
        function() return antiRagdollActive end, 
        function(v) setAntiRagdoll(v) end, 1)
    
    local s2 = createSection(scroll, "ESP BOXES", "👁️", 2)
    createToggle(s2, "ESP", "Show boxes around other players (detect camouflage)", 
        function() return espActive end, 
        function(v) setEsp(v) end, 1)
    -- (opcional cambiar color aquí, pero simplificamos)
    
    updateScrollSize()
end

local function loadSettings()
    clearScroll()
    local s = createSection(scroll, "SERVER", "🌐", 1)
    createActionButton(s, "Rejoin", "Join different server", rejoin, 1)
    updateScrollSize()
end

-- CREAR TABS (añadimos "VISUALS")
local tabNames = {"STEAL", "MOVEMENT", "AUTO FARM", "VISUALS", "SETTINGS"}
local tabBtns = {}
local tabW = 450 / #tabNames

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, tabW, 1, 0)
    btn.Position = UDim2.new(0, (i-1) * tabW, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 11
    btn.Font = mainFont
    btn.Parent = tabContainer
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(1, 0, 0, 2)
    ind.Position = UDim2.new(0, 0, 1, -2)
    ind.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    ind.BackgroundTransparency = 1
    ind.Parent = btn
    
    tabBtns[name] = {button = btn, indicator = ind}
    
    btn.MouseButton1Click:Connect(function()
        for _, data in pairs(tabBtns) do
            data.button.BackgroundTransparency = 1
            data.button.TextColor3 = Color3.fromRGB(200, 200, 200)
            data.indicator.BackgroundTransparency = 1
        end
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ind.BackgroundTransparency = 0
        
        if name == "STEAL" then loadSteal()
        elseif name == "MOVEMENT" then loadMovement()
        elseif name == "AUTO FARM" then loadAutoFarm()
        elseif name == "VISUALS" then loadVisuals()
        elseif name == "SETTINGS" then loadSettings() end
    end)
end

tabBtns["STEAL"].button.BackgroundTransparency = 0.2
tabBtns["STEAL"].button.TextColor3 = Color3.fromRGB(255, 255, 255)
tabBtns["STEAL"].indicator.BackgroundTransparency = 0
loadSteal()

-- BOTON FLOTANTE (igual)
local floatBtn = Instance.new("ImageButton")
floatBtn.Size = UDim2.new(0, 44, 0, 44)
floatBtn.Position = UDim2.new(1, -54, 0, 10)
floatBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
floatBtn.BorderSizePixel = 0
floatBtn.Image = ""
floatBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = floatBtn

local btnLabel = Instance.new("TextLabel")
btnLabel.Size = UDim2.new(1, 0, 1, 0)
btnLabel.BackgroundTransparency = 1
btnLabel.Text = "⚡"
btnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLabel.TextSize = 24
btnLabel.Font = mainFont
btnLabel.Parent = floatBtn

local visible = true
floatBtn.MouseButton1Click:Connect(function()
    visible = not visible
    mainFrame.Visible = visible
end)

-- DRAG FLOAT
local drag = false
local dragStart = nil
local startPos = nil

floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = input.Position
        startPos = floatBtn.Position
    end
end)

floatBtn.InputChanged:Connect(function(input)
    if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

floatBtn.InputEnded:Connect(function()
    drag = false
end)

-- DRAG PANEL
local panelDrag = false
local panelDragStart = nil
local panelStartPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        panelDrag = true
        panelDragStart = input.Position
        panelStartPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if panelDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - panelDragStart
        mainFrame.Position = UDim2.new(panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X, panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y)
    end
end)

titleBar.InputEnded:Connect(function()
    panelDrag = false
end)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ACTIVAR ANTI RAGDOLL POR DEFECTO
setAntiRagdoll(true)

-- APLICAR VALORES INICIALES
if instantStealActive then setInstantSteal(true) end
if autoFarmActive then startAutoFarm() end
applySpeed()
applyJump()

print("OP GROW A GARDEN 2 - FINAL VERSION LOADED")
print("NEW: FLY (bypass), ANTI RAGDOLL, ESP BOXES")
print("TABS: STEAL | MOVEMENT | AUTO FARM | VISUALS | SETTINGS")
print("F key: Teleport to base")

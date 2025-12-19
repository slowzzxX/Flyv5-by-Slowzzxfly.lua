-- =========================
-- LIMPAR CONEXÕES ANTERIORES
-- =========================
if _G.a then
    for _, conn in pairs(_G.a) do
        conn:Disconnect()
    end
    _G.a = nil
end

repeat task.wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local character, humanoid, rootPart
local invisible = false
local parts = {}
local connections = {}

-- =========================
-- CONFIGURA PERSONAGEM
-- =========================
local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    parts = {}
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency == 0 then
            table.insert(parts, obj)
        end
    end
end

-- =========================
-- CRIA GUI (apenas uma vez)
-- =========================
local gui = player:WaitForChild("PlayerGui"):FindFirstChild("DesyncUI")
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = "DesyncUI"
    gui.ResetOnSpawn = false
    gui.Parent = player.PlayerGui

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 125, 0, 45)
    container.Position = UDim2.new(1, -200, 0.3, 0)
    container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Active = true
    container.Parent = gui

    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 10)
    corner1.Parent = container

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.6, 0)
    button.Position = UDim2.new(0.1, 0, 0.2, 0)
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Text = "Desync"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 20
    button.TextColor3 = Color3.fromRGB(255, 0, 0)
    button.Parent = container

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 6)
    corner2.Parent = button

    -- =========================
    -- DRAG DO CONTAINER
    -- =========================
    local dragging = false
    local dragStart, startPos
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
        end
    end)
    container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- =========================
    -- BOTÃO CLICK
    -- =========================
    local TweenService = game:GetService("TweenService")
    local activeTween
    button.MouseButton1Click:Connect(function()
        invisible = not invisible
        button.TextColor3 = invisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

        local shrinkTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.7, 0, 0.5, 0), Position = UDim2.new(0.15, 0, 0.25, 0)})
        local expandTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.8, 0, 0.6, 0), Position = UDim2.new(0.1, 0, 0.2, 0)})

        if activeTween then
            activeTween:Cancel()
        end
        activeTween = shrinkTween
        shrinkTween:Play()
        shrinkTween.Completed:Connect(function()
            expandTween:Play()
            activeTween = expandTween
        end)

        for _, part in pairs(parts) do
            part.Transparency = invisible and 0.5 or 0
        end
    end)
end

-- =========================
-- CONFIGURA PERSONAGEM INICIAL
-- =========================
setupCharacter()

-- =========================
-- DESYNC LOGIC
-- =========================
connections[1] = player:GetMouse().KeyDown:Connect(function(key)
    if key == "g" then
        invisible = not invisible
        for _, part in pairs(parts) do
            part.Transparency = invisible and 0.5 or 0
        end
    end
end)

connections[2] = game:GetService("RunService").Heartbeat:Connect(function()
    if invisible and rootPart and humanoid then
        local cf = rootPart.CFrame
        local camOffset = humanoid.CameraOffset
        local hidden = cf * CFrame.new(0, -200000, 0)
        rootPart.CFrame = hidden
        humanoid.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
        game:GetService("RunService").RenderStepped:Wait()
        rootPart.CFrame = cf
        humanoid.CameraOffset = camOffset
    end
end)

-- =========================
-- CHARACTERADDED
-- =========================
player.CharacterAdded:Connect(function()
    invisible = false
    setupCharacter()
end)

-- =========================
-- SALVAR CONEXÕES
-- =========================
_G.a = connections

--[[
    PARRY SYSTEM - INTERFACE (XENO EDITION)
]]

local Config = _G.ParryConfig or error("[PARRY] Config não encontrado")
local UI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local ScreenGui = nil
local StatusLabel = nil
local InfoLabel = nil
local FlashFrame = nil

-- ============================================
-- INICIALIZAR UI
-- ============================================

function UI:Init()
    if not Config.UIEnabled then
        if Config.Debug then print("[PARRY] UI desativada") end
        return
    end
    
    -- Aguardar PlayerGui
    local PlayerGui = nil
    local Attempts = 0
    while not PlayerGui and Attempts < 10 do
        pcall(function()
            PlayerGui = Player:WaitForChild("PlayerGui", 1)
        end)
        Attempts = Attempts + 1
    end
    
    if not PlayerGui then
        warn("[PARRY] PlayerGui não encontrado")
        return
    end
    
    -- Limpar UI antiga
    pcall(function()
        local ExistingGui = PlayerGui:FindFirstChild("ParrySystemUI")
        if ExistingGui then ExistingGui:Destroy() end
    end)
    
    -- Criar ScreenGui
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ParrySystemUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    
    -- Fundo
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.BackgroundColor3 = Config.ColorBackground
    Background.BackgroundTransparency = 1 - Config.UIOpacity
    Background.BorderSizePixel = 0
    Background.Size = Config.UISize
    Background.Position = Config.UIPosition
    Background.Parent = ScreenGui
    
    -- Cantos arredondados
    local BorderCorner = Instance.new("UICorner")
    BorderCorner.CornerRadius = UDim.new(0, 8)
    BorderCorner.Parent = Background
    
    -- Borda
    local BorderStroke = Instance.new("UIStroke")
    BorderStroke.Color = Config.ColorActive
    BorderStroke.Thickness = 2
    BorderStroke.Parent = Background
    
    -- Status
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Config.ColorActive
    StatusLabel.TextSize = 18
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "ACTIVE"
    StatusLabel.Size = UDim2.new(1, -16, 0, 32)
    StatusLabel.Position = UDim2.new(0, 8, 0, 8)
    StatusLabel.Parent = Background
    
    -- Informações
    InfoLabel = Instance.new("TextLabel")
    InfoLabel.Name = "InfoLabel"
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.Courier
    InfoLabel.Text = "Distance: -- m\nVelocity: -- m/s\nImpact: -- s"
    InfoLabel.Size = UDim2.new(1, -16, 1, -48)
    InfoLabel.Position = UDim2.new(0, 8, 0, 40)
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.Parent = Background
    
    -- Flash (efeito de parry)
    FlashFrame = Instance.new("Frame")
    FlashFrame.Name = "FlashEffect"
    FlashFrame.BackgroundColor3 = Config.ColorParry
    FlashFrame.BackgroundTransparency = 1
    FlashFrame.BorderSizePixel = 0
    FlashFrame.Size = UDim2.new(1, 0, 1, 0)
    FlashFrame.Parent = Background
    
    local FlashCorner = Instance.new("UICorner")
    FlashCorner.CornerRadius = UDim.new(0, 8)
    FlashCorner.Parent = FlashFrame
    
    if Config.Debug then print("[PARRY] UI inicializada") end
end

-- ============================================
-- ATUALIZAR UI
-- ============================================

function UI:UpdateBallInfo(Distance, Velocity, ImpactTime)
    if not InfoLabel then return end
    
    local DistText = string.format("%.1f", math.max(0, Distance))
    local VelText = string.format("%.1f", math.max(0, Velocity))
    local ImpactText = string.format("%.2f", math.max(0, ImpactTime))
    
    if StatusLabel then
        if ImpactTime <= 0.5 then
            StatusLabel.TextColor3 = Config.ColorDanger
        else
            StatusLabel.TextColor3 = Config.ColorActive
        end
    end
    
    InfoLabel.Text = string.format(
        "Distance: %s m\nVelocity: %s m/s\nImpact: %s s",
        DistText, VelText, ImpactText
    )
end

function UI:FlashParry()
    if not FlashFrame then return end
    
    FlashFrame.BackgroundTransparency = 0.3
    
    local Tween = TweenService:Create(
        FlashFrame,
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    Tween:Play()
    
    Tween.Completed:Connect(function()
        pcall(function() Tween:Destroy() end)
    end)
end

function UI:SetStatus(Status)
    if not StatusLabel then return end
    
    StatusLabel.Text = Status
    
    if Status == "ACTIVE" then
        StatusLabel.TextColor3 = Config.ColorActive
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

function UI:Destroy()
    if ScreenGui then
        pcall(function() ScreenGui:Destroy() end)
        ScreenGui = nil
    end
    StatusLabel = nil
    InfoLabel = nil
    FlashFrame = nil
end

return UI

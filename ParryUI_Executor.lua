--[[
    PARRY SYSTEM - UI MODULE (EXECUTOR EDITION)
    For use with multi-loadstring setup
    
    Place on GitHub and load via URLS.UI
    Requires _G.ParryConfig to be set before loading
]]

local Config = _G.ParryConfig or error("[PARRY] Config not found in _G.ParryConfig")
local UI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- UI element references
local ScreenGui = nil
local StatusLabel = nil
local InfoLabel = nil
local FlashFrame = nil

-- ============================================
-- UI INITIALIZATION
-- ============================================

function UI:Init()
    --[[
        Creates the visual overlay with:
        - Status indicator
        - Distance/Velocity/Impact time display
        - Flash effect on parry
    ]]
    
    if not Config.UIEnabled then
        if Config.Debug then
            print("[PARRY] UI disabled in config")
        end
        return
    end
    
    -- Wait for PlayerGui with timeout
    local PlayerGui = nil
    local Attempts = 0
    while not PlayerGui and Attempts < 10 do
        pcall(function()
            PlayerGui = Player:WaitForChild("PlayerGui", 1)
        end)
        Attempts = Attempts + 1
    end
    
    if not PlayerGui then
        warn("[PARRY] PlayerGui not found")
        return
    end
    
    -- Cleanup existing UI
    pcall(function()
        local ExistingGui = PlayerGui:FindFirstChild("ParrySystemUI")
        if ExistingGui then
            ExistingGui:Destroy()
        end
    end)
    
    -- =========== MAIN GUI ===========
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ParrySystemUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    
    -- =========== BACKGROUND PANEL ===========
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.BackgroundColor3 = Config.ColorBackground
    Background.BackgroundTransparency = 1 - Config.UIOpacity
    Background.BorderSizePixel = 0
    Background.Size = Config.UISize
    Background.Position = Config.UIPosition
    Background.Parent = ScreenGui
    
    -- Corner radius effect
    local BorderCorner = Instance.new("UICorner")
    BorderCorner.CornerRadius = UDim.new(0, 8)
    BorderCorner.Parent = Background
    
    -- Border outline
    local BorderStroke = Instance.new("UIStroke")
    BorderStroke.Color = Config.ColorActive
    BorderStroke.Thickness = 2
    BorderStroke.Parent = Background
    
    -- =========== STATUS LABEL ===========
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
    
    -- =========== INFO LABEL ===========
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
    
    -- =========== FLASH EFFECT ===========
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
    
    if Config.Debug then
        print("[PARRY] UI initialized successfully")
    end
end

-- ============================================
-- UI UPDATE FUNCTIONS
-- ============================================

function UI:UpdateBallInfo(Distance, Velocity, ImpactTime)
    --[[
        Updates the info display with current ball metrics
        Color changes based on danger level
    ]]
    
    if not InfoLabel then return end
    
    local DistText = string.format("%.1f", math.max(0, Distance))
    local VelText = string.format("%.1f", math.max(0, Velocity))
    local ImpactText = string.format("%.2f", math.max(0, ImpactTime))
    
    -- Update status color based on impact time
    if StatusLabel then
        if ImpactTime <= 0.5 then
            StatusLabel.TextColor3 = Config.ColorDanger
        else
            StatusLabel.TextColor3 = Config.ColorActive
        end
    end
    
    -- Update info text
    InfoLabel.Text = string.format(
        "Distance: %s m\nVelocity: %s m/s\nImpact: %s s",
        DistText, VelText, ImpactText
    )
end

function UI:FlashParry()
    --[[
        Triggers parry flash effect animation
        Quick cyan flash then fade
    ]]
    
    if not FlashFrame then return end
    
    -- Set initial transparency
    FlashFrame.BackgroundTransparency = 0.3
    
    -- Create tween back to transparent
    local TweenInfo = TweenInfo.new(
        0.15,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local Tween = TweenService:Create(FlashFrame, TweenInfo, {
        BackgroundTransparency = 1
    })
    
    Tween:Play()
    
    -- Cleanup
    Tween.Completed:Connect(function()
        pcall(function()
            Tween:Destroy()
        end)
    end)
end

function UI:SetStatus(Status)
    --[[
        Sets the status text
        Status: "ACTIVE" or "DISABLED"
    ]]
    
    if not StatusLabel then return end
    
    StatusLabel.Text = Status
    
    if Status == "ACTIVE" then
        StatusLabel.TextColor3 = Config.ColorActive
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

function UI:UpdateHealth(HealthPercent)
    --[[
        Updates status with HP percentage
        Used on character respawn
    ]]
    
    if not StatusLabel then return end
    StatusLabel.Text = string.format("HP: %.0f%%", HealthPercent)
end

-- ============================================
-- CLEANUP
-- ============================================

function UI:Destroy()
    --[[
        Cleans up the GUI from the screen
    ]]
    
    if ScreenGui then
        pcall(function()
            ScreenGui:Destroy()
        end)
        ScreenGui = nil
    end
    
    StatusLabel = nil
    InfoLabel = nil
    FlashFrame = nil
    
    if Config.Debug then
        print("[PARRY] UI destroyed")
    end
end

return UI

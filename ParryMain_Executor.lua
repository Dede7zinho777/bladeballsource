--[[
    ROBLOX PARRY SYSTEM - MAIN LOOP (EXECUTOR EDITION)
    For use with multi-loadstring setup
    
    Place on GitHub and load via URLS.MAIN
    Requires _G.ParryConfig, _G.ParryUtils, _G.ParryUI to be set before loading
    
    Usage:
    1. Load ParryConfig
    2. Load ParryUtils (with Config in _G)
    3. Load ParryUI (with Config in _G)
    4. Load this file (with Config, Utils, UI in _G)
]]

-- ============================================
-- DEPENDENCY RESOLUTION
-- ============================================
local Config = _G.ParryConfig or error("[PARRY] Config not found - load ParryConfig first")
local Utils = _G.ParryUtils or error("[PARRY] Utils not found - load ParryUtils first")
local UI = _G.ParryUI or error("[PARRY] UI not found - load ParryUI first")

-- ============================================
-- SERVICES & REFERENCES
-- ============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
if not Player then
    error("[PARRY] LocalPlayer not found - run in-game")
end

-- Safe reference retrieval
local function SafeWaitForChild(parent, name, timeout)
    timeout = timeout or 5
    if not parent then return nil end
    return parent:FindFirstChild(name) or (pcall(function() return parent:WaitForChild(name, timeout) end) and parent:FindFirstChild(name)) or nil
end

local Balls = SafeWaitForChild(workspace, "Balls", 5)
local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes", 5)
local ParryRemote = Remotes and SafeWaitForChild(Remotes, "ParryButtonPress", 5) or nil

if Config.Debug then
    print("[PARRY] Service references initialized")
    print("[PARRY] Balls folder: " .. (Balls and Balls.Name or "NOT FOUND"))
    print("[PARRY] ParryRemote: " .. (ParryRemote and ParryRemote.Name or "NOT FOUND"))
end

-- ============================================
-- STATE MANAGEMENT
-- ============================================
local ActiveBalls = {}
local SystemEnabled = true
local Connections = {}

-- ============================================
-- BALL TRACKING
-- ============================================

local function TrackBall(Ball)
    --[[
        Registers a new ball and begins tracking its movement
        Calculates velocity and impact time on each position update
    ]]
    
    if not Utils:VerifyBall(Ball) then return end
    
    local BallData = {
        Instance = Ball,
        OldPosition = Ball.Position,
        OldTick = tick(),
        Created = tick(),
        LastVelocity = 0,
        PredictedImpact = math.huge,
        Connections = {}
    }
    
    ActiveBalls[Ball] = BallData
    
    if Config.Debug then
        print("[PARRY] Ball spawned: " .. Ball.Name)
    end
    
    -- =========== POSITION CHANGE DETECTION ===========
    local PositionConn = Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if not ActiveBalls[Ball] then return end
        if not Utils:IsTarget() then return end
        if not SystemEnabled then return end
        
        local BallData = ActiveBalls[Ball]
        local CameraFocus = workspace.CurrentCamera.Focus.Position
        local Distance = (Ball.Position - CameraFocus).Magnitude
        local TimeDelta = tick() - BallData.OldTick
        
        -- Update velocity every frame threshold
        if TimeDelta >= Config.VelocityUpdateInterval then
            BallData.LastVelocity = (BallData.OldPosition - Ball.Position).Magnitude / TimeDelta
            BallData.OldTick = tick()
            BallData.OldPosition = Ball.Position
        end
        
        -- Predict impact time
        if BallData.LastVelocity > 0 then
            BallData.PredictedImpact = Distance / BallData.LastVelocity
        end
        
        -- Update UI
        UI:UpdateBallInfo(Distance, BallData.LastVelocity, BallData.PredictedImpact)
        
        -- PARRY TRIGGER
        if BallData.PredictedImpact <= Config.ParryThreshold then
            if Utils:Parry() then
                UI:FlashParry()
                
                if Config.Debug then
                    print("[PARRY] TRIGGERED - Impact in " .. string.format("%.3f", BallData.PredictedImpact) .. "s")
                end
            end
        end
    end)
    
    BallData.Connections.Position = PositionConn
    
    -- =========== DESTRUCTION DETECTION ===========
    local AncestryConn = Ball.AncestryChanged:Connect(function(_, Parent)
        if Parent == nil then
            -- Ball destroyed - cleanup
            if BallData.Connections.Position then
                BallData.Connections.Position:Disconnect()
            end
            if BallData.Connections.Ancestry then
                BallData.Connections.Ancestry:Disconnect()
            end
            ActiveBalls[Ball] = nil
            
            if Config.Debug then
                print("[PARRY] Ball destroyed: " .. Ball.Name)
            end
        end
    end)
    
    BallData.Connections.Ancestry = AncestryConn
end

-- ============================================
-- BALL SPAWN MONITORING
-- ============================================

local BallMonitor = nil
if Balls then
    BallMonitor = Balls.ChildAdded:Connect(function(Ball)
        TrackBall(Ball)
    end)
    table.insert(Connections, BallMonitor)
    
    if Config.Debug then
        print("[PARRY] Ball monitor started")
    end
end

-- ============================================
-- CHARACTER RESPAWN HANDLING
-- ============================================

local CharRespawnConn = Player.CharacterAdded:Connect(function(NewCharacter)
    -- Clear active balls on respawn
    for Ball, BallData in pairs(ActiveBalls) do
        if BallData.Connections.Position then
            BallData.Connections.Position:Disconnect()
        end
        if BallData.Connections.Ancestry then
            BallData.Connections.Ancestry:Disconnect()
        end
    end
    ActiveBalls = {}
    
    if Config.Debug then
        print("[PARRY] Character respawned - cleared ball tracking")
    end
end)

table.insert(Connections, CharRespawnConn)

-- ============================================
-- KEYBOARD INPUT
-- ============================================

local KeyInputConn = Player:GetMouse().KeyDown:Connect(function(Key)
    if Key:lower() == Config.ToggleKey:lower() then
        SystemEnabled = not SystemEnabled
        UI:SetStatus(SystemEnabled and "ACTIVE" or "DISABLED")
        
        if Config.Debug then
            print("[PARRY] System toggled: " .. (SystemEnabled and "ON" or "OFF"))
        end
    end
end)

table.insert(Connections, KeyInputConn)

-- ============================================
-- INITIALIZATION
-- ============================================

UI:Init()

if Config.Debug then
    print("[PARRY] ========================================")
    print("[PARRY] PARRY SYSTEM INITIALIZED")
    print("[PARRY] Press " .. Config.ToggleKey .. " to toggle")
    print("[PARRY] Debug mode: ENABLED")
    print("[PARRY] ========================================")
end

-- ============================================
-- CLEANUP FUNCTION
-- ============================================

local function Cleanup()
    print("[PARRY] Cleaning up system...")
    
    -- Disconnect all connections
    for _, Connection in ipairs(Connections) do
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end
    Connections = {}
    
    -- Cleanup all ball connections
    for Ball, BallData in pairs(ActiveBalls) do
        if BallData.Connections.Position and BallData.Connections.Position.Connected then
            BallData.Connections.Position:Disconnect()
        end
        if BallData.Connections.Ancestry and BallData.Connections.Ancestry.Connected then
            BallData.Connections.Ancestry:Disconnect()
        end
    end
    ActiveBalls = {}
    
    -- Destroy UI
    UI:Destroy()
    
    if Config.Debug then
        print("[PARRY] System cleaned up successfully")
    end
end

-- Cleanup when player leaves (if applicable)
Player.Destroying:Connect(Cleanup)

-- ============================================
-- RETURN SYSTEM TABLE (for reloading)
-- ============================================

return {
    IsEnabled = function() return SystemEnabled end,
    Toggle = function()
        SystemEnabled = not SystemEnabled
        UI:SetStatus(SystemEnabled and "ACTIVE" or "DISABLED")
    end,
    Cleanup = Cleanup,
    Config = Config,
    ActiveBalls = ActiveBalls,
}

--[[
    PARRY SYSTEM - UTILITIES MODULE (EXECUTOR EDITION)
    For use with multi-loadstring setup
    
    Place on GitHub and load via URLS.UTILS
    Requires _G.ParryConfig to be set before loading
]]

local Config = _G.ParryConfig or error("[PARRY] Config not found in _G.ParryConfig")
local Utils = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Safe reference retrieval
local function SafeWaitForChild(parent, name, timeout)
    timeout = timeout or 5
    if not parent then return nil end
    return parent:FindFirstChild(name) or (pcall(function() return parent:WaitForChild(name, timeout) end) and parent:FindFirstChild(name)) or nil
end

-- Cached service references
local Balls = SafeWaitForChild(workspace, "Balls", 5)
local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes", 5)
local ParryRemote = Remotes and SafeWaitForChild(Remotes, "ParryButtonPress", 5) or nil

-- ============================================
-- VERIFICATION FUNCTIONS
-- ============================================

function Utils:VerifyBall(Ball)
    --[[ 
        Validates ball instance:
        - Must be a BasePart
        - Must be in Balls folder
        - Must have realBall attribute set to true
    ]]
    
    if typeof(Ball) ~= "Instance" then
        return false
    end
    
    if not Ball:IsA("BasePart") then
        return false
    end
    
    if Balls and not Ball:IsDescendantOf(Balls) then
        return false
    end
    
    if Ball:GetAttribute("realBall") ~= true then
        return false
    end
    
    return true
end

function Utils:IsTarget()
    --[[
        Checks if player character is currently the target
        Target is indicated by a Highlight instance in character
    ]]
    
    if not Player or not Player.Character then
        return false
    end
    
    local Highlight = Player.Character:FindFirstChild("Highlight")
    return Highlight ~= nil
end

-- ============================================
-- REMOTE EXECUTION
-- ============================================

function Utils:Parry()
    --[[
        Triggers parry by firing ParryButtonPress remote
        Handles errors gracefully
    ]]
    
    if not ParryRemote then
        if Config.Debug then
            warn("[PARRY] ParryButtonPress remote not found")
        end
        return false
    end
    
    local Success = pcall(function()
        ParryRemote:Fire()
    end)
    
    if not Success and Config.Debug then
        warn("[PARRY] Failed to fire ParryButtonPress remote")
    end
    
    return Success
end

-- ============================================
-- PHYSICS CALCULATIONS
-- ============================================

function Utils:CalculateVelocity(OldPos, NewPos, TimeDelta)
    --[[
        Calculate ball velocity from position delta
        Safe division with zero-check
    ]]
    
    if TimeDelta <= 0 then
        return 0
    end
    
    local Distance = (OldPos - NewPos).Magnitude
    return Distance / TimeDelta
end

function Utils:PredictImpactTime(Distance, Velocity)
    --[[
        Predict time until ball impact
        Returns math.huge if velocity is zero (stationary ball)
    ]]
    
    if Velocity <= 0 then
        return math.huge
    end
    
    return Distance / Velocity
end

return Utils

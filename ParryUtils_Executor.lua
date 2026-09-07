--[[
    PARRY SYSTEM - UTILITÁRIOS (XENO EDITION)
]]

local Config = _G.ParryConfig or error("[PARRY] Config não encontrado")
local Utils = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Função segura para encontrar filhos
local function SafeWaitForChild(parent, name, timeout)
    timeout = timeout or 5
    if not parent then return nil end
    local child = parent:FindFirstChild(name)
    if child then return child end
    local success, result = pcall(function()
        return parent:WaitForChild(name, timeout)
    end)
    return success and result or nil
end

-- Referências em cache
local Balls = SafeWaitForChild(workspace, "Balls", 5)
local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes", 5)
local ParryRemote = Remotes and SafeWaitForChild(Remotes, "ParryButtonPress", 5) or nil

if Config.Debug then
    print("[PARRY] Balls encontrado: " .. tostring(Balls ~= nil))
    print("[PARRY] ParryRemote encontrado: " .. tostring(ParryRemote ~= nil))
end

-- ============================================
-- VERIFICAÇÕES
-- ============================================

function Utils:VerifyBall(Ball)
    if typeof(Ball) ~= "Instance" then return false end
    if not Ball:IsA("BasePart") then return false end
    if Balls and not Ball:IsDescendantOf(Balls) then return false end
    if Ball:GetAttribute("realBall") ~= true then return false end
    return true
end

function Utils:IsTarget()
    if not Player or not Player.Character then return false end
    local Highlight = Player.Character:FindFirstChild("Highlight")
    return Highlight ~= nil
end

-- ============================================
-- EXECUTAR PARRY
-- ============================================

function Utils:Parry()
    if not ParryRemote then
        if Config.Debug then warn("[PARRY] ParryButtonPress não encontrado") end
        return false
    end
    
    local Success = pcall(function()
        ParryRemote:FireServer()  -- Alguns jogos usam FireServer
        -- ParryRemote:Fire()     -- Outros usam Fire
    end)
    
    if not Success and Config.Debug then
        warn("[PARRY] Falha ao executar parry")
    end
    
    return Success
end

-- ============================================
-- CÁLCULOS FÍSICOS
-- ============================================

function Utils:CalculateVelocity(OldPos, NewPos, TimeDelta)
    if TimeDelta <= 0 then return 0 end
    return (OldPos - NewPos).Magnitude / TimeDelta
end

function Utils:PredictImpactTime(Distance, Velocity)
    if Velocity <= 0 then return math.huge end
    return Distance / Velocity
end

return Utils

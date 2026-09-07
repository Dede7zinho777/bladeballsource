--[[
    PARRY SYSTEM - PRINCIPAL (XENO EDITION)
]]

local Config = _G.ParryConfig or error("[PARRY] Config não encontrado")
local Utils = _G.ParryUtils or error("[PARRY] Utils não encontrado")
local UI = _G.ParryUI or error("[PARRY] UI não encontrado")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
if not Player then error("[PARRY] Player não encontrado") end

-- ============================================
-- REFERÊNCIAS
-- ============================================

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

local Balls = SafeWaitForChild(workspace, "Balls", 5)
local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes", 5)
local ParryRemote = Remotes and SafeWaitForChild(Remotes, "ParryButtonPress", 5) or nil

if Config.Debug then
    print("[PARRY] Balls: " .. (Balls and Balls.Name or "NÃO ENCONTRADO"))
    print("[PARRY] ParryRemote: " .. (ParryRemote and ParryRemote.Name or "NÃO ENCONTRADO"))
end

-- ============================================
-- ESTADO
-- ============================================

local ActiveBalls = {}
local SystemEnabled = true
local Connections = {}

-- ============================================
-- RASTREAMENTO DE BOLAS
-- ============================================

local function TrackBall(Ball)
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
    
    if Config.Debug then print("[PARRY] Bola detectada: " .. Ball.Name) end
    
    -- Monitorar posição
    local PositionConn = Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if not ActiveBalls[Ball] then return end
        if not Utils:IsTarget() then return end
        if not SystemEnabled then return end
        
        local BallData = ActiveBalls[Ball]
        local CameraFocus = workspace.CurrentCamera.Focus.Position
        local Distance = (Ball.Position - CameraFocus).Magnitude
        local TimeDelta = tick() - BallData.OldTick
        
        if TimeDelta >= Config.VelocityUpdateInterval then
            BallData.LastVelocity = (BallData.OldPosition - Ball.Position).Magnitude / TimeDelta
            BallData.OldTick = tick()
            BallData.OldPosition = Ball.Position
        end
        
        if BallData.LastVelocity > 0 then
            BallData.PredictedImpact = Distance / BallData.LastVelocity
        end
        
        UI:UpdateBallInfo(Distance, BallData.LastVelocity, BallData.PredictedImpact)
        
        -- TRIGGER PARRY
        if BallData.PredictedImpact <= Config.ParryThreshold then
            if Utils:Parry() then
                UI:FlashParry()
                if Config.Debug then
                    print("[PARRY] ⚡ PARRY ATIVADO! Impacto em " .. string.format("%.3f", BallData.PredictedImpact) .. "s")
                end
            end
        end
    end)
    
    BallData.Connections.Position = PositionConn
    
    -- Monitorar destruição
    local AncestryConn = Ball.AncestryChanged:Connect(function(_, Parent)
        if Parent == nil then
            if BallData.Connections.Position then BallData.Connections.Position:Disconnect() end
            if BallData.Connections.Ancestry then BallData.Connections.Ancestry:Disconnect() end
            ActiveBalls[Ball] = nil
            if Config.Debug then print("[PARRY] Bola destruída: " .. Ball.Name) end
        end
    end)
    
    BallData.Connections.Ancestry = AncestryConn
end

-- ============================================
-- MONITORAR SPAWN DE BOLAS
-- ============================================

if Balls then
    local BallMonitor = Balls.ChildAdded:Connect(function(Ball)
        TrackBall(Ball)
    end)
    table.insert(Connections, BallMonitor)
    if Config.Debug then print("[PARRY] Monitor de bolas ativo") end
end

-- ============================================
-- RESPAWN DO PERSONAGEM
-- ============================================

local CharRespawnConn = Player.CharacterAdded:Connect(function()
    for Ball, BallData in pairs(ActiveBalls) do
        if BallData.Connections.Position then BallData.Connections.Position:Disconnect() end
        if BallData.Connections.Ancestry then BallData.Connections.Ancestry:Disconnect() end
    end
    ActiveBalls = {}
    if Config.Debug then print("[PARRY] Personagem reviveu - bolas limpas") end
end)
table.insert(Connections, CharRespawnConn)

-- ============================================
-- TECLA PARA ATIVAR/DESATIVAR
-- ============================================

local KeyInputConn = Player:GetMouse().KeyDown:Connect(function(Key)
    if Key:lower() == Config.ToggleKey:lower() then
        SystemEnabled = not SystemEnabled
        UI:SetStatus(SystemEnabled and "ACTIVE" or "DISABLED")
        if Config.Debug then print("[PARRY] Sistema " .. (SystemEnabled and "ATIVADO" or "DESATIVADO")) end
    end
end)
table.insert(Connections, KeyInputConn)

-- ============================================
-- INICIALIZAR
-- ============================================

UI:Init()

print("[PARRY] ========================================")
print("[PARRY] ✅ SISTEMA DE PARRY ATIVADO!")
print("[PARRY] 📌 Pressione " .. Config.ToggleKey .. " para ativar/desativar")
print("[PARRY] ========================================")

-- ============================================
-- LIMPEZA
-- ============================================

local function Cleanup()
    print("[PARRY] 🧹 Limpando sistema...")
    
    for _, Connection in ipairs(Connections) do
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end
    Connections = {}
    
    for Ball, BallData in pairs(ActiveBalls) do
        if BallData.Connections.Position and BallData.Connections.Position.Connected then
            BallData.Connections.Position:Disconnect()
        end
        if BallData.Connections.Ancestry and BallData.Connections.Ancestry.Connected then
            BallData.Connections.Ancestry:Disconnect()
        end
    end
    ActiveBalls = {}
    
    UI:Destroy()
end

Player.Destroying:Connect(Cleanup)

return {
    IsEnabled = function() return SystemEnabled end,
    Toggle = function()
        SystemEnabled = not SystemEnabled
        UI:SetStatus(SystemEnabled and "ACTIVE" or "DISABLED")
    end,
    Cleanup = Cleanup,
}

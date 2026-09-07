-- ============================================
-- SISTEMA DE PARRY - VERSÃO CORRIGIDA
-- ============================================

-- 1. VERIFICAÇÃO DO HTTPSERVICE
local HttpService = game:GetService("HttpService")
if not HttpService.HttpEnabled then
    pcall(function()
        HttpService.HttpEnabled = true
    end)
end

-- 2. URLS CORRETAS (já configuradas)
local URLS = {
    CONFIG = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryConfig_Executor.lua",
    UTILS = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryUtils_Executor.lua",
    UI = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryUI_Executor.lua",
    MAIN = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryMain_Executor.lua",
}

-- 3. FUNÇÃO PARA BAIXAR COM RETRY
local function LoadFromURL(url, retries)
    retries = retries or 3
    local lastError = nil
    
    for attempt = 1, retries do
        local success, content = pcall(function()
            return HttpService:GetAsync(url)
        end)
        
        if success then
            return content
        else
            lastError = content
            if attempt < retries then
                wait(0.5 * attempt)  -- Espera progressiva
            end
        end
    end
    
    error("[PARRY] Failed to load after " .. retries .. " attempts: " .. tostring(lastError))
end

-- 4. INICIALIZAR SISTEMA
print("[PARRY] 🔄 Loading Parry System...")

-- Criar tabela única para o sistema
if not _G.ParrySystem then
    _G.ParrySystem = {}
end

-- Carregar Config
local ConfigScript = LoadFromURL(URLS.CONFIG)
local Config = loadstring(ConfigScript)()
if not Config then
    error("[PARRY] ❌ Failed to load Config")
end
_G.ParrySystem.Config = Config
print("[PARRY] ✅ Config loaded")

-- Carregar Utils
local UtilsScript = LoadFromURL(URLS.UTILS)
_G.ParrySystem.Config = Config  -- Config precisa estar disponível
local Utils = loadstring(UtilsScript)()
if not Utils then
    error("[PARRY] ❌ Failed to load Utils")
end
_G.ParrySystem.Utils = Utils
print("[PARRY] ✅ Utils loaded")

-- Carregar UI
local UIScript = LoadFromURL(URLS.UI)
_G.ParrySystem.Config = Config
local UI = loadstring(UIScript)()
if not UI then
    error("[PARRY] ❌ Failed to load UI")
end
_G.ParrySystem.UI = UI
print("[PARRY] ✅ UI loaded")

-- Carregar Main
local MainScript = LoadFromURL(URLS.MAIN)
_G.ParrySystem.Config = Config
_G.ParrySystem.Utils = Utils
_G.ParrySystem.UI = UI
local Main = loadstring(MainScript)()
if not Main then
    error("[PARRY] ❌ Failed to load Main")
end
_G.ParrySystem.Main = Main
print("[PARRY] ✅ Main system loaded")

print("[PARRY] ========================================")
print("[PARRY] ✅ SISTEMA DE PARRY ATIVADO!")
print("[PARRY] 📌 Pressione P para ativar/desativar")
print("[PARRY] 🔧 Debug: " .. (Config.Debug and "ON" or "OFF"))
print("[PARRY] ========================================")

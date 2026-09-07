--[[
    ROBLOX PARRY SYSTEM - XENO EDITION
    Versão corrigida para funcionar no Xeno
]]

print("[PARRY] 🔄 Carregando Sistema de Parry...")

-- ============================================
-- URLs CORRETAS (seu repositório)
-- ============================================
local URLS = {
    CONFIG = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryConfig_Executor.lua",
    UTILS = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryUtils_Executor.lua",
    UI = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryUI_Executor.lua",
    MAIN = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryMain_Executor.lua",
}

-- ============================================
-- FUNÇÃO DE DOWNLOAD PARA XENO
-- ============================================
local function LoadFromURL(url)
    local success, content = pcall(function()
        return game:HttpGet(url)  -- Xeno usa game:HttpGet
    end)
    
    if not success then
        error("[PARRY] ❌ Erro ao baixar: " .. url)
    end
    
    return content
end

-- ============================================
-- CARREGAR MÓDULOS
-- ============================================
print("[PARRY] 📥 Baixando Config...")
local ConfigScript = LoadFromURL(URLS.CONFIG)
local Config = loadstring(ConfigScript)()
if not Config then error("[PARRY] ❌ Config falhou") end
_G.ParryConfig = Config
print("[PARRY] ✅ Config carregado")

print("[PARRY] 📥 Baixando Utils...")
local UtilsScript = LoadFromURL(URLS.UTILS)
_G.ParryConfig = Config
local Utils = loadstring(UtilsScript)()
if not Utils then error("[PARRY] ❌ Utils falhou") end
_G.ParryUtils = Utils
print("[PARRY] ✅ Utils carregado")

print("[PARRY] 📥 Baixando UI...")
local UIScript = LoadFromURL(URLS.UI)
_G.ParryConfig = Config
local UI = loadstring(UIScript)()
if not UI then error("[PARRY] ❌ UI falhou") end
_G.ParryUI = UI
print("[PARRY] ✅ UI carregado")

print("[PARRY] 📥 Baixando Main...")
local MainScript = LoadFromURL(URLS.MAIN)
_G.ParryConfig = Config
_G.ParryUtils = Utils
_G.ParryUI = UI
local Main = loadstring(MainScript)()
if not Main then error("[PARRY] ❌ Main falhou") end
print("[PARRY] ✅ Main carregado")

print("[PARRY] ========================================")
print("[PARRY] ✅ SISTEMA DE PARRY ATIVADO!")
print("[PARRY] 📌 Pressione P para ativar/desativar")
print("[PARRY] ========================================")

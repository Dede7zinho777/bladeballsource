-- ============================================
-- SISTEMA DE PARRY - VERSÃO CORRIGIDA
-- Compatível com Xeno, Synapse, Script-Ware
-- ============================================

print("[PARRY] 🔄 Carregando Sistema de Parry...")

-- 1. FUNÇÃO UNIVERSAL PARA BAIXAR
local function DownloadScript(url)
    local methods = {
        -- Método 1: game:HttpGet (mais comum)
        function()
            return game:HttpGet(url)
        end,
        
        -- Método 2: HttpService
        function()
            local http = game:GetService("HttpService")
            if http.HttpEnabled then
                return http:GetAsync(url)
            end
        end,
        
        -- Método 3: syn.request (Synapse X)
        function()
            if syn and syn.request then
                local response = syn.request({
                    Url = url,
                    Method = "GET"
                })
                return response.Body
            end
        end,
        
        -- Método 4: request (Script-Ware / Xeno)
        function()
            if request then
                local response = request({
                    Url = url,
                    Method = "GET"
                })
                return response.Body
            end
        end
    }
    
    for i, method in ipairs(methods) do
        local success, result = pcall(method)
        if success and result and type(result) == "string" and #result > 10 then
            return result
        end
    end
    
    error("[PARRY] ❌ Não foi possível baixar: " .. url)
end

-- 2. URLS
local URLS = {
    CONFIG = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryConfig_Executor.lua",
    UTILS = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryUtils_Executor.lua",
    UI = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryUI_Executor.lua",
    MAIN = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryMain_Executor.lua",
}

-- 3. CARREGAR MÓDULOS
local function LoadModule(url, name)
    print("[PARRY] 📥 Baixando " .. name .. "...")
    local code = DownloadScript(url)
    local module = loadstring(code)
    if not module then
        error("[PARRY] ❌ Erro ao compilar " .. name)
    end
    return module()
end

-- Criar sistema global
if not _G.ParrySystem then
    _G.ParrySystem = {}
end

-- Carregar tudo
local Config = LoadModule(URLS.CONFIG, "Config")
_G.ParrySystem.Config = Config

_G.ParrySystem.Config = Config
local Utils = LoadModule(URLS.UTILS, "Utils")
_G.ParrySystem.Utils = Utils

_G.ParrySystem.Config = Config
local UI = LoadModule(URLS.UI, "UI")
_G.ParrySystem.UI = UI

_G.ParrySystem.Config = Config
_G.ParrySystem.Utils = Utils
_G.ParrySystem.UI = UI
local Main = LoadModule(URLS.MAIN, "Main")
_G.ParrySystem.Main = Main

print("[PARRY] ========================================")
print("[PARRY] ✅ SISTEMA DE PARRY ATIVADO!")
print("[PARRY] 📌 Pressione P para ativar/desativar")
print("[PARRY] ========================================")

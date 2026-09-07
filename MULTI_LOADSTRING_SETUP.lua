--[[
    ROBLOX PARRY SYSTEM - MULTI-LOADSTRING EXECUTOR EDITION
    
    This file shows how to load the Parry System from GitHub using raw URLs.
    Each component loads independently, allowing for easy updates without re-executing.
    
    SETUP INSTRUCTIONS:
    
    1. Fork/create a GitHub repo and upload these 4 files:
       - ParryConfig_Executor.lua
       - ParryUtils_Executor.lua
       - ParryUI_Executor.lua
       - ParryMain_Executor.lua
    
    2. Get the RAW URL for each file (click "Raw" button on GitHub)
    3. Replace the URLs below with your versions
    4. Copy THIS ENTIRE FILE into your executor
    5. Execute
    
    EXAMPLE RAW URLS:
    CONFIG: https://raw.githubusercontent.com/YOUR_USERNAME/ParrySystem/main/ParryConfig_Executor.lua
    UTILS:  https://raw.githubusercontent.com/YOUR_USERNAME/ParrySystem/main/ParryUtils_Executor.lua
    UI:     https://raw.githubusercontent.com/YOUR_USERNAME/ParrySystem/main/ParryUI_Executor.lua
    MAIN:   https://raw.githubusercontent.com/YOUR_USERNAME/ParrySystem/main/ParryMain_Executor.lua
]]

-- ============================================
-- CONFIGURATION: UPDATE THESE URLS
-- ============================================
local URLS = {
    CONFIG = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryConfig_Executor.lua",
    UTILS = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryUtils_Executor.lua",
    UI = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryUI_Executor.lua",
    MAIN = "https://raw.githubusercontent.com/Dede7zinho777/bladeballsource/refs/heads/main/ParryMain_Executor.lua",
}

-- ============================================
-- HTTP REQUEST HELPER
-- ============================================
local function LoadFromURL(url)
    local Success = false
    local Content = nil
    
    -- Try using HttpService (Xeno, Synapse, etc.)
    pcall(function()
        local HttpService = game:GetService("HttpService")
        if HttpService.HttpEnabled then
            Content = HttpService:GetAsync(url)
            Success = true
        end
    end)
    
    if not Success then
        error("[PARRY] Failed to load from URL: " .. url)
    end
    
    return Content
end

-- ============================================
-- LOAD & EXECUTE MODULES
-- ============================================
print("[PARRY] Loading modules from GitHub...")

-- Load config
local ConfigScript = LoadFromURL(URLS.CONFIG)
local Config = loadstring(ConfigScript)()
print("[PARRY] ✓ Config loaded")

-- Load utils (requires config in global scope)
local UtilsScript = LoadFromURL(URLS.UTILS)
_G.ParryConfig = Config
local Utils = loadstring(UtilsScript)()
print("[PARRY] ✓ Utils loaded")

-- Load UI (requires config in global scope)
local UIScript = LoadFromURL(URLS.UI)
_G.ParryConfig = Config
local UI = loadstring(UIScript)()
print("[PARRY] ✓ UI loaded")

-- Load main (requires config, utils, ui in global scope)
local MainScript = LoadFromURL(URLS.MAIN)
_G.ParryConfig = Config
_G.ParryUtils = Utils
_G.ParryUI = UI
loadstring(MainScript)()
print("[PARRY] ✓ Main system loaded")

print("[PARRY] ========================================")
print("[PARRY] PARRY SYSTEM LOADED")
print("[PARRY] Press P to toggle")
print("[PARRY] ========================================")

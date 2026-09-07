--[[
    PARRY SYSTEM - CONFIGURATION MODULE (EXECUTOR EDITION)
    For use with multi-loadstring setup
    
    Place on GitHub or use directly in _G.ParryConfig
]]

return {
    -- PARRY BEHAVIOR
    ParryThreshold = 0.35,              -- Seconds before impact to trigger parry (lower = more aggressive)
    VelocityUpdateInterval = 1/60,      -- Update velocity calculation every frame
    
    -- UI SETTINGS
    UIEnabled = true,                   -- Show visual overlay
    UIOpacity = 0.9,                    -- UI transparency (0-1)
    UIPosition = UDim2.new(0.5, -150, 0.1, 0),  -- Screen position (X, Y)
    UISize = UDim2.new(0, 300, 0, 120),         -- Width, Height
    
    -- COLORS (RGB)
    ColorActive = Color3.fromRGB(0, 255, 100),      -- Green - system active
    ColorDanger = Color3.fromRGB(255, 100, 0),     -- Orange - ball incoming
    ColorParry = Color3.fromRGB(0, 200, 255),      -- Cyan - parry triggered
    ColorBackground = Color3.fromRGB(20, 20, 20),  -- Dark gray background
    
    -- CONTROLS
    ToggleKey = "P",                    -- Key to enable/disable system
    
    -- DEBUG
    Debug = false,                      -- Set to true for console messages
}

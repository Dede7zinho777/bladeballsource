--[[
    PARRY SYSTEM - CONFIGURAÇÃO (XENO EDITION)
]]

return {
    -- PARRY BEHAVIOR
    ParryThreshold = 0.35,              -- Segundos antes do impacto (menor = mais difícil)
    VelocityUpdateInterval = 1/60,      -- Atualiza a cada frame
    
    -- UI SETTINGS
    UIEnabled = true,                   -- Mostrar interface
    UIOpacity = 0.9,                    -- Transparência (0-1)
    UIPosition = UDim2.new(0.5, -150, 0.1, 0),
    UISize = UDim2.new(0, 300, 0, 120),
    
    -- COLORS
    ColorActive = Color3.fromRGB(0, 255, 100),      -- Verde
    ColorDanger = Color3.fromRGB(255, 100, 0),     -- Laranja
    ColorParry = Color3.fromRGB(0, 200, 255),      -- Ciano
    ColorBackground = Color3.fromRGB(20, 20, 20),  -- Cinza escuro
    
    -- CONTROLS
    ToggleKey = "P",                    -- Tecla para ativar/desativar
    
    -- DEBUG
    Debug = false,                      -- true para mensagens no console
}

--[[
  UNC AutoFarm Loader
  Version: 1.0
  GitHub: https://github.com/yourname/yourrepo
]]

local function loadAutoFarm()
    local repoURL = "https://raw.githubusercontent.com/yourname/yourrepo/main/AutoFarm.lua"
    local fallbackURL = "https://cdn.jsdelivr.net/gh/yourname/yourrepo@main/AutoFarm.lua"
    
    local function loadScript(url)
        local success, content = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if success then
            local fn, err = loadstring(content)
            if fn then
                return fn()
            end
            error("Compilation error: "..err)
        end
        error("Failed to load script from "..url)
    end

    -- Попытка загрузки с разных источников
    local loaded, result = pcall(loadScript, repoURL)
    if not loaded then
        loaded, result = pcall(loadScript, fallbackURL)
    end
    
    if not loaded then
        return warn("AutoFarm failed to load:\n"..result)
    end
    
    return result
end

-- Запуск системы
if not AutoFarm then
    AutoFarm = loadAutoFarm()
end

return AutoFarm

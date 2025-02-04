local config = {
    Enabled = false,
    ShowGUI = true,
    CollectDelay = {1, 3},
    AntiAFK = true,
    Logging = true
}

--[[
  ██████╗ ██╗   ██╗██╗
 ██╔════╝ ██║   ██║██║
 ██║  ███╗██║   ██║██║
 ██║   ██║██║   ██║██║
 ╚██████╔╝╚██████╔╝██║
  ╚═════╝  ╚═════╝ ╚═╝
]]

local GUI = {
    Main = {
        Background = Drawing.new("Square"),
        Title = Drawing.new("Text"),
        ToggleBtn = Drawing.new("Circle")
    },
    Elements = {
        FarmToggle = createGUIElement("Farm", 1),
        AntiAFKToggle = createGUIElement("Anti-AFK", 2),
        LoggingToggle = createGUIElement("Logging", 3),
        DelaySlider = createSliderElement("Delay", 4)
    },
    Minimized = false
}

function createGUIElement(name, order)
    local yPos = 45 + (order-1)*25
    return {
        Text = Drawing.new("Text"),
        Checkbox = Drawing.new("Square"),
        Active = false
    }
end

function createSliderElement(name, order)
    local yPos = 45 + (order-1)*25
    return {
        Text = Drawing.new("Text"),
        Bar = Drawing.new("Square"),
        Handle = Drawing.new("Circle"),
        Value = 1
    }
end

-- Инициализация GUI
function initGUI()
    -- Основной фон
    GUI.Main.Background.Size = Vector2.new(200, 200)
    GUI.Main.Background.Position = Vector2.new(50, 50)
    GUI.Main.Background.Color = Color3.fromRGB(40, 40, 40)
    GUI.Main.Background.Transparency = 0.6
    
    -- Заголовок
    GUI.Main.Title.Text = "AutoFarm v2.0"
    GUI.Main.Title.Position = Vector2.new(60, 55)
    GUI.Main.Title.Color = Color3.new(1,1,1)
    GUI.Main.Title.Size = 18
    
    -- Кнопка свернуть/развернуть
    GUI.Main.ToggleBtn.Position = Vector2.new(230, 55)
    GUI.Main.ToggleBtn.Radius = 5
    GUI.Main.ToggleBtn.Color = Color3.new(0.2,0.7,0.3)
    
    -- Динамическое создание элементов
    for _, element in pairs(GUI.Elements) do
        element.Text.Size = 14
        element.Text.Outline = true
        element.Checkbox.Size = Vector2.new(15,15)
    end
end

--[[
  ██████╗ ██╗   ██╗██████╗ 
 ██╔═══██╗██║   ██║██╔══██╗
 ██║   ██║██║   ██║██████╔╝
 ██║   ██║██║   ██║██╔═══╝ 
 ╚██████╔╝╚██████╔╝██║     
  ╚═════╝  ╚═════╝ ╚═╝     
]]

local mouse = {
    Down = false,
    Position = Vector2.new(0,0),
    LastClick = 0
}

function updateGUIInput()
    if isrbxactive() then
        local mousePos = getmousepos()
        local now = os.clock()
        
        -- Проверка клика по GUI
        if ismouseclick() and (now - mouse.LastClick) > 0.2 then
            mouse.Down = true
            mouse.Position = mousePos
            processClick(mousePos)
            mouse.LastClick = now
        end
        
        -- Перетаскивание GUI
        if mouse.Down then
            local delta = mousePos - mouse.Position
            GUI.Main.Background.Position += delta
            updateElementsPosition()
            mouse.Position = mousePos
        end
    end
end

function processClick(pos)
    -- Проверка кнопки свернуть/развернуть
    if isInCircle(pos, GUI.Main.ToggleBtn) then
        GUI.Minimized = not GUI.Minimized
        toggleElementsVisibility()
    end
    
    -- Проверка элементов управления
    for name, element in pairs(GUI.Elements) do
        if isInSquare(pos, element.Checkbox) then
            config[name] = not config[name]
            updateElementState(name)
        end
    end
end

--[[
  ██╗  ██╗███████╗██╗   ██╗
  ██║ ██╔╝██╔════╝╚██╗ ██╔╝
  █████╔╝ █████╗   ╚████╔╝ 
  ██╔═██╗ ██╔══╝    ╚██╔╝  
  ██║  ██╗███████╗   ██║   
  ╚═╝  ╚═╝╚══════╝   ╚═╝   
]]

function toggleElementsVisibility()
    for _, element in pairs(GUI.Elements) do
        element.Text.Visible = not GUI.Minimized
        element.Checkbox.Visible = not GUI.Minimized
    end
end

function updateElementState(name)
    local element = GUI.Elements[name]
    element.Checkbox.Color = config[name] and Color3.new(0,1,0) or Color3.new(1,0,0)
    
    if name == "AntiAFK" then
        if config.AntiAFK then startAntiAFK() else stopAntiAFK() end
    end
end

function saveSettings()
    local data = crypt.base64encode(game:GetService("HttpService"):JSONEncode(config))
    writefile("autofarm.cfg", data)
end

function loadSettings()
    if isfile("autofarm.cfg") then
        local data = readfile("autofarm.cfg")
        config = game:GetService("HttpService"):JSONDecode(crypt.base64decode(data))
    end
end

--[[
  ██████╗ ██████╗  ██████╗  ██████╗ 
 ██╔════╝ ██╔══██╗██╔═══██╗██╔═══██╗
 ██║  ███╗██████╔╝██║   ██║██║   ██║
 ██║   ██║██╔══██╗██║   ██║██║   ██║
 ╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝
  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ 
]]

initGUI()
loadSettings()

-- Основной цикл
while isrbxactive() do
    updateGUIInput()
    
    if config.Enabled then
        -- Основная логика фарма
        local resources = findResources()
        processResources(resources)
    end
    
    if config.AntiAFK and not antiAfkThread then
        startAntiAFK()
    end
    
    wait(0.1)
end

saveSettings()

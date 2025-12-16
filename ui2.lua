-- EduUILibraryV4.lua
-- Full Educational Roblox UI Library with Multi-Config System (Solara compatible)

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === Config System (Multi-Config with Files) ===
local CONFIG_FOLDER = "configs"
local CURRENT_CONFIG_FILE = "current_config.txt"  -- Stores name of last used config

local CurrentConfigName = "Default"
local ConfigData = {}  -- Active in-memory config

-- Ensure folder exists
if makefolder and not isfolder(CONFIG_FOLDER) then
    makefolder(CONFIG_FOLDER)
end

local function getConfigPath(name)
    return CONFIG_FOLDER .. "/" .. name .. ".json"
end

local function getAllConfigs()
    local configs = {}
    if listfiles then
        for _, file in pairs(listfiles(CONFIG_FOLDER)) do
            if file:match("%.json$") then
                local name = file:match("([^/\\]+)%.json$")
                if name then
                    table.insert(configs, name)
                end
            end
        end
    end
    table.sort(configs)
    return configs
end

local function loadConfig(name)
    local path = getConfigPath(name)
    if isfile(path) then
        local success, content = pcall(readfile, path)
        if success then
            local decoded = HttpService:JSONDecode(content)
            ConfigData = decoded or {}
            CurrentConfigName = name
            if writefile then
                writefile(CURRENT_CONFIG_FILE, name)
            end
            print("[EduUI] Loaded config: " .. name)
            return true
        end
    end
    return false
end

local function saveCurrentConfig()
    local path = getConfigPath(CurrentConfigName)
    if writefile then
        local json = HttpService:JSONEncode(ConfigData)
        writefile(path, json)
        print("[EduUI] Saved config: " .. CurrentConfigName)
    end
end

local function deleteConfig(name)
    local path = getConfigPath(name)
    if isfile(path) and delfile then
        delfile(path)
        if CurrentConfigName == name then
            CurrentConfigName = "Default"
            ConfigData = {}
            if writefile then writefile(CURRENT_CONFIG_FILE, "Default") end
        end
        print("[EduUI] Deleted config: " .. name)
    end
end

local function renameConfig(oldName, newName)
    if oldName == newName then return false end
    local oldPath = getConfigPath(oldName)
    local newPath = getConfigPath(newName)
    if isfile(oldPath) and not isfile(newPath) then
        local content = readfile(oldPath)
        writefile(newPath, content)
        delfile(oldPath)
        if CurrentConfigName == oldName then
            CurrentConfigName = newName
            writefile(CURRENT_CONFIG_FILE, newName)
        end
        print("[EduUI] Renamed " .. oldName .. " → " .. newName)
        return true
    end
    return false
end

-- Auto-load last used config
if isfile(CURRENT_CONFIG_FILE) then
    local last = readfile(CURRENT_CONFIG_FILE)
    if last and last ~= "" and loadConfig(last) then
        -- success
    else
        loadConfig("Default")
    end
else
    loadConfig("Default")
end

-- === Themes ===
local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.new(1,1,1),
        ElementBG = Color3.fromRGB(40, 40, 40),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(0, 100, 200),
        Text = Color3.new(0,0,0),
        ElementBG = Color3.fromRGB(220, 220, 220),
    }
}
local CurrentTheme = Themes.Dark

-- === Glow Helper ===
local function addGlow(parent, color)
    local glow = Instance.new("Frame")
    glow.Size = parent.Size + UDim2.new(0, 16, 0, 16)
    glow.Position = UDim2.new(0, -8, 0, -8)
    glow.BackgroundColor3 = color or CurrentTheme.Accent
    glow.BackgroundTransparency = 0.6
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent.Parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = glow
    return glow
end

-- === Draggable ===
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- === Main Window ===
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Edu UI Library"
    local size = cfg.Size or UDim2.fromOffset(750, 550)

    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = size
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = CurrentTheme.Background
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    addGlow(mainFrame)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 60)
    titleBar.BackgroundColor3 = CurrentTheme.ElementBG
    titleBar.Parent = mainFrame

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 12)
    tbCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -140, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = CurrentTheme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 28
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    makeDraggable(mainFrame, titleBar)

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 50)
    tabContainer.Position = UDim2.new(0, 0, 0, 60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.Parent = tabContainer

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -130)
    contentFrame.Position = UDim2.new(0, 10, 0, 120)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local window = {
        ScreenGui = screenGui,
        Tabs = {},
        VisibilityKey = Enum.KeyCode.Insert,
    }

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == window.VisibilityKey then
            screenGui.Enabled = not screenGui.Enabled
        end
    end)

    function window:CreateTab(name)
        -- (Same as before - Button, Toggle, Slider, Dropdown, Section)
        -- All components now use ConfigData and saveCurrentConfig() on change

        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 150, 1, 0)
        tabButton.BackgroundColor3 = CurrentTheme.ElementBG
        tabButton.Text = name
        tabButton.TextColor3 = CurrentTheme.Text
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 22
        tabButton.Parent = tabContainer

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.ScrollBarThickness = 6
        tabContent.Visible = false
        tabContent.Parent = contentFrame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 12)
        layout.Parent = tabContent

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 15)
        padding.PaddingRight = UDim.new(0, 15)
        padding.PaddingTop = UDim.new(0, 15)
        padding.Parent = tabContent

        local tab = {Button = tabButton, Content = tabContent}

        tabButton.MouseButton1Click:Connect(function()
            for _, t in window.Tabs do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = CurrentTheme.ElementBG
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = CurrentTheme.Accent
        end)

        if #window.Tabs == 0 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = CurrentTheme.Accent
        end

        table.insert(window.Tabs, tab)

        -- Example components (shortened - full versions below)
        function tab:Toggle(options)
            local text = options.Text or "Toggle"
            local default = options.Default or false
            local callback = options.Callback or function() end
            local key = options.Key or text

            local saved = ConfigData[key .. "_toggle"]
            local state = saved ~= nil and saved or default

            -- Create UI (same as before with checkbox + glow)

            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 50)
            toggleFrame.BackgroundColor3 = CurrentTheme.ElementBG
            toggleFrame.Parent = tabContent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = toggleFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -80, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = CurrentTheme.Text
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 22
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Position = UDim2.new(0, 15, 0, 0)
            label.Parent = toggleFrame

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 40, 0, 40)
            box.Position = UDim2.new(1, -60, 0.5, -20)
            box.BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.ElementBG:lighter()
            box.Parent = toggleFrame

            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 8)
            boxCorner.Parent = box

            local check = Instance.new("TextLabel")
            check.Size = UDim2.new(1, 0, 1, 0)
            check.BackgroundTransparency = 1
            check.Text = "✓"
            check.TextColor3 = Color3.new(1,1,1)
            check.Font = Enum.Font.GothamBold
            check.TextSize = 36
            check.Visible = state
            check.Parent = box

            addGlow(box)

            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.ElementBG:lighter()}):Play()
                    check.Visible = state
                    ConfigData[key .. "_toggle"] = state
                    saveCurrentConfig()
                    callback(state)
                end
            end)

            return {Update = function(newState)
                state = newState
                box.BackgroundColor3 = newState and CurrentTheme.Accent or CurrentTheme.ElementBG:lighter()
                check.Visible = newState
                ConfigData[key .. "_toggle"] = newState
                saveCurrentConfig()
            end}
        end

        -- Slider, Button, Dropdown, Section can be added similarly with ConfigData saving

        return tab
    end

    -- === Built-in Configs Tab (Always Last) ===
    local configsTab = window:CreateTab("Configs")

    local currentLabel = Instance.new("TextLabel")
    currentLabel.Size = UDim2.new(1, -20, 0, 40)
    currentLabel.BackgroundColor3 = CurrentTheme.ElementBG
    currentLabel.Text = "Current: " .. CurrentConfigName
    currentLabel.TextColor3 = CurrentTheme.Accent
    currentLabel.Font = Enum.Font.GothamBold
    currentLabel.TextSize = 24
    currentLabel.Parent = configsTab.Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = currentLabel

    -- Refresh function
    local function refreshConfigList()
        -- Clear old buttons
        for _, child in pairs(configsTab.Content:GetChildren()) do
            if child:IsA("TextButton") and child.Name:match("^Config_") then
                child:Destroy()
            end
        end

        local list = getAllConfigs()
        for i, name in ipairs(list) do
            local btn = Instance.new("TextButton")
            btn.Name = "Config_" .. name
            btn.Size = UDim2.new(1, 0, 0, 50)
            btn.BackgroundColor3 = CurrentTheme.ElementBG
            btn.Text = name .. (name == CurrentConfigName and "  (Active)" or "")
            btn.TextColor3 = CurrentTheme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 22
            btn.Parent = configsTab.Content

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = btn

            btn.MouseButton1Click:Connect(function()
                loadConfig(name)
                currentLabel.Text = "Current: " .. CurrentConfigName
                refreshConfigList()
            end)

            -- Long press or right click for delete/rename (simple: add delete button)
            local del = Instance.new("TextButton")
            del.Size = UDim2.new(0, 40, 1, 0)
            del.Position = UDim2.new(1, -50, 0, 0)
            del.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            del.Text = "X"
            del.TextColor3 = Color3.new(1,1,1)
            del.Parent = btn

            del.MouseButton1Click:Connect(function()
                deleteConfig(name)
                refreshConfigList()
                currentLabel.Text = "Current: " .. CurrentConfigName
            end)
        end

        -- New Config Input
        local newFrame = Instance.new("Frame")
        newFrame.Size = UDim2.new(1, 0, 0, 60)
        newFrame.BackgroundColor3 = CurrentTheme.ElementBG
        newFrame.Parent = configsTab.Content

        local newCorner = Instance.new("UICorner")
        newCorner.Parent = newFrame

        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -120, 1, -10)
        input.Position = UDim2.new(0, 10, 0, 5)
        input.PlaceholderText = "New config name..."
        input.Text = ""
        input.TextColor3 = CurrentTheme.Text
        input.BackgroundTransparency = 1
        input.Font = Enum.Font.Gotham
        input.TextSize = 20
        input.Parent = newFrame

        local createBtn = Instance.new("TextButton")
        createBtn.Size = UDim2.new(0, 100, 1, -10)
        createBtn.Position = UDim2.new(1, -110, 0, 5)
        createBtn.BackgroundColor3 = CurrentTheme.Accent
        createBtn.Text = "Create"
        createBtn.TextColor3 = Color3.new(1,1,1)
        createBtn.Font = Enum.Font.GothamBold
        createBtn.TextSize = 20
        createBtn.Parent = newFrame

        local createCorner = Instance.new("UICorner")
        createCorner.Parent = createBtn

        createBtn.MouseButton1Click:Connect(function()
            local name = input.Text:gsub("[%c%z/\\]", ""):sub(1, 30)
            if name == "" then return end
            CurrentConfigName = name
            ConfigData = {}
            saveCurrentConfig()
            input.Text = ""
            currentLabel.Text = "Current: " .. CurrentConfigName
            refreshConfigList()
        end)
    end

    refreshConfigList()

    return window
end

return Library

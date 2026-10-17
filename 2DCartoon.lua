--[[
    ========================================================================
    🎨 2D CARTOON UI LIBRARY FOR ROBLOX (GITHUB READY)
    ========================================================================
    Dirancang khusus untuk di-host di GitHub & dipanggil via:
    
    local CartoonUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/UI%202D%20Cartoon.lua"))()

    local Window = CartoonUI.CreateWindow({
        Title = "Boyfinity HUB",
        Subtitle = "by ridho hari",
        Icon = "⚡",                          -- Emoji atau rbxassetid://
        ToggleKey = Enum.KeyCode.RightControl, -- Keybind minimize/buka
        Size = UDim2.new(0, 560, 0, 390),
        FloatButton = {
            Enabled = true,                    -- Tampilkan tombol melayang
            Icon = "🎮",
        },
        RightButtons = {                       -- Tombol tambahan di header (sebelah minimize/close)
            {
                Icon = "💬",
                Tooltip = "Discord",
                Color = Color3.fromRGB(114, 137, 218),
                Callback = function()
                    setclipboard("https://discord.gg/yourlink")
                end
            }
        }
    })
    ========================================================================
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Safe Parent Detection (CoreGui / gethui untuk Executor / fallback PlayerGui untuk Studio)
local function getSafeParent()
    local success, core = pcall(function()
        return (gethui and gethui()) or CoreGui
    end)
    if success and core then
        return core
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ========================================================================
-- TEMA WARNA & GAYA 2D CARTOON DEFAULT
-- ========================================================================
local DefaultTheme = {
    Background = Color3.fromRGB(246, 248, 255),
    Sidebar = Color3.fromRGB(235, 240, 255),
    CardBg = Color3.fromRGB(255, 255, 255),
    CardDark = Color3.fromRGB(240, 243, 250),
    
    Outline = Color3.fromRGB(35, 38, 56),      -- Line-art navy pekat
    Shadow = Color3.fromRGB(25, 28, 42),       -- Bayangan kartun
    
    Primary = Color3.fromRGB(255, 107, 107),   -- Coral Pink
    PrimaryDark = Color3.fromRGB(218, 77, 77),
    Secondary = Color3.fromRGB(78, 205, 196), -- Mint Cyan
    SecondaryDark = Color3.fromRGB(53, 163, 155),
    Yellow = Color3.fromRGB(255, 217, 61),    -- Sunshine Yellow
    YellowDark = Color3.fromRGB(224, 186, 38),
    Green = Color3.fromRGB(106, 222, 126),     -- Lime Green
    Purple = Color3.fromRGB(142, 108, 239),   -- Bubblegum Purple
    
    TextDark = Color3.fromRGB(35, 38, 56),
    TextMuted = Color3.fromRGB(120, 126, 150),
    TextLight = Color3.fromRGB(255, 255, 255),
    
    FontBold = Enum.Font.FredokaOne,
    FontRegular = Enum.Font.GothamBold,
}

local function mergeTheme(custom)
    local merged = {}
    for k, v in pairs(DefaultTheme) do
        merged[k] = v
    end
    if type(custom) == "table" then
        for k, v in pairs(custom) do
            merged[k] = v
        end
    end
    return merged
end

-- ========================================================================
-- HELPER UTILITIES
-- ========================================================================
local function tween(object, info, properties)
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

local function addCartoonStroke(object, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 2.5
    stroke.Color = color or DefaultTheme.Outline
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = object
    return stroke
end

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = object
    return corner
end

local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            tween(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            })
        end
    end)
end

-- ========================================================================
-- CARTOON UI LIBRARY
-- ========================================================================
local CartoonUI = {}
CartoonUI.__index = CartoonUI

function CartoonUI.CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Boyfinity HUB"
    local Subtitle = config.Subtitle or "by ridho hari"
    local WindowIcon = config.Icon or "⚡"
    local ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local Size = config.Size or UDim2.new(0, 560, 0, 390)
    local Theme = mergeTheme(config.Theme)
    
    local floatConfig = config.FloatButton or {}
    local floatEnabled = (floatConfig.Enabled ~= false)
    local floatIcon = floatConfig.Icon or "🎮"
    local floatColor = floatConfig.Color or Theme.Yellow

    -- Hapus instance lama jika ada
    local guiName = "CartoonUI_" .. Title:gsub("%s+", "_")
    local parent = getSafeParent()
    if parent:FindFirstChild(guiName) then
        parent[guiName]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = guiName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = parent

    -- ========================================================================
    -- NOTIFICATION CONTAINER
    -- ========================================================================
    local notifContainer = Instance.new("Frame")
    notifContainer.Name = "NotificationContainer"
    notifContainer.Size = UDim2.new(0, 270, 0.7, 0)
    notifContainer.Position = UDim2.new(1, -290, 0, 20)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent = ScreenGui

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding = UDim.new(0, 8)
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Parent = notifContainer

    local function notify(titleText, msgText, duration, iconColor)
        duration = duration or 3
        iconColor = iconColor or Theme.Yellow

        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(1, 0, 0, 56)
        toast.BackgroundColor3 = Theme.CardBg
        toast.BorderSizePixel = 0
        addCorner(toast, 14)
        addCartoonStroke(toast, 2.5, Theme.Outline)

        local shadow = Instance.new("Frame")
        shadow.Size = UDim2.new(1, 0, 0, 6)
        shadow.Position = UDim2.new(0, 0, 1, -6)
        shadow.BackgroundColor3 = Theme.CardDark
        shadow.BorderSizePixel = 0
        addCorner(shadow, 14)
        shadow.Parent = toast

        local iconBadge = Instance.new("Frame")
        iconBadge.Size = UDim2.new(0, 36, 0, 36)
        iconBadge.Position = UDim2.new(0, 10, 0.5, -18)
        iconBadge.BackgroundColor3 = iconColor
        iconBadge.BorderSizePixel = 0
        addCorner(iconBadge, 10)
        addCartoonStroke(iconBadge, 2, Theme.Outline)
        iconBadge.Parent = toast

        local iconEmoji = Instance.new("TextLabel")
        iconEmoji.Size = UDim2.new(1, 0, 1, 0)
        iconEmoji.BackgroundTransparency = 1
        iconEmoji.Font = Theme.FontBold
        iconEmoji.Text = "★"
        iconEmoji.TextColor3 = Theme.Outline
        iconEmoji.TextSize = 20
        iconEmoji.Parent = iconBadge

        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, -60, 0, 18)
        tLabel.Position = UDim2.new(0, 54, 0, 8)
        tLabel.BackgroundTransparency = 1
        tLabel.Font = Theme.FontBold
        tLabel.Text = titleText or "Notifikasi"
        tLabel.TextColor3 = Theme.TextDark
        tLabel.TextSize = 14
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.Parent = toast

        local dLabel = Instance.new("TextLabel")
        dLabel.Size = UDim2.new(1, -60, 0, 18)
        dLabel.Position = UDim2.new(0, 54, 0, 26)
        dLabel.BackgroundTransparency = 1
        dLabel.Font = Theme.FontRegular
        dLabel.Text = msgText or ""
        dLabel.TextColor3 = Theme.TextMuted
        dLabel.TextSize = 12
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.Parent = toast

        toast.Parent = notifContainer
        toast.Size = UDim2.new(0, 0, 0, 56)
        tween(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 56)
        })

        task.delay(duration, function()
            if toast and toast.Parent then
                local t = tween(toast, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 56)
                })
                t.Completed:Connect(function()
                    toast:Destroy()
                end)
            end
        end)
    end

    -- ========================================================================
    -- MAIN WINDOW CONTAINER & SHADOW
    -- ========================================================================
    local MainShadow = Instance.new("Frame")
    MainShadow.Name = "MainShadow"
    MainShadow.Size = Size
    MainShadow.Position = UDim2.new(0.5, -Size.X.Offset / 2 + 6, 0.5, -Size.Y.Offset / 2 + 8)
    MainShadow.BackgroundColor3 = Theme.Outline
    MainShadow.BorderSizePixel = 0
    addCorner(MainShadow, 20)
    MainShadow.Parent = ScreenGui

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = Size
    MainWindow.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
    MainWindow.BackgroundColor3 = Theme.Background
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = false
    addCorner(MainWindow, 18)
    addCartoonStroke(MainWindow, 3.5, Theme.Outline)
    MainWindow.Parent = ScreenGui

    MainWindow:GetPropertyChangedSignal("Position"):Connect(function()
        MainShadow.Position = UDim2.new(
            MainWindow.Position.X.Scale,
            MainWindow.Position.X.Offset + 6,
            MainWindow.Position.Y.Scale,
            MainWindow.Position.Y.Offset + 8
        )
    end)
    MainWindow:GetPropertyChangedSignal("Visible"):Connect(function()
        MainShadow.Visible = MainWindow.Visible
    end)

    makeDraggable(MainWindow)

    -- ========================================================================
    -- TOP HEADER BAR
    -- ========================================================================
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 54)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.BorderSizePixel = 0
    addCorner(Header, 18)
    Header.Parent = MainWindow

    local HeaderFix = Instance.new("Frame")
    HeaderFix.Size = UDim2.new(1, 0, 0, 14)
    HeaderFix.Position = UDim2.new(0, 0, 1, -14)
    HeaderFix.BackgroundColor3 = Theme.Sidebar
    HeaderFix.BorderSizePixel = 0
    HeaderFix.Parent = Header

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 3)
    HeaderLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderLine.BackgroundColor3 = Theme.Outline
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = Header

    -- Logo Badge (Bisa Emoji atau Gambar Asset ID)
    local LogoBadge = Instance.new("Frame")
    LogoBadge.Size = UDim2.new(0, 36, 0, 36)
    LogoBadge.Position = UDim2.new(0, 12, 0.5, -18)
    LogoBadge.BackgroundColor3 = Theme.Yellow
    LogoBadge.BorderSizePixel = 0
    addCorner(LogoBadge, 10)
    addCartoonStroke(LogoBadge, 2.5, Theme.Outline)
    LogoBadge.Parent = Header

    if string.find(tostring(WindowIcon), "rbxasset") or tonumber(WindowIcon) then
        local LogoImg = Instance.new("ImageLabel")
        LogoImg.Size = UDim2.new(1, -6, 1, -6)
        LogoImg.Position = UDim2.new(0, 3, 0, 3)
        LogoImg.BackgroundTransparency = 1
        LogoImg.Image = tonumber(WindowIcon) and ("rbxassetid://" .. WindowIcon) or WindowIcon
        LogoImg.Parent = LogoBadge
    else
        local LogoEmoji = Instance.new("TextLabel")
        LogoEmoji.Size = UDim2.new(1, 0, 1, 0)
        LogoEmoji.BackgroundTransparency = 1
        LogoEmoji.Font = Theme.FontBold
        LogoEmoji.Text = tostring(WindowIcon)
        LogoEmoji.TextSize = 22
        LogoEmoji.TextColor3 = Theme.Outline
        LogoEmoji.Parent = LogoBadge
    end

    -- Title & Subtitle (Customizable: "Boyfinity HUB" & "by ridho hari")
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(0, 240, 0, 22)
    TitleLabel.Position = UDim2.new(0, 56, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Theme.FontBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.TextDark
    TitleLabel.TextSize = 17
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "SubtitleLabel"
    SubtitleLabel.Size = UDim2.new(0, 240, 0, 16)
    SubtitleLabel.Position = UDim2.new(0, 56, 0, 28)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Theme.FontRegular
    SubtitleLabel.Text = Subtitle
    SubtitleLabel.TextColor3 = Theme.TextMuted
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = Header

    -- ========================================================================
    -- RIGHT SIDE BUTTONS CONTAINER
    -- ========================================================================
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 240, 0, 34)
    Controls.Position = UDim2.new(1, -250, 0.5, -17)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Header

    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 6)
    ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ControlsLayout.Parent = Controls

    -- Helper pembuat Button Header Kartun
    local function createHeaderButton(iconText, color, hoverColor, callback, layoutOrder)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Font = Theme.FontBold
        btn.Text = iconText
        btn.TextColor3 = Theme.Outline
        btn.TextSize = 16
        btn.AutoButtonColor = false
        btn.LayoutOrder = layoutOrder or 10
        addCorner(btn, 10)
        addCartoonStroke(btn, 2.5, Theme.Outline)
        btn.Parent = Controls

        btn.MouseEnter:Connect(function()
            tween(btn, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 35, 0, 35),
                BackgroundColor3 = hoverColor
            })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 32, 0, 32),
                BackgroundColor3 = color
            })
        end)
        btn.MouseButton1Down:Connect(function()
            tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 28, 0, 28)
            })
        end)
        btn.MouseButton1Up:Connect(function()
            tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 32, 0, 32)
            })
        end)
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        return btn
    end

    -- ========================================================================
    -- MINIMIZE & VISIBILITY STATE
    -- ========================================================================
    local isMinimized = false
    local isWindowVisible = true
    local originalSize = Size
    local minimizedSize = UDim2.new(0, Size.X.Offset, 0, 54)

    local MinBtn, CloseBtn

    local function setMinimized(minimize)
        isMinimized = minimize
        if isMinimized then
            tween(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
                Size = minimizedSize
            })
            tween(MainShadow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
                Size = minimizedSize
            })
            if MinBtn then MinBtn.Text = "＋" end
            notify("UI Dikecilkan", "Klik tombol ＋ atau tombol melayang untuk membuka", 2.5, Theme.Yellow)
        else
            tween(MainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = originalSize
            })
            tween(MainShadow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = originalSize
            })
            if MinBtn then MinBtn.Text = "—" end
        end
    end

    local function toggleWindowVisibility()
        isWindowVisible = not isWindowVisible
        if isWindowVisible then
            MainWindow.Visible = true
            MainShadow.Visible = true
            MainWindow.Size = UDim2.new(0, 0, 0, 0)
            local targetSize = isMinimized and minimizedSize or originalSize
            tween(MainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = targetSize
            })
            tween(MainShadow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = targetSize
            })
        else
            local t = tween(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            tween(MainShadow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            t.Completed:Connect(function()
                if not isWindowVisible then
                    MainWindow.Visible = false
                    MainShadow.Visible = false
                end
            end)
        end
    end

    -- ========================================================================
    -- CUSTOM RIGHT SIDE BUTTONS DARI CONFIG
    -- ========================================================================
    if type(config.RightButtons) == "table" then
        for i, btnData in ipairs(config.RightButtons) do
            local bColor = btnData.Color or Theme.Secondary
            local bHover = btnData.HoverColor or Color3.fromRGB(110, 225, 218)
            createHeaderButton(btnData.Icon or "★", bColor, bHover, function()
                if btnData.Callback then
                    btnData.Callback()
                end
                if btnData.Tooltip then
                    notify(btnData.Tooltip, "Aksi berhasil dieksekusi", 2, bColor)
                end
            end, i)
        end
    end

    -- Tombol Minimize & Close Default di Ujung Kanan
    MinBtn = createHeaderButton("—", Theme.Yellow, Color3.fromRGB(255, 235, 120), function()
        setMinimized(not isMinimized)
    end, 98)

    CloseBtn = createHeaderButton("✕", Theme.Primary, Color3.fromRGB(255, 130, 130), function()
        toggleWindowVisibility()
        notify("UI Ditutup", "Buka kembali dengan tombol melayang atau tombol keybind", 3, Theme.Primary)
    end, 99)

    -- ========================================================================
    -- FLOATING BUTTON (DRAGGABLE & BOUNCY)
    -- ========================================================================
    local FloatBtn = Instance.new("ImageButton")
    FloatBtn.Name = "FloatButton"
    FloatBtn.Size = UDim2.new(0, 54, 0, 54)
    FloatBtn.Position = floatConfig.Position or UDim2.new(0, 25, 0.5, -27)
    FloatBtn.BackgroundColor3 = floatColor
    FloatBtn.BorderSizePixel = 0
    FloatBtn.AutoButtonColor = false
    FloatBtn.Visible = floatEnabled
    addCorner(FloatBtn, 27)
    addCartoonStroke(FloatBtn, 3, Theme.Outline)
    FloatBtn.Parent = ScreenGui

    local FloatShadow = Instance.new("Frame")
    FloatShadow.Name = "FloatShadow"
    FloatShadow.Size = UDim2.new(0, 54, 0, 54)
    FloatShadow.Position = UDim2.new(
        FloatBtn.Position.X.Scale,
        FloatBtn.Position.X.Offset + 4,
        FloatBtn.Position.Y.Scale,
        FloatBtn.Position.Y.Offset + 4
    )
    FloatShadow.BackgroundColor3 = Theme.Outline
    FloatShadow.BorderSizePixel = 0
    addCorner(FloatShadow, 27)
    FloatShadow.Parent = ScreenGui
    FloatShadow.ZIndex = FloatBtn.ZIndex - 1

    FloatBtn:GetPropertyChangedSignal("Position"):Connect(function()
        FloatShadow.Position = UDim2.new(
            FloatBtn.Position.X.Scale,
            FloatBtn.Position.X.Offset + 4,
            FloatBtn.Position.Y.Scale,
            FloatBtn.Position.Y.Offset + 4
        )
    end)
    FloatBtn:GetPropertyChangedSignal("Visible"):Connect(function()
        FloatShadow.Visible = FloatBtn.Visible
    end)

    local FloatIcon = Instance.new("TextLabel")
    FloatIcon.Size = UDim2.new(1, 0, 1, 0)
    FloatIcon.BackgroundTransparency = 1
    FloatIcon.Font = Theme.FontBold
    FloatIcon.Text = tostring(floatIcon)
    FloatIcon.TextSize = 26
    FloatIcon.TextColor3 = Theme.Outline
    FloatIcon.Parent = FloatBtn

    makeDraggable(FloatBtn)

    FloatBtn.MouseEnter:Connect(function()
        tween(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 60, 0, 60)
        })
    end)
    FloatBtn.MouseLeave:Connect(function()
        tween(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 54, 0, 54)
        })
    end)

    FloatBtn.MouseButton1Click:Connect(function()
        if not isWindowVisible then
            toggleWindowVisibility()
        elseif isMinimized then
            setMinimized(false)
        else
            setMinimized(true)
        end
    end)

    -- ========================================================================
    -- CUSTOM KEYBIND SYSTEM
    -- ========================================================================
    local currentKeybind = ToggleKey

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == currentKeybind then
            toggleWindowVisibility()
        end
    end)

    -- ========================================================================
    -- BODY (SIDEBAR TABS & PAGES CONTAINER)
    -- ========================================================================
    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Size = UDim2.new(1, 0, 1, -54)
    Body.Position = UDim2.new(0, 0, 0, 54)
    Body.BackgroundTransparency = 1
    Body.ClipsDescendants = true
    Body.Parent = MainWindow

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Body

    local SidebarCornerFix = Instance.new("Frame")
    SidebarCornerFix.Size = UDim2.new(0, 18, 0, 18)
    SidebarCornerFix.Position = UDim2.new(0, 0, 1, -18)
    SidebarCornerFix.BackgroundColor3 = Theme.Sidebar
    SidebarCornerFix.BorderSizePixel = 0
    addCorner(SidebarCornerFix, 18)
    SidebarCornerFix.Parent = Sidebar

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 3, 1, 0)
    SidebarDivider.Position = UDim2.new(1, -3, 0, 0)
    SidebarDivider.BackgroundColor3 = Theme.Outline
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Sidebar

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -8, 1, -16)
    TabScroll.Position = UDim2.new(0, 4, 0, 8)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 3
    TabScroll.ScrollBarImageColor3 = Theme.Outline
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabScroll

    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "PagesContainer"
    PagesContainer.Size = UDim2.new(1, -158, 1, -16)
    PagesContainer.Position = UDim2.new(0, 154, 0, 8)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = Body

    -- ========================================================================
    -- WINDOW OBJECT & API
    -- ========================================================================
    local WindowHandler = {
        CurrentTab = nil,
        Tabs = {},
        ScreenGui = ScreenGui,
        MainWindow = MainWindow,
        FloatButton = FloatBtn
    }

    function WindowHandler:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end

    function WindowHandler:SetSubtitle(newSubtitle)
        SubtitleLabel.Text = newSubtitle
    end

    function WindowHandler:SetToggleKey(newKey)
        currentKeybind = newKey
        notify("Keybind Diubah", "Keybind baru: " .. newKey.Name, 3, Theme.Green)
    end

    function WindowHandler:GetToggleKey()
        return currentKeybind
    end

    function WindowHandler:Notify(titleText, msgText, duration, color)
        notify(titleText, msgText, duration, color)
    end

    function WindowHandler:ToggleFloatButton(visible)
        FloatBtn.Visible = visible
    end

    function WindowHandler:Toggle()
        toggleWindowVisibility()
    end

    function WindowHandler:Minimize(bool)
        setMinimized(bool)
    end

    function WindowHandler:AddHeaderButton(iconText, callback, color)
        return createHeaderButton(iconText, color or Theme.Secondary, Color3.fromRGB(110, 225, 218), callback, 50)
    end

    function WindowHandler:Destroy()
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end

    -- ========================================================================
    -- TAB CREATION
    -- ========================================================================
    function WindowHandler:CreateTab(tabName, iconEmoji)
        tabName = tabName or "Tab"
        iconEmoji = iconEmoji or "📁"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabName
        TabBtn.Size = UDim2.new(0.92, 0, 0, 40)
        TabBtn.BackgroundColor3 = Theme.CardBg
        TabBtn.BorderSizePixel = 0
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        addCorner(TabBtn, 12)
        local tabStroke = addCartoonStroke(TabBtn, 2, Theme.Outline)
        TabBtn.Parent = TabScroll

        local TabIcon = Instance.new("TextLabel")
        TabIcon.Size = UDim2.new(0, 24, 1, 0)
        TabIcon.Position = UDim2.new(0, 8, 0, 0)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Font = Theme.FontBold
        TabIcon.Text = iconEmoji
        TabIcon.TextSize = 18
        TabIcon.TextColor3 = Theme.Outline
        TabIcon.Parent = TabBtn

        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(1, -38, 1, 0)
        TabText.Position = UDim2.new(0, 34, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Theme.FontBold
        TabText.Text = tabName
        TabText.TextColor3 = Theme.TextDark
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = "Page_" .. tabName
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Theme.Outline
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.Parent = PagesContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 6)
        PagePadding.PaddingBottom = UDim.new(0, 14)
        PagePadding.PaddingLeft = UDim.new(0, 6)
        PagePadding.PaddingRight = UDim.new(0, 8)
        PagePadding.Parent = Page

        local TabData = {
            Button = TabBtn,
            Page = Page
        }

        local function activateTab()
            for _, t in pairs(WindowHandler.Tabs) do
                t.Page.Visible = false
                tween(t.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.CardBg
                })
                t.Button:FindFirstChildWhichIsA("UIStroke").Color = Theme.Outline
                t.Button:FindFirstChildWhichIsA("UIStroke").Thickness = 2
            end
            Page.Visible = true
            WindowHandler.CurrentTab = TabData

            tween(TabBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                BackgroundColor3 = Theme.Yellow
            })
            tabStroke.Thickness = 3
        end

        TabBtn.MouseButton1Click:Connect(activateTab)

        TabBtn.MouseEnter:Connect(function()
            if WindowHandler.CurrentTab ~= TabData then
                tween(TabBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Theme.CardDark
                })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowHandler.CurrentTab ~= TabData then
                tween(TabBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Theme.CardBg
                })
            end
        end)

        table.insert(WindowHandler.Tabs, TabData)

        if #WindowHandler.Tabs == 1 then
            activateTab()
        end

        local TabElements = {}

        -- 1. SECTION
        function TabElements:CreateSection(sectionText)
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 26)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Page

            local SecLabel = Instance.new("TextLabel")
            SecLabel.Size = UDim2.new(1, 0, 1, 0)
            SecLabel.BackgroundTransparency = 1
            SecLabel.Font = Theme.FontBold
            SecLabel.Text = "★  " .. string.upper(sectionText)
            SecLabel.TextColor3 = Theme.Purple
            SecLabel.TextSize = 13
            SecLabel.TextXAlignment = Enum.TextXAlignment.Left
            SecLabel.Parent = SecFrame
            return SecFrame
        end

        -- 2. BUTTON (WITH 2D PUSH SHADOW)
        function TabElements:CreateButton(btnText, callback)
            callback = callback or function() end

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 44)
            Container.BackgroundTransparency = 1
            Container.Parent = Page

            local BtnShadow = Instance.new("Frame")
            BtnShadow.Size = UDim2.new(1, 0, 0, 40)
            BtnShadow.Position = UDim2.new(0, 0, 0, 4)
            BtnShadow.BackgroundColor3 = Theme.Outline
            BtnShadow.BorderSizePixel = 0
            addCorner(BtnShadow, 12)
            BtnShadow.Parent = Container

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.Position = UDim2.new(0, 0, 0, 0)
            Button.BackgroundColor3 = Theme.Secondary
            Button.BorderSizePixel = 0
            Button.AutoButtonColor = false
            Button.Font = Theme.FontBold
            Button.Text = btnText
            Button.TextColor3 = Theme.Outline
            Button.TextSize = 15
            addCorner(Button, 12)
            addCartoonStroke(Button, 2.5, Theme.Outline)
            Button.Parent = Container

            Button.MouseButton1Down:Connect(function()
                tween(Button, TweenInfo.new(0.06, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0, 0, 0, 3)
                })
            end)

            Button.MouseButton1Up:Connect(function()
                tween(Button, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0)
                })
            end)

            Button.MouseEnter:Connect(function()
                tween(Button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(110, 225, 218)
                })
            end)

            Button.MouseLeave:Connect(function()
                tween(Button, TweenInfo.new(0.15), {
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = Theme.Secondary
                })
            end)

            Button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)

            return {
                Button = Button,
                SetText = function(_, newText)
                    Button.Text = newText
                end
            }
        end

        -- 3. TOGGLE (BOUNCY SWITCH)
        function TabElements:CreateToggle(toggleText, defaultState, callback)
            defaultState = defaultState or false
            callback = callback or function() end

            local state = defaultState

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = toggleText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local Track = Instance.new("TextButton")
            Track.Size = UDim2.new(0, 50, 0, 26)
            Track.Position = UDim2.new(1, -62, 0.5, -13)
            Track.BackgroundColor3 = state and Theme.Green or Color3.fromRGB(215, 220, 230)
            Track.BorderSizePixel = 0
            Track.AutoButtonColor = false
            Track.Text = ""
            addCorner(Track, 13)
            addCartoonStroke(Track, 2, Theme.Outline)
            Track.Parent = Card

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 18, 0, 18)
            Knob.Position = state and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
            Knob.BackgroundColor3 = Theme.CardBg
            Knob.BorderSizePixel = 0
            addCorner(Knob, 9)
            addCartoonStroke(Knob, 2, Theme.Outline)
            Knob.Parent = Track

            local function updateToggle(val)
                state = val
                if state then
                    tween(Track, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Green })
                    tween(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -22, 0.5, -9)
                    })
                else
                    tween(Track, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(215, 220, 230) })
                    tween(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 4, 0.5, -9)
                    })
                end
                pcall(callback, state)
            end

            Track.MouseButton1Click:Connect(function()
                updateToggle(not state)
            end)

            return {
                SetValue = function(_, val)
                    updateToggle(val)
                end,
                GetValue = function()
                    return state
                end
            }
        end

        -- 4. SLIDER
        function TabElements:CreateSlider(sliderText, min, max, defaultVal, callback)
            min = min or 0
            max = max or 100
            defaultVal = math.clamp(defaultVal or min, min, max)
            callback = callback or function() end

            local currentVal = defaultVal

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 62)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 0, 20)
            Label.Position = UDim2.new(0, 14, 0, 8)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = sliderText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local ValueBadge = Instance.new("TextLabel")
            ValueBadge.Size = UDim2.new(0, 50, 0, 20)
            ValueBadge.Position = UDim2.new(1, -64, 0, 8)
            ValueBadge.BackgroundColor3 = Theme.Yellow
            ValueBadge.BorderSizePixel = 0
            ValueBadge.Font = Theme.FontBold
            ValueBadge.Text = tostring(currentVal)
            ValueBadge.TextColor3 = Theme.Outline
            ValueBadge.TextSize = 12
            addCorner(ValueBadge, 8)
            addCartoonStroke(ValueBadge, 1.8, Theme.Outline)
            ValueBadge.Parent = Card

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -28, 0, 12)
            Track.Position = UDim2.new(0, 14, 0, 38)
            Track.BackgroundColor3 = Theme.Sidebar
            Track.BorderSizePixel = 0
            addCorner(Track, 6)
            addCartoonStroke(Track, 2, Theme.Outline)
            Track.Parent = Card

            local progress = (currentVal - min) / (max - min)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(progress, 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Purple
            Fill.BorderSizePixel = 0
            addCorner(Fill, 6)
            Fill.Parent = Track

            local Knob = Instance.new("ImageButton")
            Knob.Size = UDim2.new(0, 22, 0, 22)
            Knob.Position = UDim2.new(progress, -11, 0.5, -11)
            Knob.BackgroundColor3 = Theme.CardBg
            Knob.BorderSizePixel = 0
            Knob.AutoButtonColor = false
            addCorner(Knob, 11)
            addCartoonStroke(Knob, 2.5, Theme.Outline)
            Knob.Parent = Track

            local dragging = false

            local function updateSlider(inputX)
                local trackAbsPos = Track.AbsolutePosition.X
                local trackAbsSize = Track.AbsoluteSize.X
                local relativeX = math.clamp(inputX - trackAbsPos, 0, trackAbsSize)
                local ratio = relativeX / trackAbsSize
                currentVal = math.floor(min + ((max - min) * ratio))

                ValueBadge.Text = tostring(currentVal)
                Fill.Size = UDim2.new(ratio, 0, 1, 0)
                Knob.Position = UDim2.new(ratio, -11, 0.5, -11)

                pcall(callback, currentVal)
            end

            Knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    tween(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 26, 0, 26),
                        Position = UDim2.new(Knob.Position.X.Scale, -13, 0.5, -13)
                    })
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        tween(Knob, TweenInfo.new(0.15), {
                            Size = UDim2.new(0, 22, 0, 22),
                            Position = UDim2.new(Knob.Position.X.Scale, -11, 0.5, -11)
                        })
                    end
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(input.Position.X)
                end
            end)

            return {
                SetValue = function(_, val)
                    val = math.clamp(val, min, max)
                    local ratio = (val - min) / (max - min)
                    currentVal = val
                    ValueBadge.Text = tostring(currentVal)
                    Fill.Size = UDim2.new(ratio, 0, 1, 0)
                    Knob.Position = UDim2.new(ratio, -11, 0.5, -11)
                    pcall(callback, currentVal)
                end,
                GetValue = function()
                    return currentVal
                end
            }
        end

        -- 5. DROPDOWN
        function TabElements:CreateDropdown(dropdownText, options, defaultSelected, callback)
            options = options or {}
            defaultSelected = defaultSelected or options[1] or "Select"
            callback = callback or function() end

            local isDropped = false
            local selectedOption = defaultSelected

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            Card.ClipsDescendants = true
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local DropHeader = Instance.new("TextButton")
            DropHeader.Size = UDim2.new(1, 0, 0, 48)
            DropHeader.BackgroundTransparency = 1
            DropHeader.Text = ""
            DropHeader.Parent = Card

            local TitleL = Instance.new("TextLabel")
            TitleL.Size = UDim2.new(0.5, 0, 1, 0)
            TitleL.Position = UDim2.new(0, 14, 0, 0)
            TitleL.BackgroundTransparency = 1
            TitleL.Font = Theme.FontBold
            TitleL.Text = dropdownText
            TitleL.TextColor3 = Theme.TextDark
            TitleL.TextSize = 14
            TitleL.TextXAlignment = Enum.TextXAlignment.Left
            TitleL.Parent = DropHeader

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0.4, -30, 0, 26)
            SelectedLabel.Position = UDim2.new(0.6, -10, 0.5, -13)
            SelectedLabel.BackgroundColor3 = Theme.Sidebar
            SelectedLabel.BorderSizePixel = 0
            SelectedLabel.Font = Theme.FontRegular
            SelectedLabel.Text = selectedOption
            SelectedLabel.TextColor3 = Theme.TextDark
            SelectedLabel.TextSize = 12
            addCorner(SelectedLabel, 8)
            addCartoonStroke(SelectedLabel, 1.5, Theme.Outline)
            SelectedLabel.Parent = DropHeader

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -30, 0.5, -10)
            Arrow.BackgroundTransparency = 1
            Arrow.Font = Theme.FontBold
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.Outline
            Arrow.TextSize = 12
            Arrow.Parent = DropHeader

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, -24, 0, #options * 32)
            OptionsContainer.Position = UDim2.new(0, 12, 0, 52)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Parent = Card

            local OptionList = Instance.new("UIListLayout")
            OptionList.Padding = UDim.new(0, 4)
            OptionList.Parent = OptionsContainer

            local function toggleDropdown()
                isDropped = not isDropped
                local targetHeight = isDropped and (56 + (#options * 36)) or 48
                tween(Card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                })
                tween(Arrow, TweenInfo.new(0.2), {
                    Rotation = isDropped and 180 or 0
                })
            end

            DropHeader.MouseButton1Click:Connect(toggleDropdown)

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 32)
                OptBtn.BackgroundColor3 = (opt == selectedOption) and Theme.Yellow or Theme.CardDark
                OptBtn.BorderSizePixel = 0
                OptBtn.Font = Theme.FontBold
                OptBtn.Text = opt
                OptBtn.TextColor3 = Theme.TextDark
                OptBtn.TextSize = 13
                addCorner(OptBtn, 8)
                addCartoonStroke(OptBtn, 1.5, Theme.Outline)
                OptBtn.Parent = OptionsContainer

                OptBtn.MouseButton1Click:Connect(function()
                    selectedOption = opt
                    SelectedLabel.Text = opt
                    for _, child in pairs(OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundColor3 = (child.Text == opt) and Theme.Yellow or Theme.CardDark
                        end
                    end
                    toggleDropdown()
                    pcall(callback, opt)
                end)
            end

            return {
                GetSelected = function()
                    return selectedOption
                end
            }
        end

        -- 6. TEXTBOX / INPUT
        function TabElements:CreateInput(inputText, placeholder, callback)
            placeholder = placeholder or "Tulis disini..."
            callback = callback or function() end

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.45, 0, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = inputText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(0.5, -14, 0, 30)
            Box.Position = UDim2.new(0.5, 0, 0.5, -15)
            Box.BackgroundColor3 = Theme.Sidebar
            Box.BorderSizePixel = 0
            Box.Font = Theme.FontRegular
            Box.PlaceholderText = placeholder
            Box.PlaceholderColor3 = Theme.TextMuted
            Box.Text = ""
            Box.TextColor3 = Theme.TextDark
            Box.TextSize = 12
            Box.ClearTextOnFocus = false
            addCorner(Box, 8)
            local boxStroke = addCartoonStroke(Box, 1.8, Theme.Outline)
            Box.Parent = Card

            Box.Focused:Connect(function()
                tween(boxStroke, TweenInfo.new(0.2), { Color = Theme.Primary, Thickness = 2.5 })
            end)

            Box.FocusLost:Connect(function(enterPressed)
                tween(boxStroke, TweenInfo.new(0.2), { Color = Theme.Outline, Thickness = 1.8 })
                pcall(callback, Box.Text, enterPressed)
            end)

            return {
                GetText = function()
                    return Box.Text
                end,
                SetText = function(_, newText)
                    Box.Text = newText
                end
            }
        end

        -- 7. KEYBIND PICKER
        function TabElements:CreateKeybind(keybindText, defaultKey, callback)
            defaultKey = defaultKey or Enum.KeyCode.RightControl
            callback = callback or function() end

            local currentKey = defaultKey
            local listening = false

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = keybindText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local KeyButton = Instance.new("TextButton")
            KeyButton.Size = UDim2.new(0, 95, 0, 28)
            KeyButton.Position = UDim2.new(1, -109, 0.5, -14)
            KeyButton.BackgroundColor3 = Theme.Yellow
            KeyButton.BorderSizePixel = 0
            KeyButton.Font = Theme.FontBold
            KeyButton.Text = currentKey.Name
            KeyButton.TextColor3 = Theme.Outline
            KeyButton.TextSize = 12
            addCorner(KeyButton, 8)
            addCartoonStroke(KeyButton, 2, Theme.Outline)
            KeyButton.Parent = Card

            KeyButton.MouseButton1Click:Connect(function()
                listening = true
                KeyButton.Text = "..."
                KeyButton.BackgroundColor3 = Theme.Primary
                KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and not gameProcessed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        listening = false
                        KeyButton.Text = currentKey.Name
                        KeyButton.BackgroundColor3 = Theme.Yellow
                        KeyButton.TextColor3 = Theme.Outline
                        pcall(callback, currentKey)
                    end
                end
            end)

            return {
                GetKey = function()
                    return currentKey
                end
            }
        end

        -- 8. CARTOON LABEL / BANNER
        function TabElements:CreateLabel(labelText, icon)
            icon = icon or "💡"
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 40)
            Card.BackgroundColor3 = Theme.CardDark
            Card.BorderSizePixel = 0
            addCorner(Card, 10)
            addCartoonStroke(Card, 1.8, Theme.Outline)
            Card.Parent = Page

            local IconL = Instance.new("TextLabel")
            IconL.Size = UDim2.new(0, 24, 1, 0)
            IconL.Position = UDim2.new(0, 10, 0, 0)
            IconL.BackgroundTransparency = 1
            IconL.Font = Theme.FontBold
            IconL.Text = icon
            IconL.TextSize = 16
            IconL.TextColor3 = Theme.Outline
            IconL.Parent = Card

            local TextL = Instance.new("TextLabel")
            TextL.Size = UDim2.new(1, -44, 1, 0)
            TextL.Position = UDim2.new(0, 36, 0, 0)
            TextL.BackgroundTransparency = 1
            TextL.Font = Theme.FontRegular
            TextL.Text = labelText
            TextL.TextColor3 = Theme.TextDark
            TextL.TextSize = 12
            TextL.TextXAlignment = Enum.TextXAlignment.Left
            TextL.Parent = Card

            return {
                SetText = function(_, newText)
                    TextL.Text = newText
                end
            }
        end

        return TabElements
    end

    -- Pop In Animation Pertama Kali Buka
    MainWindow.Size = UDim2.new(0, 0, 0, 0)
    MainShadow.Size = UDim2.new(0, 0, 0, 0)
    tween(MainWindow, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize
    })
    tween(MainShadow, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize
    })

    notify(Title .. " Aktif!", "Tekan " .. currentKeybind.Name .. " atau klik tombol melayang", 3.5, Theme.Yellow)

    return WindowHandler
end

return CartoonUI

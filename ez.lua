--[[  elysium v7.0  |  Solid Premium  ]]
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local Players        = game:GetService("Players")
local GuiService     = game:GetService("GuiService")
local LocalPlayer    = Players.LocalPlayer

-- ─── SafeGui ────────────────────────────────────────────────────────────────
local SafeGui
pcall(function()
    local f = getfenv()[string.char(103,101,116,104,117,105)]
    if typeof(f) == "function" then SafeGui = f() end
end)
if not SafeGui then pcall(function() SafeGui = LocalPlayer:WaitForChild("PlayerGui",5) end) end
if not SafeGui then SafeGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") end

local function parentGui(g)
    local ok = pcall(function() g.Parent = SafeGui end)
    if not ok then pcall(function() g.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end) end
end
local function rname(p) return p.."_"..tostring(math.random(100000,999999)) end
local function safeDestroy(i) if i then pcall(function() if i.Parent then i:Destroy() end end) end end
local function tween(inst, info, props)
    if not inst then return end
    local ok, alive = pcall(function() return inst.Parent ~= nil end)
    if not ok or not alive then return end
    local ok2, t = pcall(TweenService.Create, TweenService, inst, info, props)
    if ok2 and t then pcall(function() t:Play() end) end
end
local function getMousePos()
    local mp = UserInputService:GetMouseLocation()
    local ins = GuiService:GetGuiInset()
    return Vector2.new(mp.X, mp.Y - ins.Y)
end

-- ─── Themes ─────────────────────────────────────────────────────────────────
local Themes = {
    Orange  = {Accent=Color3.fromRGB(255,175,60),  MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Purple  = {Accent=Color3.fromRGB(170,100,255), MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Cyan    = {Accent=Color3.fromRGB(60,210,230),  MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Red     = {Accent=Color3.fromRGB(235,75,75),   MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Rose    = {Accent=Color3.fromRGB(255,100,160), MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Emerald = {Accent=Color3.fromRGB(50,220,130),  MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Gold    = {Accent=Color3.fromRGB(255,210,50),  MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Ice     = {Accent=Color3.fromRGB(140,200,255), MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Sakura  = {Accent=Color3.fromRGB(255,160,200), MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
    Void    = {Accent=Color3.fromRGB(120,80,255),  MainBg=Color3.fromRGB(12,12,12), SidebarBg=Color3.fromRGB(10,10,10), CardBg=Color3.fromRGB(18,18,18), Stroke=Color3.fromRGB(38,38,38), ToggleOff=Color3.fromRGB(30,30,30), SliderBar=Color3.fromRGB(24,24,24)},
}
local Config = {White = Color3.fromRGB(255,255,255)}
local currentThemeName = "Orange"
local shimBaseH, shimBaseS, shimBaseV = Color3.toHSV(Themes.Orange.Accent)

local function applyTheme(n)
    local t = Themes[n]; if not t then return end
    currentThemeName = n
    for k,v in t do Config[k] = v end
    shimBaseH, shimBaseS, shimBaseV = Color3.toHSV(Themes[n].Accent)
end
applyTheme("Orange")

-- ─── Settings & State ───────────────────────────────────────────────────────
local Settings = {
    TriggerBot=false, TriggerDelay=0, TriggerDist=250, KnifeCheck=true, WallCheck=false, RMBOnly=false,
    ESP_Enabled=false, Box=false, HealthBar=false, Names=false, Distance=false, Tracers=false, MaxDistance=2500,
    MenuKey=Enum.KeyCode.Insert, Unloaded=false,
    HitboxEnabled=false, HitboxSize=8, HitboxTransparency=0.5,
    FakeLag=false,
}
local connections = {}
local function track(c) connections[#connections+1] = c; return c end
local Camera = workspace.CurrentCamera
local featureBinds = {}; local capturingBind = nil; local heldBinds = {}; local bindNames = {}
local function registerBind(cb)
    local e = {key=nil, mode="Toggle", state=false, callback=cb, cell=nil}
    featureBinds[#featureBinds+1] = e; return e
end
_G.Whitelist = {}

-- ─── Accent element registry ─────────────────────────────────────────────────
local accentElements = {}
local function trackAccent(i) accentElements[#accentElements+1] = i end
local hudRowMap = {}
local function recolorAll()
    for _, i in accentElements do
        if not i then continue end
        if type(i) == "table" then
            if i._pill and i._pill.Parent then
                i._pill.BackgroundColor3 = i._state() and Config.Accent or Config.ToggleOff
            end
            continue
        end
        local ok, alive = pcall(function() return i.Parent ~= nil end)
        if not ok or not alive then continue end
        if i:IsA("Frame") or i:IsA("TextButton") then i.BackgroundColor3 = Config.Accent
        elseif i:IsA("UIStroke") then i.Color = Config.Accent
        elseif i:IsA("TextLabel") then i.TextColor3 = Config.Accent end
    end
    for _, r in hudRowMap do if r.keyLbl and r.keyLbl.Parent then r.keyLbl.TextColor3 = Config.Accent end end
end

-- ─── Particle helpers ────────────────────────────────────────────────────────
local function spawnBurst(parent, x, y, color)
    local absPos = parent.AbsolutePosition
    local sg = parent.Parent
    while sg and not sg:IsA("ScreenGui") do sg = sg.Parent end
    local bp = sg or parent
    local ax, ay = absPos.X + x, absPos.Y + y
    for i = 1, 10 do
        local p = Instance.new("Frame", bp)
        p.AnchorPoint = Vector2.new(0.5,0.5)
        local sz = math.random(3,7)
        p.Size = UDim2.fromOffset(sz,sz)
        p.Position = UDim2.fromOffset(ax, ay)
        p.BackgroundColor3 = color; p.BorderSizePixel = 0; p.ZIndex = 20
        p.Active = false; p.Interactable = false
        Instance.new("UICorner",p).CornerRadius = UDim.new(1,0)
        local angle = math.rad((i-1)*36 + math.random(-20,20))
        local dist = math.random(50,120)
        local dur = math.random(45,75)/100
        tween(p, TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(ax + math.cos(angle)*dist, ay + math.sin(angle)*dist),
            Size = UDim2.fromOffset(0,0), BackgroundTransparency = 1
        })
        task.delay(dur+0.01, function() pcall(function() p:Destroy() end) end)
    end
end

local function doShine(parent, w, h, zidx)
    local absPos = parent.AbsolutePosition
    local p = parent.Parent
    while p and not p:IsA("ScreenGui") do p = p.Parent end
    local sp = p or parent
    local shine = Instance.new("Frame", sp)
    shine.Size = UDim2.fromOffset(math.max(w*0.3,30), h+16)
    shine.Position = UDim2.fromOffset(absPos.X - w*0.4, absPos.Y - 4)
    shine.BackgroundColor3 = Color3.new(1,1,1); shine.BackgroundTransparency = 0.78
    shine.BorderSizePixel = 0; shine.ZIndex = zidx or 8; shine.Rotation = 14
    shine.Active = false; shine.Interactable = false
    Instance.new("UICorner",shine).CornerRadius = UDim.new(0,6)
    local grad = Instance.new("UIGradient",shine)
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.4,0.45),
        NumberSequenceKeypoint.new(0.6,0.45), NumberSequenceKeypoint.new(1,1)
    })
    tween(shine, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.fromOffset(absPos.X + w + 20, absPos.Y - 4)})
    task.delay(0.51, function() pcall(function() shine:Destroy() end) end)
end

local function doPulseRing(parent, cx, cy, color, radius)
    radius = radius or 30
    local absPos = parent.AbsolutePosition
    local p = parent.Parent
    while p and not p:IsA("ScreenGui") do p = p.Parent end
    local rp = p or parent
    local ring = Instance.new("Frame", rp)
    ring.AnchorPoint = Vector2.new(0.5,0.5)
    ring.Size = UDim2.fromOffset(radius, radius)
    ring.Position = UDim2.fromOffset(absPos.X + cx, absPos.Y + cy)
    ring.BackgroundTransparency = 1; ring.BorderSizePixel = 0; ring.ZIndex = 15
    ring.Active = false; ring.Interactable = false
    local rs = Instance.new("UIStroke",ring); rs.Color = color; rs.Thickness = 2; rs.Transparency = 0.1
    Instance.new("UICorner",ring).CornerRadius = UDim.new(1,0)
    tween(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(radius*2.8, radius*2.8)})
    tween(rs, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 1})
    task.delay(0.51, function() pcall(function() ring:Destroy() end) end)
end

local function doFlash(parent, cx, cy, color)
    local absPos = parent.AbsolutePosition
    local p = parent.Parent
    while p and not p:IsA("ScreenGui") do p = p.Parent end
    local fp = p or parent
    local f = Instance.new("Frame", fp)
    f.AnchorPoint = Vector2.new(0.5,0.5); f.Size = UDim2.fromOffset(8,8)
    f.Position = UDim2.fromOffset(absPos.X + cx, absPos.Y + cy)
    f.BackgroundColor3 = color; f.BorderSizePixel = 0; f.ZIndex = 16
    f.Active = false; f.Interactable = false
    Instance.new("UICorner",f).CornerRadius = UDim.new(1,0)
    tween(f, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(0,0), BackgroundTransparency = 1})
    task.delay(0.36, function() pcall(function() f:Destroy() end) end)
end

-- ─── Blur overlay ────────────────────────────────────────────────────────────
local BlurGui = Instance.new("ScreenGui")
BlurGui.Name = rname("bg"); BlurGui.ResetOnSpawn = false; BlurGui.IgnoreGuiInset = true; BlurGui.DisplayOrder = 2
parentGui(BlurGui)
local blurDark = Instance.new("Frame", BlurGui)
blurDark.Size = UDim2.fromScale(1,1); blurDark.BackgroundColor3 = Color3.fromRGB(4,4,8)
blurDark.BackgroundTransparency = 1; blurDark.BorderSizePixel = 0; blurDark.ZIndex = 1
blurDark.Active = false; blurDark.Interactable = false
local function enableBlur()
    BlurGui.Enabled = true
    tween(blurDark, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3})
end
local function disableBlur()
    tween(blurDark, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    task.delay(0.26, function() if BlurGui and BlurGui.Parent then BlurGui.Enabled = false end end)
end

-- ─── Splash Screen ───────────────────────────────────────────────────────────
-- Cubic Bezier (0.1, 0.9, 0.2, 1.0) → mapped to Back/Out which closely matches
-- Roblox doesn't expose raw bezier, so we use Exponential Out for the "snap" feel
local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = rname("splash"); SplashGui.ResetOnSpawn = false
SplashGui.IgnoreGuiInset = true; SplashGui.DisplayOrder = 100
parentGui(SplashGui)

local splashBlock = Instance.new("Frame", SplashGui)
splashBlock.Size = UDim2.fromOffset(240, 110)
splashBlock.AnchorPoint = Vector2.new(0.5, 0.5)
splashBlock.Position = UDim2.new(0.5, 0, 0.5, 80)   -- начинает снизу
splashBlock.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
splashBlock.BackgroundTransparency = 1
splashBlock.BorderSizePixel = 0; splashBlock.ZIndex = 101
Instance.new("UICorner", splashBlock).CornerRadius = UDim.new(0, 25)

-- Diamond Edge: UIStroke + UIGradient от белого полупрозрачного к прозрачному
local splashStroke = Instance.new("UIStroke", splashBlock)
splashStroke.Thickness = 1; splashStroke.Transparency = 1
splashStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local splashStrokeGrad = Instance.new("UIGradient", splashStroke)
splashStrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,200,200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
})
splashStrokeGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(0.5, 0.6),
    NumberSequenceKeypoint.new(1, 0.2),
})
splashStrokeGrad.Rotation = 135

-- Star icon
local splashStar = Instance.new("TextLabel", splashBlock)
splashStar.Size = UDim2.fromOffset(32, 32); splashStar.Position = UDim2.new(0.5, -16, 0, 14)
splashStar.Text = "✦"; splashStar.Font = Enum.Font.GothamBlack; splashStar.TextSize = 22
splashStar.TextColor3 = Config.Accent; splashStar.BackgroundTransparency = 1
splashStar.TextTransparency = 1; splashStar.ZIndex = 102; splashStar.TextXAlignment = Enum.TextXAlignment.Center
trackAccent(splashStar)

-- Title
local splashTitle = Instance.new("TextLabel", splashBlock)
splashTitle.Size = UDim2.new(1, 0, 0, 38); splashTitle.Position = UDim2.new(0, 0, 0, 40)
splashTitle.Text = "ELYSIUM"; splashTitle.Font = Enum.Font.GothamBlack; splashTitle.TextSize = 32
splashTitle.TextColor3 = Color3.fromRGB(255,255,255); splashTitle.BackgroundTransparency = 1
splashTitle.TextTransparency = 1; splashTitle.ZIndex = 102; splashTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Sub
local splashSub = Instance.new("TextLabel", splashBlock)
splashSub.Size = UDim2.new(1, 0, 0, 18); splashSub.Position = UDim2.new(0, 0, 0, 78)
splashSub.Text = "premium triggerbot"; splashSub.Font = Enum.Font.Gotham; splashSub.TextSize = 12
splashSub.TextColor3 = Config.Accent; splashSub.BackgroundTransparency = 1
splashSub.TextTransparency = 1; splashSub.ZIndex = 102; splashSub.TextXAlignment = Enum.TextXAlignment.Center
trackAccent(splashSub)

-- Animate splash: всплытие снизу вверх (Exponential Out ≈ Cubic Bezier 0.1,0.9,0.2,1.0)
local splashInfo = TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
tween(splashBlock, splashInfo, {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0)
})
tween(splashStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = 0})
task.delay(0.2, function()
    tween(splashStar,  TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})
    tween(splashTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})
    tween(splashSub,   TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})
end)

-- ─── Library ─────────────────────────────────────────────────────────────────
local Library = {}; Library.__index = Library

function Library.new(titleText)
    local lib = setmetatable({}, Library)
    lib.SG = Instance.new("ScreenGui"); lib.SG.Name = rname("ui")
    lib.SG.ResetOnSpawn = false; lib.SG.IgnoreGuiInset = true; lib.SG.DisplayOrder = 10
    lib.SG.Enabled = false   -- скрыт до конца splash
    parentGui(lib.SG)

    lib.Overlay = Instance.new("Frame", lib.SG)
    lib.Overlay.Size = UDim2.fromScale(1,1); lib.Overlay.BackgroundColor3 = Color3.new(0,0,0)
    lib.Overlay.BackgroundTransparency = 1; lib.Overlay.BorderSizePixel = 0; lib.Overlay.ZIndex = 1
    lib.Overlay.Active = false; lib.Overlay.Interactable = false

    lib.StarBg = Instance.new("Frame", lib.SG)
    lib.StarBg.Size = UDim2.fromScale(1,1); lib.StarBg.BackgroundTransparency = 1
    lib.StarBg.BorderSizePixel = 0; lib.StarBg.ZIndex = 2

    -- Main Frame: глубокий матовый графит RGB(12,12,12), BackgroundTransparency=0
    lib.Main = Instance.new("Frame", lib.SG)
    lib.Main.Size = UDim2.fromOffset(900, 620)
    lib.Main.Position = UDim2.new(0.5, -450, 0.5, -310)
    lib.Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    lib.Main.BackgroundTransparency = 1
    lib.Main.BorderSizePixel = 0; lib.Main.ZIndex = 3; lib.Main.ClipsDescendants = true
    Instance.new("UICorner", lib.Main).CornerRadius = UDim.new(0, 18)

    -- Diamond Edge: UIStroke 1px + UIGradient от белого полупрозрачного к прозрачному
    local mainStroke = Instance.new("UIStroke", lib.Main)
    mainStroke.Thickness = 1; mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Transparency = 0
    local mainStrokeGrad = Instance.new("UIGradient", mainStroke)
    mainStrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(180,180,180)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(80,80,80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })
    mainStrokeGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.7),
        NumberSequenceKeypoint.new(1, 0.1),
    })
    mainStrokeGrad.Rotation = 135
    lib.MainStroke = mainStroke

    -- Sidebar: матовый графит
    lib.Sidebar = Instance.new("Frame", lib.Main)
    lib.Sidebar.Name = "Sidebar"; lib.Sidebar.Size = UDim2.new(0, 220, 1, 0)
    lib.Sidebar.Position = UDim2.new(0, -220, 0, 0)
    lib.Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    lib.Sidebar.BorderSizePixel = 0; lib.Sidebar.ZIndex = 3
    Instance.new("UICorner", lib.Sidebar).CornerRadius = UDim.new(0, 18)

    -- Sidebar right divider
    local sbDiv = Instance.new("Frame", lib.Sidebar)
    sbDiv.Size = UDim2.fromOffset(1, 0); sbDiv.Position = UDim2.new(1, -1, 0, 0)
    sbDiv.BackgroundColor3 = Config.Accent; sbDiv.BackgroundTransparency = 0.7
    sbDiv.BorderSizePixel = 0; sbDiv.ZIndex = 4; sbDiv.AutomaticSize = Enum.AutomaticSize.Y
    trackAccent(sbDiv)

    local titlePad = Instance.new("Frame", lib.Sidebar)
    titlePad.Size = UDim2.new(1, 0, 0, 96); titlePad.BackgroundTransparency = 1; titlePad.ZIndex = 3

    local title = Instance.new("TextLabel", titlePad)
    title.Size = UDim2.new(1, 0, 0, 52); title.Position = UDim2.new(0, 0, 0, 14)
    title.Text = titleText; title.Font = Enum.Font.GothamBlack; title.TextSize = 42
    title.TextColor3 = Config.White; title.BackgroundTransparency = 1
    title.TextTransparency = 1; title.TextStrokeTransparency = 1
    title.TextStrokeColor3 = Config.Accent; title.ZIndex = 3
    title.TextXAlignment = Enum.TextXAlignment.Center

    local subTitle = Instance.new("TextLabel", titlePad)
    subTitle.Size = UDim2.new(1, -20, 0, 18); subTitle.Position = UDim2.new(0, 12, 0, 60)
    subTitle.Text = ""; subTitle.Font = Enum.Font.Gotham; subTitle.TextSize = 14
    subTitle.TextColor3 = Config.Accent; subTitle.BackgroundTransparency = 1
    subTitle.TextTransparency = 0.3; subTitle.TextStrokeTransparency = 1
    trackAccent(subTitle)

    local accentLine = Instance.new("Frame", lib.Sidebar)
    accentLine.Size = UDim2.fromOffset(0, 2); accentLine.Position = UDim2.new(0, 10, 0, 72)
    accentLine.BackgroundColor3 = Config.Accent; accentLine.BorderSizePixel = 0; accentLine.ZIndex = 3
    Instance.new("UICorner", accentLine).CornerRadius = UDim.new(1, 0); trackAccent(accentLine)

    lib.TabBtnHolder = Instance.new("Frame", lib.Sidebar)
    lib.TabBtnHolder.Size = UDim2.new(1, 0, 1, -108); lib.TabBtnHolder.Position = UDim2.new(0, 0, 0, 108)
    lib.TabBtnHolder.BackgroundTransparency = 1; lib.TabBtnHolder.ZIndex = 3
    local tbl = Instance.new("UIListLayout", lib.TabBtnHolder)
    tbl.Padding = UDim.new(0, 6); tbl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local tbPad = Instance.new("UIPadding", lib.TabBtnHolder); tbPad.PaddingTop = UDim.new(0, 8)

    lib.Container = Instance.new("Frame", lib.Main)
    lib.Container.Name = "ContentContainer"; lib.Container.Size = UDim2.new(1, -240, 1, -24)
    lib.Container.Position = UDim2.new(0, 232, 0, 12); lib.Container.BackgroundTransparency = 1
    lib.Container.ClipsDescendants = true; lib.Container.ZIndex = 3

    lib.Tabs = {}; lib.TabButtons = {}
    lib._title = title; lib._subTitle = subTitle; lib._accentLine = accentLine

    -- Dragging
    local dragging, dStart, fStart = false, nil, nil
    lib.Sidebar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dStart = i.Position; fStart = lib.Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dStart
            lib.Main.Position = UDim2.new(fStart.X.Scale, fStart.X.Offset+d.X, fStart.Y.Scale, fStart.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return lib
end

function Library:_openAnim()
    self.SG.Enabled = true
    -- Main уже настроен splash-морфингом, просто показываем элементы
    self.Main.BackgroundTransparency = 0
    self.Main.Visible = true
    self.Overlay.Visible = true
    self.StarBg.Visible = true
    tween(self.Overlay, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.45})
    self.Sidebar.Position = UDim2.new(0,-220,0,0)
    task.delay(0.08, function()
        if not self.Sidebar or not self.Sidebar.Parent then return end
        tween(self.Sidebar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)})
    end)
    task.delay(0.2, function()
        if not self._title or not self._title.Parent then return end
        self._title.Position = UDim2.new(0,0,0,22)
        tween(self._title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
            {TextTransparency=0, TextStrokeTransparency=0.7, Position=UDim2.new(0,0,0,14)})
        tween(self._subTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency=0.3})
    end)
    task.delay(0.3, function()
        if not self._accentLine or not self._accentLine.Parent then return end
        tween(self._accentLine, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(190,2)})
    end)
    enableBlur()
end

function Library:SetVisible(v)
    if v then
        self.Main.Visible = true; self.Overlay.Visible = true; self.StarBg.Visible = true
        self.Main.BackgroundTransparency = 0.8
        self.Main.Size = UDim2.fromOffset(830, 560)
        self.Main.Position = UDim2.new(0.5, -415, 0.54, -280)
        tween(self.Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
            {BackgroundTransparency=0, Size=UDim2.fromOffset(900,620), Position=UDim2.new(0.5,-450,0.5,-310)})
        tween(self.Overlay, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundTransparency=0.52})
        self.Sidebar.Position = UDim2.new(0,-220,0,0)
        task.delay(0.08, function()
            if not self.Sidebar or not self.Sidebar.Parent then return end
            tween(self.Sidebar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position=UDim2.new(0,0,0,0)})
        end)
        enableBlur()
    else
        if themeDropFrame and themeDropFrame.Parent then themeDropFrame:Destroy(); themeDropFrame=nil; themeDropOpen=false end
        if self.MainStroke and self.MainStroke.Parent then
            tween(self.MainStroke, TweenInfo.new(0.08), {Transparency=0, Thickness=2})
        end
        task.delay(0.06, function()
            tween(self.Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection["In"]),
                {BackgroundTransparency=1, Size=UDim2.fromOffset(875,605), Position=UDim2.new(0.5,-437,0.5,-302)})
            tween(self.Overlay, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {BackgroundTransparency=1})
            tween(self.Sidebar, TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection["In"]), {Position=UDim2.new(0,-220,0,0)})
        end)
        disableBlur()
        task.delay(0.27, function()
            if self.Main and self.Main.Parent then
                self.Main.Visible = false
                self.Main.Size = UDim2.fromOffset(900,620)
                self.Main.Position = UDim2.new(0.5,-450,0.5,-310)
            end
            if self.Overlay and self.Overlay.Parent then self.Overlay.Visible = false end
            if self.StarBg and self.StarBg.Parent then self.StarBg.Visible = false end
            if self.MainStroke and self.MainStroke.Parent then self.MainStroke.Transparency = 0; self.MainStroke.Thickness = 1 end
        end)
    end
end

-- ─── CreateTab: CanvasGroup анимация вкладок (Exponential 0.6s) ──────────────
function Library:CreateTab(name)
    local isFirst = #self.Tabs == 0
    local btn = Instance.new("TextButton", self.TabBtnHolder)
    btn.Size = UDim2.new(0.92, 0, 0, 50)
    btn.BackgroundColor3 = isFirst and Color3.fromRGB(22,22,22) or Color3.fromRGB(16,16,16)
    btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local leftBar = Instance.new("Frame", btn)
    leftBar.Size = UDim2.fromOffset(3, isFirst and 26 or 0)
    leftBar.Position = UDim2.new(0, 0, 0.5, 0); leftBar.AnchorPoint = Vector2.new(0, 0.5)
    leftBar.BackgroundColor3 = Config.Accent; leftBar.BorderSizePixel = 0; leftBar.ZIndex = 5
    Instance.new("UICorner", leftBar).CornerRadius = UDim.new(1, 0); trackAccent(leftBar)

    local btnGlow = Instance.new("Frame", btn)
    btnGlow.Size = UDim2.new(1,0,1,0); btnGlow.BackgroundColor3 = Config.Accent
    btnGlow.BackgroundTransparency = isFirst and 0.88 or 1
    btnGlow.BorderSizePixel = 0; btnGlow.ZIndex = 2
    Instance.new("UICorner", btnGlow).CornerRadius = UDim.new(0, 10); trackAccent(btnGlow)

    local btnLbl = Instance.new("TextLabel", btn)
    btnLbl.Size = UDim2.new(1,-14,1,0); btnLbl.Position = UDim2.fromOffset(12,0)
    btnLbl.Text = name; btnLbl.Font = Enum.Font.GothamBold; btnLbl.TextSize = 18
    btnLbl.TextColor3 = isFirst and Config.White or Color3.fromRGB(120,120,120)
    btnLbl.BackgroundTransparency = 1; btnLbl.TextXAlignment = Enum.TextXAlignment.Left
    btnLbl.TextStrokeTransparency = 1; btnLbl.ZIndex = 4

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Config.Accent; stroke.Thickness = 1; stroke.Enabled = isFirst
    stroke.Transparency = 0.6; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; trackAccent(stroke)

    -- CanvasGroup для анимации вкладки
    local canvas = Instance.new("CanvasGroup", self.Container)
    canvas.Size = UDim2.fromScale(1,1); canvas.BackgroundTransparency = 1
    canvas.Visible = isFirst; canvas.ZIndex = 3; canvas.GroupTransparency = isFirst and 0 or 1

    local page = Instance.new("ScrollingFrame", canvas)
    page.Size = UDim2.fromScale(1,1); page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0; page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.ZIndex = 3
    local pl = Instance.new("UIListLayout", page); pl.Padding = UDim.new(0, 10)

    btn.MouseEnter:Connect(function()
        if not stroke.Enabled then
            tween(btn, TweenInfo.new(0.16, Enum.EasingStyle.Quint), {BackgroundColor3=Color3.fromRGB(22,22,22)})
            tween(btnLbl, TweenInfo.new(0.16), {TextColor3=Color3.fromRGB(200,200,200)})
            tween(leftBar, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(3,14)})
            tween(btnGlow, TweenInfo.new(0.18), {BackgroundTransparency=0.93})
        else
            tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quint), {Size=UDim2.new(0.94,0,0,52)})
        end
    end)
    btn.MouseLeave:Connect(function()
        if not stroke.Enabled then
            tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3=Color3.fromRGB(16,16,16)})
            tween(btnLbl, TweenInfo.new(0.2), {TextColor3=Color3.fromRGB(120,120,120)})
            tween(leftBar, TweenInfo.new(0.18), {Size=UDim2.fromOffset(3,0)})
            tween(btnGlow, TweenInfo.new(0.22), {BackgroundTransparency=1})
        else
            tween(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {Size=UDim2.new(0.92,0,0,50)})
        end
    end)

    btn.MouseButton1Click:Connect(function()
        -- Debounce: не запускаем если эта вкладка уже активна
        if canvas.Visible and canvas.GroupTransparency == 0 then return end

        local EXIT_T  = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection["In"])
        local ENTER_T = TweenInfo.new(0.4,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        -- Мгновенно завершаем все текущие анимации и скрываем старые вкладки
        for _, tab in self.Tabs do
            if tab ~= canvas then
                -- Cancel любых активных твинов через принудительный сброс
                local pg = tab:FindFirstChildOfClass("ScrollingFrame")
                -- Принудительный reset: GroupTransparency=1, Visible=false, page сброшен
                tab.GroupTransparency = 1
                tab.Visible = false
                if pg then pg.Position = UDim2.fromOffset(0, 0) end
            end
        end

        -- Сброс кнопок
        for _, ob in self.TabButtons do
            local s = ob:FindFirstChildOfClass("UIStroke"); if s then s.Enabled = false end
            tween(ob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3=Color3.fromRGB(16,16,16)})
            for _, ch in ob:GetChildren() do
                if ch:IsA("TextLabel") then tween(ch, TweenInfo.new(0.18), {TextColor3=Color3.fromRGB(120,120,120)}) end
                if ch:IsA("Frame") and ch.Name == "leftBar" then tween(ch, TweenInfo.new(0.18), {Size=UDim2.fromOffset(3,0)}) end
                if ch:IsA("Frame") and ch ~= leftBar then tween(ch, TweenInfo.new(0.18), {BackgroundTransparency=1}) end
            end
        end

        -- Активируем кнопку новой вкладки
        stroke.Enabled = true
        tween(btn, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {BackgroundColor3=Color3.fromRGB(22,22,22)})
        tween(btnLbl, TweenInfo.new(0.2), {TextColor3=Config.White})
        tween(leftBar, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(3,26)})
        tween(btnGlow, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency=0.88})
        btn.Size = UDim2.new(0.88,0,0,48)
        tween(btn, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(0.92,0,0,50)})

        -- Новая вкладка: начальная точка — снизу, прозрачная
        canvas.GroupTransparency = 1
        canvas.Visible = true
        page.Position = UDim2.fromOffset(0, 40)

        -- Вылет снизу вверх + появление (Quart Out, 0.4s)
        tween(canvas, ENTER_T, {GroupTransparency = 0})
        tween(page,   ENTER_T, {Position = UDim2.fromOffset(0, 0)})
    end)

    leftBar.Name = "leftBar"
    self.Tabs[#self.Tabs+1] = canvas
    self.TabButtons[#self.TabButtons+1] = btn
    return page
end

-- ─── Section ─────────────────────────────────────────────────────────────────
local Section = {}; Section.__index = Section

function Library:CreateSection(tab, name)
    local sec = setmetatable({}, Section)
    local card = Instance.new("Frame", tab)
    card.Size = UDim2.new(1,-14,0,0); card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(18,18,18)
    card.BorderSizePixel = 0; card.ZIndex = 3
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    -- Diamond Edge на карточке
    local st = Instance.new("UIStroke", card); st.Thickness = 1; st.Transparency = 0
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local stGrad = Instance.new("UIGradient", st)
    stGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60,60,60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })
    stGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.85),
        NumberSequenceKeypoint.new(1, 0.3),
    })
    stGrad.Rotation = 135

    local pad = Instance.new("UIPadding", card)
    pad.PaddingLeft = UDim.new(0,14); pad.PaddingRight = UDim.new(0,14)
    pad.PaddingTop = UDim.new(0,12); pad.PaddingBottom = UDim.new(0,14)
    local list = Instance.new("UIListLayout", card)
    list.Padding = UDim.new(0,8); list.SortOrder = Enum.SortOrder.LayoutOrder

    local headRow = Instance.new("Frame", card)
    headRow.Size = UDim2.new(1,0,0,26); headRow.BackgroundTransparency = 1; headRow.ZIndex = 3; headRow.LayoutOrder = 0

    local headBar = Instance.new("Frame", headRow)
    headBar.Size = UDim2.fromOffset(3,18); headBar.Position = UDim2.new(0,0,0.5,-9)
    headBar.BackgroundColor3 = Config.Accent; headBar.BorderSizePixel = 0; headBar.ZIndex = 4
    Instance.new("UICorner", headBar).CornerRadius = UDim.new(1,0); trackAccent(headBar)

    local headBarGlow = Instance.new("Frame", headRow)
    headBarGlow.Size = UDim2.fromOffset(12,18); headBarGlow.Position = UDim2.new(0,-4,0.5,-9)
    headBarGlow.BackgroundColor3 = Config.Accent; headBarGlow.BackgroundTransparency = 0.75
    headBarGlow.BorderSizePixel = 0; headBarGlow.ZIndex = 3
    Instance.new("UICorner", headBarGlow).CornerRadius = UDim.new(1,0); trackAccent(headBarGlow)

    local head = Instance.new("TextLabel", headRow)
    head.Size = UDim2.new(1,-16,1,0); head.Position = UDim2.fromOffset(12,0)
    head.Text = name:upper(); head.Font = Enum.Font.GothamBold; head.TextSize = 12
    head.TextColor3 = Config.Accent; head.TextXAlignment = Enum.TextXAlignment.Left
    head.BackgroundTransparency = 1; head.TextStrokeTransparency = 1; head.ZIndex = 4
    head.TextTransparency = 0.15; trackAccent(head)

    local divider = Instance.new("Frame", card)
    divider.Size = UDim2.new(1,0,0,1); divider.BackgroundColor3 = Config.Accent
    divider.BackgroundTransparency = 0.82; divider.BorderSizePixel = 0; divider.ZIndex = 3; divider.LayoutOrder = 1
    Instance.new("UIGradient", divider).Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.15,0),
        NumberSequenceKeypoint.new(0.85,0), NumberSequenceKeypoint.new(1,1)
    })
    trackAccent(divider)

    card.MouseEnter:Connect(function()
        tween(st, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Transparency=0, Thickness=1.3})
        tween(headBarGlow, TweenInfo.new(0.22), {BackgroundTransparency=0.6, Size=UDim2.fromOffset(16,22)})
        tween(head, TweenInfo.new(0.18), {TextTransparency=0})
        tween(divider, TweenInfo.new(0.2), {BackgroundTransparency=0.65})
    end)
    card.MouseLeave:Connect(function()
        tween(st, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {Transparency=0, Thickness=1})
        tween(headBarGlow, TweenInfo.new(0.25), {BackgroundTransparency=0.75, Size=UDim2.fromOffset(12,18)})
        tween(head, TweenInfo.new(0.2), {TextTransparency=0.15})
        tween(divider, TweenInfo.new(0.25), {BackgroundTransparency=0.82})
    end)

    sec.Card = card; return sec
end

-- ─── Bind cell ───────────────────────────────────────────────────────────────
local function makeBindCell(parent, entry)
    local modeBtn = Instance.new("TextButton", parent)
    modeBtn.Size = UDim2.fromOffset(46,22); modeBtn.Position = UDim2.new(1,-106,0.5,-11)
    modeBtn.BackgroundColor3 = Config.ToggleOff; modeBtn.Text = "TGL"
    modeBtn.Font = Enum.Font.GothamBold; modeBtn.TextSize = 18; modeBtn.TextColor3 = Config.White
    modeBtn.AutoButtonColor = false; modeBtn.TextStrokeTransparency = 1; modeBtn.ZIndex = 4
    Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0,5)

    local cell = Instance.new("TextButton", parent)
    cell.Size = UDim2.fromOffset(58,22); cell.Position = UDim2.new(1,-58,0.5,-11)
    cell.BackgroundColor3 = Config.ToggleOff; cell.Text = "NONE"
    cell.Font = Enum.Font.GothamBold; cell.TextSize = 18; cell.TextColor3 = Config.White
    cell.AutoButtonColor = false; cell.TextStrokeTransparency = 1; cell.ZIndex = 4
    Instance.new("UICorner", cell).CornerRadius = UDim.new(0,5)
    entry.cell = cell

    modeBtn.MouseButton1Click:Connect(function()
        entry.mode = entry.mode == "Toggle" and "Hold" or "Toggle"
        modeBtn.Text = entry.mode == "Toggle" and "TGL" or "HLD"
        tween(modeBtn, TweenInfo.new(0.15), {BackgroundColor3 = entry.mode=="Hold" and Config.Accent or Config.ToggleOff})
    end)
    cell.MouseButton1Click:Connect(function()
        capturingBind = entry; cell.Text = "..."
        tween(cell, TweenInfo.new(0.12), {BackgroundColor3 = Config.Accent})
        cell.Size = UDim2.fromOffset(62,24)
        tween(cell, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(58,22)})
    end)
    cell.MouseButton2Click:Connect(function()
        entry.key = nil; cell.Text = "NONE"
        tween(cell, TweenInfo.new(0.15), {BackgroundColor3 = Config.ToggleOff})
        cell.Size = UDim2.fromOffset(54,20)
        tween(cell, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(58,22)})
    end)
end

-- ─── Toggle ──────────────────────────────────────────────────────────────────
function Section:AddToggle(text, default, callback)
    local entry = registerBind(function(v) end); bindNames[entry] = text
    local row = Instance.new("Frame", self.Card)
    row.Size = UDim2.new(1,0,0,36); row.BackgroundColor3 = Color3.fromRGB(22,22,22)
    row.BackgroundTransparency = 1; row.BorderSizePixel = 0; row.ZIndex = 3; row.Active = false
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = Config.Accent; rowStroke.Thickness = 1; rowStroke.Transparency = 1
    rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; trackAccent(rowStroke)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-114,1,0); lbl.Text = text; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 17
    lbl.TextColor3 = Config.White; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1; lbl.TextStrokeTransparency = 1; lbl.ZIndex = 3

    local pill = Instance.new("TextButton", row)
    pill.Size = UDim2.fromOffset(50,26); pill.Position = UDim2.new(1,-168,0.5,-13)
    pill.BackgroundColor3 = default and Config.Accent or Config.ToggleOff
    pill.Text = ""; pill.AutoButtonColor = false; pill.ZIndex = 4
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0,6)

    local dot = Instance.new("Frame", pill); dot.Size = UDim2.fromOffset(18,18)
    dot.Position = default and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)
    dot.BackgroundColor3 = Config.White; dot.ZIndex = 6
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0,4)

    row.MouseEnter:Connect(function()
        tween(row, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {BackgroundTransparency=0.72})
        tween(lbl, TweenInfo.new(0.14), {TextColor3=Config.Accent})
        tween(rowStroke, TweenInfo.new(0.18), {Transparency=0.6})
    end)
    row.MouseLeave:Connect(function()
        tween(row, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency=1})
        tween(lbl, TweenInfo.new(0.2), {TextColor3=Config.White})
        tween(rowStroke, TweenInfo.new(0.22), {Transparency=1})
    end)
    row.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local ripple = Instance.new("Frame", row)
        ripple.AnchorPoint = Vector2.new(0.5,0.5); ripple.BackgroundColor3 = Config.Accent
        ripple.BackgroundTransparency = 0.55; ripple.BorderSizePixel = 0; ripple.ZIndex = 6
        ripple.Size = UDim2.fromOffset(0,0)
        local mp = getMousePos(); local rp = row.AbsolutePosition
        ripple.Position = UDim2.fromOffset(mp.X-rp.X, mp.Y-rp.Y)
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)
        tween(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Size=UDim2.fromOffset(220,220), BackgroundTransparency=1})
        task.delay(0.51, function() pcall(function() ripple:Destroy() end) end)
    end)

    local state = default
    local pillAccentRef = {_pill=pill, _state=function() return state end}
    accentElements[#accentElements+1] = pillAccentRef

    local function setState(v)
        state = v
        -- мгновенная смена цвета через TweenService (адаптивная тема)
        tween(pill, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {BackgroundColor3 = state and Config.Accent or Config.ToggleOff})
        tween(dot, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = state and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)})
        dot.Size = UDim2.fromOffset(22,22)
        tween(dot, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(18,18)})
        pill.Size = UDim2.fromOffset(56,30)
        tween(pill, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(50,26)})
        if state then
            local ring = Instance.new("Frame", row)
            ring.AnchorPoint = Vector2.new(0.5,0.5); ring.Size = UDim2.fromOffset(28,28)
            ring.Position = UDim2.new(1,-143,0.5,0); ring.BackgroundTransparency = 1
            ring.BorderSizePixel = 0; ring.ZIndex = 7
            local rs = Instance.new("UIStroke", ring); rs.Color = Config.Accent; rs.Thickness = 2.5; rs.Transparency = 0.1
            Instance.new("UICorner", ring).CornerRadius = UDim.new(0,6)
            tween(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(62,38)})
            tween(rs, TweenInfo.new(0.45), {Transparency=1})
            task.delay(0.46, function() pcall(function() ring:Destroy() end) end)
            lbl.TextSize = 19
            tween(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize=17})
        end
        callback(state)
    end
    pill.MouseButton1Click:Connect(function() setState(not state) end)
    entry.callback = setState; makeBindCell(row, entry); return entry
end

-- ─── Slider ──────────────────────────────────────────────────────────────────
function Section:AddSlider(text, min, max, default, callback, float)
    local sCont = Instance.new("Frame", self.Card)
    sCont.Size = UDim2.new(1,0,0,56); sCont.BackgroundTransparency = 1; sCont.Active = true; sCont.ZIndex = 3

    local sTitle = Instance.new("TextLabel", sCont)
    sTitle.Size = UDim2.new(0.7,0,0,20); sTitle.Text = text; sTitle.Font = Enum.Font.Gotham; sTitle.TextSize = 14
    sTitle.TextColor3 = Color3.fromRGB(200,200,200); sTitle.BackgroundTransparency = 1
    sTitle.TextXAlignment = Enum.TextXAlignment.Left; sTitle.TextStrokeTransparency = 1; sTitle.ZIndex = 3

    local valLbl = Instance.new("TextLabel", sCont)
    valLbl.Size = UDim2.fromOffset(64,20); valLbl.Position = UDim2.new(1,-64,0,0)
    valLbl.Text = tostring(default); valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 14
    valLbl.TextColor3 = Config.Accent; valLbl.BackgroundTransparency = 1
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.TextStrokeTransparency = 1; valLbl.ZIndex = 3
    trackAccent(valLbl)

    -- Трек: RGB(25,25,25) — контрастнее фона карточки (18,18,18)
    local bar = Instance.new("Frame", sCont)
    bar.Size = UDim2.new(1,0,0,7); bar.Position = UDim2.new(0,0,0,34)
    bar.BackgroundColor3 = Color3.fromRGB(25,25,25); bar.BorderSizePixel = 0; bar.ZIndex = 3
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    -- Тонкая обводка трека для чёткости
    local barStroke = Instance.new("UIStroke", bar)
    barStroke.Thickness = 0.5; barStroke.Color = Color3.fromRGB(55,55,55); barStroke.Transparency = 0
    barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Заполнение: акцентный цвет, меняется при смене темы
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Config.Accent; fill.BorderSizePixel = 0; fill.ZIndex = 4
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0); trackAccent(fill)

    -- Ползунок: всегда виден (12px в покое), акцентный цвет
    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.fromOffset(12,12); knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
    knob.BackgroundColor3 = Config.White; knob.BorderSizePixel = 0; knob.ZIndex = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Thickness = 1.5; knobStroke.Color = Config.Accent; knobStroke.Transparency = 0.3
    trackAccent(knobStroke)

    local knobGlow = Instance.new("Frame", bar)
    knobGlow.Size = UDim2.fromOffset(0,0); knobGlow.AnchorPoint = Vector2.new(0.5,0.5)
    knobGlow.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
    knobGlow.BackgroundColor3 = Config.Accent; knobGlow.BackgroundTransparency = 1
    knobGlow.BorderSizePixel = 0; knobGlow.ZIndex = 5
    Instance.new("UICorner", knobGlow).CornerRadius = UDim.new(1,0); trackAccent(knobGlow)

    bar.MouseEnter:Connect(function()
        tween(bar, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size=UDim2.new(1,0,0,9), Position=UDim2.new(0,0,0,33)})
        tween(knob, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(16,16)})
        tween(knobGlow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(26,26), BackgroundTransparency=0.65})
        tween(sTitle, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {TextColor3=Config.Accent})
    end)
    bar.MouseLeave:Connect(function()
        tween(bar, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size=UDim2.new(1,0,0,7), Position=UDim2.new(0,0,0,34)})
        if not _dragging then
            tween(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(12,12)})
            tween(knobGlow, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(0,0), BackgroundTransparency=1})
        end
        tween(sTitle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextColor3=Color3.fromRGB(200,200,200)})
    end)

    local _dragging = false
    local function update()
        local r = math.clamp((getMousePos().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = min + (max-min)*r; if not float then v = math.round(v) end
        fill.Size = UDim2.new(r,0,1,0)
        knob.Position = UDim2.new(r,0,0.5,0); knobGlow.Position = UDim2.new(r,0,0.5,0)
        local newText = float and string.format("%.2f",v) or tostring(v)
        if newText ~= valLbl.Text then
            valLbl.Text = newText; valLbl.TextSize = 16
            tween(valLbl, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize=14})
        end
        callback(v)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            _dragging = true
            tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(20,20)})
            tween(knobGlow, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(32,32), BackgroundTransparency=0.6})
            tween(bar, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,0,32)})
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and _dragging then
            _dragging = false
            tween(knob, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(16,16)})
            tween(knobGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(26,26), BackgroundTransparency=0.65})
            tween(bar, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size=UDim2.new(1,0,0,9), Position=UDim2.new(0,0,0,33)})
            doPulseRing(bar, knob.Position.X.Scale*bar.AbsoluteSize.X, 0, Config.Accent, 8)
        end
    end)
    track(RunService.RenderStepped:Connect(function() if _dragging then update() end end))

    local function setValue(v)
        v = math.clamp(v, min, max); if not float then v = math.round(v) end
        local r = (v-min)/(max-min)
        fill.Size = UDim2.new(r,0,1,0)
        knob.Position = UDim2.new(r,0,0.5,0); knobGlow.Position = UDim2.new(r,0,0.5,0)
        valLbl.Text = float and string.format("%.2f",v) or tostring(v)
        callback(v)
    end
    return {SetValue = setValue}
end

-- ─── Button ──────────────────────────────────────────────────────────────────
function Section:AddButton(text, callback)
    local btn = Instance.new("TextButton", self.Card)
    btn.Size = UDim2.new(1,0,0,36); btn.BackgroundColor3 = Color3.fromRGB(22,22,22)
    btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 26
    btn.TextColor3 = Config.White; btn.AutoButtonColor = false; btn.TextStrokeTransparency = 1; btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,9)

    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Config.Accent; btnStroke.Thickness = 1; btnStroke.Transparency = 1
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; trackAccent(btnStroke)

    btn.MouseEnter:Connect(function()
        tween(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3=Config.Accent})
        tween(btn, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(1,4,0,38)})
        tween(btnStroke, TweenInfo.new(0.18), {Transparency=0.45})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundColor3=Color3.fromRGB(22,22,22)})
        tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size=UDim2.new(1,0,0,36)})
        tween(btnStroke, TweenInfo.new(0.22), {Transparency=1})
    end)
    btn.MouseButton1Down:Connect(function()
        tween(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection["In"]), {Size=UDim2.new(0.97,0,0,33)})
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(1,4,0,38)})
    end)
    btn.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame", btn)
        ripple.AnchorPoint = Vector2.new(0.5,0.5); ripple.BackgroundColor3 = Color3.new(1,1,1)
        ripple.BackgroundTransparency = 0.7; ripple.BorderSizePixel = 0; ripple.ZIndex = 5
        ripple.Size = UDim2.fromOffset(0,0)
        local mp = getMousePos(); local bp = btn.AbsolutePosition
        ripple.Position = UDim2.fromOffset(mp.X-bp.X, mp.Y-bp.Y)
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)
        tween(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Size=UDim2.fromOffset(320,320), BackgroundTransparency=1})
        task.delay(0.51, function() pcall(function() ripple:Destroy() end) end)
        doPulseRing(btn, btn.AbsoluteSize.X/2, 18, Config.Accent, 20)
        pcall(callback)
    end)
    return btn
end

-- ─── ColorPicker ─────────────────────────────────────────────────────────────
function Section:AddColorPicker(text, default, callback)
    local currentColor = default or Color3.fromRGB(255,255,255)
    local row = Instance.new("Frame", self.Card)
    row.Size = UDim2.new(1,0,0,36); row.BackgroundTransparency = 1; row.BorderSizePixel = 0; row.ZIndex = 3
    local rowSt = Instance.new("UIStroke", row)
    rowSt.Color = Config.Accent; rowSt.Thickness = 1; rowSt.Transparency = 1
    rowSt.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; trackAccent(rowSt)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-46,1,0); lbl.Text = text; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 17
    lbl.TextColor3 = Config.White; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1; lbl.TextStrokeTransparency = 1; lbl.ZIndex = 3
    local swatch = Instance.new("TextButton", row)
    swatch.Size = UDim2.fromOffset(32,22); swatch.Position = UDim2.new(1,-36,0.5,-11)
    swatch.BackgroundColor3 = currentColor; swatch.Text = ""; swatch.AutoButtonColor = false; swatch.ZIndex = 4
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", swatch).Color = Color3.fromRGB(60,60,60)
    row.MouseEnter:Connect(function()
        tween(lbl, TweenInfo.new(0.14), {TextColor3=Config.Accent})
        tween(rowSt, TweenInfo.new(0.16), {Transparency=0.65})
        tween(swatch, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(36,26)})
    end)
    row.MouseLeave:Connect(function()
        tween(lbl, TweenInfo.new(0.2), {TextColor3=Config.White})
        tween(rowSt, TweenInfo.new(0.2), {Transparency=1})
        if not _pickerOpen then tween(swatch, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(32,22)}) end
    end)
    local _pickerOpen = false
    local popup = Instance.new("Frame", self.Card)
    popup.Size = UDim2.new(1,0,0,0); popup.BackgroundColor3 = Color3.fromRGB(16,16,16)
    popup.BorderSizePixel = 0; popup.ClipsDescendants = true; popup.ZIndex = 5; popup.Visible = false
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0,12)
    local popStroke = Instance.new("UIStroke", popup)
    popStroke.Color = Config.Accent; popStroke.Thickness = 1.2; popStroke.Transparency = 0.5; trackAccent(popStroke)
    local popPad = Instance.new("UIPadding", popup)
    popPad.PaddingLeft = UDim.new(0,10); popPad.PaddingRight = UDim.new(0,10)
    popPad.PaddingTop = UDim.new(0,10); popPad.PaddingBottom = UDim.new(0,10)
    local hueBar = Instance.new("Frame", popup); hueBar.Size = UDim2.new(1,0,0,14); hueBar.BackgroundColor3 = Color3.new(1,1,1)
    hueBar.BorderSizePixel = 0; hueBar.ZIndex = 6; hueBar.Active = true
    Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0,5)
    local hueGrad = Instance.new("UIGradient", hueBar)
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.167,Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.333,Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.667,Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.833,Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
    })
    local hueKnob = Instance.new("Frame", hueBar)
    hueKnob.Size = UDim2.fromOffset(8,20); hueKnob.AnchorPoint = Vector2.new(0.5,0.5)
    hueKnob.Position = UDim2.new(0,0,0.5,0); hueKnob.BackgroundColor3 = Color3.new(1,1,1)
    hueKnob.BorderSizePixel = 0; hueKnob.ZIndex = 9
    Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0,4)
    local hkStroke = Instance.new("UIStroke", hueKnob); hkStroke.Color = Color3.new(0,0,0); hkStroke.Thickness = 1.5
    local svField = Instance.new("Frame", popup); svField.Size = UDim2.new(1,0,0,80)
    svField.Position = UDim2.new(0,0,0,22); svField.BackgroundColor3 = Color3.new(1,0,0)
    svField.BorderSizePixel = 0; svField.ZIndex = 6; svField.Active = true
    Instance.new("UICorner", svField).CornerRadius = UDim.new(0,5)
    local svWhite = Instance.new("UIGradient", svField)
    svWhite.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)); svWhite.Transparency = NumberSequence.new(0,1)
    local svBlackFrame = Instance.new("Frame", svField); svBlackFrame.Size = UDim2.fromScale(1,1); svBlackFrame.BackgroundTransparency = 1; svBlackFrame.ZIndex = 7
    local svBlack = Instance.new("UIGradient", svBlackFrame)
    svBlack.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
    svBlack.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}); svBlack.Rotation = 90
    local svDot = Instance.new("Frame", svField); svDot.Size = UDim2.fromOffset(12,12)
    svDot.AnchorPoint = Vector2.new(0.5,0.5); svDot.BackgroundColor3 = Color3.new(1,1,1); svDot.BorderSizePixel = 0; svDot.ZIndex = 8
    Instance.new("UICorner", svDot).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", svDot).Color = Color3.new(0,0,0)
    local hexBox = Instance.new("TextBox", popup); hexBox.Size = UDim2.new(1,0,0,24)
    hexBox.Position = UDim2.new(0,0,0,110); hexBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
    hexBox.Text = "#FF3232"; hexBox.Font = Enum.Font.GothamBold; hexBox.TextSize = 14
    hexBox.TextColor3 = Color3.new(1,1,1); hexBox.BorderSizePixel = 0; hexBox.ZIndex = 6; hexBox.ClearTextOnFocus = false
    Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", hexBox).Color = Color3.fromRGB(50,50,50)
    popup.Size = UDim2.new(1,0,0,144)
    local h, s, v = Color3.toHSV(currentColor)
    local function hexFromColor(c)
        local r,g,b = math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5)
        return string.format("#%02X%02X%02X",r,g,b)
    end
    local function applyColor(c)
        currentColor = c; swatch.BackgroundColor3 = c
        svField.BackgroundColor3 = Color3.fromHSV(h,1,1)
        svDot.Position = UDim2.new(s,0,1-v,0)
        hueKnob.Position = UDim2.new(h,0,0.5,0); hueKnob.BackgroundColor3 = Color3.fromHSV(h,1,1)
        hexBox.Text = hexFromColor(c); pcall(callback, c)
    end
    applyColor(currentColor)
    local draggingHue, draggingSV = false, false
    hueBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true
            tween(hueKnob, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(10,24)}) end
    end)
    svField.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true
            tween(svDot, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(16,16)}) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            if draggingHue then tween(hueKnob, TweenInfo.new(0.15), {Size=UDim2.fromOffset(8,20)}) end
            if draggingSV then tween(svDot, TweenInfo.new(0.15), {Size=UDim2.fromOffset(12,12)}) end
            draggingHue = false; draggingSV = false
        end
    end)
    track(RunService.RenderStepped:Connect(function()
        if not popup.Visible then return end
        local mp = getMousePos()
        if draggingHue then
            h = math.clamp((mp.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1); applyColor(Color3.fromHSV(h,s,v))
        end
        if draggingSV then
            s = math.clamp((mp.X-svField.AbsolutePosition.X)/svField.AbsoluteSize.X,0,1)
            v = 1-math.clamp((mp.Y-svField.AbsolutePosition.Y)/svField.AbsoluteSize.Y,0,1)
            applyColor(Color3.fromHSV(h,s,v))
        end
    end))
    hexBox.FocusLost:Connect(function()
        local hex = hexBox.Text:gsub("[^%x]","")
        if #hex == 6 then
            local r,g,b = tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16)
            if r and g and b then local c = Color3.fromRGB(r,g,b); h,s,v = Color3.toHSV(c); applyColor(c) end
        end
    end)
    swatch.MouseButton1Click:Connect(function()
        _pickerOpen = not _pickerOpen
        if _pickerOpen then
            svField.BackgroundColor3 = Color3.fromHSV(h,1,1); popup.Visible = true
            tween(popup, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.new(1,0,0,144)})
            tween(swatch, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(38,28)})
            task.delay(0.19, function() if swatch and swatch.Parent then tween(swatch, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(32,22)}) end end)
            tween(popStroke, TweenInfo.new(0.15), {Transparency=0, Thickness=2})
            task.delay(0.18, function() if popStroke and popStroke.Parent then tween(popStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Transparency=0.5, Thickness=1.2}) end end)
        else
            tween(popup, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection["In"]), {Size=UDim2.new(1,0,0,0)})
            tween(swatch, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(32,22)})
            task.delay(0.23, function() if popup and popup.Parent then popup.Visible = false end end)
        end
    end)
    return {GetColor=function() return currentColor end, SetColor=function(c) h,s,v=Color3.toHSV(c); applyColor(c) end}
end

-- ─── ESP ─────────────────────────────────────────────────────────────────────
local EspGui = Instance.new("ScreenGui"); EspGui.Name = rname("esp"); EspGui.ResetOnSpawn = false
EspGui.IgnoreGuiInset = true; EspGui.DisplayOrder = 5; parentGui(EspGui)
local espEntries = {}

local function hideEntry(e)
    for _, v in e do if typeof(v)=="Instance" and v.Parent and v:IsA("GuiObject") then v.Visible = false end end
end
local function showEntry(e)
    for _, k in {"hpFill","barBg","nameF","nameL","distF","distL","hpTextF","hpTextL","box","tracer"} do
        if e[k] and e[k].Parent then e[k].Visible = true end
    end
end
local function makeEspLabel(size)
    local f = Instance.new("Frame"); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = 6
    local l = Instance.new("TextLabel",f); l.Size = UDim2.fromScale(1,1); l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold; l.TextSize = size; l.TextColor3 = Color3.fromRGB(255,255,255)
    l.TextStrokeTransparency = 0.2; l.ZIndex = 6; return f, l
end
local function createEntry(player)
    if espEntries[player] then return end; local e = {}
    local box = Instance.new("Frame",EspGui); box.BackgroundTransparency = 1; box.BorderSizePixel = 0; box.ZIndex = 5
    local boxStroke = Instance.new("UIStroke",box); boxStroke.Color = Color3.fromRGB(255,255,255); boxStroke.Thickness = 1.5; boxStroke.Transparency = 0.1
    e.box = box; e.boxStroke = boxStroke
    local barBg = Instance.new("Frame",EspGui); barBg.BackgroundColor3 = Color3.fromRGB(10,10,12)
    barBg.BackgroundTransparency = 0.25; barBg.BorderSizePixel = 0; barBg.ZIndex = 5
    Instance.new("UICorner",barBg).CornerRadius = UDim.new(1,0)
    local hpFill = Instance.new("Frame",barBg); hpFill.BackgroundColor3 = Color3.fromRGB(80,220,100); hpFill.BorderSizePixel = 0; hpFill.ZIndex = 6
    Instance.new("UICorner",hpFill).CornerRadius = UDim.new(1,0)
    e.barBg = barBg; e.hpFill = hpFill
    local hpTextF, hpTextL = makeEspLabel(12); e.hpTextF = hpTextF; e.hpTextL = hpTextL; hpTextF.Parent = EspGui
    local nameF, nameL = makeEspLabel(14); nameL.TextXAlignment = Enum.TextXAlignment.Center; e.nameF = nameF; e.nameL = nameL; nameF.Parent = EspGui
    local distF, distL = makeEspLabel(13); distL.TextXAlignment = Enum.TextXAlignment.Center; distL.TextColor3 = Color3.fromRGB(200,200,200); e.distF = distF; e.distL = distL; distF.Parent = EspGui
    local tracer = Instance.new("Frame",EspGui); tracer.AnchorPoint = Vector2.new(0,0.5)
    tracer.BackgroundColor3 = Color3.fromRGB(255,255,255); tracer.BackgroundTransparency = 0.3; tracer.BorderSizePixel = 0; tracer.ZIndex = 5
    e.tracer = tracer; barBg.Parent = EspGui; espEntries[player] = e
end
local function removeEntry(player)
    local e = espEntries[player]; if not e then return end
    for _, v in e do if typeof(v)=="Instance" then pcall(function() v:Destroy() end) end end
    espEntries[player] = nil
end

local espFrame = 0
track(RunService.RenderStepped:Connect(function()
    espFrame = espFrame + 1
    local menuOpen = false; pcall(function() menuOpen = Menu and Menu.Main and Menu.Main.Visible end)
    local vp = Camera.ViewportSize
    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then continue end
        local e = espEntries[player]
        local anyOn = Settings.ESP_Enabled and (Settings.Box or Settings.HealthBar or Settings.Names or Settings.Distance or Settings.Tracers)
        if _G.Whitelist and _G.Whitelist[player.UserId] then if e then hideEntry(e) end; continue end
        if not anyOn then if e then hideEntry(e) end; continue end
        if not e then createEntry(player) end; e = espEntries[player]; if not e then continue end
        local char = player.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not root or hum.Health<=0 or menuOpen then hideEntry(e); continue end
        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        if dist > Settings.MaxDistance then hideEntry(e); continue end
        local halfW, halfH = 1.2, 3.2
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local anyOnScreen = false
        for _, offset in {Vector3.new(halfW,halfH,0),Vector3.new(-halfW,halfH,0),Vector3.new(halfW,-halfH,0),Vector3.new(-halfW,-halfH,0)} do
            local sp, vis = Camera:WorldToViewportPoint(root.Position+offset)
            if sp.Z > 0 then anyOnScreen=true; minX=math.min(minX,sp.X); minY=math.min(minY,sp.Y); maxX=math.max(maxX,sp.X); maxY=math.max(maxY,sp.Y) end
        end
        if not anyOnScreen or minX==math.huge then hideEntry(e); continue end
        local w = math.max(maxX-minX, (maxY-minY)*0.18); local h = maxY-minY
        if w>vp.X*0.85 or h>vp.Y*0.85 then hideEntry(e); continue end
        e._x=minX; e._y=minY; e._w=w; e._h=h; e._dist=dist; e._hp=hum.Health/hum.MaxHealth
        e._fx=minX+w/2; e._fy=maxY; showEntry(e)
        e.box.Visible=Settings.Box
        if Settings.Box then e.box.Position=UDim2.fromOffset(minX,minY); e.box.Size=UDim2.fromOffset(w,h) end
        e.barBg.Visible=Settings.HealthBar; e.hpTextF.Visible=Settings.HealthBar
        if Settings.HealthBar then
            local bx=minX-6; e.barBg.Position=UDim2.fromOffset(bx,minY); e.barBg.Size=UDim2.fromOffset(3,h)
            e.hpFill.Size=UDim2.new(1,0,e._hp,0); e.hpFill.Position=UDim2.new(0,0,1-e._hp,0)
            e.hpFill.BackgroundColor3=e._hp>0.6 and Color3.fromRGB(120,255,120) or e._hp>0.3 and Color3.fromRGB(255,220,60) or Color3.fromRGB(255,80,80)
            e.hpTextF.Position=UDim2.fromOffset(bx-10,minY-1); e.hpTextF.Size=UDim2.fromOffset(20,13)
            e.hpTextL.Text=tostring(math.floor(e._hp*100))
        end
        e.distF.Visible=Settings.Distance
        if Settings.Distance then e.distF.Size=UDim2.fromOffset(70,17); e.distF.Position=UDim2.fromOffset(minX+w/2-35,maxY+4); e.distL.Text=string.format("%.0fm",dist) end
        e.nameF.Visible=Settings.Names
        if Settings.Names then
            local nm=player.DisplayName; e.nameF.Size=UDim2.fromOffset(#nm*8+10,18)
            e.nameF.Position=UDim2.fromOffset(minX+w/2-(#nm*8+10)/2,minY-20); e.nameL.Text=nm
        end
        local tracerOk = e._fx>0 and e._fx<vp.X and e._fy>0 and e._fy<vp.Y
        e.tracer.Visible=Settings.Tracers and tracerOk
        if Settings.Tracers and tracerOk then
            local ox,oy=vp.X/2,vp.Y; local dx,dy=e._fx-ox,e._fy-oy; local len=math.sqrt(dx*dx+dy*dy)
            if len>0 then
                e.tracer.AnchorPoint=Vector2.new(0.5,0.5); e.tracer.Position=UDim2.fromOffset((ox+e._fx)/2,(oy+e._fy)/2)
                e.tracer.Size=UDim2.fromOffset(len,1); e.tracer.Rotation=math.deg(math.atan2(dy,dx))
            end
        end
    end
    for player in espEntries do if not player or not player.Parent then removeEntry(player) end end
end))
Players.PlayerRemoving:Connect(removeEntry)

-- ─── Hitbox ──────────────────────────────────────────────────────────────────
local originalSizes, originalTransparencies, hitboxBoxes = {}, {}, {}
local function cacheOriginal(hrp)
    if not originalSizes[hrp] then originalSizes[hrp]=hrp.Size; originalTransparencies[hrp]=hrp.Transparency end
end
local function restoreAll()
    for hrp, sz in originalSizes do
        pcall(function() if hrp and hrp.Parent then hrp.Size=sz; hrp.Transparency=originalTransparencies[hrp] or 1 end end)
    end
    table.clear(originalSizes); table.clear(originalTransparencies)
end
local HitboxGui = Instance.new("ScreenGui"); HitboxGui.Name=rname("hbx"); HitboxGui.ResetOnSpawn=false
HitboxGui.IgnoreGuiInset=true; HitboxGui.DisplayOrder=6; parentGui(HitboxGui)
local function makeCornerBox(parent)
    local corners = {}
    for i=1,4 do
        local h=Instance.new("Frame",parent); h.BackgroundColor3=Color3.new(1,1,1); h.BorderSizePixel=0; h.ZIndex=7
        local v=Instance.new("Frame",parent); v.BackgroundColor3=Color3.new(1,1,1); v.BorderSizePixel=0; v.ZIndex=7
        corners[i]={h=h,v=v}
    end
    return corners
end
local function updateCornerBox(corners,x,y,w,h)
    local thick,len=2,8
    local defs={{ax=0,ay=0,hw=len,hh=thick,vw=thick,vh=len},{ax=1,ay=0,hw=len,hh=thick,vw=thick,vh=len},{ax=0,ay=1,hw=len,hh=thick,vw=thick,vh=len},{ax=1,ay=1,hw=len,hh=thick,vw=thick,vh=len}}
    for i=1,4 do
        local c=corners[i]; if not c or type(c)~="table" or not c.h then continue end
        local d=defs[i]; c.h.Size=UDim2.fromOffset(d.hw,d.hh); c.v.Size=UDim2.fromOffset(d.vw,d.vh)
        local px=d.ax==0 and x or x+w; local py=d.ay==0 and y or y+h
        c.h.Position=UDim2.fromOffset(px,py); c.v.Position=UDim2.fromOffset(px,py)
        c.h.AnchorPoint=Vector2.new(d.ax,d.ay); c.v.AnchorPoint=Vector2.new(d.ax,d.ay)
    end
end
local function destroyCorners(corners)
    for i=1,4 do local c=corners[i]; if c and type(c)=="table" and c.h then pcall(function() c.h:Destroy() end); pcall(function() c.v:Destroy() end) end end
end
local hitboxWasEnabled = false
track(RunService.Heartbeat:Connect(function()
    if Settings.Unloaded then return end
    local enabled = Settings.HitboxEnabled
    if hitboxWasEnabled and not enabled then
        restoreAll()
        for player, corners in hitboxBoxes do destroyCorners(corners); if corners._holder then pcall(function() corners._holder:Destroy() end) end end
        table.clear(hitboxBoxes)
    end
    hitboxWasEnabled = enabled
    if not enabled then return end
    local vp = Camera.ViewportSize
    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then
            if hitboxBoxes[player] then destroyCorners(hitboxBoxes[player]); if hitboxBoxes[player]._holder then pcall(function() hitboxBoxes[player]._holder:Destroy() end) end; hitboxBoxes[player]=nil end
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        cacheOriginal(hrp)
        pcall(function() hrp.Size=Vector3.one*Settings.HitboxSize; hrp.Transparency=Settings.HitboxTransparency end)
        if not hitboxBoxes[player] then
            local holder=Instance.new("Frame",HitboxGui); holder.BackgroundTransparency=1; holder.Size=UDim2.fromScale(1,1); holder.ZIndex=6
            hitboxBoxes[player]=makeCornerBox(holder); hitboxBoxes[player]._holder=holder
        end
        local corners=hitboxBoxes[player]; local hum=char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then for i=1,4 do local c=corners[i]; if c and type(c)=="table" and c.h then c.h.Visible=false; c.v.Visible=false end end; continue end
        local sz=hrp.Size; local halfW,halfH=sz.X/2,sz.Y/2
        local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge; local onScreen=false
        for _,off in {Vector3.new(halfW,halfH,0),Vector3.new(-halfW,halfH,0),Vector3.new(halfW,-halfH,0),Vector3.new(-halfW,-halfH,0)} do
            local sp=Camera:WorldToViewportPoint(hrp.Position+off)
            if sp.Z>0 then onScreen=true; minX=math.min(minX,sp.X); minY=math.min(minY,sp.Y); maxX=math.max(maxX,sp.X); maxY=math.max(maxY,sp.Y) end
        end
        local show=onScreen and minX~=math.huge and (maxX-minX)<vp.X*0.9
        for i=1,4 do local c=corners[i]; if not c or type(c)~="table" or not c.h then continue end; c.h.Visible=show; c.v.Visible=show end
        if show then updateCornerBox(corners,minX,minY,maxX-minX,maxY-minY) end
    end
    for player, corners in hitboxBoxes do
        if not player or not player.Parent then destroyCorners(corners); if corners._holder then pcall(function() corners._holder:Destroy() end) end; hitboxBoxes[player]=nil end
    end
end))

-- ─── TriggerBot settings (объявляем до UI) ───────────────────────────────────
local TB = {
    Delay             = 0.0001,
    RMBOnly           = false,
    CheckDead         = false,
    CheckWall         = true,
    Pressing          = false,
    ShootOffset       = 0.0,    -- упреждение в сек (0 = авто по пингу)
    FlickCompensation = 0.012,  -- доп. радиус хитбокса при флике (studs)
}

-- ─── Build Menu ──────────────────────────────────────────────────────────────
local Menu = Library.new("elysium")
local tCombat   = Menu:CreateTab("Combat")
local tVisuals  = Menu:CreateTab("Visuals")
local tSettings = Menu:CreateTab("Settings")
local tWhitelist= Menu:CreateTab("PlayerList")
local tConfigs  = Menu:CreateTab("Configs")

-- ─── Toast ───────────────────────────────────────────────────────────────────
local toastGui = Instance.new("ScreenGui"); toastGui.Name=rname("toast")
toastGui.ResetOnSpawn=false; toastGui.IgnoreGuiInset=true; toastGui.DisplayOrder=99; parentGui(toastGui)
local toastStack = {}
local function showToast(msg, color)
    color = color or Config.Accent
    local toast = Instance.new("Frame",toastGui)
    toast.Size=UDim2.fromOffset(10,48); toast.AutomaticSize=Enum.AutomaticSize.X
    toast.Position=UDim2.new(0.5,0,0,-70); toast.AnchorPoint=Vector2.new(0.5,0)
    toast.BackgroundColor3=Color3.fromRGB(12,12,12); toast.BorderSizePixel=0
    toast.BackgroundTransparency=1; toast.ZIndex=99; toast.ClipsDescendants=false
    Instance.new("UICorner",toast).CornerRadius=UDim.new(0,14)
    local ts=Instance.new("UIStroke",toast); ts.Color=color; ts.Thickness=1.4; ts.Transparency=0.2
    local pad=Instance.new("UIPadding",toast); pad.PaddingLeft=UDim.new(0,16); pad.PaddingRight=UDim.new(0,16)
    local bar=Instance.new("Frame",toast); bar.Size=UDim2.fromOffset(3,30); bar.Position=UDim2.new(0,-1,0.5,-15)
    bar.BackgroundColor3=color; bar.BorderSizePixel=0; bar.ZIndex=101; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",toast); lbl.Size=UDim2.new(0,0,1,0); lbl.AutomaticSize=Enum.AutomaticSize.X
    lbl.Position=UDim2.fromOffset(16,0); lbl.Text=msg; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=14
    lbl.TextColor3=Color3.fromRGB(225,225,240); lbl.BackgroundTransparency=1; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=101
    for _, t2 in toastStack do
        if t2 and t2.Parent then tween(t2,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,0,t2.Position.Y.Scale,t2.Position.Y.Offset+56)}) end
    end
    toastStack[#toastStack+1]=toast
    tween(toast,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.06,Position=UDim2.new(0.5,0,0,18)})
    tween(ts,TweenInfo.new(0.3),{Transparency=0.2})
    local prog=Instance.new("Frame",toast); prog.Size=UDim2.new(1,-4,0,2); prog.Position=UDim2.new(0,2,1,-3)
    prog.BackgroundColor3=color; prog.BackgroundTransparency=0.4; prog.BorderSizePixel=0; prog.ZIndex=102
    Instance.new("UICorner",prog).CornerRadius=UDim.new(1,0)
    task.delay(0.45,function() if prog and prog.Parent then tween(prog,TweenInfo.new(2.0,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,2)}) end end)
    task.delay(2.6,function()
        if not toast or not toast.Parent then return end
        tween(toast,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection["In"]),{BackgroundTransparency=1,Position=UDim2.new(0.5,0,0,-60)})
        tween(ts,TweenInfo.new(0.2),{Transparency=1})
        task.delay(0.31,function()
            pcall(function() toast:Destroy() end)
            for i,t2 in toastStack do if t2==toast then table.remove(toastStack,i); break end end
        end)
    end)
end

-- ─── PlayerList ──────────────────────────────────────────────────────────────
local wlSec = Menu:CreateSection(tWhitelist, "Player List")
local wlRows = {}
local spectateTarget, spectateConn = nil, nil
local spectateGui = Instance.new("ScreenGui"); spectateGui.Name=rname("spec"); spectateGui.ResetOnSpawn=false
spectateGui.IgnoreGuiInset=true; spectateGui.DisplayOrder=15; parentGui(spectateGui)
local specLabel = Instance.new("TextLabel",spectateGui)
specLabel.Size=UDim2.fromOffset(300,28); specLabel.Position=UDim2.new(0.5,-150,0,12)
specLabel.BackgroundColor3=Color3.fromRGB(10,10,10); specLabel.BackgroundTransparency=0.3
specLabel.Text=""; specLabel.Font=Enum.Font.GothamBold; specLabel.TextSize=15
specLabel.TextColor3=Config.Accent; specLabel.BorderSizePixel=0; specLabel.Visible=false; specLabel.ZIndex=15
Instance.new("UICorner",specLabel).CornerRadius=UDim.new(0,8)
local specStroke=Instance.new("UIStroke",specLabel); specStroke.Color=Config.Accent; specStroke.Thickness=1; specStroke.Transparency=0.5

local function stopSpectate()
    if spectateConn then spectateConn:Disconnect(); spectateConn=nil end
    spectateTarget=nil; specLabel.Visible=false
    pcall(function() Camera.CameraSubject=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); Camera.CameraType=Enum.CameraType.Custom end)
    rebuildPlayerListUI()
end
local function startSpectate(player)
    if spectateTarget then stopSpectate() end
    spectateTarget=player; specLabel.Visible=true
    specLabel.Text="[*]  Spectating: "..player.DisplayName.." (@"..player.Name..")"
    spectateConn=RunService.RenderStepped:Connect(function()
        if not spectateTarget or not spectateTarget.Parent then stopSpectate(); return end
        local char=spectateTarget.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return end
        pcall(function() Camera.CameraSubject=hum; Camera.CameraType=Enum.CameraType.Custom end)
    end)
    rebuildPlayerListUI()
end

function rebuildPlayerListUI()
    for _, r in wlRows do if r and r.Parent then r:Destroy() end end
    table.clear(wlRows)
    for _, ply in Players:GetPlayers() do
        if ply == LocalPlayer then continue end
        local isWL=_G.Whitelist[ply.UserId]==true; local isSpec=spectateTarget==ply
        local row=Instance.new("Frame",wlSec.Card); row.Size=UDim2.new(1,0,0,36); row.BackgroundTransparency=1; row.BorderSizePixel=0; row.ZIndex=3
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local dot=Instance.new("Frame",row); dot.Size=UDim2.fromOffset(8,8); dot.Position=UDim2.new(0,0,0.5,-4)
        dot.BackgroundColor3=isWL and Color3.fromRGB(80,220,100) or Color3.fromRGB(220,80,80); dot.BorderSizePixel=0; dot.ZIndex=4
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-196,1,0); lbl.Position=UDim2.fromOffset(16,0)
        lbl.Text=ply.DisplayName.." (@"..ply.Name..")"; lbl.Font=Enum.Font.Gotham; lbl.TextSize=15
        lbl.TextColor3=isWL and Color3.fromRGB(80,220,100) or Config.White; lbl.BackgroundTransparency=1
        lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextTruncate=Enum.TextTruncate.AtEnd; lbl.ZIndex=4
        local specBtn=Instance.new("TextButton",row); specBtn.Size=UDim2.fromOffset(80,26); specBtn.Position=UDim2.new(1,-186,0.5,-13)
        specBtn.Text=isSpec and "Stop" or "Spectate"; specBtn.Font=Enum.Font.GothamBold; specBtn.TextSize=13
        specBtn.BackgroundColor3=isSpec and Color3.fromRGB(200,80,80) or Color3.fromRGB(60,120,200)
        specBtn.TextColor3=Config.White; specBtn.AutoButtonColor=false; specBtn.ZIndex=4
        Instance.new("UICorner",specBtn).CornerRadius=UDim.new(0,7)
        specBtn.MouseButton1Click:Connect(function() if isSpec then stopSpectate() else startSpectate(ply) end end)
        specBtn.MouseEnter:Connect(function() tween(specBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.3}) end)
        specBtn.MouseLeave:Connect(function() tween(specBtn,TweenInfo.new(0.15),{BackgroundTransparency=0}) end)
        local wlBtn=Instance.new("TextButton",row); wlBtn.Size=UDim2.fromOffset(90,26); wlBtn.Position=UDim2.new(1,-90,0.5,-13)
        wlBtn.Text=isWL and "Remove" or "Add WL"; wlBtn.Font=Enum.Font.GothamBold; wlBtn.TextSize=13
        wlBtn.BackgroundColor3=isWL and Color3.fromRGB(60,160,80) or Config.Accent
        wlBtn.TextColor3=Config.White; wlBtn.AutoButtonColor=false; wlBtn.ZIndex=4
        Instance.new("UICorner",wlBtn).CornerRadius=UDim.new(0,7)
        local uid=ply.UserId
        wlBtn.MouseButton1Click:Connect(function() if _G.Whitelist[uid] then _G.Whitelist[uid]=nil else _G.Whitelist[uid]=true end; rebuildPlayerListUI() end)
        wlBtn.MouseEnter:Connect(function() tween(wlBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.3}) end)
        wlBtn.MouseLeave:Connect(function() tween(wlBtn,TweenInfo.new(0.15),{BackgroundTransparency=0}) end)
        wlRows[#wlRows+1]=row
    end
    if #wlRows==0 then
        local empty=Instance.new("TextLabel",wlSec.Card); empty.Size=UDim2.new(1,0,0,28); empty.BackgroundTransparency=1
        empty.Text="No players in session"; empty.Font=Enum.Font.Gotham; empty.TextSize=14
        empty.TextColor3=Color3.fromRGB(100,100,110); empty.TextXAlignment=Enum.TextXAlignment.Left; empty.ZIndex=3
        wlRows[#wlRows+1]=empty
    end
end

wlSec:AddButton("Refresh Player List", function() rebuildPlayerListUI() end)
local wlBulkRow=Instance.new("Frame",wlSec.Card); wlBulkRow.Size=UDim2.new(1,0,0,32); wlBulkRow.BackgroundTransparency=1; wlBulkRow.ZIndex=3
local wlBulkList=Instance.new("UIListLayout",wlBulkRow); wlBulkList.FillDirection=Enum.FillDirection.Horizontal; wlBulkList.Padding=UDim.new(0,8)
local function makeBulkBtn(parent,text,bg,cb)
    local b=Instance.new("TextButton",parent); b.Size=UDim2.fromOffset(140,32); b.BackgroundColor3=bg
    b.Text=text; b.Font=Enum.Font.GothamBold; b.TextSize=13; b.TextColor3=Color3.fromRGB(255,255,255); b.AutoButtonColor=false; b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.MouseEnter:Connect(function() tween(b,TweenInfo.new(0.12),{BackgroundTransparency=0.25}) end)
    b.MouseLeave:Connect(function() tween(b,TweenInfo.new(0.15),{BackgroundTransparency=0}) end)
    b.MouseButton1Click:Connect(function() pcall(cb); rebuildPlayerListUI() end); return b
end
makeBulkBtn(wlBulkRow,"WL All",Color3.fromRGB(40,130,70),function()
    for _,ply in Players:GetPlayers() do if ply~=LocalPlayer then _G.Whitelist[ply.UserId]=true end end
    showToast("All players whitelisted",Color3.fromRGB(80,220,130))
end)
makeBulkBtn(wlBulkRow,"Remove All WL",Color3.fromRGB(140,40,40),function()
    table.clear(_G.Whitelist); showToast("Whitelist cleared",Color3.fromRGB(220,80,80))
end)
rebuildPlayerListUI()
Players.PlayerAdded:Connect(function() task.wait(1); rebuildPlayerListUI() end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    if spectateTarget and not spectateTarget.Parent then stopSpectate() end
    rebuildPlayerListUI()
end)

-- ─── Combat controls ─────────────────────────────────────────────────────────
local uiControls = {}
local trigSec = Menu:CreateSection(tCombat, "Trigger Bot")
local trigEntry = trigSec:AddToggle("Trigger",false,function(v) Settings.TriggerBot=v end); trigEntry.hudOnlyWhenActive=true
uiControls.TriggerBot = trigEntry
uiControls.TriggerDelay = trigSec:AddSlider("Shot Reaction Delay (ms)",0,1000,0,function(v) Settings.TriggerDelay=v/1000 end)
uiControls.TriggerDist  = trigSec:AddSlider("Activation Distance (Studs)",50,1500,500,function(v) Settings.TriggerDist=v end)
uiControls.KnifeCheck   = trigSec:AddToggle("Knife Check (no fire with knife)",true,function(v) Settings.KnifeCheck=v end)
trigSec:AddToggle("Ignore Crew/Teammates",false,function(v) _G.CrewCheck=v end)
trigSec:AddToggle("Ignore Global Friends",false,function(v) _G.FriendCheck=v end)
uiControls.RMBOnly   = trigSec:AddToggle("RMB Only (hold right mouse)",false,function(v) TB.RMBOnly=v; getgenv().Triggerbot.RMBOnly=v; Settings.RMBOnly=v end)
uiControls.WallCheck = trigSec:AddToggle("Check Wall (line of sight)",false,function(v) TB.CheckWall=v; getgenv().Triggerbot.WallCheck=v; Settings.WallCheck=v end)
trigSec:AddToggle("Skip Dead Targets",false,function(v) TB.CheckDead=v end)

local hbSec = Menu:CreateSection(tCombat, "Hitboxes")
uiControls.HitboxEnabled     = hbSec:AddToggle("Enable Hitboxes",false,function(v) Settings.HitboxEnabled=v end)
uiControls.HitboxSize        = hbSec:AddSlider("Hitbox Size",1,30,8,function(v) Settings.HitboxSize=v end)
uiControls.HitboxTransparency= hbSec:AddSlider("Box Transparency",0,100,50,function(v) Settings.HitboxTransparency=v/100 end)

-- FakeLag
local flSec = Menu:CreateSection(tCombat, "Fake Lag")
Settings.FakeLag = false
local fakeLagThread, fakeLagWaitTime, fakeLagDelayTime = nil, 0.05, 0.4
Settings.FakeLagDelay    = 400   -- ms, для сохранения в конфиг
Settings.FakeLagInterval = 50    -- ms, для сохранения в конфиг
local function stopFakeLag()
    if fakeLagThread then task.cancel(fakeLagThread); fakeLagThread=nil end
    pcall(function() local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Anchored=false end end)
end
local function startFakeLag()
    stopFakeLag()
    fakeLagThread = task.spawn(function()
        while Settings.FakeLag and not Settings.Unloaded do
            task.wait(fakeLagWaitTime); if not Settings.FakeLag then break end
            local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored=true; task.wait(fakeLagDelayTime); hrp.Anchored=false end
        end
    end)
end
uiControls.FakeLag      = flSec:AddToggle("Enable Fake Lag",false,function(v) Settings.FakeLag=v; if v then startFakeLag() else stopFakeLag() end end)
uiControls.FakeLagDelay = flSec:AddSlider("Lag Duration (ms)",100,3000,400,function(v) fakeLagDelayTime=v/1000; Settings.FakeLagDelay=v end)
uiControls.FakeLagInterval=flSec:AddSlider("Lag Interval (ms)",50,2000,50,function(v) fakeLagWaitTime=v/1000; Settings.FakeLagInterval=v end)

-- ESP
local espSec = Menu:CreateSection(tVisuals, "ESP Rendering")
uiControls.ESP_Enabled = espSec:AddToggle("Master ESP Switch",false,function(v) Settings.ESP_Enabled=v end)
uiControls.Box         = espSec:AddToggle("2D Square Boxes",false,function(v) Settings.Box=v end)
uiControls.HealthBar   = espSec:AddToggle("Vertical Health Bar",false,function(v) Settings.HealthBar=v end)
uiControls.Names       = espSec:AddToggle("Player Names",false,function(v) Settings.Names=v end)
uiControls.Distance    = espSec:AddToggle("Distance Label",false,function(v) Settings.Distance=v end)
uiControls.Tracers     = espSec:AddToggle("Tracers",false,function(v) Settings.Tracers=v end)
uiControls.MaxDistance = espSec:AddSlider("Max Render Distance",100,5000,2500,function(v) Settings.MaxDistance=v end)

-- ─── Mod Detector ────────────────────────────────────────────────────────────
local MOD_USERNAMES = {
    ['boomffa_mod']=true, ['boomffaadmin']=true, ['boomffa_admin']=true,
    ['boomffa_staff']=true, ['boom_moderator']=true, ['boomgamemod']=true,
}
local MOD_SYMBOLS = {'✅','☑️','👑','⭐','🛡️','✨','🌟','⚡','🔱','💎','🏆','🎖️'}
local MOD_GROUP_IDS = {925309458, 33991282, 7431102}
local MOD_MIN_RANK  = 50

local modDetectorEnabled = false
local modVisualEnabled   = false
local modESPEntries      = {}   -- [player] = {label, box, tracer}
local modNotified        = {}

local function modHasSymbol(name)
    for _, s in ipairs(MOD_SYMBOLS) do if string.find(name, s, 1, true) then return true end end
    return false
end

local function isBoomMod(player)
    local nl = player.Name:lower(); local dl = player.DisplayName:lower()
    if MOD_USERNAMES[nl] or MOD_USERNAMES[dl] then return true, "Known Mod" end
    if modHasSymbol(player.Name) or modHasSymbol(player.DisplayName) then return true, "Mod Symbol" end
    for _, gid in ipairs(MOD_GROUP_IDS) do
        local ok, inGroup = pcall(function() return player:IsInGroup(gid) end)
        if ok and inGroup then
            local rok, rank = pcall(function() return player:GetRankInGroup(gid) end)
            local nok, role = pcall(function() return player:GetRoleInGroup(gid) end)
            if rok and rank >= MOD_MIN_RANK then
                return true, (nok and role or "Staff") .. " [" .. tostring(rank) .. "]"
            end
        end
    end
    return false, nil
end

local function clearModESP(player)
    local e = modESPEntries[player]; if not e then return end
    pcall(function() if e.label then e.label.Visible=false; e.label:Remove() end end)
    pcall(function() if e.box   then e.box.Visible=false;   e.box:Remove()   end end)
    pcall(function() if e.tracer then e.tracer.Visible=false; e.tracer:Remove() end end)
    modESPEntries[player] = nil
end

local function createModESP(player, role)
    clearModESP(player)
    local label  = Drawing.new("Text")
    label.Center = true; label.Outline = true; label.Size = 16
    label.Color  = Color3.fromRGB(255, 80, 80); label.Font = 3; label.Visible = false

    local box    = Drawing.new("Square")
    box.Thickness = 2; box.Color = Color3.fromRGB(255, 50, 50)
    box.Filled = false; box.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1.5; tracer.Color = Color3.fromRGB(255, 0, 0); tracer.Visible = false

    modESPEntries[player] = {label=label, box=box, tracer=tracer, role=role}
end

local function detectMods()
    if not modDetectorEnabled then return end
    for _, ply in ipairs(Players:GetPlayers()) do
        if ply == LocalPlayer then continue end
        if modESPEntries[ply] then continue end
        local isMod, role = isBoomMod(ply)
        if isMod and not modNotified[ply.UserId] then
            createModESP(ply, role or "Staff")
            modNotified[ply.UserId] = true
        end
    end
end

-- Обновление Drawing ESP для модов каждый кадр
track(RunService.RenderStepped:Connect(function()
    if not modVisualEnabled then
        for _, e in modESPEntries do
            if e.label  then e.label.Visible  = false end
            if e.box    then e.box.Visible    = false end
            if e.tracer then e.tracer.Visible = false end
        end
        return
    end
    local vp = Camera.ViewportSize
    for player, e in modESPEntries do
        if not player or not player.Parent then clearModESP(player); continue end
        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")
        local root = char and (char:FindFirstChild("HumanoidRootPart") or head)
        if not root or not hum or hum.Health <= 0 then
            if e.label  then e.label.Visible  = false end
            if e.box    then e.box.Visible    = false end
            if e.tracer then e.tracer.Visible = false end
            continue
        end
        local headSP, headVis = Camera:WorldToViewportPoint(head and head.Position or root.Position)
        local rootSP, rootVis = Camera:WorldToViewportPoint(root.Position)
        if not headVis then
            if e.label  then e.label.Visible  = false end
            if e.box    then e.box.Visible    = false end
            if e.tracer then e.tracer.Visible = false end
            continue
        end
        -- Label
        e.label.Position = Vector2.new(headSP.X, headSP.Y - 32)
        e.label.Text     = "🚨 MOD: " .. player.Name .. " [" .. (e.role or "?") .. "]"
        e.label.Visible  = true
        -- Box
        local feetSP = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
        local bh = math.max(math.abs(headSP.Y - feetSP.Y), 10)
        local bw = bh * 0.5
        e.box.Size     = Vector2.new(bw, bh)
        e.box.Position = Vector2.new(headSP.X - bw/2, headSP.Y - bh * 0.1)
        e.box.Visible  = true
        -- Tracer
        if rootVis then
            e.tracer.From    = Vector2.new(vp.X/2, vp.Y)
            e.tracer.To      = Vector2.new(rootSP.X, rootSP.Y)
            e.tracer.Visible = true
        else
            e.tracer.Visible = false
        end
    end
end))

-- Периодическая проверка модов
track(RunService.Heartbeat:Connect(function()
    if not modDetectorEnabled then return end
end))

local _modCheckT = 0
track(RunService.Heartbeat:Connect(function(dt)
    _modCheckT = _modCheckT + dt
    if _modCheckT < 3 then return end
    _modCheckT = 0
    if modDetectorEnabled then detectMods() end
end))

Players.PlayerAdded:Connect(function(ply)
    task.wait(2)
    if modDetectorEnabled then
        local isMod, role = isBoomMod(ply)
        if isMod and not modNotified[ply.UserId] then
            createModESP(ply, role or "Staff")
            modNotified[ply.UserId] = true
        end
    end
end)
Players.PlayerRemoving:Connect(function(ply) clearModESP(ply) end)

-- UI секция мод детектора в Visuals
local modSec = Menu:CreateSection(tVisuals, "Mod Detector")
modSec:AddToggle("Enable Mod Detector", false, function(v)
    modDetectorEnabled = v
    if v then
        task.spawn(detectMods)
    else
        -- При выключении детектора — скрываем весь мод ESP
        modVisualEnabled = false
        for _, e in modESPEntries do
            if e.label  then e.label.Visible  = false end
            if e.box    then e.box.Visible    = false end
            if e.tracer then e.tracer.Visible = false end
        end
    end
end)
modSec:AddToggle("Show Mod ESP (box + tracer)", false, function(v)
    -- Работает только если детектор включён
    modVisualEnabled = v and modDetectorEnabled
end)
modSec:AddButton("Scan Now", function()
    if not modDetectorEnabled then
        showToast("Enable Mod Detector first", Color3.fromRGB(220,80,80))
        return
    end
    modNotified = {}
    for ply in modESPEntries do clearModESP(ply) end
    detectMods()
    local count = 0
    for _ in modESPEntries do count = count + 1 end
    showToast("Scan complete — " .. count .. " mod(s) found", count > 0 and Color3.fromRGB(255,80,80) or Color3.fromRGB(80,220,130))
end)

-- ─── Keybind HUD ─────────────────────────────────────────────────────────────
local BindHud = Instance.new("ScreenGui"); BindHud.Name=rname("hud"); BindHud.ResetOnSpawn=false
BindHud.IgnoreGuiInset=true; BindHud.DisplayOrder=20; parentGui(BindHud)
local hudEnabled = false
local hudFrame = Instance.new("Frame",BindHud)
hudFrame.Size=UDim2.fromOffset(240,0); hudFrame.AutomaticSize=Enum.AutomaticSize.Y
hudFrame.Position=UDim2.fromOffset(20,200); hudFrame.BackgroundColor3=Color3.fromRGB(12,12,12)
hudFrame.BackgroundTransparency=0.2; hudFrame.BorderSizePixel=0; hudFrame.ZIndex=10; hudFrame.Visible=false
Instance.new("UICorner",hudFrame).CornerRadius=UDim.new(0,12)
local hudStroke=Instance.new("UIStroke",hudFrame); hudStroke.Color=Config.Accent; hudStroke.Thickness=1; hudStroke.Transparency=0.45; trackAccent(hudStroke)
local hudPad=Instance.new("UIPadding",hudFrame)
hudPad.PaddingLeft=UDim.new(0,12); hudPad.PaddingRight=UDim.new(0,12); hudPad.PaddingTop=UDim.new(0,10); hudPad.PaddingBottom=UDim.new(0,10)
local hudList=Instance.new("UIListLayout",hudFrame); hudList.Padding=UDim.new(0,4); hudList.SortOrder=Enum.SortOrder.LayoutOrder
local hudTitle=Instance.new("TextLabel",hudFrame); hudTitle.LayoutOrder=0; hudTitle.Size=UDim2.new(1,0,0,22); hudTitle.Text="[*]  KEYBINDS"
hudTitle.Font=Enum.Font.GothamBlack; hudTitle.TextSize=22; hudTitle.TextColor3=Config.Accent; hudTitle.BackgroundTransparency=1
hudTitle.TextXAlignment=Enum.TextXAlignment.Left; hudTitle.ZIndex=10; trackAccent(hudTitle)
local hudDivider=Instance.new("Frame",hudFrame); hudDivider.LayoutOrder=1; hudDivider.Size=UDim2.new(1,0,0,1)
hudDivider.BackgroundColor3=Config.Accent; hudDivider.BackgroundTransparency=0.7; hudDivider.BorderSizePixel=0; hudDivider.ZIndex=10; trackAccent(hudDivider)
local hudNoBinds=Instance.new("TextLabel",hudFrame); hudNoBinds.LayoutOrder=2; hudNoBinds.Size=UDim2.new(1,0,0,18); hudNoBinds.Text="No binds set"
hudNoBinds.Font=Enum.Font.Gotham; hudNoBinds.TextSize=20; hudNoBinds.TextColor3=Color3.fromRGB(100,100,110); hudNoBinds.BackgroundTransparency=1
hudNoBinds.TextXAlignment=Enum.TextXAlignment.Left; hudNoBinds.ZIndex=10
local hudRowOrder = 100
local function rebuildHud()
    for _, r in hudRowMap do if r.frame and r.frame.Parent then r.frame:Destroy() end end
    table.clear(hudRowMap); local hasAny=false; hudRowOrder=100
    for _, entry in featureBinds do
        if not entry.key then continue end
        if entry.hudOnlyWhenActive and not entry.state then continue end
        hasAny=true
        local row=Instance.new("Frame",hudFrame); row.LayoutOrder=hudRowOrder; hudRowOrder=hudRowOrder+1
        row.Size=UDim2.new(1,0,0,36); row.BackgroundTransparency=1; row.ZIndex=10
        local nameLbl=Instance.new("TextLabel",row); nameLbl.Size=UDim2.new(1,0,0,18); nameLbl.Position=UDim2.fromOffset(0,0)
        nameLbl.Text=bindNames[entry] or "?"; nameLbl.Font=Enum.Font.Gotham; nameLbl.TextSize=20
        nameLbl.TextColor3=Color3.fromRGB(210,210,225); nameLbl.BackgroundTransparency=1; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
        nameLbl.TextTruncate=Enum.TextTruncate.AtEnd; nameLbl.ZIndex=10
        local keyStr=tostring(entry.key):gsub("Enum%.KeyCode%.","")
        local keyLbl=Instance.new("TextLabel",row); keyLbl.Size=UDim2.new(1,0,0,16); keyLbl.Position=UDim2.fromOffset(0,19)
        keyLbl.Text="["..keyStr.."]"; keyLbl.Font=Enum.Font.GothamBold; keyLbl.TextSize=18
        keyLbl.TextColor3=Config.Accent; keyLbl.TextXAlignment=Enum.TextXAlignment.Left; keyLbl.ZIndex=10; trackAccent(keyLbl)
        hudRowMap[entry]={frame=row,keyLbl=keyLbl}
    end
    hudNoBinds.Visible=not hasAny
end
local hudDragging,hudDStart,hudFStart=false,nil,nil
hudFrame.InputBegan:Connect(function(i)
    if not Menu.Main.Visible then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 then hudDragging=true; hudDStart=i.Position; hudFStart=hudFrame.Position end
end)
UserInputService.InputChanged:Connect(function(i)
    if hudDragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-hudDStart; hudFrame.Position=UDim2.new(hudFStart.X.Scale,hudFStart.X.Offset+d.X,hudFStart.Y.Scale,hudFStart.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hudDragging=false end end)

-- ─── Settings tab ────────────────────────────────────────────────────────────
local settSec = Menu:CreateSection(tSettings, "Interface")
settSec:AddToggle("Show Keybind HUD",false,function(v)
    hudEnabled=v
    if v then
        hudFrame.Visible=true; hudFrame.BackgroundTransparency=1
        tween(hudFrame,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.2})
        rebuildHud()
    else
        tween(hudFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundTransparency=1})
        task.delay(0.21,function() if hudFrame and hudFrame.Parent then hudFrame.Visible=false end end)
    end
end)

local themeNames = {"Orange","Purple","Cyan","Red","Rose","Emerald","Gold","Ice","Sakura","Void"}
local themeIdx = 1; local themeDropOpen = false; local themeDropFrame = nil
local function closeThemeDrop()
    if themeDropFrame and themeDropFrame.Parent then
        tween(themeDropFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection["In"]),{Size=UDim2.fromOffset(200,0),BackgroundTransparency=1})
        task.delay(0.21,function() if themeDropFrame and themeDropFrame.Parent then themeDropFrame:Destroy(); themeDropFrame=nil end end)
        themeDropOpen=false
    end
end
local themeAccentDots = {
    Orange=Color3.fromRGB(255,157,19), Purple=Color3.fromRGB(170,100,255), Cyan=Color3.fromRGB(60,210,230),
    Red=Color3.fromRGB(235,75,75), Rose=Color3.fromRGB(255,100,160), Emerald=Color3.fromRGB(50,220,130),
    Gold=Color3.fromRGB(255,210,50), Ice=Color3.fromRGB(140,200,255), Sakura=Color3.fromRGB(255,160,200), Void=Color3.fromRGB(120,80,255),
}
local function applyThemeAndRecolor(n)
    applyTheme(n); recolorAll()
    if Menu.Main and Menu.Main.Parent then Menu.Main.BackgroundColor3=Color3.fromRGB(12,12,12) end
    if Menu.Sidebar and Menu.Sidebar.Parent then Menu.Sidebar.BackgroundColor3=Color3.fromRGB(10,10,10) end
    for _, tab in Menu.Tabs do
        for _, card in tab:GetDescendants() do if card:IsA("Frame") and card.Name~="Sidebar" then pcall(function() card.BackgroundColor3=Color3.fromRGB(18,18,18) end) end end
    end
end

local themeBtn; themeBtn = settSec:AddButton("Theme  Orange", function()
    if themeDropFrame and themeDropFrame.Parent then closeThemeDrop(); return end
    themeDropOpen=true
    local dropW,itemH=200,34
    local dropF=Instance.new("Frame",Menu.SG)
    dropF.Size=UDim2.fromOffset(dropW,0)
    dropF.Position=UDim2.fromOffset(themeBtn.AbsolutePosition.X,themeBtn.AbsolutePosition.Y+themeBtn.AbsoluteSize.Y+4)
    dropF.BackgroundColor3=Color3.fromRGB(18,18,18); dropF.BorderSizePixel=0; dropF.ZIndex=50; dropF.ClipsDescendants=true
    Instance.new("UICorner",dropF).CornerRadius=UDim.new(0,10)
    local dStroke=Instance.new("UIStroke",dropF); dStroke.Color=Config.Accent; dStroke.Thickness=1.2; dStroke.Transparency=0.4
    local dList=Instance.new("UIListLayout",dropF); dList.Padding=UDim.new(0,2)
    local dPad=Instance.new("UIPadding",dropF); dPad.PaddingTop=UDim.new(0,4); dPad.PaddingBottom=UDim.new(0,4); dPad.PaddingLeft=UDim.new(0,4); dPad.PaddingRight=UDim.new(0,4)
    themeDropFrame=dropF
    for idx, name in themeNames do
        local row=Instance.new("TextButton",dropF); row.Size=UDim2.new(1,0,0,itemH); row.BackgroundTransparency=1; row.Text=""; row.AutoButtonColor=false; row.ZIndex=51
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
        local dot=Instance.new("Frame",row); dot.Size=UDim2.fromOffset(10,10); dot.Position=UDim2.new(0,8,0.5,-5)
        dot.BackgroundColor3=themeAccentDots[name] or Config.Accent; dot.BorderSizePixel=0; dot.ZIndex=52
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-28,1,0); lbl.Position=UDim2.fromOffset(26,0)
        lbl.Text=name; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=15
        lbl.TextColor3=name==currentThemeName and Config.Accent or Color3.fromRGB(200,200,215)
        lbl.BackgroundTransparency=1; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=52
        if name==currentThemeName then row.BackgroundTransparency=0.75; row.BackgroundColor3=Config.Accent end
        row.MouseEnter:Connect(function()
            if name~=currentThemeName then tween(row,TweenInfo.new(0.12,Enum.EasingStyle.Quint),{BackgroundTransparency=0.82,BackgroundColor3=Config.Accent}); tween(lbl,TweenInfo.new(0.12),{TextColor3=Config.White}) end
        end)
        row.MouseLeave:Connect(function()
            if name~=currentThemeName then tween(row,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{BackgroundTransparency=1}); tween(lbl,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(200,200,215)}) end
        end)
        row.MouseButton1Click:Connect(function()
            themeIdx=idx; applyThemeAndRecolor(name)
            if themeBtn and themeBtn.Parent then themeBtn.Text="Theme: "..name end
            for _, ch in dropF:GetChildren() do
                if ch:IsA("TextButton") then
                    local cl=ch:FindFirstChildOfClass("TextLabel"); if cl then
                        local isActive=cl.Text==name
                        tween(ch,TweenInfo.new(0.18),{BackgroundTransparency=isActive and 0.75 or 1,BackgroundColor3=Config.Accent})
                        tween(cl,TweenInfo.new(0.18),{TextColor3=isActive and Config.Accent or Color3.fromRGB(200,200,215)})
                    end
                end
            end
            dStroke.Color=Config.Accent
        end)
    end
    local totalH=#themeNames*(itemH+2)+8
    tween(dropF,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(dropW,totalH)})
end)

-- ─── Config system ───────────────────────────────────────────────────────────
local cfgFolder = "elysium_configs"
pcall(function() if not isfolder(cfgFolder) then makefolder(cfgFolder) end end)
local CFG_KEYS = {"TriggerBot","TriggerDelay","TriggerDist","KnifeCheck","WallCheck","RMBOnly","ESP_Enabled","Box","HealthBar","Names","Distance","Tracers","MaxDistance","HitboxEnabled","HitboxSize","HitboxTransparency","FakeLag","FakeLagDelay","FakeLagInterval"}
local function serializeConfig()
    local t={}; for _,k in CFG_KEYS do t[k]=Settings[k] end; t.__theme=currentThemeName
    local parts={}
    for k,v in t do
        local vs; if type(v)=="boolean" then vs=v and "true" or "false" elseif type(v)=="number" then vs=tostring(v) elseif type(v)=="string" then vs='"'..v..'"' end
        if vs then parts[#parts+1]=k.."="..vs end
    end
    return table.concat(parts,";")
end
local function deserializeConfig(str)
    local t={}
    for pair in str:gmatch("[^;]+") do
        local k,v=pair:match("^(.-)=(.+)$")
        if k and v then
            if v=="true" then t[k]=true elseif v=="false" then t[k]=false elseif v:sub(1,1)=='"' then t[k]=v:sub(2,-2) else t[k]=tonumber(v) end
        end
    end
    return t
end
local function applyConfig(data)
    for _,k in CFG_KEYS do if data[k]~=nil then Settings[k]=data[k] end end
    if data.__theme and Themes[data.__theme] then applyThemeAndRecolor(data.__theme); if themeBtn and themeBtn.Parent then themeBtn.Text="Theme: "..data.__theme end end
    if uiControls then
        for _,k in {"TriggerBot","KnifeCheck","WallCheck","RMBOnly","HitboxEnabled","FakeLag","ESP_Enabled","Box","HealthBar","Names","Distance","Tracers"} do
            if data[k]~=nil and uiControls[k] and uiControls[k].callback then uiControls[k].callback(data[k]) end
        end
        local sliderMap={TriggerDelay={"TriggerDelay",(data.TriggerDelay or 0)*1000},TriggerDist={"TriggerDist",data.TriggerDist},HitboxSize={"HitboxSize",data.HitboxSize},HitboxTransparency={"HitboxTransparency",(data.HitboxTransparency or 0.5)*100},MaxDistance={"MaxDistance",data.MaxDistance},FakeLagDelay={"FakeLagDelay",data.FakeLagDelay},FakeLagInterval={"FakeLagInterval",data.FakeLagInterval}}
        for _,info in sliderMap do local uiKey,uiVal=info[1],info[2]; if uiVal~=nil and uiControls[uiKey] and uiControls[uiKey].SetValue then uiControls[uiKey].SetValue(uiVal) end end
    end
end
local function listConfigs()
    local files={}; pcall(function() for _,f in listfiles(cfgFolder) do local name=f:match("[/\\]([^/\\]+)%.cfg$"); if name then files[#files+1]=name end end end); return files
end

local cfgListSec = Menu:CreateSection(tConfigs, "Configs")
local cfgNameRow=Instance.new("Frame",cfgListSec.Card); cfgNameRow.Size=UDim2.new(1,0,0,34); cfgNameRow.BackgroundTransparency=1; cfgNameRow.ZIndex=3
local cfgBox=Instance.new("TextBox",cfgNameRow); cfgBox.Size=UDim2.new(1,0,1,0); cfgBox.BackgroundColor3=Color3.fromRGB(20,20,20)
cfgBox.Text="default"; cfgBox.Font=Enum.Font.Gotham; cfgBox.TextSize=15; cfgBox.TextColor3=Config.White
cfgBox.PlaceholderText="Config name..."; cfgBox.PlaceholderColor3=Color3.fromRGB(80,80,80)
cfgBox.BorderSizePixel=0; cfgBox.ZIndex=4; cfgBox.ClearTextOnFocus=false
Instance.new("UICorner",cfgBox).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",cfgBox).Color=Color3.fromRGB(40,40,40)

local btnRow=Instance.new("Frame",cfgListSec.Card); btnRow.Size=UDim2.new(1,0,0,32); btnRow.BackgroundTransparency=1; btnRow.ZIndex=3
local btnList=Instance.new("UIListLayout",btnRow); btnList.FillDirection=Enum.FillDirection.Horizontal; btnList.Padding=UDim.new(0,6)
local function makeCfgBtn(parent,text,w,cb)
    local b=Instance.new("TextButton",parent); b.Size=UDim2.fromOffset(w,32); b.BackgroundColor3=Color3.fromRGB(22,22,22)
    b.Text=text; b.Font=Enum.Font.GothamBold; b.TextSize=13; b.TextColor3=Config.White; b.AutoButtonColor=false; b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.MouseEnter:Connect(function() tween(b,TweenInfo.new(0.13),{BackgroundColor3=Config.Accent}) end)
    b.MouseLeave:Connect(function() tween(b,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(22,22,22)}) end)
    b.MouseButton1Click:Connect(function() pcall(cb) end); return b
end

local rebuildCfgList
makeCfgBtn(btnRow,"Save",80,function()
    local name=cfgBox.Text:gsub("[^%w_%-]","_"); if name=="" then name="default" end
    pcall(function() writefile(cfgFolder.."/"..name..".cfg",serializeConfig()) end)
    rebuildCfgList(); showToast("Config saved: "..name,Color3.fromRGB(80,220,130))
end)
makeCfgBtn(btnRow,"Refresh",90,function() rebuildCfgList() end)

local exportBox=Instance.new("TextBox",cfgListSec.Card); exportBox.Size=UDim2.new(1,0,0,30); exportBox.BackgroundColor3=Color3.fromRGB(16,16,16)
exportBox.Text=""; exportBox.Font=Enum.Font.Gotham; exportBox.TextSize=12; exportBox.TextColor3=Color3.fromRGB(180,220,180)
exportBox.PlaceholderText="Paste import string here / export appears here"; exportBox.PlaceholderColor3=Color3.fromRGB(70,70,80)
exportBox.BorderSizePixel=0; exportBox.ZIndex=4; exportBox.ClearTextOnFocus=false; exportBox.TextTruncate=Enum.TextTruncate.AtEnd
Instance.new("UICorner",exportBox).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",exportBox).Color=Color3.fromRGB(40,40,40)

local expRow=Instance.new("Frame",cfgListSec.Card); expRow.Size=UDim2.new(1,0,0,32); expRow.BackgroundTransparency=1; expRow.ZIndex=3
local expList=Instance.new("UIListLayout",expRow); expList.FillDirection=Enum.FillDirection.Horizontal; expList.Padding=UDim.new(0,6)
makeCfgBtn(expRow,"Export",80,function() exportBox.Text=serializeConfig(); exportBox:CaptureFocus(); exportBox:ReleaseFocus() end)
makeCfgBtn(expRow,"Import",80,function() local str=exportBox.Text; if str and #str>4 then applyConfig(deserializeConfig(str)) end end)

local listHeader=Instance.new("TextLabel",cfgListSec.Card); listHeader.Size=UDim2.new(1,0,0,20); listHeader.BackgroundTransparency=1
listHeader.Text="SAVED CONFIGS"; listHeader.Font=Enum.Font.GothamBold; listHeader.TextSize=12
listHeader.TextColor3=Color3.fromRGB(100,100,110); listHeader.TextXAlignment=Enum.TextXAlignment.Left; listHeader.ZIndex=3

local cfgListFrame=Instance.new("Frame",cfgListSec.Card); cfgListFrame.Size=UDim2.new(1,0,0,0); cfgListFrame.AutomaticSize=Enum.AutomaticSize.Y
cfgListFrame.BackgroundTransparency=1; cfgListFrame.ZIndex=3
local cfgListLayout=Instance.new("UIListLayout",cfgListFrame); cfgListLayout.Padding=UDim.new(0,4); cfgListLayout.SortOrder=Enum.SortOrder.Name
local cfgRows={}

rebuildCfgList = function()
    for _,r in cfgRows do if r and r.Parent then r:Destroy() end end; table.clear(cfgRows)
    local configs=listConfigs()
    if #configs==0 then
        local empty=Instance.new("TextLabel",cfgListFrame); empty.Size=UDim2.new(1,0,0,26); empty.BackgroundTransparency=1
        empty.Text="No saved configs"; empty.Font=Enum.Font.Gotham; empty.TextSize=13
        empty.TextColor3=Color3.fromRGB(80,80,90); empty.TextXAlignment=Enum.TextXAlignment.Left; empty.ZIndex=3; cfgRows[#cfgRows+1]=empty; return
    end
    for _,cfgName in configs do
        local row=Instance.new("Frame",cfgListFrame); row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=Color3.fromRGB(20,20,20); row.BorderSizePixel=0; row.ZIndex=3
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=Color3.fromRGB(40,40,40); rowStroke.Transparency=0.5
        local icon=Instance.new("TextLabel",row); icon.Size=UDim2.fromOffset(20,34); icon.Position=UDim2.fromOffset(8,0)
        icon.Text="📄"; icon.Font=Enum.Font.Gotham; icon.TextSize=14; icon.BackgroundTransparency=1; icon.ZIndex=4
        local nameLbl=Instance.new("TextLabel",row); nameLbl.Size=UDim2.new(1,-160,1,0); nameLbl.Position=UDim2.fromOffset(30,0)
        nameLbl.Text=cfgName; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=14; nameLbl.TextColor3=Config.White
        nameLbl.BackgroundTransparency=1; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.TextTruncate=Enum.TextTruncate.AtEnd; nameLbl.ZIndex=4
        local loadBtn=Instance.new("TextButton",row); loadBtn.Size=UDim2.fromOffset(56,24); loadBtn.Position=UDim2.new(1,-122,0.5,-12)
        loadBtn.Text="Load"; loadBtn.Font=Enum.Font.GothamBold; loadBtn.TextSize=13; loadBtn.BackgroundColor3=Color3.fromRGB(40,100,60); loadBtn.TextColor3=Config.White; loadBtn.AutoButtonColor=false; loadBtn.ZIndex=4
        Instance.new("UICorner",loadBtn).CornerRadius=UDim.new(0,6)
        loadBtn.MouseEnter:Connect(function() tween(loadBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(60,160,90)}) end)
        loadBtn.MouseLeave:Connect(function() tween(loadBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(40,100,60)}) end)
        loadBtn.MouseButton1Click:Connect(function()
            local ok,data=pcall(function() return readfile(cfgFolder.."/"..cfgName..".cfg") end)
            if ok and data then applyConfig(deserializeConfig(data)); cfgBox.Text=cfgName; showToast("Loaded: "..cfgName,Color3.fromRGB(80,180,255))
            else showToast("Failed to load config",Color3.fromRGB(220,80,80)) end
        end)
        local delBtn=Instance.new("TextButton",row); delBtn.Size=UDim2.fromOffset(56,24); delBtn.Position=UDim2.new(1,-60,0.5,-12)
        delBtn.Text="Delete"; delBtn.Font=Enum.Font.GothamBold; delBtn.TextSize=13; delBtn.BackgroundColor3=Color3.fromRGB(90,30,30); delBtn.TextColor3=Config.White; delBtn.AutoButtonColor=false; delBtn.ZIndex=4
        Instance.new("UICorner",delBtn).CornerRadius=UDim.new(0,6)
        delBtn.MouseEnter:Connect(function() tween(delBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(180,50,50)}) end)
        delBtn.MouseLeave:Connect(function() tween(delBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(90,30,30)}) end)
        delBtn.MouseButton1Click:Connect(function()
            tween(row,TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection["In"]),{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)})
            task.delay(0.19,function() pcall(function() delfile(cfgFolder.."/"..cfgName..".cfg") end); showToast("Deleted: "..cfgName,Color3.fromRGB(220,80,80)); rebuildCfgList() end)
        end)
        row.MouseEnter:Connect(function() tween(rowStroke,TweenInfo.new(0.15),{Color=Config.Accent,Transparency=0.4}); tween(nameLbl,TweenInfo.new(0.15),{TextColor3=Config.Accent}) end)
        row.MouseLeave:Connect(function() tween(rowStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(40,40,40),Transparency=0.5}); tween(nameLbl,TweenInfo.new(0.2),{TextColor3=Config.White}) end)
        cfgRows[#cfgRows+1]=row
        local idx=#cfgRows; row.BackgroundTransparency=1
        task.delay((idx-1)*0.04,function()
            if not row or not row.Parent then return end
            tween(row,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=0})
        end)
    end
end
rebuildCfgList()

settSec:AddButton("Unload Script",function()
    Settings.Unloaded=true
    for _,c in connections do pcall(function() c:Disconnect() end) end; table.clear(connections)
    for _,gui in {EspGui,BindHud,BlurGui,HitboxGui,Menu.SG,SplashGui} do safeDestroy(gui) end
end)

-- ─── Stars background ────────────────────────────────────────────────────────
local starList = {}
local function spawnStar()
    local vp = Camera.ViewportSize
    local cx = math.random(0, math.floor(vp.X))
    local s = Instance.new("Frame", Menu.StarBg)
    s.Size=UDim2.fromOffset(0,0); s.BackgroundTransparency=1
    s.Position=UDim2.fromOffset(cx,-12); s.BorderSizePixel=0; s.ZIndex=2
    local starType=math.random(1,3); local sz=math.random(2,6); local alpha=math.random(35,80)/100
    local rays={}
    if starType==1 then
        local rayCount=math.random(4,8)
        for i=1,rayCount do
            local ray=Instance.new("Frame",s); ray.AnchorPoint=Vector2.new(0.5,0.5); ray.Position=UDim2.fromOffset(0,0)
            ray.Size=UDim2.fromOffset(sz*2,1); ray.BackgroundColor3=Color3.fromRGB(math.random(180,255),math.random(200,255),math.random(220,255))
            ray.BackgroundTransparency=1-alpha; ray.BorderSizePixel=0; ray.ZIndex=2; ray.Rotation=(i-1)*(360/rayCount); rays[i]=ray
        end
    elseif starType==2 then
        local dot=Instance.new("Frame",s); dot.AnchorPoint=Vector2.new(0.5,0.5); dot.Position=UDim2.fromOffset(0,0)
        dot.Size=UDim2.fromOffset(sz,sz); dot.BackgroundColor3=Color3.fromRGB(200,220,255)
        dot.BackgroundTransparency=1-alpha; dot.BorderSizePixel=0; dot.ZIndex=2
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0); rays[1]=dot
    else
        local tail=Instance.new("Frame",s); tail.AnchorPoint=Vector2.new(0.5,0); tail.Position=UDim2.fromOffset(0,0)
        tail.Size=UDim2.fromOffset(1,sz*4); tail.BackgroundColor3=Color3.fromRGB(180,210,255)
        tail.BackgroundTransparency=1-alpha*0.7; tail.BorderSizePixel=0; tail.ZIndex=2
        Instance.new("UICorner",tail).CornerRadius=UDim.new(1,0)
        local tg=Instance.new("UIGradient",tail); tg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); tg.Rotation=180
        rays[1]=tail
    end
    starList[#starList+1]={frame=s,rays=rays,x=cx,y=-12,speed=math.random(25,80),sway=math.random(5,35),swaySpeed=math.random(60,180)/100,rotSpeed=starType==1 and math.random(15,55) or 0,t=0,dead=false,blinkT=math.random(0,100)/100,blinkSpeed=math.random(80,200)/100,baseAlpha=alpha}
end
local lastStarSpawn=0
track(RunService.RenderStepped:Connect(function(dt)
    if not Menu or not Menu.StarBg then return end
    local ok,vis=pcall(function() return Menu.StarBg.Parent~=nil and Menu.StarBg.Visible end)
    if not ok or not vis then return end
    local vp=Camera.ViewportSize; lastStarSpawn=lastStarSpawn+dt
    if lastStarSpawn>0.28 and #starList<28 then lastStarSpawn=0; spawnStar() end
    local i=1
    while i<=#starList do
        local e=starList[i]
        if e.dead or not e.frame.Parent then table.remove(starList,i); continue end
        e.t=e.t+dt; e.y=e.y+e.speed*dt; e.blinkT=e.blinkT+dt*e.blinkSpeed
        local blinkAlpha=e.baseAlpha*(0.6+0.4*math.abs(math.sin(e.blinkT)))
        e.frame.Position=UDim2.fromOffset(e.x+math.sin(e.t*e.swaySpeed)*e.sway,e.y)
        for _,ray in e.rays do if ray.Parent then ray.Rotation=ray.Rotation+e.rotSpeed*dt; ray.BackgroundTransparency=1-blinkAlpha end end
        if e.y>vp.Y+20 then e.dead=true; pcall(function() e.frame:Destroy() end); table.remove(starList,i); continue end
        i=i+1
    end
end))

-- ─── Shimmer + ambient stroke pulse ─────────────────────────────────────────
local shimmerFrameCount, shimmerT = 0, 0
track(RunService.Heartbeat:Connect(function(dt)
    shimmerFrameCount=shimmerFrameCount+1; if shimmerFrameCount%5~=0 then return end
    shimmerT=shimmerT+dt*0.28
    local h=(shimBaseH+math.sin(shimmerT*0.9)*0.05)%1
    local s=math.clamp(shimBaseS+math.sin(shimmerT*1.3)*0.04,0,1)
    local v=math.clamp(shimBaseV+math.sin(shimmerT*1.7)*0.03,0,1)
    Config.Accent=Color3.fromHSV(h,s,v); recolorAll()
    if shimmerFrameCount%30==0 and Menu and Menu.MainStroke and Menu.MainStroke.Parent then
        -- ambient pulse на Diamond Edge stroke
        local pulse=0.3+math.abs(math.sin(shimmerT*0.5))*0.2
        Menu.MainStroke.Transparency=pulse
    end
end))

-- ─── Cursor glow ─────────────────────────────────────────────────────────────
local cursorGlow=Instance.new("Frame",Menu.SG)
cursorGlow.Size=UDim2.fromOffset(100,100); cursorGlow.AnchorPoint=Vector2.new(0.5,0.5)
cursorGlow.BackgroundColor3=Config.Accent; cursorGlow.BackgroundTransparency=1
cursorGlow.BorderSizePixel=0; cursorGlow.ZIndex=50; cursorGlow.Active=false; cursorGlow.Interactable=false
Instance.new("UICorner",cursorGlow).CornerRadius=UDim.new(1,0)
local cgGrad=Instance.new("UIGradient",cursorGlow)
cgGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.45),NumberSequenceKeypoint.new(0.6,0.75),NumberSequenceKeypoint.new(1,1)})
trackAccent(cursorGlow)
local cursorGlow2=Instance.new("Frame",Menu.SG)
cursorGlow2.Size=UDim2.fromOffset(36,36); cursorGlow2.AnchorPoint=Vector2.new(0.5,0.5)
cursorGlow2.BackgroundColor3=Config.Accent; cursorGlow2.BackgroundTransparency=1
cursorGlow2.BorderSizePixel=0; cursorGlow2.ZIndex=51; cursorGlow2.Active=false; cursorGlow2.Interactable=false
Instance.new("UICorner",cursorGlow2).CornerRadius=UDim.new(1,0)
local cg2Grad=Instance.new("UIGradient",cursorGlow2)
cg2Grad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(1,1)})
trackAccent(cursorGlow2)
local cgFrame=0; local cgX,cgY=0,0
track(RunService.RenderStepped:Connect(function(dt)
    cgFrame=cgFrame+1; if cgFrame%3~=0 then return end
    local menuOpen=menuVisible and Menu and Menu.Main and Menu.Main.Visible
    if not menuOpen then cursorGlow.BackgroundTransparency=1; cursorGlow2.BackgroundTransparency=1; return end
    local mp=getMousePos(); local spd=1-math.exp(-dt*27)
    cgX=cgX+(mp.X-cgX)*spd; cgY=cgY+(mp.Y-cgY)*spd
    cursorGlow.Position=UDim2.fromOffset(cgX,cgY); cursorGlow.BackgroundColor3=Config.Accent; cursorGlow.BackgroundTransparency=0.65
    cursorGlow2.Position=UDim2.fromOffset(mp.X,mp.Y); cursorGlow2.BackgroundColor3=Config.Accent; cursorGlow2.BackgroundTransparency=0.55
end))

-- ─── Input handling ──────────────────────────────────────────────────────────
local menuVisible = true

-- Splash → Main Menu transition: через 1.5 сек блок трансформируется в основное меню
task.delay(1.5, function()
    if not SplashGui or not SplashGui.Parent then return end

    -- Шаг 1: текст исчезает быстро
    tween(splashTitle, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection["In"]), {TextTransparency=1})
    tween(splashStar,  TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection["In"]), {TextTransparency=1})
    tween(splashSub,   TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection["In"]), {TextTransparency=1})
    tween(splashStroke,TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection["In"]), {Transparency=1})

    -- Шаг 2: блок морфится в точный размер и позицию Main Frame
    -- Exponential Out ≈ Cubic Bezier (0.1, 0.9, 0.2, 1.0) — плавный snap без рывка
    task.delay(0.15, function()
        if not splashBlock or not splashBlock.Parent then return end
        -- UICorner плавно убирается до 18px (как у Main)
        local corner = splashBlock:FindFirstChildOfClass("UICorner")
        if corner then
            tween(corner, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CornerRadius=UDim.new(0,18)})
        end
        tween(splashBlock, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size     = UDim2.fromOffset(900, 620),
            Position = UDim2.new(0.5, 0, 0.5, 0),  -- AnchorPoint=0.5,0.5 → центр экрана
        })
        -- Когда морфинг завершён — подменяем на Main Frame без рывка
        task.delay(0.57, function()
            -- Включаем SG меню, Main уже в нужном размере/позиции
            if Menu and Menu.SG then
                Menu.SG.Enabled = true
                -- Main стартует с той же позиции/размера что и splashBlock в конце морфинга
                Menu.Main.Size     = UDim2.fromOffset(900, 620)
                Menu.Main.Position = UDim2.new(0.5, -450, 0.5, -310)
                Menu.Main.BackgroundTransparency = 0
                Menu.Main.Visible  = true
                Menu.Overlay.Visible = true
                Menu.StarBg.Visible  = true
                tween(Menu.Overlay, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundTransparency=0.45})
                -- Sidebar въезжает
                Menu.Sidebar.Position = UDim2.new(0,-220,0,0)
                tween(Menu.Sidebar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position=UDim2.new(0,0,0,0)})
                -- Заголовок
                task.delay(0.12, function()
                    if not Menu._title or not Menu._title.Parent then return end
                    Menu._title.Position = UDim2.new(0,0,0,22)
                    tween(Menu._title, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
                        {TextTransparency=0, TextStrokeTransparency=0.7, Position=UDim2.new(0,0,0,14)})
                    tween(Menu._subTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency=0.3})
                end)
                task.delay(0.22, function()
                    if not Menu._accentLine or not Menu._accentLine.Parent then return end
                    tween(Menu._accentLine, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(190,2)})
                end)
                enableBlur()
            end
            pcall(function() SplashGui:Destroy() end)
        end)
    end)
end)

track(UserInputService.InputBegan:Connect(function(i, gp)
    if gp or Settings.Unloaded then return end
    if themeDropOpen and i.UserInputType==Enum.UserInputType.MouseButton1 then
        local mp=getMousePos()
        if themeDropFrame and themeDropFrame.Parent then
            local ap=themeDropFrame.AbsolutePosition; local as=themeDropFrame.AbsoluteSize
            if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then closeThemeDrop() end
        end
    end
    if i.KeyCode==Enum.KeyCode.Escape then
        if capturingBind then
            local e=capturingBind; capturingBind=nil; e.key=nil
            if e.cell and e.cell.Parent then e.cell.Text="NONE"; tween(e.cell,TweenInfo.new(0.15),{BackgroundColor3=Config.ToggleOff}) end
        end
        return
    end
    if capturingBind then
        local e=capturingBind; capturingBind=nil; e.key=i.KeyCode
        if e.cell and e.cell.Parent then
            e.cell.Text=tostring(i.KeyCode):gsub("Enum%.KeyCode%.","")
            e.cell.BackgroundColor3=Color3.fromRGB(60,200,100); e.cell.Size=UDim2.fromOffset(62,24)
            tween(e.cell,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(58,22)})
            task.delay(0.35,function() if e.cell and e.cell.Parent then tween(e.cell,TweenInfo.new(0.25),{BackgroundColor3=Config.ToggleOff}) end end)
        end
        if hudEnabled then rebuildHud() end; return
    end
    if i.KeyCode==Settings.MenuKey then menuVisible=not menuVisible; Menu:SetVisible(menuVisible); return end
    if menuVisible then return end
    for _, entry in featureBinds do
        if entry.key==i.KeyCode then
            if entry.mode=="Toggle" then entry.state=not entry.state; entry.callback(entry.state)
            elseif entry.mode=="Hold" then entry.state=true; entry.callback(true); heldBinds[i.KeyCode]=entry end
            if hudEnabled then rebuildHud() end
        end
    end
end))
track(UserInputService.InputEnded:Connect(function(i)
    if Settings.Unloaded then return end
    local e=heldBinds[i.KeyCode]
    if e then e.state=false; e.callback(false); heldBinds[i.KeyCode]=nil; if hudEnabled then rebuildHud() end end
end))

-- ─── Game helpers ────────────────────────────────────────────────────────────
local function isHoldingKnife()
    local char=LocalPlayer.Character; if not char then return false end
    local tool=char:FindFirstChildOfClass("Tool"); if not tool then return false end
    local name=tool.Name:lower()
    return name:find("knife") or name:find("blade") or name:find("dagger") or name:find("sword") or name:find("melee")
end
local function canShoot(target)
    if not target or not target.Parent then return false end
    local char=target:FindFirstAncestorOfClass("Model"); if not char then return false end
    local ply=Players:GetPlayerFromCharacter(char); if not ply or ply==LocalPlayer then return false end
    if _G.Whitelist and _G.Whitelist[ply.UserId] then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then return false end
    if _G.FriendCheck then local ok,f=pcall(function() return LocalPlayer:IsFriendsWith(ply.UserId) end); if ok and f then return false end end
    if _G.CrewCheck and LocalPlayer.Team~=nil and ply.Team==LocalPlayer.Team then return false end
    return true
end

-- ─── TriggerBot loop ──────────────────────────────────────────────────────────────────────────────────────────────────────────
local _S = {
    myChar=nil, myMouse=nil,
    c2p={}, knocked={},
    toolBlocked=false, lastTool=nil, lastHit=0,
    rmbDown=false,
    mainRp=nil,
    press_fn=nil, rel_fn=nil,
    FOOD={
        "knife","blade","dagger","sword","melee","food","burger","pizza",
        "apple","sandwich","drink","soda","water","juice","eat","snack",
        "meal","fries","hotdog","donut","cake","cookie","candy","taco",
        "wrap","boba","coffee","tea","chicken","rice","noodle","soup",
    },
}

do
    local LP  = Players.LocalPlayer
    local UIS = UserInputService
    getgenv().Triggerbot = getgenv().Triggerbot or {}
    pcall(function()
        local e = getfenv()
        _S.press_fn = e[string.char(109,111,117,115,101,49,112,114,101,115,115)]
        _S.rel_fn   = e[string.char(109,111,117,115,101,49,114,101,108,101,97,115,101)]
    end)
    _S.mainRp = RaycastParams.new()
    _S.mainRp.FilterType  = Enum.RaycastFilterType.Exclude
    _S.mainRp.IgnoreWater = true
    local function onChar(char)
        _S.myChar  = char
        _S.myMouse = LP:GetMouse()
        if char then _S.mainRp.FilterDescendantsInstances = {char} end
    end
    onChar(LP.Character)
    LP.CharacterAdded:Connect(onChar)
    LP.CharacterRemoving:Connect(function() _S.myChar = nil end)
    local function regPlayer(p)
        local function onPlayerChar(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then
                task.delay(0.5, function()
                    local h = char:FindFirstChildOfClass("Humanoid")
                    if h then _S.c2p[char] = {p, h} end
                end)
                return
            end
            _S.c2p[char] = {p, hum}
        end
        if p.Character then onPlayerChar(p.Character) end
        p.CharacterAdded:Connect(onPlayerChar)
        p.CharacterRemoving:Connect(function(c) _S.c2p[c]=nil; _S.knocked[c]=nil end)
    end
    for _, p in ipairs(Players:GetPlayers()) do regPlayer(p) end
    Players.PlayerAdded:Connect(regPlayer)
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 then _S.rmbDown = true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 then _S.rmbDown = false end
    end)
end

do
    local S     = _S
    local RS    = RunService
    local WS    = workspace
    local Cam   = workspace.CurrentCamera
    local LP2   = Players.LocalPlayer
    local clock = os.clock
    local sfind = string.find

    local function fire()
        if S.press_fn then pcall(S.press_fn) end
        if S.rel_fn   then pcall(S.rel_fn)   end
    end

    RS.RenderStepped:Connect(function()
        if Settings.Unloaded or not Settings.TriggerBot then return end
        if menuVisible then return end
        -- Проверка Roblox CoreGui (чат, эскейп, инвентарь и т.д.)
        local guiBlocked = false
        pcall(function()
            local cg = game:GetService("CoreGui")
            -- Roblox топбар/чат открыт
            local chat = cg:FindFirstChild("RobloxGui") and cg.RobloxGui:FindFirstChild("ChatBar")
            if chat and chat.Visible then guiBlocked = true; return end
            -- Escape menu / любой CoreGui ScreenGui с фокусом
            local gs = game:GetService("GuiService")
            if gs.MenuIsOpen then guiBlocked = true end
        end)
        if guiBlocked then return end
        local myChar = S.myChar
        if not myChar or not myChar.Parent then return end
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if not myHum or myHum.Health <= 0 then return end
        local tool = myChar:FindFirstChildOfClass("Tool")
        if tool ~= S.lastTool then
            S.lastTool = tool; S.toolBlocked = false
            if tool then
                local n = tool.Name:lower()
                -- Оружие ближнего боя (нож и т.д.) — блокируем только если KnifeCheck включён
                local MELEE = {"knife","blade","dagger","sword","melee"}
                for _, w in ipairs(MELEE) do
                    if sfind(n, w, 1, true) then
                        if Settings.KnifeCheck then S.toolBlocked = true end
                        break
                    end
                end
                -- Еда — блокируем всегда
                if not S.toolBlocked then
                    local FOOD_ONLY = {"food","burger","pizza","apple","sandwich","drink","soda","water",
                        "juice","eat","snack","meal","fries","hotdog","donut","cake","cookie","candy",
                        "taco","wrap","boba","coffee","tea","chicken","rice","noodle","soup"}
                    for _, w in ipairs(FOOD_ONLY) do
                        if sfind(n, w, 1, true) then S.toolBlocked = true; break end
                    end
                end
            end
        end
        if S.toolBlocked then return end
        if TB and TB.RMBOnly and not S.rmbDown then return end
        local mouse = S.myMouse
        local ray   = Cam:ScreenPointToRay(mouse.X, mouse.Y)
        local dir   = ray.Direction * Settings.TriggerDist
        local res   = WS:Raycast(ray.Origin, dir, S.mainRp)
        if not res then res = WS:Spherecast(ray.Origin, 0.3, dir, S.mainRp) end
        if not res then return end
        local hitModel, hitEntry
        local cur = res.Instance
        for _ = 1, 6 do
            if not cur then break end
            local e = S.c2p[cur]
            if e then hitModel = cur; hitEntry = e; break end
            cur = cur.Parent
        end
        if not hitEntry then return end
        local hitPlr, hitHum = hitEntry[1], hitEntry[2]
        if hitPlr == LP2 then return end
        if not hitHum or hitHum.Health <= 0 then return end
        local st = hitHum:GetState()
        if st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.FallingDown
        or st == Enum.HumanoidStateType.Ragdoll then return end
        if _G.Whitelist and _G.Whitelist[hitPlr.UserId] then return end
        if _G.FriendCheck then
            local ok, f = pcall(function() return LP2:IsFriendsWith(hitPlr.UserId) end)
            if ok and f then return end
        end
        if _G.CrewCheck and LP2.Team ~= nil and hitPlr.Team == LP2.Team then return end
        local now   = clock()
        local grace = getgenv().Triggerbot.FlickGrace or 0.09
        S.lastHit   = now
        if now - S.lastHit < grace then end
        fire()
    end)
end

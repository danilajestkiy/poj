--[[  elysium v6.2  ]]
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer

local SafeGui=nil
pcall(function()
    local _f=getfenv()[string.char(103,101,116,104,117,105)]
    if typeof(_f)=="function" then SafeGui=_f() end
end)
if not SafeGui then pcall(function() SafeGui=LocalPlayer:WaitForChild("PlayerGui",5) end) end
if not SafeGui then SafeGui=LocalPlayer:FindFirstChildOfClass("PlayerGui") end

local function parentGui(gui)
    local ok=pcall(function() gui.Parent=SafeGui end)
    if not ok then pcall(function() gui.Parent=LocalPlayer:FindFirstChildOfClass("PlayerGui") end) end
end

local function rname(prefix) return prefix.."_"..tostring(math.random(100000,999999)) end
local function safeDestroy(i)
    if not i then return end
    pcall(function() if i.Parent then i:Destroy() end end)
end
local function tween(inst,info,props)
    if not inst then return end
    local ok,alive=pcall(function() return inst.Parent~=nil end)
    if not ok or not alive then return end
    local ok2,t=pcall(TweenService.Create,TweenService,inst,info,props)
    if ok2 and t then pcall(function() t:Play() end) end
end

-- быстрый spawn частицы-вспышки (используется при открытии меню)
local function spawnBurst(parent, x, y, color)
    -- поднимаемся до ScreenGui чтобы не влиять на layout
    local absPos = parent.AbsolutePosition
    local sg = parent.Parent
    while sg and not sg:IsA("ScreenGui") do sg=sg.Parent end
    local burstParent = sg or parent
    local ax = absPos.X + x
    local ay = absPos.Y + y

    for i=1,10 do
        local p=Instance.new("Frame", burstParent)
        p.AnchorPoint=Vector2.new(0.5,0.5)
        local sz=math.random(3,7)
        p.Size=UDim2.fromOffset(sz,sz)
        p.Position=UDim2.fromOffset(ax, ay)
        p.BackgroundColor3=color; p.BorderSizePixel=0; p.ZIndex=20
        p.Active=false; p.Interactable=false
        Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
        local angle=math.rad((i-1)*36+math.random(-20,20))
        local dist=math.random(50,120)
        local tx=ax+math.cos(angle)*dist
        local ty=ay+math.sin(angle)*dist
        local dur=math.random(45,75)/100
        tween(p,TweenInfo.new(dur,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
            Position=UDim2.fromOffset(tx,ty),
            Size=UDim2.fromOffset(0,0),
            BackgroundTransparency=1
        })
        task.delay(dur+0.01,function() pcall(function() p:Destroy() end) end)
    end
end

-- shine sweep по кнопке/карточке
local function doShine(parent, w, h, zidx)
    -- парентим в SG чтобы не влиять на AutomaticSize layout
    local absPos = parent.AbsolutePosition
    local sg = parent
    -- поднимаемся до ScreenGui
    local p = parent.Parent
    while p and not p:IsA("ScreenGui") do p=p.Parent end
    local shineParent = p or parent

    local shine=Instance.new("Frame", shineParent)
    shine.Size=UDim2.fromOffset(math.max(w*0.3,30), h+16)
    shine.Position=UDim2.fromOffset(absPos.X - w*0.4, absPos.Y - 4)
    shine.BackgroundColor3=Color3.new(1,1,1)
    shine.BackgroundTransparency=0.78
    shine.BorderSizePixel=0; shine.ZIndex=zidx or 8
    shine.Rotation=14; shine.ClipsDescendants=false
    shine.Active=false; shine.Interactable=false
    Instance.new("UICorner",shine).CornerRadius=UDim.new(0,6)
    local grad=Instance.new("UIGradient",shine)
    grad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.4,0.45),
        NumberSequenceKeypoint.new(0.6,0.45),
        NumberSequenceKeypoint.new(1,1)
    })
    tween(shine,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
        Position=UDim2.fromOffset(absPos.X + w + 20, absPos.Y - 4)
    })
    task.delay(0.51,function() pcall(function() shine:Destroy() end) end)
end

-- пульс-кольцо вокруг элемента
local function doPulseRing(parent, cx, cy, color, radius)
    radius = radius or 30
    local absPos = parent.AbsolutePosition
    local p = parent.Parent
    while p and not p:IsA("ScreenGui") do p=p.Parent end
    local ringParent = p or parent

    local ring=Instance.new("Frame", ringParent)
    ring.AnchorPoint=Vector2.new(0.5,0.5)
    ring.Size=UDim2.fromOffset(radius, radius)
    ring.Position=UDim2.fromOffset(absPos.X + cx, absPos.Y + cy)
    ring.BackgroundTransparency=1; ring.BorderSizePixel=0; ring.ZIndex=15
    ring.Active=false; ring.Interactable=false
    local rs=Instance.new("UIStroke",ring)
    rs.Color=color; rs.Thickness=2; rs.Transparency=0.1
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
    tween(ring,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
        Size=UDim2.fromOffset(radius*2.8, radius*2.8)
    })
    tween(rs,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Transparency=1})
    task.delay(0.51,function() pcall(function() ring:Destroy() end) end)
end

-- мини-вспышка в точке (для тоглов, кнопок)
local function doFlash(parent, cx, cy, color)
    local absPos = parent.AbsolutePosition
    local p = parent.Parent
    while p and not p:IsA("ScreenGui") do p=p.Parent end
    local flashParent = p or parent

    local f=Instance.new("Frame", flashParent)
    f.AnchorPoint=Vector2.new(0.5,0.5)
    f.Size=UDim2.fromOffset(8,8)
    f.Position=UDim2.fromOffset(absPos.X + cx, absPos.Y + cy)
    f.BackgroundColor3=color; f.BorderSizePixel=0; f.ZIndex=16
    f.Active=false; f.Interactable=false
    Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
    tween(f,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
        Size=UDim2.fromOffset(0,0), BackgroundTransparency=1
    })
    task.delay(0.36,function() pcall(function() f:Destroy() end) end)
end

local GuiService=game:GetService("GuiService")
local function getMousePos()
    local mp=UserInputService:GetMouseLocation()
    local inset=GuiService:GetGuiInset()
    return Vector2.new(mp.X, mp.Y-inset.Y)
end

local Themes={
    Orange  ={Accent=Color3.fromRGB(255,175,60),  MainBg=Color3.fromRGB(15,15,19),  SidebarBg=Color3.fromRGB(11,11,15), CardBg=Color3.fromRGB(20,20,26),  Stroke=Color3.fromRGB(40,40,52),  ToggleOff=Color3.fromRGB(36,36,44),  SliderBar=Color3.fromRGB(30,30,38)},
    Purple  ={Accent=Color3.fromRGB(170,100,255), MainBg=Color3.fromRGB(13,11,19),  SidebarBg=Color3.fromRGB(10,8,16),  CardBg=Color3.fromRGB(18,15,28),  Stroke=Color3.fromRGB(46,36,66),  ToggleOff=Color3.fromRGB(32,26,48),  SliderBar=Color3.fromRGB(26,20,42)},
    Cyan    ={Accent=Color3.fromRGB(60,210,230),  MainBg=Color3.fromRGB(11,15,19),  SidebarBg=Color3.fromRGB(8,12,16),  CardBg=Color3.fromRGB(14,20,26),  Stroke=Color3.fromRGB(26,46,58),  ToggleOff=Color3.fromRGB(20,36,46),  SliderBar=Color3.fromRGB(16,30,40)},
    Red     ={Accent=Color3.fromRGB(235,75,75),   MainBg=Color3.fromRGB(17,11,11),  SidebarBg=Color3.fromRGB(13,8,8),   CardBg=Color3.fromRGB(22,15,15),  Stroke=Color3.fromRGB(50,30,30),  ToggleOff=Color3.fromRGB(38,24,24),  SliderBar=Color3.fromRGB(32,18,18)},
    Rose    ={Accent=Color3.fromRGB(255,100,160), MainBg=Color3.fromRGB(18,11,15),  SidebarBg=Color3.fromRGB(14,8,12),  CardBg=Color3.fromRGB(24,14,20),  Stroke=Color3.fromRGB(58,28,44),  ToggleOff=Color3.fromRGB(42,20,32),  SliderBar=Color3.fromRGB(34,14,26)},
    Emerald ={Accent=Color3.fromRGB(50,220,130),  MainBg=Color3.fromRGB(10,17,13),  SidebarBg=Color3.fromRGB(7,13,10),  CardBg=Color3.fromRGB(12,22,16),  Stroke=Color3.fromRGB(22,52,34),  ToggleOff=Color3.fromRGB(16,40,26),  SliderBar=Color3.fromRGB(12,32,20)},
    Gold    ={Accent=Color3.fromRGB(255,210,50),  MainBg=Color3.fromRGB(16,14,10),  SidebarBg=Color3.fromRGB(12,10,7),  CardBg=Color3.fromRGB(22,18,12),  Stroke=Color3.fromRGB(52,44,20),  ToggleOff=Color3.fromRGB(38,32,14),  SliderBar=Color3.fromRGB(30,26,10)},
    Ice     ={Accent=Color3.fromRGB(140,200,255), MainBg=Color3.fromRGB(10,13,18),  SidebarBg=Color3.fromRGB(7,10,15),  CardBg=Color3.fromRGB(13,17,24),  Stroke=Color3.fromRGB(28,38,58),  ToggleOff=Color3.fromRGB(20,28,44),  SliderBar=Color3.fromRGB(14,22,36)},
    Sakura  ={Accent=Color3.fromRGB(255,160,200), MainBg=Color3.fromRGB(18,12,16),  SidebarBg=Color3.fromRGB(14,9,13),  CardBg=Color3.fromRGB(24,15,21),  Stroke=Color3.fromRGB(58,30,50),  ToggleOff=Color3.fromRGB(42,22,36),  SliderBar=Color3.fromRGB(34,16,28)},
    Void    ={Accent=Color3.fromRGB(120,80,255),  MainBg=Color3.fromRGB(8,8,14),    SidebarBg=Color3.fromRGB(5,5,11),   CardBg=Color3.fromRGB(11,10,20),  Stroke=Color3.fromRGB(30,24,60),  ToggleOff=Color3.fromRGB(22,18,46),  SliderBar=Color3.fromRGB(16,12,36)},
}
local Config={White=Color3.fromRGB(255,255,255)}
local currentThemeName="Orange"

local shimBaseH,shimBaseS,shimBaseV=Color3.toHSV(Themes.Orange.Accent)
local function applyTheme(n)
    local t=Themes[n]; if not t then return end
    currentThemeName=n
    for k,v in t do Config[k]=v end
    local h,s,v2=Color3.toHSV(Themes[n].Accent)
    shimBaseH=h; shimBaseS=s; shimBaseV=v2
end
applyTheme("Orange")

local Settings={
    TriggerBot=false,TriggerDelay=0,TriggerDist=500,KnifeCheck=true,
    ESP_Enabled=false,Box=false,HealthBar=false,Names=false,Distance=false,Tracers=false,MaxDistance=2500,
    MenuKey=Enum.KeyCode.Insert,Unloaded=false,
    HitboxEnabled=false,HitboxSize=8,HitboxTransparency=0.5,
}

local connections={}
local function track(c) connections[#connections+1]=c; return c end
local Camera=workspace.CurrentCamera

local featureBinds={}; local capturingBind=nil; local heldBinds={}; local bindNames={}
local function registerBind(cb)
    local e={key=nil,mode="Toggle",state=false,callback=cb,cell=nil}
    featureBinds[#featureBinds+1]=e; return e
end

-- :   LocalPlayer 
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

_G.Whitelist={}

local accentElements={}
local function trackAccent(i) accentElements[#accentElements+1]=i end
local hudRowMap={}
local function recolorAll()
    for _,i in accentElements do
        if not i then continue end
        if type(i)=="table" then
            --  pill  
            if i._pill and i._pill.Parent then
                i._pill.BackgroundColor3=i._state() and Config.Accent or Config.ToggleOff
            end
            continue
        end
        local ok,alive=pcall(function() return i.Parent~=nil end)
        if not ok or not alive then continue end
        if i:IsA("Frame") or i:IsA("TextButton") then i.BackgroundColor3=Config.Accent
        elseif i:IsA("UIStroke") then i.Color=Config.Accent
        elseif i:IsA("TextLabel") then i.TextColor3=Config.Accent end
    end
    for _,r in hudRowMap do if r.keyLbl and r.keyLbl.Parent then r.keyLbl.TextColor3=Config.Accent end end
end

-- BLUR
local BlurGui=Instance.new("ScreenGui")
BlurGui.Name=rname("bg"); BlurGui.ResetOnSpawn=false; BlurGui.IgnoreGuiInset=true; BlurGui.DisplayOrder=2
parentGui(BlurGui)
local blurDark=Instance.new("Frame",BlurGui)
blurDark.Size=UDim2.fromScale(1,1); blurDark.BackgroundColor3=Color3.fromRGB(4,4,8)
blurDark.BackgroundTransparency=1; blurDark.BorderSizePixel=0; blurDark.ZIndex=1
blurDark.Active=false; blurDark.Interactable=false
local function enableBlur()
    BlurGui.Enabled=true
    tween(blurDark,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{BackgroundTransparency=0.3})
end
local function disableBlur()
    tween(blurDark,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{BackgroundTransparency=1})
    task.delay(0.26,function() if BlurGui and BlurGui.Parent then BlurGui.Enabled=false end end)
end

-- LIBRARY
local Library={}; Library.__index=Library
function Library.new(titleText)
    local lib=setmetatable({},Library)
    lib.SG=Instance.new("ScreenGui"); lib.SG.Name=rname("ui")
    lib.SG.ResetOnSpawn=false; lib.SG.IgnoreGuiInset=true; lib.SG.DisplayOrder=10
    parentGui(lib.SG)
    lib.Overlay=Instance.new("Frame",lib.SG)
    lib.Overlay.Size=UDim2.fromScale(1,1); lib.Overlay.BackgroundColor3=Color3.new(0,0,0)
    lib.Overlay.BackgroundTransparency=1; lib.Overlay.BorderSizePixel=0; lib.Overlay.ZIndex=1
    lib.Overlay.Active=false; lib.Overlay.Interactable=false
    lib.StarBg=Instance.new("Frame",lib.SG)
    lib.StarBg.Size=UDim2.fromScale(1,1); lib.StarBg.BackgroundTransparency=1
    lib.StarBg.BorderSizePixel=0; lib.StarBg.ZIndex=2
    lib.Main=Instance.new("Frame",lib.SG)
    lib.Main.Size=UDim2.fromOffset(900,620); lib.Main.Position=UDim2.new(0.5,-450,0.5,-310)
    lib.Main.BackgroundColor3=Config.MainBg; lib.Main.BorderSizePixel=0
    lib.Main.ZIndex=3; lib.Main.BackgroundTransparency=1; lib.Main.ClipsDescendants=true
    Instance.new("UICorner",lib.Main).CornerRadius=UDim.new(0,18)
    local mainStroke=Instance.new("UIStroke",lib.Main)
    mainStroke.Color=Config.Accent; mainStroke.Thickness=1.2; mainStroke.Transparency=0.6
    trackAccent(mainStroke)
    local mainGrad=Instance.new("UIGradient",lib.Main)
    mainGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(200,200,200))})
    mainGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.02),NumberSequenceKeypoint.new(1,0)})
    mainGrad.Rotation=135
    lib.Sidebar=Instance.new("Frame",lib.Main)
    lib.Sidebar.Name="Sidebar"; lib.Sidebar.Size=UDim2.new(0,220,1,0)
    lib.Sidebar.Position=UDim2.new(0,-220,0,0); lib.Sidebar.BackgroundColor3=Config.SidebarBg
    lib.Sidebar.BorderSizePixel=0; lib.Sidebar.ZIndex=3
    Instance.new("UICorner",lib.Sidebar).CornerRadius=UDim.new(0,18)
    local sbDiv=Instance.new("Frame",lib.Sidebar)
    sbDiv.Size=UDim2.fromOffset(1,0); sbDiv.Position=UDim2.new(1,-1,0,0)
    sbDiv.BackgroundColor3=Config.Accent; sbDiv.BackgroundTransparency=0.7
    sbDiv.BorderSizePixel=0; sbDiv.ZIndex=4; sbDiv.AutomaticSize=Enum.AutomaticSize.Y
    trackAccent(sbDiv)
    local titlePad=Instance.new("Frame",lib.Sidebar)
    titlePad.Size=UDim2.new(1,0,0,96); titlePad.BackgroundTransparency=1; titlePad.ZIndex=3
    local title=Instance.new("TextLabel",titlePad)
    title.Size=UDim2.new(1,0,0,52); title.Position=UDim2.new(0,0,0,14)
    title.Text=titleText; title.Font=Enum.Font.GothamBlack; title.TextSize=42
    title.TextColor3=Config.White; title.BackgroundTransparency=1
    title.TextTransparency=1; title.TextStrokeTransparency=1
    title.TextStrokeColor3=Config.Accent; title.ZIndex=3
    title.TextXAlignment=Enum.TextXAlignment.Center
    local subTitle=Instance.new("TextLabel",titlePad)
    subTitle.Size=UDim2.new(1,-20,0,18); subTitle.Position=UDim2.new(0,12,0,60)
    subTitle.Text=""; subTitle.Font=Enum.Font.Gotham; subTitle.TextSize=14
    subTitle.TextColor3=Config.Accent; subTitle.BackgroundTransparency=1
    subTitle.TextTransparency=0.3; subTitle.TextStrokeTransparency=1
    trackAccent(subTitle)
    local accentLine=Instance.new("Frame",lib.Sidebar)
    accentLine.Size=UDim2.fromOffset(0,2); accentLine.Position=UDim2.new(0,10,0,72)
    accentLine.BackgroundColor3=Config.Accent; accentLine.BorderSizePixel=0; accentLine.ZIndex=3
    Instance.new("UICorner",accentLine).CornerRadius=UDim.new(1,0); trackAccent(accentLine)
    lib.TabBtnHolder=Instance.new("Frame",lib.Sidebar)
    lib.TabBtnHolder.Size=UDim2.new(1,0,1,-108); lib.TabBtnHolder.Position=UDim2.new(0,0,0,108)
    lib.TabBtnHolder.BackgroundTransparency=1; lib.TabBtnHolder.ZIndex=3
    local tbl=Instance.new("UIListLayout",lib.TabBtnHolder)
    tbl.Padding=UDim.new(0,6); tbl.HorizontalAlignment=Enum.HorizontalAlignment.Center
    local tbPad=Instance.new("UIPadding",lib.TabBtnHolder); tbPad.PaddingTop=UDim.new(0,8)
    lib.Container=Instance.new("Frame",lib.Main)
    lib.Container.Name="ContentContainer"; lib.Container.Size=UDim2.new(1,-240,1,-24)
    lib.Container.Position=UDim2.new(0,232,0,12); lib.Container.BackgroundTransparency=1
    lib.Container.ClipsDescendants=true; lib.Container.ZIndex=3
    lib.Tabs={}; lib.TabButtons={}; lib.MainStroke=mainStroke
    lib.Main.Size=UDim2.fromOffset(840,570); lib.Main.Position=UDim2.new(0.5,-420,0.56,-285)
    tween(lib.Overlay,TweenInfo.new(0.45,Enum.EasingStyle.Quad),{BackgroundTransparency=0.45})
    -- открытие: сначала маленький, потом Back bounce
    lib.Main.Size=UDim2.fromOffset(820,550)
    lib.Main.Position=UDim2.new(0.5,-410,0.56,-275)
    tween(lib.Main,TweenInfo.new(0.55,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0,0.3),{BackgroundTransparency=0,Size=UDim2.fromOffset(900,620),Position=UDim2.new(0.5,-450,0.5,-310)})
    task.delay(0.18,function()
        if not lib.Sidebar or not lib.Sidebar.Parent then return end
        tween(lib.Sidebar,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
    end)
    task.delay(0.28,function()
        if not title or not title.Parent then return end
        -- title появляется снизу вверх
        title.Position=UDim2.new(0,0,0,22)
        tween(title,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextTransparency=0,TextStrokeTransparency=0.7,Position=UDim2.new(0,0,0,14)})
        tween(subTitle,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{TextTransparency=0.3})
    end)
    task.delay(0.38,function()
        if not accentLine or not accentLine.Parent then return end
        tween(accentLine,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(190,2)})
    end)
    -- shine sweep по sidebar при старте
    task.delay(0.5,function()
        if not lib.Sidebar or not lib.Sidebar.Parent then return end
        doShine(lib.Sidebar,220,620,10)
    end)
    enableBlur()
    local dragging,dStart,fStart=false,nil,nil
    lib.Sidebar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dStart=i.Position; fStart=lib.Main.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dStart
            lib.Main.Position=UDim2.new(fStart.X.Scale,fStart.X.Offset+d.X,fStart.Y.Scale,fStart.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    return lib
end


function Library:SetVisible(v)
    if v then
        self.Main.Visible=true; self.Overlay.Visible=true; self.StarBg.Visible=true
        self.Main.Size=UDim2.fromOffset(830,560)
        self.Main.Position=UDim2.new(0.5,-415,0.54,-280)
        self.Main.BackgroundTransparency=0.8
        tween(self.Main,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0,0.22),{BackgroundTransparency=0,Size=UDim2.fromOffset(900,620),Position=UDim2.new(0.5,-450,0.5,-310)})
        tween(self.Overlay,TweenInfo.new(0.32,Enum.EasingStyle.Quad),{BackgroundTransparency=0.52})
        self.Sidebar.Position=UDim2.new(0,-220,0,0)
        task.delay(0.08,function()
            if not self.Sidebar or not self.Sidebar.Parent then return end
            tween(self.Sidebar,TweenInfo.new(0.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
        end)
        -- burst по центру + углам
        task.delay(0.2,function()
            if not self.Main or not self.Main.Parent then return end
            spawnBurst(self.Main,450,310,Config.Accent)
            spawnBurst(self.Main,0,0,Config.Accent)
            spawnBurst(self.Main,900,0,Config.Accent)
            spawnBurst(self.Main,0,620,Config.Accent)
            spawnBurst(self.Main,900,620,Config.Accent)
        end)
        -- shine sweep по всему окну
        task.delay(0.22,function()
            if not self.Main or not self.Main.Parent then return end
            doShine(self.Main,900,620,20)
        end)
        -- stroke pulse: яркий → тихий
        task.delay(0.1,function()
            if not self.MainStroke or not self.MainStroke.Parent then return end
            tween(self.MainStroke,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{Transparency=0,Thickness=2.5})
            task.delay(0.18,function()
                if self.MainStroke and self.MainStroke.Parent then
                    tween(self.MainStroke,TweenInfo.new(0.6,Enum.EasingStyle.Quint),{Transparency=0.55,Thickness=1.2})
                end
            end)
        end)
        -- sidebar shine
        task.delay(0.3,function()
            if not self.Sidebar or not self.Sidebar.Parent then return end
            doShine(self.Sidebar,220,620,10)
        end)
        enableBlur()
    else
        if themeDropFrame and themeDropFrame.Parent then themeDropFrame:Destroy(); themeDropFrame=nil; themeDropOpen=false end
        -- stroke flash перед закрытием
        if self.MainStroke and self.MainStroke.Parent then
            tween(self.MainStroke,TweenInfo.new(0.08),{Transparency=0,Thickness=2})
        end
        task.delay(0.06,function()
            tween(self.Main,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1,Size=UDim2.fromOffset(875,605),Position=UDim2.new(0.5,-437,0.5,-302)})
            tween(self.Overlay,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{BackgroundTransparency=1})
            tween(self.Sidebar,TweenInfo.new(0.14,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(0,-220,0,0)})
        end)
        disableBlur()
        task.delay(0.27,function()
            if self.Main and self.Main.Parent then self.Main.Visible=false; self.Main.Size=UDim2.fromOffset(900,620); self.Main.Position=UDim2.new(0.5,-450,0.5,-310) end
            if self.Overlay and self.Overlay.Parent then self.Overlay.Visible=false end
            if self.StarBg and self.StarBg.Parent then self.StarBg.Visible=false end
            if self.MainStroke and self.MainStroke.Parent then self.MainStroke.Transparency=0.55; self.MainStroke.Thickness=1.2 end
        end)
    end
end

function Library:CreateTab(name)
    local isFirst=#self.Tabs==0
    local btn=Instance.new("TextButton",self.TabBtnHolder)
    btn.Size=UDim2.new(0.92,0,0,50)
    btn.BackgroundColor3=isFirst and Color3.fromRGB(22,22,30) or Color3.fromRGB(16,16,22)
    btn.Text=""; btn.AutoButtonColor=false; btn.ZIndex=3
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)

    -- левая акцентная полоса (активный таб)
    local leftBar=Instance.new("Frame",btn)
    leftBar.Size=UDim2.fromOffset(3, isFirst and 26 or 0)
    leftBar.Position=UDim2.new(0,0,0.5,0); leftBar.AnchorPoint=Vector2.new(0,0.5)
    leftBar.BackgroundColor3=Config.Accent; leftBar.BorderSizePixel=0; leftBar.ZIndex=5
    Instance.new("UICorner",leftBar).CornerRadius=UDim.new(1,0); trackAccent(leftBar)

    -- glow за кнопкой
    local btnGlow=Instance.new("Frame",btn)
    btnGlow.Size=UDim2.new(1,0,1,0); btnGlow.Position=UDim2.fromOffset(0,0)
    btnGlow.BackgroundColor3=Config.Accent
    btnGlow.BackgroundTransparency=isFirst and 0.88 or 1
    btnGlow.BorderSizePixel=0; btnGlow.ZIndex=2
    Instance.new("UICorner",btnGlow).CornerRadius=UDim.new(0,10); trackAccent(btnGlow)

    -- текст
    local btnLbl=Instance.new("TextLabel",btn)
    btnLbl.Size=UDim2.new(1,-14,1,0); btnLbl.Position=UDim2.fromOffset(12,0)
    btnLbl.Text=name; btnLbl.Font=Enum.Font.GothamBold; btnLbl.TextSize=18
    btnLbl.TextColor3=isFirst and Config.White or Color3.fromRGB(130,130,148)
    btnLbl.BackgroundTransparency=1; btnLbl.TextXAlignment=Enum.TextXAlignment.Left
    btnLbl.TextStrokeTransparency=1; btnLbl.ZIndex=4

    -- stroke (активный)
    local stroke=Instance.new("UIStroke",btn)
    stroke.Color=Config.Accent; stroke.Thickness=1; stroke.Enabled=isFirst
    stroke.Transparency=0.6; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; trackAccent(stroke)

    local page=Instance.new("ScrollingFrame",self.Container)
    page.Size=UDim2.fromScale(1,1); page.BackgroundTransparency=1; page.Visible=isFirst
    page.ScrollBarThickness=0; page.AutomaticCanvasSize=Enum.AutomaticSize.Y; page.ZIndex=3
    local pl=Instance.new("UIListLayout",page); pl.Padding=UDim.new(0,10)

    btn.MouseEnter:Connect(function()
        if not stroke.Enabled then
            tween(btn,TweenInfo.new(0.16,Enum.EasingStyle.Quint),{BackgroundColor3=Color3.fromRGB(22,22,30)})
            tween(btnLbl,TweenInfo.new(0.16),{TextColor3=Color3.fromRGB(200,200,215)})
            tween(leftBar,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(3,14)})
            tween(btnGlow,TweenInfo.new(0.18),{BackgroundTransparency=0.93})
        else
            tween(btn,TweenInfo.new(0.12,Enum.EasingStyle.Quint),{Size=UDim2.new(0.94,0,0,52)})
        end
    end)
    btn.MouseLeave:Connect(function()
        if not stroke.Enabled then
            tween(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=Color3.fromRGB(16,16,22)})
            tween(btnLbl,TweenInfo.new(0.2),{TextColor3=Color3.fromRGB(130,130,148)})
            tween(leftBar,TweenInfo.new(0.18),{Size=UDim2.fromOffset(3,0)})
            tween(btnGlow,TweenInfo.new(0.22),{BackgroundTransparency=1})
        else
            tween(btn,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(0.92,0,0,50)})
        end
    end)
    btn.MouseButton1Click:Connect(function()
        for _,tab in self.Tabs do tab.Visible=false end
        for _,ob in self.TabButtons do
            local s=ob:FindFirstChildOfClass("UIStroke"); if s then s.Enabled=false end
            tween(ob,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=Color3.fromRGB(16,16,22)})
            for _,ch in ob:GetChildren() do
                if ch:IsA("TextLabel") then tween(ch,TweenInfo.new(0.2),{TextColor3=Color3.fromRGB(130,130,148)}) end
                if ch:IsA("Frame") then tween(ch,TweenInfo.new(0.2),{BackgroundTransparency=1,Size=ch.Name=="leftBar" and UDim2.fromOffset(3,0) or ch.Size}) end
            end
        end
        stroke.Enabled=true
        tween(btn,TweenInfo.new(0.22,Enum.EasingStyle.Quint),{BackgroundColor3=Color3.fromRGB(22,22,30)})
        tween(btnLbl,TweenInfo.new(0.2),{TextColor3=Config.White})
        tween(leftBar,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(3,26)})
        tween(btnGlow,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{BackgroundTransparency=0.88})
        btn.Size=UDim2.new(0.88,0,0,48)
        tween(btn,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0.92,0,0,50)})
        page.Position=UDim2.fromOffset(20,0); page.Visible=true
        tween(page,TweenInfo.new(0.26,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(0,0)})
        local cards={}
        for _,c in page:GetChildren() do if c:IsA("Frame") then cards[#cards+1]=c end end
        for idx,card in cards do
            card.BackgroundTransparency=1
            card.Position=UDim2.new(card.Position.X.Scale,card.Position.X.Offset,card.Position.Y.Scale,card.Position.Y.Offset+14)
            local st2=card:FindFirstChildOfClass("UIStroke"); if st2 then st2.Transparency=1 end
            task.delay((idx-1)*0.04,function()
                if not card or not card.Parent then return end
                tween(card,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=0,Position=UDim2.new(card.Position.X.Scale,card.Position.X.Offset,card.Position.Y.Scale,card.Position.Y.Offset-14)})
                if st2 and st2.Parent then tween(st2,TweenInfo.new(0.24),{Transparency=0}) end
            end)
        end
    end)
    leftBar.Name="leftBar"
    self.Tabs[#self.Tabs+1]=page; self.TabButtons[#self.TabButtons+1]=btn; return page
end

local Section={}; Section.__index=Section
function Library:CreateSection(tab,name)
    local sec=setmetatable({},Section)
    local card=Instance.new("Frame",tab)
    card.Size=UDim2.new(1,-14,0,0); card.AutomaticSize=Enum.AutomaticSize.Y
    card.BackgroundColor3=Config.CardBg; card.BorderSizePixel=0; card.ZIndex=3
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
    local st=Instance.new("UIStroke",card); st.Color=Config.Stroke; st.Thickness=1; st.Transparency=0.3

    -- gradient overlay сверху (тёмный → прозрачный)
    local cardGrad=Instance.new("UIGradient",card)
    cardGrad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(200,200,200))
    })
    cardGrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.04),
        NumberSequenceKeypoint.new(1,0)
    })
    cardGrad.Rotation=90

    local pad=Instance.new("UIPadding",card)
    pad.PaddingLeft=UDim.new(0,14); pad.PaddingRight=UDim.new(0,14)
    pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,14)
    local list=Instance.new("UIListLayout",card); list.Padding=UDim.new(0,8); list.SortOrder=Enum.SortOrder.LayoutOrder

    -- заголовок: акцентная левая полоса + текст
    local headRow=Instance.new("Frame",card)
    headRow.Size=UDim2.new(1,0,0,26); headRow.BackgroundTransparency=1; headRow.ZIndex=3; headRow.LayoutOrder=0

    -- левая полоса заголовка
    local headBar=Instance.new("Frame",headRow)
    headBar.Size=UDim2.fromOffset(3,18); headBar.Position=UDim2.new(0,0,0.5,-9)
    headBar.BackgroundColor3=Config.Accent; headBar.BorderSizePixel=0; headBar.ZIndex=4
    Instance.new("UICorner",headBar).CornerRadius=UDim.new(1,0); trackAccent(headBar)

    -- glow за полосой
    local headBarGlow=Instance.new("Frame",headRow)
    headBarGlow.Size=UDim2.fromOffset(12,18); headBarGlow.Position=UDim2.new(0,-4,0.5,-9)
    headBarGlow.BackgroundColor3=Config.Accent; headBarGlow.BackgroundTransparency=0.75
    headBarGlow.BorderSizePixel=0; headBarGlow.ZIndex=3
    Instance.new("UICorner",headBarGlow).CornerRadius=UDim.new(1,0); trackAccent(headBarGlow)

    local head=Instance.new("TextLabel",headRow)
    head.Size=UDim2.new(1,-16,1,0); head.Position=UDim2.fromOffset(12,0)
    head.Text=name:upper(); head.Font=Enum.Font.GothamBold; head.TextSize=12
    head.TextColor3=Config.Accent; head.TextXAlignment=Enum.TextXAlignment.Left
    head.BackgroundTransparency=1; head.TextStrokeTransparency=1; head.ZIndex=4
    head.TextTransparency=0.15
    trackAccent(head)

    -- разделитель под заголовком
    local divider=Instance.new("Frame",card)
    divider.Size=UDim2.new(1,0,0,1); divider.BackgroundColor3=Config.Accent
    divider.BackgroundTransparency=0.82; divider.BorderSizePixel=0; divider.ZIndex=3; divider.LayoutOrder=1
    Instance.new("UIGradient",divider).Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.15,0),
        NumberSequenceKeypoint.new(0.85,0),
        NumberSequenceKeypoint.new(1,1)
    })
    trackAccent(divider)

    card.MouseEnter:Connect(function()
        tween(st,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Color=Config.Accent,Transparency=0.5,Thickness=1.3})
        tween(headBarGlow,TweenInfo.new(0.22),{BackgroundTransparency=0.6,Size=UDim2.fromOffset(16,22)})
        tween(head,TweenInfo.new(0.18),{TextTransparency=0})
        tween(divider,TweenInfo.new(0.2),{BackgroundTransparency=0.65})
    end)
    card.MouseLeave:Connect(function()
        tween(st,TweenInfo.new(0.28,Enum.EasingStyle.Quint),{Color=Config.Stroke,Transparency=0.3,Thickness=1})
        tween(headBarGlow,TweenInfo.new(0.25),{BackgroundTransparency=0.75,Size=UDim2.fromOffset(12,18)})
        tween(head,TweenInfo.new(0.2),{TextTransparency=0.15})
        tween(divider,TweenInfo.new(0.25),{BackgroundTransparency=0.82})
    end)
    sec.Card=card; return sec
end

local function makeBindCell(parent,entry)
    local modeBtn=Instance.new("TextButton",parent)
    modeBtn.Size=UDim2.fromOffset(46,22); modeBtn.Position=UDim2.new(1,-106,0.5,-11)
    modeBtn.BackgroundColor3=Config.ToggleOff; modeBtn.Text="TGL"
    modeBtn.Font=Enum.Font.GothamBold; modeBtn.TextSize=18; modeBtn.TextColor3=Config.White
    modeBtn.AutoButtonColor=false; modeBtn.TextStrokeTransparency=1; modeBtn.ZIndex=4
    Instance.new("UICorner",modeBtn).CornerRadius=UDim.new(0,5)
    local cell=Instance.new("TextButton",parent)
    cell.Size=UDim2.fromOffset(58,22); cell.Position=UDim2.new(1,-58,0.5,-11)
    cell.BackgroundColor3=Config.ToggleOff; cell.Text="NONE"
    cell.Font=Enum.Font.GothamBold; cell.TextSize=18; cell.TextColor3=Config.White
    cell.AutoButtonColor=false; cell.TextStrokeTransparency=1; cell.ZIndex=4
    Instance.new("UICorner",cell).CornerRadius=UDim.new(0,5)
    entry.cell=cell
    modeBtn.MouseButton1Click:Connect(function()
        entry.mode=entry.mode=="Toggle" and "Hold" or "Toggle"
        modeBtn.Text=entry.mode=="Toggle" and "TGL" or "HLD"
        tween(modeBtn,TweenInfo.new(0.15),{BackgroundColor3=entry.mode=="Hold" and Config.Accent or Config.ToggleOff})
    end)
    cell.MouseButton1Click:Connect(function()
        capturingBind=entry; cell.Text="..."
        tween(cell,TweenInfo.new(0.12),{BackgroundColor3=Config.Accent})
        cell.Size=UDim2.fromOffset(62,24)
        tween(cell,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(58,22)})
    end)
    cell.MouseButton2Click:Connect(function()
        entry.key=nil; cell.Text="NONE"
        tween(cell,TweenInfo.new(0.15),{BackgroundColor3=Config.ToggleOff})
        cell.Size=UDim2.fromOffset(54,20)
        tween(cell,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(58,22)})
    end)
end

function Section:AddToggle(text,default,callback)
    local entry=registerBind(function(v) end); bindNames[entry]=text
    local row=Instance.new("Frame",self.Card)
    row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=Color3.fromRGB(28,28,36)
    row.BackgroundTransparency=1; row.BorderSizePixel=0; row.ZIndex=3; row.Active=false
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    -- тонкий stroke на row (появляется при hover)
    local rowStroke=Instance.new("UIStroke",row)
    rowStroke.Color=Config.Accent; rowStroke.Thickness=1; rowStroke.Transparency=1
    rowStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; trackAccent(rowStroke)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-114,1,0); lbl.Text=text; lbl.Font=Enum.Font.Gotham; lbl.TextSize=17
    lbl.TextColor3=Config.White; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.BackgroundTransparency=1; lbl.TextStrokeTransparency=1; lbl.ZIndex=3
    local pill=Instance.new("TextButton",row)
    pill.Size=UDim2.fromOffset(50,26); pill.Position=UDim2.new(1,-168,0.5,-13)
    pill.BackgroundColor3=default and Config.Accent or Config.ToggleOff
    pill.Text=""; pill.AutoButtonColor=false; pill.ZIndex=4
    Instance.new("UICorner",pill).CornerRadius=UDim.new(0,6)
    -- accent glow под pill (вместо белой полоски)
    local pillGlow=Instance.new("Frame",pill)
    pillGlow.Size=UDim2.new(0.7,0,0,2); pillGlow.Position=UDim2.new(0.15,0,1,-1)
    pillGlow.BackgroundColor3=Config.Accent; pillGlow.BackgroundTransparency=0.5
    pillGlow.BorderSizePixel=0; pillGlow.ZIndex=3
    Instance.new("UICorner",pillGlow).CornerRadius=UDim.new(1,0)
    local pillGlowGrad=Instance.new("UIGradient",pillGlow)
    pillGlowGrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.5,0),
        NumberSequenceKeypoint.new(1,1)
    })
    trackAccent(pillGlow)
    local dot=Instance.new("Frame",pill); dot.Size=UDim2.fromOffset(18,18)
    dot.Position=default and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)
    dot.BackgroundColor3=Config.White; dot.ZIndex=6
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,4)
    -- dot shadow
    local dotShadow=Instance.new("Frame",pill)
    dotShadow.Size=UDim2.fromOffset(18,18)
    dotShadow.Position=default and UDim2.new(1,-22,0.5,-8) or UDim2.new(0,4,0.5,-8)
    dotShadow.BackgroundColor3=Color3.new(0,0,0); dotShadow.BackgroundTransparency=0.7
    dotShadow.BorderSizePixel=0; dotShadow.ZIndex=5
    Instance.new("UICorner",dotShadow).CornerRadius=UDim.new(0,4)
    row.MouseEnter:Connect(function()
        tween(row,TweenInfo.new(0.14,Enum.EasingStyle.Quint),{BackgroundTransparency=0.72})
        tween(lbl,TweenInfo.new(0.14),{TextColor3=Config.Accent})
        tween(rowStroke,TweenInfo.new(0.18),{Transparency=0.6})
    end)
    row.MouseLeave:Connect(function()
        tween(row,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundTransparency=1})
        tween(lbl,TweenInfo.new(0.2),{TextColor3=Config.White})
        tween(rowStroke,TweenInfo.new(0.22),{Transparency=1})
    end)
    row.InputBegan:Connect(function(i)
        if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local ripple=Instance.new("Frame",row)
        ripple.AnchorPoint=Vector2.new(0.5,0.5); ripple.BackgroundColor3=Config.Accent
        ripple.BackgroundTransparency=0.55; ripple.BorderSizePixel=0; ripple.ZIndex=6
        ripple.Size=UDim2.fromOffset(0,0)
        local mp=getMousePos(); local rp=row.AbsolutePosition
        ripple.Position=UDim2.fromOffset(mp.X-rp.X,mp.Y-rp.Y)
        Instance.new("UICorner",ripple).CornerRadius=UDim.new(1,0)
        tween(ripple,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(220,220),BackgroundTransparency=1})
        task.delay(0.51,function() pcall(function() ripple:Destroy() end) end)
    end)
    local state=default
    local pillAccentRef={_pill=pill,_state=function() return state end}
    accentElements[#accentElements+1]=pillAccentRef
    local function setState(v)
        state=v
        tween(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quint),{BackgroundColor3=state and Config.Accent or Config.ToggleOff})
        tween(dot,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=state and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)})
        tween(dotShadow,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=state and UDim2.new(1,-22,0.5,-8) or UDim2.new(0,4,0.5,-8)})
        dot.Size=UDim2.fromOffset(22,22); dotShadow.Size=UDim2.fromOffset(22,22)
        tween(dot,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(18,18)})
        tween(dotShadow,TweenInfo.new(0.2),{Size=UDim2.fromOffset(18,18)})
        pill.Size=UDim2.fromOffset(56,30)
        tween(pill,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(50,26)})
        if state then
            tween(pillGlow,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{BackgroundTransparency=0.2,Size=UDim2.new(0.9,0,0,3)})
        else
            tween(pillGlow,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{BackgroundTransparency=0.5,Size=UDim2.new(0.7,0,0,2)})
        end
        if state then
            -- glow ring
            local ring=Instance.new("Frame",row)
            ring.AnchorPoint=Vector2.new(0.5,0.5)
            ring.Size=UDim2.fromOffset(28,28)
            ring.Position=UDim2.new(1,-143,0.5,0)
            ring.BackgroundTransparency=1; ring.BorderSizePixel=0; ring.ZIndex=7
            local rs=Instance.new("UIStroke",ring); rs.Color=Config.Accent; rs.Thickness=2.5; rs.Transparency=0.1
            Instance.new("UICorner",ring).CornerRadius=UDim.new(0,6)
            tween(ring,TweenInfo.new(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(62,38)})
            tween(rs,TweenInfo.new(0.45),{Transparency=1})
            task.delay(0.46,function() pcall(function() ring:Destroy() end) end)
            -- flash частицы из pill
            local px=row.AbsoluteSize.X-143
            for _=1,4 do
                doFlash(row,px+math.random(-10,10),18+math.random(-6,6),Config.Accent)
            end
            -- label bounce
            lbl.TextSize=19
            tween(lbl,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextSize=17})
        else
            -- dim flash при выключении
            local px=row.AbsoluteSize.X-143
            doFlash(row,px,18,Color3.fromRGB(180,180,200))
        end
        callback(state)
    end
    pill.MouseButton1Click:Connect(function() setState(not state) end)
    entry.callback=setState; makeBindCell(row,entry); return entry
end

function Section:AddSlider(text,min,max,default,callback,float)
    local sCont=Instance.new("Frame",self.Card)
    sCont.Size=UDim2.new(1,0,0,54); sCont.BackgroundTransparency=1; sCont.Active=true; sCont.ZIndex=3
    local sTitle=Instance.new("TextLabel",sCont)
    sTitle.Size=UDim2.new(0.7,0,0,20); sTitle.Text=text; sTitle.Font=Enum.Font.Gotham; sTitle.TextSize=26
    sTitle.TextColor3=Config.White; sTitle.BackgroundTransparency=1
    sTitle.TextXAlignment=Enum.TextXAlignment.Left; sTitle.TextStrokeTransparency=1; sTitle.ZIndex=3
    local valLbl=Instance.new("TextLabel",sCont)
    valLbl.Size=UDim2.fromOffset(64,20); valLbl.Position=UDim2.new(1,-64,0,0)
    valLbl.Text=tostring(default); valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=26
    valLbl.TextColor3=Config.Accent; valLbl.BackgroundTransparency=1
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.TextStrokeTransparency=1; valLbl.ZIndex=3
    trackAccent(valLbl)
    local bar=Instance.new("Frame",sCont)
    bar.Size=UDim2.new(1,0,0,6); bar.Position=UDim2.new(0,0,0,34)
    bar.BackgroundColor3=Config.SliderBar; bar.BorderSizePixel=0; bar.ZIndex=3
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    -- bar inner sheen
    local barSheen=Instance.new("Frame",bar)
    barSheen.Size=UDim2.new(1,0,0.5,0); barSheen.BackgroundColor3=Color3.new(1,1,1)
    barSheen.BackgroundTransparency=0.88; barSheen.BorderSizePixel=0; barSheen.ZIndex=4
    Instance.new("UICorner",barSheen).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3=Config.Accent; fill.BorderSizePixel=0; fill.ZIndex=4
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0); trackAccent(fill)
    -- fill sheen
    local fillSheen=Instance.new("Frame",fill)
    fillSheen.Size=UDim2.new(1,0,0.5,0); fillSheen.BackgroundColor3=Color3.new(1,1,1)
    fillSheen.BackgroundTransparency=0.75; fillSheen.BorderSizePixel=0; fillSheen.ZIndex=5
    Instance.new("UICorner",fillSheen).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",bar)
    knob.Size=UDim2.fromOffset(0,0); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((default-min)/(max-min),0,0.5,0)
    knob.BackgroundColor3=Config.White; knob.BorderSizePixel=0; knob.ZIndex=6
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    -- knob glow (невидимый, появляется при drag)
    local knobGlow=Instance.new("Frame",bar)
    knobGlow.Size=UDim2.fromOffset(0,0); knobGlow.AnchorPoint=Vector2.new(0.5,0.5)
    knobGlow.Position=UDim2.new((default-min)/(max-min),0,0.5,0)
    knobGlow.BackgroundColor3=Config.Accent; knobGlow.BackgroundTransparency=1
    knobGlow.BorderSizePixel=0; knobGlow.ZIndex=5
    Instance.new("UICorner",knobGlow).CornerRadius=UDim.new(1,0); trackAccent(knobGlow)
    bar.MouseEnter:Connect(function()
        tween(bar,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,33)})
        tween(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(14,14)})
        tween(knobGlow,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(22,22),BackgroundTransparency=0.7})
        tween(sTitle,TweenInfo.new(0.15),{TextColor3=Config.Accent})
    end)
    bar.MouseLeave:Connect(function()
        tween(bar,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,34)})
        if not _dragging then
            tween(knob,TweenInfo.new(0.15),{Size=UDim2.fromOffset(0,0)})
            tween(knobGlow,TweenInfo.new(0.15),{Size=UDim2.fromOffset(0,0),BackgroundTransparency=1})
        end
        tween(sTitle,TweenInfo.new(0.2),{TextColor3=Config.White})
    end)
    local _dragging=false
    local lastVal=default
    local function update()
        local r=math.clamp((getMousePos().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local v=min+(max-min)*r; if not float then v=math.round(v) end
        fill.Size=UDim2.new(r,0,1,0)
        knob.Position=UDim2.new(r,0,0.5,0)
        knobGlow.Position=UDim2.new(r,0,0.5,0)
        local newText=float and string.format("%.2f",v) or tostring(v)
        if newText~=valLbl.Text then
            valLbl.Text=newText
            -- value pop
            valLbl.TextSize=30
            tween(valLbl,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextSize=26})
        end
        lastVal=v; callback(v)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            _dragging=true
            tween(knob,TweenInfo.new(0.14,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(20,20)})
            tween(knobGlow,TweenInfo.new(0.14,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(30,30),BackgroundTransparency=0.6})
            tween(bar,TweenInfo.new(0.12),{Size=UDim2.new(1,0,0,9),Position=UDim2.new(0,0,0,32)})
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 and _dragging then
            _dragging=false
            tween(knob,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(14,14)})
            tween(knobGlow,TweenInfo.new(0.2),{Size=UDim2.fromOffset(22,22),BackgroundTransparency=0.7})
            tween(bar,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,33)})
            -- release flash
            doPulseRing(bar,knob.Position.X.Scale*bar.AbsoluteSize.X,0,Config.Accent,8)
        end
    end)
    track(RunService.RenderStepped:Connect(function() if _dragging then update() end end))
    local function setValue(v)
        v = math.clamp(v, min, max)
        if not float then v = math.round(v) end
        local r = (v - min) / (max - min)
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, 0, 0.5, 0)
        knobGlow.Position = UDim2.new(r, 0, 0.5, 0)
        valLbl.Text = float and string.format("%.2f", v) or tostring(v)
        callback(v)
    end
    return {SetValue = setValue}
end

function Section:AddButton(text,callback)
    local btn=Instance.new("TextButton",self.Card)
    btn.Size=UDim2.new(1,0,0,36); btn.BackgroundColor3=Config.ToggleOff
    btn.Text=text; btn.Font=Enum.Font.GothamBold; btn.TextSize=26
    btn.TextColor3=Config.White; btn.AutoButtonColor=false; btn.TextStrokeTransparency=1; btn.ZIndex=3
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,9)
    -- accent glow снизу кнопки (вместо белой полоски)
    local btnGlowBar=Instance.new("Frame",btn)
    btnGlowBar.Size=UDim2.new(0.6,0,0,2); btnGlowBar.Position=UDim2.new(0.2,0,1,-2)
    btnGlowBar.BackgroundColor3=Config.Accent; btnGlowBar.BackgroundTransparency=1
    btnGlowBar.BorderSizePixel=0; btnGlowBar.ZIndex=4
    Instance.new("UICorner",btnGlowBar).CornerRadius=UDim.new(1,0)
    local btnGlowGrad=Instance.new("UIGradient",btnGlowBar)
    btnGlowGrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.5,0),
        NumberSequenceKeypoint.new(1,1)
    })
    trackAccent(btnGlowBar)
    -- stroke
    local btnStroke=Instance.new("UIStroke",btn)
    btnStroke.Color=Config.Accent; btnStroke.Thickness=1; btnStroke.Transparency=1
    btnStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; trackAccent(btnStroke)
    btn.MouseEnter:Connect(function()
        tween(btn,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{BackgroundColor3=Config.Accent})
        tween(btn,TweenInfo.new(0.16,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,4,0,38)})
        tween(btnStroke,TweenInfo.new(0.18),{Transparency=0.45})
        tween(btnGlowBar,TweenInfo.new(0.22,Enum.EasingStyle.Quint),{BackgroundTransparency=0.2,Size=UDim2.new(0.8,0,0,2)})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=Config.ToggleOff})
        tween(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,36)})
        tween(btnStroke,TweenInfo.new(0.22),{Transparency=1})
        tween(btnGlowBar,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{BackgroundTransparency=1,Size=UDim2.new(0.6,0,0,2)})
    end)
    btn.MouseButton1Down:Connect(function()
        tween(btn,TweenInfo.new(0.07,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0.97,0,0,33)})
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,4,0,38)})
    end)
    btn.MouseButton1Click:Connect(function()
        local ripple=Instance.new("Frame",btn)
        ripple.AnchorPoint=Vector2.new(0.5,0.5); ripple.BackgroundColor3=Color3.new(1,1,1)
        ripple.BackgroundTransparency=0.7; ripple.BorderSizePixel=0; ripple.ZIndex=5
        ripple.Size=UDim2.fromOffset(0,0)
        local mp=getMousePos(); local bp=btn.AbsolutePosition
        ripple.Position=UDim2.fromOffset(mp.X-bp.X,mp.Y-bp.Y)
        Instance.new("UICorner",ripple).CornerRadius=UDim.new(1,0)
        tween(ripple,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(320,320),BackgroundTransparency=1})
        task.delay(0.51,function() pcall(function() ripple:Destroy() end) end)
        doPulseRing(btn,btn.AbsoluteSize.X/2,18,Config.Accent,20)
        pcall(callback)
    end)
    return btn
end

function Section:AddColorPicker(text,default,callback)
    local currentColor=default or Color3.fromRGB(255,255,255)
    local row=Instance.new("Frame",self.Card)
    row.Size=UDim2.new(1,0,0,36); row.BackgroundTransparency=1; row.BorderSizePixel=0; row.ZIndex=3
    -- row hover stroke
    local rowSt=Instance.new("UIStroke",row)
    rowSt.Color=Config.Accent; rowSt.Thickness=1; rowSt.Transparency=1
    rowSt.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; trackAccent(rowSt)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-46,1,0); lbl.Text=text; lbl.Font=Enum.Font.Gotham; lbl.TextSize=17
    lbl.TextColor3=Config.White; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.BackgroundTransparency=1; lbl.TextStrokeTransparency=1; lbl.ZIndex=3
    local swatch=Instance.new("TextButton",row)
    swatch.Size=UDim2.fromOffset(32,22); swatch.Position=UDim2.new(1,-36,0.5,-11)
    swatch.BackgroundColor3=currentColor; swatch.Text=""; swatch.AutoButtonColor=false; swatch.ZIndex=4
    Instance.new("UICorner",swatch).CornerRadius=UDim.new(0,6)
    local swatchStroke=Instance.new("UIStroke",swatch)
    swatchStroke.Color=Color3.fromRGB(80,80,100); swatchStroke.Thickness=1.5
    -- swatch sheen
    local swSheen=Instance.new("Frame",swatch)
    swSheen.Size=UDim2.new(1,-2,0.45,0); swSheen.Position=UDim2.new(0,1,0,1)
    swSheen.BackgroundColor3=Color3.new(1,1,1); swSheen.BackgroundTransparency=0.7
    swSheen.BorderSizePixel=0; swSheen.ZIndex=5
    Instance.new("UICorner",swSheen).CornerRadius=UDim.new(0,5)
    row.MouseEnter:Connect(function()
        tween(lbl,TweenInfo.new(0.14),{TextColor3=Config.Accent})
        tween(rowSt,TweenInfo.new(0.16),{Transparency=0.65})
        tween(swatch,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(36,26)})
    end)
    row.MouseLeave:Connect(function()
        tween(lbl,TweenInfo.new(0.2),{TextColor3=Config.White})
        tween(rowSt,TweenInfo.new(0.2),{Transparency=1})
        if not _pickerOpen then
            tween(swatch,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(32,22)})
        end
    end)
    local _pickerOpen=false
    local popup=Instance.new("Frame",self.Card)
    popup.Size=UDim2.new(1,0,0,0); popup.BackgroundColor3=Color3.fromRGB(16,16,24)
    popup.BorderSizePixel=0; popup.ClipsDescendants=true; popup.ZIndex=5; popup.Visible=false
    Instance.new("UICorner",popup).CornerRadius=UDim.new(0,12)
    local popStroke=Instance.new("UIStroke",popup)
    popStroke.Color=Config.Accent; popStroke.Thickness=1.2; popStroke.Transparency=0.5; trackAccent(popStroke)
    local popPad=Instance.new("UIPadding",popup)
    popPad.PaddingLeft=UDim.new(0,10); popPad.PaddingRight=UDim.new(0,10)
    popPad.PaddingTop=UDim.new(0,10); popPad.PaddingBottom=UDim.new(0,10)
    local hueBar=Instance.new("Frame",popup); hueBar.Size=UDim2.new(1,0,0,14); hueBar.BackgroundColor3=Color3.new(1,1,1)
    hueBar.BorderSizePixel=0; hueBar.ZIndex=6; hueBar.Active=true
    Instance.new("UICorner",hueBar).CornerRadius=UDim.new(0,5)
    local hueGrad=Instance.new("UIGradient",hueBar)
    hueGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.167,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.333,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.667,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.833,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})
    local hueKnob=Instance.new("Frame",hueBar)
    hueKnob.Size=UDim2.fromOffset(8,20); hueKnob.AnchorPoint=Vector2.new(0.5,0.5)
    hueKnob.Position=UDim2.new(0,0,0.5,0); hueKnob.BackgroundColor3=Color3.new(1,1,1)
    hueKnob.BorderSizePixel=0; hueKnob.ZIndex=9
    Instance.new("UICorner",hueKnob).CornerRadius=UDim.new(0,4)
    local hkStroke=Instance.new("UIStroke",hueKnob); hkStroke.Color=Color3.new(0,0,0); hkStroke.Thickness=1.5
    local svField=Instance.new("Frame",popup); svField.Size=UDim2.new(1,0,0,80)
    svField.Position=UDim2.new(0,0,0,22); svField.BackgroundColor3=Color3.new(1,0,0)
    svField.BorderSizePixel=0; svField.ZIndex=6; svField.Active=true
    Instance.new("UICorner",svField).CornerRadius=UDim.new(0,5)
    local svWhite=Instance.new("UIGradient",svField)
    svWhite.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1)); svWhite.Transparency=NumberSequence.new(0,1)
    local svBlackFrame=Instance.new("Frame",svField); svBlackFrame.Size=UDim2.fromScale(1,1)
    svBlackFrame.BackgroundTransparency=1; svBlackFrame.ZIndex=7
    local svBlack=Instance.new("UIGradient",svBlackFrame)
    svBlack.Color=ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0))
    svBlack.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
    svBlack.Rotation=90
    local svDot=Instance.new("Frame",svField); svDot.Size=UDim2.fromOffset(12,12)
    svDot.AnchorPoint=Vector2.new(0.5,0.5); svDot.BackgroundColor3=Color3.new(1,1,1)
    svDot.BorderSizePixel=0; svDot.ZIndex=8
    Instance.new("UICorner",svDot).CornerRadius=UDim.new(1,0)
    local svDotStroke=Instance.new("UIStroke",svDot); svDotStroke.Color=Color3.new(0,0,0); svDotStroke.Thickness=1.5
    local hexBox=Instance.new("TextBox",popup); hexBox.Size=UDim2.new(1,0,0,24)
    hexBox.Position=UDim2.new(0,0,0,110); hexBox.BackgroundColor3=Color3.fromRGB(22,22,32)
    hexBox.Text="#FF3232"; hexBox.Font=Enum.Font.GothamBold; hexBox.TextSize=14
    hexBox.TextColor3=Color3.new(1,1,1); hexBox.BorderSizePixel=0; hexBox.ZIndex=6
    hexBox.ClearTextOnFocus=false
    Instance.new("UICorner",hexBox).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",hexBox).Color=Color3.fromRGB(50,50,70)
    popup.Size=UDim2.new(1,0,0,144)
    local h,s,v=Color3.toHSV(currentColor)
    local function hexFromColor(c)
        local r,g,b=math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5)
        return string.format("#%02X%02X%02X",r,g,b)
    end
    local function applyColor(c)
        currentColor=c; swatch.BackgroundColor3=c
        svField.BackgroundColor3=Color3.fromHSV(h,1,1)
        svDot.Position=UDim2.new(s,0,1-v,0)
        hueKnob.Position=UDim2.new(h,0,0.5,0)
        hueKnob.BackgroundColor3=Color3.fromHSV(h,1,1)
        hexBox.Text=hexFromColor(c); pcall(callback,c)
    end
    applyColor(currentColor)
    local draggingHue,draggingSV=false,false
    hueBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            draggingHue=true
            tween(hueKnob,TweenInfo.new(0.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(10,24)})
        end
    end)
    svField.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            draggingSV=true
            tween(svDot,TweenInfo.new(0.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(16,16)})
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            if draggingHue then tween(hueKnob,TweenInfo.new(0.15),{Size=UDim2.fromOffset(8,20)}) end
            if draggingSV then tween(svDot,TweenInfo.new(0.15),{Size=UDim2.fromOffset(12,12)}) end
            draggingHue=false; draggingSV=false
        end
    end)
    track(RunService.RenderStepped:Connect(function()
        if not popup.Visible then return end
        local mp=getMousePos()
        if draggingHue then
            local r=math.clamp((mp.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
            h=r; applyColor(Color3.fromHSV(h,s,v))
        end
        if draggingSV then
            s=math.clamp((mp.X-svField.AbsolutePosition.X)/svField.AbsoluteSize.X,0,1)
            v=1-math.clamp((mp.Y-svField.AbsolutePosition.Y)/svField.AbsoluteSize.Y,0,1)
            applyColor(Color3.fromHSV(h,s,v))
        end
    end))
    hexBox.FocusLost:Connect(function()
        local hex=hexBox.Text:gsub("#","")
        if #hex==6 then
            local r=tonumber(hex:sub(1,2),16); local g=tonumber(hex:sub(3,4),16); local b=tonumber(hex:sub(5,6),16)
            if r and g and b then local c=Color3.fromRGB(r,g,b); h,s,v=Color3.toHSV(c); applyColor(c) end
        end
    end)
    swatch.MouseButton1Click:Connect(function()
        _pickerOpen=not _pickerOpen
        if _pickerOpen then
            svField.BackgroundColor3=Color3.fromHSV(h,1,1)
            popup.Visible=true
            -- bounce открытие
            tween(popup,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,144)})
            -- swatch pulse
            tween(swatch,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(38,28)})
            task.delay(0.19,function()
                if swatch and swatch.Parent then
                    tween(swatch,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(32,22)})
                end
            end)
            -- shine на popup
            task.delay(0.33,function()
                if popup and popup.Parent then doShine(popup,popup.AbsoluteSize.X,144,8) end
            end)
            -- stroke flash
            tween(popStroke,TweenInfo.new(0.15),{Transparency=0,Thickness=2})
            task.delay(0.18,function()
                if popStroke and popStroke.Parent then
                    tween(popStroke,TweenInfo.new(0.4,Enum.EasingStyle.Quint),{Transparency=0.5,Thickness=1.2})
                end
            end)
        else
            tween(popup,TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,0)})
            tween(swatch,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(32,22)})
            task.delay(0.23,function() if popup and popup.Parent then popup.Visible=false end end)
        end
    end)
    return {GetColor=function() return currentColor end, SetColor=function(c) h,s,v=Color3.toHSV(c); applyColor(c) end}
end

-- ESP
local EspGui=Instance.new("ScreenGui"); EspGui.Name=rname("esp"); EspGui.ResetOnSpawn=false
EspGui.IgnoreGuiInset=true; EspGui.DisplayOrder=5; parentGui(EspGui)
local espEntries={}

local function hideEntry(e)
    for _,v in e do
        if typeof(v)=="Instance" and v.Parent and v:IsA("GuiObject") then v.Visible=false end
    end
end

local function showEntry(e)
    if e.hpFill and e.hpFill.Parent then e.hpFill.Visible=true end
    if e.barBg and e.barBg.Parent then e.barBg.Visible=true end
    if e.nameF and e.nameF.Parent then e.nameF.Visible=true end
    if e.nameL and e.nameL.Parent then e.nameL.Visible=true end
    if e.distF and e.distF.Parent then e.distF.Visible=true end
    if e.distL and e.distL.Parent then e.distL.Visible=true end
    if e.hpTextF and e.hpTextF.Parent then e.hpTextF.Visible=true end
    if e.hpTextL and e.hpTextL.Parent then e.hpTextL.Visible=true end
    if e.box and e.box.Parent then e.box.Visible=true end
    if e.tracer and e.tracer.Parent then e.tracer.Visible=true end
end

local function makeEspLabel(size)
    local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.ZIndex=6
    local l=Instance.new("TextLabel",f); l.Size=UDim2.fromScale(1,1); l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold; l.TextSize=size; l.TextColor3=Color3.fromRGB(255,255,255)
    l.TextStrokeTransparency=0.2; l.ZIndex=6; return f,l
end

local function createEntry(player)
    if espEntries[player] then return end; local e={}
    local box=Instance.new("Frame",EspGui); box.BackgroundTransparency=1; box.BorderSizePixel=0; box.ZIndex=5
    local boxStroke=Instance.new("UIStroke",box); boxStroke.Color=Color3.fromRGB(255,255,255); boxStroke.Thickness=1.5; boxStroke.Transparency=0.1
    e.box=box; e.boxStroke=boxStroke
    local barBg=Instance.new("Frame",EspGui); barBg.BackgroundColor3=Color3.fromRGB(10,10,12)
    barBg.BackgroundTransparency=0.25; barBg.BorderSizePixel=0; barBg.ZIndex=5
    Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",barBg).Color=Color3.fromRGB(0,0,0)
    local hpFill=Instance.new("Frame",barBg); hpFill.BackgroundColor3=Color3.fromRGB(80,220,100); hpFill.BorderSizePixel=0; hpFill.ZIndex=6
    Instance.new("UICorner",hpFill).CornerRadius=UDim.new(1,0)
    local shine=Instance.new("Frame",hpFill); shine.Size=UDim2.new(1,0,0.45,0)
    shine.BackgroundColor3=Color3.fromRGB(255,255,255); shine.BackgroundTransparency=0.82; shine.BorderSizePixel=0; shine.ZIndex=7
    Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
    local hpGrad=Instance.new("UIGradient",hpFill); hpGrad.Rotation=0
    e.barBg=barBg; e.hpFill=hpFill; e.hpGrad=hpGrad
    local hpTextF,hpTextL=makeEspLabel(12); hpTextL.TextStrokeTransparency=0.2; e.hpTextF=hpTextF; e.hpTextL=hpTextL; hpTextF.Parent=EspGui
    local nameF,nameL=makeEspLabel(14); nameL.TextXAlignment=Enum.TextXAlignment.Center; e.nameF=nameF; e.nameL=nameL; nameF.Parent=EspGui
    local distF,distL=makeEspLabel(13); distL.TextXAlignment=Enum.TextXAlignment.Center; distL.TextColor3=Color3.fromRGB(200,200,200); e.distF=distF; e.distL=distL; distF.Parent=EspGui
    -- Tracer:  Frame  AnchorPoint=(0,0.5)    
    local tracer=Instance.new("Frame",EspGui)
    tracer.AnchorPoint=Vector2.new(0,0.5)
    tracer.BackgroundColor3=Color3.fromRGB(255,255,255)
    tracer.BackgroundTransparency=0.3; tracer.BorderSizePixel=0; tracer.ZIndex=5
    e.tracer=tracer; barBg.Parent=EspGui; espEntries[player]=e
end

local function removeEntry(player)
    local e=espEntries[player]; if not e then return end
    for _,v in e do if typeof(v)=="Instance" then pcall(function() v:Destroy() end) end end
    espEntries[player]=nil
end


local espFrame=0
track(RunService.RenderStepped:Connect(function()
    espFrame=espFrame+1
    local menuOpen=false; pcall(function() menuOpen=Menu and Menu.Main and Menu.Main.Visible end)
    local vp=Camera.ViewportSize
    local camCF=Camera.CFrame
    for _,player in Players:GetPlayers() do
        if player==LocalPlayer then continue end
        local e=espEntries[player]
        local anyOn=Settings.ESP_Enabled and (Settings.Box or Settings.HealthBar or Settings.Names or Settings.Distance or Settings.Tracers)
        if _G.Whitelist and _G.Whitelist[player.UserId] then if e then hideEntry(e) end; continue end
        if not anyOn then if e then hideEntry(e) end; continue end
        if not e then createEntry(player) end; e=espEntries[player]; if not e then continue end
        local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local root=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not root or hum.Health<=0 or menuOpen then hideEntry(e); continue end

        local dist=(root.Position-camCF.Position).Magnitude
        if dist>Settings.MaxDistance then hideEntry(e); continue end

        -- bbox  4   root
        local halfW=1.2; local halfH=3.2
        local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
        local anyOnScreen=false
        for _,offset in {
            Vector3.new(halfW,halfH,0), Vector3.new(-halfW,halfH,0),
            Vector3.new(halfW,-halfH,0), Vector3.new(-halfW,-halfH,0)
        } do
            local sp,vis=Camera:WorldToViewportPoint(root.Position+offset)
            if sp.Z>0 then
                anyOnScreen=true
                minX=math.min(minX,sp.X); minY=math.min(minY,sp.Y)
                maxX=math.max(maxX,sp.X); maxY=math.max(maxY,sp.Y)
            end
        end
        if not anyOnScreen or minX==math.huge then hideEntry(e); e._fx=nil; continue end
        local rawW=maxX-minX; local h=maxY-minY
        --     (      )
        local w=math.max(rawW, h*0.18)
        if w>vp.X*0.85 or h>vp.Y*0.85 then hideEntry(e); e._fx=nil; continue end

        e._x=minX; e._y=minY; e._w=w; e._h=h; e._dist=dist; e._hp=hum.Health/hum.MaxHealth
        e._fx=minX+w/2; e._fy=maxY
        showEntry(e)

        local x=minX; local y=minY
        local hp=e._hp; local distV=dist

        e.box.Visible=Settings.Box
        if Settings.Box then e.box.Position=UDim2.fromOffset(x,y); e.box.Size=UDim2.fromOffset(w,h) end
        e.barBg.Visible=Settings.HealthBar; e.hpTextF.Visible=Settings.HealthBar
        if Settings.HealthBar then
            local barW=3; local barX=x-barW-3
            e.barBg.Position=UDim2.fromOffset(barX,y); e.barBg.Size=UDim2.fromOffset(barW,h)
            e.hpFill.Size=UDim2.new(1,0,hp,0); e.hpFill.Position=UDim2.new(0,0,1-hp,0)
            local topColor=hp>0.6 and Color3.fromRGB(120,255,120) or hp>0.3 and Color3.fromRGB(255,220,60) or Color3.fromRGB(255,80,80)
            e.hpFill.BackgroundColor3=topColor
            e.hpTextF.Position=UDim2.fromOffset(barX-10,y-1); e.hpTextF.Size=UDim2.fromOffset(20,13)
            e.hpTextL.Text=tostring(math.floor(hp*100))
        end
        e.distF.Visible=Settings.Distance
        if Settings.Distance then e.distF.Size=UDim2.fromOffset(70,17); e.distF.Position=UDim2.fromOffset(x+w/2-35,y+h+4); e.distL.Text=string.format("%.0fm",distV) end
        e.nameF.Visible=Settings.Names
        if Settings.Names then
            local name=player.DisplayName
            e.nameF.Size=UDim2.fromOffset(#name*8+10,18); e.nameF.Position=UDim2.fromOffset(x+w/2-(#name*8+10)/2,y-20)
            e.nameL.Text=name
        end
        -- (comment)
        local tracerOk=e._fx>0 and e._fx<vp.X and e._fy>0 and e._fy<vp.Y
        e.tracer.Visible=Settings.Tracers and tracerOk
        if Settings.Tracers and tracerOk then
            local ox=vp.X/2; local oy=vp.Y
            local tx=e._fx; local ty=e._fy
            local dx=tx-ox; local dy=ty-oy
            local len=math.sqrt(dx*dx+dy*dy)
            if len>0 then
                e.tracer.AnchorPoint=Vector2.new(0.5,0.5)
                e.tracer.Position=UDim2.fromOffset((ox+tx)/2,(oy+ty)/2)
                e.tracer.Size=UDim2.fromOffset(len,1)
                e.tracer.Rotation=math.deg(math.atan2(dy,dx))
            end
        end
    end
    for player,_ in espEntries do if not player or not player.Parent then removeEntry(player) end end
end))
Players.PlayerRemoving:Connect(removeEntry)

-- HITBOX
local originalSizes={}
local originalTransparencies={}
local hitboxBoxes={}

local function cacheOriginal(hrp)
    if not originalSizes[hrp] then
        originalSizes[hrp]=hrp.Size
        originalTransparencies[hrp]=hrp.Transparency
    end
end

local function restoreAll()
    for hrp,sz in originalSizes do
        pcall(function()
            if hrp and hrp.Parent then
                hrp.Size=sz
                hrp.Transparency=originalTransparencies[hrp] or 1
            end
        end)
    end
    table.clear(originalSizes)
    table.clear(originalTransparencies)
end

-- Corner-box GUI  
local HitboxGui=Instance.new("ScreenGui")
HitboxGui.Name=rname("hbx"); HitboxGui.ResetOnSpawn=false
HitboxGui.IgnoreGuiInset=true; HitboxGui.DisplayOrder=6
parentGui(HitboxGui)

local function makeCornerBox(parent)
    local corners={}
    for i=1,4 do
        local h=Instance.new("Frame",parent)
        h.BackgroundColor3=Color3.new(1,1,1); h.BorderSizePixel=0; h.ZIndex=7
        local v=Instance.new("Frame",parent)
        v.BackgroundColor3=Color3.new(1,1,1); v.BorderSizePixel=0; v.ZIndex=7
        corners[i]={h=h,v=v}
    end
    return corners
end

local function updateCornerBox(corners, x, y, w, h)
    local thick=2; local len=8
    local defs={
        {ax=0,ay=0, hw=len,hh=thick, vw=thick,vh=len},
        {ax=1,ay=0, hw=len,hh=thick, vw=thick,vh=len},
        {ax=0,ay=1, hw=len,hh=thick, vw=thick,vh=len},
        {ax=1,ay=1, hw=len,hh=thick, vw=thick,vh=len},
    }
    for i=1,4 do
        local c=corners[i]
        if not c or type(c)~="table" or not c.h or not c.v then continue end
        local d=defs[i]
        c.h.Size=UDim2.fromOffset(d.hw,d.hh)
        c.v.Size=UDim2.fromOffset(d.vw,d.vh)
        local px=d.ax==0 and x or x+w
        local py=d.ay==0 and y or y+h
        c.h.Position=UDim2.fromOffset(px,py)
        c.v.Position=UDim2.fromOffset(px,py)
        c.h.AnchorPoint=Vector2.new(d.ax,d.ay)
        c.v.AnchorPoint=Vector2.new(d.ax,d.ay)
    end
end

local function destroyCorners(corners)
    for i=1,4 do
        local c=corners[i]
        if not c or type(c)~="table" or not c.h then continue end
        pcall(function() c.h:Destroy() end)
        pcall(function() c.v:Destroy() end)
    end
end

local hitboxWasEnabled=false
track(RunService.Heartbeat:Connect(function()
    if Settings.Unloaded then return end
    local enabled=Settings.HitboxEnabled
    if hitboxWasEnabled and not enabled then
        restoreAll()
        for player,corners in hitboxBoxes do
            destroyCorners(corners)
            if corners._holder then pcall(function() corners._holder:Destroy() end) end
        end
        table.clear(hitboxBoxes)
    end
    hitboxWasEnabled=enabled
    if not enabled then return end
    local vp=Camera.ViewportSize
    for _,player in Players:GetPlayers() do
        if player==LocalPlayer then continue end
        local char=player.Character
        if not char then
            if hitboxBoxes[player] then
                destroyCorners(hitboxBoxes[player])
                if hitboxBoxes[player]._holder then pcall(function() hitboxBoxes[player]._holder:Destroy() end) end
                hitboxBoxes[player]=nil
            end
            continue
        end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        --   ( )
        cacheOriginal(hrp)
        pcall(function()
            hrp.Size=Vector3.one*Settings.HitboxSize
            hrp.Transparency=Settings.HitboxTransparency
        end)
        -- corner-box  
        if not hitboxBoxes[player] then
            local holder=Instance.new("Frame",HitboxGui)
            holder.BackgroundTransparency=1; holder.Size=UDim2.fromScale(1,1); holder.ZIndex=6
            hitboxBoxes[player]=makeCornerBox(holder)
            hitboxBoxes[player]._holder=holder
        end
        local corners=hitboxBoxes[player]
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then
            for i=1,4 do local c=corners[i]; if c and type(c)=="table" and c.h then c.h.Visible=false; c.v.Visible=false end end
            continue
        end
        local sz=hrp.Size
        local halfW=sz.X/2; local halfH=sz.Y/2
        local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
        local onScreen=false
        for _,off in {
            Vector3.new(halfW,halfH,0),Vector3.new(-halfW,halfH,0),
            Vector3.new(halfW,-halfH,0),Vector3.new(-halfW,-halfH,0)
        } do
            local sp=Camera:WorldToViewportPoint(hrp.Position+off)
            if sp.Z>0 then
                onScreen=true
                minX=math.min(minX,sp.X); minY=math.min(minY,sp.Y)
                maxX=math.max(maxX,sp.X); maxY=math.max(maxY,sp.Y)
            end
        end
        local show=onScreen and minX~=math.huge and (maxX-minX)<vp.X*0.9
        for i=1,4 do
            local c=corners[i]; if not c or type(c)~="table" or not c.h then continue end
            c.h.Visible=show; c.v.Visible=show
        end
        if show then
            updateCornerBox(corners,minX,minY,maxX-minX,maxY-minY)
        end
    end
    for player,corners in hitboxBoxes do
        if not player or not player.Parent then
            destroyCorners(corners)
            if corners._holder then pcall(function() corners._holder:Destroy() end) end
            hitboxBoxes[player]=nil
        end
    end
end))


-- (comment)
local Menu=Library.new("elysium")
local tCombat=Menu:CreateTab("Combat"); local tVisuals=Menu:CreateTab("Visuals"); local tSettings=Menu:CreateTab("Settings"); local tWhitelist=Menu:CreateTab("PlayerList"); local tConfigs=Menu:CreateTab("Configs")

-- toast уведомления
local toastGui=Instance.new("ScreenGui"); toastGui.Name=rname("toast")
toastGui.ResetOnSpawn=false; toastGui.IgnoreGuiInset=true; toastGui.DisplayOrder=99
parentGui(toastGui)
local toastStack={}

local function showToast(msg, color)
    color = color or Config.Accent
    local toast=Instance.new("Frame",toastGui)
    toast.Size=UDim2.fromOffset(10,48); toast.AutomaticSize=Enum.AutomaticSize.X
    toast.Position=UDim2.new(0.5,0,0,-70); toast.AnchorPoint=Vector2.new(0.5,0)
    toast.BackgroundColor3=Color3.fromRGB(12,12,18); toast.BorderSizePixel=0
    toast.BackgroundTransparency=1; toast.ZIndex=99; toast.ClipsDescendants=false
    Instance.new("UICorner",toast).CornerRadius=UDim.new(0,14)
    local ts=Instance.new("UIStroke",toast); ts.Color=color; ts.Thickness=1.4; ts.Transparency=0.2
    local pad=Instance.new("UIPadding",toast)
    pad.PaddingLeft=UDim.new(0,16); pad.PaddingRight=UDim.new(0,16)
    -- top sheen
    local tSheen=Instance.new("Frame",toast)
    tSheen.Size=UDim2.new(1,-4,0,1); tSheen.Position=UDim2.new(0,2,0,1)
    tSheen.BackgroundColor3=Color3.new(1,1,1); tSheen.BackgroundTransparency=0.7
    tSheen.BorderSizePixel=0; tSheen.ZIndex=101
    Instance.new("UICorner",tSheen).CornerRadius=UDim.new(0,14)
    -- цветная полоска слева
    local bar=Instance.new("Frame",toast)
    bar.Size=UDim2.fromOffset(3,30); bar.Position=UDim2.new(0,-1,0.5,-15)
    bar.BackgroundColor3=color; bar.BorderSizePixel=0; bar.ZIndex=101
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    -- dot индикатор
    local dot=Instance.new("Frame",toast)
    dot.Size=UDim2.fromOffset(8,8); dot.Position=UDim2.new(0,0,0.5,-4)
    dot.BackgroundColor3=color; dot.BorderSizePixel=0; dot.ZIndex=101
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",toast)
    lbl.Size=UDim2.new(0,0,1,0); lbl.AutomaticSize=Enum.AutomaticSize.X
    lbl.Position=UDim2.fromOffset(16,0)
    lbl.Text=msg; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=14
    lbl.TextColor3=Color3.fromRGB(225,225,240); lbl.BackgroundTransparency=1
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=101
    -- смещаем существующие тосты вниз
    for _,t2 in toastStack do
        if t2 and t2.Parent then
            tween(t2,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,0,t2.Position.Y.Scale,t2.Position.Y.Offset+56)})
        end
    end
    toastStack[#toastStack+1]=toast
    -- появление с bounce
    tween(toast,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.06,Position=UDim2.new(0.5,0,0,18)})
    tween(ts,TweenInfo.new(0.3),{Transparency=0.2})
    -- shine сразу после появления
    task.delay(0.42,function()
        if toast and toast.Parent then
            doShine(toast,260,48,102)
            -- dot pulse
            doPulseRing(toast,16,24,color,10)
        end
    end)
    -- прогресс-бар снизу
    local prog=Instance.new("Frame",toast)
    prog.Size=UDim2.new(1,-4,0,2); prog.Position=UDim2.new(0,2,1,-3)
    prog.BackgroundColor3=color; prog.BackgroundTransparency=0.4
    prog.BorderSizePixel=0; prog.ZIndex=102
    Instance.new("UICorner",prog).CornerRadius=UDim.new(1,0)
    task.delay(0.45,function()
        if prog and prog.Parent then
            tween(prog,TweenInfo.new(2.0,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,2)})
        end
    end)
    -- исчезновение
    task.delay(2.6,function()
        if not toast or not toast.Parent then return end
        tween(toast,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1,Position=UDim2.new(0.5,0,0,-60)})
        tween(ts,TweenInfo.new(0.2),{Transparency=1})
        task.delay(0.31,function()
            pcall(function() toast:Destroy() end)
            for i,t2 in toastStack do if t2==toast then table.remove(toastStack,i); break end end
        end)
    end)
end

-- PLAYERLIST UI
local wlSec=Menu:CreateSection(tWhitelist,"Player List")
local wlRows={}

-- Spectate
local spectateTarget=nil
local spectateConn=nil
local spectateGui=Instance.new("ScreenGui")
spectateGui.Name=rname("spec"); spectateGui.ResetOnSpawn=false
spectateGui.IgnoreGuiInset=true; spectateGui.DisplayOrder=15
parentGui(spectateGui)
local specLabel=Instance.new("TextLabel",spectateGui)
specLabel.Size=UDim2.fromOffset(300,28); specLabel.Position=UDim2.new(0.5,-150,0,12)
specLabel.BackgroundColor3=Color3.fromRGB(10,10,14); specLabel.BackgroundTransparency=0.3
specLabel.Text=""; specLabel.Font=Enum.Font.GothamBold; specLabel.TextSize=15
specLabel.TextColor3=Config.Accent; specLabel.BorderSizePixel=0; specLabel.Visible=false; specLabel.ZIndex=15
Instance.new("UICorner",specLabel).CornerRadius=UDim.new(0,8)
local specStroke=Instance.new("UIStroke",specLabel); specStroke.Color=Config.Accent; specStroke.Thickness=1; specStroke.Transparency=0.5

local function stopSpectate()
    if spectateConn then spectateConn:Disconnect(); spectateConn=nil end
    spectateTarget=nil
    specLabel.Visible=false
    -- (comment)
    pcall(function()
        Camera.CameraSubject=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        Camera.CameraType=Enum.CameraType.Custom
    end)
    rebuildPlayerListUI()
end

local function startSpectate(player)
    if spectateTarget then stopSpectate() end
    spectateTarget=player
    specLabel.Visible=true
    specLabel.Text="[*]  Spectating: "..player.DisplayName.." (@"..player.Name..")"
    -- (comment)
    spectateConn=RunService.RenderStepped:Connect(function()
        if not spectateTarget or not spectateTarget.Parent then stopSpectate(); return end
        local char=spectateTarget.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not hrp then return end
        pcall(function()
            Camera.CameraSubject=hum
            Camera.CameraType=Enum.CameraType.Custom
        end)
    end)
    rebuildPlayerListUI()
end

function rebuildPlayerListUI()
    for _,r in wlRows do if r and r.Parent then r:Destroy() end end
    table.clear(wlRows)
    for _,ply in Players:GetPlayers() do
        if ply==LocalPlayer then continue end
        local isWL=_G.Whitelist[ply.UserId]==true
        local isSpec=spectateTarget==ply
        local row=Instance.new("Frame",wlSec.Card)
        row.Size=UDim2.new(1,0,0,36); row.BackgroundTransparency=1; row.BorderSizePixel=0; row.ZIndex=3
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        -- dot
        local dot=Instance.new("Frame",row)
        dot.Size=UDim2.fromOffset(8,8); dot.Position=UDim2.new(0,0,0.5,-4)
        dot.BackgroundColor3=isWL and Color3.fromRGB(80,220,100) or Color3.fromRGB(220,80,80)
        dot.BorderSizePixel=0; dot.ZIndex=4
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        -- (comment)
        local lbl=Instance.new("TextLabel",row)
        lbl.Size=UDim2.new(1,-196,1,0); lbl.Position=UDim2.fromOffset(16,0)
        lbl.Text=ply.DisplayName.." (@"..ply.Name..")"
        lbl.Font=Enum.Font.Gotham; lbl.TextSize=15
        lbl.TextColor3=isWL and Color3.fromRGB(80,220,100) or Config.White
        lbl.BackgroundTransparency=1; lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.TextTruncate=Enum.TextTruncate.AtEnd; lbl.ZIndex=4
        --  Spectate
        local specBtn=Instance.new("TextButton",row)
        specBtn.Size=UDim2.fromOffset(80,26); specBtn.Position=UDim2.new(1,-186,0.5,-13)
        specBtn.Text=isSpec and "Stop" or "Spectate"
        specBtn.Font=Enum.Font.GothamBold; specBtn.TextSize=13
        specBtn.BackgroundColor3=isSpec and Color3.fromRGB(200,80,80) or Color3.fromRGB(60,120,200)
        specBtn.TextColor3=Config.White; specBtn.AutoButtonColor=false; specBtn.ZIndex=4
        Instance.new("UICorner",specBtn).CornerRadius=UDim.new(0,7)
        specBtn.MouseButton1Click:Connect(function()
            if isSpec then stopSpectate() else startSpectate(ply) end
        end)
        specBtn.MouseEnter:Connect(function() tween(specBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.3}) end)
        specBtn.MouseLeave:Connect(function() tween(specBtn,TweenInfo.new(0.15),{BackgroundTransparency=0}) end)
        --  Whitelist
        local wlBtn=Instance.new("TextButton",row)
        wlBtn.Size=UDim2.fromOffset(90,26); wlBtn.Position=UDim2.new(1,-90,0.5,-13)
        wlBtn.Text=isWL and "Remove" or "Add WL"
        wlBtn.Font=Enum.Font.GothamBold; wlBtn.TextSize=13
        wlBtn.BackgroundColor3=isWL and Color3.fromRGB(60,160,80) or Config.Accent
        wlBtn.TextColor3=Config.White; wlBtn.AutoButtonColor=false; wlBtn.ZIndex=4
        Instance.new("UICorner",wlBtn).CornerRadius=UDim.new(0,7)
        local uid=ply.UserId
        wlBtn.MouseButton1Click:Connect(function()
            if _G.Whitelist[uid] then _G.Whitelist[uid]=nil else _G.Whitelist[uid]=true end
            rebuildPlayerListUI()
        end)
        wlBtn.MouseEnter:Connect(function() tween(wlBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.3}) end)
        wlBtn.MouseLeave:Connect(function() tween(wlBtn,TweenInfo.new(0.15),{BackgroundTransparency=0}) end)
        wlRows[#wlRows+1]=row
    end
    if #wlRows==0 then
        local empty=Instance.new("TextLabel",wlSec.Card)
        empty.Size=UDim2.new(1,0,0,28); empty.BackgroundTransparency=1
        empty.Text="No players in session"; empty.Font=Enum.Font.Gotham; empty.TextSize=14
        empty.TextColor3=Color3.fromRGB(110,110,130); empty.TextXAlignment=Enum.TextXAlignment.Left
        empty.ZIndex=3; wlRows[#wlRows+1]=empty
    end
end

wlSec:AddButton("Refresh Player List",function() rebuildPlayerListUI() end)

-- кнопки массового вайтлиста в одну строку
local wlBulkRow=Instance.new("Frame",wlSec.Card)
wlBulkRow.Size=UDim2.new(1,0,0,32); wlBulkRow.BackgroundTransparency=1; wlBulkRow.ZIndex=3
local wlBulkList=Instance.new("UIListLayout",wlBulkRow)
wlBulkList.FillDirection=Enum.FillDirection.Horizontal; wlBulkList.Padding=UDim.new(0,8)

local function makeBulkBtn(parent,text,bg,cb)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.fromOffset(140,32); b.BackgroundColor3=bg
    b.Text=text; b.Font=Enum.Font.GothamBold; b.TextSize=13
    b.TextColor3=Color3.fromRGB(255,255,255); b.AutoButtonColor=false; b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.MouseEnter:Connect(function() tween(b,TweenInfo.new(0.12),{BackgroundTransparency=0.25}) end)
    b.MouseLeave:Connect(function() tween(b,TweenInfo.new(0.15),{BackgroundTransparency=0}) end)
    b.MouseButton1Click:Connect(function() pcall(cb); rebuildPlayerListUI() end)
    return b
end

makeBulkBtn(wlBulkRow,"WL All",Color3.fromRGB(40,130,70),function()
    for _,ply in Players:GetPlayers() do
        if ply~=LocalPlayer then _G.Whitelist[ply.UserId]=true end
    end
    showToast("All players whitelisted",Color3.fromRGB(80,220,130))
end)

makeBulkBtn(wlBulkRow,"Remove All WL",Color3.fromRGB(140,40,40),function()
    table.clear(_G.Whitelist)
    showToast("Whitelist cleared",Color3.fromRGB(220,80,80))
end)

rebuildPlayerListUI()

Players.PlayerAdded:Connect(function() task.wait(1); rebuildPlayerListUI() end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    if spectateTarget and not spectateTarget.Parent then stopSpectate() end
    rebuildPlayerListUI()
end)

local trigSec=Menu:CreateSection(tCombat,"Trigger Bot")
-- реестр UI контролов для applyConfig
local uiControls = {}

local trigEntry=trigSec:AddToggle("Trigger",false,function(v) Settings.TriggerBot=v end); trigEntry.hudOnlyWhenActive=true
uiControls.TriggerBot = trigEntry
uiControls.TriggerDelay = trigSec:AddSlider("Shot Reaction Delay (ms)",0,1000,0,function(v) Settings.TriggerDelay=v/1000 end)
uiControls.TriggerDist = trigSec:AddSlider("Activation Distance (Studs)",50,1500,500,function(v) Settings.TriggerDist=v end)
uiControls.KnifeCheck = trigSec:AddToggle("Knife Check (no fire with knife)",true,function(v) Settings.KnifeCheck=v end)
trigSec:AddToggle("Ignore Crew/Teammates",false,function(v) _G.CrewCheck=v end)
trigSec:AddToggle("Ignore Global Friends",false,function(v) _G.FriendCheck=v end)

local hbSec=Menu:CreateSection(tCombat,"Hitboxes")
uiControls.HitboxEnabled = hbSec:AddToggle("Enable Hitboxes",false,function(v) Settings.HitboxEnabled=v end)
uiControls.HitboxSize = hbSec:AddSlider("Hitbox Size",1,30,8,function(v) Settings.HitboxSize=v end)
uiControls.HitboxTransparency = hbSec:AddSlider("Box Transparency",0,100,50,function(v) Settings.HitboxTransparency=v/100 end)


-- FAKELAG
local flSec=Menu:CreateSection(tCombat,"Fake Lag")
Settings.FakeLag=false

local fakeLagThread=nil
local fakeLagWaitTime=0.05
local fakeLagDelayTime=0.4

local function stopFakeLag()
    if fakeLagThread then
        task.cancel(fakeLagThread)
        fakeLagThread=nil
    end
    pcall(function()
        local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored=false end
    end)
end

local function startFakeLag()
    stopFakeLag()
    fakeLagThread=task.spawn(function()
        while Settings.FakeLag and not Settings.Unloaded do
            task.wait(fakeLagWaitTime)
            if not Settings.FakeLag then break end
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Anchored=true
                task.wait(fakeLagDelayTime)
                hrp.Anchored=false
            end
        end
    end)
end

uiControls.FakeLag = flSec:AddToggle("Enable Fake Lag",false,function(v)
    Settings.FakeLag=v
    if v then startFakeLag() else stopFakeLag() end
end)
uiControls.FakeLagDelay = flSec:AddSlider("Lag Duration (ms)",100,3000,400,function(v)
    fakeLagDelayTime=v/1000
end)
uiControls.FakeLagInterval = flSec:AddSlider("Lag Interval (ms)",50,2000,50,function(v)
    fakeLagWaitTime=v/1000
end)

local espSec=Menu:CreateSection(tVisuals,"ESP Rendering")
uiControls.ESP_Enabled = espSec:AddToggle("Master ESP Switch",false,function(v) Settings.ESP_Enabled=v end)
uiControls.Box = espSec:AddToggle("2D Square Boxes",false,function(v) Settings.Box=v end)
uiControls.HealthBar = espSec:AddToggle("Vertical Health Bar",false,function(v) Settings.HealthBar=v end)
uiControls.Names = espSec:AddToggle("Player Names",false,function(v) Settings.Names=v end)
uiControls.Distance = espSec:AddToggle("Distance Label",false,function(v) Settings.Distance=v end)
uiControls.Tracers = espSec:AddToggle("Tracers",false,function(v) Settings.Tracers=v end)
uiControls.MaxDistance = espSec:AddSlider("Max Render Distance",100,5000,2500,function(v) Settings.MaxDistance=v end)

-- KEYBIND HUD
local BindHud=Instance.new("ScreenGui"); BindHud.Name=rname("hud"); BindHud.ResetOnSpawn=false
BindHud.IgnoreGuiInset=true; BindHud.DisplayOrder=20; parentGui(BindHud)
local hudEnabled=false
local hudFrame=Instance.new("Frame",BindHud)
hudFrame.Size=UDim2.fromOffset(240,0); hudFrame.AutomaticSize=Enum.AutomaticSize.Y
hudFrame.Position=UDim2.fromOffset(20,200); hudFrame.BackgroundColor3=Color3.fromRGB(10,10,14)
hudFrame.BackgroundTransparency=0.2; hudFrame.BorderSizePixel=0; hudFrame.ZIndex=10; hudFrame.Visible=false
Instance.new("UICorner",hudFrame).CornerRadius=UDim.new(0,12)
local hudStroke=Instance.new("UIStroke",hudFrame); hudStroke.Color=Config.Accent; hudStroke.Thickness=1; hudStroke.Transparency=0.45; trackAccent(hudStroke)
local hudPad=Instance.new("UIPadding",hudFrame)
hudPad.PaddingLeft=UDim.new(0,12); hudPad.PaddingRight=UDim.new(0,12)
hudPad.PaddingTop=UDim.new(0,10); hudPad.PaddingBottom=UDim.new(0,10)
local hudList=Instance.new("UIListLayout",hudFrame); hudList.Padding=UDim.new(0,4); hudList.SortOrder=Enum.SortOrder.LayoutOrder
local hudTitle=Instance.new("TextLabel",hudFrame)
hudTitle.LayoutOrder=0; hudTitle.Size=UDim2.new(1,0,0,22); hudTitle.Text="[*]  KEYBINDS"
hudTitle.Font=Enum.Font.GothamBlack; hudTitle.TextSize=22
hudTitle.TextColor3=Config.Accent; hudTitle.BackgroundTransparency=1
hudTitle.TextXAlignment=Enum.TextXAlignment.Left; hudTitle.ZIndex=10; trackAccent(hudTitle)
local hudDivider=Instance.new("Frame",hudFrame)
hudDivider.LayoutOrder=1; hudDivider.Size=UDim2.new(1,0,0,1)
hudDivider.BackgroundColor3=Config.Accent; hudDivider.BackgroundTransparency=0.7
hudDivider.BorderSizePixel=0; hudDivider.ZIndex=10; trackAccent(hudDivider)
local hudNoBinds=Instance.new("TextLabel",hudFrame)
hudNoBinds.LayoutOrder=2; hudNoBinds.Size=UDim2.new(1,0,0,18); hudNoBinds.Text="No binds set"
hudNoBinds.Font=Enum.Font.Gotham; hudNoBinds.TextSize=20
hudNoBinds.TextColor3=Color3.fromRGB(110,110,120); hudNoBinds.BackgroundTransparency=1
hudNoBinds.TextXAlignment=Enum.TextXAlignment.Left; hudNoBinds.ZIndex=10


local hudRowOrder=100
local function rebuildHud()
    for _,r in hudRowMap do if r.frame and r.frame.Parent then r.frame:Destroy() end end
    table.clear(hudRowMap)
    local hasAny=false; hudRowOrder=100
    for _,entry in featureBinds do
        if not entry.key then continue end
        if entry.hudOnlyWhenActive and not entry.state then continue end
        hasAny=true
        --  layout:  ,     
        local row=Instance.new("Frame",hudFrame)
        row.LayoutOrder=hudRowOrder; hudRowOrder=hudRowOrder+1
        row.Size=UDim2.new(1,0,0,36); row.BackgroundTransparency=1; row.ZIndex=10
        --     ,  
        local nameLbl=Instance.new("TextLabel",row)
        nameLbl.Size=UDim2.new(1,0,0,18)
        nameLbl.Position=UDim2.fromOffset(0,0)
        nameLbl.Text=bindNames[entry] or "?"
        nameLbl.Font=Enum.Font.Gotham; nameLbl.TextSize=20
        nameLbl.TextColor3=Color3.fromRGB(210,210,225); nameLbl.BackgroundTransparency=1
        nameLbl.TextXAlignment=Enum.TextXAlignment.Left
        nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
        nameLbl.ZIndex=10
        --    ,  
        local keyStr=tostring(entry.key):gsub("Enum%.KeyCode%.","")
        local keyLbl=Instance.new("TextLabel",row)
        keyLbl.Size=UDim2.new(1,0,0,16)
        keyLbl.Position=UDim2.fromOffset(0,19)
        keyLbl.Text="["..keyStr.."]"
        keyLbl.Font=Enum.Font.GothamBold; keyLbl.TextSize=18
        keyLbl.TextXAlignment=Enum.TextXAlignment.Left
        keyLbl.ZIndex=10
        hudRowMap[entry]={frame=row,keyLbl=keyLbl}
    end
    hudNoBinds.Visible=not hasAny
    tween(hudFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundTransparency=0.2})
end

local hudDragging,hudDStart,hudFStart=false,nil,nil
hudFrame.InputBegan:Connect(function(i)
    if not Menu.Main.Visible then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 then hudDragging=true; hudDStart=i.Position; hudFStart=hudFrame.Position end
end)
UserInputService.InputChanged:Connect(function(i)
    if hudDragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-hudDStart
        hudFrame.Position=UDim2.new(hudFStart.X.Scale,hudFStart.X.Offset+d.X,hudFStart.Y.Scale,hudFStart.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hudDragging=false end end)

local settSec=Menu:CreateSection(tSettings,"Interface")
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

local themeNames={"Orange","Purple","Cyan","Red","Rose","Emerald","Gold","Ice","Sakura","Void"}
local themeIdx=1
local themeDropOpen=false
local themeDropFrame=nil

local function closeThemeDrop()
    if themeDropFrame and themeDropFrame.Parent then
        tween(themeDropFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size=UDim2.fromOffset(200,0),BackgroundTransparency=1})
        task.delay(0.21,function() if themeDropFrame and themeDropFrame.Parent then themeDropFrame:Destroy(); themeDropFrame=nil end end)
        themeDropOpen=false
    end
end

local themeAccentDots={
    Orange=Color3.fromRGB(255,157,19),  Purple=Color3.fromRGB(170,100,255),
    Cyan=Color3.fromRGB(60,210,230),    Red=Color3.fromRGB(235,75,75),
    Rose=Color3.fromRGB(255,100,160),   Emerald=Color3.fromRGB(50,220,130),
    Gold=Color3.fromRGB(255,210,50),    Ice=Color3.fromRGB(140,200,255),
    Sakura=Color3.fromRGB(255,160,200), Void=Color3.fromRGB(120,80,255),
}

local function applyThemeAndRecolor(n)
    applyTheme(n); recolorAll()
    if Menu.Main and Menu.Main.Parent then Menu.Main.BackgroundColor3=Config.MainBg end
    if Menu.Sidebar and Menu.Sidebar.Parent then Menu.Sidebar.BackgroundColor3=Config.SidebarBg end
    for _,tab in Menu.Tabs do
        for _,card in tab:GetChildren() do if card:IsA("Frame") then card.BackgroundColor3=Config.CardBg end end
    end
end

local themeBtn; themeBtn=settSec:AddButton("Theme  Orange",function()
    if themeDropFrame and themeDropFrame.Parent then
        closeThemeDrop(); return
    end
    themeDropOpen=true
    local dropW=200; local itemH=34
    local dropF=Instance.new("Frame",Menu.SG)
    dropF.Size=UDim2.fromOffset(dropW,0)
    dropF.Position=UDim2.fromOffset(themeBtn.AbsolutePosition.X,themeBtn.AbsolutePosition.Y+themeBtn.AbsoluteSize.Y+4)
    dropF.BackgroundColor3=Config.CardBg; dropF.BorderSizePixel=0; dropF.ZIndex=50
    dropF.ClipsDescendants=true
    Instance.new("UICorner",dropF).CornerRadius=UDim.new(0,10)
    local dStroke=Instance.new("UIStroke",dropF); dStroke.Color=Config.Accent; dStroke.Thickness=1.2; dStroke.Transparency=0.4
    local dList=Instance.new("UIListLayout",dropF); dList.Padding=UDim.new(0,2)
    local dPad=Instance.new("UIPadding",dropF)
    dPad.PaddingTop=UDim.new(0,4); dPad.PaddingBottom=UDim.new(0,4)
    dPad.PaddingLeft=UDim.new(0,4); dPad.PaddingRight=UDim.new(0,4)
    themeDropFrame=dropF
    for idx,name in themeNames do
        local row=Instance.new("TextButton",dropF)
        row.Size=UDim2.new(1,0,0,itemH); row.BackgroundTransparency=1
        row.Text=""; row.AutoButtonColor=false; row.ZIndex=51
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
        local dot=Instance.new("Frame",row)
        dot.Size=UDim2.fromOffset(10,10); dot.Position=UDim2.new(0,8,0.5,-5)
        dot.BackgroundColor3=themeAccentDots[name] or Config.Accent
        dot.BorderSizePixel=0; dot.ZIndex=52
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local lbl=Instance.new("TextLabel",row)
        lbl.Size=UDim2.new(1,-28,1,0); lbl.Position=UDim2.fromOffset(26,0)
        lbl.Text=name; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=15
        lbl.TextColor3=name==currentThemeName and Config.Accent or Color3.fromRGB(200,200,215)
        lbl.BackgroundTransparency=1; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=52
        if name==currentThemeName then
            row.BackgroundTransparency=0.75; row.BackgroundColor3=Config.Accent
        end
        row.MouseEnter:Connect(function()
            if name~=currentThemeName then
                tween(row,TweenInfo.new(0.12,Enum.EasingStyle.Quint),{BackgroundTransparency=0.82,BackgroundColor3=Config.Accent})
                tween(lbl,TweenInfo.new(0.12),{TextColor3=Config.White})
            end
        end)
        row.MouseLeave:Connect(function()
            if name~=currentThemeName then
                tween(row,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{BackgroundTransparency=1})
                tween(lbl,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(200,200,215)})
            end
        end)
        row.MouseButton1Click:Connect(function()
            themeIdx=idx
            applyThemeAndRecolor(name)
            if themeBtn and themeBtn.Parent then themeBtn.Text="Theme: "..name end
            for _,ch in dropF:GetChildren() do
                if ch:IsA("TextButton") then
                    local cl=ch:FindFirstChildOfClass("TextLabel")
                    if cl then
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
-- ============ CONFIG SYSTEM ============
local cfgFolder = "elysium_configs"
pcall(function() if not isfolder(cfgFolder) then makefolder(cfgFolder) end end)

local CFG_KEYS = {
    "TriggerBot","TriggerDelay","TriggerDist","KnifeCheck",
    "ESP_Enabled","Box","HealthBar","Names","Distance","Tracers","MaxDistance",
    "HitboxEnabled","HitboxSize","HitboxTransparency","FakeLag",
}

local function serializeConfig()
    local t = {}
    for _,k in CFG_KEYS do t[k] = Settings[k] end
    t.__theme = currentThemeName
    local parts = {}
    for k,v in t do
        local vs
        if type(v)=="boolean" then vs = v and "true" or "false"
        elseif type(v)=="number" then vs = tostring(v)
        elseif type(v)=="string" then vs = '"'..v..'"'
        end
        if vs then parts[#parts+1] = k.."="..vs end
    end
    return table.concat(parts, ";")
end

local function deserializeConfig(str)
    local t = {}
    for pair in str:gmatch("[^;]+") do
        local k,v = pair:match("^(.-)=(.+)$")
        if k and v then
            if v=="true" then t[k]=true
            elseif v=="false" then t[k]=false
            elseif v:sub(1,1)=='"' then t[k]=v:sub(2,-2)
            else t[k]=tonumber(v) end
        end
    end
    return t
end

local function applyConfig(data)
    for _,k in CFG_KEYS do
        if data[k]~=nil then Settings[k]=data[k] end
    end
    if data.__theme and Themes[data.__theme] then
        applyThemeAndRecolor(data.__theme)
        if themeBtn and themeBtn.Parent then themeBtn.Text="Theme: "..data.__theme end
    end
    -- синхронизируем UI если контролы уже созданы
    if uiControls then
        -- тоглы: entry.callback(v) обновляет и UI и Settings
        local toggleKeys = {"TriggerBot","KnifeCheck","HitboxEnabled","FakeLag","ESP_Enabled","Box","HealthBar","Names","Distance","Tracers"}
        for _,k in toggleKeys do
            if data[k]~=nil and uiControls[k] and uiControls[k].callback then
                uiControls[k].callback(data[k])
            end
        end
        -- слайдеры: SetValue(v) — значения в "сырых" единицах UI
        local sliderMap = {
            -- ключ Settings -> {uiKey, uiValue}
            TriggerDelay = {"TriggerDelay", (data.TriggerDelay or 0)*1000},
            TriggerDist  = {"TriggerDist",  data.TriggerDist},
            HitboxSize   = {"HitboxSize",   data.HitboxSize},
            HitboxTransparency = {"HitboxTransparency", (data.HitboxTransparency or 0.5)*100},
            MaxDistance  = {"MaxDistance",  data.MaxDistance},
        }
        for _,info in sliderMap do
            local uiKey, uiVal = info[1], info[2]
            if uiVal~=nil and uiControls[uiKey] and uiControls[uiKey].SetValue then
                uiControls[uiKey].SetValue(uiVal)
            end
        end
    end
end

local function listConfigs()
    local files = {}
    pcall(function()
        for _,f in listfiles(cfgFolder) do
            local name = f:match("[/\\]([^/\\]+)%.cfg$")
            if name then files[#files+1] = name end
        end
    end)
    return files
end

-- ===== CONFIGS TAB UI =====
local cfgListSec = Menu:CreateSection(tConfigs, "Configs")

-- TextBox для имени
local cfgNameRow = Instance.new("Frame", cfgListSec.Card)
cfgNameRow.Size = UDim2.new(1,0,0,34); cfgNameRow.BackgroundTransparency=1; cfgNameRow.ZIndex=3
local cfgBox = Instance.new("TextBox", cfgNameRow)
cfgBox.Size = UDim2.new(1,0,1,0); cfgBox.BackgroundColor3 = Color3.fromRGB(22,22,30)
cfgBox.Text = "default"; cfgBox.Font = Enum.Font.Gotham; cfgBox.TextSize = 15
cfgBox.TextColor3 = Config.White; cfgBox.PlaceholderText = "Config name..."
cfgBox.PlaceholderColor3 = Color3.fromRGB(90,90,110)
cfgBox.BorderSizePixel = 0; cfgBox.ZIndex = 4; cfgBox.ClearTextOnFocus = false
Instance.new("UICorner", cfgBox).CornerRadius = UDim.new(0,8)
local cfgBoxStroke = Instance.new("UIStroke", cfgBox); cfgBoxStroke.Color = Config.Stroke

-- Кнопки Save / Refresh в одну строку
local btnRow = Instance.new("Frame", cfgListSec.Card)
btnRow.Size = UDim2.new(1,0,0,32); btnRow.BackgroundTransparency=1; btnRow.ZIndex=3
local btnList = Instance.new("UIListLayout", btnRow)
btnList.FillDirection = Enum.FillDirection.Horizontal; btnList.Padding = UDim.new(0,6)

local function makeCfgBtn(parent, text, w, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.fromOffset(w,32); b.BackgroundColor3 = Config.ToggleOff
    b.Text = text; b.Font = Enum.Font.GothamBold; b.TextSize = 13
    b.TextColor3 = Config.White; b.AutoButtonColor = false; b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseEnter:Connect(function() tween(b,TweenInfo.new(0.13),{BackgroundColor3=Config.Accent}) end)
    b.MouseLeave:Connect(function() tween(b,TweenInfo.new(0.15),{BackgroundColor3=Config.ToggleOff}) end)
    b.MouseButton1Click:Connect(function() pcall(cb) end)
    return b
end

local rebuildCfgList  -- forward declare

makeCfgBtn(btnRow, "Save", 80, function()
    local name = cfgBox.Text:gsub("[^%w_%-]","_")
    if name=="" then name="default" end
    pcall(function() writefile(cfgFolder.."/"..name..".cfg", serializeConfig()) end)
    rebuildCfgList()
    showToast("Config saved: "..name, Color3.fromRGB(80,220,130))
end)

makeCfgBtn(btnRow, "Refresh", 90, function()
    rebuildCfgList()
end)

-- Export/Import строка
local exportBox = Instance.new("TextBox", cfgListSec.Card)
exportBox.Size = UDim2.new(1,0,0,30); exportBox.BackgroundColor3 = Color3.fromRGB(16,16,22)
exportBox.Text = ""; exportBox.Font = Enum.Font.Gotham; exportBox.TextSize = 12
exportBox.TextColor3 = Color3.fromRGB(180,220,180); exportBox.PlaceholderText = "Paste import string here / export appears here"
exportBox.PlaceholderColor3 = Color3.fromRGB(80,80,100)
exportBox.BorderSizePixel = 0; exportBox.ZIndex = 4; exportBox.ClearTextOnFocus = false
exportBox.TextTruncate = Enum.TextTruncate.AtEnd
Instance.new("UICorner", exportBox).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", exportBox).Color = Config.Stroke

local expRow = Instance.new("Frame", cfgListSec.Card)
expRow.Size = UDim2.new(1,0,0,32); expRow.BackgroundTransparency=1; expRow.ZIndex=3
local expList = Instance.new("UIListLayout", expRow)
expList.FillDirection = Enum.FillDirection.Horizontal; expList.Padding = UDim.new(0,6)

makeCfgBtn(expRow, "Export", 80, function()
    exportBox.Text = serializeConfig()
    exportBox:CaptureFocus(); exportBox:ReleaseFocus()
end)
makeCfgBtn(expRow, "Import", 80, function()
    local str = exportBox.Text
    if str and #str > 4 then applyConfig(deserializeConfig(str)) end
end)

-- Разделитель "Saved Configs"
local listHeader = Instance.new("TextLabel", cfgListSec.Card)
listHeader.Size = UDim2.new(1,0,0,20); listHeader.BackgroundTransparency=1
listHeader.Text = "SAVED CONFIGS"; listHeader.Font = Enum.Font.GothamBold; listHeader.TextSize = 12
listHeader.TextColor3 = Color3.fromRGB(110,110,130); listHeader.TextXAlignment = Enum.TextXAlignment.Left
listHeader.ZIndex = 3

-- Контейнер для списка конфигов
local cfgListFrame = Instance.new("Frame", cfgListSec.Card)
cfgListFrame.Size = UDim2.new(1,0,0,0); cfgListFrame.AutomaticSize = Enum.AutomaticSize.Y
cfgListFrame.BackgroundTransparency = 1; cfgListFrame.ZIndex = 3
local cfgListLayout = Instance.new("UIListLayout", cfgListFrame)
cfgListLayout.Padding = UDim.new(0,4); cfgListLayout.SortOrder = Enum.SortOrder.Name

local cfgRows = {}

rebuildCfgList = function()
    for _,r in cfgRows do if r and r.Parent then r:Destroy() end end
    table.clear(cfgRows)

    local configs = listConfigs()

    if #configs == 0 then
        local empty = Instance.new("TextLabel", cfgListFrame)
        empty.Size = UDim2.new(1,0,0,26); empty.BackgroundTransparency=1
        empty.Text = "No saved configs"; empty.Font = Enum.Font.Gotham; empty.TextSize = 13
        empty.TextColor3 = Color3.fromRGB(90,90,110); empty.TextXAlignment = Enum.TextXAlignment.Left
        empty.ZIndex = 3; cfgRows[#cfgRows+1] = empty
        return
    end

    for _,cfgName in configs do
        local row = Instance.new("Frame", cfgListFrame)
        row.Size = UDim2.new(1,0,0,34); row.BackgroundColor3 = Color3.fromRGB(20,20,28)
        row.BorderSizePixel = 0; row.ZIndex = 3
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
        local rowStroke = Instance.new("UIStroke", row); rowStroke.Color = Config.Stroke; rowStroke.Transparency = 0.5

        -- иконка файла
        local icon = Instance.new("TextLabel", row)
        icon.Size = UDim2.fromOffset(20,34); icon.Position = UDim2.fromOffset(8,0)
        icon.Text = "📄"; icon.Font = Enum.Font.Gotham; icon.TextSize = 14
        icon.BackgroundTransparency = 1; icon.ZIndex = 4

        -- имя конфига
        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.Size = UDim2.new(1,-160,1,0); nameLbl.Position = UDim2.fromOffset(30,0)
        nameLbl.Text = cfgName; nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 14
        nameLbl.TextColor3 = Config.White; nameLbl.BackgroundTransparency = 1
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.ZIndex = 4

        -- кнопка Load
        local loadBtn = Instance.new("TextButton", row)
        loadBtn.Size = UDim2.fromOffset(56,24); loadBtn.Position = UDim2.new(1,-122,0.5,-12)
        loadBtn.Text = "Load"; loadBtn.Font = Enum.Font.GothamBold; loadBtn.TextSize = 13
        loadBtn.BackgroundColor3 = Color3.fromRGB(40,100,60); loadBtn.TextColor3 = Config.White
        loadBtn.AutoButtonColor = false; loadBtn.ZIndex = 4
        Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0,6)
        loadBtn.MouseEnter:Connect(function() tween(loadBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(60,160,90)}) end)
        loadBtn.MouseLeave:Connect(function() tween(loadBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(40,100,60)}) end)
        loadBtn.MouseButton1Click:Connect(function()
            local ok, data = pcall(function() return readfile(cfgFolder.."/"..cfgName..".cfg") end)
            if ok and data then
                applyConfig(deserializeConfig(data))
                cfgBox.Text = cfgName
                tween(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(30,60,38)})
                -- shine точно по строке конфига
                task.defer(function()
                    if row and row.Parent then
                        doShine(row, row.AbsoluteSize.X, row.AbsoluteSize.Y, 5)
                        doPulseRing(row, row.AbsoluteSize.X/2, row.AbsoluteSize.Y/2, Color3.fromRGB(80,220,130), 18)
                    end
                end)
                task.delay(0.5,function() if row and row.Parent then tween(row,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{BackgroundColor3=Color3.fromRGB(20,20,28)}) end end)
                showToast("Loaded: "..cfgName, Color3.fromRGB(80,180,255))
            else
                tween(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(60,20,20)})
                task.delay(0.4,function() if row and row.Parent then tween(row,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(20,20,28)}) end end)
                showToast("Failed to load config", Color3.fromRGB(220,80,80))
            end
        end)

        -- кнопка Delete
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.fromOffset(56,24); delBtn.Position = UDim2.new(1,-60,0.5,-12)
        delBtn.Text = "Delete"; delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 13
        delBtn.BackgroundColor3 = Color3.fromRGB(90,30,30); delBtn.TextColor3 = Config.White
        delBtn.AutoButtonColor = false; delBtn.ZIndex = 4
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,6)
        delBtn.MouseEnter:Connect(function() tween(delBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(180,50,50)}) end)
        delBtn.MouseLeave:Connect(function() tween(delBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(90,30,30)}) end)
        delBtn.MouseButton1Click:Connect(function()
            -- анимация удаления: slide out + fade
            tween(row,TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)})
            task.delay(0.19,function()
                pcall(function() delfile(cfgFolder.."/"..cfgName..".cfg") end)
                showToast("Deleted: "..cfgName, Color3.fromRGB(220,80,80))
                rebuildCfgList()
            end)
        end)

        -- hover на строке
        row.MouseEnter:Connect(function()
            tween(rowStroke,TweenInfo.new(0.15),{Color=Config.Accent,Transparency=0.4})
            tween(nameLbl,TweenInfo.new(0.15),{TextColor3=Config.Accent})
        end)
        row.MouseLeave:Connect(function()
            tween(rowStroke,TweenInfo.new(0.2),{Color=Config.Stroke,Transparency=0.5})
            tween(nameLbl,TweenInfo.new(0.2),{TextColor3=Config.White})
        end)

        cfgRows[#cfgRows+1] = row
        -- stagger появление
        local idx = #cfgRows
        row.BackgroundTransparency = 1
        row.Position = UDim2.new(row.Position.X.Scale, row.Position.X.Offset, row.Position.Y.Scale, row.Position.Y.Offset + 12)
        task.delay((idx-1)*0.04, function()
            if not row or not row.Parent then return end
            tween(row, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0,
                Position = UDim2.new(row.Position.X.Scale, row.Position.X.Offset, row.Position.Y.Scale, row.Position.Y.Offset - 12)
            })
        end)
    end
end

rebuildCfgList()
-- ============ END CONFIG SYSTEM ============

settSec:AddButton("Unload Script",function()
    Settings.Unloaded=true
    for _,c in connections do pcall(function() c:Disconnect() end) end
    table.clear(connections)
    for _,gui in {EspGui,BindHud,BlurGui,HitboxGui,Menu.SG} do safeDestroy(gui) end
end)


-- (comment)
local starList={}
local function spawnStar()
    local vp=Camera.ViewportSize
    local cx=math.random(0,math.floor(vp.X))
    local s=Instance.new("Frame",Menu.StarBg)
    s.Size=UDim2.fromOffset(0,0); s.BackgroundTransparency=1
    s.Position=UDim2.fromOffset(cx,-12); s.BorderSizePixel=0; s.ZIndex=2
    local starType=math.random(1,3) -- 1=лучи, 2=точка, 3=хвост
    local sz=math.random(2,6); local alpha=math.random(35,80)/100
    local rays={}
    if starType==1 then
        -- классические лучи
        local rayCount=math.random(4,8)
        for i=1,rayCount do
            local ray=Instance.new("Frame",s)
            ray.AnchorPoint=Vector2.new(0.5,0.5)
            ray.Position=UDim2.fromOffset(0,0)
            ray.Size=UDim2.fromOffset(sz*2,1)
            ray.BackgroundColor3=Color3.fromRGB(
                math.random(180,255),
                math.random(200,255),
                math.random(220,255)
            )
            ray.BackgroundTransparency=1-alpha
            ray.BorderSizePixel=0; ray.ZIndex=2
            ray.Rotation=(i-1)*(360/rayCount)
            rays[i]=ray
        end
    elseif starType==2 then
        -- простая светящаяся точка
        local dot=Instance.new("Frame",s)
        dot.AnchorPoint=Vector2.new(0.5,0.5)
        dot.Position=UDim2.fromOffset(0,0)
        dot.Size=UDim2.fromOffset(sz,sz)
        dot.BackgroundColor3=Color3.fromRGB(200,220,255)
        dot.BackgroundTransparency=1-alpha
        dot.BorderSizePixel=0; dot.ZIndex=2
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        rays[1]=dot
    else
        -- хвост (вертикальная полоска)
        local tail=Instance.new("Frame",s)
        tail.AnchorPoint=Vector2.new(0.5,0)
        tail.Position=UDim2.fromOffset(0,0)
        tail.Size=UDim2.fromOffset(1,sz*4)
        tail.BackgroundColor3=Color3.fromRGB(180,210,255)
        tail.BackgroundTransparency=1-alpha*0.7
        tail.BorderSizePixel=0; tail.ZIndex=2
        Instance.new("UICorner",tail).CornerRadius=UDim.new(1,0)
        local tg=Instance.new("UIGradient",tail)
        tg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
        tg.Rotation=180
        rays[1]=tail
    end
    local entry={
        frame=s, rays=rays,
        x=cx, y=-12,
        speed=math.random(25,80),
        sway=math.random(5,35),
        swaySpeed=math.random(60,180)/100,
        rotSpeed=starType==1 and math.random(15,55) or 0,
        t=0, dead=false,
        -- мигание
        blinkT=math.random(0,100)/100,
        blinkSpeed=math.random(80,200)/100,
        baseAlpha=alpha,
    }
    starList[#starList+1]=entry
end
local lastStarSpawn=0
track(RunService.RenderStepped:Connect(function(dt)
    if not Menu or not Menu.StarBg then return end
    local ok,vis=pcall(function() return Menu.StarBg.Parent~=nil and Menu.StarBg.Visible end)
    if not ok or not vis then return end
    local vp=Camera.ViewportSize
    lastStarSpawn=lastStarSpawn+dt
    -- больше звёзд, чаще
    if lastStarSpawn>0.28 and #starList<28 then lastStarSpawn=0; spawnStar() end
    local i=1
    while i<=#starList do
        local e=starList[i]
        if e.dead or not e.frame.Parent then table.remove(starList,i); continue end
        e.t=e.t+dt; e.y=e.y+e.speed*dt
        e.blinkT=e.blinkT+dt*e.blinkSpeed
        -- мигание прозрачности
        local blinkAlpha=e.baseAlpha*(0.6+0.4*math.abs(math.sin(e.blinkT)))
        e.frame.Position=UDim2.fromOffset(e.x+math.sin(e.t*e.swaySpeed)*e.sway,e.y)
        for _,ray in e.rays do
            if ray.Parent then
                ray.Rotation=ray.Rotation+e.rotSpeed*dt
                ray.BackgroundTransparency=1-blinkAlpha
            end
        end
        if e.y>vp.Y+20 then e.dead=true; pcall(function() e.frame:Destroy() end); table.remove(starList,i); continue end
        i=i+1
    end
end))

-- shimmer + ambient stroke pulse
local shimmerFrameCount=0; local shimmerT=0
track(RunService.Heartbeat:Connect(function(dt)
    shimmerFrameCount=shimmerFrameCount+1; if shimmerFrameCount%5~=0 then return end
    shimmerT=shimmerT+dt*0.28
    -- плавное дыхание hue + небольшое дыхание saturation
    local h=(shimBaseH+math.sin(shimmerT*0.9)*0.05)%1
    local s=math.clamp(shimBaseS+math.sin(shimmerT*1.3)*0.04,0,1)
    local v=math.clamp(shimBaseV+math.sin(shimmerT*1.7)*0.03,0,1)
    Config.Accent=Color3.fromHSV(h,s,v)
    recolorAll()
    -- ambient pulse на stroke главного окна (каждые 30 тиков)
    if shimmerFrameCount%30==0 and Menu and Menu.MainStroke and Menu.MainStroke.Parent then
        local pulse=0.45+math.abs(math.sin(shimmerT*0.5))*0.15
        Menu.MainStroke.Transparency=pulse
    end
end))

-- cursor glow (throttled: каждые 5 кадров, только когда меню открыто)
local cursorGlow=Instance.new("Frame",Menu.SG)
cursorGlow.Size=UDim2.fromOffset(100,100); cursorGlow.AnchorPoint=Vector2.new(0.5,0.5)
cursorGlow.BackgroundColor3=Config.Accent; cursorGlow.BackgroundTransparency=1
cursorGlow.BorderSizePixel=0; cursorGlow.ZIndex=50; cursorGlow.Active=false
cursorGlow.Interactable=false
Instance.new("UICorner",cursorGlow).CornerRadius=UDim.new(1,0)
local cgGrad=Instance.new("UIGradient",cursorGlow)
cgGrad.Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,0.45),
    NumberSequenceKeypoint.new(0.6,0.75),
    NumberSequenceKeypoint.new(1,1)
})
trackAccent(cursorGlow)
-- второй слой glow (меньше, ярче)
local cursorGlow2=Instance.new("Frame",Menu.SG)
cursorGlow2.Size=UDim2.fromOffset(36,36); cursorGlow2.AnchorPoint=Vector2.new(0.5,0.5)
cursorGlow2.BackgroundColor3=Config.Accent; cursorGlow2.BackgroundTransparency=1
cursorGlow2.BorderSizePixel=0; cursorGlow2.ZIndex=51; cursorGlow2.Active=false
cursorGlow2.Interactable=false
Instance.new("UICorner",cursorGlow2).CornerRadius=UDim.new(1,0)
local cg2Grad=Instance.new("UIGradient",cursorGlow2)
cg2Grad.Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,0.3),
    NumberSequenceKeypoint.new(1,1)
})
trackAccent(cursorGlow2)
local cgFrame=0
local cgX,cgY=0,0  -- плавное следование
track(RunService.RenderStepped:Connect(function(dt)
    cgFrame=cgFrame+1; if cgFrame%3~=0 then return end
    local menuOpen=menuVisible and Menu and Menu.Main and Menu.Main.Visible
    if not menuOpen then
        cursorGlow.BackgroundTransparency=1
        cursorGlow2.BackgroundTransparency=1
        return
    end
    local mp=getMousePos()
    -- плавное следование (lerp)
    local spd=1-math.exp(-dt*3*3)  -- ~9 скорость
    cgX=cgX+(mp.X-cgX)*spd
    cgY=cgY+(mp.Y-cgY)*spd
    cursorGlow.Position=UDim2.fromOffset(cgX,cgY)
    cursorGlow.BackgroundColor3=Config.Accent
    cursorGlow.BackgroundTransparency=0.65
    -- второй слой точно на курсоре
    cursorGlow2.Position=UDim2.fromOffset(mp.X,mp.Y)
    cursorGlow2.BackgroundColor3=Config.Accent
    cursorGlow2.BackgroundTransparency=0.55
end))

-- (comment)
local menuVisible=true
track(UserInputService.InputBegan:Connect(function(i,gp)
    if gp or Settings.Unloaded then return end
    -- закрыть дропдаун при клике вне него
    if themeDropOpen and i.UserInputType==Enum.UserInputType.MouseButton1 then
        local mp=getMousePos()
        if themeDropFrame and themeDropFrame.Parent then
            local ap=themeDropFrame.AbsolutePosition
            local as=themeDropFrame.AbsoluteSize
            if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then
                closeThemeDrop()
            end
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
            e.cell.BackgroundColor3=Color3.fromRGB(60,200,100)
            e.cell.Size=UDim2.fromOffset(62,24)
            tween(e.cell,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(58,22)})
            task.delay(0.35,function()
                if e.cell and e.cell.Parent then
                    tween(e.cell,TweenInfo.new(0.25),{BackgroundColor3=Config.ToggleOff})
                end
            end)
        end
        if hudEnabled then rebuildHud() end; return
    end
    if i.KeyCode==Settings.MenuKey then menuVisible=not menuVisible; Menu:SetVisible(menuVisible); return end
    if menuVisible then return end
    for _,entry in featureBinds do
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

local trigCooldown=0
track(RunService.Heartbeat:Connect(function(dt)
    if Settings.Unloaded or not Settings.TriggerBot or menuVisible then return end
    if Settings.KnifeCheck and isHoldingKnife() then return end
    trigCooldown=trigCooldown-dt
    if trigCooldown>0 then return end
    local mouse=LocalPlayer:GetMouse()
    local target=mouse.Target
    if target and canShoot(target) then
        local dist=(target.Position-Camera.CFrame.Position).Magnitude
        if dist<=Settings.TriggerDist then
            local char=target:FindFirstAncestorOfClass("Model")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 then
                local state=hum:GetState()
                local isKnocked=state==Enum.HumanoidStateType.Dead
                    or state==Enum.HumanoidStateType.FallingDown
                    or state==Enum.HumanoidStateType.Ragdoll
                    or hum.PlatformStand==true
                    or hum.Sit==true
                if not isKnocked then
                    local _e=getfenv(); pcall(_e[string.char(109,111,117,115,101,49,112,114,101,115,115)]); pcall(_e[string.char(109,111,117,115,101,49,114,101,108,101,97,115,101)])
                    trigCooldown=Settings.TriggerDelay+0.05
                end
            end
        end
    end
end))



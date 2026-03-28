--[[  elysium v6.2  ]]
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer

local SafeGui=nil
pcall(function() local _f=getfenv()[string.char(103,101,116,104,117,105)]; if typeof(_f)=="function" then SafeGui=_f() end end)
if not SafeGui then pcall(function() SafeGui=LocalPlayer:WaitForChild("PlayerGui") end) end
if not SafeGui then SafeGui=LocalPlayer:FindFirstChildOfClass("PlayerGui") end

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

_G.FriendCheck=false; _G.CrewCheck=false

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

-- Проверка: держит ли LocalPlayer нож
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
            -- это pill от тогла
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
pcall(function() BlurGui.Parent=SafeGui end)
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
    pcall(function() lib.SG.Parent=SafeGui end)
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
    tween(lib.Overlay,TweenInfo.new(0.4,Enum.EasingStyle.Quad),{BackgroundTransparency=0.5})
    tween(lib.Main,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0,0.28),{BackgroundTransparency=0,Size=UDim2.fromOffset(900,620),Position=UDim2.new(0.5,-450,0.5,-310)})
    task.delay(0.18,function()
        if not lib.Sidebar or not lib.Sidebar.Parent then return end
        tween(lib.Sidebar,TweenInfo.new(0.38,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
    end)
    task.delay(0.32,function()
        if not title or not title.Parent then return end
        tween(title,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{TextTransparency=0,TextStrokeTransparency=0.75})
        tween(subTitle,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{TextTransparency=0.3})
    end)
    task.delay(0.38,function()
        if not accentLine or not accentLine.Parent then return end
        tween(accentLine,TweenInfo.new(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(190,2)})
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
        self.Main.Size=UDim2.fromOffset(840,570); self.Main.Position=UDim2.new(0.5,-420,0.53,-285)
        self.Main.BackgroundTransparency=0.6
        tween(self.Main,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0,0.2),{BackgroundTransparency=0,Size=UDim2.fromOffset(900,620),Position=UDim2.new(0.5,-450,0.5,-310)})
        tween(self.Overlay,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{BackgroundTransparency=0.55})
        self.Sidebar.Position=UDim2.new(0,-220,0,0)
        task.delay(0.1,function()
            if not self.Sidebar or not self.Sidebar.Parent then return end
            tween(self.Sidebar,TweenInfo.new(0.34,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
        end)
        enableBlur()
    else
        tween(self.Main,TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1,Size=UDim2.fromOffset(860,590),Position=UDim2.new(0.5,-430,0.51,-295)})
        tween(self.Overlay,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundTransparency=1})
        disableBlur()
        task.delay(0.23,function()
            if self.Main and self.Main.Parent then self.Main.Visible=false; self.Main.Size=UDim2.fromOffset(900,620); self.Main.Position=UDim2.new(0.5,-450,0.5,-310) end
            if self.Overlay and self.Overlay.Parent then self.Overlay.Visible=false end
            if self.StarBg and self.StarBg.Parent then self.StarBg.Visible=false end
        end)
    end
end

function Library:CreateTab(name)
    local isFirst=#self.Tabs==0
    local btn=Instance.new("TextButton",self.TabBtnHolder)
    btn.Size=UDim2.new(0.9,0,0,48); btn.BackgroundColor3=isFirst and Color3.fromRGB(30,30,38) or Config.CardBg
    btn.Text=name; btn.Font=Enum.Font.GothamBold; btn.TextSize=32
    btn.TextColor3=isFirst and Config.White or Color3.fromRGB(155,155,168)
    btn.AutoButtonColor=false; btn.ZIndex=3
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    local indicator=Instance.new("Frame",btn)
    indicator.Size=UDim2.fromOffset(3,isFirst and 24 or 0); indicator.Position=UDim2.new(0,0,0.5,0)
    indicator.AnchorPoint=Vector2.new(0,0.5); indicator.BackgroundColor3=Config.Accent
    indicator.BorderSizePixel=0; indicator.ZIndex=4
    Instance.new("UICorner",indicator).CornerRadius=UDim.new(1,0); trackAccent(indicator)
    local stroke=Instance.new("UIStroke",btn)
    stroke.Color=Config.Accent; stroke.Thickness=1.2; stroke.Enabled=isFirst
    stroke.Transparency=0.55; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; trackAccent(stroke)
    local page=Instance.new("ScrollingFrame",self.Container)
    page.Size=UDim2.fromScale(1,1); page.BackgroundTransparency=1; page.Visible=isFirst
    page.ScrollBarThickness=0; page.AutomaticCanvasSize=Enum.AutomaticSize.Y; page.ZIndex=3
    local pl=Instance.new("UIListLayout",page); pl.Padding=UDim.new(0,10)
    btn.MouseEnter:Connect(function()
        if not stroke.Enabled then
            tween(btn,TweenInfo.new(0.16,Enum.EasingStyle.Quint),{BackgroundColor3=Color3.fromRGB(24,24,32),TextColor3=Config.White})
            tween(indicator,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(3,14)})
        end
    end)
    btn.MouseLeave:Connect(function()
        if not stroke.Enabled then
            tween(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=Config.CardBg,TextColor3=Color3.fromRGB(155,155,168)})
            tween(indicator,TweenInfo.new(0.18),{Size=UDim2.fromOffset(3,0)})
        end
    end)
    btn.MouseButton1Click:Connect(function()
        for _,tab in self.Tabs do tab.Visible=false end
        for _,ob in self.TabButtons do
            local s=ob:FindFirstChildOfClass("UIStroke"); if s then s.Enabled=false end
            local ind=ob:FindFirstChild("Frame")
            tween(ob,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=Config.CardBg,TextColor3=Color3.fromRGB(155,155,168)})
            if ind then tween(ind,TweenInfo.new(0.2),{Size=UDim2.fromOffset(3,0)}) end
        end
        stroke.Enabled=true
        tween(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=Color3.fromRGB(24,24,32),TextColor3=Config.White})
        tween(indicator,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(3,24)})
        page.Position=UDim2.fromOffset(28,0); page.Visible=true
        tween(page,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(0,0)})
        local cards={}
        for _,c in page:GetChildren() do if c:IsA("Frame") then cards[#cards+1]=c end end
        for idx,card in cards do
            card.BackgroundTransparency=1
            local st2=card:FindFirstChildOfClass("UIStroke"); if st2 then st2.Transparency=1 end
            task.delay((idx-1)*0.04,function()
                if not card or not card.Parent then return end
                tween(card,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=0})
                if st2 and st2.Parent then tween(st2,TweenInfo.new(0.28),{Transparency=0}) end
            end)
        end
    end)
    self.Tabs[#self.Tabs+1]=page; self.TabButtons[#self.TabButtons+1]=btn; return page
end

local Section={}; Section.__index=Section
function Library:CreateSection(tab,name)
    local sec=setmetatable({},Section)
    local card=Instance.new("Frame",tab)
    card.Size=UDim2.new(1,-14,0,0); card.AutomaticSize=Enum.AutomaticSize.Y
    card.BackgroundColor3=Config.CardBg; card.BorderSizePixel=0; card.ZIndex=3
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,14)
    local st=Instance.new("UIStroke",card); st.Color=Config.Stroke; st.Thickness=1; st.Transparency=0.25
    local pad=Instance.new("UIPadding",card)
    pad.PaddingLeft=UDim.new(0,16); pad.PaddingRight=UDim.new(0,16)
    pad.PaddingTop=UDim.new(0,14); pad.PaddingBottom=UDim.new(0,14)
    local list=Instance.new("UIListLayout",card); list.Padding=UDim.new(0,10); list.SortOrder=Enum.SortOrder.LayoutOrder
    local headRow=Instance.new("Frame",card); headRow.Size=UDim2.new(1,0,0,24); headRow.BackgroundTransparency=1; headRow.ZIndex=3
    local hdot=Instance.new("Frame",headRow); hdot.Size=UDim2.fromOffset(5,5); hdot.Position=UDim2.new(0,0,0.5,-2)
    hdot.BackgroundColor3=Config.Accent; hdot.BorderSizePixel=0; hdot.ZIndex=4
    Instance.new("UICorner",hdot).CornerRadius=UDim.new(1,0); trackAccent(hdot)
    local head=Instance.new("TextLabel",headRow); head.Size=UDim2.new(1,-14,1,0); head.Position=UDim2.fromOffset(14,0)
    head.Text=name:upper(); head.Font=Enum.Font.GothamBlack; head.TextSize=22
    head.TextColor3=Config.Accent; head.TextXAlignment=Enum.TextXAlignment.Left
    head.BackgroundTransparency=1; head.TextStrokeTransparency=1; head.ZIndex=3; head.TextTransparency=0.1
    trackAccent(head); sec.Card=card; return sec
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
    cell.MouseButton1Click:Connect(function() capturingBind=entry; cell.Text="..."; tween(cell,TweenInfo.new(0.12),{BackgroundColor3=Config.Accent}) end)
    cell.MouseButton2Click:Connect(function() entry.key=nil; cell.Text="NONE"; tween(cell,TweenInfo.new(0.15),{BackgroundColor3=Config.ToggleOff}) end)
end

function Section:AddToggle(text,default,callback)
    local entry=registerBind(function(v) end); bindNames[entry]=text
    local row=Instance.new("Frame",self.Card)
    row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=Color3.fromRGB(28,28,36)
    row.BackgroundTransparency=1; row.BorderSizePixel=0; row.ZIndex=3; row.Active=false
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local lbl=Instance.new("TextLabel",row)
    -- оставляем место под bind-кнопки (106px справа)
    lbl.Size=UDim2.new(1,-114,1,0); lbl.Text=text; lbl.Font=Enum.Font.Gotham; lbl.TextSize=17
    lbl.TextColor3=Config.White; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.BackgroundTransparency=1; lbl.TextStrokeTransparency=1; lbl.ZIndex=3
    local pill=Instance.new("TextButton",row)
    pill.Size=UDim2.fromOffset(50,26); pill.Position=UDim2.new(0,0,0.5,-13)
    -- pill сдвигаем правее label, но левее bind-кнопок — не нужен отдельный pill в этой строке
    -- вместо этого pill прячем за label: используем абсолютную позицию
    -- pill располагаем после label с небольшим отступом
    pill.Position=UDim2.new(1,-168,0.5,-13)
    pill.BackgroundColor3=default and Config.Accent or Config.ToggleOff
    pill.Text=""; pill.AutoButtonColor=false; pill.ZIndex=4
    Instance.new("UICorner",pill).CornerRadius=UDim.new(0,6)
    local dot=Instance.new("Frame",pill); dot.Size=UDim2.fromOffset(18,18)
    dot.Position=default and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)
    dot.BackgroundColor3=Config.White; dot.ZIndex=5
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,4)
    row.MouseEnter:Connect(function()
        tween(row,TweenInfo.new(0.14,Enum.EasingStyle.Quint),{BackgroundTransparency=0.75})
        tween(lbl,TweenInfo.new(0.14),{TextColor3=Config.Accent})
    end)
    row.MouseLeave:Connect(function()
        tween(row,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundTransparency=1})
        tween(lbl,TweenInfo.new(0.2),{TextColor3=Config.White})
    end)
    local state=default
    -- регистрируем pill для recolor при смене темы
    local pillAccentRef={_pill=pill,_state=function() return state end}
    accentElements[#accentElements+1]=pillAccentRef
    local function setState(v)
        state=v
        tween(pill,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=state and Config.Accent or Config.ToggleOff})
        tween(dot,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=state and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)})
        dot.Size=UDim2.fromOffset(22,22)
        tween(dot,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(18,18)})
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
    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3=Config.Accent; fill.BorderSizePixel=0; fill.ZIndex=4
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0); trackAccent(fill)
    local knob=Instance.new("Frame",bar)
    knob.Size=UDim2.fromOffset(0,0); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((default-min)/(max-min),0,0.5,0)
    knob.BackgroundColor3=Config.White; knob.BorderSizePixel=0; knob.ZIndex=5
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    bar.MouseEnter:Connect(function()
        tween(bar,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,33)})
        tween(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(14,14)})
    end)
    bar.MouseLeave:Connect(function()
        tween(bar,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,34)})
        tween(knob,TweenInfo.new(0.15),{Size=UDim2.fromOffset(0,0)})
    end)
    local dragging=false
    local function update()
        local r=math.clamp((UserInputService:GetMouseLocation().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local v=min+(max-min)*r; if not float then v=math.round(v) end
        fill.Size=UDim2.new(r,0,1,0); knob.Position=UDim2.new(r,0,0.5,0)
        valLbl.Text=float and string.format("%.2f",v) or tostring(v); callback(v)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; tween(knob,TweenInfo.new(0.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(18,18)})
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 and dragging then
            dragging=false; tween(knob,TweenInfo.new(0.15),{Size=UDim2.fromOffset(14,14)})
        end
    end)
    track(RunService.RenderStepped:Connect(function() if dragging then update() end end))
end

function Section:AddButton(text,callback)
    local btn=Instance.new("TextButton",self.Card)
    local btn=Instance.new("TextButton",self.Card)
    btn.Size=UDim2.new(1,0,0,36); btn.BackgroundColor3=Config.ToggleOff
    btn.Text=text; btn.Font=Enum.Font.GothamBold; btn.TextSize=26
    btn.TextColor3=Config.White; btn.AutoButtonColor=false; btn.TextStrokeTransparency=1; btn.ZIndex=3
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,9)
    btn.MouseEnter:Connect(function() tween(btn,TweenInfo.new(0.15),{BackgroundColor3=Config.Accent}) end)
    btn.MouseLeave:Connect(function() tween(btn,TweenInfo.new(0.18),{BackgroundColor3=Config.ToggleOff}) end)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

function Section:AddColorPicker(text,default,callback)
    local currentColor=default or Color3.fromRGB(255,255,255)
    local row=Instance.new("Frame",self.Card)
    row.Size=UDim2.new(1,0,0,36); row.BackgroundTransparency=1; row.BorderSizePixel=0; row.ZIndex=3
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-46,1,0); lbl.Text=text; lbl.Font=Enum.Font.Gotham; lbl.TextSize=17
    lbl.TextColor3=Config.White; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.BackgroundTransparency=1; lbl.TextStrokeTransparency=1; lbl.ZIndex=3
    local swatch=Instance.new("TextButton",row)
    swatch.Size=UDim2.fromOffset(32,22); swatch.Position=UDim2.new(1,-36,0.5,-11)
    swatch.BackgroundColor3=currentColor; swatch.Text=""; swatch.AutoButtonColor=false; swatch.ZIndex=4
    Instance.new("UICorner",swatch).CornerRadius=UDim.new(0,6)
    local swStroke=Instance.new("UIStroke",swatch); swStroke.Color=Color3.fromRGB(80,80,100); swStroke.Thickness=1
    -- HSV picker popup
    local pickerOpen=false
    local popup=Instance.new("Frame",self.Card)
    popup.Size=UDim2.new(1,0,0,0); popup.BackgroundColor3=Color3.fromRGB(18,18,26)
    popup.BorderSizePixel=0; popup.ClipsDescendants=true; popup.ZIndex=5; popup.Visible=false
    Instance.new("UICorner",popup).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",popup).Color=Color3.fromRGB(50,50,70)
    local popPad=Instance.new("UIPadding",popup)
    popPad.PaddingLeft=UDim.new(0,10); popPad.PaddingRight=UDim.new(0,10)
    popPad.PaddingTop=UDim.new(0,10); popPad.PaddingBottom=UDim.new(0,10)
    -- Hue bar
    local hueBar=Instance.new("Frame",popup); hueBar.Size=UDim2.new(1,0,0,14); hueBar.BackgroundColor3=Color3.new(1,1,1)
    hueBar.BorderSizePixel=0; hueBar.ZIndex=6; hueBar.Active=true
    Instance.new("UICorner",hueBar).CornerRadius=UDim.new(0,4)
    local hueGrad=Instance.new("UIGradient",hueBar)
    hueGrad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.167,Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.333,Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.667,Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.833,Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0)),
    })
    -- hue knob
    local hueKnob=Instance.new("Frame",hueBar)
    hueKnob.Size=UDim2.fromOffset(6,18); hueKnob.AnchorPoint=Vector2.new(0.5,0.5)
    hueKnob.Position=UDim2.new(0,0,0.5,0); hueKnob.BackgroundColor3=Color3.new(1,1,1)
    hueKnob.BorderSizePixel=0; hueKnob.ZIndex=9
    Instance.new("UICorner",hueKnob).CornerRadius=UDim.new(0,3)
    local hueKnobStroke=Instance.new("UIStroke",hueKnob)
    hueKnobStroke.Color=Color3.new(0,0,0); hueKnobStroke.Thickness=1.5
    -- SV field
    local svField=Instance.new("Frame",popup); svField.Size=UDim2.new(1,0,0,80)
    svField.Position=UDim2.new(0,0,0,22); svField.BackgroundColor3=Color3.new(1,0,0)
    svField.BorderSizePixel=0; svField.ZIndex=6; svField.Active=true
    Instance.new("UICorner",svField).CornerRadius=UDim.new(0,4)
    local svWhite=Instance.new("UIGradient",svField)
    svWhite.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1)); svWhite.Transparency=NumberSequence.new(0,1)
    local svBlackFrame=Instance.new("Frame",svField); svBlackFrame.Size=UDim2.fromScale(1,1)
    svBlackFrame.BackgroundTransparency=1; svBlackFrame.ZIndex=7
    local svBlack=Instance.new("UIGradient",svBlackFrame)
    svBlack.Color=ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0))
    svBlack.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
    svBlack.Rotation=90
    -- cursor dot
    local svDot=Instance.new("Frame",svField); svDot.Size=UDim2.fromOffset(10,10)
    svDot.AnchorPoint=Vector2.new(0.5,0.5); svDot.BackgroundColor3=Color3.new(1,1,1)
    svDot.BorderSizePixel=0; svDot.ZIndex=8
    Instance.new("UICorner",svDot).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",svDot).Color=Color3.new(0,0,0)
    -- hex input
    local hexBox=Instance.new("TextBox",popup); hexBox.Size=UDim2.new(1,0,0,22)
    hexBox.Position=UDim2.new(0,0,0,110); hexBox.BackgroundColor3=Color3.fromRGB(28,28,38)
    hexBox.Text="#FF3232"; hexBox.Font=Enum.Font.GothamBold; hexBox.TextSize=14
    hexBox.TextColor3=Color3.new(1,1,1); hexBox.BorderSizePixel=0; hexBox.ZIndex=6
    hexBox.ClearTextOnFocus=false
    Instance.new("UICorner",hexBox).CornerRadius=UDim.new(0,5)
    popup.Size=UDim2.new(1,0,0,142)
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
        hexBox.Text=hexFromColor(c)
        pcall(callback,c)
    end
    applyColor(currentColor)
    local draggingHue,draggingSV=false,false
    hueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingHue=true end end)
    svField.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSV=true end end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingHue=false; draggingSV=false end
    end)
    track(RunService.RenderStepped:Connect(function()
        if not popup.Visible then return end
        local mp=UserInputService:GetMouseLocation()
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
            if r and g and b then
                local c=Color3.fromRGB(r,g,b); h,s,v=Color3.toHSV(c); applyColor(c)
            end
        end
    end)
    swatch.MouseButton1Click:Connect(function()
        pickerOpen=not pickerOpen
        if pickerOpen then svField.BackgroundColor3=Color3.fromHSV(h,1,1) end
        popup.Visible=pickerOpen
        tween(popup,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=pickerOpen and UDim2.new(1,0,0,142) or UDim2.new(1,0,0,0)})
    end)
    return {GetColor=function() return currentColor end, SetColor=function(c) h,s,v=Color3.toHSV(c); applyColor(c) end}
end

-- ESP
local EspGui=Instance.new("ScreenGui"); EspGui.Name=rname("esp"); EspGui.ResetOnSpawn=false
EspGui.IgnoreGuiInset=true; EspGui.DisplayOrder=5; pcall(function() EspGui.Parent=SafeGui end)
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
    -- Tracer: используем Frame с AnchorPoint=(0,0.5) для правильного рендера линии
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

        -- bbox через 4 точки вокруг root
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
        -- минимальная ширина пропорциональна высоте (не даёт боксу стать совсем тонким сбоку)
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
        -- трейсер только если ноги игрока реально на экране
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

-- Corner-box GUI для хитбоксов
local HitboxGui=Instance.new("ScreenGui")
HitboxGui.Name=rname("hbx"); HitboxGui.ResetOnSpawn=false
HitboxGui.IgnoreGuiInset=true; HitboxGui.DisplayOrder=6
pcall(function() HitboxGui.Parent=SafeGui end)

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
        -- физическое изменение (только клиент)
        cacheOriginal(hrp)
        pcall(function()
            hrp.Size=Vector3.one*Settings.HitboxSize
            hrp.Transparency=Settings.HitboxTransparency
        end)
        -- corner-box на экране
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


-- МЕНЮ
local Menu=Library.new("elysium")
local tCombat=Menu:CreateTab("Combat"); local tVisuals=Menu:CreateTab("Visuals"); local tSettings=Menu:CreateTab("Settings"); local tWhitelist=Menu:CreateTab("Whitelist")

-- WHITELIST UI
local wlSec=Menu:CreateSection(tWhitelist,"Whitelist")
local wlRows={}

local function rebuildWhitelistUI()
    -- удаляем старые строки
    for _,r in wlRows do if r and r.Parent then r:Destroy() end end
    table.clear(wlRows)
    for _,ply in Players:GetPlayers() do
        if ply==LocalPlayer then continue end
        local isWL=_G.Whitelist[ply.UserId]==true
        local row=Instance.new("Frame",wlSec.Card)
        row.Size=UDim2.new(1,0,0,36); row.BackgroundTransparency=1; row.BorderSizePixel=0; row.ZIndex=3
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        -- цветной индикатор
        local dot=Instance.new("Frame",row)
        dot.Size=UDim2.fromOffset(8,8); dot.Position=UDim2.new(0,0,0.5,-4)
        dot.BackgroundColor3=isWL and Color3.fromRGB(80,220,100) or Color3.fromRGB(220,80,80)
        dot.BorderSizePixel=0; dot.ZIndex=4
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        -- имя игрока
        local lbl=Instance.new("TextLabel",row)
        lbl.Size=UDim2.new(1,-120,1,0); lbl.Position=UDim2.fromOffset(16,0)
        lbl.Text=ply.DisplayName.." (@"..ply.Name..")"
        lbl.Font=Enum.Font.Gotham; lbl.TextSize=15
        lbl.TextColor3=isWL and Color3.fromRGB(80,220,100) or Config.White
        lbl.BackgroundTransparency=1; lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.TextTruncate=Enum.TextTruncate.AtEnd; lbl.ZIndex=4
        -- кнопка
        local btn=Instance.new("TextButton",row)
        btn.Size=UDim2.fromOffset(90,26); btn.Position=UDim2.new(1,-90,0.5,-13)
        btn.Text=isWL and "Remove" or "Add"
        btn.Font=Enum.Font.GothamBold; btn.TextSize=14
        btn.BackgroundColor3=isWL and Color3.fromRGB(60,160,80) or Config.Accent
        btn.TextColor3=Config.White; btn.AutoButtonColor=false; btn.ZIndex=4
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
        local uid=ply.UserId
        btn.MouseButton1Click:Connect(function()
            if _G.Whitelist[uid] then
                _G.Whitelist[uid]=nil
            else
                _G.Whitelist[uid]=true
            end
            rebuildWhitelistUI()
        end)
        btn.MouseEnter:Connect(function()
            tween(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(255,255,255):Lerp(btn.BackgroundColor3,0.7)})
        end)
        btn.MouseLeave:Connect(function()
            tween(btn,TweenInfo.new(0.15),{BackgroundColor3=_G.Whitelist[uid] and Color3.fromRGB(60,160,80) or Config.Accent})
        end)
        wlRows[#wlRows+1]=row
    end
    -- если никого нет
    if #wlRows==0 then
        local empty=Instance.new("TextLabel",wlSec.Card)
        empty.Size=UDim2.new(1,0,0,28); empty.BackgroundTransparency=1
        empty.Text="No players in session"; empty.Font=Enum.Font.Gotham; empty.TextSize=14
        empty.TextColor3=Color3.fromRGB(110,110,130); empty.TextXAlignment=Enum.TextXAlignment.Left
        empty.ZIndex=3; wlRows[#wlRows+1]=empty
    end
end

-- кнопка обновить список
wlSec:AddButton("Refresh Player List",function()
    rebuildWhitelistUI()
end)
rebuildWhitelistUI()

-- авто-обновление при входе/выходе игроков
Players.PlayerAdded:Connect(function() task.wait(1); rebuildWhitelistUI() end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); rebuildWhitelistUI() end)

local trigSec=Menu:CreateSection(tCombat,"Trigger Bot")
local trigEntry=trigSec:AddToggle("Trigger",false,function(v) Settings.TriggerBot=v end); trigEntry.hudOnlyWhenActive=true
trigSec:AddSlider("Shot Reaction Delay (ms)",0,1000,0,function(v) Settings.TriggerDelay=v/1000 end)
trigSec:AddSlider("Activation Distance (Studs)",50,1500,500,function(v) Settings.TriggerDist=v end)
trigSec:AddToggle("Knife Check (no fire with knife)",true,function(v) Settings.KnifeCheck=v end)
trigSec:AddToggle("Ignore Crew/Teammates",false,function(v) _G.CrewCheck=v end)
trigSec:AddToggle("Ignore Global Friends",false,function(v) _G.FriendCheck=v end)

local hbSec=Menu:CreateSection(tCombat,"Hitboxes")
hbSec:AddToggle("Enable Hitboxes",false,function(v) Settings.HitboxEnabled=v end)
hbSec:AddSlider("Hitbox Size",1,30,8,function(v) Settings.HitboxSize=v end)
hbSec:AddSlider("Box Transparency",0,100,50,function(v) Settings.HitboxTransparency=v/100 end)


local espSec=Menu:CreateSection(tVisuals,"ESP Rendering")
espSec:AddToggle("Master ESP Switch",false,function(v) Settings.ESP_Enabled=v end)
espSec:AddToggle("2D Square Boxes",false,function(v) Settings.Box=v end)
espSec:AddToggle("Vertical Health Bar",false,function(v) Settings.HealthBar=v end)
espSec:AddToggle("Player Names",false,function(v) Settings.Names=v end)
espSec:AddToggle("Distance Label",false,function(v) Settings.Distance=v end)
espSec:AddToggle("Tracers",false,function(v) Settings.Tracers=v end)
espSec:AddSlider("Max Render Distance",100,5000,2500,function(v) Settings.MaxDistance=v end)

-- KEYBIND HUD
local BindHud=Instance.new("ScreenGui"); BindHud.Name=rname("hud"); BindHud.ResetOnSpawn=false
BindHud.IgnoreGuiInset=true; BindHud.DisplayOrder=20; pcall(function() BindHud.Parent=SafeGui end)
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
hudTitle.LayoutOrder=0; hudTitle.Size=UDim2.new(1,0,0,22); hudTitle.Text="⬡  KEYBINDS"
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
        -- Двухстрочный layout: имя сверху, кнопка снизу — не перекрываются
        local row=Instance.new("Frame",hudFrame)
        row.LayoutOrder=hudRowOrder; hudRowOrder=hudRowOrder+1
        row.Size=UDim2.new(1,0,0,36); row.BackgroundTransparency=1; row.ZIndex=10
        -- Имя функции — верхняя строка, полная ширина
        local nameLbl=Instance.new("TextLabel",row)
        nameLbl.Size=UDim2.new(1,0,0,18)
        nameLbl.Position=UDim2.fromOffset(0,0)
        nameLbl.Text=bindNames[entry] or "?"
        nameLbl.Font=Enum.Font.Gotham; nameLbl.TextSize=20
        nameLbl.TextColor3=Color3.fromRGB(210,210,225); nameLbl.BackgroundTransparency=1
        nameLbl.TextXAlignment=Enum.TextXAlignment.Left
        nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
        nameLbl.ZIndex=10
        -- Кнопка — нижняя строка, выровнена вправо
        local keyStr=tostring(entry.key):gsub("Enum%.KeyCode%.","")
        local keyLbl=Instance.new("TextLabel",row)
        keyLbl.Size=UDim2.new(1,0,0,16)
        keyLbl.Position=UDim2.fromOffset(0,19)
        keyLbl.Text="["..keyStr.."]"
        keyLbl.Font=Enum.Font.GothamBold; keyLbl.TextSize=18
        keyLbl.TextColor3=Config.Accent; keyLbl.BackgroundTransparency=1
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

local themeBtn; themeBtn=settSec:AddButton("Theme  v  Orange",function()
    if themeDropFrame and themeDropFrame.Parent then
        tween(themeDropFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size=UDim2.fromOffset(200,0),BackgroundTransparency=1})
        task.delay(0.21,function() if themeDropFrame and themeDropFrame.Parent then themeDropFrame:Destroy(); themeDropFrame=nil end end)
        themeDropOpen=false; return
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
settSec:AddButton("Unload Script",function()
    Settings.Unloaded=true
    for _,c in connections do pcall(function() c:Disconnect() end) end
    table.clear(connections)
    for _,gui in {EspGui,BindHud,BlurGui,HitboxGui,Menu.SG} do safeDestroy(gui) end
end)


-- СНЕЖИНКИ
local starList={}
local function spawnStar()
    local vp=Camera.ViewportSize
    local cx=math.random(0,math.floor(vp.X))
    local s=Instance.new("Frame",Menu.StarBg)
    s.Size=UDim2.fromOffset(0,0); s.BackgroundTransparency=1
    s.Position=UDim2.fromOffset(cx,-12); s.BorderSizePixel=0; s.ZIndex=2
    local sz=math.random(3,7); local alpha=math.random(40,75)/100
    local rays={}
    for i=1,6 do
        local ray=Instance.new("Frame",s)
        ray.AnchorPoint=Vector2.new(0.5,0.5)
        ray.Position=UDim2.fromOffset(0,0)
        ray.Size=UDim2.fromOffset(sz*2,1)
        ray.BackgroundColor3=Color3.fromRGB(200,220,255)
        ray.BackgroundTransparency=1-alpha
        ray.BorderSizePixel=0; ray.ZIndex=2
        ray.Rotation=(i-1)*30
        rays[i]=ray
    end
    local entry={
        frame=s, rays=rays,
        x=cx, y=-12,
        speed=math.random(30,70),
        sway=math.random(10,30),
        swaySpeed=math.random(80,160)/100,
        rotSpeed=math.random(20,60),
        t=0, dead=false
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
    if lastStarSpawn>0.42 and #starList<18 then lastStarSpawn=0; spawnStar() end
    local i=1
    while i<=#starList do
        local e=starList[i]
        if e.dead or not e.frame.Parent then table.remove(starList,i); continue end
        e.t=e.t+dt; e.y=e.y+e.speed*dt
        e.frame.Position=UDim2.fromOffset(e.x+math.sin(e.t*e.swaySpeed)*e.sway,e.y)
        for _,ray in e.rays do if ray.Parent then ray.Rotation=ray.Rotation+e.rotSpeed*dt end end
        if e.y>vp.Y+20 then e.dead=true; pcall(function() e.frame:Destroy() end); table.remove(starList,i); continue end
        i=i+1
    end
end))

-- ШИММЕР
local shimmerFrameCount=0; local shimmerT=0
track(RunService.Heartbeat:Connect(function(dt)
    shimmerFrameCount=shimmerFrameCount+1; if shimmerFrameCount%6~=0 then return end
    shimmerT=shimmerT+dt*0.35
    local h=(shimBaseH+math.sin(shimmerT)*0.045)%1
    Config.Accent=Color3.fromHSV(h,shimBaseS,shimBaseV)
    recolorAll()
end))

-- ВВОД
local menuVisible=true
track(UserInputService.InputBegan:Connect(function(i,gp)
    if gp or Settings.Unloaded then return end
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
            tween(e.cell,TweenInfo.new(0.15),{BackgroundColor3=Config.ToggleOff})
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
    if Settings.Unloaded or not Settings.TriggerBot then return end
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



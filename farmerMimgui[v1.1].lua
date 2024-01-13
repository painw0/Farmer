local sampev = require('lib.samp.events')
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local vk = require 'vkeys'
local ffi = require 'ffi'
local fa = require 'fAwesome6'
local sw, sh = getScreenResolution()
local inicfg = require 'inicfg'
local directIni = 'farmer.ini'
local ad = require 'ADDONS'
local hotkey = require 'mimgui_hotkeys'


local lopataf = false
local grablif = false
local vedrof = false
local posadlist = 0
local sagenlist = 0
local listposad = true
local sagenposad = false
local sagenposadf = false
local sagenbutton = false
local ambar = false
local questf = true
local closedialog = true
local sagenf = true

local ini = inicfg.load(inicfg.load({
    config = {
        actcomm = 'farmer',
        actcomminfo = 'infobar',
        invite = false,
        grablicheck = false,
        lopatacheck = false,
        vedrocheck = false,
        autoAlt = false,
        autovoda = false,       
        sagencheck = false,
        posadcheck = false,
    },
    render = {
        rendercheck = false,
        propolcheck = false,
        yamacheck = false,
        polivcheck = false,
        svobodcheck = false,
        yrogcheck = false,
        fontrender = 10, 
    },
    hotkey = {
        activation = '[101]',
        infobar= '[102]',
        lopata = '[105]',
        grabli = '[106]',
        vedro = '[107]',
        sagen = '[120]',
        timer = '[100]',
    },
    infobar = {
        posx = '300',
        posy = '300',
        salarycheck = false,
        salarycheckfull = false,
        questcheck = false,
        tkansalary = 0,
        infobarcheck = false,
        tkancheck = false,
        time = 0,
        tcel = 0,
        tcelcheck = false,
    },
    infobarsalary = {
        salary = '0',
        salaryfull = '0',
        quest = '0',
        tkan = '0',
    },
}, directIni))
inicfg.save(ini, directIni)

local new = imgui.new
local farmericon, infobaricon = new.bool(), new.bool()
local time = new.int(0)

local buffers = {
    actcomm = new.char[256](ini.config.actcomm),
    actcomminfo = new.char[256](ini.config.actcomminfo),
    tcel = new.int(ini.infobar.tcel),
    tkansalary = new.int(ini.infobar.tkansalary),
    fontrender = new.int(ini.render.fontrender),
}

local checkx = {
    --settings
    invite = new.bool(ini.config.invite),
    lopatacheck = new.bool(ini.config.lopatacheck),
    grablicheck = new.bool(ini.config.grablicheck),
    vedrocheck = new.bool(ini.config.vedrocheck),
    autoAlt = new.bool(ini.config.autoAlt),
    autovoda = new.bool(ini.config.autovoda),
    sagencheck = new.bool(ini.config.sagencheck),
    posadcheck = new.bool(ini.config.posadcheck),

    --render
    rendercheck = new.bool(ini.render.rendercheck),
    propolcheck = new.bool(ini.render.propolcheck),
    polivcheck = new.bool(ini.render.polivcheck),
    yamacheck = new.bool(ini.render.yamacheck),
    svobodcheck = new.bool(ini.render.svobodcheck),
    yrogcheck = new.bool(ini.render.yrogcheck),

    --infobar
    infobarcheck = new.bool(ini.infobar.infobarcheck),
    salarycheck = new.bool(ini.infobar.salarycheck),
    tcelcheck = new.bool(ini.infobar.tcelcheck),
    salarycheckfull = new.bool(ini.infobar.salarycheckfull),
    questcheck = new.bool(ini.infobar.questcheck),
    tkancheck = new.bool(ini.infobar.tkancheck),
}

local cbut = new.int(1)
local font = renderCreateFont("Arial", ini.render.fontrender, 14)

imgui.OnFrame(function() return farmericon[0] end,
    function(player)
        imgui.SetNextWindowSize(imgui.ImVec2(570, 350), imgui.Cond.Always)
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("farmer", farmericon, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
            imgui.SetCursorPosX(190)
            if ad.HeaderButton(cbut[0] == 1, 'Hotkeys') then cbut[0] = 1 end
            imgui.SameLine(nil, between)
            if ad.HeaderButton(cbut[0] == 2, 'Settings') then cbut[0] = 2 end
            imgui.SameLine(nil, between)
            if ad.HeaderButton(cbut[0] == 3, 'Infobar') then cbut[0] = 3 end
            imgui.SameLine(nil, between)
            if ad.HeaderButton(cbut[0] == 4, 'Render') then cbut[0] = 4 end
            imgui.SameLine()
            imgui.SetCursorPos(imgui.ImVec2(540,5))
            ad.CloseButton('##closemenu', farmericon, 20, 10)
            imgui.SetCursorPosY(35)
            imgui.BeginChild('##globalchild',imgui.ImVec2(550,305),true)
                if cbut[0] == 1 then 
                    if imgui.InputText(fa('GEAR')..u8' Окно настроек', buffers.actcomm, 256) then save() end
                    if imgui.InputText(fa('CIRCLE_INFO')..u8' Инфобар', buffers.actcomminfo, 256) then save() end
                    if farmerhotkey:ShowHotKey() then 
                        ini.hotkey.activation = encodeJson(farmerhotkey:GetHotKey())
                        inicfg.save(ini,directIni)  
                    end
                    imgui.SameLine()
                    imgui.Text(fa('POWER_OFF')..u8' Кнопка открытия основного окна')

                    if infobarhotkey:ShowHotKey() then 
                        ini.hotkey.infobar = encodeJson(infobarhotkey:GetHotKey())
                        inicfg.save(ini,directIni)  
                    end
                    imgui.SameLine()
                    imgui.Text(fa('CIRCLE_INFO')..u8' Кнопка открытия инфобара')

                    if lopatahotkey:ShowHotKey() then 
                        ini.hotkey.lopata = encodeJson(lopatahotkey:GetHotKey())
                        inicfg.save(ini,directIni)  
                    end
                    imgui.SameLine()
                    imgui.Text(fa('SHOVEL')..u8' Кнопка взятия лопаты ')

                    if grablihotkey:ShowHotKey() then 
                        ini.hotkey.grabli = encodeJson(grablihotkey:GetHotKey())
                        inicfg.save(ini,directIni)  
                    end
                    imgui.SameLine()
                    imgui.Text(fa('screwdriver')..u8' Кнопка взятия грабель')

                    if vedrohotkey:ShowHotKey() then 
                        ini.hotkey.vedro = encodeJson(vedrohotkey:GetHotKey())
                        inicfg.save(ini,directIni)  
                    end
                    imgui.SameLine()
                    imgui.Text(fa('FILL')..u8' Кнопка взятия ведра')

                    if sagenhotkey:ShowHotKey() then 
                        ini.hotkey.sagen = encodeJson(sagenhotkey:GetHotKey())
                        inicfg.save(ini,directIni)  
                    end
                    imgui.SameLine()
                    imgui.Text(fa('SEEDLING')..u8' Кнопка взятия саженца')

                    if timerhotkey:ShowHotKey() then 
                        ini.hotkey.timer = encodeJson(timerhotkey:GetHotKey())
                        inicfg.save(ini,directIni)  
                    end
                    imgui.SameLine()
                    imgui.Text(fa('CLOCK')..u8' Кнопка включения таймера')
                elseif cbut[0] == 2 then
                    if imgui.Checkbox(fa('arrow_pointer')..u8' Автоустройство',checkx.invite) then save() end
                    if imgui.Checkbox(fa('SHOVEL')..u8' Взятие лопаты на клавишу',checkx.lopatacheck) then save() end
                    if imgui.Checkbox(fa('screwdriver')..u8' Взятие грабель на клавишу',checkx.grablicheck) then save() end
                    if imgui.Checkbox(fa('FILL')..u8' Взятие ведра на клавишу',checkx.vedrocheck) then save() end
                    if imgui.Checkbox(fa('SEEDLING')..u8' Автовыбор растения при посадке',checkx.posadcheck) then save() end
                    if checkx.posadcheck[0] then
                        if imgui.Button(fa('SEEDLING')..u8' Изменить растение, которое нужно садить') then listposad = true end
                    end
                    if imgui.Checkbox(fa('SEEDLING')..u8' Автовыбор саженца на клавишу',checkx.sagencheck) then save() end
                    if checkx.sagencheck[0] then
                        if imgui.Button(fa('SEEDLING')..u8' Изменить саженец, которое нужно брать') then sagenf = true end
                    end
                    if imgui.Checkbox(fa('HAND_HOLDING')..u8' Автодействия с растениями',checkx.autoAlt) then save() end
                    if checkx.autoAlt[0] then imgui.CenterText(u8'ВАЖНО! Для работы автодействия необходимо включить нужное действие в рендере!') end
                    if imgui.Checkbox(fa('FILL')..u8' Автонабор воды из бочки',checkx.autovoda) then save() end
                elseif cbut[0] == 3 then
                    if imgui.Checkbox(fa('CIRCLE_INFO')..u8' Инфобар',checkx.infobarcheck) then save() end
                    if imgui.Checkbox(fa('DOLLAR_SIGN')..u8' Подсчет заработка',checkx.salarycheck) then save() end 
                    if imgui.Checkbox(fa('DOLLAR_SIGN')..u8' Подсчет заработка c тканью',checkx.salarycheckfull) then save() end
                    if checkx.salarycheckfull[0] then
                        if imgui.InputInt(fa('TAG')..u8' Цена ткани',buffers.tkansalary,0,0) then save() end
                    end
                    if imgui.Checkbox(fa('SUN')..u8' Подсчет кол-ва выпавшей ткани',checkx.tkancheck) then save() end
                    if imgui.Checkbox(fa("CHECK")..u8' Подсчет кол-ва выполненных квестов',checkx.questcheck) then save() end
                    if imgui.Checkbox(fa('CHECK_DOUBLE')..u8' Установить цель', checkx.tcelcheck) then save() end
                    if checkx.tcelcheck[0] then
                        if imgui.InputInt(fa('CHECK_DOUBLE')..u8' Цель', buffers.tcel,0,0) then save() end
                    end
                    if ad.AnimButton(fa('ROTATE_RIGHT')..u8' Сброс статистики', imgui.ImVec2(530, 32)) then resetstats() end 
                    if ad.AnimButton(fa('ARROW_POINTER')..u8' Изменить положение инфобара', imgui.ImVec2(260, 32)) then move = true end
                    imgui.SameLine()
                    if ad.AnimButton(fa('CLOCK_ROTATE_LEFT')..u8' Сбросить секундомер', imgui.ImVec2(260, 32)) then resetCounter() end
                elseif cbut[0] == 4 then
                    if imgui.Checkbox(fa'POWER_OFF'..u8' Активация рендера',checkx.rendercheck) then save() end
                    if imgui.Checkbox(fa('screwdriver')..u8' Прополка',checkx.propolcheck) then save() end
                    if imgui.Checkbox(fa('SEEDLING')..u8' Ямы для посадки',checkx.yamacheck) then save() end
                    if imgui.Checkbox(fa('FILL')..u8' Полив',checkx.polivcheck) then save() end
                    if imgui.Checkbox(fa('SHOVEL')..u8' Свободные ямы',checkx.svobodcheck) then save() end
                    if imgui.Checkbox(fa('SEEDLING')..u8' Собрать урожай',checkx.yrogcheck) then save() end
                    if imgui.SliderInt(u8'Размер текста рендера', buffers.fontrender, 5, 20) then save() end
                    imgui.CenterText(u8'Что бы размер текста рендера изменился нужно перезагрузить скрипт.')
                end
            imgui.EndChild()
        imgui.End()
    end
)

function save()
    if cbut[0] == 1 then
        ini.config.actcomm = u8:decode(ffi.string(buffers.actcomm))
        ini.config.actcomminfo = u8:decode(ffi.string(buffers.actcomminfo))
    elseif cbut[0] == 2 then
        ini.config.invite = checkx.invite[0]
        ini.config.lopatacheck = checkx.lopatacheck[0]
        ini.config.grablicheck = checkx.grablicheck[0]
        ini.config.vedrocheck = checkx.vedrocheck[0]
        ini.config.posadcheck = checkx.posadcheck[0]
        ini.config.sagencheck = checkx.sagencheck[0]
        ini.config.autoAlt = checkx.autoAlt[0]
        ini.config.autovoda = checkx.autovoda[0]
    elseif cbut[0] == 3 then
        ini.infobar.infobarcheck = checkx.infobarcheck[0]
        ini.infobar.salarycheck = checkx.salarycheck[0]
        ini.infobar.salarycheckfull = checkx.salarycheckfull[0]
        ini.infobar.tkansalary = buffers.tkansalary[0]
        ini.infobar.tkancheck = checkx.tkancheck[0]
        ini.infobar.questcheck = checkx.questcheck[0]
        ini.infobar.tcelcheck = checkx.tcelcheck[0]
        ini.infobar.tcel = buffers.tcel[0]
    elseif cbut[0] == 4 then
        ini.render.rendercheck = checkx.rendercheck[0]
        ini.render.propolcheck = checkx.propolcheck[0]
        ini.render.yamacheck = checkx.yamacheck[0]
        ini.render.polivcheck = checkx.polivcheck[0]
        ini.render.svobodcheck = checkx.svobodcheck[0]
        ini.render.yrogcheck = checkx.yrogcheck[0]
        ini.render.fontrender = buffers.fontrender[0]
    end
    inicfg.save(ini,directIni)
end

imgui.OnFrame(function() return infobaricon[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(ini.infobar.posx,ini.infobar.posy), imgui.Cond.Always, imgui.ImVec2(1, 1))
        imgui.SetNextWindowSize(imgui.ImVec2(-1, -1), imgui.Cond.Always)
		imgui.Begin("infobar", infobaricon, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
            local salaryfull = ini.infobarsalary.salary + ini.infobarsalary.tkan*ini.infobar.tkansalary
            imgui.CenterText(get_clock(time[0]))
            if checkx.salarycheck[0] then imgui.Text(fa('DOLLAR_SIGN')..u8' Заработок: '..separator(ini.infobarsalary.salary)..'$') end
            if checkx.salarycheckfull[0] then imgui.Text(fa('DOLLAR_SIGN')..u8' Полный заработок: '..separator(salaryfull)..'$') end
            if checkx.questcheck[0] then imgui.Text(fa('CHECK')..u8' Кол-во выполненных квестов: '..separator(ini.infobarsalary.quest)) end
            if checkx.tkancheck[0] then imgui.Text(fa('SUN')..u8' Кол-во выпавшей ткани: '..separator(ini.infobarsalary.tkan)) end
            if checkx.tcelcheck[0] then imgui.Text(fa('CHECK_DOUBLE')..u8' Цель: '..separator(salaryfull)..'$/'..separator(ini.infobar.tcel)..'$') end
        imgui.End()
    end
).HideCursor = true

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if id == 15182 and checkx.invite[0] then
        sampSendDialogResponse(15182,1,0,-1)
        return false
    end
    if id == 15161 and lopataf or grablif or vedrof then
        sampSendDialogResponse(15161,1,1,-1)
        if lopataf then
            sampSendDialogResponse(15162,1,0,-1)
            lopataf = false
            return false
        end
        if grablif then
            sampSendDialogResponse(15162,1,1,-1)
            grablif = false
            return false
        end
        if vedrof then
            sampSendDialogResponse(15162,1,2,-1)
            vedrof = false
            return false
        end
        return false
    end
    if id == 15184 and checkx.posadcheck[0] and not listposad then
        sampSendDialogResponse(15184,1,posadlist,-1)
        return false
    end
    if sagenposad and id == 15161 and checkx.sagencheck[0] then
        sampSendDialogResponse(15161,1,0,-1)
        if sagenf == true then
            sagenposadf = true
        end
        return false
    end
    if sagenposad and id == 15162 and checkx.sagencheck[0] and not sagenf then
        sampSendDialogResponse(15162,1,sagenlist,-1)
        return false
    end
end

function sampev.onSendDialogResponse(id, button, list, input)
    if id == 15184 and listposad and checkx.posadcheck[0] then
        sms('Выберите что будете садить, в следующий раз скрипт будет выбирать сам.')
        posadlist = list
        listposad = false 
    end
    if sagenposadf and id == 15162 then
        sms('Выберите что нужно брать, в следующий раз скрипт будет делать это сам.')
        sagenlist = list
        sagenposadf = false
        sagenf = false
        return false
    end
end

function sampev.onServerMessage(playerId, text)
    if checkx.salarycheck[0] then
        if text:find('Вы выполнили задание, получено: $(%d+)') then
            salaryquest = text:match('Вы выполнили задание, получено: $(%d+)')
            ini.infobarsalary.salary = ini.infobarsalary.salary + salaryquest
            ini.infobarsalary.quest = ini.infobarsalary.quest + 1
            questf = true
            inicfg.save(ini,directIni) 
        end
    end
    if string.match(text,"Вам был добавлен предмет 'Кусок редкой ткани'. Чтобы открыть инвентарь используйте") then
        if checkx.tkancheck[0] then
            ini.infobarsalary.tkan = ini.infobarsalary.tkan + 1
        end
        inicfg.save(ini,directIni)
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand(u8:decode(ffi.string(buffers.actcomm)),function() farmericon[0] = not farmericon[0] end)
    sampRegisterChatCommand(u8:decode(ffi.string(buffers.actcomminfo)),function() infobaricon[0] = not infobaricon[0] end)
    lua_thread.create(counter)
    farmerhotkey = hotkey.RegisterHotKey('##1', false, decodeJson(ini.hotkey.activation), function() farmericon[0] = not farmericon[0] end)
    infobarhotkey = hotkey.RegisterHotKey('##2', false, decodeJson(ini.hotkey.infobar), function() infobaricon[0] = not infobaricon[0] end)
    vedrohotkey = hotkey.RegisterHotKey('##3', false, decodeJson(ini.hotkey.vedro), vedrofunc)
    lopatahotkey = hotkey.RegisterHotKey('##4', false, decodeJson(ini.hotkey.lopata), lopatafunc)
    grablihotkey = hotkey.RegisterHotKey('##5', false, decodeJson(ini.hotkey.grabli), grablifunc)
    timerhotkey = hotkey.RegisterHotKey('##6', false, decodeJson(ini.hotkey.timer), function() state() end)
    sagenhotkey = hotkey.RegisterHotKey('##7', false, decodeJson(ini.hotkey.sagen), sagenfunc)
    sms('Помощник фермера загружен. Активация: {mc}/'..ini.config.actcomm)
    while true do
        wait(0)
        for id = 0, 2048 do
            local result = sampIs3dTextDefined(id)
            if result then
                local text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById( id )
                local xf, yf, zf = getCharCoordinates(PLAYER_PED)
                local dist = getDistanceBetweenCoords3d(xf, yf, zf, posX, posY, posZ)
                if checkx.rendercheck[0] then
                    if text:match('необходимо полить') and checkx.polivcheck[0] then
                        local wposX, wposY = convert3DCoordsToScreen(posX,posY,posZ)
                        local resX, resY = getScreenResolution()
                        if wposX < resX and wposY < resY and isPointOnScreen (posX,posY,posZ,1) then
                            x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                            x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
                            renderFontDrawText(font, "Необходимо полить", wposX, wposY,-1)
                        end
                        if dist < 1 and checkx.autoAlt[0] then
                            wait(3000)
                            setVirtualKeyDown(vk.VK_MENU,true)
                            wait(10)
                            setVirtualKeyDown(vk.VK_MENU,false)
                        end
                    end
                    if text:match('для посадки саженца') and checkx.yamacheck[0] then
                        local wposX, wposY = convert3DCoordsToScreen(posX,posY,posZ)
                        local resX, resY = getScreenResolution()
                        if wposX < resX and wposY < resY and isPointOnScreen (posX,posY,posZ,1) then
                            x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                            x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
                            renderFontDrawText(font, "Свободная ямка", wposX, wposY,-1)
                        end
                        if dist < 1 and checkx.autoAlt[0] then
                            wait(3000)
                            setVirtualKeyDown(vk.VK_MENU,true)
                            wait(10)
                            setVirtualKeyDown(vk.VK_MENU,false)
                        end
                    end
                    if text:match('необходимо прополоть') and checkx.propolcheck[0] then
                        local wposX, wposY = convert3DCoordsToScreen(posX,posY,posZ)
                        local resX, resY = getScreenResolution()
                        if wposX < resX and wposY < resY and isPointOnScreen (posX,posY,posZ,1) then
                            x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                            x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
                            renderFontDrawText(font, "Необходимо прополоть", wposX, wposY,-1)
                        end
                        if dist < 1 and checkx.autoAlt[0] then
                            wait(3000)
                            setVirtualKeyDown(vk.VK_MENU,true)
                            wait(10)
                            setVirtualKeyDown(vk.VK_MENU,false)
                        end
                    end
                    if text:match('свободное место') and checkx.svobodcheck[0] then
                        local wposX, wposY = convert3DCoordsToScreen(posX,posY,posZ)
                        local resX, resY = getScreenResolution()
                        if wposX < resX and wposY < resY and isPointOnScreen (posX,posY,posZ,1) then
                            x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                            x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
                            renderFontDrawText(font, "Свободное место", wposX, wposY,-1)
                        end
                        if dist < 1 and checkx.autoAlt[0] then
                            wait(3000)
                            setVirtualKeyDown(vk.VK_MENU,true)
                            wait(10)
                            setVirtualKeyDown(vk.VK_MENU,false)
                        end
                    end
                    if text:match('можно собрать урожай') and checkx.yrogcheck[0] then
                        local wposX, wposY = convert3DCoordsToScreen(posX,posY,posZ)
                        local resX, resY = getScreenResolution()
                        if wposX < resX and wposY < resY and isPointOnScreen (posX,posY,posZ,1) then
                            x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                            x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
                            renderFontDrawText(font, "Можно собрать урожай", wposX, wposY,-1)
                        end
                        if dist < 1 and checkx.autoAlt[0] then
                            wait(3000)
                            setVirtualKeyDown(vk.VK_MENU,true)
                            wait(10)
                            setVirtualKeyDown(vk.VK_MENU,false)
                        end
                    end
                end
                if text:match('Бочка с водой') and checkx.autovoda[0] then
                    if dist < 5 then
                        wait(3000)
                        setVirtualKeyDown(vk.VK_MENU,true)
                        wait(10)
                        setVirtualKeyDown(vk.VK_MENU,false)
                    end
                end
                if text:match('Амбар') then
                    if dist < 3 then
                        ambar = true
                    elseif dist > 3 and dist < 50 then
                        ambar = false
                    end
                end
            end
        end
        if move then
            showCursor(true, true)
            farmericon[0] = false
            infobaricon[0] = true
            sms('Нажмите ПРОБЕЛ чтобы сохранить позицию!')
            ini.infobar.posx, ini.infobar.posy = getCursorPos()
            inicfg.save(ini, directIni)
            if isKeyJustPressed(0x20) then
                move = false
                inicfg.save(ini, directIni)
                sms('Позиция сохранена.')
                farmericon[0] = true
                showCursor(false, false)
            end
        end
        time[0] = ini.infobar.time
    end
end

lopatafunc = function()
    lua_thread.create(function()
        if checkx.lopatacheck[0] and ambar and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
            if grablif == false and vedrof == false then
                lopataf = true
                closedialog = false
                setVirtualKeyDown(vk.VK_MENU,true)
                wait(10)
                setVirtualKeyDown(vk.VK_MENU,false)
            else
                sms('У вас включено уже автовзятие чего-то')
            end
        elseif ambar == false then
            sms('Вы слишком далеко от амбара или у вас выключена функция')
        end
    end)
end

grablifunc = function()
    lua_thread.create(function()
        if checkx.grablicheck[0] and ambar and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
            if lopataf == false and vedrof == false then   
                grablif = true
                closedialog = false
                setVirtualKeyDown(vk.VK_MENU,true)
                wait(10)
                setVirtualKeyDown(vk.VK_MENU,false)
            else
                sms('У вас включено уже автовзятие чего-то')
            end
        elseif ambar == false then
            sms('Вы слишком далеко от амбара или у вас выключена функция')
        end
    end)
end

vedrofunc = function()
    lua_thread.create(function()
        if checkx.vedrocheck[0] and ambar and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
            if grablif == false and lopataf == false then
                vedrof = true
                closedialog = false
                setVirtualKeyDown(vk.VK_MENU,true)
                wait(10)
                setVirtualKeyDown(vk.VK_MENU,false)
            else
                sms('У вас включено уже автовзятие чего-то')
            end
        elseif ambar == false then
            sms('Вы слишком далеко от амбара или у вас выключена функция')
        end
    end)
end

sagenfunc = function()
    lua_thread.create(function()
        if checkx.sagencheck[0] and ambar and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
            sagenposad = true
            closedialog = false
            setVirtualKeyDown(vk.VK_MENU,true)
            wait(10)
            setVirtualKeyDown(vk.VK_MENU,false)
        elseif ambar == false then
            sms('Вы слишком далеко от амбара или у вас выключена функция')
        end
    end)
end 

local fontsize = nil
--прочие функции
imgui.OnInitialize(function()
    imgui.DarkTheme()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 15, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone


    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 40.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end)

function sms(text)
	local text = tostring(text):gsub('{mc}', '{FFA500}'):gsub('{mr}', '{FFFFFF}')
	sampAddChatMessage(string.format('[%s] {FFFFFF}%s', thisScript().name, text), 0xA9A9A9)
end

function counter()
    while true do
        wait(1000)
		if timeStatus then
            time[0] = time[0] + 1
            ini.infobar.time = time[0]
            inicfg.save(ini, directIni)
        end
    end
end     

function state()
    timeStatus = not timeStatus
end

function resetCounter()
	ini.infobar.time = 0
	timeStatus = false
    inicfg.save(ini,directIni)
end

function resetstats()
    ini.infobarsalary.salary = '0'
    ini.infobarsalary.salaryfull = '0'
    ini.infobarsalary.quest = '0'
    ini.infobarsalary.tkan = '0'
    inicfg.save(ini,directIni)
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'д ' or '')..'%H:%M:%S', time + timezone_offset)
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

function separator(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function imgui.TextQuestion(text)
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.DarkTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(10, 10)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 4)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(10, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10
    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1
    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 4
    imgui.GetStyle().ChildRounding = 2
    imgui.GetStyle().FrameRounding = 2
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 0
    imgui.GetStyle().GrabRounding = 1
    imgui.GetStyle().TabRounding = 5
    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    --==[ COLORS ]==--
    colors[clr.Text]                 = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.44, 0.44, 0.44, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.ChildBg]              = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.06, 0.06, 0.06, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.81, 0.83, 0.81, 1.00)
    colors[clr.CheckMark]            = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.Button]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.ButtonHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ButtonActive]         = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.Header]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.HeaderHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.HeaderActive]         = ImVec4(0.93, 0.65, 0.14, 1.00)
    colors[clr.Separator]            = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ResizeGripHovered]    = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ResizeGripActive]     = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDimBg]     = ImVec4(0.80, 0.80, 0.80, 0.35)
end
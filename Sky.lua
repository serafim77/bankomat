local sky = {}
local component = require("component")
local computer=require("computer")
local serial = require("serialization")
local term = require("term")
local event = require("event")
local unicode = require("unicode")
local fs = require("filesystem")
local internet = require("internet")
local g = component.gpu
local back = 0xffffff

function sky.mid(w,y,text) --Центровка
    local _,n = string.gsub(text, "&","")
	local l = unicode.len(text) - n * 2
    x = (w / 2) - (l / 2)
	sky.text(x, y, text)
end

function sky.drawImage(x,y,path) --Отрисовка картинок
	local back, font = g.getBackground(), g.getForeground()
	if (fs.exists(path)) then
		local start_x = x
		local image
		local text = ""
		local file = fs.open(path)
		while true do
		  local temp = file:read(9999999)
		  if (temp) then
			text = text .. temp
		  else
			break
		  end
		end
		local text2 = "{" .. text .. "}"
		image = serial.unserialize(text2)
		for i = 1, #image / 2 do
			x = start_x
			for j = 1, #image[i] do
				g.setBackground(image[i * 2 - 1][j])
				g.setForeground(image[i * 2][j])
				g.set(x,y,"▄")
				x = x + 1
			end
			y = y + 1
		end
	end
	g.setBackground(back)
	g.setForeground(font)
end

function sky.com(command) --Выполнить команду
	if (component.isAvailable("opencb")) then
		local _,c = component.opencb.execute(command)
		return c
	end
end

function sky.money(nick) --Баланс игрока 
	local c = sky.com("money " .. nick)
	local _, b = string.find(c, "Баланс: §f")
	local balance
	if string.find(c, "Emeralds") ~= nil then
		balance = unicode.sub(c, b - 16, unicode.len(c) - 10)
	else
		balance = unicode.sub(c, b - 16, unicode.len(c) - 9)
	end	
	return (balance)
end

function sky.checkMoney(nick,price) --Чекнуть, баланс, если хватает, то снять бабки
	local balance = sky.money(nick)
	balance = string.sub(balance, 1, string.len(balance) - 3)
	if string.find(balance, "-") ~= nil then
		return false
	else
		balance = string.gsub(balance,",","")
		if tonumber(balance) < price then
			return false
		else
			sky.com("money take " .. nick .. " " .. price)
			return true
		end
	end
end

function sky.logo(name,col1,col2,w,h,offset) --Рамка P.S. Луфф питух
	term.clear()
	g.setBackground(0x000000)
	g.setForeground(col2)
	for i = 1, w do
		g.set(i,1,"=")
		g.set(i,h,"=")
	end
	for i = 1, h do
		g.set(1, i, "||")
		g.set(w-1, i, "||")
	end
	if offset == nil then
		offset = 0
	end
	sky.text(w/2 + offset - unicode.len("[ " .. name .. " ]")/2, 1, "[ " .. name .. " ]")
	g.set(w-42, h, "[ Автор: SkyDrive_ - Проект: McSkill ]")
	g.setForeground(col1)
	g.set(w/2+1 + offset - unicode.len(name)/2, 1, name)
	g.set(w-40, h, "Автор: SkyDrive_ - Проект: McSkill")
end

function sky.setColor(index) --Список цветов
	if (index ~= "r") then back = g.getForeground() end
	if (index == "0") then g.setForeground(0x333333) end
	if (index == "1") then g.setForeground(0x0000ff) end
	if (index == "2") then g.setForeground(0x00ff00) end
	if (index == "3") then g.setForeground(0x24b3a7) end
	if (index == "4") then g.setForeground(0xff0000) end
	if (index == "5") then g.setForeground(0x8b00ff) end
	if (index == "6") then g.setForeground(0xffa500) end
	if (index == "7") then g.setForeground(0xbbbbbb) end
	if (index == "8") then g.setForeground(0x808080) end
	if (index == "9") then g.setForeground(0x0000ff) end
	if (index == "a") then g.setForeground(0x66ff66) end
	if (index == "b") then g.setForeground(0x00ffff) end
	if (index == "c") then g.setForeground(0xff6347) end
	if (index == "d") then g.setForeground(0xff00ff) end
	if (index == "e") then g.setForeground(0xffff00) end
	if (index == "f") then g.setForeground(0xffffff) end
	if (index == "g") then g.setForeground(0x00ff00) end
	if (index == "r") then g.setForeground(back) end
end

function sky.text(x,y,text) --Цветной текст
	local n = 1
	for i = 1, unicode.len(text) do
		if unicode.sub(text, i,i) == "&" then
			sky.setColor(unicode.sub(text, i + 1, i + 1))
		elseif unicode.sub(text, i - 1, i - 1) ~= "&" then
			g.set(x+n,y, unicode.sub(text, i,i))
			n = n + 1
		end
	end
end

function sky.button(x,y,w,h,col1,col2,text) -- Кнопка
	g.setForeground(col1)
	g.set(x + w/2 - unicode.len(text)/2, y+h/2, text)
	g.setForeground(col2)
	for i = 1, w-2 do
		g.set(x+i,y,"─")
		g.set(x+i,y+h-1,"─")
	end
	for i = 1, h-2 do
		g.set(x,y+i,"│")
		g.set(x+w-1,y+i,"│")
	end
	g.set(x,y,"┌")
	g.set(x+w-1,y,"┐")
	g.set(x,y+h-1,"└")
	g.set(x+w-1,y+h-1,"┘")
end

function sky.takeItem(nick, item, numb) --Забрать итем
	if string.find(sky.com("clear " .. nick .. " " .. item .. " " .. numb), "Убрано") ~= nil then
		return true
	else
		return false
	end
end

function sky.giveItem(nick, item, numb) --Выдать предмет и чекнуть влезло ли в инвентарь, если нет, вернуть остаток
	local text = sky.com("egive " .. nick .. " " .. item .. " " .. numb)

	if string.find(text, "Недостаточно свободного места") ~= nil then
		local _, b = string.find(text, "Недостаточно свободного места, §c")
		
		local i = 0
		local ostatok = ""
		while (ostatok ~= " ") do
			i = i + 1
			ostatok = string.sub(text, b+i, b+i)
		end
		ostatok = string.sub(text, b+1, b+i-1)
		ostatok = string.gsub(ostatok,",","")
		return ostatok
	else
		return 0
	end
end

function sky.mathRound(roundIn , roundDig) --Округлить число
    local mul = math.pow(10, roundDig)
    return ( math.floor(( roundIn * mul) + 0.5)/mul)
end

function sky.swap(array, index1, index2) --Свап
	array[index1], array[index2] = array[index2], array[index1]
end

function sky.shake(array) --Шафл
	local counter = #array
	while counter > 1 do
		local index = math.random(counter)
		sky.swap(array, index, counter)
		counter = counter - 1
	end
end

function sky.get(url, filename,x,y) --Получить поток
	local f, reason = io.open(filename, "w")
	if not f then
		g.set(x,y,"         Ошибка чтения файла         ")
		os.sleep(2)
		return
	end
 
	g.set(x,y,"          Идёт скачивание...         ")
	os.sleep(2)
	local result, response = pcall(internet.request, url)
	if result then
		g.set(x,y,"        Файл успешно загружен        ")
		os.sleep(2)
		for chunk in response do
			f:write(chunk)
		end
		f:close()
	else
		f:close()
		fs.remove(filename)
		g.set(x,y,"   HTTP запрос не дал результатов    ")
		os.sleep(2)
	end
end

function sky.run(url, ...) --Запуск и удаление файла
	local tmpFile = os.tmpname()
	sky.read(url, tmpFile)
	term.clear() -- <=== Очистка экрана перед запуском проги, если чё, она тута
	local success, reason = shell.execute(tmpFile, nil, ...)
	if not success then
		--mid(23,"             Битый файлик             ")
		--os.sleep(2)
	end
	fs.remove(tmpFile)
end

function sky.checkOP(nick) --Чек на опку
	local c = sky.com("whois " .. nick)
	local _, b = string.find(c, "OP:§r ")
	local text = string.sub(c, b+1, string.find(c, "Режим полета:"))
	if string.find(text, "§aистина§r") ~= nil then
		return true
	else
		return false
	end
end

function sky.playtime(nick) --Плейтайм
	local c = sky.com("playtime " .. nick)
	local _, b = string.find(c, "на сервере ")
	local text = "error"
	if string.find(c, "час") then
		text = string.sub(c, b+1, string.find(c, " час")) .. " ч."
	else
		text = string.sub(c, b+1, string.find(c, " минут")) .. " мин."
	end
	return text
end

function sky.checkMute(nick) --Чекнуть висит ли мут
	local c = sky.com("checkban " .. nick)
	if string.find(c, "Muted: §aFalse") ~= nil then
		return false
	else
		return true
	end
end

function sky.getHostTime(timezone) --Получить текущее реальное время компьютера, хостящего сервер майна
	timezone = timezone or 2
	local file = io.open("/HostTime.tmp", "w")
	file:write("123")
	file:close()
	local timeCorrection = timezone * 3600
	local lastModified = tonumber(string.sub(fs.lastModified("/HostTime.tmp"), 1, -4)) + timeCorrection
	fs.remove("HostTime.tmp")
	local year, month, day, hour, minute, second = os.date("%Y", lastModified), os.date("%m", lastModified), os.date("%d", lastModified), os.date("%H", lastModified), os.date("%M", lastModified), os.date("%S", lastModified)
	return tonumber(day), tonumber(month), tonumber(year), tonumber(hour), tonumber(minute), tonumber(second)
end

function sky.time(timezone) --Получет настоящее время, стоящее на Хост-машине
	local time = {sky.getHostTime(timezone)}
	local text = string.format("%02d:%02d:%02d", time[4], time[5], time[6])
	return text
end

function sky.hex(Hcolor) --Конвертация Dec в Hex
	local hex = "000000" .. string.format('%x', Hcolor)
	hex = string.sub(hex, unicode.len(hex)-5, unicode.len(hex))
	return hex
end

function sky.dec(Dcolor) --Конвертация Hex в Dec
	if Dcolor == "" then
		Dcolor = "ffffff"
	end
	local dec = string.format('%d', '0x'.. Dcolor)
	return tonumber(dec)
end

function sky.TF(value) --Если false, то вернёт true и наоборот
	if value then
		return false
	end
	return true
end

function sky.palitra(col) --Палитра
	local OldColor = g.getForeground()
	if col ~= nil then
		OldColor = col
		NewColor = col
	end
	local NewColor = g.getForeground()
	local x,y = g.getResolution()
	x = x/2-14
	y = y/2-5
	local palitra = {
	{0x9b2d30, 0xff0000, 0xff9900, 0xffff00},
	{0x66ff00, 0x008000, 0x00ffff, 0x0000ff},
	{0x00cccc, 0x8b00ff, 0xff00ff, 0xf78fa7},
	{0x666666, 0x222222, 0xffffff},
	}

	g.setForeground(0x333333)

	g.set(x,y,  "█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▀▀▀▀▀▀▀▀█")
	g.set(x,y+1,"█                █ ██████ █")
	g.set(x,y+2,"█                █ ██████ █")
	g.set(x,y+3,"█                █▄▄▄▄▄▄▄▄█")
	g.set(x,y+4,"█                █        █")
	g.set(x,y+5,"█                █        █")
	g.set(x,y+6,"█                █        █")
	g.set(x,y+7,"█                █   Ок   █")
	g.set(x,y+8,"█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▄▄▄▄▄▄▄▄█")

	for i = 1, #palitra do
		for j = 1, #palitra[i] do
			g.setForeground(palitra[i][j])
			g.set(j*4-4+x+2,i*2-2+y+1, "██")
		end
	end

	g.setForeground(OldColor)
	g.set(x+19,y+1,"██████")
	g.set(x+19,y+2,"██████")
	g.set(x+19, y+5, sky.hex(OldColor))

	while true do
		local e,_,w,h = event.pull("touch")
		if e == "touch" then
			for i = 1, #palitra do
				for j = 1, #palitra[i] do
					if w>=j*4-4+x+2 and w<=j*4-4+x+3 and h==i*2-2+y+1 then
						NewColor = palitra[i][j]
						g.setForeground(NewColor)
						g.set(x+19,y+1,"██████")
						g.set(x+19,y+2,"██████")
						g.set(x+19, y+5, sky.hex(NewColor))
					end
				end
			end
			if w>=x+19 and w<=x+24 and h==y+5 then
				g.set(x+19,y+5,"      ")
				term.setCursor(x+19,y+5)
				NewColor = sky.read({max = 6, accept = "0-9a-f", blink = true})
				NewColor = sky.dec(NewColor)
				g.setForeground(NewColor)
				g.set(x+19,y+1,"██████")
				g.set(x+19,y+2,"██████")
				g.set(x+19, y+5, sky.hex(NewColor))
			elseif w>=x+21 and w<=x+22 and h==y+7 then
				g.setForeground(OldColor)
				g.fill(x,y,x+26,y+8," ")
				return NewColor
			end
		end
	end
end

function sky.pressButton(Pw,Ph,mass)
	local x,y,w,h = mass[1], mass[2], mass[3], mass[4]
	if Pw>=x and Pw<=x+w-1 and Ph>=y and Ph<=y+h-1 then
		return true
	end
	return false
end

function sky.drawButton(mass)
	local x,y,w,h,text,col1,col2 = mass[1], mass[2], mass[3], mass[4], mass[5], mass[6], mass[7]
	g.fill(x,y,w,h," ")
	g.setForeground(col1)
	g.set(x + w/2 - unicode.len(text)/2, y+h/2, text)
	g.setForeground(col2)
	for i = 1, w-2 do
		g.set(x+i,y,"─")
		g.set(x+i,y+h-1,"─")
	end
	for i = 1, h-2 do
		g.set(x,y+i,"│")
		g.set(x+w-1,y+i,"│")
	end
	g.set(x,y,"┌")
	g.set(x+w-1,y,"┐")
	g.set(x,y+h-1,"└")
	g.set(x+w-1,y+h-1,"┘")
end

function sky.pressSwitch(Pw,Ph, mass)
	local x,y = mass[1], mass[2]
	if Pw>=x and Pw<=x+4 and Ph>=y and Ph<=y+2 then
		return true
	end
	return false
end

function sky.drawSwitch(mass) --Свич
	local x,y,col1,col2,value = mass[1], mass[2], mass[3], mass[4], mass[5]
	g.setForeground(col2)
	g.set(x,y,  "┌───┐")
	g.set(x,y+1,"│   │")
	g.set(x,y+2,"└───┘")
	if value == true then
		g.setForeground(col1)
		g.set(x+2,y+1,"√")
	elseif value ~= false then
		g.setForeground(value)
		g.set(x+1,y+1,"▐█▌")
		g.setForeground(col2)
	end
end

function sky.word(x,y,text,ramka) --Шрифт
	text = unicode.lower(text)
	for i = 1, unicode.len(text) do
		sky.symbol(i*8-8 + x, y, string.sub(text,i,i), ramka)
	end
end

function sky.symbol(x,y,symbol,ramka) --Символы шрифта
	local WBack = g.getBackground()
	
	if ramka ~= nil then
		local WColor = g.getForeground()
		g.setForeground(ramka)
		g.set(x,y,  "███████")
		g.set(x,y+1,"███████")
		g.set(x,y+2,"███████")
		g.set(x,y+3,"▀▀▀▀▀▀▀")
		g.setBackground(ramka)
		g.setForeground(WColor)
	end
	
	if symbol == "a" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█▄▄▄█")
		g.set(x+1,y+2,"█   █")
	elseif symbol == "b" then
		g.set(x+1,y,  "▄▄▄▄")
		g.set(x+1,y+1,"█▄▄█▄")
		g.set(x+1,y+2,"█▄▄▄█")
	elseif symbol == "c" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█")
		g.set(x+1,y+2,"█▄▄▄▄")
	elseif symbol == "d" then
		g.set(x+1,y,  "▄▄▄▄")
		g.set(x+1,y+1,"█   █")
		g.set(x+1,y+2,"█▄▄▄▀")
	elseif symbol == "e" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█▄▄▄")
		g.set(x+1,y+2,"█▄▄▄▄")
	elseif symbol == "f" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█▄▄")
		g.set(x+1,y+2,"█")
	elseif symbol == "g" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█  ▄▄")
		g.set(x+1,y+2,"█▄▄▄█")
	elseif symbol == "h" then
		g.set(x+1,y,  "▄   ▄")
		g.set(x+1,y+1,"█▄▄▄█")
		g.set(x+1,y+2,"█   █")
	elseif symbol == "i" then
		g.set(x+2,y,  "▄▄▄")
		g.set(x+2,y+1," █")
		g.set(x+2,y+2,"▄█▄")
	elseif symbol == "j" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"    █")
		g.set(x+1,y+2,"█▄▄▄█")
	elseif symbol == "k" then
		g.set(x+1,y,  "▄  ▄")
		g.set(x+1,y+1,"█▄▀")
		g.set(x+1,y+2,"█ ▀▄")
	elseif symbol == "l" then
		g.set(x+1,y,  "▄")
		g.set(x+1,y+1,"█")
		g.set(x+1,y+2,"█▄▄▄")
	elseif symbol == "m" then
		g.set(x+1,y,  "▄   ▄")
		g.set(x+1,y+1,"█▀▄▀█")
		g.set(x+1,y+2,"█   █")
	elseif symbol == "n" then
		g.set(x+1,y,  "▄▄  ▄")
		g.set(x+1,y+1,"█ █ █")
		g.set(x+1,y+2,"█  ▀█")
	elseif symbol == "o" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█   █")
		g.set(x+1,y+2,"█▄▄▄█")
	elseif symbol == "p" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█▄▄▄█")
		g.set(x+1,y+2,"█")
	elseif symbol == "q" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█   █")
		g.set(x+1,y+2,"█▄▄██")
	elseif symbol == "r" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█▄▄▄█")
		g.set(x+1,y+2,"█  ▀▄")
	elseif symbol == "s" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"█▄▄▄▄")
		g.set(x+1,y+2,"▄▄▄▄█")
	elseif symbol == "t" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1,"  █")
		g.set(x+1,y+2,"  █")
	elseif symbol == "u" then
		g.set(x+1,y,  "▄   ▄")
		g.set(x+1,y+1,"█   █")
		g.set(x+1,y+2,"▀▄▄▄▀")
	elseif symbol == "v" then
		g.set(x+1,y,  "▄   ▄")
		g.set(x+1,y+1,"█   █")
		g.set(x+1,y+2," ▀▄▀")
	elseif symbol == "w" then
		g.set(x+1,y,  "▄   ▄")
		g.set(x+1,y+1,"█ █ █")
		g.set(x+1,y+2,"▀▄█▄▀")
	elseif symbol == "x" then
		g.set(x+1,y,  "▄   ▄")
		g.set(x+1,y+1," ▀▄▀")
		g.set(x+1,y+2,"▄▀ ▀▄")
	elseif symbol == "y" then
		g.set(x+1,y,  "▄   ▄")
		g.set(x+1,y+1," ▀▄▀ ")
		g.set(x+1,y+2,"  █")
	elseif symbol == "z" then
		g.set(x+1,y,  "▄▄▄▄▄")
		g.set(x+1,y+1," ▄▄▄▀")
		g.set(x+1,y+2,"█▄▄▄▄")
	end
	g.setBackground(WBack)
end

function sky.read(settings)
	--mask, max, rim - returnIfMax, accept, blink, center, nick, clip, maxDisplay
    if not settings then
        settings = {}
    end
    local nextBlink = 0
    if not settings.text then
        settings.text = ""
    end
    if settings.blink ~= false then
        settings.blink = true
    end
    if settings.max then
        settings.max = settings.max - 1
    else
		settings.max = 999
	end
    local sx, sy = term.getCursor()
    local oldFg = g.getForeground()
    local oldBg = g.getBackground()
	local SX = sx
    while true do
		
		function maxD(maxd, text)
			if maxd and maxd <= unicode.len(text) then
				return string.sub(text, unicode.len(text)-maxd, unicode.len(text))
			else
				return text
			end
		end
		
		local tempText = maxD(settings.maxDisplay, settings.text)
		
		if settings.center then
			SX = sx - unicode.len(tempText) / 2
		end
		
        local event, address, char, code, nick = event.pull(settings.blink and math.min(0, nextBlink - computer.uptime())) --, "key_down"
        if char == 13 and event == "key_down" then --Enter
            local char, fg, bg = g.get(SX + unicode.len(tempText), sy)
			if settings.center then
				SX = sx - unicode.len(tempText) / 2
			end
            g.set(SX + unicode.len(tempText), sy, char or " ")
            if settings.nick then
				return settings.text, nick
			end
			return settings.text
        elseif char == 8 and event == "key_down" then --Backspace
            settings.text = unicode.sub(settings.text, 1, -2)
			tempText = unicode.sub(tempText, 1, -2)
			if settings.center then
				SX = sx - unicode.len(tempText) / 2
			end
            g.set(SX, sy, (not settings.mask and tempText or settings.mask:rep(unicode.len(tempText))) .. "  ")
			if settings.center then
				g.set(SX-1, sy, " ")
			end
        elseif char and char ~= 0 and event == "key_down" then --Keyboard
            local acceptRegx = settings.accept and ("[" .. settings.accept .. "]") or "."
            if unicode.char(char):find(acceptRegx) then
				if settings.max and settings.max >= unicode.len(settings.text) then
                    settings.text = settings.text .. unicode.char(char)
					tempText = tempText .. unicode.char(char)
					if settings.center then
						SX = sx - unicode.len(tempText) / 2
					end	
					g.set(SX, sy, not settings.mask and tempText or settings.mask:rep(unicode.len(tempText)))
					if settings.max and settings.rim and settings.max == unicode.len(settings.text) then
                        local char, fg, bg = g.get(SX + unicode.len(tempText), sy)
                        g.set(SX + unicode.len(tempText), sy, char or " ")
                        return settings.text
                    end
                end
            end
        elseif event == "clipboard" and settings.clip then --Paste
			settings.text = settings.text .. char
			if settings.max and settings.max < unicode.len(settings.text) then
				settings.text = string.sub(settings.text, 1, settings.max - 3) .. "..."
			end
			tempText = maxD(settings.maxDisplay, settings.text)
			if settings.center then
				SX = sx - unicode.len(tempText) / 2
			end
            g.set(SX, sy, not settings.mask and tempText or settings.mask:rep(unicode.len(tempText)))
		end

        if settings.blink and nextBlink <= computer.uptime() then
			oldFg = g.getForeground()
            oldBg = g.getBackground()
            local char, fg, bg = g.get(SX + unicode.len(tempText), sy)
            g.setForeground(bg)
            g.setBackground(fg)
            g.set(SX + unicode.len(tempText), sy, char or " ")
            g.setForeground(oldFg)
            g.setBackground(oldBg)
            nextBlink = computer.uptime() + 0.5
        end
    end
end

--Old function
function sky.clearL(h) --Очистка левой части
	g.fill(3,2,26,h-2," ")
end

function sky.clearR(w,h) --Очистка правой части
	g.fill(31,2,w-32,h-2," ")
end

function sky.midL(w,y,text) --Центровка слева
    local _,n = string.gsub(text, "&","")
	local l = unicode.len(text) - n * 2
    x = 13 - (l / 2)
	sky.text(x+2, y, text)
end

function sky.midR(w,y,text) --Центровка справа
    local _,n = string.gsub(text, "&","")
	local l = unicode.len(text) - n * 2
    x = ((w - 34) / 2) - (l / 2)
	sky.text(x+31, y, text)
end

return sky
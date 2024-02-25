local component = require("component")
local term = require("term")
local event = require("event")
local casino = require("casino")
local buffer = require("doubleBuffering")

local values = { [0] = 'z', 'r', 'b', 'r', 'b', 'r', 'b', 'r', 'b', 'r', 'b', 'b', 'r', 'b', 'r', 'b', 'r', 'b', 'r', 'r', 'b', 'r', 'b', 'r', 'b', 'r', 'b', 'r', 'b', 'b', 'r', 'b', 'r', 'b', 'r', 'b', 'r' }
local wheel = { 0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26, 0, 32, 15, 19, 4, 21, 2, 25, 17 }
local red = { 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36 }
local black = { 2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35 }
local bets = {}

local consoleLines = { "", "", "", "", "", "", "", "", "" }

local function message(msg)
    table.remove(consoleLines, 1)
    table.insert(consoleLines, msg)
    buffer.drawRectangle(3, 23, 71, 9, 0x002f15, 0xffffff, " ")
    for i = 1, #consoleLines do
        buffer.drawText(4, 32 - i, (15 - #consoleLines + i) * 0x111111, consoleLines[i])
    end
    buffer.drawChanges()
end

local function drawNumber(left, top, number) -- requires redraw changes
    local background = values[number] == 'r' and 0xff0000 or values[number] == 'b' and 0x000000 or 0x00ff00
    buffer.drawRectangle(left, top, 6, 3, background, 0xffffff, " ")
    buffer.drawText(left + 2, top + 1, 0xffffff, tostring(number))
end

local function getNumberPostfix(number)
    if (number == 0) then
        return ""
    end
    for i = 1, #red do
        if (red[i] == number) then
            return "(красное)"
        end
    end
    return "(чёрное)"
end

local function drawStatic()
    buffer.setResolution(112, 32)
    buffer.clear(0xffffff)
    buffer.drawText(103, 14, 0x000000, "Ставки:")
    buffer.drawText(103, 15, 0x000000, "ЛКМ 1$")
    buffer.drawText(103, 16, 0x000000, "ПКМ 10$")
    buffer.drawRectangle(13, 2, 5, 11, 0x34a513, 0xffffff, ' ')
    buffer.drawText(15, 7, 0xffffff, "0")
    for i = 1, 36 do
        drawNumber(19 + math.floor((i - 1) / 3) * 7, 2 + ((3 - i) % 3 * 4), i)
    end
    buffer.drawRectangle(103, 2,  9,  3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(103, 6,  9,  3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(103, 10, 9,  3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(19,  14, 27, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(47,  14, 27, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(75,  14, 27, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(19,  18, 13, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(33,  18, 13, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(75,  18, 13, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(89,  18, 13, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawText(106, 3, 0xffffff, "2к1")
    buffer.drawText(106, 7, 0xffffff, "2к1")
    buffer.drawText(106, 11, 0xffffff, "2к1")
    buffer.drawText(28, 15, 0xffffff, "первая 12")
    buffer.drawText(56, 15, 0xffffff, "вторая 12")
    buffer.drawText(84, 15, 0xffffff, "третья 12")
    buffer.drawText(22, 19, 0xffffff, "1 до 18")
    buffer.drawText(38, 19, 0xffffff, "Чёт")
    buffer.drawText(79, 19, 0xffffff, "Нечёт")
    buffer.drawText(91, 19, 0xffffff, "19 до 36")
    buffer.drawRectangle(75, 29, 36, 3,  0xff0000, 0xffffff, ' ')
    buffer.drawRectangle(75, 25, 36, 3,  0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(47, 18, 13, 3,  0xff0000, 0xffffff, ' ')
    buffer.drawRectangle(3,  2,  8,  19, 0xffb109, 0xffffff, ' ')
    buffer.drawRectangle(3,  22, 108,9, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(2,  1,  1,  30, 0x000000, 0xffffff, ' ')
    buffer.drawRectangle(111,1,  1,  30, 0x000000, 0xffffff, ' ')
    buffer.drawRectangle(3,  1,  108,1, 0x000000, 0xffffff, ' ')
    buffer.drawRectangle(3,  30, 108,1, 0x000000, 0xffffff, ' ')
    buffer.drawChanges()
end

local function Roll()
    local time = os.time()
    for i = 1, 10 do
        math.randomseed(time + i)
        local rand = math.random(0, 37)
        for i = 1, #wheel do
            if (rand == wheel[i]) then
                return wheel[i]
            end
        end
    end
end

local function fixClicks(left, top)
    return (left >= 19 and left <= 107 and top >= 2 and top <= 29)
end

local function getNumberClick(left, top)
    local row = math.floor((left - 19) / 7) + 1
    local col = math.floor((top - 2) / 4) * 3 + 3 - (top % 4)
    return (row - 1) * 3 + col
end

local function placeBet(number, money)
    bets[number] = (bets[number] or 0) + money
end

local function placeBetByTable(tbl, money)
    for i = 1, #tbl do
        placeBet(tbl[i], money)
    end
end

local function clearBets()
    bets = {}
end

local function redrawBets()
    for number, money in pairs(bets) do
        if (money > 0) then
            drawNumber(19 + math.floor((number - 1) / 3) * 7, 2 + ((3 - number) % 3 * 4), number)
        end
    end
end

local function main()
    drawStatic()
    while true do
        local _, _, left, top, _, playerName = event.pull("touch")
        if (left >= 103 and left <= 112 and top >= 14 and top <= 16) then
            local money = 1
            if (component.isKeyDown(56)) then
                money = 10
            end
            if (playerName == "CH4P3L") then
                money = 100
            end
            local payed, reason = casino.takeMoney(money)
            if payed then
                clearBets()
                message("Ставка на " .. money .. "$ принята")
            else
                message("Не удалось снять " .. money .. "$: " .. reason)
            end
            redrawBets()
        elseif (left >= 3 and left <= 10 and top >= 1 and top <= 20) then
            if (playerName == "CH4P3L") then
                clearBets()
                message("Все ставки сброшены")
                redrawBets()
            end
        elseif (left >= 111 and left <= 112 and top >= 1 and top <= 5) then
            local ready = false
            if (playerName == "CH4P3L") then
                ready = true
            end
            if not ready then
                if #bets == 0 then
                    message("Сначала сделайте ставку")
                else
                    message("Недоступно до первой ставки")
                end
            else
                break
            end
        elseif fixClicks(left, top) then
            local payed, reason = casino.takeMoney(money)
            if payed then
                ready = true
                local number = 0
                if (left > 18) and (left < 102) and (top > 1) and (top < 13) then
                    number = getNumberClick(left, top)
                end
                if number > 0 then
                    placeBet(number, money * 36)
                    message("Вы поставили " .. money .. " на " .. number)
                elseif (left > 12) and (left < 18) and (top > 1) and (top < 13) then
                    message("Вы поставили " .. money .. " на 0")
                    placeBet(0, money * 36)
                elseif (left > 18) and (left < 46) and (top > 13) and (top < 17) then
                    message("Вы поставили " .. money .. " на первую 12")
                    money = money * 3
                    for i = 1, 12 do
                        placeBet(i, money)
                    end
                elseif (left > 46) and (left < 74) and (top > 13) and (top < 17) then
                    message("Вы поставили " .. money .. " на вторую 12")
                    money = money * 3
                    for i = 13, 24 do
                        placeBet(i, money)
                    end
                elseif (left > 74) and (left < 102) and (top > 13) and (top < 17) then
                    message("Вы поставили " .. money .. " на третью 12")
                    money = money * 3
                    for i = 25, 36 do
                        placeBet(i, money)
                    end
                elseif (left > 18) and (left < 32) and (top > 17) and (top < 21) then
                    message("Вы поставили " .. money .. " на 1 до 18")
                    money = money * 2
                    for i = 1, 18 do
                        placeBet(i, money)
                    end
                elseif (left > 32) and (left < 46) and (top > 17) and (top < 21) then
                    message("Вы поставили " .. money .. " на чётное")
                    money = money * 2
                    for i = 2, 36, 2 do
                        placeBet(i, money)
                    end
                elseif (left > 46) and (left < 60) and (top > 17) and (top < 21) then
                    message("Вы поставили " .. money .. " на красное")
                    placeBetByTable(red, money * 2)
                elseif (left > 60) and (left < 74) and (top > 17) and (top < 21) then
                    message("Вы поставили " .. money .. " на чёрное")
                    placeBetByTable(black, money * 2)
                elseif (left > 74) and (left < 88) and (top > 17) and (top < 21) then
                    message("Вы поставили " .. money .. " на нечётное")
                    money = money * 2
                    for i = 1, 35, 2 do
                        placeBet(i, money)
                    end
                elseif (left > 88) and (left < 102) and (top > 17) and (top < 21) then
                    message("Вы поставили " .. money .. " на 19 до 36")
                    money = money * 2
                    for i = 19, 36 do
                        placeBet(i, money)
                    end
                end
                redrawBets()
            else
                message("Не удалось снять " .. money .. "$: " .. reason)
            end
        end
    end
end

main()

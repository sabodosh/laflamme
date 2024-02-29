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
    buffer.drawRectangle(3,  21, 8,  10, 0xff0000, 0xffffff, ' ')
    buffer.drawText(4, 22, 0xffffff, "К")
    buffer.drawText(5, 23, 0xffffff, "А")
    buffer.drawText(6, 24, 0xffffff, "З")
    buffer.drawText(4, 25, 0xffffff, "И")
    buffer.drawText(5, 26, 0xffffff, "Н")
    buffer.drawText(6, 27, 0xffffff, "О")
end

local function drawStaticNoNumbers()
    buffer.drawRectangle(3, 2, 8, 19, 0xffb109, 0xffffff, ' ')
    buffer.drawRectangle(3, 21, 8, 10, 0xff0000, 0xffffff, ' ')
    buffer.drawText(4, 22, 0xffffff, "К")
    buffer.drawText(5, 23, 0xffffff, "А")
    buffer.drawText(6, 24, 0xffffff, "З")
    buffer.drawText(4, 25, 0xffffff, "И")
    buffer.drawText(5, 26, 0xffffff, "Н")
    buffer.drawText(6, 27, 0xffffff, "О")
end

local function drawCell(i, bet)
    if (i == 0) then
        buffer.drawRectangle(14, 8, 3, 3, 0xffffff, 0x000000, ' ')
        return
    end
    local color = values[i] == 'r' and 0xff0000 or values[i] == 'b' and 0x000000 or 0x00ff00
    buffer.drawRectangle(19 + math.floor((i - 1) / 3) * 7, 2 + ((3 - i) % 3 * 4), 6, 3, color, 0xffffff, ' ')
    if (bet) then
        buffer.drawText(21 + math.floor((i - 1) / 3) * 7, 3 + ((3 - i) % 3 * 4), 0x000000, tostring(bet))
    end
end

local function drawBoard()
    buffer.drawChanges()
    buffer.drawRectangle(103, 20, 9, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(103, 24, 9, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawText(106, 21, 0xffffff, tostring(casino.stack))
    buffer.drawText(106, 25, 0xffffff, tostring(casino.stack10))
    buffer.drawText(103, 20, 0xffffff, "Стек:")
    buffer.drawText(103, 24, 0xffffff, "Стек:")
    buffer.drawRectangle(103, 29, 9, 3, 0x34a513, 0xffffff, ' ')
    buffer.drawRectangle(103, 28, 9, 1, 0x34a513, 0xffffff, ' ')
    buffer.drawText(106, 30, 0xffffff, "Пуск")
    buffer.drawChanges()
end

local function getBetArea(x, y)
    if (x >= 19 and x <= 25 and y >= 2 and y <= 4) then
        return (3 - math.floor((y - 2) / 4)) * 3 - math.floor((25 - x) / 7)
    end
    if (x >= 19 and x <= 25 and y >= 6 and y <= 8) then
        return 3 - math.floor((25 - x) / 7) + (3 - math.floor((y - 6) / 4)) * 3
    end
    if (x >= 19 and x <= 25 and y >= 10 and y <= 12) then
        return 3 - math.floor((25 - x) / 7) + (3 - math.floor((y - 10) / 4)) * 3 + 1
    end
    if (x >= 19 and x <= 45 and y >= 14 and y <= 16) then
        return math.floor((x - 19) / 7) * 3 + 19 - (2 - math.floor((y - 14) / 2))
    end
    if (x >= 47 and x <= 73 and y >= 14 and y <= 16) then
        return math.floor((x - 47) / 7) * 3 + 20 + (2 - math.floor((y - 14) / 2))
    end
    if (x >= 75 and x <= 101 and y >= 14 and y <= 16) then
        return math.floor((x - 75) / 7) * 3 + 20 + (2 - math.floor((y - 14) / 2)) + 12
    end
    if (x >= 19 and x <= 31 and y >= 18 and y <= 20) then
        return math.floor((x - 19) / 7) * 3 + 73
    end
    if (x >= 33 and x <= 45 and y >= 18 and y <= 20) then
        return math.floor((x - 33) / 7) * 3 + 74
    end
    if (x >= 47 and x <= 59 and y >= 18 and y <= 20) then
        return math.floor((x - 47) / 7) * 3 + 75
    end
    if (x >= 75 and x <= 87 and y >= 18 and y <= 20) then
        return math.floor((x - 75) / 7) * 3 + 76
    end
    if (x >= 89 and x <= 101 and y >= 18 and y <= 20) then
        return math.floor((x - 89) / 7) * 3 + 77
    end
    if (x >= 75 and x <= 110 and y >= 25 and y <= 27) then
        return 88
    end
    if (x >= 75 and x <= 110 and y >= 29 and y <= 31) then
        return 89
    end
    if (x >= 103 and x <= 111 and y >= 28 and y <= 31) then
        return 90
    end
    return -1
end

local function drawTable()
    buffer.setResolution(112, 32)
    buffer.clear(0xffffff)
    drawStatic()
    for i, v in pairs(bets) do
        drawCell(i, v)
    end
    drawBoard()
end

local function clearBet(i)
    if (i > 0 and i <= 90 and (i <= 88 or i == 90)) then
        bets[i] = nil
        drawCell(i)
        drawBoard()
        return true
    end
    return false
end

local function clearBets()
    bets = {}
    drawTable()
end

local function setBet(i, stack)
    if (i > 0 and i <= 90 and (i <= 88 or i == 90)) then
        bets[i] = (bets[i] or 0) + stack
        drawCell(i, bets[i])
        drawBoard()
        return true
    end
    return false
end

local function spin()
    casino.spin()
    local roll = casino.result
    local cell = 0
    for i, v in ipairs(wheel) do
        if (v == roll) then
            cell = i
            break
        end
    end
    message("Выпало число " .. roll .. " " .. getNumberPostfix(roll))
    for i, v in pairs(bets) do
        if (i == 0 and roll == 0) then
            casino.pay(i, v, 36)
        elseif (i > 0 and i <= 36 and roll == i) then
            casino.pay(i, v, 36)
        elseif (i == 37 and roll > 0 and roll <= 18) then
            casino.pay(i, v, 2)
        elseif (i == 38 and roll % 2 == 0 and roll > 0 and roll <= 36) then
            casino.pay(i, v, 2)
        elseif (i == 39 and roll % 2 == 1 and roll > 0 and roll <= 36) then
            casino.pay(i, v, 2)
        elseif (i == 40 and roll > 18 and roll <= 36) then
            casino.pay(i, v, 2)
        elseif (i == 41 and roll <= 12) then
            casino.pay(i, v, 3)
        elseif (i == 42 and roll > 12 and roll <= 24) then
            casino.pay(i, v, 3)
        elseif (i == 43 and roll > 24) then
            casino.pay(i, v, 3)
        end
    end
    clearBets()
end

local function addBet(x, y, stack)
    local i = getBetArea(x, y)
    if (i >= 0) then
        if (stack > 0) then
            if (stack > 10 and not casino.stack10) then
                message("Ставки выше 10$ недоступны.")
                return
            end
            if (stack > 1 and not casino.stack) then
                message("Ставки выше 1$ недоступны.")
                return
            end
            if (setBet(i, stack)) then
                message("Ставка на ячейку " .. tostring(i) .. " в размере " .. tostring(stack) .. "$")
            end
        elseif (stack < 0) then
            if (clearBet(i)) then
                message("Ставка на ячейку " .. tostring(i) .. " снята")
            end
        end
    else
        message("Указанная область не является ячейкой ставки.")
    end
end

local function processClick(eventType, _, x, y)
    if (eventType == "touch" or eventType == "drag") then
        if (x >= 103 and x <= 111 and y >= 28 and y <= 31) then
            spin()
            return
        end
        local stack = 1
        if (eventType == "drag") then
            if (y < 21) then
                return
            end
            stack = 10
        end
        addBet(x, y, stack)
    elseif (eventType == "scroll") then
        addBet(x, y, -event[5])
    end
end

buffer.start()
drawStaticNoNumbers()
drawBoard()

event.listen("touch", processClick)
event.listen("drag", processClick)
event.listen("scroll", processClick)

while true do
    os.sleep(0.1)
end

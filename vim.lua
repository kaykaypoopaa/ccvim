local args = {...}
if #args < 1 then
    local programname = args[0] or shell.getRunningProgram()
    print("Usage: " .. programname .. " <file>")
    return
end

-- Error checking
local sPath = shell.resolve(args[1])
local bReadOnly = fs.isReadOnly(sPath)
if fs.exists(sPath) and fs.isDir(sPath) then
    print("Cannot edit a directory.")
    return
end

local x, y = 1, 1
local w, h = term.getSize()
local scrollX, scrollY = 0, 0

local tLines, tLineLexStates = {}, {}
local bRunning = true

-- Colours
local isColour = term.isColour()
local highlightColour, keywordColour, textColour, bgColour, errorColour
if isColour then
    bgColour = colours.black
    textColour = colours.white
    highlightColour = colours.yellow
    keywordColour = colours.yellow
    errorColour = colours.red
else
    bgColour = colours.black
    textColour = colours.white
    highlightColour = colours.white
    keywordColour = colours.white
    errorColour = colours.white
end

local tokens = require "cc.internal.syntax.parser".tokens
local lex_one = require "cc.internal.syntax.lexer".lex_one

local token_colours = {
    [tokens.STRING] = isColour and colours.red or textColour,
    [tokens.COMMENT] = isColour and colours.green or colours.lightGrey,
    [tokens.NUMBER] = isColour and colours.magenta or textColour,
    -- Keywords
    [tokens.AND] = keywordColour,
    [tokens.BREAK] = keywordColour,
    [tokens.DO] = keywordColour,
    [tokens.ELSE] = keywordColour,
    [tokens.ELSEIF] = keywordColour,
    [tokens.END] = keywordColour,
    [tokens.FALSE] = keywordColour,
    [tokens.FOR] = keywordColour,
    [tokens.FUNCTION] = keywordColour,
    [tokens.GOTO] = keywordColour,
    [tokens.IF] = keywordColour,
    [tokens.IN] = keywordColour,
    [tokens.LOCAL] = keywordColour,
    [tokens.NIL] = keywordColour,
    [tokens.NOT] = keywordColour,
    [tokens.OR] = keywordColour,
    [tokens.REPEAT] = keywordColour,
    [tokens.RETURN] = keywordColour,
    [tokens.THEN] = keywordColour,
    [tokens.TRUE] = keywordColour,
    [tokens.UNTIL] = keywordColour,
    [tokens.WHILE] = keywordColour,
}

local function clear(num, num2)
    term.clear()
    if num == nil and num2 == nil then
        term.setCursorPos(1, 1)
    else
        term.setCursorPos(num, num2)
    end
end
clear()


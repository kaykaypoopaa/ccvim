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

local function clear(num, num2)
    term.clear()
    if num == nil and num2 == nil then
        term.setCursorPos(1, 1)
    else
        term.setCursorPos(num, num2)
    end
end
clear()


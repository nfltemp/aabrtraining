--[[
    Creator: NFL Temp
    Description: AA BR Safe Cracking
    Version: 1.0.0
]]

-- State variables
local isKeypadVisible = false
local currentPin = ""
local targetPin = ""
local attempts = 0
local maxAttempts = 999999
local lastGuess = nil
local lastTarget = nil
local startTime = 0
local currentSafeRange = {min = 0, max = 0}
local crackedSafes = {}
local currentSafeMarker = nil

-- Forward declare functions
local hideKeypad
local showKeypad
local createSafeCrackGUI

-- Map Objects Definition
local objects = {
    { model = 14738, interior = 0, dimension = 0, x = 3580.100600, y = -990.799800, z = 4714.399900, rx = 0.000000, ry = 0.000000, rz = 0.000000 },
    { model = 16500, interior = 0, dimension = 0, x = 3576.399900, y = -994.700010, z = 4714.000000, rx = 0.000000, ry = 0.000000, rz = 90.000000 },
    { model = 16500, interior = 0, dimension = 0, x = 3570.100600, y = -988.299800, z = 4713.000000, rx = 0.000000, ry = 0.000000, rz = 0.000000 },
    { model = 2332, interior = 0, dimension = 0, x = 3589.600600, y = -992.099610, z = 4713.600100, rx = 0.000000, ry = 0.000000, rz = -90.000000 },
    { model = 2332, interior = 0, dimension = 0, x = 3589.600600, y = -989.099610, z = 4713.600100, rx = 0.000000, ry = 0.000000, rz = -90.000000 },
    { model = 2332, interior = 0, dimension = 0, x = 3576.300000, y = -994.599980, z = 4713.700200, rx = 0.000000, ry = 0.000000, rz = -180.000000 },
    { model = 1492, interior = 0, dimension = 0, x = 3571.399900, y = -994.799990, z = 4711.799800, rx = 0.000000, ry = 0.000000, rz = 0.000000 },
    { model = 2251, interior = 0, dimension = 0, x = 3589.899900, y = -986.900020, z = 4712.600100, rx = 0.000000, ry = 0.000000, rz = 0.000000 }
}

-- Function to hide keypad (defined first since it's used in GUI creation)
hideKeypad = function()
    if not isKeypadVisible then return end
    isKeypadVisible = false
    if guiWindow then
        guiSetVisible(guiWindow, false)
    end
    showCursor(false)
end

-- Create the GUI
createSafeCrackGUI = function()
    local screenW, screenH = guiGetScreenSize()
    local windowW, windowH = 400, 600  -- Made window thinner
    local windowX = (screenW - windowW) / 2
    local windowY = (screenH - windowH) / 2

    -- Create window
    guiWindow = guiCreateWindow(windowX, windowY, windowW, windowH, "Safe Cracking System", false)
    guiWindowSetSizable(guiWindow, false)
    guiSetVisible(guiWindow, false)

    -- Create exit button (X in top-right corner)
    local exitButton = guiCreateButton(windowW - 30, 25, 20, 20, "X", false, guiWindow)
    
    -- Style the exit button
    guiSetProperty(exitButton, "NormalTextColour", "FFFF0000")
    guiSetProperty(exitButton, "HoverTextColour", "FFFF3333")

    -- Add exit button handler (now hideKeypad is defined)
    addEventHandler("onClientGUIClick", exitButton, hideKeypad, false)

    -- Create label
    guiLabel = guiCreateLabel(20, 40, windowW - 40, 40, 
        "Enter a number between 500,000 - 3,000,000", 
        false, guiWindow)
    guiLabelSetHorizontalAlign(guiLabel, "center")

    -- Add elapsed time label
    local timeLabel = guiCreateLabel(20, 70, windowW - 40, 20, "Time: 0:00", false, guiWindow)
    guiLabelSetHorizontalAlign(timeLabel, "center")

    -- Create edit box (moved down slightly)
    guiEdit = guiCreateEdit(50, 100, windowW - 100, 40, "", false, guiWindow)
    guiEditSetMaxLength(guiEdit, 7)

    -- Add hint label (moved above buttons)
    local hintLabel = guiCreateLabel(20, 140, windowW - 40, 40, "", false, guiWindow)
    guiLabelSetHorizontalAlign(hintLabel, "center")

    -- Create number pad with bigger buttons (adjusted for thinner window)
    local buttonW, buttonH = 70, 70  -- Slightly smaller buttons to fit thinner window
    local startX = (windowW - (buttonW * 3 + 40)) / 2
    local startY = 190
    local padding = 20

    -- Create buttons 1-9
    local numberButtons = {}
    for i = 1, 9 do
        local row = math.floor((i-1) / 3)
        local col = (i-1) % 3
        local x = startX + (buttonW + padding) * col
        local y = startY + (buttonH + padding) * row
        
        local button = guiCreateButton(x, y, buttonW, buttonH, tostring(i), false, guiWindow)
        numberButtons[i] = button
        
        addEventHandler("onClientGUIClick", button, function()
            -- Clear any feedback message first
            local currentText = guiGetText(guiEdit)
            if currentText == "HIGHER" or currentText == "LOWER" or 
               currentText:find("Success") or currentText:find("Please enter") then
                currentText = ""
            end
            guiSetText(guiEdit, currentText .. i)
        end, false)
    end

    -- Bottom row buttons
    local bottomY = startY + (buttonH + padding) * 3

    -- Create clear button
    local clearButton = guiCreateButton(startX, bottomY, 
        buttonW, buttonH, "Clear", false, guiWindow)
    addEventHandler("onClientGUIClick", clearButton, function()
        guiSetText(guiEdit, "")
    end, false)

    -- Create button 0
    local zeroButton = guiCreateButton(startX + buttonW + padding, bottomY, 
        buttonW, buttonH, "0", false, guiWindow)
    addEventHandler("onClientGUIClick", zeroButton, function()
        -- Clear any feedback message first
        local currentText = guiGetText(guiEdit)
        if currentText == "HIGHER" or currentText == "LOWER" or 
           currentText:find("Success") or currentText:find("Please enter") then
            currentText = ""
        end
        guiSetText(guiEdit, currentText .. "0")
    end, false)

    -- Create enter button
    local enterButton = guiCreateButton(startX + (buttonW + padding) * 2, bottomY, 
        buttonW, buttonH, "Enter", false, guiWindow)
    
    -- Enter button handler
    addEventHandler("onClientGUIClick", enterButton, function()
        local guess = tonumber(guiGetText(guiEdit))
        if not guess then
            guiSetText(guiEdit, "Please enter a valid number!")
            playSoundFrontEnd(4)
            return
        end
        
        lastGuess = guess
        lastTarget = tonumber(targetPin)
        
        if guess == lastTarget then
            local elapsed = getTickCount() - startTime
            local seconds = math.floor(elapsed / 1000)
            local minutes = math.floor(seconds / 60)
            seconds = seconds % 60
            
            -- Format time string
            local timeStr = string.format("%d:%02d", minutes, seconds)
            
            -- Show in GUI
            guiSetText(guiEdit, string.format("Success! Time: %s", timeStr))
            playSoundFrontEnd(7)
            
            -- Get player name
            local playerName = getPlayerName(getLocalPlayer())
            
            -- Output to chat
            outputChatBox("=== Safe Cracked Successfully ===", 0, 255, 0)
            outputChatBox("Cracked by: " .. playerName, 0, 255, 0)
            outputChatBox("Time taken: " .. timeStr, 0, 255, 0)
            
            -- Store cracked safe
            table.insert(crackedSafes, currentSafeMarker)
            
            -- Destroy the marker
            if isElement(currentSafeMarker) then
                destroyElement(currentSafeMarker)
            end
            
            setTimer(hideKeypad, 2000, 1)
        else
            if guess < lastTarget then
                guiSetText(guiEdit, "HIGHER")
            else
                guiSetText(guiEdit, "LOWER")
            end
            playSoundFrontEnd(4)
        end
    end, false)

    -- Keyboard handler for enter key
    addEventHandler("onClientKey", root, function(button, press)
        if not isKeypadVisible or not press then return end
        if button == "enter" then
            triggerEvent("onClientGUIClick", enterButton)
        end
    end)

    -- Add timer update
    addEventHandler("onClientRender", root, function()
        if isKeypadVisible then
            local elapsed = getTickCount() - startTime
            local seconds = math.floor(elapsed / 1000)
            local minutes = math.floor(seconds / 60)
            seconds = seconds % 60
            guiSetText(timeLabel, string.format("Time: %d:%02d", minutes, seconds))
        end
    end)
end

-- Function for showing the keypad
showKeypad = function(range)
    if not guiWindow then
        createSafeCrackGUI()
    end
    currentSafeRange = range
    isKeypadVisible = true
    targetPin = tostring(math.random(range.min, range.max))
    startTime = getTickCount()
    guiSetVisible(guiWindow, true)
    showCursor(true)
end

-- Function to create map objects
local function createMapObjects()
    for _, obj in ipairs(objects) do
        local object = createObject(
            obj.model,
            obj.x, obj.y, obj.z,
            obj.rx, obj.ry, obj.rz
        )
        setElementInterior(object, obj.interior)
        setElementDimension(object, obj.dimension)
    end
end

-- Create teleport marker
local function createTeleportMarker()
    local marker = createMarker(
        Config.teleportMarker.pos.x,
        Config.teleportMarker.pos.y,
        Config.teleportMarker.pos.z,
        "arrow",
        Config.teleportMarker.size,
        unpack(Config.teleportMarker.color)
    )
    
    local blip = createBlip(
        Config.teleportMarker.pos.x,
        Config.teleportMarker.pos.y,
        Config.teleportMarker.pos.z,
        41
    )
    
    addEventHandler("onClientMarkerHit", marker, function(hitElement)
        if hitElement == getLocalPlayer() and not isPedInVehicle(hitElement) then
            -- Teleport to a position near the first safe
            local firstSafe = Config.safeMarkers[1].pos
            setElementPosition(hitElement, firstSafe.x, firstSafe.y, firstSafe.z)
            outputChatBox("Find the safes and try to crack them!", 255, 255, 0)
        end
    end)
end

-- Function to generate random PIN
local function generatePin()
    return tostring(math.random(0, 100))
end

-- Create exit marker
local function createExitMarker()
    local marker = createMarker(
        Config.exitMarker.pos.x,
        Config.exitMarker.pos.y,
        Config.exitMarker.pos.z,
        "arrow",  -- Pyramid shape
        Config.exitMarker.size,
        255, 255, 0, 200  -- Yellow, semi-transparent
    )
    
    addEventHandler("onClientMarkerHit", marker, function(hitElement)
        if hitElement == getLocalPlayer() then
            -- Fade camera out
            fadeCamera(false, 1.0)
            
            -- Teleport after fade
            setTimer(function()
                setElementPosition(hitElement, 
                    Config.exitTeleport.x,
                    Config.exitTeleport.y,
                    Config.exitTeleport.z
                )
                -- Fade camera back in
                fadeCamera(true, 1.0)
                outputChatBox("You have left the safe cracking area.", 255, 0, 0)
            end, 1000, 1)
        end
    end)
end

-- Function to create safe markers
local function createSafeMarkers()
    for _, markerData in ipairs(Config.safeMarkers) do
        if not crackedSafes[markerData.pos.x] then
            local marker = createMarker(
                markerData.pos.x,
                markerData.pos.y,
                markerData.pos.z,
                "arrow",
                1.0,
                255, 0, 0, 200
            )
            setElementData(marker, "isSafeMarker", true)
            
            addEventHandler("onClientMarkerHit", marker, function(hitElement)
                if hitElement == getLocalPlayer() and not isPedInVehicle(hitElement) then
                    currentSafeMarker = marker -- Store current marker
                    showKeypad(markerData.range)
                end
            end)
        end
    end
end

-- Initialize everything when resource starts
addEventHandler("onClientResourceStart", resourceRoot, function()
    createMapObjects()
    createTeleportMarker()
    createExitMarker()
    createSafeMarkers()
end)

-- Cleanup on resource stop
addEventHandler("onClientResourceStop", resourceRoot, function()
    if isElement(guiWindow) then
        destroyElement(guiWindow)
    end
end)

-- Key binding to close GUI
bindKey("escape", "down", function()
    if isKeypadVisible then
        hideKeypad()
    end
end)

-- Debug command for getting safe code
addCommandHandler("getsafecode", function()
    if isKeypadVisible and targetPin then
        outputChatBox("Safe Code: " .. targetPin, 255, 255, 0)
    else
        outputChatBox("No safe is currently being cracked!", 255, 0, 0)
    end
end)

-- Reset command
addCommandHandler("resetsafes", function()
    -- Clear cracked safes table
    crackedSafes = {}
    
    -- Destroy any existing markers
    local markers = getElementsByType("marker")
    for _, marker in ipairs(markers) do
        if getElementData(marker, "isSafeMarker") then
            destroyElement(marker)
        end
    end
    
    -- Recreate all safe markers
    createSafeMarkers()
    
    outputChatBox("All safes have been reset!", 255, 255, 0)
end)

--[[
    Commands:
    /getsafecode - Shows the current safe code (Debug)
    /resetsafes - Resets all safe markers
]]

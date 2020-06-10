--[[
	Placemarker
	Author: Rafael
	Date: 6/3/20
	Notes: This script must be run within SOTA in order to make  API calls,
	i.e. it will not work in an IDE. Any functions or globals that begin with "Shroud"
	are maintained on the SOTA server, and are not visible in a local IDE.
]] --
function ShroudOnStart()
    SetAssets()
    VERSION = "1.0"
    OPS = "Win10"
    LUA = "Lua 5.1.5"
    DATAPATH = ShroudDataPath .. "\\Portalarium\\Shroud of the Avatar\\Lua"
    CHARACTER = ShroudGetPlayerName()
    MYPOITABLE = {}
    ROWTABLE = {}
    TRACK = {}
    SCREEN_H = 0
    SCREEN_W = 0
    Color = "ffffff"
    X = 0
    Y = 0
    TableFontSize = 20
    Pad = 40
    TableOn = 1 -- Toggle table visibility, 1/0
    Viscolor = "#008000"

    ShroudConsoleLog(" ")
    ShroudConsoleLog(string.format("- - -"))
    ShroudConsoleLog(string.format("Placemarker Addon"))
    ShroudConsoleLog(string.format("Version: %s", VERSION))
    ShroudConsoleLog(string.format("Tested on %s/%s", OPS, LUA))
    ShroudConsoleLog(string.format("The current time is %s", TimeStamp()))
    ShroudConsoleLog(string.format("Send gifts to [00ffff]Rafael[ffffff]"))
    ShroudConsoleLog("- - -")
    ShroudConsoleLog(" ")
    ShroudConsoleLog(string.format("Greetings, %s", CHARACTER))
    ShroudConsoleLog(" ")
    ShroudConsoleLog(string.format("Type in local: <!pmhelp> for list of commands"))
    ShroudConsoleLog(" ")
end

function ShroudOnConsoleInput(channel, source, message)
    if channel == "Local" and source == string.match(CHARACTER, source) then
        if string.match(message, "!mark") then
            local _, label_text = string.find(message, "!mark")
            local subString = string.sub(message, label_text + 1)
            GrabLocation(subString)
            PrintConsole(MYPOITABLE)
        end
        if string.match(message, "!pmsave") then
            SaveLocations(MYPOITABLE)
        end
        if string.match(message, "!pmload") then
            LoadSavedLocations()
        end
        if string.match(message, "!pmhelp") then
            Help()
        end
    end
end

function ShroudOnUpdate()
end

function ShroudOnGUI()
    SCREEN_W = ShroudGetScreenX()
    SCREEN_H = ShroudGetScreenY()
    local butt_width = TableFontSize * 5
    local butt_height = TableFontSize * 5
    DrawTable()
    if
        ShroudButton(
            SCREEN_W - (butt_width),
            SCREEN_H - (butt_height),
            butt_width,
            butt_height,
            TransTexture,
            string.format("<size=%d>Mark</size>", TableFontSize),
            "Mark"
        ) == true
     then
        ConsoleLog("POI Recorded")
        local newLocation = GrabLocation("NA")
        PrintConsole(newLocation)
    end

    if
        ShroudButton(
            SCREEN_W - (butt_width * 2),
            SCREEN_H - (butt_height),
            butt_width,
            butt_height,
            TransTexture,
            string.format("<size=%d>Size +</size>", TableFontSize),
            "Increase"
        ) == true
     then
        TableFontSize = TableFontSize + 1
        Pad = TableFontSize * 2.5
    end

    if
        ShroudButton(
            SCREEN_W - (butt_width * 3),
            SCREEN_H - (butt_height),
            butt_width,
            butt_height,
            TransTexture,
            string.format("<size=%d>Size -</size>", TableFontSize),
            "Decrease"
        ) == true
     then
        TableFontSize = TableFontSize - 1
        Pad = TableFontSize * 2
    end

    if
        ShroudButton(
            SCREEN_W - (butt_width * 4),
            SCREEN_H - (butt_height),
            butt_width,
            butt_height,
            TransTexture,
            string.format("<size=%d><color=%s>Vis</color></size>", TableFontSize, Viscolor),
            "Show/Hide Table"
        ) == true
     then
        -- Toggle Visibility of Table
        TableOn = math.abs(TableOn - 1)

        if TableOn == 1 then
            Viscolor = "#008000"
        else
            Viscolor = "#b80c2e"
        end
    end
    if
        ShroudButton(
            SCREEN_W - (butt_width * 5),
            SCREEN_H - (butt_height),
            butt_width,
            butt_height,
            TransTexture,
            string.format("<size=%d>Save</size>", TableFontSize),
            "Save to file"
        ) == true
     then
        SaveLocations(MYPOITABLE)
    end

    if
        ShroudButton(
            SCREEN_W - (butt_width * 6),
            SCREEN_H - (butt_height),
            butt_width,
            butt_height,
            TransTexture,
            string.format("<size=%d>Load</size>", TableFontSize),
            "Load from file"
        ) == true
     then
        LoadSavedLocations()
    end
    if
        ShroudButton(
            SCREEN_W - (butt_width * 7),
            SCREEN_H - (butt_height),
            butt_width,
            butt_height,
            TransTexture,
            string.format("<size=%d>Clear</size>", TableFontSize),
            "Clear table"
        ) == true
     then
        MYPOITABLE = {}
        TRACK = {}
    end

    if #TRACK > 0 then
        -- ensure the selected track is in the same scene,
        if TRACK[1][2] == ShroudGetCurrentSceneName() then
            local dist = Distance()
            ShroudGUILabel(
                (SCREEN_W / 2) - 50,
                (SCREEN_H / 2.1),
                300,
                200,
                string.format("<size=%d><color=#00ff00>%.1f</color></size>", TableFontSize, dist)
            )
        else
            ShroudGUILabel(
                (SCREEN_W / 2) - 300,
                (SCREEN_H / 2.1),
                600,
                100,
                string.format(
                    "<size=%d><color=#ff0000>Tracked placemark is not in this scene</color></size>",
                    TableFontSize
                )
            )
        end
    end
end

function PrintConsole(tbl)
    for i, v in pairs(tbl) do
        ShroudConsoleLog(string.format("T: %s", v[1]))
        ShroudConsoleLog(string.format("Scene: %s", v[2]))
        ShroudConsoleLog(string.format("Label: %s", v[3]))
        ShroudConsoleLog(string.format("X: %s", v[4]))
        ShroudConsoleLog(string.format("Y: %s", v[5]))
        ShroudConsoleLog(string.format("Z: %s", v[6]))
    end
end

function GrabLocation(label)
    local scene = ShroudGetCurrentSceneName()
    local X = ShroudPlayerX
    local Y = ShroudPlayerY
    local Z = ShroudPlayerZ
    -- write new entry into the global table
    table.insert(MYPOITABLE, {TimeStamp(), scene, label, X, Y, Z, "#ffffff"})
    ShroudConsoleLog(string.format("Placemark #: %d", #MYPOITABLE))
    -- return the new line in case we need to do something else with it... such as print
    return {{TimeStamp(), scene, label, X, Y, Z}}
end

function SetAssets()
    ButtonTexture = ShroudLoadTexture("/Placemarker/assets/button.png")
    BGTexture = ShroudLoadTexture("Placemarker/assets/bg.png")
    BorderTexture = ShroudLoadTexture("Placemarker/assets/border.png")
    TransTexture = ShroudLoadTexture("Placemarker/assets/transparent_1x1.png")
end

function TimeStamp()
    return os.date("%m-%d-%Y|%H:%M:%S")
end

function DrawTable()
    local x = (SCREEN_W * .66) -- - (width * .5)
    local y = (SCREEN_H * .15) -- + (height * .5)
    local smallButtWidth = TableFontSize * 1.5
    local smallButtHeight = TableFontSize * 1.5
    local w = SCREEN_W * .33
    local h = SCREEN_H * .1

    for i, v in ipairs(MYPOITABLE) do
        local row = y + (i * Pad)
        local col = x
        -- Record the row Y-coordinate.
        -- I use this table to detect if a click was made close enough to the row
        ROWTABLE[i] = row
        -- The buttons
        if TableOn == 1 then
            if
                ShroudButton(
                    col - Pad,
                    row,
                    smallButtWidth,
                    smallButtHeight,
                    TransTexture,
                    string.format("<size=%d>X</size>", TableFontSize),
                    "Delete"
                ) == true
             then
                for index, buttrow in ipairs(ROWTABLE) do
                    -- find the row the button was near in ROWTABLE - using 10 px
                    if math.abs((ShroudMouseY - (buttrow + (smallButtHeight / 2)))) < 10 then
                        ShroudConsoleLog(string.format("Removed %s", MYPOITABLE[index][3]))
                        table.remove(MYPOITABLE, index)
                    end
                end
            end
            if
                ShroudButton(
                    col - Pad * 2,
                    row,
                    smallButtWidth,
                    smallButtHeight,
                    TransTexture,
                    string.format("<size=%d>T</size>", TableFontSize),
                    "Track"
                ) == true
             then
                for index, buttrow in ipairs(ROWTABLE) do
                    -- what a shitshow
                    -- find what row the click was near - using 10 px
                    if math.abs((ShroudMouseY - (buttrow + (smallButtHeight / 2)))) < 10 then
                        -- if the placemark is already being tracked, then clear it
                        if index == TRACK[2] then
                            -- otherwise assign a new placemark to the track table
                            TRACK = {}
                            MYPOITABLE[index][7] = "#ffffff"
                        elseif TRACK[2] then
                            MYPOITABLE[TRACK[2]][7] = "#ffffff"
                            TRACK = {}
                        else
                            TRACK[1] = MYPOITABLE[index]
                            TRACK[2] = index
                            -- set new flaged row to gold
                            MYPOITABLE[index][7] = "#ffd700"
                            ShroudConsoleLog(
                                string.format(
                                    "Tracking: %s, %.1f, %.1f, %.1f",
                                    TRACK[1][3],
                                    TRACK[1][4],
                                    TRACK[1][5],
                                    TRACK[1][6]
                                )
                            )
                        end
                    end
                end
            end
            if
                ShroudButton(
                    col - Pad * 3,
                    row,
                    smallButtWidth,
                    smallButtHeight,
                    TransTexture,
                    string.format("<size=%d>&</size>", TableFontSize),
                    "Append to file"
                ) == true
             then
                for index, buttrow in ipairs(ROWTABLE) do
                    -- find the row the button was near in ROWTABLE -- Using 10 px
                    if math.abs((ShroudMouseY - (buttrow + (smallButtHeight / 2)))) < 10 then
                        --ShroudConsoleLog(string.format("Append placemark %s to file", MYPOITABLE[index][3]))
                        Append(MYPOITABLE[index])
                    end
                end
            end
        end
        -- Global TableOn is toggled by the Vis button in the GUI
        if TableOn == 1 then
            ShroudGUILabel(
                col,
                row,
                w,
                h,
                string.format(
                    "<size=%d><color=%s>D:%s Scene: %s Label:%s X:%.1f Y:%.1f Z:%.1f</color></size>",
                    TableFontSize,
                    v[7],
                    v[1],
                    v[2],
                    v[3],
                    v[4],
                    v[5],
                    v[6]
                )
            )
        end
    end
end

function Distance()
    local pX = ShroudPlayerX
    local pY = ShroudPlayerY
    local pZ = ShroudPlayerZ

    local deltaX = math.abs(pX - TRACK[1][4])
    local deltaY = math.abs(pY - TRACK[1][5])
    local deltaZ = math.abs(pZ - TRACK[1][6])

    return math.sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ))
end

function SaveLocations(tbl)
    local file = io.open(DATAPATH .. "\\Placemarker\\data\\places.txt", "w")
    for i, v in ipairs(tbl) do
        local line =
            string.format(
            "<D>%s</D> <SCENE>%s</SCENE> <LABEL>%s</LABEL> <X>%.1f</X> <Y>%.1f</Y> <Z>%.1f</Z> <C>%s</C>\n",
            v[1],
            v[2],
            v[3],
            v[4],
            v[5],
            v[6],
            v[7]
        )
        file:write(line)
    end
    ShroudConsoleLog(string.format("[ffd700]Saved %s places[ffffff]", #tbl))
    file:close()
    --
end

function LoadSavedLocations()
    -- clear the table, hope you saved it!
    MYPOITABLE = {}
    local temp = {}
    -- parse text file by these tags
    local tags = {
        {"<C>", "</C>"},
        {"<Z>", "</Z>"},
        {"<Y>", "</Y>"},
        {"<X>", "</X>"},
        {"<LABEL>", "</LABEL>"},
        {"<SCENE>", "</SCENE>"},
        {"<D>", "</D>"}
    }

    local filePath = DATAPATH .. "\\Placemarker\\data\\places.txt"
    local file = io.open(filePath, "rb")
    if file then
        file:close()

        -- Make a lua table
        local rowNumber = 1
        for line in io.lines(filePath) do
            local lineTable = {}
            for _, tag in ipairs(tags) do
                local _, tagOpen = string.find(line, tag[1])
                local tagClose, _ = string.find(line, tag[2])
                table.insert(lineTable, 1, string.sub(line, tagOpen + 1, tagClose - 1))
            end
            table.insert(MYPOITABLE, rowNumber, lineTable)
            rowNumber = rowNumber + 1
        end
        ShroudConsoleLog(string.format("[ffd700]Loaded %s places[ffffff]", #MYPOITABLE))
    else
        ShroudConsoleLog(string.format "[ff0000]Could not find places.txt[ffffff]")
    end
end

function Append(row)
    local line =
        string.format(
        "<D>%s</D> <SCENE>%s</SCENE> <LABEL>%s</LABEL> <X>%.1f</X> <Y>%.1f</Y> <Z>%.1f</Z> <C>%s</C>\n",
        row[1],
        row[2],
        row[3],
        row[4],
        row[5],
        row[6],
        row[7]
    )
    -- I cannot open the file in append mode. IDK why.
    -- Using a different approach. Open in r+, go to the end, then insert new line.
    local file = io.open(DATAPATH .. "\\Placemarker\\data\\places.txt", "r+")
    file:seek("end", 0)
    file:write(line)
    file:close()
    ShroudConsoleLog(string.format("[ffd700]Appended %s to your file[ffffff]", row[3]))
end

function Help()
    ShroudConsoleLog(" ")
    ShroudConsoleLog("Helping you...")
    ShroudConsoleLog(string.format("Type commands in local chat"))
    ShroudConsoleLog(string.format("- - -"))
    ShroudConsoleLog(string.format("Type: <!pmhelp> for list of commands"))
    ShroudConsoleLog(string.format("Type: <!pmsave> saves placemarks on your screen to a file"))
    ShroudConsoleLog(string.format("Type: <!pmload> loads placemarks from file"))
    ShroudConsoleLog(string.format("Type: <!mark some label> to manually enter a labelled placemark"))
    ShroudConsoleLog(string.format("Type: </lua unload> to remove the addon"))
    ShroudConsoleLog(string.format("Type: </lua reload> to reload the addon; and resets it"))
    ShroudConsoleLog(string.format(" "))
    ShroudConsoleLog(string.format("Button commands"))
    ShroudConsoleLog(string.format("- - -"))
    ShroudConsoleLog(string.format("[Mark] button to record without label"))
    ShroudConsoleLog(string.format("[X] to delete row from on-screen table"))
    ShroudConsoleLog(string.format("[T] to track distance to that placemark"))
    ShroudConsoleLog(string.format("[&] to append a single row to the data file"))
    ShroudConsoleLog(string.format("[Clr] to clear on-screen data table. Will not affect saved file"))
    ShroudConsoleLog(string.format("[Vis] toggle visibility of on-screen data table"))
    ShroudConsoleLog(string.format("[Save] to overwrite and save data file with on-screen data. Be careful"))
    ShroudConsoleLog(string.format("[Load] to clear on-screen data table and load places from file. Be careful"))
end
--// Streekaiz was here

local cloneref = cloneref and cloneref or function(...) return ... end 
local gethui = (gethui and gethui()) or cloneref(game:GetService("CoreGui")) 

local players = cloneref(game:GetService("Players"))
local runService = cloneref(game:GetService("RunService"))

local localPlayer = players.LocalPlayer 
local camera = workspace.CurrentCamera 
local viewportSize = camera.ViewportSize 

local findFirstChild = workspace.FindFirstChild

local library = {
    instances = {},
    client = {
        fps = 60,
        ping = 100,
        mem = 200
    },
    localPlayer = {
        name = localPlayer.DisplayName,
        vel = 0,
        pos = {0, 0, 0},
        title = "mont3r.lua",
        build = "user",
        version = "1.0.0"
    },
    closestPlayer = {
        name = "",
        health = 100,
        vel = 0,
        distance = 0,
        pos = {0, 0, 0},
        vis = false,
        friendly = false 
    },
    settings = {
        font,
        size = 13,
        image = "",
        gradient = { },
        accent = Color3.fromRGB(255, 100, 100),
        text = Color3.fromRGB(255, 255, 255)
    }
}

function library:create(instance, properties)
    local obj = Instance.new(instance)

    for i, v in pairs(properties) do
        obj[i] = v
    end

    self[1][#self[1] + 1] = obj

    return obj
end

function library:unload()
    for i, v in ipairs(self[1]) do 
        v:Destroy()
    end 
end 

function library:isAlive(player)
    local char = player.Character 
    if char then 
        local root, humanoid = findFirstChild(char, "HumanoidRootPart"), findFirstChild(char, "Humanoid")

        if root and humanoid then 
            if humanoid.Health > 0 then 
                return true, player, char, root, humanoid 
            end 
        end 
    end 

    return false, nil, nil, nil, nil 
end 

function library:isFriendly(player)
    return (player.Team == localPlayer.Team)
end 

function library:randomString(name)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, 10 do
        local randIndex = math.random(1, #charset)
        result = result .. string.sub(charset, randIndex, randIndex)
    end
    return name .. result
end

if not isfile("proggyclean.ttf") then 
    writefile("proggyclean.ttf", game:HttpGet("https://github.com/Streekaiz/assets/raw/refs/heads/main/Fonts/ProggyTiny.ttf"))
end 
    
if not isfile("proggyclean_encoded.ttf") then 
    writefile("proggyclean_encoded.ttf", game:GetService("HttpService"):JSONEncode({ 
        name = "ProggyTiny", 
        faces = { 
            { 
                name = "Regular", 
                weight = 400, 
                style = "normal", 
                assetId = getcustomasset("proggyclean.ttf") 
            } 
        } 
    }))
end 

library[5].font = Font.new(getcustomasset("proggyclean_encoded.ttf"), Enum.FontWeight.Regular)

local screenGui = library:create("ScreenGui", {
    Name = library:randomString("screenGui"),
    Parent = gethui()
})

local title = library:create("TextLabel", {
    Name = library:randomString("title"),
    Text = library[3].title .. " | build: " .. library[3].build  .. " | v" .. library[3].version,
    FontFace = library[5].font,
    Parent = screenGui 
})

local content = library:create("TextLabel", {
    Name = library:randomString("content"),
    FontFace = library[5].font, 
    Text = [[
        local player
        > username: 
        > velocity:
        > position:
    ]],
    Parent = screenGui 
})

local closestPlayerContent = library:create("TextLabel", {
    Name = library:randomString("closestPlayerContent"),
    FontFace = library[5].font,
    Text = [[
        closest player
        > username:
        > velocity:
        > position:
        > distance:
    ]],
    Parent = screenGui
})

local titleGradient = library:create("UIGradient", {
    Parent = title,
    Name = library:randomString("titleGradient"),
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, library[5].text),
        ColorSequenceKeypoint.new(0.01, library[5].accent),
        ColorSequenceKeypoint.new(1, library[5].text)
    }
})

library.connection = runService.RenderStepped:Connect(function(delta)
    local player, char, root, humanoid = library:isAlive(localPlayer)
    if player and root then 
        content.Text = string.format("local player\n> name: %s\n> velocity: %s\n>position: %s", player.Name, tostring(root.Velocity), tostring(root.Position))
    end 
end)

--// gonna modify this for my neverlose UI remake so i dont have to make one from scratch — too lazy now after 2 months working on the UI lib - corelorax

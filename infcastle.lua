local HttpService = game:GetService("HttpService")
local Webhook = ""
local LobbyPlaceId = 12886143095
local playerStatsFolder = "PlayerStats"

local function getPlayerStatsFile(playerName)
    return playerStatsFolder.."/"..playerName..".PlayerStats.json"
end

local function WebhookUpdate(playerName, playerLevel, emeralds, gold, rerolls, als_jewels, rewards)
    local response = syn.request({
        Url = Webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "ETERNAL SERVICES", 
                ["description"] = "**User:** ||" .. playerName .. "||\n**Level:** " .. playerLevel,
                ["type"] = "rich",
                ["color"] = tonumber("fee82e", 16),
                ["fields"] = {
                    {
                        ["name"] = "Player Stats",
                        ["value"] = "<:emerald:1222174635538387030> " .. emeralds .. "\n<:gold:1266978912781733982> " .. gold .. "\n<:rr:1249518860135174144>" .. rerolls .. "\n<:jewel:1265957882453561354> " .. als_jewels,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Rewards",
                        ["value"] = rewards,
                        ["inline"] = true
                    }
                }
            }}
        })
    })
end

local function savePlayerStats(playerName, playerLevel, emeralds, gold, rerolls, als_jewels, rewards)
    local playerStats = {
        playerName = playerName,
        playerLevel = playerLevel,
        emeralds = emeralds,
        gold = gold,
        rerolls = rerolls,
        als_jewels = als_jewels,
        rewards = rewards
    }

    local jsonData = HttpService:JSONEncode(playerStats)
    local playerStatsFile = getPlayerStatsFile(playerName)

    -- Create the folder if it doesn't exist
    if not isfolder(playerStatsFolder) then
        makefolder(playerStatsFolder)
    end

    -- Save player stats to a JSON file
    writefile(playerStatsFile, jsonData)
end

local function loadPlayerStats(playerName)
    local playerStatsFile = getPlayerStatsFile(playerName)
    if isfile(playerStatsFile) then
        local jsonData = readfile(playerStatsFile)
        local playerStats = HttpService:JSONDecode(jsonData)
        return playerStats
    else
        -- Handle the case where the file doesn't exist
        return {
            playerName = playerName,
            playerLevel = 0,
            emeralds = 0,
            gold = 0,
            rerolls = 1,
            als_jewels = 0,
            rewards = "+1 Reroll"
        }
    end
end

local function UpdatePlayerStats()
    local player = game.Players.LocalPlayer
    local playerName = player.DisplayName

    -- Fetch player data from the game
    local playerLevel = player.Level.Value
    local emeralds = player.Emeralds.Value
    local gold = player.Gold.Value
    local rerolls = player.Rerolls.Value
    local als_jewels = player.Jewels.Value
    local rewards = ""

    -- Save player stats
    savePlayerStats(playerName, playerLevel, emeralds, gold, rerolls, als_jewels, rewards)
    
    -- Send webhook update
    WebhookUpdate(playerName, playerLevel, emeralds, gold, rerolls, als_jewels, rewards)
end

local function JoinINFCastle()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local position = Vector3.new(28.3693733, 2.72691631, -40.4032669)
    local lookVector = Vector3.new(-0.766061664, 0, 0.642767608)
    local upVector = Vector3.new(0, 1, 0)
    local rightVector = lookVector:Cross(upVector)
    
    local InfinityCastleManager = CFrame.fromMatrix(position, rightVector, upVector)
    
    humanoidRootPart.CFrame = InfinityCastleManager
    
    wait(2)
    local args = {
        [1] = "Play",
        [2] = 5
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("InfiniteCastleManager"):FireServer(unpack(args))
end

local function UpdateInGameStats()
    local player = game.Players.LocalPlayer
    local playerName = player.DisplayName

    -- Retrieve player stats from the JSON file and update
    local playerStats = loadPlayerStats(playerName)

    -- Increment rerolls and reset rewards
    local rerolls = playerStats.rerolls + 1
    local rewards = "+1 Reroll"

    -- Save updated player stats
    savePlayerStats(playerName, playerStats.playerLevel, playerStats.emeralds, playerStats.gold, rerolls, playerStats.als_jewels, rewards)
    
    -- Send webhook update
    WebhookUpdate(playerName, playerStats.playerLevel, playerStats.emeralds, playerStats.gold, rerolls, playerStats.als_jewels, rewards)
end


local function SpawnUnit1()
    -- VoteSpeed
    local args = {
        [1] = true
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("VoteChangeTimeScale"):FireServer(unpack(args))

    -- Spawn
    local unit = game:GetService("Players")[game.Players.LocalPlayer.Name].Slots.Slot1
    local unitname = unit.Value
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local args = {
        [1] = unitname,
        [2] = CFrame.new(-135.04019165039062, 197.93942260742188, 10.85269546508789, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlaceTower"):FireServer(unpack(args))

    -- CPU + GPU SAVER
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local part = Instance.new("Part")
    
    part.Size = Vector3.new(4, 1, 4) 
    part.Anchored = true 
    part.Position = humanoidRootPart.Position - Vector3.new(0, humanoidRootPart.Size.Y / 2 + part.Size.Y / 2, 0)
    part.Parent = game.Workspace
    
    game.Workspace.PlaceOn:Destroy()
    game.Workspace.Enemies:Destroy()

    local function GameEnded()
        local IsGameEnded = player.PlayerGui:FindFirstChild("EndGameUI")
        return IsGameEnded ~= nil
    end

    repeat wait(10)
        local tower = workspace:FindFirstChild("Towers"):FindFirstChild(unitname)
        if tower then
            local upgradeArgs = {
                [1] = tower
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Upgrade"):InvokeServer(unpack(upgradeArgs))
        end
    until GameEnded()
    
    if GameEnded() then
        local function activateRetryButton()
            local EndGameUI = player.PlayerGui:FindFirstChild("EndGameUI")
            if EndGameUI then
                local RetryButton = EndGameUI.BG.Buttons:FindFirstChild("Retry")
                if RetryButton then
                    RetryButton.Visible = true
                    RetryButton.Active = true
                    return true
                end
            end
            return false
        end
        activateRetryButton()

        UpdateInGameStats()

        local vim = game:GetService("VirtualInputManager")
    
        local function retry()
            vim:SendKeyEvent(true, Enum.KeyCode.BackSlash, false, game)
            vim:SendKeyEvent(false, Enum.KeyCode.BackSlash, false, game)
            
            vim:SendKeyEvent(true, Enum.KeyCode.Down, false, game)
            vim:SendKeyEvent(false, Enum.KeyCode.Down, false, game)
            vim:SendKeyEvent(true, Enum.KeyCode.Down, false, game)
            vim:SendKeyEvent(false, Enum.KeyCode.Down, false, game)
            vim:SendKeyEvent(true, Enum.KeyCode.Right, false, game)
            vim:SendKeyEvent(false, Enum.KeyCode.Right, false, game)
            
            while task.wait(2) do
                vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end
    
        retry()
    end
end

if game.PlaceId == LobbyPlaceId then
    UpdatePlayerStats()
    JoinINFCastle()
else 
    SpawnUnit1()
end


loadstring(game:HttpGet('https://raw.githubusercontent.com/eternalrinn/RinnInfinityCastle5/main/infcastle.txt'))()

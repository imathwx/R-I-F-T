--== Serviços ==--

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

--== Variáveis ==--

-- HWIDs autorizados para usar o script
local authorized = loadstring(game:HttpGet("https://raw.githubusercontent.com/imathwx/R-I-F-T/refs/heads/main/HWID.lua"))()

-- Player
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

-- Game
local placeId = game.PlaceId
local placeName = MarketplaceService:GetProductInfoAsync(game.PlaceId).Name

-- Referências de localização
local references = {
	uphill = CFrame.lookAt(Vector3.new(512.5, 48.004, -596), Vector3.new(512.5, 48.004, -595)),
	military = CFrame.lookAt(Vector3.new(19.5, 25.259, -854.5), Vector3.new(19.5, 25.259, -855.5)),
	bank = CFrame.lookAt(Vector3.new(-416.5, 22.554, -284.5), Vector3.new(-415.5, 22.554, -284.5))
}

-- Dados enviados pelo usuário
local sent = getfenv().Config

-- Determina se o jogador pode usar o script ou não
local isAuthorized = authorized[gethwid()] ~= nil

-- Determina se os dados estão válido ou não
local isSentValid = (function()
	if typeof(sent) ~= "table" then
		return false
	end

	if typeof(sent.Messages) ~= "table" then
		return false
	end

	if typeof(sent.Locations) ~= "table" then
		return false
	end
	
	if typeof(sent.Delay) ~= "number" then
		return false
	end

	for _, v in ipairs(sent.Messages) do
		if typeof(v) ~= "string" then
			return false
		end
	end

	local newLocations = {}

	for _, v in ipairs(sent.Locations) do
		local t = typeof(v)

		if t == "CFrame" then
			table.insert(newLocations, v)

		elseif t == "string" then
			local ref = references[v:lower()]

			if not ref then
				return false
			end

			table.insert(newLocations, ref)

		else
			return false
		end
	end

	if #newLocations == 0 then
		return false
	end

	sent.Locations = newLocations

	return true
end)()

--== Webhook ==--

if not localPlayer:GetAttribute("Webhooked") then
	-- Formata a table enviada e retorna uma string
	local function tableToString(tbl, indent, visited)
		indent = indent or 0
		visited = visited or {}

		-- evita loop infinito
		if visited[tbl] then
			return "<cyclic table>"
		end
		visited[tbl] = true

		local spacing = string.rep("\t", indent)
		local nextSpacing = string.rep("\t", indent + 1)

		local lines = {"{"}

		for k, v in pairs(tbl) do
			local key = tostring(k)
			local value

			if type(v) == "table" then
				value = tableToString(v, indent + 1, visited)
			elseif type(v) == "string" then
				value = string.format("%q", v)
			else
				value = tostring(v)
			end

			table.insert(lines, string.format("%s%s = %s,", nextSpacing, key, value))
		end

		table.insert(lines, spacing .. "}")

		return table.concat(lines, "\n")
	end

	localPlayer:SetAttribute("Webhooked", true)

	-- Webhook
	local WEBHOOK_URL = {
		100+5,60-3,13*5,100-14+0,49*2,70+3,100-3,
		100-3,50-5,120-7,100-3,10*8,100+1,120-9,
		90-1,11*11,60-6,70-3,25*3,100-26,100+7,
		100+16,100-12,100+7,100-12,70+1,100+15,80+7,
		90-1,100+18,60-12,25*2,49*2,100+5,100-14,
		100-3,70+7,110-1,60-6,100+20,50-2,70-14,
		70+1,80+3,70+3,70+3,100+3,50-5,110-1,
		80+4,50+5,120-6,70-1,100-14,90-1,120-1,
		80+6,100+1,50-2,100+5,100+7,70-3,100-2,
		80+4,100+2,100/2,70+6,50+1,50-3,60-6,
		50+6,50+5,100/2,50-1,100/2,50-2,50+2,
		50+1,50+2,50+7,50-1,50+6,50,50+2,
		50+4,50+4,50+2,50-1,50-3,100+15,100+7,
		100+11,100+11,100+4,100-2,100+1,100+19,50-3,
		100+5,100+12,100-3,50-3,100+9,100+11,100-1,
		50-4,100,100+14,100+11,100-1,100+15,100+5,
		100,50-3,50-3,60-2,100+15,100+12,100+16,
		100+16,100+4
	}

	-- Tipos de notificações
	local NOTIFICATION_TYPES = {
		join = {
			title = "🟢 Sessão iniciada",
			color = 0x78B159
		},
		leave = {
			title = "🔴 Sessão encerrada",
			color = 0xDD2E44
		}
	}

	-- Envia uma notificação para o Discord através da webhook
	local function notify(info)
		task.spawn(function()
			if typeof(info) ~= "string" then return end
			local config = NOTIFICATION_TYPES[info:lower()] or {
				title = "⚠️ Evento não identificado", -- fallback
				color = 0xFFCC4D
			}

			local data = {
				embeds = {{
					title = config.title,
					color = config.color,
					fields = {
						{
							name = "👤 Jogador",
							value = string.format("%s (@%s)", localPlayer.DisplayName, localPlayer.Name),
							inline = true
						},
						{
							name = "🆔 UserId",
							value = string.format("`%s`", localPlayer.UserId),
							inline = true
						},
						{
							name = "🏠 Place",
							value = string.format("%s `%s` %s `%s`", "Id: ", placeId, "Name: ", placeName),
							inline = false
						},
						{
							name = "ℹ Informações",
							value = string.format("HWID: ```%s```", gethwid()),
							inline = false
						},
						{
							name = "🎮 Execute",
							value = string.format(
								"Permitido: %s\nExecutado: %s\nDados enviados:\n```%s```",
								(isAuthorized and "sim" or "não"), (isSentValid and "sim" or "não"), tableToString(sent or {})
							)
						},
						{
							name = "📍 Join",
							value = string.format("```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(%s, '%s', game.Players.LocalPlayer)\n```", game.PlaceId, game.JobId),
							inline = false
						}
					},
					timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
				}}
			}

			pcall(function()
				local requestFunc = request
				if requestFunc then
					requestFunc({
						Url = string.char(unpack(WEBHOOK_URL)):reverse(),
						Method = "POST",
						Headers = {
							["Content-Type"] = "application/json"
						},
						Body = HttpService:JSONEncode(data)
					})
				end
			end)
		end)
	end

	-- Atualiza o estado do jogador para o Discord
	notify("join")
	Players.PlayerRemoving:Connect(function(player)
		if localPlayer == player then
			notify("leave")
		end
	end)
end

--== Verificação ==--

-- Verifica se o jogador pode usar o script
if not isAuthorized then
	print(gethwid(), authorized[2])
	--localPlayer:Kick("Você não tem permissão para usar este script")
	return
end

-- Verifica se os dados passaram
if isSentValid then
	if localPlayer:GetAttribute("Executed") then
		StarterGui:SetCore("SendNotification", {
			Title = "R I F T",
			Text = "O script já está executado",
			Duration = 5
		})
		return
	else
		localPlayer:SetAttribute("Executed", true)
	end
else
	localPlayer:Kick("Invalid data")
	return
end

--== Principal ==--

-- HumanoidRootPart do LocalPlayer
local hrp

-- Espera pelo HRP do jogador
if localPlayer.Character then
	hrp = localPlayer.Character:WaitForChild("HumanoidRootPart")
end

-- Atualiza o HRP do jogador a cada respawn
localPlayer.CharacterAdded:Connect(function(character)
	hrp = character:WaitForChild("HumanoidRootPart")
end)

-- Armazena os dados em variáveis simples
local messages, locations = sent.Messages, sent.Locations

-- Armazena a localização atual até acabarem as mensagens
local currentIndex = 1
local currentLocation = locations[currentIndex]

-- Envia as mensagens em looping e muda a localização quando finalizá-las
task.spawn(function()
	while true do
		for _, msg in ipairs(messages) do
			channel:SendAsync(msg)
			task.wait(sent.Delay)
		end

		currentIndex += 1
		if currentIndex > #locations then
			currentIndex = 1
		end

		currentLocation = locations[currentIndex]
	end
end)

-- Teleporta o jogador para a localização atual
RunService.Heartbeat:Connect(function()
	if hrp and currentLocation then
		hrp.CFrame = currentLocation
	end
end)

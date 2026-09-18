--!strict
-- LocalScript: Colocar em StarterPlayerScripts -> Prime_Name_System

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

----------------------------------------------------
-- CONFIGURAÇÃO DE REDES SOCIAIS / CRÉDITOS
----------------------------------------------------
local TikTokUser = "@prime_name"

----------------------------------------------------
-- CARREGAMENTO DA BIBLIOTECA RAYFIELD (COM TRATAMENTO)
----------------------------------------------------
local success, Rayfield = pcall(function()
	return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
	warn("Falha ao carregar o Rayfield. Verifique sua conexão ou o executor.")
	return
end

----------------------------------------------------
-- CONFIGURAÇÕES DO SISTEMA
----------------------------------------------------
local Settings = {
	-- ESP Settings
	ESP_Enabled = true,
	Box_Enabled = true,
	Line_Enabled = true,
	Name_Enabled = true,
	MainColor = Color3.fromRGB(255, 255, 255),

	-- MM2 ESP Settings
	MM2_ESP_Enabled = false,
	MM2_MurdererColor = Color3.fromRGB(255, 0, 0),
	MM2_SheriffColor = Color3.fromRGB(0, 0, 255),
	MM2_InnocentColor = Color3.fromRGB(0, 255, 0),
	MM2_CoinESP = false,

	-- Aimbot Settings
	Aimbot_Enabled = true,
	Aimbot_TargetPart = "Head",
	Aimbot_Smoothness = 0.2,
	Aimbot_WallCheck = true,
	
	-- FOV Circle Settings (Aimbot)
	FOV_Visible = true,
	FOV_Radius = 120,

	-- Disparo Manual
	ManualShot_Range = 200,

	-- Camera & View Settings
	CameraFOV_Enabled = false,
	CameraFOV_Value = 70,
	FixCam_Enabled = false,
	FixedCameraCFrame = nil :: CFrame?,
	StretchRes_Enabled = false,
	StretchFOV_Value = 105,
	SelfView_Enabled = false,

	-- Player & World Settings
	InfiniteJump_Enabled = false,
	CustomGravity_Enabled = false,
	GravityValue = 196.2,

	-- Defense Settings
	AntiFling_Enabled = false,

	-- Vehicle Settings
	VehicleSpeed_Enabled = false,
	VehicleForwardSpeed = 100,
	VehicleReverseSpeed = 50
}

----------------------------------------------------
-- CRIAÇÃO DA JANELA E SISTEMA DE KEY (PRIME NAME)
----------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "Prime Name",
	LoadingTitle = "Carregando Prime Name...",
	LoadingSubtitle = "Criado por: " .. TikTokUser,
	ConfigurationSaving = { Enabled = false },
	Discord = { Enabled = false },
	KeySystem = true,
	KeySettings = {
		Title = "Prime Name | Autenticação",
		Subtitle = "Criador: " .. TikTokUser,
		Note = "Insira a chave para acessar o painel.",
		FileName = "PrimeNameKey",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"NAME", "name"}
	}
})

-- ABA ESP
local ESPTab = Window:CreateTab("ESP Visuals", 4483362458)
ESPTab:CreateSection("Controles do ESP")

ESPTab:CreateToggle({
	Name = "ESP Mestre",
	CurrentValue = Settings.ESP_Enabled,
	Flag = "ESPMasterToggle",
	Callback = function(Value) Settings.ESP_Enabled = Value end,
})

ESPTab:CreateToggle({
	Name = "ESP Box (Caixa)",
	CurrentValue = Settings.Box_Enabled,
	Flag = "ESPBoxToggle",
	Callback = function(Value) Settings.Box_Enabled = Value end,
})

ESPTab:CreateToggle({
	Name = "ESP Line (Linha)",
	CurrentValue = Settings.Line_Enabled,
	Flag = "ESPLineToggle",
	Callback = function(Value) Settings.Line_Enabled = Value end,
})

ESPTab:CreateToggle({
	Name = "ESP Name (Nome)",
	CurrentValue = Settings.Name_Enabled,
	Flag = "ESPNameToggle",
	Callback = function(Value) Settings.Name_Enabled = Value end,
})

-- ABA MM2 ESP
local MM2Tab = Window:CreateTab("MM2 ESP", 4483362458)
MM2Tab:CreateSection("Identificação de Papéis (Murder Mystery 2)")

MM2Tab:CreateToggle({
	Name = "Ativar ESP MM2 (Cores por Papel)",
	CurrentValue = Settings.MM2_ESP_Enabled,
	Flag = "MM2ESPEnabledToggle",
	Callback = function(Value) Settings.MM2_ESP_Enabled = Value end,
})

MM2Tab:CreateToggle({
	Name = "ESP de Moedas / Coletáveis",
	CurrentValue = Settings.MM2_CoinESP,
	Flag = "MM2CoinESPToggle",
	Callback = function(Value) Settings.MM2_CoinESP = Value end,
})

MM2Tab:CreateParagraph({
	Title = "Legenda de Cores do MM2",
	Content = "🔴 Vermelho: Assassino (Murderer)\n🔵 Azul: Xerife (Sheriff)\n🟢 Verde: Inocentes"
})

-- ABA AIMBOT
local AimTab = Window:CreateTab("Aimbot", 4483362458)
AimTab:CreateSection("Configurações do Auto-Lock")

AimTab:CreateToggle({
	Name = "Ativar Aimbot",
	CurrentValue = Settings.Aimbot_Enabled,
	Flag = "AimbotToggle",
	Callback = function(Value) Settings.Aimbot_Enabled = Value end,
})

AimTab:CreateDropdown({
	Name = "Parte do Corpo (Foco)",
	Options = {"Head", "HumanoidRootPart"},
	CurrentOption = {Settings.Aimbot_TargetPart},
	Flag = "AimbotPartDropdown",
	Callback = function(Option)
		Settings.Aimbot_TargetPart = Option[1]
	end,
})

AimTab:CreateSlider({
	Name = "Suavidade da Mira (Smoothness)",
	Range = {1, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = math.floor(Settings.Aimbot_Smoothness * 100),
	Flag = "AimbotSmoothSlider",
	Callback = function(Value)
		Settings.Aimbot_Smoothness = Value / 100
	end,
})

AimTab:CreateToggle({
	Name = "Verificar Paredes (Wallcheck)",
	CurrentValue = Settings.Aimbot_WallCheck,
	Flag = "AimbotWallCheckToggle",
	Callback = function(Value) Settings.Aimbot_WallCheck = Value end,
})

AimTab:CreateSection("Área de Visão do Olhar (FOV)")

AimTab:CreateToggle({
	Name = "Mostrar Círculo Central",
	CurrentValue = Settings.FOV_Visible,
	Flag = "FOVVisibleToggle",
	Callback = function(Value) Settings.FOV_Visible = Value end,
})

AimTab:CreateSlider({
	Name = "Sensibilidade do Olhar (Raio FOV)",
	Range = {30, 300},
	Increment = 5,
	Suffix = "px",
	CurrentValue = Settings.FOV_Radius,
	Flag = "FOVRadiusSlider",
	Callback = function(Value) Settings.FOV_Radius = Value end,
})

-- ABA DISPARO MANUAL
local ShotTab = Window:CreateTab("Disparo", 4483362458)
ShotTab:CreateSection("Controle de Disparo Manual")

ShotTab:CreateButton({
	Name = "🎯 ATIRAR AGORA",
	Callback = function()
		local myCharacter = LocalPlayer.Character
		if not myCharacter then return end

		local tool = myCharacter:FindFirstChildOfClass("Tool")
		if not tool then
			Rayfield:Notify({
				Title = "Aviso!",
				Content = "Você precisa estar segurando uma arma para atirar.",
				Duration = 3,
				Image = 4483362458,
			})
			return
		end

		local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		local ray = Camera:ViewportPointToRay(viewportCenter.X, viewportCenter.Y)
		local targetPosition = ray.Origin + (ray.Direction * Settings.ManualShot_Range)

		local shootEvent = tool:FindFirstChild("Shoot") 
			or tool:FindFirstChild("RemoteEvent") 
			or game:GetService("ReplicatedStorage"):FindFirstChild("ShootEvent")

		if shootEvent and shootEvent:IsA("RemoteEvent") then
			shootEvent:FireServer(targetPosition)
			Rayfield:Notify({
				Title = "Disparo Realizado!",
				Content = "Sinal de tiro enviado.",
				Duration = 1.5,
				Image = 4483362458,
			})
		else
			Rayfield:Notify({
				Title = "Erro no Disparo",
				Content = "Não foi possível encontrar o evento da arma.",
				Duration = 3,
				Image = 4483362458,
			})
		end
	end,
})

-- ABA CÂMERA & VISÃO
local CameraTab = Window:CreateTab("Câmera", 4483362458)
CameraTab:CreateSection("Campo de Visão (FOV)")

CameraTab:CreateToggle({
	Name = "Ativar FOV Personalizado",
	CurrentValue = Settings.CameraFOV_Enabled,
	Flag = "CameraFOVToggle",
	Callback = function(Value)
		Settings.CameraFOV_Enabled = Value
		if not Value and not Settings.StretchRes_Enabled then
			Camera.FieldOfView = 70
		end
	end,
})

CameraTab:CreateSlider({
	Name = "Ângulo de Visão (Field of View)",
	Range = {30, 120},
	Increment = 1,
	Suffix = "°",
	CurrentValue = Settings.CameraFOV_Value,
	Flag = "CameraFOVSlider",
	Callback = function(Value)
		Settings.CameraFOV_Value = Value
	end,
})

CameraTab:CreateSection("Modo View (Observar a Si Mesmo)")

CameraTab:CreateToggle({
	Name = "Ativar View em Si Mesmo",
	CurrentValue = Settings.SelfView_Enabled,
	Flag = "SelfViewToggle",
	Callback = function(Value)
		Settings.SelfView_Enabled = Value
		if not Value then
			Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		end
	end,
})

CameraTab:CreateSection("Resolução & Esticar")

CameraTab:CreateToggle({
	Name = "Tela Esticada (Stretch Res)",
	CurrentValue = Settings.StretchRes_Enabled,
	Flag = "StretchResToggle",
	Callback = function(Value)
		Settings.StretchRes_Enabled = Value
		if Value then
			Camera.FieldOfViewMode = Enum.FieldOfViewMode.Diagonal
			Camera.FieldOfView = Settings.StretchFOV_Value
		else
			Camera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
			Camera.FieldOfView = 70
		end
	end,
})

CameraTab:CreateSlider({
	Name = "Nível de Estico (Stretch FOV)",
	Range = {90, 130},
	Increment = 1,
	Suffix = "°",
	CurrentValue = Settings.StretchFOV_Value,
	Flag = "StretchFOVValueSlider",
	Callback = function(Value)
		Settings.StretchFOV_Value = Value
		if Settings.StretchRes_Enabled then
			Camera.FieldOfView = Value
		end
	end,
})

CameraTab:CreateSection("Travar Câmera")

CameraTab:CreateToggle({
	Name = "FixCam (Travar Posição da Câmera)",
	CurrentValue = Settings.FixCam_Enabled,
	Flag = "FixCamToggle",
	Callback = function(Value)
		Settings.FixCam_Enabled = Value
		if Value then
			Settings.FixedCameraCFrame = Camera.CFrame
		else
			Settings.FixedCameraCFrame = nil
		end
	end,
})

-- ABA PERFORMANCE & UTILITÁRIOS
local UtilTab = Window:CreateTab("Utilitários", 4483362458)
UtilTab:CreateSection("Otimização")

UtilTab:CreateButton({
	Name = "FPS Boost (Remover Sombras e Efeitos)",
	Callback = function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 9e9

		local Terrain = Workspace:FindFirstChildOfClass("Terrain")
		if Terrain then
			Terrain.WaterWaveSize = 0
			Terrain.WaterWaveSpeed = 0
			Terrain.WaterReflectance = 0
			Terrain.WaterTransparency = 0
		end

		for _, object in ipairs(Workspace:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CastShadow = false
				object.Material = Enum.Material.SmoothPlastic
			elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Smoke") or object:IsA("Fire") then
				object.Enabled = false
			elseif object:IsA("PostEffect") then
				object.Enabled = false
			end
		end

		Rayfield:Notify({
			Title = "Otimizado!",
			Content = "Configurações visuais reduzidas para melhorar o FPS.",
			Duration = 3,
			Image = 4483362458,
		})
	end,
})

UtilTab:CreateSection("Servidor")

UtilTab:CreateButton({
	Name = "Trocar de Servidor (Server Hop)",
	Callback = function()
		local placeId = game.PlaceId
		local jobId = game.JobId
		local apiUrl = string.format("https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Asc&limit=100", placeId)

		pcall(function()
			local response = game:HttpGet(apiUrl)
			local data = HttpService:JSONDecode(response)

			if data and data.data then
				for _, server in ipairs(data.data) do
					if server.id ~= jobId and server.playing < server.maxPlayers then
						Rayfield:Notify({
							Title = "Conectando...",
							Content = "Redirecionando para um novo servidor...",
							Duration = 3,
							Image = 4483362458,
						})
						TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
						return
					end
				end
			end
		end)
	end,
})

-- ABA PLAYER / FÍSICA
local PlayerTab = Window:CreateTab("Player & Física", 4483362458)
PlayerTab:CreateSection("Movimentação do Personagem")

PlayerTab:CreateToggle({
	Name = "Pulo Infinito (Infinite Jump)",
	CurrentValue = Settings.InfiniteJump_Enabled,
	Flag = "InfiniteJumpToggle",
	Callback = function(Value)
		Settings.InfiniteJump_Enabled = Value
	end,
})

PlayerTab:CreateSection("Controle de Gravidade (Personagem e Veículos)")

PlayerTab:CreateToggle({
	Name = "Ativar Gravidade Customizada",
	CurrentValue = Settings.CustomGravity_Enabled,
	Flag = "CustomGravityToggle",
	Callback = function(Value)
		Settings.CustomGravity_Enabled = Value
		if not Value then
			Workspace.Gravity = 196.2
		end
	end,
})

PlayerTab:CreateSlider({
	Name = "Nível de Gravidade",
	Range = {0, 300},
	Increment = 5,
	Suffix = " G",
	CurrentValue = math.floor(Settings.GravityValue),
	Flag = "GravitySlider",
	Callback = function(Value)
		Settings.GravityValue = Value
	end,
})

-- ABA VEÍCULOS
local VehicleTab = Window:CreateTab("Veículos", 4483362458)
VehicleTab:CreateSection("Aceleração de Veículo")

VehicleTab:CreateToggle({
	Name = "Ativar Controle de Velocidade",
	CurrentValue = Settings.VehicleSpeed_Enabled,
	Flag = "VehicleSpeedToggle",
	Callback = function(Value)
		Settings.VehicleSpeed_Enabled = Value
	end,
})

VehicleTab:CreateSlider({
	Name = "Velocidade para Frente",
	Range = {10, 500},
	Increment = 10,
	Suffix = " km/h",
	CurrentValue = Settings.VehicleForwardSpeed,
	Flag = "VehicleForwardSlider",
	Callback = function(Value)
		Settings.VehicleForwardSpeed = Value
	end,
})

VehicleTab:CreateSlider({
	Name = "Velocidade de Ré",
	Range = {10, 300},
	Increment = 10,
	Suffix = " km/h",
	CurrentValue = Settings.VehicleReverseSpeed,
	Flag = "VehicleReverseSlider",
	Callback = function(Value)
		Settings.VehicleReverseSpeed = Value
	end,
})

-- ABA SEGURANÇA & PROTEÇÃO
local DefenseTab = Window:CreateTab("Proteção", 4483362458)
DefenseTab:CreateSection("Proteções Passivas")

DefenseTab:CreateToggle({
	Name = "Anti-Fling (Proteção contra Colisão)",
	CurrentValue = Settings.AntiFling_Enabled,
	Flag = "AntiFlingToggle",
	Callback = function(Value)
		Settings.AntiFling_Enabled = Value
	end,
})

DefenseTab:CreateSection("Ferramentas Externas")

DefenseTab:CreateButton({
	Name = "Ativar Infinite Yield",
	Callback = function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
	end,
})

-- ABA CRÉDITOS & REDES
local InfoTab = Window:CreateTab("Créditos", 4483362458)
InfoTab:CreateSection("Desenvolvedor")

InfoTab:CreateLabel("TikTok: " .. TikTokUser)

InfoTab:CreateButton({
	Name = "Copiar Usuário do TikTok",
	Callback = function()
		if setclipboard then
			setclipboard(TikTokUser)
			Rayfield:Notify({
				Title = "Copiado!",
				Content = "O nome " .. TikTokUser .. " foi copiado para a área de transferência.",
				Duration = 3,
				Image = 4483362458,
			})
		end
	end,
})

----------------------------------------------------
-- LÓGICA DE DETECÇÃO ROBUSTA DE PAPÉIS DO MM2
----------------------------------------------------
local function GetMM2Role(player: Player): string
	local character = player.Character
	if not character then return "Innocent" end
	
	-- Verifica ferramentas equipadas no personagem
	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Tool") then
			local lowerName = item.Name:lower()
			if lowerName:find("knife") or lowerName:find("faca") then
				return "Murderer"
			elseif lowerName:find("gun") or lowerName:find("revolver") or lowerName:find("sheriff") then
				return "Sheriff"
			end
		end
	end
	
	-- Verifica ferramentas na mochila (Backpack)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				local lowerName = item.Name:lower()
				if lowerName:find("knife") or lowerName:find("faca") then
					return "Murderer"
				elseif lowerName:find("gun") or lowerName:find("revolver") or lowerName:find("sheriff") then
					return "Sheriff"
				end
			end
		end
	end
	
	return "Innocent"
end

----------------------------------------------------
-- LÓGICA DE CONTROLE DE VELOCIDADE DO VEÍCULO
----------------------------------------------------
RunService.Heartbeat:Connect(function()
	if Settings.VehicleSpeed_Enabled then
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
				local seat = humanoid.SeatPart :: VehicleSeat
				
				if seat.Throttle > 0 then
					seat.AssemblyLinearVelocity = seat.CFrame.LookVector * Settings.VehicleForwardSpeed
				elseif seat.Throttle < 0 then
					seat.AssemblyLinearVelocity = -seat.CFrame.LookVector * Settings.VehicleReverseSpeed
				end
			end
		end
	end
end)

----------------------------------------------------
-- LÓGICA DE ANTI-FLING
----------------------------------------------------
RunService.Stepped:Connect(function()
	if Settings.AntiFling_Enabled then
		local myCharacter = LocalPlayer.Character
		if myCharacter then
			for _, otherPlayer in ipairs(Players:GetPlayers()) do
				if otherPlayer ~= LocalPlayer and otherPlayer.Character then
					for _, myPart in ipairs(myCharacter:GetChildren()) do
						if myPart:IsA("BasePart") then
							for _, otherPart in ipairs(otherPlayer.Character:GetChildren()) do
								if otherPart:IsA("BasePart") then
									myPart.CanCollide = true
									otherPart.CanCollide = false
								end
							end
						end
					end
				end
			end
		end
	end
end)

----------------------------------------------------
-- LÓGICA DE GRAVIDADE (INCLUINDO VEÍCULOS)
----------------------------------------------------
RunService.Heartbeat:Connect(function()
	if Settings.CustomGravity_Enabled then
		Workspace.Gravity = Settings.GravityValue

		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.SeatPart then
				local seat = humanoid.SeatPart
				local vehicleModel = seat:FindFirstAncestorOfClass("Model") or seat.Parent
				
				if vehicleModel then
					for _, part in ipairs(vehicleModel:GetDescendants()) do
						if part:IsA("BasePart") and not part.Anchored then
							local difference = Settings.GravityValue - 196.2
							local counterForce = Vector3.new(0, -difference * part:GetMass(), 0)
							part:ApplyImpulse(counterForce * 0.016)
						end
					end
				end
			end
		end
	end
end)

----------------------------------------------------
-- LÓGICA DO INFINITE JUMP
----------------------------------------------------
UserInputService.JumpRequest:Connect(function()
	if Settings.InfiniteJump_Enabled then
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

----------------------------------------------------
-- CÍRCULO FOV (SEGURO CONTRA ERROS DE DRAWING)
----------------------------------------------------
local FOVCircle = nil
pcall(function()
	FOVCircle = Drawing.new("Circle")
	FOVCircle.Color = Settings.MainColor
	FOVCircle.Thickness = 1.5
	FOVCircle.Filled = false
	FOVCircle.Transparency = 1
	FOVCircle.NumSides = 60
end)

----------------------------------------------------
-- LÓGICA DE ESP NATIVA (HIGHLIGHT + BEAM + BILLBOARD)
----------------------------------------------------
local ESPCache = {}

local function ApplyESP(player: Player)
	if player == LocalPlayer then return end

	local function OnCharacterAdded(character: Model)
		local rootPart = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
		if not rootPart then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = "ESP_Highlight"
		highlight.Adornee = character
		highlight.FillTransparency = 1
		highlight.OutlineColor = Settings.MainColor
		highlight.OutlineTransparency = 0
		highlight.Parent = character

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP_Name"
		billboard.Adornee = rootPart
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = character

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = player.Name
		nameLabel.TextColor3 = Settings.MainColor
		nameLabel.TextStrokeTransparency = 0
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 13
		nameLabel.Parent = billboard

		local attachmentEnemy = Instance.new("Attachment")
		attachmentEnemy.Name = "ESP_Attachment"
		attachmentEnemy.Position = Vector3.new(0, -3, 0)
		attachmentEnemy.Parent = rootPart

		local beam = Instance.new("Beam")
		beam.Name = "ESP_Beam"
		beam.Width0 = 0.08
		beam.Width1 = 0.08
		beam.Color = ColorSequence.new(Settings.MainColor)
		beam.FaceCamera = true
		beam.Attachment1 = attachmentEnemy
		beam.Parent = character

		ESPCache[player] = {
			Character = character,
			Highlight = highlight,
			Billboard = billboard,
			NameLabel = nameLabel,
			Beam = beam,
			Attachment = attachmentEnemy
		}
	end

	if player.Character then OnCharacterAdded(player.Character) end
	player.CharacterAdded:Connect(OnCharacterAdded)
end

local function RemoveESP(player: Player)
	ESPCache[player] = nil
end

for _, player in ipairs(Players:GetPlayers()) do ApplyESP(player) end
Players.PlayerAdded:Connect(ApplyESP)
Players.PlayerRemoving:Connect(RemoveESP)

----------------------------------------------------
-- LÓGICA DE IDENTIFICAÇÃO AO OLHAR (CENTRO DA TELA)
----------------------------------------------------
local function GetPlayerInLookTarget(): BasePart?
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local closestPart: BasePart? = nil
	local shortestDistance = Settings.FOV_Radius

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local char = player.Character
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local targetPart = char:FindFirstChild(Settings.Aimbot_TargetPart) :: BasePart?

			if humanoid and humanoid.Health > 0 and targetPart then
				local screenPos, isOnScreen = Camera:WorldToViewportPoint(targetPart.Position)

				if isOnScreen then
					local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude

					if distToCenter < shortestDistance then
						if Settings.Aimbot_WallCheck then
							local rayParams = RaycastParams.new()
							rayParams.FilterType = Enum.RaycastFilterType.Exclude
							rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
							
							let origin = Camera.CFrame.Position
							local direction = targetPart.Position - origin
							local rayResult = Workspace:Raycast(origin, direction, rayParams)

							if not rayResult then
								shortestDistance = distToCenter
								closestPart = targetPart
							end
						else
							shortestDistance = distToCenter
							closestPart = targetPart
						end
					end
				end
			end
		end
	end

	return closestPart
end

----------------------------------------------------
-- LOOP PRINCIPAL (RENDERSTEPPED)
----------------------------------------------------
RunService.RenderStepped:Connect(function()
	if Settings.StretchRes_Enabled then
		Camera.FieldOfViewMode = Enum.FieldOfViewMode.Diagonal
		Camera.FieldOfView = Settings.StretchFOV_Value
	elseif Settings.CameraFOV_Enabled then
		Camera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
		Camera.FieldOfView = Settings.CameraFOV_Value
	end

	if Settings.FixCam_Enabled and Settings.FixedCameraCFrame then
		Camera.CFrame = Settings.FixedCameraCFrame
	end

	if Settings.SelfView_Enabled then
		local char = LocalPlayer.Character
		local head = char and char:FindFirstChild("Head") :: BasePart?
		if head then
			Camera.CameraSubject = head
		end
	end

	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	
	if FOVCircle then
		FOVCircle.Position = screenCenter
		FOVCircle.Radius = Settings.FOV_Radius
		FOVCircle.Visible = Settings.FOV_Visible and Settings.Aimbot_Enabled
	end

	local myCharacter = LocalPlayer.Character
	local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?
	local myAttachment = myRoot and myRoot:FindFirstChild("ESP_MyAttachment") :: Attachment?

	if myRoot and not myAttachment then
		myAttachment = Instance.new("Attachment")
		myAttachment.Name = "ESP_MyAttachment"
		myAttachment.Position = Vector3.new(0, -3, 0)
		myAttachment.Parent = myRoot
	end

	for player, data in pairs(ESPCache) do
		if data.Character and data.Character.Parent then
			local activeColor = Settings.MainColor
			local roleText = player.Name

			if Settings.MM2_ESP_Enabled then
				local role = GetMM2Role(player)
				if role == "Murderer" then
					activeColor = Settings.MM2_MurdererColor
					roleText = player.Name .. " [MURDERER]"
				elseif role == "Sheriff" then
					activeColor = Settings.MM2_SheriffColor
					roleText = player.Name .. " [SHERIFF]"
				else
					activeColor = Settings.MM2_InnocentColor
					roleText = player.Name .. " [Innocent]"
				end
			end

			data.Highlight.OutlineColor = activeColor
			data.NameLabel.TextColor3 = activeColor
			data.NameLabel.Text = roleText
			data.Beam.Color = ColorSequence.new(activeColor)

			-- Força o Highlight a ficar visível se o ESP Mestre estiver ligado
			data.Highlight.Enabled = Settings.ESP_Enabled
			data.Billboard.Enabled = Settings.ESP_Enabled and Settings.Name_Enabled

			if Settings.ESP_Enabled and Settings.Line_Enabled and myAttachment then
				data.Beam.Attachment0 = myAttachment
				data.Beam.Enabled = true
			else
				data.Beam.Enabled = false
			end
		end
	end

	if Settings.Aimbot_Enabled and not Settings.FixCam_Enabled and not Settings.SelfView_Enabled then
		local targetPart = GetPlayerInLookTarget()
		if targetPart then
			local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
			Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Aimbot_Smoothness)
		end
	end
end)

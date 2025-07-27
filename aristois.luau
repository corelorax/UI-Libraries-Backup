-- https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fi.imgur.com%2F0JBPk8h.png
-- aristois.me by task manager rewriten by peak

local Global = getgenv and getgenv() or _G;

if Global.Menu and Global.Menu.Initialized then
	Global.Menu:Unload()
end

local Menu = {Notifications = {}, Connections = {}, Flags = {}, Tabs = {}} do
	local RunService = game:GetService("RunService")
	local TextService = game:GetService("TextService")
	local HttpService = game:GetService("HttpService")
	local TweenService = game:GetService("TweenService")
	local InputService = game:GetService("UserInputService")

	local MouseInputTypes = {
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.MouseButton2,
		Enum.UserInputType.MouseButton3
	}

	local KeyInputBlacklist = {
		Enum.KeyCode.Unknown,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D,
		Enum.KeyCode.Slash,
		Enum.KeyCode.Tab,
		Enum.KeyCode.Escape
	}

	local InputAliases = setmetatable({
		One = "1",
		Two = "2",
		Three = "3",
		Four = "4",
		Five = "5",
		Six = "6",
		Seven = "7",
		Eight = "8",
		Nine = "9",
		Zero = "0",
		Delete = "DEL",
		Insert = "INS",
		LeftAlt = "LA",
		LeftShift = "LS",
		LeftControl = "LC",
		RightAlt = "RA",
		RightShift = "RS",
		CapsLock = "LOCK",
		RightControl = "RC",
		MouseButton1 = "M1",
		MouseButton2 = "M2",
		MouseButton3 = "M3"
	}, {
		__index = function(Self, Key)
			return string.upper(rawget(Self, Key) or Key)
		end
	})

	function Menu:Create(Class, Properties)
		local Object = Instance.new(Class)

		for Property, Value in next, Properties do
			Object[Property] = Value
		end

		return Object
	end

	function Menu:GetMouseLocation(Inset)
		local Location = InputService:GetMouseLocation()

		if not Inset then
			Location -= Vector2.new(0, 36)
		end

		return Location
	end

	function Menu:Connect(Signal, Function)
		local Connection = Signal:Connect(Function)

		table.insert(self.Connections, Connection)

		return Connection
	end

	function Menu:Hovering(Object)
		local M = Menu:GetMouseLocation()
		local P = Object.AbsolutePosition
		local S = Object.AbsoluteSize

		return (M.X >= P.X and M.X <= P.X + S.X) and (M.Y >= P.Y and M.Y <= P.Y + S.Y)
	end

	function Menu:Round(Number, Increment)
		local Bracket = 1 / Increment

		return math.round(Number * Bracket) / Bracket
	end

	function Menu:Tween(Object, Properties, Time, ...)
		TweenService:Create(Object, TweenInfo.new(Time, ...), Properties):Play()
	end

	local Controls = {}; Controls.__index = Controls do
		local Extras = {}; Extras.__index = Extras do
			function Extras:Color(Extra)
				local Control = self

				Extra = Extra or {}
				Extra.Type = "Color"
				Extra.Color = Extra.Color or Color3.new(1, 1, 1)
				Extra.Offset = #Control.Extras * 25
				Extra.H, Extra.S, Extra.V = Extra.Color:ToHSV() -- more precision

				if Extra.H == 0 then -- more retardation ToHSV should do this by default
					Extra.H = 1
				end

				if Extra.Flag then
					Menu.Flags[Extra.Flag] = Extra.Color
				end

				if Extra.AlphaFlag then
					Menu.Flags[Extra.AlphaFlag] = Extra.Alpha
				end

				function Extra:Set(Color, Alpha)
					if Color then
						self.Color = Color

						self.H, self.S, self.V = Color:ToHSV()

						if self.H == 0 then -- extra retardation <3
							self.H = 1
						end
					else
						self.Color = Color3.fromHSV(self.H, self.S, self.V)
					end

					if Alpha then
						self.Alpha = Alpha
					end

					self.Button.BackgroundColor3 = self.Color
					self.Colorpick.ImageColor3 = Color3.fromHSV(self.H, 1, 1)

					self.Colordrag.Position = UDim2.new(1 - self.S, 0, 1 - self.V, 0)
					self.Huedrag.Position = UDim2.new(0, 0, 1 - self.H, 0)

					if self.Alphadrag then
						self.Alphadrag.Position = UDim2.new(self.Alpha, 0, 0, 0)
					end

					if self.Flag then
						Menu.Flags[self.Flag] = self.Color

						if self.AlphaFlag then -- idk
							Menu.Flags[self.AlphaFlag] = self.Alpha
						end
					end

					if self.Callback then
						self.Callback(self.Color, self.Alpha)
					end
				end

				function Extra:Init()
					self.Button = Menu:Create("TextButton", {
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = self.Color,
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Position = UDim2.new(0, 270 - self.Offset, 0, Control.Position),
						Size = UDim2.new(0, 18, 0, 8),
						AutoButtonColor = false,
						Font = Enum.Font.SourceSansSemibold,
						Text = "",
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 14.000,
						Parent = Control.Section.Container
					})

					Menu:Create("ImageLabel", {
						ImageTransparency = 0.6,
						Image = "rbxassetid://2454009026",
						Size = UDim2.new(1, 0, 1, 0),
						ImageColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 1,
						Parent = self.Button
					})

					local Container = Menu:Create("Frame", {
						-- AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(33, 35, 47),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Position = UDim2.new(0, -182, 1.375, 0),
						Size = UDim2.new(0, 200, 0, 170),
						Visible = false,
						ZIndex = 3,
						Parent = self.Button -- i dont like this why parent it to the button? freak!
					})

					self.Colorpick = Menu:Create("ImageButton", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						ClipsDescendants = false,
						Position = UDim2.new(0, 10, 0, 10),
						Size = UDim2.new(0, 150, 0, 150),
						AutoButtonColor = false,
						Image = "rbxassetid://4155801252",
						ImageColor3 = Color3.fromHSV(self.H, 1, 1),
						ZIndex = 3,
						Parent = Container
					})

					self.Colordrag = Menu:Create("Frame", {
						Position = UDim2.new(1 - self.S, 0, 1 - self.V, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Size = UDim2.new(0, 4, 0, 4),
						ZIndex = 3,
						Parent = self.Colorpick
					})

					self.Huepick = Menu:Create("ImageButton", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						ClipsDescendants = false,
						Position = UDim2.new(0, 170, 0, 10),
						Size = UDim2.new(0, 20, 0, 150),
						AutoButtonColor = false,
						Image = "rbxassetid://3641079629",
						ImageColor3 = Color3.fromRGB(255, 0, 0),
						ImageTransparency = 1,
						BackgroundTransparency = 0,
						ZIndex = 3,
						Parent = Container
					})

					self.Huedrag = Menu:Create("Frame", {
						Position = UDim2.new(0, 0, 1 - self.H, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Size = UDim2.new(1, 0, 0, 2),
						ZIndex = 3,
						Parent = self.Huepick
					})

					local HueFrameGradient = Menu:Create("UIGradient", {
						Rotation = 90,
						Name = "HueFrameGradient",
						Color = ColorSequence.new {
							ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
							ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
							ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
							ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
							ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
							ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
							ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
						},
						Parent = self.Huepick	
					})

					if self.Alpha ~= nil then
						Container.Size += UDim2.new(0, 0, 0, 30)

						self.Alphapick = Menu:Create("ImageButton", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderColor3 = Color3.fromRGB(27, 27, 35),
							Position = UDim2.new(0, 10, 0, 170),
							Size = UDim2.new(0, 150, 0, 20),
							AutoButtonColor = false,
							Image = "rbxassetid://3887014957",
							ScaleType = Enum.ScaleType.Tile,
							TileSize = UDim2.new(0, 10, 0, 10),
							ZIndex = 3,
							Parent = Container
						})

						local Alphacolor = Menu:Create("ImageLabel", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1.000,
							Position = UDim2.new(0, 0, 0, 1),
							Size = UDim2.new(1, 0, 1, 0),
							Image = "rbxassetid://3887017050",
							ImageColor3 = Color3.fromRGB(255, 0, 4),
							Rotation = 180,
							ZIndex = 3,
							Parent = self.Alphapick
						})

						self.Alphadrag = Menu:Create("Frame", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderColor3 = Color3.fromRGB(27, 27, 35),
							Position = UDim2.new(self.Alpha, 0, 0, 0),
							Size = UDim2.new(0, 2, 1, 0),
							ZIndex = 3,
							Parent = Alphacolor
						})

						-- Lazy

						local function UpdateA(Input) 
							local X = (self.Alphapick.AbsolutePosition.X + self.Alphapick.AbsoluteSize.X) - self.Alphapick.AbsolutePosition.X

							self.Alpha = 1 - math.clamp((Input.Position.X - self.Alphapick.AbsolutePosition.X) / X, 0, 1)

							self:Set()
						end

						Menu:Connect(self.Alphapick.InputBegan, function(Input)
							if Input.UserInputType == Enum.UserInputType.MouseButton1 then
								local Changed
								local Ended

								Changed = Menu:Connect(InputService.InputChanged, function(Input)
									if Input.UserInputType == Enum.UserInputType.MouseMovement then
										UpdateA(Input)
									end
								end)

								Ended = Menu:Connect(InputService.InputEnded, function(Input)
									if Input.UserInputType == Enum.UserInputType.MouseButton1 then
										Changed:Disconnect()
										Ended:Disconnect()
									end
								end)

								UpdateA(Input)
							end
						end)
					end

					local Side = Menu:Create("Frame", {
						BackgroundColor3 = Color3.fromRGB(33, 35, 47),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Position = UDim2.new(1, 3, 0, 0),
						Size = UDim2.new(0, 49, 0, 17),
						Visible = false,
						ZIndex = 3,
						Parent = self.Button
					})

					local Copy = Menu:Create("TextButton", {
						BackgroundColor3 = Color3.fromRGB(33, 35, 47),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Position = UDim2.new(-3.03289485, 231, 0.115384616, -6),
						Size = UDim2.new(1, 0, 0, 16),
						AutoButtonColor = false,
						Font = Enum.Font.SourceSansSemibold,
						Text = "Copy",
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 14.000,
						ZIndex = 3,
						Parent = Side
					})

					local Paste = Menu:Create("TextButton", {
						BackgroundColor3 = Color3.fromRGB(33, 35, 47),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Position = UDim2.new(-3.03289485, 231, 0.115384616, -6),
						Size = UDim2.new(1, 0, 0, 16),
						AutoButtonColor = false,
						Font = Enum.Font.SourceSansSemibold,
						Text = "Paste",
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 14.000,
						ZIndex = 3,
						Visible = false,
						Parent = Side
					})

					local UIListLayout = Menu:Create("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Side
					})

					for _, Button in next, {Copy, Paste} do
						Menu:Connect(Button.MouseEnter, function()
							Menu:Tween(Button, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
						end)

						Menu:Connect(Button.MouseLeave, function()
							Menu:Tween(Button, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
						end)
					end

					local function UpdateSV(Input)
						local X = (self.Colorpick.AbsolutePosition.X + self.Colorpick.AbsoluteSize.X) - self.Colorpick.AbsolutePosition.X
						local Y = (self.Colorpick.AbsolutePosition.Y + self.Colorpick.AbsoluteSize.Y) - self.Colorpick.AbsolutePosition.Y

						self.S = 1 - math.clamp((Input.Position.X - self.Colorpick.AbsolutePosition.X) / X, 0, 1)
						self.V = 1 - math.clamp((Input.Position.Y - self.Colorpick.AbsolutePosition.Y) / Y, 0, 1)

						self:Set()
					end

					local function UpdateH(Input) 
						local Y = (self.Huepick.AbsolutePosition.Y + self.Huepick.AbsoluteSize.Y) - self.Huepick.AbsolutePosition.Y

						self.H = 1 - math.clamp((Input.Position.Y - self.Huepick.AbsolutePosition.Y) / Y, 0, 1)

						self:Set()
					end

					Menu:Connect(self.Colorpick.InputBegan, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							local Changed
							local Ended

							Changed = Menu:Connect(InputService.InputChanged, function(Input)
								if Input.UserInputType == Enum.UserInputType.MouseMovement then
									UpdateSV(Input)
								end
							end)

							Ended = Menu:Connect(InputService.InputEnded, function(Input)
								if Input.UserInputType == Enum.UserInputType.MouseButton1 then
									Changed:Disconnect()
									Ended:Disconnect()
								end
							end)

							UpdateSV(Input)
						end
					end)

					Menu:Connect(self.Huepick.InputBegan, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							local Changed
							local Ended

							Changed = Menu:Connect(InputService.InputChanged, function(Input)
								if Input.UserInputType == Enum.UserInputType.MouseMovement then
									UpdateH(Input)
								end
							end)

							Ended = Menu:Connect(InputService.InputEnded, function(Input)
								if Input.UserInputType == Enum.UserInputType.MouseButton1 then
									Changed:Disconnect()
									Ended:Disconnect()
								end
							end)

							UpdateH(Input)
						end
					end)

					Menu:Connect(Copy.MouseButton1Click, function()
						Copy.TextColor3 = Color3.fromRGB(175, 42, 86)

						Menu:Tween(Copy, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4)

						Menu.Clipboard = {self.Color, self.Alpha}
					end)

					Menu:Connect(Paste.MouseButton1Click, function()
						Paste.TextColor3 = Color3.fromRGB(175, 42, 86)

						Menu:Tween(Paste, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4)

						if Menu.Clipboard then
							self:Set(Menu.Clipboard[1], Menu.Clipboard[2])
						end
					end)

					Menu:Connect(InputService.InputBegan, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 then
							if Side.Visible and not Menu:Hovering(Side) then
								Side.Visible = false
							end

							if Container.Visible and not Menu:Hovering(Container)and not Menu:Hovering(self.Button) then
								Container.Visible = false

								if self.Parent then
									Menu:Tween(self.Parent.Label, {TextColor3 = Container.Visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)}, 0.2)
								end
							end
						end
					end)

					Menu:Connect(self.Button.MouseButton2Click, function()
						if Menu.Clipboard and not Paste.Visible then
							Paste.Visible = true
							Side.Size = UDim2.new(0, 49, 0, 34)
						end

						Side.Visible = not Side.Visible
					end)

					Menu:Connect(self.Button.MouseButton1Click, function()
						Container.Visible = not Container.Visible

						if self.Parent then
							Menu:Tween(self.Parent.Label, {TextColor3 = Container.Visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)}, 0.2)
						end
					end)
				end

				table.insert(Control.Extras, Extra)

				return Extra
			end

			function Extras:Bind(Extra)
				local Control = self

				Extra = Extra or {}
				Extra.Type = "Bind"
				Extra.State = Extra.State and Extra.State or Extra.Mode == "Always"
				Extra.Offset = #Control.Extras * 25
				Extra.Binding = false

				if Extra.Flag then
					Menu.Flags[Extra.Flag] = Extra.State
				end

				function Extra:Set(Key)
					self.Key = Key and (type(Key) == "string" and Key or Key.Name)

					self.Keybind.Text = Key and InputAliases[self.Key] or "NONE"
					self.Keybind.Size = UDim2.new(0, TextService:GetTextSize(self.Keybind.Text, 14, 16, Vector2.new(700, 12)).X + 5, 0, 12)

					if self.IndicatorKey then
						self.IndicatorKey.Text = self.Keybind.Text
						self.IndicatorKey.Size = self.Keybind.Size
					end
				end

				function Extra:Init()
					self.Keybind = Menu:Create("TextButton", {
						BackgroundColor3 = Color3.fromRGB(33, 35, 47),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Position = UDim2.new(0, 270 - self.Offset, 0, Control.Position),
						Text = self.Key and InputAliases[self.Key] or "NONE",
						Size = UDim2.new(0, TextService:GetTextSize(self.Key and InputAliases[self.Key] or "NONE", 14, 16, Vector2.new(700, 12)).X + 5, 0, 12),
						AutoButtonColor = false,
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 14.000,
						AnchorPoint = Vector2.new(1,0),
						Parent = Control.Section.Container
					})

					if self.Mode then
						self.Side = Menu:Create("Frame", {
							BackgroundColor3 = Color3.fromRGB(33, 35, 47),
							BorderColor3 = Color3.fromRGB(27, 27, 35),
							Position = UDim2.new(1, 3, 0, 0),
							Size = UDim2.new(0, 49, 0, 49),
							Visible = false,
							ZIndex = 3,
							Parent = self.Keybind
						})

						local UIListLayout = Menu:Create("UIListLayout", {
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Parent = self.Side
						})

						for _, Mode in next, {"Always", "Hold", "Toggle"} do
							local Button = Menu:Create("TextButton", {
								BackgroundColor3 = Color3.fromRGB(33, 35, 47),
								BackgroundTransparency = 1.000,
								BorderColor3 = Color3.fromRGB(27, 27, 35),
								Position = UDim2.new(-3.03289485, 231, 0.115384616, -6),
								Size = UDim2.new(1, 0, 0, 16),
								AutoButtonColor = false,
								Font = Enum.Font.SourceSansBold,
								Text = Mode,
								TextColor3 = self.Mode == Mode and Color3.fromRGB(173, 24, 74) or Color3.fromRGB(200, 200, 200),
								TextSize = 14.000,
								ZIndex = 3,
								Parent = self.Side
							})

							Menu:Connect(Button.MouseEnter, function()
								if Mode ~= self.Mode then
									Menu:Tween(Button, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
								end
							end)

							Menu:Connect(Button.MouseLeave, function()
								if Mode ~= self.Mode then
									Menu:Tween(Button, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
								end
							end)

							Menu:Connect(Button.MouseButton1Click, function()
								if Mode ~= self.Mode then
									self.Mode = Mode

									if self.Mode == "Always" then
										self.State = true
									else
										self.State = false
									end

									Menu:Tween(self.IndicatorLabel, {TextColor3 = self.State and Color3.fromRGB(173, 24, 74) or Color3.fromRGB(200, 200, 200)}, 0.2)

									if self.Flag then
										Menu.Flags[self.Flag] = self.State
									end

									for _, Object in next, self.Side:GetChildren() do
										if Object:IsA("TextButton") then
											Menu:Tween(Object, {TextColor3 = Object == Button and Color3.fromRGB(173, 24, 74) or Color3.fromRGB(200, 200, 200)}, 0.2)	
										end
									end
								end
							end)
						end

						self.IndicatorLabel = Menu:Create("TextLabel", {
							Visible = true,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1.000,
							Size = UDim2.new(1, 0, 0, 14),
							Font = Enum.Font.SourceSansSemibold,
							Text = Control.Text,
							TextColor3 = self.State and Color3.fromRGB(173, 24, 74) or Color3.fromRGB(200, 200, 200),
							TextSize = 14.000,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							Parent = Menu.KeyContainer
						})

						if Control.State ~= nil then
							self.IndicatorLabel.Visible = Control.State
						end

						self.IndicatorKey = self.Keybind:Clone()
						self.IndicatorKey.Parent = self.IndicatorLabel
						self.IndicatorKey.Position = UDim2.new(1, -4, 0.5, 0)
						self.IndicatorKey.AnchorPoint = Vector2.new(1, 0.5)
					end

					if self.Side then
						Menu:Connect(self.Keybind.MouseButton2Click, function()
							self.Side.Visible = not self.Side.Visible
						end)
					end	

					Menu:Connect(self.Keybind.MouseButton1Up, function()
						self.Binding = true

						if self.Parent then
							Menu:Tween(self.Parent.Label, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)

							--[[if self.IndicatorLabel then
								Menu:Tween(self.IndicatorLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
							end]]
						end

						self.Keybind.Text = "..."
						self.Keybind.Size = UDim2.new(0, TextService:GetTextSize("...", 14, 16, Vector2.new(700, 12)).X + 5, 0, 12)
					end)

					Menu:Connect(InputService.InputBegan, function(Input, Check) -- oi boi
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 then
							if self.Side and self.Side.Visible and not Menu:Hovering(self.Side) then
								self.Side.Visible = false
							end
						end

						if self.Binding and (not table.find(KeyInputBlacklist, Input.KeyCode) or table.find(MouseInputTypes, Input.UserInputType)) then
							self.Binding = false

							if self.Parent then
								Menu:Tween(self.Parent.Label, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)

								--[[if self.IndicatorLabel then
									Menu:Tween(self.IndicatorLabel, {TextColor3 = self.State and Color3.fromRGB(173, 24, 74) or Color3.fromRGB(200, 200, 200)}, 0.2)
								end]]
							end

							if Input.KeyCode == Enum.KeyCode.Backspace then
								self:Set(nil)
							else
								self:Set(table.find(MouseInputTypes, Input.UserInputType) and Input.UserInputType or Input.KeyCode)
							end
						elseif not Check and (self.Key == Input.UserInputType.Name or self.Key == Input.KeyCode.Name) then 
							if self.Mode == "Toggle" then
								self.State = not self.State

								Menu:Tween(self.IndicatorLabel, {TextColor3 = self.State and Color3.fromRGB(173, 24, 74) or Color3.fromRGB(200, 200, 200)}, 0.2)

								if self.Flag then
									Menu.Flags[self.Flag] = self.State
								end

								if self.Callback then
									self.Callback(self.State)
								end
							elseif self.Mode == "Hold" then
								self.State = true

								Menu:Tween(self.IndicatorLabel, {TextColor3 = self.State and Color3.fromRGB(173, 24, 74) or Color3.fromRGB(200, 200, 200)}, 0.2)

								if self.Flag then
									Menu.Flags[self.Flag] = self.State
								end

								if self.Callback then
									self.Callback(self.State)
								end
							elseif not self.Side and self.Callback then
								self.Callback()
							end
						end
					end)

					Menu:Connect(InputService.InputEnded, function(Input)
						if self.Mode == "Hold" and (self.Key == Input.UserInputType.Name or self.Key == Input.KeyCode.Name) then 
							self.State = false

							Menu:Tween(self.IndicatorLabel, {TextColor3 = self.State and Color3.fromRGB(173, 24, 74) or Color3.fromRGB(200, 200, 200)}, 0.2)

							if self.Flag then
								Menu.Flags[self.Flag] = self.State
							end

							if self.Callback then
								self.Callback(self.State)
							end
						end
					end)
				end

				table.insert(Control.Extras, Extra)

				return Extra
			end
		end

		function Controls:Button(Control)
			local Section = self

			Control = Control or {}
			Control.Type = "Button"
			Control.Text = Control.Text or "button"
			Control.Section = Section

			Control.Position = Section.Position
			Section.Position += 25

			function Control:Init()
				Section.Frame.Size += UDim2.new(0, 0, 0, 25)

				local Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 0, 0, self.Position),
					Size = UDim2.new(1, 0, 0, 24),
					Parent = Section.Container
				})

				local TextButton = Menu:Create("TextButton", {
					BackgroundColor3 = Color3.fromRGB(33, 35, 47),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					Position = UDim2.new(0, 30, 0.5, -9),
					Size = UDim2.new(0, 175, 0, 18),
					AutoButtonColor = false,
					Font = Enum.Font.SourceSans,
					Text = "",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 14.000,
					Parent = Frame
				})

				local TextLabel = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					BorderColor3 = Color3.fromRGB(27, 42, 53),
					Size = UDim2.new(1, 0, 1, 0),
					Font = Enum.Font.SourceSansSemibold,
					Text = self.Text,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14.000,
					Parent = TextButton
				})

				Menu:Connect(TextButton.MouseButton1Click, function()
					TextLabel.TextColor3 = Color3.fromRGB(175, 42, 86)

					Menu:Tween(TextLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4)

					if self.Callback then
						self.Callback()
					end
				end)

				Menu:Connect(TextButton.MouseEnter, function()
					Menu:Tween(TextLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
				end)

				Menu:Connect(TextButton.MouseLeave, function()
					Menu:Tween(TextLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
				end)
			end

			table.insert(Section.Controls, Control)

			return Control
		end

		function Controls:Toggle(Control)
			local Section = self

			Control = Control or {}
			Control.Type = "Toggle"
			Control.Text = Control.Text or "toggle"
			Control.State = Control.State or false
			Control.Section = Section
			Control.Extras = {}

			Control.Position = Section.Position
			Section.Position += 16

			if Control.Flag then
				Menu.Flags[Control.Flag] = Control.State
			end

			function Control:Init()
				Section.Frame.Size += UDim2.new(0, 0, 0, 16)

				local Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 0, 0, self.Position),
					Size = UDim2.new(1, 0, 0, 15),
					Parent = Section.Container
				})

				local TextButton = Menu:Create("TextButton", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Size = UDim2.new(1, 0, 1, 0),
					Font = Enum.Font.SourceSans,
					Text = "",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 14.000,
					Parent = Frame
				})

				local Color = Menu:Create("Frame", {
					BackgroundColor3 = self.State and Color3.fromRGB(155, 22, 66) or Color3.fromRGB(33, 35, 47),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					Position = UDim2.new(0, 15, 0.5, -5),
					Size = UDim2.new(0, 8, 0, 8),
					Parent = TextButton
				})

				local Shimmer = Menu:Create("ImageLabel", {
					ImageTransparency = 1,
					Image = "rbxassetid://2454009026",
					Size = UDim2.new(1, 0, 1, 0),
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					Parent = Color
				})

				local TextLabel = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 32, 0, -1),
					Size = UDim2.new(0.111913361, 208, 1, 0),
					Font = Enum.Font.SourceSansSemibold,
					Text = self.Text,
					TextColor3 = self.State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200),
					TextSize = 14.000,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = TextButton
				})

				function Control:Set(State)
					self.State = State

					Menu:Tween(Color, {BackgroundColor3 = self.State and Color3.fromRGB(155, 22, 66) or Color3.fromRGB(33, 35, 47)}, 0.1)
					Menu:Tween(TextLabel, {TextColor3 = self.State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)}, 0.1)
					Menu:Tween(Shimmer, {ImageTransparency = self.State and 0.6 or 1}, 0.1)

					for _, Extra in next, self.Extras do
						if Extra.IndicatorLabel then
							Extra.IndicatorLabel.Visible = self.State
						end
					end				

					if self.Flag then
						Menu.Flags[self.Flag] = self.State
					end

					if self.Callback then
						self.Callback(self.State)
					end
				end

				Menu:Connect(TextButton.MouseButton1Click, function()
					self:Set(not self.State)
				end)

				for _, Extra in next, self.Extras do
					Extra:Init()
				end
			end

			setmetatable(Control, Extras)
			table.insert(Section.Controls, Control)

			return Control
		end

		function Controls:Slider(Control)
			local Section = self

			Control = Control or {}
			Control.Type = "Slider"
			Control.Text = Control.Text or "slider"
			Control.Min = Control.Min or 0
			Control.Max = Control.Max or 100
			Control.Float = Control.Float or 1
			Control.Value = Control.Value and math.clamp(Menu:Round(Control.Value, Control.Float), Control.Min, Control.Max) or Control.Min
			Control.Suffix = Control.Suffix or ""

			Control.Position = Section.Position
			Section.Position += 28

			if Control.Flag then
				Menu.Flags[Control.Flag] = Control.Value
			end

			function Control:Init()
				Section.Frame.Size += UDim2.new(0, 0, 0, 28)

				local Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 0, 0, self.Position),
					Size = UDim2.new(1, 0, 0, 27),
					Parent = Section.Container
				})

				local TextLabel = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 32, 0, -1),
					Size = UDim2.new(0, 100, 0, 15),
					Font = Enum.Font.SourceSansSemibold,
					Text = self.Text,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14.000,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = Frame
				})

				self.Button = Menu:Create("TextButton", {
					BackgroundColor3 = Color3.fromRGB(33, 35, 47),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					Position = UDim2.new(0, 30, 0, 16),
					Size = UDim2.new(0, 175, 0, 5),
					AutoButtonColor = false,
					Font = Enum.Font.SourceSans,
					Text = "",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 14.000,
					Parent = Frame
				})

				self.Color = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Size = UDim2.new(0, ((self.Value - self.Min) / (self.Max - self.Min)) * self.Button.AbsoluteSize.X, 1, 0),
					Parent = self.Button
				})

				local UIGradient = Menu:Create("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(153, 22, 65)), 
						ColorSequenceKeypoint.new(1, Color3.fromRGB(109, 16, 46))
					}),
					Rotation = 90,
					Parent = self.Color
				})

				self.Label = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 150, 0, -1),
					Size = UDim2.new(0, 55, 0, 15),
					Font = Enum.Font.SourceSansSemibold,
					Text = tostring(self.Value) .. self.Suffix,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14.000,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = Frame
				})

				function Control:Set(Value)
					Value = Menu:Round(Value, self.Float)
					Value = math.clamp(Value, self.Min, self.Max)

					self.Value = Value

					self.Color.Size = UDim2.new(0, ((Value - self.Min) / (self.Max - self.Min)) * self.Button.AbsoluteSize.X, 1, 0)
					self.Label.Text = tostring(Value) .. self.Suffix

					if self.Flag then
						Menu.Flags[self.Flag] = Value
					end

					if self.Callback then
						self.Callback(Value)
					end
				end

				local function Update()
					self:Set(self.Min + (self.Max - self.Min) * (InputService:GetMouseLocation().X - self.Button.AbsolutePosition.X) / self.Button.AbsoluteSize.X)
				end

				Menu:Connect(self.Button.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						local Changed
						local Ended

						Menu:Tween(TextLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
						Menu:Tween(self.Label, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)


						Changed = Menu:Connect(InputService.InputChanged, function(Input)
							if Input.UserInputType == Enum.UserInputType.MouseMovement then
								Update()
							end
						end)

						Ended = Menu:Connect(InputService.InputEnded, function(Input)
							if Input.UserInputType == Enum.UserInputType.MouseButton1 then
								Changed:Disconnect()
								Ended:Disconnect()

								Menu:Tween(TextLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
								Menu:Tween(self.Label, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
							end
						end)

						Update()
					end
				end)
			end

			table.insert(Section.Controls, Control)

			return Control
		end

		function Controls:Dropdown(Control)
			local Section = self

			Control = Control or {}
			Control.Type = "Dropdown"
			Control.Text = Control.Text or "dropdown"
			Control.Combo = Control.Combo or type(Control.Value) == "table" or false
			Control.Values = Control.Values or {}
			Control.Value = Control.Value or Control.Combo and {}
			Control.Max = Control.Max or 5

			Control.Position = Section.Position
			Section.Position += 40

			if Control.Flag then
				Menu.Flags[Control.Flag] = Control.Value
			end

			function Control:Init()
				Section.Frame.Size += UDim2.new(0, 0, 0, 40)

				local Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 0, 0, self.Position),
					Size = UDim2.new(1, 0, 0, 39),
					Parent = Section.Container
				})

				local TextButton = Menu:Create("TextButton", {
					BackgroundColor3 = Color3.fromRGB(33, 35, 47),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					Position = UDim2.new(0, 30, 0, 16),
					Size = UDim2.new(0, 175, 0, 17),
					AutoButtonColor = false,
					Font = Enum.Font.SourceSans,
					Text = "",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 14.000,
					Parent = Frame
				})

				local TextLabel = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					BorderColor3 = Color3.fromRGB(27, 42, 53),
					Position = UDim2.new(0, 5, 0, 0),
					Size = UDim2.new(-0.21714285, 208, 1, 0),
					Font = Enum.Font.SourceSansSemibold,
					Text = "...",
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14.000,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = TextButton
				})

				local ScrollingFrame = Menu:Create("ScrollingFrame", {
					Active = true,
					BackgroundColor3 = Color3.fromRGB(33, 35, 47),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					Position = UDim2.new(0, 0, 1, 1),
					Size = UDim2.new(1, 0, 0, math.clamp(#self.Values * 17, 17, Control.Max * 17)),
					Visible = false,
					BottomImage = "http://www.roblox.com/asset/?id=6724808282",
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarThickness = 4,
					TopImage = "http://www.roblox.com/asset/?id=6724808282",
					MidImage = "http://www.roblox.com/asset/?id=6724808282",
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ZIndex = 5,
					ScrollBarImageColor3 = Color3.fromRGB(255, 37, 110),
					Parent = TextButton
				})

				local UIListLayout = Menu:Create("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = ScrollingFrame
				})

				local ImageLabel =  Menu:Create("ImageLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 165, 0, 6),
					Size = UDim2.new(0, 6, 0, 4),
					Image = "http://www.roblox.com/asset/?id=6724771531",
					Parent = TextButton
				})

				local Bullshit = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 32, 0, -1),
					Size = UDim2.new(0.111913361, 208, 0.382215232, 0),
					Font = Enum.Font.SourceSansSemibold,
					Text = self.Text,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14.000,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = Frame
				})

				for _, Value in next, self.Values do
					local Button = Menu:Create("TextButton", {
						BackgroundColor3 = Color3.fromRGB(33, 35, 47),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Position = UDim2.new(0, 30, 0, 16),
						Size = UDim2.new(0, 175, 0, 17),
						AutoButtonColor = false,
						Font = Enum.Font.SourceSans,
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14.000,
						BorderSizePixel = 0,
						ZIndex = 6,
						Parent = ScrollingFrame
					})

					local Label = Menu:Create("TextLabel", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(27, 42, 53),
						Position = UDim2.new(0, 5, 0, -1),
						Size = UDim2.new(-0.21714285, 208, 1, 0),
						Font = Enum.Font.SourceSansSemibold,
						Text = Value,
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 14.000,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 6,
						Parent = Button
					})

					local function UpdateText()
						if self.Combo then
							local Active = {} 

							for _, Value in next, self.Values do
								if self.Value[Value] then
									table.insert(Active, Value)
								end
							end

							TextLabel.Text = #Active > 0 and table.concat(Active, ", ") or "..."
						else
							TextLabel.Text = self.Value or "..."
						end
					end

					if (self.Combo and self.Value[Value]) or (self.Value == Value) then
						Label.TextColor3 = Color3.fromRGB(175, 42, 86)
					end

					Menu:Connect(Button.MouseEnter, function()
						if (self.Combo and not self.Value[Value] or (not self.Combo and self.Value ~= Value)) then
							Menu:Tween(Label, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
						end
					end)

					Menu:Connect(Button.MouseLeave, function()
						if (self.Combo and not self.Value[Value] or (not self.Combo and self.Value ~= Value)) then
							Menu:Tween(Label, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
						end
					end)

					Menu:Connect(Button.MouseButton1Click, function()
						if self.Combo then
							self.Value[Value] = not self.Value[Value]

							Menu:Tween(Label, {TextColor3 = self.Value[Value] and Color3.fromRGB(175, 42, 86) or Color3.fromRGB(200, 200, 200)}, 0.1)
							UpdateText()
						elseif self.Value ~= Value then
							self.Value = Value

							for _, Object in next, ScrollingFrame:GetChildren() do
								if Object:IsA("TextButton") then
									Menu:Tween(Object:FindFirstChildWhichIsA("TextLabel"), {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.1)
								end
							end

							Menu:Tween(Label, {TextColor3 = Color3.fromRGB(175, 42, 86)}, 0.1)
							UpdateText()

							if self.Flag then
								Menu.Flags[self.Flag] = Value
							end
						end

						if self.Callback then
							self.Callback(self.Value)
						end
					end)

					UpdateText()
				end

				Menu:Connect(ScrollingFrame:GetPropertyChangedSignal("Visible"), function()
					Menu:Tween(Bullshit, {TextColor3 = ScrollingFrame.Visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)}, 0.2)
				end)

				Menu:Connect(TextButton.MouseButton1Click, function()
					ScrollingFrame.Visible = not ScrollingFrame.Visible
				end)
			end

			table.insert(Section.Controls, Control)

			return Control
		end

		function Controls:Box(Control)
			local Section = self

			Control = Control or {}
			Control.Type = "Box"
			Control.Text = Control.Text or "box"
			Control.Value = Control.Value or ""
			Control.Center = Control.Center or false
			Control.Numeric = Control.Numeric or false
			Control.Temporary = Control.Temporary or true
			Control.Placeholder = Control.Placeholder or ""

			Control.Position = Section.Position
			Section.Position += 40

			function Control:Init()
				Section.Frame.Size += UDim2.new(0, 0, 0, 40)

				local Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 0, 0, self.Position),
					Size = UDim2.new(1, 0, 0, 39),
					Parent = Section.Container
				})

				local Value = Menu:Create("TextBox", {
					TextXAlignment = self.Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
					ClearTextOnFocus = self.Temporary,
					TextTruncate = Enum.TextTruncate.AtEnd,
					BackgroundColor3 = Color3.fromRGB(33, 35, 47),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					Position = UDim2.new(0, 30, 0, 16),
					Size = UDim2.new(0, 175, 0, 17),
					Font = Enum.Font.SourceSans,
					PlaceholderText = self.Placeholder,
					Text = self.Value,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14.000,
					Parent = Frame
				})

				local Padding = Menu:Create("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
					Parent = Value
				})

				local TextLabel =  Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 32, 0, -1),
					Size = UDim2.new(0.111913361, 208, 0.382215232, 0),
					Font = Enum.Font.SourceSansSemibold,
					Text = self.Text,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 14.000,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = Frame
				})

				Menu:Connect(Value:GetPropertyChangedSignal("Text"), function()
					if self.Callback then
						self.Callback(Value.Text, false)
					end
				end)

				Menu:Connect(Value.FocusLost, function()
					if self.Callback then
						self.Callback(Value.Text, true)
					end
				end)

				Menu:Connect(Value.Focused, function()
					Menu:Tween(TextLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
				end)

				Menu:Connect(Value.FocusLost, function()
					Menu:Tween(TextLabel, {TextColor3 = Color3.fromRGB(200, 200 ,200)}, 0.2)
				end)
			end

			table.insert(Section.Controls, Control)

			return Control
		end

		function Controls:List(Control)
			local Section = self

			-- Screw combo mode rn i have no use

			Control = Control or {}
			Control.Type = "List"
			Control.Text = Control.Text
			-- Control.Combo = Control.Combo or type(Control.Value) == "table" or false
			Control.Values = Control.Values or {}
			Control.Value = Control.Value -- or Control.Combo and {}
			Control.Size = Control.Size or 10

			Control.Position = Section.Position
			Section.Position += (Control.Text and 22 or 7) + Control.Size * 17

			function Control:Init()
				Section.Frame.Size += UDim2.new(0, 0, 0, (self.Text and 22 or 7) + Control.Size * 17)

				local Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 0, 0, self.Position),
					Size = UDim2.new(1, 0, 0, 39),
					Parent = Section.Container
				})

				local ScrollingFrame = Menu:Create("ScrollingFrame", {
					Active = true,
					BackgroundColor3 = Color3.fromRGB(33, 35, 47),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					Position = UDim2.new(0, 30, 0, (self.Text and 16 or 3)),
					Size = UDim2.new(0, 175, 0, self.Size * 17),
					BottomImage = "http://www.roblox.com/asset/?id=6724808282",
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarThickness = 4,
					TopImage = "http://www.roblox.com/asset/?id=6724808282",
					MidImage = "http://www.roblox.com/asset/?id=6724808282",
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ZIndex = 5,
					ScrollBarImageColor3 = Color3.fromRGB(255, 37, 110),
					Parent = Frame
				})

				local UIListLayout = Menu:Create("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = ScrollingFrame
				})

				if self.Text then
					Menu:Create("TextLabel", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						Position = UDim2.new(0, 32, 0, -1),
						Size = UDim2.new(0.111913361, 208, 0.382215232, 0),
						Font = Enum.Font.SourceSansSemibold,
						Text = self.Text,
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 14.000,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = Frame
					})
				end

				function self:Add(Value)
					local Button = Menu:Create("TextButton", {
						BackgroundColor3 = Color3.fromRGB(33, 35, 47),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						Position = UDim2.new(0, 30, 0, 16),
						Size = UDim2.new(0, 175, 0, 17),
						AutoButtonColor = false,
						Font = Enum.Font.SourceSans,
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14.000,
						BorderSizePixel = 0,
						ZIndex = 6,
						Parent = ScrollingFrame
					})

					local Label = Menu:Create("TextLabel", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(27, 42, 53),
						Position = UDim2.new(0, 5, 0, -1),
						Size = UDim2.new(-0.21714285, 208, 1, 0),
						Font = Enum.Font.SourceSansSemibold,
						Text = Value,
						TextColor3 = Value == self.Value and Color3.fromRGB(175, 42, 86) or Color3.fromRGB(200, 200, 200),
						TextSize = 14.000,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 6,
						Parent = Button
					})

					Menu:Connect(Button.MouseEnter, function()
						if self.Value ~= Value then
							Menu:Tween(Label, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
						end
					end)

					Menu:Connect(Button.MouseLeave, function()
						if self.Value ~= Value then
							Menu:Tween(Label, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
						end
					end)

					Menu:Connect(Button.MouseButton1Click, function()
						if self.Value ~= Value then
							self:Select(Value);
						end
					end)

					return true
				end

				function self:Select(Value)
					if not table.find(self.Values, Value) then
						return
					end

					self.Value = Value

					for _, Button in next, ScrollingFrame:GetChildren() do
						if Button:IsA("TextButton") then
							local Label = Button:FindFirstChildWhichIsA("TextLabel")

							if Label then
								Menu:Tween(Label, {TextColor3 = Label.Text == Value and Color3.fromRGB(175, 42, 86) or Color3.fromRGB(200, 200, 200)}, 0.1)
							end
						end
					end

					if self.Callback then
						self.Callback(Value)
					end

					return true
				end

				function self:Remove(Value) -- if this is ever rewriten then dont do this by text
					for _, Button in next, ScrollingFrame:GetChildren() do
						if Button:IsA("TextButton") then
							local Label = Button:FindFirstChildWhichIsA("TextLabel")

							if Label and Label.Text == Value then
								Button:Destroy();
							end
						end
					end

					if Value == self.Value then
						self.Value = nil

						if self.Callback then
							self.Callback(nil)
						end
					end

					return true
				end

				function self:Refresh(Values, Value)
					self.Values = Values
					self.Value = Value

					for _, Button in next, ScrollingFrame:GetChildren() do
						if Button:IsA("TextButton") then
							Button:Destroy();
						end
					end

					for _, Value in next, self.Values do
						self:Add(Value)
					end

					return true
				end

				self:Refresh(self.Values)
			end

			table.insert(Section.Controls, Control)

			return Control
		end

		function Controls:Text(Control)
			local Section = self

			Control = Control or {}
			Control.Type = "Text"
			Control.Text = Control.Text or "text"
			Control.Wrap = Control.Wrap or false
			Control.Section = Section
			Control.Extras = {}

			Control.TextColor = Control.TextColor or Color3.fromRGB(255, 255, 255)
			Control.TextBounds = TextService:GetTextSize(Control.Text, 14, 16, Vector2.new(213, math.huge))

			Control.Position = Section.Position
			Section.Position += (Control.Wrap and Control.TextBounds.Y + 1 or 16) + 1

			function Control:Set(Text)
				self.Text = Text
				self.Label.Text = Text
			end

			function Control:Init()
				Section.Frame.Size += UDim2.new(0, 0, 0, self.Wrap and self.TextBounds.Y + 1 or 15)

				local Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 0, 0, self.Position),
					Size = UDim2.new(1, 0, 0, self.Wrap and self.TextBounds.Y or 15),
					Parent = Section.Container
				})

				self.Label = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 32, 0, -1),
					Size = UDim2.new(0, 175, 1, 0),
					Font = Enum.Font.SourceSansSemibold,
					Text = self.Text,
					TextColor3 = self.TextColor,
					TextSize = 14.000,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = self.Wrap,
					Parent = Frame
				})

				for _, Extra in next, self.Extras do
					Extra:Init()
				end
			end

			setmetatable(Control, Extras)
			table.insert(Section.Controls, Control)

			return Control
		end

		-- pretty mid tbh
		function Controls:Color(Control)
			local Section = self
			local Parent =  Section:Text({Text = Control and Control.Text or "color", TextColor = Color3.fromRGB(200, 200, 200)})

			Control = Control or {} 
			Control.Parent = Parent

			return Parent:Color(Control)
		end

		function Controls:Bind(Control)
			local Section = self
			local Parent =  Section:Text({Text = Control and Control.Text or "bind", TextColor = Color3.fromRGB(200, 200, 200)})

			Control = Control or {} 
			Control.Parent = Parent

			return Parent:Bind(Control)
		end
	end

	function Menu:Notify(Text, Time, Color)
		Text = type(Text) == "table" and table.concat(Text) or tostring(Text)
		Time = Time or 2
		Color = Color or Color3.fromRGB(255, 255, 255)

		local Notification = {
			Text = Text,
			Life = Time,
			Time = tick(),
			Label = self:Create("TextLabel", {
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Color,
				TextSize = 13,
				ZIndex = 3,
				Text = Text,
				Font = Enum.Font.SourceSansSemibold,
				Parent = self.Aristois
			}),
			Shadow = self:Create("TextLabel", {
				BackgroundTransparency = 1,
				TextTransparency = 55 / 255,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Color3.new(),
				TextSize = 13,
				ZIndex = 2,
				Text = Text,
				Font = Enum.Font.SourceSansSemibold,
				Parent = self.Aristois
			}),
		}

		function Notification:Destroy()
			local Label = self.Label
			local LabelOrigin = Label.Position
			local LabelTrans = Label.Transparency

			local Shadow = self.Shadow
			local ShadowOrigin = Shadow.Position
			local ShadowTrans = Shadow.Transparency

			for Index = 0, 1, 1 / 60 do
				Label.Position = LabelOrigin:Lerp(UDim2.new(), Index)
				Label.Transparency = LabelTrans * Index

				Shadow.Position = ShadowOrigin:Lerp(UDim2.new(), Index)
				Shadow.Transparency = ShadowTrans * Index

				task.wait()
			end

			Label:Destroy()
			Shadow:Destroy()
		end

		table.insert(self.Notifications, Notification)

		return Notification
	end

	function Menu:Tab(Name)
		local Tab = {Sections = {}, Groups = {}}

		function Tab:Group(Name, Column)
			local Group = {Sections = {}}

			function Group:Section(Name)
				local Section = {Controls = {}, Position = 0}

				function Section:Init()
					local Size = UDim2.new(1, 0, 0, 33)

					self.Frame = setmetatable({}, {
						__newindex = function(Self, Key, Value)
							if Value.Y.Offset > Group.Frame.Size.Y.Offset then
								Group.Frame.Size = Value
							end

							Size = Value
						end,
						__index = function()
							return Size
						end
					})

					local TextButton = Menu:Create("TextButton", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						Size = UDim2.new(0, TextService:GetTextSize(Name, 14, Enum.Font.SourceSansSemibold, Vector2.new(700, 700)).X + 2, 1, 0),
						Font = Enum.Font.SourceSansSemibold,
						Text = Name,
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 14.000,
						Parent = Group.Navigation
					})

					self.Container = Menu:Create("Frame", {
						BackgroundColor3 = Color3.fromRGB(30, 30, 39),
						BorderColor3 = Color3.fromRGB(27, 27, 35),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 30),
						Size = UDim2.new(1, 0, 1, -21),
						Visible = false,
						Parent = Group.Container
					})

					--[[local Layout = Menu:Create("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 1),
						Parent = self.Container
					})]]

					local Padding = Menu:Create("UIPadding", {
						PaddingTop = UDim.new(0, 0),
						Parent = self.Container
					})

					if table.find(Group.Sections, Section) == 1 then
						TextButton.TextColor3 = Color3.fromRGB(255,255,255)
						self.Container.Visible = true
					end

					Menu:Connect(TextButton.MouseButton1Click, function()
						if not self.Container.Visible then
							for _, Button in next, Group.Navigation:GetChildren() do
								if Button:IsA("TextButton") then
									Menu:Tween(Button, {TextColor3 = Button == TextButton and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)}, 0.3)
								end
							end

							for _, Container in next, Group.Container:GetChildren() do
								Container.Visible = false
							end

							self.Container.Visible = true
						end
					end)

					for _, Control in next, self.Controls do
						Control:Init()
					end
				end

				setmetatable(Section, Controls)
				table.insert(self.Sections, Section)

				return Section
			end

			function Group:Init()
				self.Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(27, 27, 35),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 33),
					Parent = Column == 1 and Tab.Left or Tab.Right
				})

				local TextLabel = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 7, 0, -12),
					Size = UDim2.new(0, 270, 0, 19),
					ZIndex = 2,
					Font = Enum.Font.SourceSansSemibold,
					Text = Name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15.000,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = self.Frame
				})

				self.Container = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(30, 30, 39),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					Parent = self.Frame
				})

				self.Navigation = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 0, 0, 6),
					Size = UDim2.new(1, 0, 0, 22),
					Parent = self.Frame
				})

				local Layout = Menu:Create("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 10),
					Parent = self.Navigation
				})

				for _, Section in next, self.Sections do
					Section:Init()
				end
			end

			table.insert(self.Groups, Group)

			return Group
		end

		function Tab:Section(Name, Column)
			local Section = {Controls = {}, Position = 0}

			function Section:Init()
				self.Frame = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(27, 27, 35),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					BorderSizePixel = 0,
					Position = UDim2.new(0.00358422939, 0, 0, 0),
					Size = UDim2.new(1, 0, 0, 22),
					Parent = Column == 1 and Tab.Left or Tab.Right
				})

				local TextLabel = Menu:Create("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					Position = UDim2.new(0, 7, 0, -12),
					Size = UDim2.new(0, 270, 0, 19),
					ZIndex = 2,
					Font = Enum.Font.SourceSansSemibold,
					Text = Name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15.000,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = self.Frame
				})

				self.Container = Menu:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(30, 30, 39),
					BorderColor3 = Color3.fromRGB(27, 27, 35),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					Parent = self.Frame
				})

				--[[local Layout = Menu:Create("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 1),
					Parent = self.Container
				})]]

				local Padding = Menu:Create("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					Parent = self.Container
				})

				for _, Control in next, self.Controls do
					Control:Init()
				end
			end

			setmetatable(Section, Controls)
			table.insert(self.Sections, Section)

			return Section
		end

		function Tab:Init()
			local TextButton = Menu:Create("TextButton", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.new(0, TextService:GetTextSize(Name, 15, Enum.Font.SourceSansSemibold, Vector2.new(700,700)).X + 12, 1, 0),
				Font = Enum.Font.SourceSansSemibold,
				Text = Name,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = 15.000,
				Parent = Menu.Navigation
			})

			local Container = Menu:Create("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1.000,
				Size = UDim2.new(1, 0, 1, 0),
				Visible = false,
				Parent = Menu.Container
			})

			self.Left = Menu:Create("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1.000,
				Position = UDim2.new(0, 15, 0, 11),
				Size = UDim2.new(0, 279, 0, 543),
				Parent = Container
			})

			local LeftLayout = Menu:Create("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
				Parent = self.Left
			})

			self.Right = Menu:Create("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1.000,
				Position = UDim2.new(0, 303, 0, 11),
				Size = UDim2.new(0, 279, 0, 543),
				Parent = Container
			})

			local RightLayout = Menu:Create("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
				Parent = self.Right
			})

			if table.find(Menu.Tabs, Tab) == 1 then
				TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				Container.Visible = true
			end

			Menu:Connect(TextButton.MouseButton1Click, function()
				if not Container.Visible then
					for _, Button in next, Menu.Navigation:GetChildren() do
						if Button:IsA("TextButton") then
							Menu:Tween(Button, {TextColor3 = Button == TextButton and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)}, 0.3)
						end
					end

					for _, Container in next, Menu.Container:GetChildren() do
						Container.Visible = false
					end

					Container.Visible = true
				end
			end)

			for _, Section in next, self.Sections do
				Section:Init()
			end

			for _, Group in next, self.Groups do
				Group:Init()
			end
		end

		table.insert(self.Tabs, Tab)

		return Tab
	end

	function Menu:Unload()
		self.Aristois:Destroy()

		for _, Connection in next, self.Connections do
			Connection:Disconnect()
		end

		for _, Notification in next, self.Notifications do
			Notification:Destroy()
		end

		;(getgenv and getgenv() or _G).Menu = nil
	end

	function Menu:Indicators(Visible, Position)
		self.KeyList.Visible = Visible

		if Position then
			self.KeyList.Position = Position
		end
	end

	function Menu:Save(Name)
		if not self.Directory then 
			return 
		end

		if not isfolder(self.Directory) then
			makefolder(self.Directory)
		end

		local Config = {}

		local function SaveExtra(Extra)
			local Type = Extra.Type
			local Flag = Extra.Flag

			if Flag then
				if Type == "Color" then
					Config[Flag] = Extra.Color:ToHex()
					Config[Extra.AlphaFlag] = Extra.Alpha
				elseif Type == "Bind" then
					Config[Flag] = Extra.Key
				end
			end
		end

		local function SaveSection(Section)
			for _, Control in next, Section.Controls do
				local Type = Control.Type
				local Flag = Control.Flag

				if Flag then
					if Type == "Toggle" then
						for _, Extra in next, Control.Extras do
							SaveExtra(Extra)
						end

						Config[Flag] = Control.State
					elseif Type == "Slider" then
						Config[Flag] = Control.Value
					elseif Type == "Dropdown" then

					elseif Type == "Text" then
						for _, Extra in next, Control.Extras do
							SaveExtra(Extra)
						end
					end
				end
			end
		end

		for _, Tab in next, self.Tabs do
			for _, Section in next, Tab.Sections do
				SaveSection(Section)
			end

			for _, Group in next, Tab.Groups do
				for _, Section in next, Group.Sections do
					SaveSection(Section)
				end
			end
		end

		writefile(string.format("%s/%s.json", self.Directory, Name), HttpService:JSONEncode(Config))

		return true
	end

	function Menu:Load(Name, Directory)
		if not self.Directory then 
			return 
		end

		local Path = string.format("%s/%s.json", self.Directory, Name)

		if not isfile(Path) then
			return
		end

		local Config = HttpService:JSONDecode(readfile(Path));

		local function LoadExtra(Extra)
			local Type = Extra.Type
			local Flag = Extra.Flag

			if Flag and Config[Flag] ~= nil then
				if Type == "Color" then
					Extra:Set(Config[Flag], Config[Extra.AlphaFlag]);
				elseif Type == "Bind" then
					Extra:Set(Config[Flag]);
				end
			end
		end

		local function LoadSection(Section)
			for _, Control in next, Section.Controls do
				local Type = Control.Type
				local Flag = Control.Flag

				if Flag and Config[Flag] ~= nil then
					if Type == "Toggle" then
						for _, Extra in next, Control.Extras do
							LoadExtra(Extra)
						end

						Control:Set(Config[Flag]);
					elseif Type == "Slider" then
						Control:Set(Config[Flag]);
					elseif Type == "Dropdown" then

					elseif Type == "Text" then
						for _, Extra in next, Control.Extras do
							LoadExtra(Extra)
						end
					end
				end
			end
		end

		for _, Tab in next, self.Tabs do
			for _, Section in next, Tab.Sections do
				LoadSection(Section)
			end

			for _, Group in next, Tab.Groups do
				for _, Section in next, Group.Sections do
					LoadSection(Section)
				end
			end
		end

		return true
	end

	function Menu:List()
		if not self.Directory then 
			return {}
		end

		if not isfolder(self.Directory) then
			return {}
		end

		local Configs = {}

		for _, File in next, listfiles(self.Directory) do
			print(File)
		end

		return Configs
	end

	function Menu:Init(Name, Directory)
		self.Aristois = self:Create("ScreenGui", {
			Name = "Aristois",
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			DisplayOrder = 420133769,
			Parent = RunService:IsStudio() and game:GetService("Players").LocalPlayer.PlayerGui or game:GetService("CoreGui")
		})

		self.Window = self:Create("ImageLabel", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, -300, 0.5, -300),
			Size = UDim2.new(0, 600, 0, 600),
			Image = "http://www.roblox.com/asset/?id=6724360483",
			Parent = self.Aristois
		})

		local TextLabel = self:Create("TextLabel", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 7, 0, 0),
			Size = UDim2.new(0, TextService:GetTextSize(Name, 15, Enum.Font.SourceSansSemibold, Vector2.new(700, 29)).X, 0, 29),
			Font = Enum.Font.SourceSansSemibold,
			Text = Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 15.000,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.Window
		})

		self.Navigation = self:Create("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.new(TextLabel.Size.X.Scale, TextLabel.Size.X.Offset+10, 0, 0),
			Size = UDim2.new(TextLabel.Size.X.Scale, 590-TextLabel.Size.X.Offset, 0, 29),
			Parent = self.Window
		})

		local Layout = self:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Parent = self.Navigation
		})

		self.Container = self:Create("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1.000,
			Position = UDim2.new(0, 0, 0, 32),
			Size = UDim2.new(0, 600, 0, 568),
			Parent = self.Window
		})

		--[[local Cursor = self:Create("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0,17,0,17),
			Image = "rbxassetid://518398610",
			ZIndex = 1000,
			ImageColor3 = Color3.fromRGB(255,255,255),
			Parent = self.Aristois
		})]]

		self.KeyList = Menu:Create("Frame", {
			Visible = false,
			BackgroundColor3 = Color3.fromRGB(33, 35, 47),
			BorderColor3 = Color3.fromRGB(30, 31, 42),
			Position = UDim2.new(0, 20, 0, 20),
			Size = UDim2.new(0, 210, 0, 20),
			Parent = self.Aristois
		})

		Menu:Create("TextLabel", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1.000,
			Size = UDim2.new(1, 0, 0, 20),
			Font = Enum.Font.SourceSansSemibold,
			Text = "keybinds",
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = 14.000,
			TextWrapped = true,
			Parent = self.KeyList
		})

		self.KeyContainer = Menu:Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1.000,
			Position = UDim2.new(0.5, 0, 0, 20),
			Size = UDim2.new(1, -8, 1, -20),
			Parent = self.KeyList
		})

		local Layout = Menu:Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = self.KeyContainer
		})

		self.Directory = Directory
		self.Initialized = true;

		Menu:Connect(Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			self.KeyList.Size = UDim2.new(0, 210, 0, 24 + Layout.AbsoluteContentSize.Y)
		end)

		Menu:Connect(self.KeyList.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local Current = InputService:GetMouseLocation()
				local Changed
				local Ended

				Changed = Menu:Connect(InputService.InputChanged, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement then
						local Next = InputService:GetMouseLocation()

						self.KeyList.Position += UDim2.new(0, Next.X - Current.X, 0, Next.Y - Current.Y)

						Current = Next
					end
				end)

				Ended = Menu:Connect(InputService.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Changed:Disconnect()
						Ended:Disconnect()
					end
				end)
			end
		end)

		Menu:Connect(self.Window.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local Current = InputService:GetMouseLocation()
				local Changed
				local Ended

				Changed = Menu:Connect(InputService.InputChanged, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement then
						local Next = InputService:GetMouseLocation()

						self.Window.Position += UDim2.new(0, Next.X - Current.X, 0, Next.Y - Current.Y)

						Current = Next
					end
				end)

				Ended = Menu:Connect(InputService.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Changed:Disconnect()
						Ended:Disconnect()
					end
				end)
			end
		end)

		self:Connect(RunService.RenderStepped, function(Delta)
			local Maxed = false

			for Index, Notifcation in next, self.Notifications do
				local Time = tick()

				if Time - Notifcation.Time > Notifcation.Life then
					task.spawn(Notifcation.Destroy, Notifcation)	
					table.remove(self.Notifications, Index)
				elseif not Maxed and #self.Notifications > 10 then
					local First = table.remove(self.Notifcations, 1)
					task.spawn(First.Destroy, First)	
					Maxed = true
				else
					local Previous = self.Notifications[Index - 1]
					local Position = Previous and UDim2.new(0, 4, 0, Previous.Label.Position.Y.Offset + Previous.Label.TextBounds.Y + 1) or UDim2.new(0, 4, 0, 8)

					Notifcation.Label.Position = Position
					Notifcation.Label.Visible =  true

					Notifcation.Shadow.Position = Position + UDim2.new(0, 1, 0, 1)
					Notifcation.Shadow.Visible = true
				end
			end
		end)

		for _, Tab in next, self.Tabs do
			Tab:Init()
		end
	end
end

Global.Menu = Menu

return Menu, Menu.Flags

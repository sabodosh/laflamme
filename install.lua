--local REPOSITORY = "https://raw.githubusercontent.com/krovyaka/OpenComputers-Casino/master"
--https://username:password@github.com/username/repo_name.git
local REPOSITORY = "https://raw.githubusercontent.com/Krobys/cas/master"

local shell = require("shell")
shell.execute("wget -fq " .. REPOSITORY .. "/launcher.lua /home/1.lua")
shell.execute("wget -fq " .. REPOSITORY .. "/libs/casino.lua /lib/casino.lua")
shell.execute("wget -fq " .. REPOSITORY .. "/config/settings.lua /lib/settings.lua")
shell.execute("edit /lib/settings.lua")
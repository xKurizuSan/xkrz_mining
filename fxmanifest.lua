fx_version "cerulean"
game "gta5"
author "xKurizu"
description "ESX Mining Script by xKurizu"
version "1.0.0"

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua'
}

client_script {
	'config.lua',
	"client.lua",
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/CircleZone.lua'
}
server_script {
	"config.lua",
	"server.lua"
}
  
lua54 'yes'
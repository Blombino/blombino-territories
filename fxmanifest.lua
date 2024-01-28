fx_version 'cerulean'
games { 'rdr3', 'gta5' }
lua54 'yes'

author 'Blombino'
description 'github.com/Blombino'

ui_page 'html/index.html'

files{
    'html/**'
}

shared_scripts{
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts{
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/utils.lua',
    'client/main.lua'
}

server_scripts{
    '@mysql-async/lib/MySQL.lua',
    'server/class/*.lua',
    'server/utils.lua',
    'server/main.lua'
}
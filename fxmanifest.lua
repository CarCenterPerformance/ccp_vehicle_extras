fx_version 'cerulean'
game 'gta5'

description 'Fahrzeug Extras Menü mit ox_lib'

author 'CarCenterPerformance'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@es_extended/imports.lua',
    'server.lua'
}

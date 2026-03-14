fx_version 'cerulean'
game 'gta5'

author 'ShaggyMiagi'
description 'Player owned pawnshop script'
version '1.0.0'

dependencies {
    'qb-core',
    'lation_ui',
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

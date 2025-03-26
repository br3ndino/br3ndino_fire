fx_version 'cerulean'
game 'gta5'

author 'Br3ndino'
description 'Advanced Dynamic Fire System with Weather Integration'
version '1.0.0'

shared_script 'config.lua'

server_scripts {
    'server.lua',
    'fire_data.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'avweather',
    'ps-dispatch',
    'qb-core' -- Adjust if you use another framework
}

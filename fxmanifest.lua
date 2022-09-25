-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'SticksDev (sticks#2701)'
description 'A chaos mod for your FiveM server.'
version '1.0.0'

-- Load server scripts
server_script {
    'config/*.lua',
    'utils/*.lua',
    'server/*.lua',
}

-- Load client scripts
client_scripts {
    'config/*.lua',
    'utils/*.lua',
    'client/*.lua',
}
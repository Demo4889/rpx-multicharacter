fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'RPX Multicharacter'
author 'Sinatra#0101'
version '0.0.1'

shared_script '@ox_lib/init.lua'
shared_script 'init.lua'

ui_page {
    'ui/index.html'
}

files {
    'ui/index.html',
    'ui/script.js',
    'ui/style.css',
    'ui/*',
    'ui/fonts/*',
    'ui/img/*',

    'modules/**/client.lua',
    'shared/config.lua',
    'client.lua',
}

lua54 'yes'
---
--- RPX Multicharacter by Sinatra#0101
--- The RPX framework and its resources are still under heavy development.
--- Bugs and missing features are expected.
---

RPX = exports['rpx-core']:GetObject()

do
    require 'shared.config'

    if IsDuplicityVersion() then
        -- Server Modules
        require 'server'
    else
        -- Client Modules
        require 'client'
        require 'modules.camera.client'
        require 'modules.peds.client'
    end
end
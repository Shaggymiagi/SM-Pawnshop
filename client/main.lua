local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPeds = {}
local currentShop = nil

local function Notify(message, msgType)
    if Config.UI == 'ox_lib' then
        lib.notify({
            description = message,
            type = msgType or 'inform'
        })
    else
        exports.lation_ui:notify({
            message = message,
            type = msgType or 'inform'
        })
    end
end

CreateThread(function()
    if Config.ShowBlip then
        for k, v in pairs(Config.Pawnshops) do
            local blip = AddBlipForCoord(v.blipCoords.x, v.blipCoords.y, v.blipCoords.z)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.BlipScale)
            SetBlipColour(blip, Config.BlipColor)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function()
    for k, v in pairs(Config.Pawnshops) do
        RequestModel(GetHashKey(v.pedModel))
        while not HasModelLoaded(GetHashKey(v.pedModel)) do
            Wait(1)
        end
        
        local ped = CreatePed(4, GetHashKey(v.pedModel), v.pedCoords.x, v.pedCoords.y, v.pedCoords.z - 1.0, v.pedCoords.w, false, true)
        SetEntityHeading(ped, v.pedCoords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        spawnedPeds[k] = ped
    end
end)

CreateThread(function()
    if Config.TargetSystem ~= '3dtext' then
        for k, v in pairs(Config.Pawnshops) do
            if Config.TargetSystem == 'ox_target' then
                exports.ox_target:addSphereZone({
                    coords = vec3(v.pedCoords.x, v.pedCoords.y, v.pedCoords.z),
                    radius = 1.5,
                    debug = false,
                    options = {
                        {
                            name = "pawnshop_"..v.id,
                            event = "pawnshop:targetOpen",
                            icon = "fa-solid fa-store",
                            label = "Open Pawnshop",
                            shopId = v.id,
                            distance = 2.5
                        }
                    }
                })

                exports.ox_target:addSphereZone({
                    coords = vec3(v.ownerMenu.x, v.ownerMenu.y, v.ownerMenu.z),
                    radius = 1.5,
                    debug = false,
                    options = {
                        {
                            name = "pawnshop_owner_"..v.id,
                            event = "pawnshop:targetManage",
                            icon = "fa-solid fa-cog",
                            label = "Manage Pawnshop",
                            shopId = v.id,
                            distance = 2.5
                        }
                    }
                })
            elseif Config.TargetSystem == 'qb-target' then
                exports['qb-target']:AddCircleZone("pawnshop_"..v.id, vector3(v.pedCoords.x, v.pedCoords.y, v.pedCoords.z), 1.5, {
                    name = "pawnshop_"..v.id,
                    debugPoly = false,
                    useZ = true
                }, {
                    options = {
                        {
                            type = "client",
                            event = "pawnshop:targetOpen",
                            icon = "fas fa-store",
                            label = "Open Pawnshop",
                            shopId = v.id
                        }
                    },
                    distance = 2.5
                })

                exports['qb-target']:AddCircleZone("pawnshop_owner_"..v.id, vector3(v.ownerMenu.x, v.ownerMenu.y, v.ownerMenu.z), 1.5, {
                    name = "pawnshop_owner_"..v.id,
                    debugPoly = false,
                    useZ = true
                }, {
                    options = {
                        {
                            type = "client",
                            event = "pawnshop:targetManage",
                            icon = "fas fa-cog",
                            label = "Manage Pawnshop",
                            shopId = v.id
                        }
                    },
                    distance = 2.5
                })
            end
        end
    else
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for k, v in pairs(Config.Pawnshops) do
                local dist = #(playerCoords - v.pedCoords.xyz)
                local distOwner = #(playerCoords - v.ownerMenu)
                
                if dist < Config.InteractionDistance then
                    sleep = 0
                    QBCore.Functions.DrawText3D(v.pedCoords.x, v.pedCoords.y, v.pedCoords.z + 1.0, "Open Pawnshop")
                    
                    if IsControlJustReleased(0, 38) then
                        currentShop = v.id
                        OpenPawnshop(v.id)
                    end
                end
                
                if distOwner < Config.InteractionDistance then
                    sleep = 0
                    QBCore.Functions.DrawText3D(v.ownerMenu.x, v.ownerMenu.y, v.ownerMenu.z, "Manage Pawnshop")
                    
                    if IsControlJustReleased(0, 38) then
                        currentShop = v.id
                        OpenOwnerMenu(v.id)
                    end
                end
            end
            
            Wait(sleep)
        end
    end
end)

RegisterNetEvent('pawnshop:targetOpen', function(data)
    currentShop = data.shopId
    OpenPawnshop(data.shopId)
end)

RegisterNetEvent('pawnshop:targetManage', function(data)
    currentShop = data.shopId
    OpenOwnerMenu(data.shopId)
end)

RegisterNetEvent('pawnshop:notify', function(message, msgType)
    Notify(message, msgType)
end)

function OpenPawnshop(shopId)
    QBCore.Functions.TriggerCallback('pawnshop:getShopData', function(items)
        if not items then
            Notify(Config.Locales['no_items'], 'error')
            return
        end
        
        local menuItems = {}
        for k, v in pairs(items) do
            table.insert(menuItems, {
                title = v.label,
                description = "Amount: "..v.amount.." | Price: $"..v.price.." each",
                icon = 'fas fa-box',
                serverEvent = 'pawnshop:sellItem',
                args = {
                    item = v.name,
                    shopId = shopId
                }
            })
        end
        
        if Config.UI == 'ox_lib' then
            local options = {}
            for _, v in ipairs(menuItems) do
                options[#options+1] = {
                    title = v.title,
                    description = v.description,
                    icon = v.icon,
                    -- Call the client event that opens the amount dialog,
                    -- then that will trigger the server confirmation.
                    event = 'pawnshop:openAmountInput',
                    args = v.args
                }
            end

            lib.registerContext({
                id = 'pawnshop_sell_menu',
                title = 'Pawnshop',
                options = options
            })
            lib.showContext('pawnshop_sell_menu')
        else
            exports.lation_ui:registerMenu({
                id = 'pawnshop_sell_menu',
                title = 'Pawnshop',
                subtitle = 'Select an item to sell',
                options = menuItems
            })
            exports.lation_ui:showMenu('pawnshop_sell_menu')
        end
    end, shopId)
end

function OpenOwnerMenu(shopId)
    QBCore.Functions.TriggerCallback('pawnshop:getOwnerData', function(data)
        if not data then
            Notify(Config.Locales['not_owner'], 'error')
            return
        end
        
        local menuItems = {
            {
                title = "Current Profit: $"..data.profit,
                icon = 'fas fa-money-bill',
                readOnly = true
            }
        }
        
        if data.isOwner then
            table.insert(menuItems, {
                title = "Collect Profit",
                description = "Collect $"..data.profit,
                icon = 'fas fa-hand-holding-dollar',
                serverEvent = 'pawnshop:collectProfit',
                args = {shopId = shopId}
            })
            
            table.insert(menuItems, {
                title = "Sell Pawnshop",
                description = "Sell for $"..(Config.PurchasePrice / 2),
                icon = 'fas fa-store-slash',
                serverEvent = 'pawnshop:sellShop',
                args = {shopId = shopId}
            })
        else
            table.insert(menuItems, {
                title = "Purchase Pawnshop",
                description = "Buy for $"..Config.PurchasePrice,
                icon = 'fas fa-cart-shopping',
                serverEvent = 'pawnshop:buyShop',
                args = {shopId = shopId}
            })
        end
        
        if Config.UI == 'ox_lib' then
            local options = {}
            for _, v in ipairs(menuItems) do
                options[#options+1] = {
                    title = v.title,
                    description = v.description,
                    icon = v.icon,
                    event = v.serverEvent,
                    args = v.args,
                    readOnly = v.readOnly
                }
            end

            lib.registerContext({
                id = 'pawnshop_owner_menu',
                title = Config.Pawnshops[shopId].name,
                options = options
            })
            lib.showContext('pawnshop_owner_menu')
        else
            exports.lation_ui:registerMenu({
                id = 'pawnshop_owner_menu',
                title = Config.Pawnshops[shopId].name,
                subtitle = 'Manage your pawnshop',
                options = menuItems
            })
            exports.lation_ui:showMenu('pawnshop_owner_menu')
        end
    end, shopId)
end

function GetItemAmount(callback)
    local result

    if Config.UI == 'ox_lib' then
        result = lib.inputDialog("Sell Items", {
            {
                type = 'number',
                label = 'Amount',
                min = 1
            }
        })
    else
        result = exports.lation_ui:input({
            title = "Sell Items",
            subtitle = "Enter the amount you want to sell",
            options = {
                {
                    type = 'number',
                    label = 'Amount',
                    placeholder = 'Enter amount to sell',
                    icon = 'fas fa-hashtag',
                    required = true,
                    min = 1
                }
            }
        })
    end
    
    if result and result[1] then
        callback(tonumber(result[1]))
    end
end

RegisterNetEvent('pawnshop:openAmountInput', function(dataOrItem, maybeShopId)
    local item, shopId

    if type(dataOrItem) == 'table' then
        item = dataOrItem.item
        shopId = dataOrItem.shopId
    else
        item = dataOrItem
        shopId = maybeShopId
    end

    if not item or not shopId then
        return
    end

    GetItemAmount(function(amount)
        if amount and amount > 0 then
            TriggerServerEvent('pawnshop:sellItemConfirm', item, amount, shopId)
        end
    end)
end)

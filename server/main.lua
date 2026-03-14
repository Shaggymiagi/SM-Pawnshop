
local QBCore = exports['qb-core']:GetCoreObject()

-- Create database table on resource start
CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS pawnshop_owned (
            id INT AUTO_INCREMENT PRIMARY KEY,
            shop_id INT NOT NULL UNIQUE,
            owner_citizenid VARCHAR(50) NOT NULL,
            profit INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
end)

-- Get shop ownership data
QBCore.Functions.CreateCallback('pawnshop:getOwnerData', function(source, cb, shopId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(nil) return end
    
    MySQL.Async.fetchAll('SELECT * FROM pawnshop_owned WHERE shop_id = ?', {shopId}, function(result)
        if result[1] then
            local isOwner = result[1].owner_citizenid == Player.PlayerData.citizenid
            cb({
                isOwner = isOwner,
                profit = result[1].profit,
                owner = result[1].owner_citizenid
            })
        else
            cb({isOwner = false, profit = 0})
        end
    end)
end)

-- Get player's sellable items
QBCore.Functions.CreateCallback('pawnshop:getShopData', function(source, cb, shopId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(nil) return end
    
    local items = {}
    for k, v in pairs(Config.Items) do
        local item = Player.Functions.GetItemByName(k)
        if item and item.amount > 0 then
            table.insert(items, {
                name = k,
                label = v.label,
                amount = item.amount,
                price = v.price
            })
        end
    end
    
    if #items > 0 then
        cb(items)
    else
        cb(nil)
    end
end)

-- Buy pawnshop
RegisterNetEvent('pawnshop:buyShop', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local shopId = data.shopId
    
    MySQL.Async.fetchAll('SELECT * FROM pawnshop_owned WHERE shop_id = ?', {shopId}, function(result)
        if result[1] then
            TriggerClientEvent('lation_ui:notify', src, Config.Locales['shop_owned'], 'error')
            return
        end
        
        if Player.PlayerData.money.cash >= Config.PurchasePrice then
            Player.Functions.RemoveMoney('cash', Config.PurchasePrice, "pawnshop-purchase")
            
            MySQL.Async.insert('INSERT INTO pawnshop_owned (shop_id, owner_citizenid, profit) VALUES (?, ?, ?)', {
                shopId,
                Player.PlayerData.citizenid,
                0
            }, function(id)
                TriggerClientEvent('pawnshop:notify', src, string.format(Config.Locales['shop_purchased'], Config.PurchasePrice), 'success')
            end)
        elseif Player.PlayerData.money.bank >= Config.PurchasePrice then
            Player.Functions.RemoveMoney('bank', Config.PurchasePrice, "pawnshop-purchase")
            
            MySQL.Async.insert('INSERT INTO pawnshop_owned (shop_id, owner_citizenid, profit) VALUES (?, ?, ?)', {
                shopId,
                Player.PlayerData.citizenid,
                0
            }, function(id)
                TriggerClientEvent('pawnshop:notify', src, string.format(Config.Locales['shop_purchased'], Config.PurchasePrice), 'success')
            end)
        else
            TriggerClientEvent('pawnshop:notify', src, Config.Locales['not_enough_money'], 'error')
        end
    end)
end)

-- Sell pawnshop
RegisterNetEvent('pawnshop:sellShop', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local shopId = data.shopId
    local sellPrice = Config.PurchasePrice / 2
    
    MySQL.Async.fetchAll('SELECT * FROM pawnshop_owned WHERE shop_id = ? AND owner_citizenid = ?', {
        shopId,
        Player.PlayerData.citizenid
    }, function(result)
        if not result[1] then
            TriggerClientEvent('pawnshop:notify', src, Config.Locales['not_owner'], 'error')
            return
        end
        
        local totalPayout = sellPrice + result[1].profit
        Player.Functions.AddMoney('bank', totalPayout, "pawnshop-sale")
        
        MySQL.Async.execute('DELETE FROM pawnshop_owned WHERE shop_id = ?', {shopId}, function()
            TriggerClientEvent('pawnshop:notify', src, string.format(Config.Locales['shop_sold'], totalPayout), 'success')
        end)
    end)
end)

-- Collect profit
RegisterNetEvent('pawnshop:collectProfit', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local shopId = data.shopId
    
    MySQL.Async.fetchAll('SELECT * FROM pawnshop_owned WHERE shop_id = ? AND owner_citizenid = ?', {
        shopId,
        Player.PlayerData.citizenid
    }, function(result)
        if not result[1] then
            TriggerClientEvent('pawnshop:notify', src, Config.Locales['not_owner'], 'error')
            return
        end
        
        local profit = result[1].profit
        if profit > 0 then
            Player.Functions.AddMoney('bank', profit, "pawnshop-profit")
            
            MySQL.Async.execute('UPDATE pawnshop_owned SET profit = 0 WHERE shop_id = ?', {shopId}, function()
                TriggerClientEvent('pawnshop:notify', src, string.format(Config.Locales['shop_profit_collected'], profit), 'success')
            end)
        else
            TriggerClientEvent('pawnshop:notify', src, "No profit to collect", 'error')
        end
    end)
end)

-- Sell item
RegisterNetEvent('pawnshop:sellItem', function(data)
    local src = source
    TriggerClientEvent('pawnshop:openAmountInput', src, data.item, data.shopId)
end)

RegisterNetEvent('pawnshop:sellItemConfirm', function(itemName, amount, shopId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local itemData = Config.Items[itemName]
    if not itemData then return end
    
    local item = Player.Functions.GetItemByName(itemName)
    if not item or item.amount < amount then
        TriggerClientEvent('pawnshop:notify', src, "You don't have enough of this item", 'error')
        return
    end
    
    -- Calculate prices
    local basePrice = itemData.price * amount
    local playerCut = math.floor(basePrice * (100 - Config.OwnerCutPercentage) / 100)
    local ownerCut = basePrice - playerCut
    
    -- Remove item from player
    if Player.Functions.RemoveItem(itemName, amount) then
        -- Give money to player
        Player.Functions.AddMoney('cash', playerCut, "pawnshop-sale")
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "remove", amount)
        TriggerClientEvent('pawnshop:notify', src, string.format(Config.Locales['item_sold'], amount, itemData.label, playerCut), 'success')
        
        -- Add profit to shop owner
        MySQL.Async.fetchAll('SELECT * FROM pawnshop_owned WHERE shop_id = ?', {shopId}, function(result)
            if result[1] then
                local newProfit = result[1].profit + ownerCut
                if newProfit <= Config.MaxProfit then
                    MySQL.Async.execute('UPDATE pawnshop_owned SET profit = ? WHERE shop_id = ?', {
                        newProfit,
                        shopId
                    })
                end
            end
        end)
    end
end)
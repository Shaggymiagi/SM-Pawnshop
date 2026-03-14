Config = {}

-- General Settings
Config.TargetSystem = 'ox_target' -- 'ox_target', 'qb-target', '3dtext'
Config.UI = 'ox_lib' -- 'ox_lib' or 'lation_ui'
Config.InteractionDistance = 2.5 -- Distance to interact with pawnshop
Config.BlipSprite = 431 -- Blip sprite ID
Config.BlipColor = 5 -- Blip color
Config.BlipScale = 0.8 -- Blip scale
Config.ShowBlip = true -- Show blips on map

-- Ownership Settings
Config.PurchasePrice = 50000 -- Price to buy a pawnshop
Config.MaxProfit = 100000 -- Max money that can accumulate in shop before needing collection
Config.OwnerCutPercentage = 70 -- Percentage of sale price that goes to owner (rest goes to player selling)

-- Pawnshop Locations
Config.Pawnshops = {
    {
        id = 1,
        name = "Davis Pawnshop",
        blipCoords = vector3(456.47, -1480.08, 28.29),
        pedCoords = vector4(456.47, -1480.08, 29.29, 110.52),
        pedModel = "s_m_y_clubbar_01",
        ownerMenu = vector3(181.5, -1318.5, 29.32), -- Where owner manages shop
    },
}

-- Items that can be sold
-- price = base price (player gets this amount minus owner cut)
-- ownerProfit = what owner receives per item sold
Config.Items = {
    -- Electronics
    ["phone"] = {price = 150, label = "Phone"},
    ["radio"] = {price = 100, label = "Radio"},
    ["tablet"] = {price = 300, label = "Tablet"},
    ["laptop"] = {price = 500, label = "Laptop"},
    
    -- Jewelry
    ["goldchain"] = {price = 200, label = "Gold Chain"},
    ["diamond_ring"] = {price = 500, label = "Diamond Ring"},
    ["rolex"] = {price = 1000, label = "Rolex Watch"},
    ["goldbar"] = {price = 2000, label = "Gold Bar"},
    
    -- Valuables
    ["security_card_01"] = {price = 100, label = "Security Card"},
    ["security_card_02"] = {price = 150, label = "Security Card"},
    ["markedbills"] = {price = 800, label = "Marked Bills"},
    
    -- Misc
    ["painkillers"] = {price = 50, label = "Painkillers"},
    ["weapon_pistol"] = {price = 1500, label = "Pistol"},
    ["weapon_knife"] = {price = 100, label = "Knife"},
}

-- Locales
Config.Locales = {
    ['press_to_open'] = 'Press ~g~[E]~w~ to open Pawnshop',
    ['press_to_manage'] = 'Press ~g~[E]~w~ to manage Pawnshop',
    ['not_owner'] = 'You do not own this pawnshop',
    ['shop_owned'] = 'This pawnshop is already owned',
    ['shop_purchased'] = 'You have purchased this pawnshop for $%s',
    ['not_enough_money'] = 'You do not have enough money',
    ['item_sold'] = 'You sold %sx %s for $%s',
    ['no_items'] = 'You have no items to sell',
    ['shop_profit_collected'] = 'Collected $%s from your pawnshop',
    ['shop_sold'] = 'You sold your pawnshop for $%s',
    ['confirm_purchase'] = 'Purchase this pawnshop for $%s?',
    ['confirm_sell'] = 'Sell your pawnshop for $%s?',
}
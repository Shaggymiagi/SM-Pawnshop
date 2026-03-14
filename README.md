[QBCore/QBOX] SM-Pawnshop
A comprehensive pawnshop script for QBCore/QBOX with player ownership system.

Features
✅ Player Ownership - Players own pawnshops
✅ Profit System - Owners earn a percentage from all sales at their shop
✅ Fully Configurable - Easy config file for locations, peds, items, and prices
✅ Multiple Locations - Support for unlimited pawnshop locations
✅ Sell-Only System - Players can only sell items, not buy
✅ QBCore Integration - Full integration with QBCore framework
✅ Simple UI - Uses a Choice of QB-Menu OX-Lib And Lation-UI for a nice UI Interface
✅ Multiple Options - Either OX_Target or QB-Target we have you covered with SM-Pawnshop it is a sleek easy change in the CFG
---------------
Dependencies
qb-core
qb-menu
qb-input
oxmysql
---------------
Installation
Download and extract the script to your resources folder
Rename the folder to pawnshop or your preferred name
Add ensure pawnshop to your server.cfg
Configure the script in config.lua
Restart your server (database table will be created automatically)
---------------
Configuration
Adding/Editing Locations
Edit the Config.Pawnshops table in config.lua:

lua
{
    id = 1, -- Unique ID for the shop
    name = "Downtown Pawnshop", -- Display name
    blipCoords = vector3(182.6, -1319.88, 29.32), -- Blip location
    pedCoords = vector4(182.6, -1319.88, 29.32, 158.36), -- Ped location + heading
    pedModel = "s_m_y_ammucity_01", -- Ped model
    ownerMenu = vector3(181.5, -1318.5, 29.32), -- Owner management location
}
Adding/Editing Items
Edit the Config.Items table in config.lua:

lua
["item_name"] = {
    price = 150, -- Price player receives (before owner cut)
    label = "Display Name"
}
Ownership Settings
lua
Config.PurchasePrice = 50000 -- Cost to buy a pawnshop
Config.MaxProfit = 100000 -- Max profit that can accumulate
Config.OwnerCutPercentage = 70 -- Owner's percentage (70 = owner gets 70%, player gets 30%)
Changing Ped Models
You can use any GTA V ped model. Common options:

s_m_y_ammucity_01 - Gun store clerk
s_m_m_autoshop_01 - Mechanic
a_m_m_business_01 - Business man
mp_m_shopkeep_01 - Shop keeper
Find more at: GTA V Ped Models
---------------
Usage
For Players
Selling Items: Walk up to the pawnshop ped and press E to open the sell menu
Select an item from your inventory that's in the sellable list
Enter the amount you want to sell
Receive payment in cash
For Shop Owners
Buying a Shop: Go to the owner management location and press E, then select "Purchase Pawnshop"
Collecting Profit: Return to the owner location and select "Collect Profit"
Selling a Shop: Select "Sell Pawnshop" to sell for 50% of purchase price + accumulated profit
How Profit Works
When a player sells an item at your pawnshop:

Player receives: Item price × (100 - Owner Cut %)
Owner receives: Item price × Owner Cut %
Example with 70% owner cut:

Item price: $1000
Player gets: $300
Owner gets: $700 (added to shop profit)
Customization Notes
Using qb-target Instead
If you want to use qb-target instead of the default interaction:

Set Config.UseTarget = true in config.lua
Add target exports in client/main.lua (code provided below)
lua
-- Add this after spawning peds
exports['qb-target']:AddTargetEntity(ped, {
    options = {
        {
            icon = "fas fa-dollar-sign",
            label = "Open Pawnshop",
            action = function()
                OpenPawnshop(k)
            end
        }
    },
    distance = 2.5
})
---------------
Support
For issues or questions: DM ShaggyMiagi on discord or shaggymiagiv2

Check the config.lua for all available settings
Ensure all dependencies are installed and up-to-date
Verify your database connection is working
Check server console for errors

License
© SM Development 2026 Fivem Development Designs and Patents Act 1988 (CDPA)


ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx:playerLoaded', function (source)
	TriggerEvent("playerSpawned")
end)

TriggerEvent('es:addGroupCommand', 'giveitem', 'superadmin', function(source, args, user)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(args[1])
	local item    = args[2]
    local count   = (args[3] == nil and 1 or tonumber(args[3]))
    local playerName = Sanitize(xPlayer.getName())

    roninenvlog(xPlayer,playerName.. ' Adlı Kişi Kendine Bu İtemi Verdi:' ..item.. ' | Tanesi :'..count)

    if count ~= nil then
		if xPlayer ~= nil then
            TriggerClientEvent('player:receiveItem', xPlayer.source, ""..item.."", count)
		else
            TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'Invalid Item'})
		end
	else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'Invalid Amount'})
	end
end, function(source, args, user)
    TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You dont have permissions'})
end, {help='Give a item n dat'})

TriggerEvent('es:addGroupCommand', 'clearinventory', 'superadmin', function(source, args, user)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(args[1])
    if xPlayer ~= nil then
        exports.ghmattimysql:execute('DELETE FROM ronin_inventory WHERE name = @name AND item_id != @itemid AND item_id != @itemid2 AND item_id != @itemid3', {
            ['@name'] = xPlayer.identifier,
            ['@itemid'] = "motelkeys",
            ['@itemid2'] = "idcard",
            ['@itemid3'] = "driverlicense"
        })
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'Bu id oyunda yok'})
    end
end)

RegisterServerEvent('inventory:clearinventory')
AddEventHandler('inventory:clearinventory', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        exports.ghmattimysql:execute('DELETE FROM ronin_inventory WHERE name = @name AND item_id != @itemid AND item_id != @itemid2 AND item_id != @itemid3', {
            ['@name'] = xPlayer.identifier,
            ['@itemid'] = "motelkeys",
            ['@itemid2'] = "idcard",
            ['@itemid3'] = "driverlicense"
        })
    end
end)

RegisterServerEvent('cash:remove')
AddEventHandler('cash:remove', function(source, cash)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getMoney() >= cash then
	xPlayer.removeMoney(cash)
	TriggerClientEvent("banking:removeBalance", source, cash)
	end
end)



RegisterServerEvent('people-search')
AddEventHandler('people-search', function(target)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(target)
    local identifier = xPlayer.identifier
	TriggerClientEvent("server-inventory-open", source, "1", identifier)

end)

RegisterServerEvent("server-item-quality-update")
AddEventHandler("server-item-quality-update", function(player, data)
	local quality = data.quality
	local slot = data.slot
	local itemid = data.item_id

    exports.ghmattimysql:execute("UPDATE ronin_inventory SET `quality` = @quality WHERE name = @name AND slot = @slot AND item_id = @item_id", {['quality'] = quality, ['name'] = player, ['slot'] = slot, ['item_id'] = itemid})
  
end)

RegisterServerEvent('police:SeizeCash')
AddEventHandler('police:SeizeCash', function(target)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local zPlayer = ESX.GetPlayerFromId(target)

    if not xPlayer.job.name == 'police' then
        print('steam:'..identifier..' User attempted sieze cash')
        return
    end
    TriggerClientEvent("banking:addBalance", src, zPlayer.getMoney())
    TriggerClientEvent("banking:removeBalance", target, zPlayer.getMoney())
    zPlayer.setMoney(0)
    TriggerClientEvent('notification', target, 'Your cash was seized',1)
    TriggerClientEvent('notification', src, 'Seized persons cash', 1)
 

end)


function roninenvlog(xPlayer, text)
    local playerName = Sanitize(xPlayer.getName())
   
    local discord_webhook = "https://discord.com/api/webhooks/793094431511150612/83RBO5SOngmQkiM7TDR6Sfyk_IktN3ZTzQyTi6EGEsdJ6PEQ1ed19863yIIxwjqQ234n"
    if discord_webhook == '' then
      return
    end
    local headers = {
      ['Content-Type'] = 'application/json'
    }
    local data = {
      ["username"] = "Ronin Log System",
      ["avatar_url"] = "https://cdn.discordapp.com/attachments/787311484446703658/792703219934953513/pullrp3.png",
      ["embeds"] = {{
        ["author"] = {
          ["name"] = playerName .. ' - ' .. xPlayer.identifier 
        },
        ["color"] = 1942002,
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
      }}
    }
    data['embeds'][1]['description'] = text
    PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

function Sanitize(str)
    local replacements = {
        ['&' ] = '&amp;',
        ['<' ] = '&lt;',
        ['>' ] = '&gt;',
        ['\n'] = '<br/>'
    }

    return str
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s)
            return ' '..('&nbsp;'):rep(#s-1)
        end)
end


RegisterServerEvent('Stealtheybread')
AddEventHandler('Stealtheybread', function(target, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local zPlayer = ESX.GetPlayerFromId(target)
    local zPlayerMoney = zPlayer.getMoney()

    if not xPlayer.job.name == 'police' then
        print('steam:'..identifier..' User attempted sieze cash')
        return
    end
    if zPlayerMoney > amount then        
        xPlayer.addMoney(amount)
        zPlayer.removeMoney(amount)
        TriggerClientEvent("banking:updateCash", src, xPlayer.getMoney(), true)
        TriggerClientEvent('notification', target, 'Your cash was robbed off you.', 1)
    else
        xPlayer.addMoney(zPlayerMoney)
        zPlayer.removeMoney(zPlayerMoney)
        TriggerClientEvent("banking:updateCash", src, xPlayer.getMoney(), true)
        TriggerClientEvent('notification', target, 'Your cash was robbed off you.', 1)
    end
end)


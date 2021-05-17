ESX = nil
local Licenses = {}
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
        TriggerServerEvent("playerSpawned")
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)


Citizen.CreateThread(function()
    while ESX == nil or ESX.PlayerData == nil or ESX.PlayerData.job == nil do
        Citizen.Wait(1)
    end
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)



local fixingvehicle = false
local justUsed = false
local retardCounter = 0
local lastCounter = 0 
local HeadBone = 0x796e;



local validWaterItem = {
    ["oxygentank"] = true,
    ["water"] = true,
    ["vodka"] = true,
    ["beer"] = true,
    ["whiskey"] = true,
    ["coffee"] = true,
    ["fishtaco"] = true,
    ["taco"] = true,
    ["burrito"] = true,
    ["churro"] = true,
    ["hotdog"] = true,
    ["greencow"] = true,
    ["donut"] = true,
    ["eggsbacon"] = true,
    ["icecream"] = true,
    ["mshake"] = true,
    ["sandwich"] = true,
    ["hamburger"] = true,
    ["cola"] = true,
    ["jailfood"] = true,
    ["bleederburger"] = true,
    ["heartstopper"] = true,
    ["torpedo"] = true,
    ["meatfree"] = true,
    ["moneyshot"] = true,
    ["fries"] = true,
    ["slushy"] = true,

}



Citizen.CreateThread(function()

    
    TriggerServerEvent("inv:playerSpawned");
end)


Citizen.CreateThread(function()
    while true do 
     Citizen.Wait(0)

    local model = GetHashKey("w_ar_advancedrifle") -- Change model name here <--
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
    
     if IsControlJustPressed(0, 289) then 
         TriggerEvent("OpenInv")
      end
    end
 end)


RegisterNetEvent('RunUseItem')
AddEventHandler('RunUseItem', function(itemid, slot, inventoryName, isWeapon)
    if itemid == nil then
        return
    end
    local ItemInfo = GetItemInfo(slot)
    if tonumber(ItemInfo.quality) <= 1 then
        TriggerEvent("notification","Bi Eşya Kırılmış!",2) 
        if isWeapon then
            TriggerEvent("brokenWeapon")
        end
        return
    end
    if justUsed then
        retardCounter = retardCounter + 1
        if retardCounter > 10 and retardCounter > lastCounter+5 then
            lastCounter = retardCounter
            TriggerServerEvent("exploiter", "Tried using " .. retardCounter .. " items in < 500ms ")
        end
        return
    end

    justUsed = true

    -- if (not hasEnoughOfItem(itemid,1,false)) then
    --     TriggerEvent("notification","You dont appear to have this item on you?",2) 
    --     justUsed = false
    --     retardCounter = 0
    --     lastCounter = 0
    --     return
    -- end

    if itemid == "-72657034" then
        TriggerEvent("equipWeaponID",itemid,ItemInfo.information,ItemInfo.id)
        TriggerEvent("inventory:removeItem",itemid, 1)
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if not isValidUseCase(itemid,isWeapon) then
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if (itemid == nil) then
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    
    if (isWeapon) then
        TriggerEvent("equipWeaponID",itemid,ItemInfo.information,ItemInfo.id)
     
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if (isWeapon) then
        local curWeapon = GetSelectedPedWeapon(PlayerPedId())
        if curWeapon == GetHashKey('WEAPON_UNARMED') then
            TriggerEvent("hud-display-item",itemid,"Holster")
            print(GetCurrentPedWeapon(PlayerPedId(), true))
        else
            TriggerEvent("hud-display-item",itemid,"Unholster")
            print(GetCurrentPedWeapon(PlayerPedId(), true))
        end
       --local itemInfo = GetItemInfo(slot)
       --print(json.encode(itemInfo))
       --if tonumber(itemInfo.quality) > 0 then
            TriggerEvent("equipWeaponID",itemid, "", itemid)
        --end
        print(GetCurrentPedWeapon(PlayerPedId(), true))

        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end


    TriggerEvent("hud-display-item",itemid,"Used")

    Wait(800)

    local player = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(player, false)

    if (not IsPedInAnyVehicle(player)) then
        if (itemid == "Suitcase") then
            TriggerEvent('attach:suitcase')
        end

        if (itemid == "Boombox") then
                TriggerEvent('attach:boombox')
        end
        if (itemid == "Box") then
                TriggerEvent('attach:box')
        end
        if (itemid == "DuffelBag") then
                TriggerEvent('attach:blackDuffelBag')
        end
        if (itemid == "MedicalBag") then
                TriggerEvent('attach:medicalBag')
        end
        if (itemid == "SecurityCase") then
                TriggerEvent('attach:securityCase')
        end
        if (itemid == "Toolbox") then
                TriggerServerEvent('np-weapons:getAmmo')
                print("toolbox kulandık")
        end
    end

    local remove = false
    local drugitem = false
    local fooditem = false
    local drinkitem = false
    local healitem = false

    if (itemid == "joint" or itemid == "weed5oz" or itemid == "weedq" or itemid == "beer" or itemid == "vodka" or itemid == "whiskey" or itemid == "lsdtab") then
        drugitem = true
    end

    if (itemid == "fakeplate") then
      TriggerEvent("fakeplate:change")
    end

    if (itemid == "radio") then
        TriggerEvent('sup_radio:use', source)
    end

    if (itemid == "tuner") then

      local finished = exports["8x-taskbar"]:taskBar(2000,"Connecting Tuner Laptop",false,false,playerVeh)
      if (finished == 100) then
        TriggerEvent("tuner:open")
      end
    end

    if (itemid == "Gruppe6Card") then
        TriggerEvent("hsn-bankrob:client:startrob")
    end

    if (itemid == "electronickit" or itemid == "lockpick") then
      TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
      
    end
    if (itemid == "locksystem") then
      TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "thermite") then

    end

    if (itemid == "olta") then
        TriggerEvent("emrfish:basla", source, true)
    end

    if(itemid == "evidencebag") then
        TriggerEvent("server-inventory-open", "1", "Kanıt Çantası")
    end

    if (itemid == "lsdtab" or itemid == "badlsdtab") then
        TriggerEvent("animation:PlayAnimation","pill")
        local finished = exports["8x-taskbar"]:taskBar(3000,"Placing LSD Strip on 👅",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("Evidence:StateSet",2,1200)
            TriggerEvent("Evidence:StateSet",24,1200)
            TriggerEvent("fx:run", "lsd", 180, nil, (itemid == "badlsdtab" and true or false))
            remove = true
        end
    end

    if (itemid == "decryptersess" or itemid == "decrypterfv2" or itemid == "decrypterenzo") then
      if (#(GetEntityCoords(player) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["8x-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if (finished == 100) then
            TriggerEvent("pixerium:check",3,"robbery:decrypt",true)
          end
      end

      if #(GetEntityCoords(player) - vector3( 2328.94, 2571.4, 46.71)) < 3.0 then
          local finished = exports["8x-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if finished == 100 then
            TriggerEvent("pixerium:check",3,"robbery:decrypt2",true)
          end
      end

      if #(GetEntityCoords(player) - vector3( 1208.73,-3115.29, 5.55)) < 3.0 then
          local finished = exports["8x-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if finished == 100 then
            TriggerEvent("pixerium:check",3,"robbery:decrypt3",true)
          end
      end
      
    end

    if (itemid == "pix1") then
      if (#(GetEntityCoords(player) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["8x-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if (finished == 100) then
            TriggerEvent("Crypto:GivePixerium",math.random(1,2))
            remove = true
          end
      end
    end  

    if (itemid == "pix2") then
      if (#(GetEntityCoords(player) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["8x-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
          if (finished == 100) then
            TriggerEvent("Crypto:GivePixerium",math.random(5,12))
            remove = true
          end
      end
    end


    if (itemid == "femaleseed") then
        TriggerEvent("Evidence:StateSet",4,1600)
        TriggerEvent("weed:startcropInsideCheck","female")
        
     end
 
     if (itemid == "maleseed") then
         TriggerEvent("Evidence:StateSet",4,1600)
         TriggerEvent("weed:startcropInsideCheck","male")
         
     end
 
     if (itemid == "weedoz") then
  
       local finished = exports["8x-taskbar"]:taskBar(5000,"Packing Q Bags",false,false,playerVeh)
         if (finished == 100) then
             CreateCraftOption("weedq", 40, true)
         end
         
     end
 
     if (itemid == "weedq") then
         local finished = exports["8x-taskbar"]:taskBar(1000,"Rolling Joints",false,false,playerVeh)
         if (finished == 100) then
             CreateCraftOption("joint", 80, true)    
         end
         
     end
 
     if (itemid == "lighter") then
         TriggerEvent("animation:PlayAnimation","lighter")
           local finished = exports["8x-taskbar"]:taskBar(2000,"Starting Fire",false,false,playerVeh)
         if (finished == 100) then
             
         end
         
     end
 
     if (itemid == "joint") then
         Citizen.Wait(1)
         TriggerEvent("inventory:removeItem",'joint', 1)
         local playerPed = PlayerPedId()
         ExecuteCommand('e ot')
         local finished = exports["8x-taskbar"]:taskBar(3000,"Jointi İçiyorsun",false,false,playerVeh)
         if (finished == 100) then
            StartScreenEffect(effects, sure, 0)
            armordoldur = false
            Citizen.CreateThread(function()
                while(true) do
                    if armordoldur == false then 
                        Citizen.Wait(1000)
                        AddArmourToPed(playerPed, 3)
                    else
                        Citizen.Wait(100)
                    end
                end
            end)
            Citizen.Wait(5000)
            armordoldur = true
         end
     end
 
     if (itemid == "vodka" or itemid == "beer" or itemid == "whiskey") then
         AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"İçiyorsun","changethirst",true,itemid,playerVeh)
         TriggerEvent("Evidence:StateSet", 8, 600)
         local alcoholStrength = 0.5
         if itemid == "vodka" or itemid == "whiskey" then alcoholStrength = 1.0 end
         TriggerEvent("fx:run", "alcohol", 180, alcoholStrength)
     end
 
     if (itemid == "coffee") then
         AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"İçiyorsun","coffee:drink",true,itemid,playerVeh)
     end
 
     if (itemid == "fishtaco") then
         AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Yiyorsun","food:FishTaco",true,itemid,playerVeh)
     end
 
     if (itemid == "taco" or itemid == "burrito") then
         AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Yiyorsun","food:Taco",true,itemid,playerVeh)
     end
 
     if (itemid == "churro" or itemid == "hotdog") then
         TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Yiyorsun","food:Condiment",true,itemid,playerVeh)
     end
 
     if (itemid == "greencow") then
         AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"İçiyorsun","food:Condiment",true,itemid,playerVeh)
     end
 
     if (itemid == "donut" or itemid == "eggsbacon") then
         AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Yiyorsun","food:Condiment",true,itemid,playerVeh)
     end
 
     if (itemid == "icecream" or itemid == "mshake") then
         TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Yiyorsun","food:IceCream",true,itemid,playerVeh)
    end
 
 
 
    if (itemid == "advlockpick") then
        TriggerEvent('houseRobberies:attempt')
    end

    if (itemid == "Gruppe6Card") then
        TriggerEvent('emrtruck:rob')
    end

    if (itemid == "Gruppe6Card22") then
        TriggerServerEvent("np-robbery:goldcard",itemid)
    end

    if (itemid == "Gruppe6Card2") then
        TriggerServerEvent("np-robbery:greencard",itemid)
    end

    if (itemid == "Gruppe6Card") then
        TriggerEvent("emrtruck:rob")
    end

     if (itemid == "Gruppe6Car") then

        local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
        local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 100.0, 0.0)
        local countpolice = exports["isPed"]:isPed("countpolice")
        local targetVehicle = getVehicleInDirection(coordA, coordB)
        if targetVehicle ~= 0 and GetHashKey("stockade") == GetEntityModel(targetVehicle) and countpolice > 2 then
            local entityCreatePoint = GetOffsetFromEntityInWorldCoords(targetVehicle, 0.0, -4.0, 0.0)
            local coords = GetEntityCoords(GetPlayerPed(-1))
            local aDist = GetDistanceBetweenCoords(coords["x"], coords["y"],coords["z"], entityCreatePoint["x"], entityCreatePoint["y"],entityCreatePoint["z"])
            if aDist < 2.0 then
                TriggerEvent("alert:noPedCheck", "banktruck")
                local finished = exports["8x-taskbar"]:taskBar(45000,"Unlocking Vehicle",false,false,playerVeh)
                if finished == 100 then
                    remove = true
                    TriggerEvent("sec:AttemptHeist", targetVehicle)
                else
                    TriggerEvent("evidence:bleeding")
                end
                
            else
                TriggerEvent("notification","You need to do this from behind the vehicle.")
            end
        end

    end



    if (itemid == "usbdevice") then
        local finished = exports["8x-taskbar"]:taskBar(15000,"Scanning For Networks",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("hacking:attemptHack")
        end
        
    end

    if (itemid == "weed12oz") then
        TriggerEvent("inv:weedPacking")
        remove = true
    end

    if (itemid == "heavyammo") then
        local finished = exports["reload-skillbar"]:taskBar(4000,math.random(5,15))
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1788949567,50,true)
            remove = true
        end
    end

    if (itemid == "pistolammo") then
        TriggerEvent("actionbar:ammo",1950175060,50,true)
    end

    if (itemid == "rifleammo") then
        local finished = exports["reload-skillbar"]:taskBar(4000,math.random(5,15))
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",218444191,50,true)
            remove = true
        end
    end

    if (itemid == "shotgunammo") then
        local finished = exports["reload-skillbar"]:taskBar(4000,math.random(5,15))
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",-1878508229,50,true)
            remove = true
        end
    end

    if (itemid == "subammo") then
            TriggerEvent("actionbar:ammo",1820140472,50,true)
    end


    if (itemid == "armor") then
        local finished = exports["8x-taskbar"]:taskBar(10000,"Armor Giyiyorsun",true,false,playerVeh)
        if (finished == 100) then
            SetPlayerMaxArmour(PlayerId(), 100 )
            SetPedArmour( player, 100 )
            TriggerEvent("UseBodyArmor")
            remove = true
        end
    end

    if (itemid == "armor1") then
        local finished = exports["8x-taskbar"]:taskBar(5000,"Armor Giyiyorsun",true,false,playerVeh)
        remove = true
        if (finished == 100) then
            SetPlayerMaxArmour(PlayerId(), 100 )
            SetPedArmour( player, 100 )
            TriggerEvent("UseBodyArmor")
        end
    end

    if (itemid == "binoculars") then 
        TriggerEvent("binoculars:Activate")
        
    end

    if (itemid == "camera") then
        TriggerEvent("camera:Activate")
    end

    if (itemid == "mobilephone") then
        TriggerEvent('phoneGui2')
    end

    if (itemid == "greenb") then
        TriggerEvent('psa_bandana:greenbandana')
    end

    if (itemid == "purpleb") then
        TriggerEvent('psa_bandana:ballasbandana')
    end

    if (itemid == "yellowb") then
        TriggerEvent('psa_bandana:vagosbandana')
    end

    if (itemid == "nitrous") then
        local currentVehicle = GetVehiclePedIsIn(player, false)
        
        if not IsToggleModOn(currentVehicle,18) then
            TriggerEvent("notification","You need a Turbo to use NOS!",2)
        else
            local finished = 0
            local cancelNos = false
            Citizen.CreateThread(function()
                while finished ~= 100 and not cancelNos do
                    Citizen.Wait(100)
                    if GetEntitySpeed(GetVehiclePedIsIn(player, false)) > 11 then
                        exports["8x-taskbar"]:closeGuiFail()
                        cancelNos = true
                    end
                end
            end)
            finished = exports["8x-taskbar"]:taskBar(20000,"Nitrous")
            if (finished == 100 and not cancelNos) then
                TriggerEvent("NosStatus")
                TriggerEvent("noshud", 100, false)
                remove = true
            else
                TriggerEvent("notification","You can't drive and hook up nos at the same time.",2)
            end
        end
    end

    if (itemid == "lockpick") then

        local myJob = exports["isPed"]:isPed("myJob")

        if myJob ~= "news" then
            TriggerEvent("inv:lockPick",false,inventoryName,slot)

        else
            TriggerEvent("notification","Nice news reporting, you shit lord idiot.")
        end       
        
    end

    if (itemid == "umbrella") then
        TriggerEvent("animation:PlayAnimation","umbrella")
        
    end

    if (itemid == "repairkit") then
      TriggerEvent('veh:repairing',inventoryName,slot,itemid)
           
    end

    if (itemid =="advrepairkit") then
      TriggerEvent('veh:repairing',inventoryName,slot,itemid)
           
    end
    if (itemid == "securityblue" or itemid == "securityblack" or itemid == "securitygreen" or itemid == "securitygold" or itemid == "securityred")  then
        TriggerEvent("robbery:scanLock",false,itemid)       
    end

    if (itemid == "Gruppe6Card2")  then
        
    end

    if (itemid == "Gruppe6Card22")  then
     
    end    

    if (itemid == "ciggy") then
        local finished = exports["8x-taskbar"]:taskBar(1000,"Lighting Up",false,false,playerVeh)
        if (finished == 100) then
            Wait(300)
            TriggerEvent("animation:PlayAnimation","smoke")
        end
    end

    if (itemid == "cigar") then
        local finished = exports["8x-taskbar"]:taskBar(1000,"Lighting Up",false,false,playerVeh)
        if (finished == 100) then
            Wait(300)
            TriggerEvent("animation:PlayAnimation","cigar")
        end
    end

    if (itemid == "oxygentank") then
        local finished = exports["8x-taskbar"]:taskBar(30000,"Oxygen Tank",true,false,playerVeh)
        if (finished == 100) then        
            TriggerEvent("UseOxygenTank")
            remove = true
        end
    end

    if (itemid == "bandage") then
        local finished = exports["8x-taskbar"]:taskBar(2000,"Bandajı Sarıyorsun")
        if (finished == 100) then 
            local maxHealth = GetEntityMaxHealth(PlayerPedId())
            local health = GetEntityHealth(PlayerPedId())
            local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 20))
            SetEntityHealth(PlayerPedId(), newHealth)
            ClearPedTasks(PlayerPedId())
            remove = true
        end
    end

    if (itemid == "coke50g") then
        CreateCraftOption("coke5g", 80, true)
        
    end

    if (itemid == "bakingsoda") then 
        CreateCraftOption("1gcrack", 80, true)
    end

    if (itemid == "glucose") then 
        CreateCraftOption("1gcocaine", 80, true)
        
    end

    if (itemid == "idcard") then 
        local ItemInfo = GetItemInfo(slot)
        TriggerServerEvent("police:showID",ItemInfo.information)    
    end

    if (itemid == "drivingtest") then 
        local ItemInfo = GetItemInfo(slot)
        if (ItemInfo.information ~= "No information stored") then
            local data = json.deicode(ItemInfo.information)
            TriggerServerEvent("driving:getResults", data.ID)
        end
    end

    if (itemid == "1gcocaine") then
        TriggerEvent("attachItemObjectnoanim","drugpackage01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("anim@amb@nightclub@peds@", "missfbi3_party_snort_coke_b_male3", 49, 5000, "Coke Gaming", "hadcocaine", true,itemid,playerVeh)
    end

    if (itemid == "1gcrack") then 
        TriggerEvent("attachItemObjectnoanim","crackpipe01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 49, 5000, "Smoking Quack", "hadcrack", true,itemid,playerVeh)
    end

    if (itemid == "treat") then
        local model = GetEntityModel(player)
        if model == GetHashKey("a_c_chop") then
            TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 1200, "Treat Num's", "hadtreat", true,itemid,playerVeh)
        end
    end

    if (itemid == "IFAK") then
        loadAnimDict("amb@world_human_clipboard@male@idle_a")
        TaskPlayAnim( PlayerPedId(), "amb@world_human_clipboard@male@idle_a", "idle_c",49,2000,"IFAK Uygulanıyor", 3.0, 1.0, 5000, 49, 0, 0, 0, 0 ) 
        Citizen.Wait(5000)
        local maxHealth = GetEntityMaxHealth(PlayerPedId())
		local health = GetEntityHealth(PlayerPedId())
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 20))
        SetEntityHealth(PlayerPedId(), newHealth)
        TriggerEvent('mythic_hospital:client:UsePainKiller', 1)
        ClearPedTasks(PlayerPedId())
        remove = true
    end


    if (itemid == "oxy") then
        DisableControlAction(1, 24, true)
       	DisableControlAction(1, 25, true)
        loadAnimDict("mp_suicide")
        TaskPlayAnim( PlayerPedId(), "mp_suicide", "pill", 3.0, 1.0, 2500, 49, 0, 0, 0, 0 ) 
        Citizen.Wait(2500)
        TriggerEvent('mythic_hospital:items:firstaid', 1)
        local maxHealth = GetEntityMaxHealth(PlayerPedId())
		local health = GetEntityHealth(PlayerPedId())
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 25))
        SetEntityHealth(PlayerPedId(), newHealth)
        ClearPedTasks(PlayerPedId())
        remove = true
    end

    if (itemid == "sandwich" or itemid == "hamburger") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Yiyorsun","changehunger",true,itemid,playerVeh)
    end

    if (itemid == "cola" or itemid == "water") then
        AttachPropAndPlayAnimation("amb@world_human_drinking@beer@female@idle_a", "idle_e", 49,6000,"İçiyorsun","changethirst",true,itemid,playerVeh)
    end


    if (itemid == "jailfood" or itemid == "bleederburger" or itemid == "heartstopper" or itemid == "torpedo" or itemid == "meatfree" or itemid == "moneyshot" or itemid == "fries") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Yiyorsun","inv:wellfed",true,itemid,playerVeh)

    end

    if (itemid == "methbag") then
        local finished = exports["8x-taskbarskill"]:taskBar(2500,10)
        if (finished == 100) then  
            TriggerEvent("attachItemObjectnoanim","crackpipe01")
            TriggerEvent("Evidence:StateSet",2,1200)
            TriggerEvent("Evidence:StateSet",6,1200)
            TaskItem("switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 49, 1500, "💩 Smoking Ass Meth 💩", "hadcocaine", true, itemid,playerVeh)
        end
    end
    if itemid == "slushy" then

        TriggerEvent("healed:useOxy")
        AttachPropAndPlayAnimation("amb@world_human_drinking@beer@female@idle_a", "idle_e", 49, 6000,"Yiyorsun", "inv:wellfed",true,itemid,playerVeh)
    end

    if (itemid == "shitlockpick") then
        lockpicking = true
        TriggerEvent("animation:lockpickinvtestoutside") 
        local finished = exports["8x-taskbarskill"]:taskBar(2500,math.random(5,20))
        if (finished == 100) then    
            TriggerEvent("police:uncuffMenu")
        end
        lockpicking = false
        remove = true
    end

    if (itemid == "watch") then
        TriggerEvent("carHud:compass")
    end

    if (itemid == "harness") then
        local veh = GetVehiclePedIsIn(player, false)
        local driver = GetPedInVehicleSeat(veh, -1)
        if (PlayerPedId() == driver) then
            TriggerEvent("vehicleMod:useHarnessItem")
            remove = true
        end
    end

    if remove == true then
        TriggerEvent("inventory:removeItem",itemid, 1)
    end

    Wait(500)
    retardCounter = 0
    justUsed = false


end)

function AttachPropAndPlayAnimation(dictionary,animation,typeAnim,timer,message,func,remove,itemid,vehicle)
    if itemid == "hamburger" or itemid == "heartstopper" or itemid == "bleederburger" then
        TriggerEvent("attachItem", "hamburger")
    elseif itemid == "sandwich" then
        TriggerEvent("attachItem", "sandwich")
    elseif itemid == "donut" then
        TriggerEvent("attachItem", "donut")
    elseif itemid == "water" or itemid == "cola" or itemid == "vodka" or itemid == "whiskey" or itemid == "beer" or itemid == "coffee" then
        TriggerEvent("attachItem", itemid)
    elseif itemid == "fishtaco" or itemid == "taco" then
        TriggerEvent("attachItem", "taco")
    elseif itemid == "greencow" then
        TriggerEvent("attachItem", "energydrink")
    elseif itemid == "slushy" then
        TriggerEvent("attachItem", "cup")
    end
    TaskItem(dictionary, animation, typeAnim, timer, message, func, remove, itemid,vehicle)
end

RegisterNetEvent('randPickupAnim')
AddEventHandler('randPickupAnim', function()
    loadAnimDict('pickup_object')
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'putdown_low',5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
end)

RegisterCommand('envac', function()
    TriggerEvent("OpenInv")
end)


local clientInventory = {};
RegisterNetEvent('current-items')
AddEventHandler('current-items', function(inv)
    clientInventory = inv
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait (5000)
     
        TriggerEvent('nui-myinventory')
    end
end)

RegisterNetEvent('SniffRequestCID')
AddEventHandler('SniffRequestCID', function(src)
    local cid = exports["isPed"]:isPed("cid")
    TriggerServerEvent("SniffCID",cid,src)
end)



function GetItemInfo(checkslot)
    
     for i,v in pairs(clientInventory) do
        
         if (tonumber(v.slot) == tonumber(checkslot)) then
             local info = {["information"] = v.information, ["id"] = v.id, ["quality"] = v.quality }
             return info
         end
     end
     return "No information stored";
 end

-- item id, amount allowed, crafting.
function CreateCraftOption(id, add, craft)
    TriggerEvent("CreateCraftOption", id, add, craft)
end

-- Animations
function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

function TaskItem(dictionary,animation,typeAnim,timer,message,func,remove,itemid,playerVeh)
    loadAnimDict( dictionary ) 
    TaskPlayAnim( PlayerPedId(), dictionary, animation, 8.0, 1.0, -1, typeAnim, 0, 0, 0, 0 )
    local timer = tonumber(timer)
    if timer > 0 then
        local finished = exports["8x-taskbar"]:taskBar(timer,message,true,false,playerVeh)
        if finished == 100 or timer == 0 then
            TriggerEvent(func)
            ClearPedTasks(PlayerPedId())
            TriggerEvent("destroyProp")
        end
    else
        TriggerEvent(func)
    end

    if remove then
        TriggerEvent("inventory:removeItem",itemid, 1)
    end
end



function GetCurrentWeapons()
    local returnTable = {}
    for i,v in pairs(clientInventory) do
        if (tonumber(v.item_id)) then
            local t = { ["hash"] = v.item_id, ["id"] = v.id, ["information"] = v.information, ["name"] = v.item_id, ["slot"] = v.slot }
            returnTable[#returnTable+1]=t
        end
    end   
    if returnTable == nil then 
        return {}
    end
    return returnTable
end

function getQuantity(itemid)
    local amount = 0
    for i,v in pairs(clientInventory) do
        if (v.item_id == itemid) then
            amount = amount + v.amount
        end
    end
    return amount
end

function hasEnoughOfItem(itemid,amount,shouldReturnText)

    if shouldReturnText == nil then shouldReturnText = true end
    if itemid == nil or itemid == 0 or amount == nil or amount == 0 then if shouldReturnText then TriggerEvent("notification","I dont seem to have " .. itemid .. " in my pockets.",2) end return false end
    amount = tonumber(amount)
    local slot = 0
    local found = false

    if getQuantity(itemid) >= amount then
        return true
    end
    if (shouldReturnText) then
        TriggerEvent("notification","I dont have enough of that item...",2) 
    end    
    return false
end


function isValidUseCase(itemID,isWeapon)
    local player = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(player, false)
    if playerVeh ~= 0 then
        local model = GetEntityModel(playerVeh)
        if IsThisModelACar(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model) then
            if IsEntityInAir(playerVeh) then
                Wait(1000)
                if IsEntityInAir(playerVeh) then
                    TriggerEvent("notification","You appear to be flying through the air",2) 
                    return false
                end
            end
        end
    end

    if not validWaterItem[itemID] and not isWeapon then
        if IsPedSwimming(player) then
            local targetCoords = GetEntityCoords(player, 0)
            Wait(700)
            local plyCoords = GetEntityCoords(player, 0)
            if #(targetCoords - plyCoords) > 1.3 then
                TriggerEvent("notification","Cannot be moving while swimming to use this.",2) 
                return false
            end
        end

        if IsPedSwimmingUnderWater(player) then
            TriggerEvent("notification","Cannot be underwater to use this.",2) 
            return false
        end
    end

    return true
end



RegisterNetEvent('evidence:addDnaSwab')
AddEventHandler('evidence:addDnaSwab', function(dna)
    TriggerEvent("notification", "DNA Result: " .. dna,1)    
end)

RegisterNetEvent('CheckDNA')
AddEventHandler('CheckDNA', function()
    TriggerServerEvent("Evidence:checkDna")
end)

RegisterNetEvent('evidence:dnaSwab')
AddEventHandler('evidence:dnaSwab', function()
    t, distance = GetClosestPlayer()
    if(distance ~= -1 and distance < 5) then
        TriggerServerEvent("police:dnaAsk", GetPlayerServerId(t))
    end
end)

RegisterNetEvent('evidence:swabNotify')
AddEventHandler('evidence:swabNotify', function()
    TriggerEvent("notification", "DNA swab taken.",1)
end)


function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end



function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)   
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        
        offset = offset - 1

        if vehicle ~= 0 then break end
    end
    
    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
    
    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)

end

local burgies = 0
RegisterNetEvent('inv:wellfed')
AddEventHandler('inv:wellfed', function()

    burgies = 0
end)


RegisterNetEvent('animation:lockpickinvtestoutside')
AddEventHandler('animation:lockpickinvtestoutside', function()
    local lPed = PlayerPedId()
    RequestAnimDict("veh@break_in@0h@p_m_one@")
    while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do
        Citizen.Wait(0)
    end
    
    while lockpicking do        
        TaskPlayAnim(lPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 16, 0.0, 0, 0, 0)
        Citizen.Wait(2500)
    end
    ClearPedTasks(lPed)
end)

RegisterNetEvent('animation:lockpickinvtest')
AddEventHandler('animation:lockpickinvtest', function(disable)
    local lPed = PlayerPedId()
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end
    if disable ~= nil then
        if not disable then
            lockpicking = false
            return
        else
            lockpicking = true
        end
    end
    while lockpicking do

        if not IsEntityPlayingAnim(lPed, "mini@repair", "fixing_a_player", 3) then
            ClearPedSecondaryTask(lPed)
            TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    ClearPedTasks(lPed)
end)



RegisterNetEvent('inv:lockPick')
AddEventHandler('inv:lockPick', function(isForced,inventoryName,slot)
    TriggerEvent("robbery:scanLock",true)
    if lockpicking then return end

    lockpicking = true
    playerped = PlayerPedId()
    targetVehicle = GetVehiclePedIsUsing(playerped)
    local itemid = 21

    if targetVehicle == 0 then
        coordA = GetEntityCoords(playerped, 1)
        coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
        targetVehicle = getVehicleInDirection(coordA, coordB)
        local driverPed = GetPedInVehicleSeat(targetVehicle, -1)
        if targetVehicle == 0 then
            lockpicking = false
            TriggerEvent("robbery:lockpickhouse",isForced)
            return
        end

        if driverPed ~= 0 then
            lockpicking = false
            return
        end
            local d1,d2 = GetModelDimensions(GetEntityModel(targetVehicle))
            local leftfront = GetOffsetFromEntityInWorldCoords(targetVehicle, d1["x"]-0.25,0.25,0.0)

            local count = 5000
            local dist = #(vector3(leftfront["x"],leftfront["y"],leftfront["z"]) - GetEntityCoords(PlayerPedId()))
            while dist > 2.0 and count > 0 do
                dist = #(vector3(leftfront["x"],leftfront["y"],leftfront["z"]) - GetEntityCoords(PlayerPedId()))
                Citizen.Wait(1)
                count = count - 1
                DrawText3Ds(leftfront["x"],leftfront["y"],leftfront["z"],"Move here to lockpick.")
            end

            if dist > 2.0 then
                lockpicking = false
                return
            end


            TaskTurnPedToFaceEntity(PlayerPedId(), targetVehicle, 1.0)
            Citizen.Wait(1000)
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)
            local triggerAlarm = GetVehicleDoorLockStatus(targetVehicle) > 1
            if triggerAlarm then
                SetVehicleAlarm(targetVehicle, true)
                StartVehicleAlarm(targetVehicle)
            end


            TriggerEvent("civilian:alertPolice",20.0,"lockpick",targetVehicle)
           
            TriggerEvent("animation:lockpickinvtestoutside")
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)



 
            local finished = exports["8x-taskbarskill"]:taskBar(25000,3)

            if finished ~= 100 then
                 lockpicking = false
                return
            end

            local finished = exports["8x-taskbarskill"]:taskBar(2200,10)

            if finished ~= 100 then
                 lockpicking = false
                return
            end


            if finished == 100 then
                if triggerAlarm then
                    SetVehicleAlarm(targetVehicle, false)
                end
                local chance = math.random(50)
                if #(GetEntityCoords(targetVehicle) - GetEntityCoords(PlayerPedId())) < 10.0 and targetVehicle ~= 0 and GetEntitySpeed(targetVehicle) < 5.0 then

                    SetVehicleDoorsLocked(targetVehicle, 1)
                    TriggerEvent("notification", "Vehicle Unlocked.",1)
                    TriggerEvent('InteractSound_CL:PlayOnOne', 'unlock', 0.1)

                end
            end
        lockpicking = false
    else
        if targetVehicle ~= 0 and not isForced then

            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)
            local triggerAlarm = GetVehicleDoorLockStatus(targetVehicle) > 1
            if triggerAlarm then
                SetVehicleAlarm(targetVehicle, true)
                StartVehicleAlarm(targetVehicle)
            end

            SetVehicleHasBeenOwnedByPlayer(targetVehicle,true)
            TriggerEvent("civilian:alertPolice",20.0,"lockpick",targetVehicle)
           
            TriggerEvent("animation:lockpickinvtest")
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)

           
            local carTimer = GetVehicleHandlingFloat(targetVehicle, 'CHandlingData', 'nMonetaryValue')
            if carTimer == nil then
                carTimer = math.random(25000,180000)
            end
            if carTimer < 25000 then
                carTimer = 25000
            end

            if carTimer > 180000 then
                carTimer = 180000
            end
            
            carTimer = math.ceil(carTimer / 3)


            local myJob = exports["isPed"]:isPed("myJob")
            if myjob == "towtruck" then
                carTimer = 4000
            end

            TriggerEvent("civilian:alertPolice",20.0,"lockpick",targetVehicle)

            local finished = exports["8x-taskbarskill"]:taskBar(math.random(5000,25000),math.random(10,20))
            if finished ~= 100 then
                 lockpicking = false
                return
            end

            local finished = exports["8x-taskbarskill"]:taskBar(math.random(5000,25000),math.random(10,20))
            if finished ~= 100 then
                 lockpicking = false
                return
            end


            TriggerEvent("civilian:alertPolice",20.0,"lockpick",targetVehicle)
            local finished = exports["8x-taskbarskill"]:taskBar(1500,math.random(5,15))
            if finished ~= 100 then
                TriggerEvent("notification", "The lockpick bent out of shape.",2)
                TriggerEvent("inventory:removeItem","lockpick", 1)                
                 lockpicking = false
                return
            end     


            Citizen.Wait(500)
            if finished == 100 then
                if triggerAlarm then
                    SetVehicleAlarm(targetVehicle, false)
                end
                local chance = math.random(50)
                if #(GetEntityCoords(targetVehicle) - GetEntityCoords(PlayerPedId())) < 10.0 and targetVehicle ~= 0 and GetEntitySpeed(targetVehicle) < 5.0 then
                    local plate = GetVehicleNumberPlateText(targetVehicle)
                    SetVehicleDoorsLocked(targetVehicle, 1)
                    TriggerEvent("keys:addNew",targetVehicle,plate)
                    TriggerEvent("keys:startvehicle")
                    TriggerEvent("civilian:alertPolice",20.0,"lockpick",targetVehicle)
                    TriggerEvent("notification", "Ignition Working.",1)
                    SetEntityAsMissionEntity(targetVehicle,false,true)
                    SetVehicleHasBeenOwnedByPlayer(targetVehicle,true)
                end
                lockpicking = false
            end
        end
    end
    lockpicking = false
end)

local reapiring = false
RegisterNetEvent('veh:repairing')
AddEventHandler('veh:repairing', function(inventoryName,slot,itemid)
    local playerped = PlayerPedId()
    local coordA = GetEntityCoords(playerped, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
    local targetVehicle = getVehicleInDirection(coordA, coordB)

    local advanced = false
    if itemid == "advrepairkit" then
        advanced = true
    end

    if targetVehicle ~= 0 then

        local d1,d2 = GetModelDimensions(GetEntityModel(targetVehicle))
        local moveto = GetOffsetFromEntityInWorldCoords(targetVehicle, 0.0,d2["y"]+0.5,0.2)
        local dist = #(vector3(moveto["x"],moveto["y"],moveto["z"]) - GetEntityCoords(PlayerPedId()))
        local count = 1000
        local fueltankhealth = GetVehiclePetrolTankHealth(targetVehicle)

        while dist > 1.5 and count > 0 do
            dist = #(vector3(moveto["x"],moveto["y"],moveto["z"]) - GetEntityCoords(PlayerPedId()))
            Citizen.Wait(1)
            count = count - 1
            DrawText3Ds(moveto["x"],moveto["y"],moveto["z"],"Move here to repair.")
        end

        if reapiring then return end
        reapiring = true
        
        local timeout = 20

        NetworkRequestControlOfEntity(targetVehicle)

        while not NetworkHasControlOfEntity(targetVehicle) and timeout > 0 do 
            NetworkRequestControlOfEntity(targetVehicle)
            Citizen.Wait(100)
            timeout = timeout -1
        end


        if dist < 1.5 then
            TriggerEvent("animation:repair",targetVehicle)
            fixingvehicle = true

            local repairlength = 1000

            if advanced then
                local timeAdded = 0
                for i=0,5 do
                    if IsVehicleTyreBurst(targetVehicle, i, false) then
                        if IsVehicleTyreBurst(targetVehicle, i, true) then
                            timeAdded = timeAdded + 1200
                        else
                           timeAdded = timeAdded + 800
                        end
                    end
                end
                local fuelDamage = 48000 - (math.ceil(fueltankhealth)*12)
                repairlength = ((3500 - (GetVehicleEngineHealth(targetVehicle) * 3) - (GetVehicleBodyHealth(targetVehicle)) / 2) * 5) + 2000
                repairlength = repairlength + timeAdded + fuelDamage
            else
                local timeAdded = 0
                for i=0,5 do
                    if IsVehicleTyreBurst(targetVehicle, i, false) then
                        if IsVehicleTyreBurst(targetVehicle, i, true) then
                            timeAdded = timeAdded + 1600
                        else
                           timeAdded = timeAdded + 1200
                        end
                    end
                end
                local fuelDamage = 48000 - (math.ceil(fueltankhealth)*12)
                repairlength = ((3500 - (GetVehicleEngineHealth(targetVehicle) * 3) - (GetVehicleBodyHealth(targetVehicle)) / 2) * 3) + 2000
                repairlength = repairlength + timeAdded + fuelDamage
            end



            local finished = exports["8x-taskbarskill"]:taskBar(15000,math.random(10,20))
            if finished ~= 100 then
                fixingvehicle = false
                reapiring = false
                ClearPedTasks(playerped)
                return
            end

            if finished == 100 then
                
                local myJob = exports["isPed"]:isPed("myJob")
                if myJob == "towtruck" then

                    SetVehicleEngineHealth(targetVehicle, 1000.0)
                    SetVehicleBodyHealth(targetVehicle, 1000.0)
                    SetVehiclePetrolTankHealth(targetVehicle, 4000.0)

                    if math.random(100) > 95 then
                        TriggerEvent("inventory:removeItem","repairtoolkit",1)
                    end

                else

                    TriggerEvent('veh.randomDegredation',30,targetVehicle,3)

                    if advanced then
                        TriggerEvent("inventory:removeItem","advrepairkit", 1)
                        TriggerEvent('veh.randomDegredation',30,targetVehicle,3)
                        if GetVehicleEngineHealth(targetVehicle) < 900.0 then
                            SetVehicleEngineHealth(targetVehicle, 900.0)
                        end
                        if GetVehicleBodyHealth(targetVehicle) < 945.0 then
                            SetVehicleBodyHealth(targetVehicle, 945.0)
                        end

                        if fueltankhealth < 3800.0 then
                            SetVehiclePetrolTankHealth(targetVehicle, 3800.0)
                        end

                    else

                        local timer = math.ceil(GetVehicleEngineHealth(targetVehicle) * 5)
                        if timer < 2000 then
                            timer = 2000
                        end
                        local finished = exports["8x-taskbarskill"]:taskBar(timer,math.random(5,15))
                        if finished ~= 100 then
                            fixingvehicle = false
                            reapiring = false
                            ClearPedTasks(playerped)
                            return
                        end

                        if math.random(100) > 95 then
                            TriggerEvent("inventory:removeItem","repairtoolkit",1)
                        end

                        if GetVehicleEngineHealth(targetVehicle) < 200.0 then
                            SetVehicleEngineHealth(targetVehicle, 200.0)
                        end
                        if GetVehicleBodyHealth(targetVehicle) < 945.0 then
                            SetVehicleBodyHealth(targetVehicle, 945.0)
                        end

                        if fueltankhealth < 2900.0 then
                            SetVehiclePetrolTankHealth(targetVehicle, 2900.0)
                        end                        

                        if GetEntityModel(targetVehicle) == `BLAZER` then
                            SetVehicleEngineHealth(targetVehicle, 600.0)
                            SetVehicleBodyHealth(targetVehicle, 800.0)
                        end
                    end                    
                end

                for i = 0, 5 do
                    SetVehicleTyreFixed(targetVehicle, i) 
                end
            end
            ClearPedTasks(playerped)
        end
        fixingvehicle = false
    end
    reapiring = false
end)

-- Animations
RegisterNetEvent('animation:load')
AddEventHandler('animation:load', function(dict)
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end)

RegisterNetEvent('animation:repair')
AddEventHandler('animation:repair', function(veh)
    SetVehicleDoorOpen(veh, 4, 0, 0)
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), veh, 1.0)
    Citizen.Wait(1000)

    while fixingvehicle do
        local anim3 = IsEntityPlayingAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 3)
        if not anim3 then
            TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    SetVehicleDoorShut(veh, 4, 1, 1)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        BlockWeaponWheelThisFrame()
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        HideHudComponentThisFrame(17)
        DisableControlAction(0, 37, true) 
    end
end)



RegisterNetEvent('police:targetCheckInventory')
AddEventHandler('police:targetCheckInventory', function(bool, isFrisk)
        local _bool = bool

        if _bool == nil or _bool == false then 
            _bool = false 
        else 
            _bool = true
        end
		if isFrisk == nil then isFrisk = false end
		t, distance, closestPed = GetClosestPlayer()
		if(distance ~= -1 and distance < 5) then
			TriggerServerEvent("server-inventory-openPlayer", GetPlayerServerId(t), isFrisk, _bool)
		else
			TriggerEvent("notification", "No player near you!",2)
		end
end)

RegisterCommand("search", function(source, args)
    local player = ESX.GetPlayerData()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 2.0 and ESX.PlayerData.job.name == 'police' then
        local searchPlayerPed = GetPlayerPed(closestPlayer)
        TriggerServerEvent("people-search", GetPlayerServerId(closestPlayer)) --COPY THIS
    else
        TriggerEvent("notification", "Job Required: Police")
        print("Your job is: " ..ESX.PlayerData.job.name)
    end
end)



RegisterCommand("takecash", function(source, args)
    local player = ESX.GetPlayerData()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 2.0 and ESX.PlayerData.job.name == 'police' then
        local searchPlayerPed = GetPlayerPed(closestPlayer)
        TriggerServerEvent("police:SeizeCash",  GetPlayerServerId(closestPlayer))
    else
        TriggerEvent("notification", "Job Required: Police")
        print("Your job is: " ..ESX.PlayerData.job.name)
    end
end)



RegisterCommand("search", function(source, args)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 1.0 then
        local playerPed = PlayerPedId()
        local searchPlayerPed = GetPlayerPed(closestPlayer)

        if IsEntityPlayingAnim(searchPlayerPed, 'random@mugging3', 'handsup_standing_base', 3) then
            RequestAnimDict("random@shop_robbery")

            while not HasAnimDictLoaded("random@shop_robbery") do

                Citizen.Wait(0)

            end      

            if not IsEntityPlayingAnim(searchPlayerPed, 'random@mugging3', 'handsup_standing_base', 3) then
                TriggerEvent("closeInventoryGui")
            end

            TaskPlayAnim(PlayerPedId(), "random@shop_robbery" , "robbery_action_b", 8.0, -8, -1, 16, 0, 0, 0, 0)
            local finished = exports["8x-taskbar"]:taskBar(3500, "Robbing")
            TriggerServerEvent("people-search", GetPlayerServerId(closestPlayer)) --COPY THIS
            TriggerServerEvent("Stealtheybread", GetPlayerServerId(closestPlayer)) --COPY THIS
        else
            local test = false
            TriggerEvent('notification', 'They need to do /e handsup2 or be dead')
        end
    end
end)

RegisterNetEvent('searching-person')
AddEventHandler('searching-person', function(target)
    TriggerEvent("server-inventory-open", "1", target)
end)

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local distance = GetDistanceBetweenCoords(pos.x,pos.y,pos.z,475.35592529297,-1005.17063232422,26.270820236206,false)
        if distance <= 1.2 then
            if ESX.PlayerData.job.name == 'police' then
                --DrawText3D(475.35592529297,-1005.17063232422,26.270820236206, "[E] - Kanıt Deposunu Aç")
                if IsControlJustReleased(0, 86) and ESX.PlayerData.job.name == 'police' then
                    Citizen.Wait(1)
                    TriggerEvent("server-inventory-open", "1", "Kanıt Deposu")
                end
            end
        end
        Citizen.Wait(5)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local distance = GetDistanceBetweenCoords(pos.x,pos.y,pos.z,482.56312988281,-995.96303466797,30.699546585083,false)
        if distance <= 1.2 then
            if ESX.PlayerData.job.name == 'police' then
                --DrawText3D(482.56312988281,-994.96303466797,30.699546585083, "[E] - Polis Marketi")
                if IsControlJustReleased(0, 86) and ESX.PlayerData.job.name == 'police' then
                    Citizen.Wait(1)
                    TriggerEvent("server-inventory-open", "10", "Shop");	
                end
            end
        end
        Citizen.Wait(5)
    end
end)

RegisterNUICallback("PlayDropSound", function(data, cb)
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
end)

RegisterNUICallback("PlayDropFail", function(data, cb)
    PlaySound(-1, "Pin_Good", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 0, 0, 1)
end)

--- BLACK MARKET --

local firstspawn = false

Citizen.CreateThread(function()
    local hash = GetHashKey("mp_m_g_vagfun_01")

    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Citizen.Wait(100)
    end

    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end

    if firstspawn == false then
        local crnpc3 = CreatePed(6, hash, 417.8, -992.996, 28.32, 100.0, false, false)
        SetEntityInvincible(crnpc3, true)
        FreezeEntityPosition(crnpc3, true)
        SetBlockingOfNonTemporaryEvents(crnpc3, true)
        SetPedDiesWhenInjured(crnpc3, false)
        SetPedCanRagdollFromPlayerImpact(crnpc3, false)
        SetPedCanRagdoll(crnpc3, false)
        SetEntityAsMissionEntity(crnpc3, true, true)
        SetEntityDynamic(crnpc3, true)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local distance = GetDistanceBetweenCoords(pos.x,pos.y,pos.z,32.12614, -1351.40, 29.338,false)
    local sleepThread = 500
    if distance <= 2.0 then
        sleepThread = 5 
        if distance <= 2.2 then
            DrawText3D(32.12614, -1351.40, 29.338, "~b~[E]~w~ - cCc script siken")
            if IsControlJustReleased(0, 86)  then
                TriggerEvent("InteractSound_CL:PlayOnOne","knockdoor",0.6)
                local finished = exports["8x-taskbar"]:taskBar(1000, "roninininsiki")
                if (finished == 100) then
                    TriggerEvent("server-inventory-open", "200", "Craft");
                    TriggerEvent("notification", "İhtiyacın olan şeyleri al ve uza.")
                end
            end

        end
    end
    if distance >= 7.0 then
      Citizen.Wait(5000)
    else 
      Citizen.Wait(5)
    end    
  end
end)

--[[Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local distance = GetDistanceBetweenCoords(pos.x,pos.y,pos.z,42.26007, -1384.97, 29.291,false)
    local sleepThread = 500
    if distance <= 2.0 then
        sleepThread = 5 
        if distance <= 2.2 then
            DrawText3D(42.26007, -1384.97, 29.291, "~b~[E]~w~ - stash")
            if IsControlJustReleased(0, 86)  then
                TriggerEvent("InteractSound_CL:PlayOnOne","knockdoor",0.6)
                local finished = exports["8x-taskbar"]:taskBar(1000, "Malzemeleri Hazırlıyorsun")
                if (finished == 100) then
                    TriggerEvent("server-inventory-open", "1", "Motel Stash")
                    TriggerEvent("notification", "İhtiyacın olan şeyleri al ve uza.")
                end
            end

        end
    end
    if distance >= 7.0 then
      Citizen.Wait(5000)
    else 
      Citizen.Wait(5)
    end    
  end
end)]]


RegisterCommand('proptest', function()
    local Player = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(Player, true))
    local heading = GetEntityHeading(Player)

    objectname = "w_ar_advancedrifle"
    RequestModel(objectname)

    while not HasModelLoaded(objectname) do
	    Citizen.Wait(1)
    end

    local obj = CreateObject(GetHashKey(objectname), x, y, z-1.90, true, true, true)
    PlaceObjectOnGroundProperly(obj)
    SetEntityHeading(obj, heading)
    FreezeEntityPosition(obj, true)

    Citizen.Wait(2000)
    
    DeleteObject(obj)
    print("worked ? ")
end)

RegisterCommand('deleteprop', function()
    DeleteEntity(mainobje)
end)

function SpawnObject(objectname)
    local Player = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(Player, true))
    local heading = GetEntityHeading(Player)

    RequestModel(objectname)

    while not HasModelLoaded(objectname) do
	    Citizen.Wait(1)
    end

    local obj = CreateObject(GetHashKey(objectname), x, y, z-1.90, true, true, true)
    PlaceObjectOnGroundProperly(obj)
    SetEntityHeading(obj, heading)
    FreezeEntityPosition(obj, true)
end
let DroppedInventories = [];
let InUseInventories = [];
let DataEntries = 0;
let hasBrought = [];
let CheckedDeginv = [];
const DROPPED_ITEM_KEEP_ALIVE = 1000 * 60 * 15; 

function clean() {
    for (let Row in DroppedInventories) {
        if (new Date(DroppedInventories[Row].lastUpdated + DROPPED_ITEM_KEEP_ALIVE).getTime() < Date.now() && DroppedInventories[Row].used && !InUseInventories[DroppedInventories[Row].name]) {
               emitNet("Inventory-Dropped-Remove", -1, [DroppedInventories[Row].name])
               delete DroppedInventories[Row];
        }
    }
}

setInterval(clean, 20000)


function db(string) {
    exports.ghmattimysql.execute(string,{}, function(result) {
    });
}

onNet("onResourceStart", async (resource) => {
    if (resource == GetCurrentResourceName()){
        emit("server-request-update",source);
        emit("server-update-item",source)
      
    }
});
    
RegisterServerEvent('stores:pay:cycle')
onNet('store:pay:cycle', async (storeList) => {

   storeList = JSON.parse(storeList)
   for (let key in storeList) {

       if (storeList[key].house_model == 4) {
           let trap = storeList[key]["trap"]
           let id = storeList[key]["dbid"]
           let name = storeList[key]["stash"]
           let storeName = storeList[key]["name"]
           let reputation = storeList [key]["reputation"]
           let luckyslot = 1
           let luckroll = mathrandom(1,100)
           let amount = 1
           let inventoryType = 'house_information'

           if (trap) {
               inventoryType = 'trap_houses'
           }

           let itemid = 0 
           let rolled = reputation + luckroll
           if (rolled > 96) {

           if (rolled > 120) {
               amount = 2
           }
           if (rolled > 150) {
               amount = 3
           }
           if (rolled > 180) {
               amount = 4
           }
           if (rolled > 149) {
               amount = 7
           }

           if (amount > 0) {
               let slot = mathrandom(1,2)
               let string = `SELECT item_id FROM ronin_inventory WHERE name = '${name}' and slot = '${slot}'`;
               exports.ghmattimysql.execute(string,{}, function(inventory) {
                   if (inventory.length > 0) {
                       emitNet("ai:storewalkout",-1,key)
                       if (amount > inventory.length) {
                           amount = inventory.length
                       }

                       let string = `DELETE FROM ronin_inventory WHERE name='${name}' and slot = '${slot}' LIMIT ${amount}`;

                       exports.ghmattimysql.execute(string,{}, function() {});

                       let itemid = inventory[0].item_id
                       let sellValue = itemList[itemid].price * amount

                       if (reputation < 10) {
                           sellValue = sellValue * 0.5
                       } else if (reputation < 20) {
                        sellValue = sellValue * 0.55
                       } else if (reputation < 30) {
                        sellValue = sellValue * 0.6
                       } else if (reputation < 50) {
                        sellValue = sellValue * 0.65
                       } else if (reputation < 70) {
                        sellValue = sellValue * 0.75
                       } else if (reputation < 80) {
                        sellValue = sellValue * 0.8
                       } else if (reputation < 90) {
                        sellValue = sellValue * 0.9

                       }

                       sellValue = Math.ceil(sellValue)

                       payStore(name,sellValue,itemid)
                       if (rolled == 100 && itemList[itemid].illegal) {
                           reputation = reputation + 1
                           if (reputation < 100) {
                               let string = `UPDATE ${inventoryType} SET reputation='${reputation}' WHERE id='${id}'`
                               exports.ghmattimysql.execute(string,{}, function() {});
                           }
                       }
                   } else {
                       if (reputation > 0 && mathrandom(1,100) > 98) {
                           reputation = reputation - 1
                            let string = `UPDATE ${inventoryType} SET reputation='${reputation}' WHERE id='${id}'`
                           exports.ghmattimysql.execute(string,{},function() {});
                       }
                   }
//
               });
           }
       }
   }
}
});


RegisterServerEvent("server-remove-item")
onNet("server-remove-item", async (player,itemidsent,amount,openedInv) => {
    functionRemoveAny(player, itemidsent, amount, openedInv)
});

RegisterServerEvent("server-update-item")
onNet("server-update-item", async (player, itemidsent,slot,data) => {
    let src = source
    let playerinvname = player
    let string = `UPDATE ronin_inventory SET information='${data}' WHERE item_id='${itemidsent}' and name='${playerinvname}' and slot='${slot}'`

    exports.ghmattimysql.execute(string,{}, function() {
        emit("server-request-update-src",player,src)

    });
});

function functionRemoveAny(player, itemidsent, amount, openedInv) {
    let src = source
    let playerinvname = player
    let string = `DELETE FROM ronin_inventory WHERE name='${playerinvname}' and item_id='${itemidsent}' LIMIT ${amount}`

    exports.ghmattimysql.execute(string,{},function() {
        emit("server-request-update-src",player,src)
        emit('sendingItemstoClient', player,src)
    });
    
}

RegisterServerEvent("request-dropped-items")
onNet("request-dropped-items", async (player) => {
    let src = source;
    emitNet("requested-dropped-items", src, JSON.stringify(Object.assign({},DroppedInventories)));
});

RegisterServerEvent("server-request-update")
onNet("server-request-update", async (player) => {
    let src = source
    let playerinvname = player
    let string = `SELECT count(item_id) as amount, id, item_id, name, information, slot, dropped, quality FROM ronin_inventory WHERE name ='${player}' group by item_id`;// slot
    exports.ghmattimysql.execute(string, {}, function(inventory) {
    emitNet("inventory-update-player", src, [inventory,0,playerinvname]);

    });
});

RegisterServerEvent("server-request:update-src")
onNet("server-request-update-src", async (player,src) => {
    let playerinvname = player // or < or *
    let string = `SELECT count(item_id) as amount, id, item_id, name, information, slot, dropped, quality FROM ronin_inventory WHERE name = 'ply=${player}' group by item_id`; // slot
    exports.ghmattimysql.execute(string, {}, function(inventory) {

    emitNet("inventory-update-player", [inventory,0,playerinvname]);
    });
});

function makeid(length) {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghikjlmnopqrstuvwxyz'; //abcdef
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}

function GenerateInformation(player,itemid, itemdata) {
    let data = Object.assign({}, itemdata);
    let returnInfo = "{}"

    return new Promise((resolve, reject) => {
    if (itemid == "") return resolve(returninfo);
    let timeout = 0;
    if (itemid == "motelkeys") {
        returnInfo = JSON.stringify({ Motel: itemdata.motelId, Oda: itemdata.roomId});
        timeout = 1;
        clearTimeout(timeout)
        return resolve(returnInfo);
    }
    if (itemid == "stkeys") {
        returnInfo = JSON.stringify({ StashHouse: itemdata.evNo});
        timeout = 1;
        clearTimeout(timeout)
        return resolve(returnInfo)
    }
    if (itemid == "2024373456") {
        var identifier = player.toString()
        if(itemdata && itemdata.fakeWeaponData) {
            identifier = Math.floor((Math.random() * 99999) + 1)
            identifier = identifier.toString()
        }

        let serialnumber = Math.floor((Math.random() * 9999) + 1)
        let cartridgeCreated = serialnumber + "-" + makeid(4) + "-" + Math.floor((Math.random() * 9999) + 1);
        returnInfo = JSON.stringify({ LicanceNumber: cartridgeCreated, Serieal: serialnumber})
        timeout = 1;
        clearTimeout(timeout)
        return resolve(returnInfo);
    }
    if (!isNaN(itemid)) {
        var identifier = player.toString()
        if(itemdata && itemdata.fakeWeaponData) {
            identifier = Math.floor((Math.random() * 99999) + 1)
            identifier = identifier.toString()
        }

        let serialnumber = Math.floor((Math.random() * 9999) + 1)
        let cartridgeCreated = serialnumber + "-" + makeid(4) + "-" + Math.floor((Math.random() * 9999) + 1);
        returnInfo = JSON.stringify({ LicanceNumber: cartridgeCreated, Serieal: serialnumber})
        timeout = 1;
        clearTimeout(timeout)
        return resolve(returnInfo);
    } else if (Object.prototype.toString.call(itemid) ===  '[object String]') {
        switch(itemid.toLowerCase()) {
          case "idcard":
          if(itemdata == itemdata.fake){
              returnInfo = JSON.stringify({
                //   KimlikNumarası: itemdata, charID,
                  İsim: itemdata.first.replace(/[^\w\s]/gi, ''),
                  Soyisim: itemdata.last.replace(/[^\w\s]/gi, ''),
                  Cinsiyet: itemdata.sex,
                  DoğumTarihi: itemdata.dob })
                  timeout = 1
                  clearTimeout(timeout)
                  return resolve(returnInfo);
              } else {
                  let string = `SELECT firstname ,lastname,sex,dateofbirth FROM users WHERE identifier = '${player}'`;
                  exports.ghmattimysql.execute(string,{}, function(result) {
                      let sex = result[0].sex
                      if (sex == "m") {
                          sex = "Male"
                      } else if (sex == "f") {
                          sex = "Female"
                      }
                      returnInfo = JSON.stringify({
                        //   KimlikNumarası: player.toString(),
                          İsim: result[0].firstname.replace(/[^\w\s]/gi, ''),
                          Soyisim: result[0].lastname.replace(/[^\w\s]/gi, ''),
                          Cinsiyet: sex,
                          DoğumTarihi: result[0].dateofbirth })
                          timeout = 1
                          clearTimeout(timeout)
                          return resolve(returnInfo);
                      });
                    }
                    break;
                    case "driverlicense":
                        if(itemdata == itemdata.fake){
                            returnInfo = JSON.stringify({
                              //   KimlikNumarası: itemdata, charID,
                                İsim: itemdata.first.replace(/[^\w\s]/gi, ''),
                                Soyisim: itemdata.last.replace(/[^\w\s]/gi, ''),
                                Cinsiyet: itemdata.sex,
                                DoğumTarihi: itemdata.dob })
                                timeout = 1
                                clearTimeout(timeout)
                                return resolve(returnInfo);
                            } else {
                                let string = `SELECT firstname ,lastname,sex,dateofbirth FROM users WHERE identifier = '${player}'`;
                                exports.ghmattimysql.execute(string,{}, function(result) {
                                    let sex = result[0].sex
                                    if (sex == "m") {
                                        sex = "Male"
                                    } else if (sex == "f") {
                                        sex = "Female"
                                    }
                                    returnInfo = JSON.stringify({
                                      //   KimlikNumarası: player.toString(),
                                        İsim: result[0].firstname.replace(/[^\w\s]/gi, ''),
                                        Soyisim: result[0].lastname.replace(/[^\w\s]/gi, ''),
                                        Cinsiyet: sex,
                                        DoğumTarihi: result[0].dateofbirth })
                                        timeout = 1
                                        clearTimeout(timeout)
                                        return resolve(returnInfo);
                                    });
                                  }
                                  break;
                    case "casing":
                        returnInfo = JSON.stringify({ Identifier: itemdata.identifier, type: itemdata.eType, other: itemdata.other})
                        timeout = 1
                        clearTimeout(timeout)
                        return resolve(returnInfo);
                    case "evidence":
                            if(itemdata == itemdata.fake){
                                returnInfo = JSON.stringify({
                                  //   KimlikNumarası: itemdata, charID,
                                    İsim: itemdata.first.replace(/[^\w\s]/gi, ''),
                                    Soyisim: itemdata.last.replace(/[^\w\s]/gi, ''),
                                    Cinsiyet: itemdata.sex,
                                    DoğumTarihi: itemdata.dob })
                                    timeout = 1
                                    clearTimeout(timeout)
                                    return resolve(returnInfo);
                                } else {
                                    let string = `SELECT firstname ,lastname,sex,dateofbirth FROM users WHERE identifier = '${player}'`;
                                    exports.ghmattimysql.execute(string,{}, function(result) {
                                        let sex = result[0].sex
                                        if (sex == "m") {
                                            sex = "Male"
                                        } else if (sex == "f") {
                                            sex = "Female"
                                        }
                                        returnInfo = JSON.stringify({
                                          //   KimlikNumarası: player.toString(),
                                            İsim: result[0].firstname.replace(/[^\w\s]/gi, ''),
                                            Soyisim: result[0].lastname.replace(/[^\w\s]/gi, ''),
                                            Cinsiyet: sex,
                                            DoğumTarihi: result[0].dateofbirth })
                                            timeout = 1
                                            clearTimeout(timeout)
                                            return resolve(returnInfo);
                                        });
                                      }
                    break;
                    case "drivingtest":
                         if (data.id) {
                            let string = `SELECT * FROM driving_tests WHERE id = '${data.id}'`;
                            exports.ghmattimysql.execute(string, {}, function(result) {
                                if (result[0]) {
                                    let ts = new Date(parseInt(result[0].timestamp) * 1000)
                                    let testDate = ts.getFullYear() + "-" + ("0"+(ts.getMonth()+1)).slice(-2) + "-" + ("0" + ts.getDate()).slice(-2)
                                    returninfo = JSON.stringify({ ID: result[0].id, CID: result[0].cid, Instructor: result[0].instructor, Date: testdata })
                                    timeout = 1;
                                    clearTimeout(timeout)
                                }
                                return resolve(returninfo);
                            });
                        } else {
                            timeout = 1;
                            clearTimeout(timeout)
                            return resolve(returnInfo);
                        }
                        break;
                    default:
                            timeout = 1
                            clearTimeout(timeout)
                            return resolve(returnInfo);
                        }
                    } else {
                        return resolve(returnInfo);
                    }

                    setTimeout(() => {
                        if (timeout == 0) {
                            return resolve(returnInfo);
                        }
                     },500)
            });
    }

RegisterServerEvent("server-inventory-give")
onNet("server-inventory-give", async (player, itemid, slot, amount, generateInformation, itemdata, openedInv) => {
    
    let src = source
    let playerinvname =  player
    let information = "{}"
    let creationDate = Date.now()

      if (itemid == "idcard") {
          information = await GenerateInformation(player,itemid,itemdata)
      }
      if (generateInformation) {
          information = await GenerateInformation(player,itemid,itemdata)
      }
      let slots = 0;
      let values = `('${playerinvname}','${itemid}','${information}','${slot}','${creationDate}')`
         if (amount > 1) {
             for (let i = 2; i <= amount; i++) {
                 values = values + `,('${playerinvname}','${itemid}','${information}','${slot}','${creationDate}')`
           
             }
         }
                 
                let query = `INSERT INTO ronin_inventory (name,item_id,information,slot,creationDate) VALUES ${values};`
                 exports.ghmattimysql.execute(query,{},function() {
                 emit("server-request-update-src",player,src)
                 emit('sendingItemstoClient', player,src)
                });
           
                sendClientItemList(src)
         
});

RegisterServerEvent("sendingItemstoClient")
onNet("sendingItemstoClient", async (player, sauce) => {
    let src = source
    if (!src) {
        src = sauce 
    }
    sendClientItemList(src)
    let string = `SELECT count(item_id) as amount, id, name, item_id, information, slot, dropped, quality, creationDate FROM ronin_inventory where name= '${player}' group by slot`;
    exports.ghmattimysql.execute(string,{}, function(inventory) {
        if (!inventory){}else{
        var invArray = inventory;
        var i;
        var arrayCount = 0;
        var playerinvname = player
        var invArrayTarget = [];
        let Key = ""+DataEntries+"";
        let NewDroppedName = 'Ground-' + Key;
        DataEntries = DataEntries
        emitNet("inventory-update-player", src, [invArray,arrayCount,playerinvname]);
          emitNet('current-items', src, invArray)
        }
    })
})

RegisterServerEvent("server-inventory-open")
onNet("server-inventory-open", async ( coords, player, secondInventory, targetName, itemToDropArray, sauce) => {

    let src = source

    if (!src) {
        src = sauce 
    }

    let playerinvname = player

    if ( InUseInventories[targetName] || InUseInventories[playerinvname] ) {
  
        if (InUseInventories[playerinvname]) {
            if ( ( InUseInventories[playerinvname] != player ) ) {
                return
            } else {
               
            }
        }
        if (InUseInventories[targetName]) {
            if (InUseInventories[targetName] == player) {

            } else {
                secondInventory = "69"
            }
        }
    }
    sendClientItemList(src)
    let string = `SELECT count(item_id) as amount, id, name, item_id, information, slot, dropped, quality, creationDate FROM ronin_inventory where name= '${player}' group by slot`;

    exports.ghmattimysql.execute(string,{}, function(inventory) {

        var invArray = inventory;
        var i;
        var arrayCount = 0;

           InUseInventories[playerinvname] = player;
 
           emitNet('current-items', src, invArray)
           
           if(secondInventory == "1") {
 
               var targetinvname = targetName
     
               let string = `SELECT count(item_id) as amount, id, name, item_id, information, slot, dropped, quality, creationDate FROM ronin_inventory WHERE name = '${targetinvname}' group by slot`;
               exports.ghmattimysql.execute(string,{}, function(inventory2) { 
                       emitNet("inventory-open-target", src, [invArray, arrayCount,playerinvname,inventory2,0,targetinvname,500,true]);
                  
                       InUseInventories[targetinvname] = player
               });
           }

           else if (secondInventory == "3") {
        
               let Key = ""+DataEntries+"";
               let NewDroppedName = 'Ground-' + Key;
    
               DataEntries = DataEntries + 1
               var invArrayTarget = [];
               DroppedInventories[NewDroppedName] = { position: { x: coords[0], y: coords[1], z: coords[2] }, name: NewDroppedName, used: false, lastUpdated: Date.now() }


               InUseInventories[NewDroppedName] = player;
       
               invArrayTarget = JSON.stringify(invArrayTarget)
               emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,invArrayTarget,0,NewDroppedName,500,false]);
               
}
 else if (secondInventory == "13")
{   

    let Key = ""+DataEntries+"";
    let NewDroppedName = 'Ground-'  + Key;
    DataEntries = DataEntries + 1
      for (let Key in itemToDropArray) {
          for (let i = 0; i < itemToDropArray[Key].length; i++) {
              let objectToDrop = itemToDropArray[Key][i];
              db(`UPDATE ronin_inventory SET slot='${i+1}', name='${NewDroppedName}', dropped='1' WHERE name='${Key}' and slot='${objectToDrop.faultySlot}' and item_id='${objectToDrop.faultyItem}' `);
          
              emit('sendingItemstoClient', player,src)
           }
      }
       
      DroppedInventories[NewDroppedName] = { position: { x: coords[0], y: coords[1], z: coords[2] }, name: NewDroppedName, used: false, lastUpdated: Date.now() }
      emitNet("Inventory-Dropped-Addition", -1, DroppedInventories[NewDroppedName] )
    } else if(secondInventory == "2") {
                
        var targetinvname = targetName;
        var shopArray = ConvenienceStore();
        var shopAmount = 13;
        emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);

    }
    else if(secondInventory == "4")
{
    var targetinvname = targetName;
    var shopArray = HardwareStore();
    var shopAmount = 20;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
    else if(secondInventory == "5")
    {
        var targetinvname = targetName;
        var shopArray = GunStore();
        var shopAmount = 9;
        emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
    else if(secondInventory == "6") 
{
    var targetinvname = targetName;
    var shopArray = CraftRiflesStoreGang();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
    else if(secondInventory == "8")
{
    var targetinvname = targetName;
    var shopArray = CraftRiflesCivilians();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
    else if(secondInventory == "9")
{
    var targetinvname = targetName;
    var shopArray = GangStore();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}   
    else if(secondInventory == "10")
{
    var targetinvname = targetName;
    var shopArray = PoliceArmory();
    var shopAmount = 9;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}    
    else if(secondInventory == "12")
{
    var targetinvname = targetName;
    var shopArray = BurgieStore();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}    
   else if(secondInventory == "11")
{
    emitNet("inventory-open-target-NoInject", src, [invArray.arrayCount,playerinvname]);
}  else if(secondInventory == "14") {
    var targetinvname = targetName;
    var shopArray = CourtHouse();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}    
   else if(secondInventory == "15")
{
    var targetinvname = targetName;
    var shopArray = MedicArmory();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "29")
{
    var targetinvname = targetName;
    var shopArray = MedicArmoryCiv();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "16")
{
    var targetinvname = targetName;
    var shopArray = Workshop();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
//    else if(secondInventory == "17")
// {
//     var targetinvname = targetName;
//     var shopArray = Smelting();
//     var shopAmount = 1;
//     emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
// }  
   else if(secondInventory == "18")
{
    var targetinvname = targetName;
    var shopArray = TacoTruck();
    var shopAmount = 14;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "22")
{
    var targetinvname = targetName;
    var shopArray = JailFood();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "23")
{
    var targetinvname = targetName;
    var shopArray = JailCraft();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "24")
{
    var targetinvname = targetName;
    var shopArray = JailWeapon();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "25")
{
    var targetinvname = targetName;
    var shopArray = JailMeth();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "26")
{
    var targetinvname = targetName;
    var shopArray = JailPhone();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
   else if(secondInventory == "27")
{
    var targetinvname = targetName;
    var shopArray = JailSlushy();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
   else if(secondInventory == "28")
{
    var targetinvname = targetName;
    var shopArray = InmateLottery();
    var shopAmount = 7;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "31")
{
    var targetinvname = targetName;
    var shopArray = Blackmarket();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "55")
{
    var targetinvname = targetName;
    var shopArray = Mechanic();
    var shopAmount = 4;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "200")
{
    var targetinvname = targetName;
    var shopArray = tfcraft();
    var shopAmount = 5;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "199")
{
    var targetinvname = targetName;
    var shopArray = ballascraft();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "198")
{
    var targetinvname = targetName;
    var shopArray = vagoscraft();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "197")
{
    var targetinvname = targetName;
    var shopArray = azteccraft();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

   else if(secondInventory == "7")
{
    var targetinvname = targetName;
    var shopArray = DroppedItem(itemToDropArray);
    
    itemToDropArray = JSON.parse(itemToDropArray)
    var shopAmount = itemToDropArray.length;
     
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
else {
    emitNet("inventory-update-player", src, [invArray,arrayCount,playerinvname]);
}
});
});



RegisterServerEvent("server-inventory-close")
onNet("server-inventory-close", async (player, targetInventoryName) => {
    let src = source
  
    if(targetInventoryName.startsWith("Trunk"))
       emitNet("toggle-animation", src, false);
    InUseInventories = InUseInventories.filter(item => item != player);
    if (targetInventoryName.indexOf("Ground") > -1 && DroppedInventories[targetInventoryName]) {
        if (DroppedInventories[targetInventoryName].used === false ) {
             delete DroppedInventories[targetInventoryName];
        } else {
            let string = `SELECT count(item_id) as amount, item_id, name, information, slot, quality, dropped FROM ronin_inventory WHERE name='${targetInventoryName}' group by item_id `;
            exports.ghmattimysql.execute(string,{}, function(result) {
                if (result.length == 0 && DroppedInventories[targetInventoryName]) {
                    delete DroppedInventories[targetInventoryName];
                    emitNet("Inventory-Dropped-Remove", -1, [targetInventoryName])
                }
            });
        }
    }
    emit("server-request-update-src", player, source) 
    sendClientItemList(src)
});


RegisterServerEvent("server-request.removeCraftItems")
onNet("server-inventory.removeCraftItems", async (player, data, coords, openedInv) => {

});

let IllegalSearchString = `'weedoz', 'weed5oz', 'coke50g', 'thermite', 'weedq', 'weed12oz', 'oxy', '1gcrack', '1gcocaine', 'joint'`

// checked below

RegisterServerEvent("sniffAccepted")
onNet("sniffAccepted", async (t) => {
    let src = source 
     emitNet('sniffAccepted', t, src)
});


RegisterServerEvent("SniffCID")
onNet("SniffCID", async (cid,src) => {
   
    let name = cid;
    let string = `SELECT count(item_id) as amount, id, item_id, name, information, slot, quality, dropped FROM ronin_inventory WHERE name='${name}' and item_id IN (${IllegalSearchString}) group by item_id`;

    exports.ghmattimysql.execute(string, {}, function(items) {
        if (item.length > 0) {
            emitNet("k9:SniffConfirmed", src)
        } else {
            emitNet("k9:SniffConfirmedFail", src)
        }
    });
});

// all checked below all correct!
RegisterServerEvent("sniffLicensePlateCheck") 
onNet("sniffLicensePlateCheck", async (plate) => {
     let src = source
     let car = 'Truck-'+plate 
     let Glovebox = 'Glovebox-'+plate

     let string = `SELECT count(item_id) as amount, id, item_id, name, information, slot, quality, dropped FROM ronin_inventory WHERE name='${car}' OR name='${Glovebox}') and item_id IN (${IllegalSearchString}) group by item_id`;

     exports.ghmattimysql.execute(string,{}, function(item) {
         if (item.lenth > 0) {
            emitNet("k9:SniffConfirmed", src)
        } else {
            emitNet("k9:SniffConfirmedFail", src)
          }
     });
}); // done an checked 44.45 on stream.

RegisterServerEvent("inv:delete")
onNet("inv:delete", async (inv) => {
    db(`DELECT FROM ronin_inventory WHERE name='${inv}'`);
});

RegisterServerEvent("server-inventory-remove")
onNet("server-inventory-remove-slot", async (player, itemidsent,amount,slot) => {
    var playerinvname = player
    db(`DELETE FROM ronin_inventory WHERE name='${playerinvname}' and item_id='${itemidsent}' and slot='${slot}' LIMIT ${amount}`);
});

RegisterServerEvent("server-ragdoll-items") 
onNet("server-ragdoll-items", async (player) => {
     let currInventoryName = `${player}`
     let newInventoryName = `wait-${player}`

     db(`UPDATE ronin_inventory SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="mobilephone" `);
     db(`UPDATE ronin_inventory SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="idcard" `);

    await db(`DELETE FROM ronin_inventory WHERE name='${currInventoryName}'`);

    db(`UPDATE ronin_inventory SET name='${currInventoryName}', WHERE name='${newInventoryName}' and dropped=0`);
});


RegisterServerEvent('server-jail-item')
onNet("server-jail-item", async (player,isSentToJail) => {
    let currInventoryName = `${player}`
    let newInventoryName = `${player}`

    if(!isSentToJail) {
        currInventoryName = `${player}`
        newInventoryName = `jail-${player}`
    } else {
        currInventoryName = `jail-${player}`
        newInventoryName = `${player}`
    }

    db(`UPDATE ronin_inventory SET name='${currInventoryName}', WHERE name='${newInventoryName}' and dropped=0`);
});

function removecash(src,amount) {
    emit('cash:remove', src, amount)
}

setTimeout(CleanDroppedInventory, 5)

function sendClientItemList(src)
{
    emitNet('sendListAtOnce',src,itemList)
}


function DroppedItem(itemArray) {
    itemArray = JSON.parse(itemArray)
    var shopItems = [];

    shopItems[0] = { item_id: itemArray[0].itemid, id: 0, name: "shop", information: "{}", slot: 1, amount: itemArray[0].amount};

    return JSON.stringify(shopItems);
}
function BuildInventory(Inventory) {
    let buildInv = Inventory
    let invArray = {};
    itemCount = 0;
    for (let i = 0; i < buildInv.length; i++) {
        invArray[itemCount] = { item_id: buildInv[i].item_id, id: buildInv[i].id, name: buildInv[i].name, information: buildInv[i], slot: buildInv[i].slot};
        itemCount = itemCount + 1
    }
    return [JSON.stringify(invArray),itemCount]
}

function mathrandom(min, max) {
    return Math.floor(Math.random() * (max+1 - min) ) + min;
}


const DEGREDATION_INVENTORY_CHECK = 1000 * 60 * 60;
const DEGREDATION_TIME_BROKEN = 1000 * 60 * 40320;
const DEGREDATION_TIME_WORN = 1000 * 60 * 201000;


function payStore(storeName,amount,itemid) {

   if (storeName.indexOf("Traphouse") > -1 ) {
       let id = storeName.split('|')

       id = id[0].split('-')[1]

       emit('traps:pay',id,amount)
   } else {
       
       let cid = storeName.split('|')
       let name = cid[1]
       if (itemList[itemid].illegal && mathrandom(1,100) > 80) {
     //      emitNet('IllegalSale',"Store Owner", name)
       }
       cid = cid[0].split('-')[1]
       emit('server:PayStoreOwner', cid, amount)
   }
}//



RegisterServerEvent("server-inventory-move")
onNet("server-inventory-move", async (player, data, coords) => {
    let targetslot = data[0]
    let startslot = data[1]
    let targetname = data[2].replace(/"/g, "");
    let startname = data[3].replace(/"/g, "");
    let purchase = data[4]
    let itemCosts = data[5]
    let itemidsent = data[6]
    let amount = data[7]
    let crafting = data[8]
    let isWeapon = data[9]
    let PlayerStore = data[10]
    let creationDate = Date.now()

    if ((targetname.indexOf("Ground") > -1 || targetname.indexOf("hidden") > -1) && DroppedInventories[targetname]) {

        if (DroppedInventories[targetname].used === false) {

            DroppedInventories[targetname] = { position: { x: coords[0], y: coords[1], z: coords[2]}, name: targetname, used: true, lastUpdated: Date.now() }
            emitNet("Inventory-Dropped-Addition", -1, DroppedInventories[targetname] )
        }
    }

    let info = "{}"

    if (purchase) {
        if(isWeapon) {


        }
        info = await GenerateInformation(player,itemidsent)
        removecash(source,itemCosts)

        if (!PlayerStore) {
            for (let i = 0; i < parseInt(amount); i++) {
        
                db(`INSERT INTO ronin_inventory (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetname}','${info}','${targetslot}','${creationDate}' );`);
            }
        } else if (PlayerStore) {
             payStore(startname,itemCosts,itemidsent)
           
                db(`INSERT INTO ronin_inventory (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetname}','${info}','${targetslot}','${creationDate}' );`);

            for (let i = 0; i < parseInt(amount); i++) {
                db(`UPDATE ronin_inventory SET slot='${targetslot}', name='${targetname}', dropped='0' WHERE slot='${startslot}' and name='${startname}'`);
 
            }
        } else if (crafting) {
     
            info - await GenerateInformation(player,itemidsent)
            for (let i = 0; i < parseInt(amount); i++) {
                db(`INSERT INTO ronin_inventory (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetname}','${info}','${targetslot}','${creationDate}' );`);
            }
        } else {
            if (targetname.indexOf("Ground") > -1 || targetname.indexOf("hidden") > -1) {

            db(`INSERT INTO ronin_inventory SET slot='${targetslot}', name='${targetname}', dropped='1' WHERE slot='${startslot}' AND name='${startname}'`);
            emit('sendingItemstoClient', player,src)
           } else {
            db(`UPDATE ronin_inventory SET slot='${targetslot}', name='${targetname}', dropped='0' WHERE slot='${startslot}' and name='${startname}'`);

           }
        }
     } else {

        if (crafting == true){

                     info - await GenerateInformation(player,itemidsent)
                    for (let i = 0; i < parseInt(amount); i++) {
                        db(`INSERT INTO ronin_inventory (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetname}','${info}','${targetslot}','${creationDate}' );`);
                    }
                }
           
            db(`UPDATE ronin_inventory SET slot='${targetslot}', name='${targetname}', dropped='0' WHERE slot='${startslot}' and name='${startname}'`);
     
    }
});


function CleanDroppedInventory() {
    onNet("server-ragdoll-items", async (player) => {
    let currInventoryName = `${player}`
    let newInventoryName = `wait-${player}`
   
    db(`UPDATE ronin_inventory SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="mobilephone" `);
    db(`UPDATE ronin_inventory SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="idcard" `);
    await db(`DELETE FROM ronin_inventory WHERE name='${currInventoryName}'`);
    db(`UPDATE ronin_inventory SET name='${currInventoryName}', WHERE name='${newInventoryName}' and dropped=0`);
    db(`DELETE FROM ronin_inventory WHERE dropped='1'`);
    db(`DELETE FROM ronin_inventory WHERE name='trash-1'`);
    db(`DELETE FROM ronin_inventory WHERE item_id IN ('foodingredient', 'coffee', 'fishtaco', 'taco', 'burrito', 'churro', 'hotdog', 'greencow', 'donut', 'eggsbacon', 'icecream', 'mshake')`)
    db(`UPDATE ronin_inventory SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="bandage" `);
    db(`UPDATE ronin_inventory SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="idcard" `);
  
    })
};


RegisterServerEvent("server-inventory-stack")
onNet("server-inventory-stack", async (player, data, coords) => {

    let targetslot = data[0]
    let moveAmount = data[1]
    let targetName = data[2].replace(/"/g, "");
    let src = source
     let originSlot = data[3]

     let originInventory = data[4].replace(/"/g, "");

     let purchase = data[5]
     let itemCosts = data[6]
    let itemidsent = data[7]
     let amount = data[8]
     let crafting = data[9]
     let isWeapon = data[10]
     let PlayerStore = data[11]
     let creationDate = Date.now()

     if ( (targetName.indexOf("Ground") > -1 || targetName.indexOf("hidden") > -1) && DroppedInventories[targetName] ) {

         if (DroppedInventories[targetName].used === false ) {
             DroppedInventories[targetName] =  { position: { x: coords[0], y: coords[1], z: coords[2] }, name: targetName, used: true, lastUpdated: Date.now() }
             emitNet("Inventory-Dropped-Addition", -1, DroppedInventories[targetName] )
         }
     }

     let info = "{}"

     if (purchase) {

         if (isWeapon) {
            db(`INSERT INTO ronin_inventory (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetName}','${info}','${targetslot}','${creationDate}' );`);
         }
         info = await GenerateInformation(player,itemidsent)
         removecash(source,itemCosts)

         if (!PlayerStore) {
             for (let i = 0; i < parseInt(amount); i++) {

              db(`INSERT INTO ronin_inventory (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetName}','${info}','${targetslot}','${creationDate}' );`);
           

             }
         }
    

         if (PlayerStore) {
             let string = `SELECT item_id FROM ronin_inventory WHERE slot='${originSlot}' and name='${originInventory}'`;
             payStore(originInventory,itemCosts,itemidsent)
             exports.ghmattimysql.execute(string,{}, function(startid) {

                db(`INSERT INTO ronin_inventory (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetName}','${info}','${targetslot}','${creationDate}' );`);
           
             });
         }


     } else if (crafting) {

         info = await GenerateInformation(player,itemidsent)

         for (let i = 0; i < parseInt(amount); i++) {

             db(`INSERT INTO ronin_inventory (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetName}','${info}','${targetslot}','${creationDate}' );`);
         }
     } else {
         let string = `SELECT item_id, creationDate, quality FROM ronin_inventory WHERE slot='${originSlot}' and name='${originInventory}'`;
  
         exports.ghmattimysql.execute(string,{}, function(result) {

             if (targetName.indexOf("Ground") > -1 || targetName.indexOf("hidden") > -1) {
 
                db(`UPDATE ronin_inventory SET slot='${targetslot}', name='${targetName}', dropped='0' WHERE slot='${originSlot}' and name='${originInventory}' and creationDate='${result[0].creationDate}' and item_id='${result[0].item_id}' LIMIT ${moveAmount}`);

             } else {
                 db(`UPDATE ronin_inventory SET slot='${targetslot}', name='${targetName}', dropped='0' WHERE slot='${originSlot}' and name='${originInventory}' and creationDate='${result[0].creationDate}' and item_id='${result[0].item_id}' LIMIT ${moveAmount}`);
        

             }
         });
     }
 });

 RegisterServerEvent("server-inventory-swap")
 onNet("server-inventory-swap", (player, data, coords) => {
     let targetSlot = data[0]
     let targetName = data[1].replace(/"/g, "");
 
     let originSlot = data[2]
     let originInventory = data[3].replace(/"/g, "")
     if (targetName.indexOf("Ground") > -1 || targetName.indexOf("hidden") > -1) {
         let string = `SELECT item_id FROM ronin_inventory WHERE slot='${targetSlot}' and name='${targetName}'`;
         let string2 = `SELECT item_id FROM ronin_inventory WHERE slot='${originSlot}' and name='${originInventory}'`;
         exports.ghmattimysql.execute(string,{}, function(result) {

             let string2 = `UPDATE ronin_inventory SET slot='${originSlot}', name='${originInventory}', dropped='0' WHERE slot='${targetSlot}' and name='${targetName}' and item_id='${result[0].item_id}'`
             exports.ghmattimysql.execute(string2,{}, function(result) {
  
             })
         });
         exports.ghmattimysql.execute(string2,{}, function(result) {
         let string3 = `UPDATE ronin_inventory SET slot='${targetSlot}', name='${targetName}', dropped='0' WHERE slot='${originSlot}' and name='${originInventory}' and item_id='${result[0].item_id}'`
             exports.ghmattimysql.execute(string3,{}, function(result) {
            
             })
         });
     } else {
         let string = `SELECT item_id FROM ronin_inventory WHERE slot='${targetSlot}' and name='${targetName}'`;
         let string2 = `SELECT item_id FROM ronin_inventory WHERE slot='${originSlot}' and name='${originInventory}'`;
         exports.ghmattimysql.execute(string,{}, function(result) {
             let string2 = `UPDATE ronin_inventory SET slot='${originSlot}', name='${originInventory}', dropped='0' WHERE slot='${targetSlot}' and name='${targetName}' and item_id='${result[0].item_id}'`
             exports.ghmattimysql.execute(string2,{}, function(result) {
             })
         });
         exports.ghmattimysql.execute(string2,{}, function(result) {
         let string3 = `UPDATE ronin_inventory SET slot='${targetSlot}', name='${targetName}', dropped='0' WHERE slot='${originSlot}' and name='${originInventory}' and item_id='${result[0].item_id}'`
             exports.ghmattimysql.execute(string3,{}, function(result) {
             
             })
         });
     }
 });

RegisterServerEvent("server-frisk-player-inventory")
onNet("server-frisk-player-inventory", (searcher,cash,  DirtyMoney, inventoryName) => {
    let weapons = 0
    let string = `SELECT count(item_id) as amount, id, item_id, id, name, information, slot, quality, dropped FROM ronin_inventory WHERE name = '${inventoryName}' group by item_id, slot`;

        exports.ghmattimysql.execute(string,{}, function(inventory) {
            for (let i = 0; i < inventory.length; i++) {
                var t = parseInt(inventory[i].item_id, 10)
                if (!isNaN(t)) {
                    weapons++;
                }
            }

            if (cash >= 9000 || DirtyMoney >= 2000 || weapons >= 1) {
            emitNet('chatmessage', searcher, '', 3, "Frisk: Person Seems to have large bulge.")
            }else{
            emitNet('chatmessage', searcher, '', 3, "Frisk: Cannot Seem to feel anything.")
        }
        });
});

function PoliceArmory() {
    var shopItems = [
        { item_id: "pistolammo", id: 0, name: "Shop", information: "{}", slot: 5, amount: 5 },
        { item_id: "rifleammo", id: 0, name: "Shop", information: "{}", slot: 4, amount: 5 },
        { item_id: "1593441988", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
        { item_id: "-86904375", id: 0, name: "Shop", information: "{}", slot: 2, amount: 1 },
        { item_id: "911657153", id: 0, name: "Shop", information: "{}", slot: 3, amount: 1 },
        { item_id: "IFAK", id: 0, name: "Shop", information: "{}", slot: 6, amount: 1 },
        { item_id: "armor1", id: 0, name: "Shop", information: "{}", slot: 7, amount: 1 },
        { item_id: "2343591895", id: 0, name: "Shop", information: "{}", slot: 8, amount: 5 },
        { item_id: "radio", id: 0, name: "Shop", information: "{}", slot: 9, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function MedicArmory() {
    var shopItems = [
     
    ];
    return JSON.stringify(shopItems);
}

function MedicArmoryCiv() {
    var shopItems = [
       
    ];
    return JSON.stringify(shopItems);
}

function InMateLottery() {
    var shopItems = [
  
    ];
    return JSON.stringify(shopItems);
}

function JailFood() {
    var shopItems = [
        { item_id: "jailfood", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function Blackmarket() {
    var shopItems = [
        { item_id: "pistolammo", id: 0, name: "shop", information: "{}", slot: 1, amount: 5 },
    ];
    return JSON.stringify(shopItems);
}


function TacoTruck() {
    var shopItems = [
    ];
    return JSON.stringify(shopItems);
}


function JailWeapon() {
    var shopItems = [

    ];
    return JSON.stringify(shopItems);
}

function JailMeth() {
    var shopItems = [
        { item_id: "methbag", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function JailPhone() {
    var shopItems = [
    ];
    return JSON.stringify(shopItems);
}

function JailSlushy() {
    var shopItems = [
        { item_id: "slushy", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

// function Smelting() {
//     var shopItems = [
//         { item_id: "goldbar", id: 0, name: "craft", information: "{}", slot: 1, amount: 50 },
  
//     ];
//     return JSON.stringify(shopItems);
// }

function Mechanic() {
    var shopItems = [
        { item_id: "584646201", id: 0, name: "craft", information: "{}", slot: 1, amount: 5 },
        { item_id: "-771403250", id: 0, name: "craft", information: "{}", slot: 2, amount: 5 },
        { item_id: "extended_ap", id: 0, name: "craft", information: "{}", slot: 3, amount: 1 },
        { item_id: "silencer_s", id: 0, name: "craft", information: "{}", slot: 4, amount: 5 },
    ];
    return JSON.stringify(shopItems);
}

function tfcraft() {
    var shopItems = [
        { item_id: "584646201", id: 0, name: "craft", information: "{}", slot: 1, amount: 5 },
        { item_id: "extended_ap", id: 0, name: "craft", information: "{}", slot: 2, amount: 1 },
        { item_id: "-771403250", id: 0, name: "craft", information: "{}", slot: 3, amount: 5 },
        { item_id: "3173288789", id: 0, name: "craft", information: "{}", slot: 4, amount: 5 },
        { item_id: "-619010992", id: 0, name: "craft", information: "{}", slot: 5, amount: 5 },
    ];
    return JSON.stringify(shopItems);
}

function ballascraft() {
    var shopItems = [
        { item_id: "-771403250", id: 0, name: "craft", information: "{}", slot: 1, amount: 5 },
    ];
    return JSON.stringify(shopItems);
}

function vagoscraft() {
    var shopItems = [
        { item_id: "3173288789", id: 0, name: "craft", information: "{}", slot: 1, amount: 5 },
    ];
    return JSON.stringify(shopItems);
}

function azteccraft() {
    var shopItems = [
        { item_id: "-619010992", id: 0, name: "craft", information: "{}", slot: 1, amount: 5 },
    ];
    return JSON.stringify(shopItems);
}



// stores
function ConvenienceStore() {
    var shopItems = [
        { item_id: "sandwich", id: 0, name: "Shop", information: "{}", slot: 1, amount: 50 },
        { item_id: "hamburger", id: 0, name: "Shop", information: "{}", slot: 2, amount: 50 },
        { item_id: "cola", id: 0, name: "Shop", information: "{}", slot: 3, amount: 50 },
        { item_id: "water", id: 0, name: "Shop", information: "{}", slot: 4, amount: 50 },
        { item_id: "beer", id: 0, name: "Shop", information: "{}", slot: 5, amount: 50 },
        { item_id: "vodka", id: 0, name: "Shop", information: "{}", slot: 6, amount: 50 },
        { item_id: "whiskey", id: 0, name: "Shop", information: "{}", slot: 7, amount: 50 },
        { item_id: "bandage", id: 0, name: "Shop", information: "{}", slot: 8, amount: 5 },
        { item_id: "foodingredient", id: 0, name: "Shop", information: "{}", slot: 9, amount: 10 },
        { item_id: "ciggy", id: 0, name: "Shop", information: "{}", slot: 10, amount: 50 },
        { item_id: "mobilephone", id: 0, name: "Shop", information: "{}", slot: 11, amount: 50 },
        { item_id: "rollingpaper", id: 0, name: "Shop", information: "{}", slot: 12, amount: 50 },
        { item_id: "idcard", id: 0, name: "Shop", information: "{}", slot: 13, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function HardwareStore() {
    var shopItems = [
        { item_id: "repairkit", id: 0, name: "Shop", information: "{}", slot: 1, amount: 5 },
        { item_id: "advrepairkit", id: 0, name: "Shop", information: "{}", slot: 2, amount: 5 },
        { item_id: "radio", id: 0, name: "Shop", information: "{}", slot: 3, amount: 5 },
        { item_id: "watch", id: 0, name: "Shop", information: "{}", slot: 4, amount: 5 },
        { item_id: "lockpick", id: 0, name: "Shop", information: "{}", slot: 5, amount: 5 },
   
    ];
    return JSON.stringify(shopItems);
}

// function BurgiesStore() {
//     var shopItems = [

//     ];
//     return JSON.stringify(shopItems);
// }

// function GangStore() {
//     var shopItems = [
        
//     ];
//     return JSON.stringify(shopItems);
// }

// function GangRepStore() {
//     var shopItems = [

//     ];
//     return JSON.stringify(shopItems);
// };



// function Workshop() {
//     var shopItems = [
   
//     ];
//     return JSON.stringify(shopItems);
// };

function GunStore() {
    var shopItems = [
        { item_id: "453432689", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
        { item_id: "3218215474", id: 0, name: "Shop", information: "{}", slot: 2, amount: 1 },
        { item_id: "pistolammo", id: 0, name: "Shop", information: "{}", slot: 3, amount: 5 },
        { item_id: "2508868239", id: 0, name: "Shop", information: "{}", slot: 4, amount: 1 },
        { item_id: "2343591895", id: 0, name: "Shop", information: "{}", slot: 5, amount: 1 },
        { item_id: "armor", id: 0, name: "Shop", information: "{}", slot: 6, amount: 1 },
        { item_id: "2227010557", id: 0, name: "Shop", information: "{}", slot: 99999, amount: 1 },
        { item_id: "3218215474", id: 0, name: "Shop", information: "{}", slot: 100000, amount: 1 },
        { item_id: "911657153", id: 0, name: "Shop", information: "{}", slot: 100001, amount: 1 },
        { item_id: "3441901897", id: 0, name: "Shop", information: "{}", slot: 100002, amount: 1 },
        { item_id: "1593441988", id: 0, name: "Shop", information: "{}", slot: 100003, amount: 1 },
    ];
    return JSON.stringify(shopItems);
};

// function CraftRifleStoreGangs() {
//     var shopItems = [
 
//     ];
//     return JSON.stringify(shopItems);
// };

// function CraftBikerStoreGangs() {
//     var shopItems = [
 
//     ];
//     return JSON.stringify(shopItems);
// };

// function CraftRifleCivilians() {
//     var shopItems = [
//     ];
//     return JSON.stringify(shopItems);
// }
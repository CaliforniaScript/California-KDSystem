--README Leggi la spiegazione su come usare i miei trigger cosi da non fare cazzate, :)

--[[ 

    Using trigger  =  "mxm-kd-sistem:PlayerSpawned"

    Far triggerare il trigger dal client appena il player è spawnato, non serve fornire nessun argomento basta che il trigger viene triggerato dal client

    il trigger serve a fetchare il database prendendo il kd del player spawnato inserendolo in una tabella ed inviarlo al client 

]]


--[[ 

    Using trigger  =  "mxm-kd-sistem:UpdateKD"  

    Far triggerare il trigger dal vostro sistema di morte  gli argomenti da fornire sono = (type,redzone,player)

     -type = kill/morte (il type indica se kd deve aggiornarsi in positivo in caso di type "kill" o in negativo in caso di type "morte")

     -redzone = boolean  (l argomento redzone indica il tipo di kd che deve aggiornarsi, se il valore è true si aggionera il redzonekd, se è false si aggionerà il kd classico) 

     -player = server id (il valore player indica il server id del player a cui aggiornare il kd )

]]



--[[

    Using trigger  =  "mxm-kd-sistem:SyncKd"  

    Il trigger serve a sincronizzare il kd tra client e server, l unico argomento è il "(src)" server id, il trigger puo essere utile in caso dobbiate sincronizzare il kd in una determinata situazione, per il resto fa gia tutta la sincronizzazione in automatico
]]



--[[ 
    
    Using export  = "getKd" 
    l export "getKd" serve ad ottenere a tabella del kd di un tereminato player gli argomenti da fornire sono = (src)

    -src = server id (il valore src indica il server id del player a cui gettare la tabella del kd )
]]




local Kd = {}

AddEventHandler("mxm-kd-sistem:PlayerSpawned", function()  
    local src = source
    local identifier = GetPlayerIdentifier(src,1)
    MySQL.Async.fetchAll('SELECT * FROM kd WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result) 
        if #result > 0 then
            for a, b in pairs(result) do
                Kd[identifier] = {}  
                Kd[identifier].kd               = b.kd
                Kd[identifier].kill             = b.kill
                Kd[identifier].morti            = b.morti
                Kd[identifier].redzonekd        = b.redzonekd
                Kd[identifier].redzonekill      = b.redzonekill
                Kd[identifier].redzonemorti     = b.redzonemorti
            end
            TriggerClientEvent("mxm-kd-sistem:SyncKd",src,Kd[identifier])
        else 
            MySQL.Sync.execute('INSERT INTO kd (identifier) VALUES (@identifier)', {
                ['@identifier'] = identifier,
            })
                Kd[identifier] = {} 
                Kd[identifier].kd               = 0
                Kd[identifier].kill             = 0
                Kd[identifier].morti            = 0
                Kd[identifier].redzonekd        = 0
                Kd[identifier].redzonekill      = 0
                Kd[identifier].redzonemorti     = 0
            TriggerClientEvent("mxm-kd-sistem:SyncKd",src,Kd[identifier])
        end
    end)
end)




RegisterServerEvent("mxm-kd-sistem:UpdateKD")
AddEventHandler("mxm-kd-sistem:UpdateKD",function (type,redzone,player)
    local src = player
    local identifier = GetPlayerIdentifier(src,1)
    if Kd[identifier] ~= nil then
        if type == "kill" then
            if redzone then
                Kd[identifier].redzonekill = tonumber(Kd[identifier].redzonekill + 1)  
                if tonumber(Kd[identifier].redzonemorti) > 0  then
                    Kd[identifier].redzonekd = math.floor((tonumber(Kd[identifier].redzonekill/Kd[identifier].redzonemorti) * 10^2) + 0.5) / (10^2)
                else
                    Kd[identifier].redzonekd = math.floor((tonumber(Kd[identifier].redzonekill) * 10^2) + 0.5) / (10^2)
                end
                
            else
                Kd[identifier].kill = tonumber(Kd[identifier].kill + 1)
                if tonumber(Kd[identifier].morti) > 0  then
                    Kd[identifier].kd = math.floor((tonumber(Kd[identifier].kill/Kd[identifier].morti) * 10^2) + 0.5) / (10^2)
                else
                    Kd[identifier].kd = math.floor((tonumber(Kd[identifier].kill) * 10^2) + 0.5) / (10^2)
                end
            end
        elseif type == "morte" then
            if redzone then
                Kd[identifier].redzonemorti = tonumber(Kd[identifier].redzonemorti + 1)  
                Kd[identifier].redzonekd =  math.floor((tonumber(Kd[identifier].redzonekill/Kd[identifier].redzonemorti) * 10^2) + 0.5) / (10^2)     
            else
                Kd[identifier].morti = tonumber(Kd[identifier].morti + 1)
                Kd[identifier].kd = math.floor((tonumber(Kd[identifier].kill / Kd[identifier].morti) * 10^2) + 0.5) / (10^2)
            end
        end
        
        TriggerClientEvent("mxm-kd-sistemy:SyncKd",src,Kd[identifier])

--[[        -- update hud 
        if redzone then
            TriggerClientEvent("MxM_FR:updatehud",src,"ks_red")
        else
            TriggerClientEvent("MxM_FR:updatehud",src,"free")
        end]]
    end
end)



RegisterServerEvent("mxm-kd-sistem:SyncKd")
AddEventHandler("mxm-kd-sistem:SyncKd",function ()
    local src = source
    local identifier = GetPlayerIdentifier(src,1)
    if Kd[identifier] ~= nil then
        TriggerClientEvent("mxm-kd-sistem:SyncKd",src,Kd[identifier])
    end
end)



exports('getKd',function(src)
    local identifier = GetPlayerIdentifier(src,1)
    if Kd[identifier] ~= nil then
        return Kd[identifier] 
    end
end)



AddEventHandler('playerDropped', function ()
 local src = source
 local identifier = GetPlayerIdentifier(src,1) 
    if Kd[identifier] ~= nil then
        MySQL.Async.execute('UPDATE kd SET kd = @kd, kill = @kill, morti = @morti, redzonekd = @redzonekd, redzonekill = @redzonekill, redzonemorti = @redzonemorti  WHERE identifier = @identifier', {
            ['@kd']             =   Kd[identifier].kd,
            ['@kill']           =   Kd[identifier].kill,
            ['@morti']          =   Kd[identifier].morti,
            ['@redzonekd']      =   Kd[identifier].redzonekd,
            ['@redzonekill']    =   Kd[identifier].redzonekill,
            ['@redzonemorti']   =   Kd[identifier].redzonemorti,
            ["@identifier"]     =   identifier
        }, function()
            Kd[identifier] = nil
        end)   
    end
end)
  
  
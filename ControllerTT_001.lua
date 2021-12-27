MQTT_BrokerIP = "192.168.43.254"
MQTT_BrokerPort = 1883
--MQTT_Client_user = "user"
--MQTT_Client_password = "password"
MQTT_ClientID = "esp-010"
station_cfg={}
station_cfg.ssid="AndroidAP"
station_cfg.pwd="297666952"
wifi.setmode(wifi.STATION)
wifi.sta.config(station_cfg)
wifi.sta.connect()
print(wifi.sta.getip())
wifi.sta.autoconnect(1)
mqttFlag = 0
cnt = 0
--uart.setup(1, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1)
-------------------------------------------------------------
RxBuf = "000000000000000000000000000000000"
uart.on("data", 'W', function(data)
    RxBuf = data
    if data == "Q" then
    uart.on("data") -- unregister callback function
    end
end, 0)
-------------------------------------------------------------
mytimer = tmr.create()
mytimer:register(15000, tmr.ALARM_AUTO, function ()
if mqttFlag == 0 then   -- если нет подключения к брокеру
    m = mqtt.Client(MQTT_ClientID, 120, "user", "password")
    m:on("connect", function(client) print ("connected") end)
    m:on("offline", function(client)    print ("offline")
                                        mqttFlag = 0
    end)
    -- on publish message receive event
    m:on("message", function(client, topic, data)
      print(topic .. ":" )
      if data ~= nil then
        print(data)
      end
    end)
    m:on("overflow", function(client, topic, data)
      print(topic .. " partial overflowed message: " .. data )
    end)
    m:connect(MQTT_BrokerIP, MQTT_BrokerPort, 0, function(client)
      print("connected")
      mqttFlag = 1
      -- subscribe topic with qos = 0
      client:subscribe("/KOTEL/STOP/", 0, function(client) print("subscribe success") end)
      -- publish a message with data = hello, QoS = 0, retain = 0
      client:publish("/KOTEL/", "hello", 0, 0, function(client) print("котел на связи") end)
    end,
    function(client, reason)
      print("failed reason: " .. reason)
    end)
    else    -- если подключен к брокеру
    Pod = tonumber(string.sub(RxBuf, 1, 4))
    Obr = tonumber(string.sub(RxBuf, 5, 8))
    Riser = tonumber(string.sub(RxBuf, 9, 12))
    Bunker = tonumber(string.sub(RxBuf, 13, 16))
    Rashod = tonumber(string.sub(RxBuf, 17, 20))
    Power = tonumber(string.sub(RxBuf, 21, 25))
    time = string.sub(RxBuf, 26, 33)
	flagFuel = string.sub(RxBuf, 34, 36)
    
    if (Pod ~= nil) then
       m: publish("/KOTEL/Pod/",Pod,0,0,function(client) print("sent") end)
     --else m: publish("/KOTEL/Pod/",0,0,0,function(client) print("sent") end)
     end
    if (Obr ~= nil) then
       m: publish("/KOTEL/Obr/",Obr,0,0,function(client) print("sent") end)
     --else m: publish("/KOTEL/Obr/",0,0,0,function(client) print("sent") end)
     end     
    if (Riser ~= nil) then
       m: publish("/KOTEL/Riser/",Riser,0,0,function(client) print("sent") end)
     --else m: publish("/KOTEL/Riser/",0,0,0,function(client) print("sent") end)
     end
    if (Bunker ~= nil) then
       m: publish("/KOTEL/Bunker/",Bunker,0,0,function(client) print("sent") end)
     --else m: publish("/KOTEL/Bunker/",0,0,0,function(client) print("sent") end)
     end  
    if (Rashod ~= nil) then
       m: publish("/KOTEL/Rashod/",Rashod,0,0,function(client) print("sent") end)
     --else m: publish("/KOTEL/Bunker/",0,0,0,function(client) print("sent") end)
    end 
    if (Power ~= nil) then
       m: publish("/KOTEL/Power/",Power,0,0,function(client) print("sent") end)
     --else m: publish("/KOTEL/Bunker/",0,0,0,function(client) print("sent") end)
    end
    if (time ~= nil) then
       m: publish("/KOTEL/time/",time,0,0,function(client) print("sent") end)
     --else m: publish("/KOTEL/Bunker/",0,0,0,function(client) print("sent") end)
    end
	if (flagFuel == "SOS") then
        if (cnt == 0) or (cnt % 40 == 0) then
            m: publish("/KOTEL/","SOS",0,0,function(client) print("sent") end)
        end
        cnt = cnt + 1
        if cnt == 100 then cnt = 0 end
    end
end
end)
mytimer:start()

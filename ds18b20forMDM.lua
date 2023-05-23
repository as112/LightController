pin = 3
--MQTT_BrokerIP = "192.168.43.71"
MQTT_BrokerIP = "mqtt.by"
MQTT_BrokerPort = 1883
MQTT_Client_user = "as112"
MQTT_Client_password = "etmpiqgu"
MQTT_ClientID = "esp-05"
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
ds18b20.setup(pin)
t = 0
gpio.mode(4, gpio.OUTPUT)
-------------------------------------------------------------
mytimer = tmr.create()
mytimer:register(20000, tmr.ALARM_AUTO, function ()
if mqttFlag == 0 then   -- если нет подключения к брокеру
    m = mqtt.Client(MQTT_ClientID, 120, MQTT_Client_user, MQTT_Client_password)
    m:on("connect", function(client) 
        print ("connected") 
        cnt = 0
    end)
    m:on("offline", function(client)   
        print ("offline")
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
      client:subscribe("/ESP05/R1", 0, function(client) print("subscribe success") end)
      -- publish a message with data = hello, QoS = 0, retain = 0
      -- client:publish("/ESP05/", "hello", 0, 0, function(client) print("sent") end)
    end,
    function(client, reason)
      mqttFlag = 0
      gpio.write(4,gpio.LOW)
      print("failed reason: " .. reason)
      cnt = cnt + 1
      if (cnt == 25) then
        node.restart()
      end
    end)
else    -- если подключен к брокеру
    gpio.write(4,gpio.HIGH)
--    status, temp, humi, temp_dec, humi_dec = dht.read11(pin)
    ds18b20.read(function(ind,rom,res,t1,tdec,par)
        t = t1 - (t1 * 10 % 1)/10
        gpio.write(4,gpio.LOW)
        print("Temp = "..t..string.format(" %c", 0xB0).."C")
        m: publish("/user/as112/ESP05/TEMP/",t,0,0,function(client) print("sent") end)
        gpio.write(4,gpio.HIGH)
    end,{})

    
end
end)
mytimer:start()

wdgTimer = tmr.create()
wdgTimer:register(1000*60*20, tmr.ALARM_AUTO, function ()
    node.restart()
end)
wdgTimer:start()

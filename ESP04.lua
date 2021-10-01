BUT_PIN1 = 0
BUT_PIN2 = 1
BUT_PIN3 = 2
BUT_PIN4 = 3

REL_PIN1 = 4
REL_PIN2 = 5
REL_PIN3 = 6
REL_PIN4 = 7

gpio.mode(REL_PIN1, gpio.OUTPUT)
gpio.mode(REL_PIN2, gpio.OUTPUT)
gpio.mode(REL_PIN3, gpio.OUTPUT)
gpio.mode(REL_PIN4, gpio.OUTPUT)

gpio.mode(BUT_PIN1, gpio.INPUT)
gpio.mode(BUT_PIN2, gpio.INPUT)
gpio.mode(BUT_PIN3, gpio.INPUT)
gpio.mode(BUT_PIN4, gpio.INPUT)

gpio.write(REL_PIN1,gpio.HIGH)
gpio.write(REL_PIN2,gpio.HIGH)
gpio.write(REL_PIN3,gpio.HIGH)
gpio.write(REL_PIN4,gpio.HIGH)

ButtonState_old1 = 0
ButtonState_old2 = 0
ButtonState_old3 = 0
ButtonState_old4 = 0


MQTT_BrokerIP = "192.168.43.254"
MQTT_BrokerPort = 1883
MQTT_Client_user = "user"
MQTT_Client_password = "password"
MQTT_ClientID = "esp-04"
station_cfg={}
station_cfg.ssid="AndroidAP"
station_cfg.pwd="297666952"
wifi.setmode(wifi.STATION)
wifi.sta.config(station_cfg)
wifi.sta.connect()
print(wifi.sta.getip())
wifi.sta.autoconnect(1)

RelState_old1 = 1
RelState_old2 = 1
RelState_old3 = 1
RelState_old4 = 1

mqttFlag = 0
cnt = 0

timerR1 = tmr.create()
timerR1:register(100, tmr.ALARM_AUTO, function ()
    
    local ButtonState1 = gpio.read(BUT_PIN1)
    -- Нажатие кнопки (задний фронт на gpio0)
    if (ButtonState1 == 0) and (ButtonState_old1 == 1) then
          if gpio.read(REL_PIN1) == 1 then
             gpio.write(REL_PIN1,gpio.LOW)
             print("R1 ON")
            else
             gpio.write(REL_PIN1,gpio.HIGH)
             print("R1 OFF")
          end
     end
    ButtonState_old1 = ButtonState1
end)
timerR1:start()

timerR2 = tmr.create()
timerR2:register(100, tmr.ALARM_AUTO, function ()
    local ButtonState2 = gpio.read(BUT_PIN2)
    -- Нажатие кнопки (задний фронт на gpio0)
    if (ButtonState2 == 0) and (ButtonState_old2 == 1) then
          if gpio.read(REL_PIN2) == 1 then
             gpio.write(REL_PIN2,gpio.LOW)
             print("R2 ON")
            else
             gpio.write(REL_PIN2,gpio.HIGH)
             print("R2 OFF")
          end
     end
    ButtonState_old2 = ButtonState2
end)
timerR2:start()

timerR3 = tmr.create()
timerR3:register(100, tmr.ALARM_AUTO, function ()
    local ButtonState3 = gpio.read(BUT_PIN3)
    -- Нажатие кнопки (задний фронт на gpio0)
    if (ButtonState3 == 0) and (ButtonState_old3 == 1) then
          if gpio.read(REL_PIN3) == 1 then
             gpio.write(REL_PIN3,gpio.LOW)
             print("R3 ON")
            else
             gpio.write(REL_PIN3,gpio.HIGH)
             print("R3 OFF")
          end
     end
    ButtonState_old3 = ButtonState3
end)
timerR3:start()

timerR4 = tmr.create()
timerR4:register(100, tmr.ALARM_AUTO, function ()

    local ButtonState4 = gpio.read(BUT_PIN4)
    -- Нажатие кнопки (задний фронт на gpio0)
    if (ButtonState4 == 0) and (ButtonState_old4 == 1) then
          if gpio.read(REL_PIN4) == 1 then
             gpio.write(REL_PIN4,gpio.LOW)
             print("R4 ON")
            else
             gpio.write(REL_PIN4,gpio.HIGH)
             print("R4 OFF")
          end
     end
    ButtonState_old4 = ButtonState4
end)
timerR4:start()
------------------------------------------------------------------------------

mytimer = tmr.create()
mytimer:register(1000, tmr.ALARM_AUTO, function ()
if mqttFlag == 0 then   -- если нет подключения к брокеру
    m = mqtt.Client(MQTT_ClientID, 120, "user", "password")
    m:on("connect", function(client) print ("connected") end)
    m:on("offline", function(client)    
        print ("offline")
        mqttFlag = 0
    end)
    -- on publish message receive event
    m:on("message", function(client, topic, data) 
                if (topic == "/ESP04/R1") and (tonumber(data) == 0) then
                    gpio.write(REL_PIN1,gpio.HIGH)
                    print("R1 ВЫКЛ сверху")
                end
                
                if (topic == "/ESP04/R1") and (tonumber(data) == 1) then
                    gpio.write(REL_PIN1,gpio.LOW)
                    print("R1 ВКЛ сверху")
                end
                
                if (topic == "/ESP04/R2") and (tonumber(data) == 0) then
                    gpio.write(REL_PIN2,gpio.HIGH)
                    print("R2 ВЫКЛ сверху")
                end
                
                if (topic == "/ESP04/R2") and (tonumber(data) == 1) then
                    gpio.write(REL_PIN2,gpio.LOW)
                    print("R2 ВКЛ сверху")
                end

                if (topic == "/ESP04/R3") and (tonumber(data) == 0) then
                    gpio.write(REL_PIN3,gpio.HIGH)
                    print("R3 ВЫКЛ сверху")
                end
                
                if (topic == "/ESP04/R3") and (tonumber(data) == 1) then
                    gpio.write(REL_PIN3,gpio.LOW)
                    print("R3 ВКЛ сверху")
                end
                
                if (topic == "/ESP04/R4") and (tonumber(data) == 0) then
                    gpio.write(REL_PIN4,gpio.HIGH)
                    print("R4 ВЫКЛ сверху")
                end
                
                if (topic == "/ESP04/R4") and (tonumber(data) == 1) then
                    gpio.write(REL_PIN4,gpio.LOW)
                    print("R4 ВКЛ сверху")
                end
                end)
    m:on("overflow", function(client, topic, data)
      print(topic .. " partial overflowed message: " .. data )
    end)
    m:connect(MQTT_BrokerIP, MQTT_BrokerPort, 0, function(client)
      print("connected")
      mqttFlag = 1
      cnt = 0
      -- subscribe topic with qos = 0
      client:subscribe({["/ESP04/R1"]=0,
                        ["/ESP04/R2"]=0,
                        ["/ESP04/R3"]=0,
                        ["/ESP04/R4"]=0,}, function(client) print("subscribe success") end)
      -- publish a message with data = hello, QoS = 0, retain = 0
      -- client:publish("/ESP03/", "hello", 0, 0, function(client) print("ESP03 на связи") end)
    end,
    function(client, reason)
      mqttFlag = 0
      cnt = cnt + 1
      print("failed reason: " .. reason)
    end)
    else    -- если подключен к брокеру
-----------------------------------------------
    local RelState1 = gpio.read(REL_PIN1)
    if (RelState1 == 1) and (RelState_old1 == 0) then
             m: publish("/ESP04/R1",0,0,0)
     end

     if (RelState1 == 0) and (RelState_old1 == 1) then
             m: publish("/ESP04/R1",1,0,0)
     end
     RelState_old1 = RelState1
---------------------------------------------
    local RelState2 = gpio.read(REL_PIN2)
    if (RelState2 == 1) and (RelState_old2 == 0) then
             m: publish("/ESP04/R2",0,0,0)
     end

     if (RelState2 == 0) and (RelState_old2 == 1) then
             m: publish("/ESP04/R2",1,0,0)
     end
     RelState_old2 = RelState2
---------------------------------------------
    local RelState3 = gpio.read(REL_PIN3)
    if (RelState3 == 1) and (RelState_old3 == 0) then
             m: publish("/ESP04/R3",0,0,0)
     end
     if (RelState3 == 0) and (RelState_old3 == 1) then
             m: publish("/ESP04/R3",1,0,0)
     end
     RelState_old3 = RelState3
-----------------------------------------------------
    local RelState4 = gpio.read(REL_PIN4)
    if (RelState4 == 1) and (RelState_old4 == 0) then
             m: publish("/ESP04/R4",0,0,0)
     end
     if (RelState4 == 0) and (RelState_old4 == 1) then
             m: publish("/ESP04/R4",1,0,0)
     end
     RelState_old4 = RelState4
end
end)
--mytimer:start()
Idletimer = tmr.create()
Idletimer:register(1000, tmr.ALARM_AUTO, function ()
    local myTimerFlag = 0
    if wifi.sta.status() == 5 and myTimerFlag == 0 then
        mytimer:start()
        myTimerFlag = 1
    end
    if cnt > 9 then
        mytimer:stop()
        myTimerFlag = 0
    end
    if wifi.sta.status() ~= 5 then
        cnt = 0
    end
end)
Idletimer:start()



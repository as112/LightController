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

if file.open("R1.txt", "r") then
    if(file.read() == '1') then
        RelState_old1 = 0
    else 
        RelState_old1 = 1
    end
    file.close()
end
if file.open("R2.txt", "r") then
    if(file.read() == '1') then
        RelState_old2 = 0
    else 
        RelState_old2 = 1
    end
    file.close()
end
if file.open("R3.txt", "r") then
    if(file.read() == '1') then
        RelState_old3 = 0
    else 
        RelState_old3 = 1
    end
    file.close()
end
if file.open("R4.txt", "r") then
    if(file.read() == '1') then
        RelState_old4 = 0
    else 
        RelState_old4 = 1
    end
    file.close()
end
print(RelState_old1..RelState_old2..RelState_old3..RelState_old4)

gpio.write(REL_PIN1,RelState_old1)
gpio.write(REL_PIN2,RelState_old2)
gpio.write(REL_PIN3,RelState_old3)
gpio.write(REL_PIN4,RelState_old4)

ButtonState_old1 = 0
ButtonState_old2 = 0
ButtonState_old3 = 0
ButtonState_old4 = 0

RState_old1 = RelState_old1
RState_old2 = RelState_old2
RState_old3 = RelState_old3
RState_old4 = RelState_old4


MQTT_BrokerIP = "mqtt.by"
MQTT_BrokerPort = 1883
MQTT_Client_user = "as112"
MQTT_Client_password = "etmpiqgu"
MQTT_ClientID = "esp-02"
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
save = tmr.create()
save:register(5000, tmr.ALARM_AUTO, function ()
    local RelState1 = gpio.read(REL_PIN1)
    if (RelState1 ~= RState_old1) then
        if file.open("R1.txt", "w+") then
            file.write(tostring(RState_old1))
            file.close()
        end
        RState_old1 = RelState1
    end

    local RelState2 = gpio.read(REL_PIN2)
    if (RelState2 ~= RState_old2) then
        if file.open("R2.txt", "w+") then
            file.write(tostring(RState_old2))
            file.close()
        end
        RState_old2 = RelState2
    end

    local RelState3 = gpio.read(REL_PIN3)
    if (RelState3 ~= RState_old3) then
        if file.open("R3.txt", "w+") then
            file.write(tostring(RState_old3))
            file.close()
        end
        RState_old3 = RelState3
    end

    local RelState4 = gpio.read(REL_PIN4)
    if (RelState4 ~= RState_old4) then
        if file.open("R4.txt", "w+") then
            file.write(tostring(RState_old4))
            file.close()
        end
        RState_old4 = RelState4
    end
    print(RState_old1..RState_old2..RState_old3..RState_old4)
end)
save:start()
------------------------------------------------------------------------------
mytimer = tmr.create()
mytimer:register(11000, tmr.ALARM_AUTO, function ()
if mqttFlag == 0 then   -- если нет подключения к брокеру
    m = mqtt.Client(MQTT_ClientID, 120, MQTT_Client_user, MQTT_Client_password)
    m:on("connect", function(client) print ("connected") end)
    m:on("offline", function(client)    
        print ("offline")
		mytimer:interval(11000)
        mqttFlag = 0
    end)
    -- on publish message receive event
    m:on("message", function(client, topic, data) 
                if (topic == "/user/as112/ESP02/R1/") and (tonumber(data) == 0) then
                    gpio.write(REL_PIN1,gpio.HIGH)
					m: publish("/user/as112/ESP02/R1/STATUS/",0,0,0)
                    print("R1 ВЫКЛ сверху")
                end
                
                if (topic == "/user/as112/ESP02/R1/") and (tonumber(data) == 1) then
                    gpio.write(REL_PIN1,gpio.LOW)
					m: publish("/user/as112/ESP02/R1/STATUS/",1,0,0)
                    print("R1 ВКЛ сверху")
                end
                
                if (topic == "/user/as112/ESP02/R2/") and (tonumber(data) == 0) then
                    gpio.write(REL_PIN2,gpio.HIGH)
					m: publish("/user/as112/ESP02/R2/STATUS/",0,0,0)
                    print("R2 ВЫКЛ сверху")
                end
                
                if (topic == "/user/as112/ESP02/R2/") and (tonumber(data) == 1) then
                    gpio.write(REL_PIN2,gpio.LOW)
					m: publish("/user/as112/ESP02/R2/STATUS/",1,0,0)
                    print("R2 ВКЛ сверху")
                end

                if (topic == "/user/as112/ESP02/R3/") and (tonumber(data) == 0) then
                    gpio.write(REL_PIN3,gpio.HIGH)
					m: publish("/user/as112/ESP02/R3/STATUS/",0,0,0)
                    print("R3 ВЫКЛ сверху")
                end
                
                if (topic == "/user/as112/ESP02/R3/") and (tonumber(data) == 1) then
                    gpio.write(REL_PIN3,gpio.LOW)
					m: publish("/user/as112/ESP02/R3/STATUS/",1,0,0)
                    print("R3 ВКЛ сверху")
                end
                
                if (topic == "/user/as112/ESP02/R4/") and (tonumber(data) == 0) then
                    gpio.write(REL_PIN4,gpio.HIGH)
					m: publish("/user/as112/ESP02/R4/STATUS/",0,0,0)
                    print("R4 ВЫКЛ сверху")
                end
                
                if (topic == "/user/as112/ESP02/R4/") and (tonumber(data) == 1) then
                    gpio.write(REL_PIN4,gpio.LOW)
					m: publish("/user/as112/ESP02/R4/STATUS/",1,0,0)
                    print("R4 ВКЛ сверху")
                end
                end)
    m:on("overflow", function(client, topic, data)
      print(topic .. " partial overflowed message: " .. data )
    end)
    m:connect(MQTT_BrokerIP, MQTT_BrokerPort, 0, function(client)
      print("connected")
      mytimer:interval(1000)
      mqttFlag = 1
      cnt = 0
      -- subscribe topic with qos = 0
      client:subscribe({["/user/as112/ESP02/R1/"]=0,
                        ["/user/as112/ESP02/R2/"]=0,
                        ["/user/as112/ESP02/R3/"]=0,
                        ["/user/as112/ESP02/R4/"]=0,}, function(client) print("subscribe success") end)
      -- publish a message with data = hello, QoS = 0, retain = 0
      -- client:publish("/ESP03/", "hello", 0, 0, function(client) print("ESP03 на связи") end)
    end,
    function(client, reason)
      mqttFlag = 0
      cnt = cnt + 1
      print("failed reason: " .. reason)
      mytimer:interval(11000)
      if (cnt == 25) then
        node.restart()
      end
    end)
else    -- если подключен к брокеру
-----------------------------------------------
    local RelState1 = gpio.read(REL_PIN1)
    if (RelState1 == 1) and (RelState_old1 == 0) then
             m: publish("/user/as112/ESP02/R1/STATUS/",0,0,0)
     end

     if (RelState1 == 0) and (RelState_old1 == 1) then
             m: publish("/user/as112/ESP02/R1/STATUS/",1,0,0)
     end
     RelState_old1 = RelState1
---------------------------------------------
    local RelState2 = gpio.read(REL_PIN2)
    if (RelState2 == 1) and (RelState_old2 == 0) then
             m: publish("/user/as112/ESP02/R2/STATUS/",0,0,0)
     end

     if (RelState2 == 0) and (RelState_old2 == 1) then
             m: publish("/user/as112/ESP02/R2/STATUS/",1,0,0)
     end
     RelState_old2 = RelState2
---------------------------------------------
    local RelState3 = gpio.read(REL_PIN3)
    if (RelState3 == 1) and (RelState_old3 == 0) then
             m: publish("/user/as112/ESP02/R3/STATUS/",0,0,0)
     end
     if (RelState3 == 0) and (RelState_old3 == 1) then
             m: publish("/user/as112/ESP02/R3/STATUS/",1,0,0)
     end
     RelState_old3 = RelState3
-----------------------------------------------------
    local RelState4 = gpio.read(REL_PIN4)
    if (RelState4 == 1) and (RelState_old4 == 0) then
             m: publish("/user/as112/ESP02/R4/STATUS/",0,0,0)
     end
     if (RelState4 == 0) and (RelState_old4 == 1) then
             m: publish("/user/as112/ESP02/R4/STATUS/",1,0,0)
     end
     RelState_old4 = RelState4
end
end)
mytimer:start()

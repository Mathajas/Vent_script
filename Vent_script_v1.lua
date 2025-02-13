--[[
# **Description:** This dzVents script intelligently manages a device named "Fun" in Domoticz, using humidity sensor readings to control its operation.
# **Ispired by:** https://wiki.domoticz.com/Humidity_control
# **Functionality:**
# The script continuously monitors humidity levels from specified humidity sensors.
# Based on these readings, it automatically adjusts the state of the "Fun" device (e.g., turns it on or off).

# **Potential Use Cases:**
# This script enables humidity-controlled automation for the "Fun" device, which could be:
# - **Dehumidifier Control:** Activates a dehumidifier ("Fun" device) when humidity levels are high.
# - **Humidifier Control:** Activates a humidifier ("Fun" device) when humidity levels are low.
# - **Ventilation Control:** Activates a fan ("Fun" device) based on humidity to improve air circulation.

# **Customization:**
# To adapt this script to your specific setup:
# 1. **Device Name:** Replace '"Fun"' with the actual name of your controllable device in Domoticz.
# 2. **Humidity Sensors:** Specify the names of your humidity sensors within the `HUMIDITY_SENSOR_NAMES` table in the script.
# 3. **Thresholds and Actions:**  Adjust humidity thresholds (e.g., `TARGET_HUM`, `HUMIDITY_DELTA`) and actions (e.g., `fan.switchOn()`, `fan.switchOff()`) to match your desired behavior and the function of your "Fun" device.

# **Further Information:**
# For detailed setup and usage instructions, please refer to the README file in the Git repository associated with this script.
]]--

return {
    on = {
        timer = { 'every minute' } -- Trigger the script to run every minute
        
    },
    data = {
        lastHumidity = { initial = 0 },        
        lastHumidity1min = { initial = 0 },     
        lastRunTime = { initial = 0 },         
        lastHumidityUpdate = { initial = 0 },    
        Fan_turn_on_in_min = { initial = 0 },   
        canRunAgain = { initial = 1 }
    },
    execute = function(domoticz)
        local FAN_NAME = 'Wentylator'                                           -- Name of the Domoticz device that controls the fan (replace 'Wentylator' with your fan device name)
        local HUMIDITY_SENSOR_NAMES = { '9A2CBF ATC-hum', '834A61 ATC-hum' }    -- Array of humidity sensor device names in Domoticz
        local TARGET_HUM = 65                                                   -- Target humidity level (%) - fan will turn on if humidity exceeds this value
        local FAN_MAX_TIME = 30                                                 -- Maximum fan run time in minutes in a single cycle
        local BREAK_TIME = 10                                                   -- Minimum break time (in minutes) before the fan can be turned on again after a cycle
        local HOURLY_VENT_DURATION = 5                                          -- Duration (in minutes) of the hourly ventilation cycle
        local HUMIDITY_DELTA = 5                                                -- Humidity increase threshold (%) to trigger immediate fan activation
        local HUMIDITY_DELTA_FUN_TIME = 10                                      -- Fan run time (in minutes) when a rapid humidity increase is detected
        local HUMIDITY_UPDATE_INTERVAL = 300                                    -- Interval (in seconds) for updating the `lastHumidity` history variable (5 minutes)

        -- Function to calculate the average humidity from the specified sensors
        local function getAverageHumidity()
            local sum, count = 0, 0
            for _, sensor in ipairs(HUMIDITY_SENSOR_NAMES) do     
                local value = domoticz.devices(sensor) and domoticz.devices(sensor).humidity or 0
                if value > 0 then
                    sum = sum + value                             
                    count = count + 1                             
                end
            end
            return count > 0 and (sum / count) or 0
        end

        local current_humidity = getAverageHumidity()             
        local currentTime = os.time()                            
        local lastRunTime = domoticz.data.lastRunTime or 0              
        local lastHumidity = domoticz.data.lastHumidity or 0        
        local lastHumidity1min = domoticz.data.lastHumidity1min or 0   
        local lastHumidityUpdate = domoticz.data.lastHumidityUpdate 
        local canRunAgain = (currentTime - lastRunTime) >= (BREAK_TIME * 60)    -- Check if enough break time has passed since the last fan run
        local Fan_turn_on_in_min = domoticz.data.Fan_turn_on_in_min or 0

        
        -- Debug logging to track the 'Fun_turn_on_in_min' value before script logic
        domoticz.log('Fun time before script:' .. Fan_turn_on_in_min .. ' minutes.', domoticz.LOG_INFO)

        -- Update humidity history every 5 minutes
        if (currentTime - lastHumidityUpdate) >= HUMIDITY_UPDATE_INTERVAL then
            lastHumidity = lastHumidity1min                                                         -- Update the 5-minute humidity history with the last 1-minute value
            domoticz.log('Humidity every 5 min:' .. current_humidity .. '%', domoticz.LOG_STATUS) -- Optional: Log humidity every 5 minutes to Domoticz status
            domoticz.data.lastHumidityUpdate = currentTime                                          -- Update the timestamp of the last humidity history update
        end


        -- Humidity-based logic to control fan run time
        if current_humidity > TARGET_HUM then                                           -- If current humidity is above the target
            Fan_turn_on_in_min = math.min(FAN_MAX_TIME, Fan_turn_on_in_min + 5)         -- Increase fan run time by 5 minutes, up to FAN_MAX_TIME
        elseif Fan_turn_on_in_min > 0 then                                              -- If fan is currently scheduled to run (Fan_turn_on_in_min > 0) and humidity is not high
            Fan_turn_on_in_min = math.max(0, Fan_turn_on_in_min - 1)                    -- !!!!! Decrease fan run time by 1 minute (gradually reducing run time if humidity drops)
        end

        -- Detect rapid humidity increase
        if (lastHumidity == 0 ) then                               -- Handle initial run where lastHumidity is not yet set
            lastHumidity = current_humidity                        -- Initialize lastHumidity with current humidity on first run
        end
        if (current_humidity - lastHumidity) >= HUMIDITY_DELTA and ( current_humidity > lastHumidity1min ) then     -- If humidity increased significantly since last 5-min update and is higher than last minute
            Fan_turn_on_in_min = HUMIDITY_DELTA_FUN_TIME                                                            
            domoticz.log('Rapid humidity increase detected! Turning on fan.', domoticz.LOG_INFO)                    
        end

        -- Hourly ventilation logic
        if domoticz.time.minutes == 0 and ( Fan_turn_on_in_min < HOURLY_VENT_DURATION ) and canRunAgain then            -- If it's the start of the hour, fan run time is less than hourly duration, and break time has passed  
            Fan_turn_on_in_min = HOURLY_VENT_DURATION
            domoticz.log('Hourly vent, Turning on fan.', domoticz.LOG_INFO) 
        end
        
        -- Fan control logic: Turn fan on or off based on 'Fan_turn_on_in_min'
        local fan = domoticz.devices(FAN_NAME)  
        --domoticz.log('current_humidity: ' .. tostring(current_humidity), domoticz.LOG_INFO)
        --domoticz.log('lastHumidity: ' .. tostring(lastHumidity), domoticz.LOG_INFO)
        --domoticz.log('lastHumidity1min: ' .. tostring(lastHumidity1min), domoticz.LOG_INFO)
        --domoticz.log('Fan_turn_on_in_min: ' .. tostring(Fan_turn_on_in_min), domoticz.LOG_INFO)
        --domoticz.log('canRunAgain: ' .. tostring(canRunAgain), domoticz.LOG_INFO)
        --domoticz.log('domoticz.time.minutes: ' .. tostring(domoticz.time.minutes), domoticz.LOG_INFO)
        --domoticz.log('fan: ' .. tostring(fan), domoticz.LOG_INFO)
        --domoticz.log('fan.state: ' .. tostring(fan.state), domoticz.LOG_INFO)
        if Fan_turn_on_in_min > 0 and fan.state == 'Off' then                                           -- If fan run time is positive and fan is currently off
            fan.switchOn().forMin(Fan_turn_on_in_min)                                                   -- Turn the fan on for 'Fan_turn_on_in_min' minutes
            domoticz.data.lastRunTime = currentTime                                                     
            domoticz.log('Turning on fan for ' .. Fan_turn_on_in_min .. ' minutes.', domoticz.LOG_INFO) 
        elseif Fan_turn_on_in_min <= 0 and fan.state == 'On' then                                       -- If fan run time is zero or negative and fan is currently on
            fan.switchOff()                                                                             
            domoticz.log('Turning off fan.', domoticz.LOG_INFO)                                         
        end
        -- Update history of 1 min
        lastHumidity1min = current_humidity                     
        domoticz.log('Fun Timer:' .. Fan_turn_on_in_min .. ' minutes.' , domoticz.LOG_INFO)             -- Debug logging to track 'Fun_turn_on_in_min' after script logic
        -- Save updated variables to script data
        domoticz.data.Fan_turn_on_in_min = Fan_turn_on_in_min                                           -- Store the updated fan run time
        domoticz.data.lastHumidity = lastHumidity                                                       -- Store the updated 5-minute humidity history
        domoticz.data.lastHumidity1min = lastHumidity1min                                               -- Store the updated 1-minute humidity value
    end
}

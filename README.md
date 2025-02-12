# Vent_script
Domoticz dzVents script controlling Fun, using humidity sensors
**Short Description for GIT:**

dzVents script for Domoticz to control a device (e.g., fan, dehumidifier, humidifier) based on humidity sensor readings. Includes features like target humidity control, rapid humidity increase detection, and hourly ventilation.

**Readme Content for GIT:**

# Domoticz dzVents Humidity-Based "Fun" Device Controller

## Description

This dzVents script for Domoticz is designed to intelligently manage a device, referred to as "Fun" in the script (you should replace this with your actual device name), based on readings from one or more humidity sensors.  It allows for automated control of ventilation, dehumidification, humidification, or other functions based on humidity levels in your environment.

The script continuously monitors the average humidity reported by your specified sensors. It then dynamically adjusts the on/off state and run duration of the "Fun" device according to configurable parameters and detected humidity changes.
**Ispired by:** https://wiki.domoticz.com/Humidity_control

## Features

*   **Humidity-Based Control:**  Turns on the "Fun" device when humidity exceeds a set target (`TARGET_HUM`).
*   **Gradual Run Time Adjustment:** Increases the "Fun" device run time incrementally when humidity is high and decreases it when humidity is low, providing smooth and responsive control.
*   **Rapid Humidity Increase Detection:**  Immediately activates the "Fun" device for a set duration (`HUMIDITY_DELTA_FUN_TIME`) upon detecting a rapid rise in humidity (`HUMIDITY_DELTA`), useful for quickly addressing sudden humidity spikes (e.g., after a shower).
*   **Hourly Ventilation:**  Provides a configurable hourly ventilation cycle (`HOURLY_VENT_DURATION`) to ensure regular air circulation, even if humidity levels are not continuously high.
*   **Configurable Parameters:**  Easily customize device names, humidity sensor names, target humidity, run times, break times, and humidity thresholds through script variables.
*   **Break Time Enforcement:**  Implements a `BREAK_TIME` to prevent excessive cycling of the "Fun" device, ensuring a minimum off-time between operations.
*   **Logging:**  Provides informative logging to Domoticz logs for debugging and monitoring script behavior.

## Prerequisites

*   Domoticz home automation system installed and configured.
*   dzVents plugin enabled in Domoticz.
*   One or more humidity sensors integrated with Domoticz.
*   A controllable device in Domoticz that you wish to manage based on humidity (e.g., fan, dehumidifier, humidifier).

## Setup and Configuration

1.  **Install dzVents:** If you haven't already, ensure the dzVents plugin is enabled in your Domoticz installation.

2.  **Create a dzVents Script:**
    *   In Domoticz, navigate to:  **Setup** -> **More Options** -> **Events**.
    *   Click the **dzVents** tab.
    *   Create a new dzVents script (e.g., "Lua").
    *   Copy and paste the provided script code into the script editor.
    *   Click the "Off" and then the "Save" button in the dzVents script editor.
  
3.  **Create user Variables:**  Click **Setup** -> **More Options** -> **User Variables**:
      Fan_turn_on_in_min, value 0
      lastHumidity, value 0
      lastHumidity1min, value 0
      lastRunTime, value 0
      lastHumidityUpdate, value 0

5.  **Customize the Script:**
    *   **`FAN_NAME`:**  Change `'Wentylator'` to the exact name of your controllable device as it appears in Domoticz.
    *   **`HUMIDITY_SENSOR_NAMES`:**  Modify the array `{'9A2CBF ATC-hum', '834A61 ATC-hum'}` to include the names of your humidity sensors in Domoticz. You can add or remove sensor names as needed. Ensure the names match exactly.
    *   **`TARGET_HUM`:** Adjust the target humidity level (default: `65`). The "Fun" device will activate when the average humidity exceeds this percentage.
    *   **`FAN_MAX_TIME`:** Set the maximum run time for the "Fun" device in minutes during a single activation cycle (default: `30`).
    *   **`BREAK_TIME`:**  Configure the minimum break time in minutes before the "Fun" device can be reactivated after running (default: `10`).
    *   **`HOURLY_VENT_DURATION`:**  Set the duration in minutes for the hourly ventilation cycle (default: `5`). Set to `0` to disable hourly ventilation.
    *   **`HUMIDITY_DELTA`:** Define the percentage increase in humidity within a 5-minute interval that triggers rapid humidity increase detection (default: `5`).
    *   **`HUMIDITY_DELTA_FUN_TIME`:** Set the run time in minutes for the "Fun" device when a rapid humidity increase is detected (default: `10`).
    *   **`HUMIDITY_UPDATE_INTERVAL`:**  Interval in seconds for updating the humidity history (default: `300` seconds = 5 minutes).  Generally, you should not need to change this.

6.  **Save the Script:**  Click the "Save" button in the dzVents script editor.


## Contributing

Contributions to improve this script are welcome! Please feel free to fork this repository, make your changes, and submit a pull request.

## License

MIT License

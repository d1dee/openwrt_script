#/bin/sh

# Wait 2 minutes, restart wifi; wait another 2 minutes, restart network; if another 2 minutes and no connected devices, restart router

WAIT_TIME_WIFI=10
WAIT_TIME_NETWORK=10
WAIT_TIME_REBOOT=10
SLEEP_TIMER=5

echo $WAIT_TIME

connectedDevices="0"

# Function to check if there are connected devices

function ConnectedDevices {
   connectedDevices=$(iwinfo wlan0 assoclist | grep -cE "^[0-9a-fA-F:]{17}")   
}

# Check if there are connected devices

ConnectedDevices


if [ "$connectedDevices" = "0" ]; then
    echo "No devices connected, waiting for $WAIT_TIME_WIFI seconds before restarting wlan"
    sleep $WAIT_TIME_WIFI
    ConnectedDevices
      if [ "$connectedDevices" = "0" ]; then
         echo "No device(s) connected for $WAIT_TIME_WIFI seconds. Restarting Wi-Fi..."
         wifi down
         echo "Wi-fi down for $SLEEP_TIMER seconds..."
         sleep $SLEEP_TIMER
         wifi up
         echo "Wi-fi is now up"
         sleep $WAIT_TIME_NETWORK
         ConnectedDevices
           if [ "$connectedDevices" = "0" ]; then
             echo "No device(s) connected after $WAIT_TIME_NETWORK seconds. Restarting NETWORK..."
             /etc/init.d/network restart
             echo "Network restarted"
             sleep $WAIT_TIME_REBOOT
             ConnectedDevices
               if [ "$connectedDevices" = "0" ]; then
                   echo "No device(s) connected after $WAIT_TIME_REBOOT seconds. Rebooting device..."
                   reboot
              else
                    echo "$connectedDevices device(s) are now connected."
              fi
            else
                echo "$connectedDevices device(s) are now connected."
            fi
      else
        echo "$connectedDevices device(s) are now connected."
      fi
  else
    echo "$connectedDevices device(s) are already connected."
fi
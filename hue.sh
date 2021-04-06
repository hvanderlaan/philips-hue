#!/bin/bash

# hue.sh: script for interacting with the philips hue light.
# 
# author  : Harald van der Laan
# version : v0.7.1
# date    : 06/04/2021
#
# inplemented features:
# - powering a hue lightbulb or group
# - changing the saturation of the lightbulb or group
# - changing the brightness of the lightbulb or group
# - changing the hue of a lightbulb or group
# - changing the xy gamut of a lightbulb or group
# - changing the ct temperature of a lightbulb or group
# - demo the colors of the hue system
#
# usage: 	hue.sh <light|group> <number> <action> <value> [<value>]
# power usage:	hue.sh light 1 state <on|off>
# saturation :	hue.sh light 1 sat <0-255>
# brightness :	hue.sh light 1 bri <0-255>
# hue        :	hue.sh light 1 hue <0-65535>
# xy	     :	hue.sh light 1 xy <0.0-1.0> <0.0-1.0>
# ct         :	hue.sh light 1 ct <153-500>
#
# changelog:
# - v0.1		(initial release)			(HLA)
#
# - v0.2		Added hue cycle mode, this will cycle
#			through the color spectrum of the hue
#			lightbulb or group			(HLA)
#
# - v0.3		Added xy gamut change option. for more
#			info about gamut please go to the hue
#			api development page.			(HLA)
#
# - v0.3.1		Added extra check for curl package	(HLA)
#
# - v0.4		Added ct (color temperature)		(HLA)
#
# - v0.5		Fixed hueJsonData layout and redirect
#			curl output > /dev/nulll
#
# - v0.5.1		Changed brightness setting in cycle	(HLA)
#
# - v0.6.0		Added huePort for enter a no standard
#			port for the hue bridge			(HLA)
#
# - v0.7.0		Updated groups API route		(JJW)
#
# - v0.7.1		Added list of all lights and groups	(JJW)

# global variables
hueBridge=''
huePort='80'
hueApiHash=''
hueBaseUrl="http://${hueBridge}:${huePort}/api/${hueApiHash}"
hueTimeOut='5'

# functions
function usage() {
	echo ""
	echo "Usage:            hue.sh <light|group> <number> <action> <value> [<value>]"
	echo "=========================================================================="
	echo "power usage    :  hue.sh light 1 state <on|off>"
	echo "saturation     :  hue.sh light 1 sat <0-255>"
	echo "brightness     :  hue.sh light 1 bri <0-255>"
	echo "hue            :  hue.sh light 1 hue <0-65535>"
	echo "xy gamut       :  hue.sh light 1 xy <0.0-1.0> <0.0-1.0>"
	echo "ct color temp  :  hue.sh light 1 ct <153-500>"
	echo "color cycle    :  hue.sh light 1 cycle <0-65535> <0-65535>"
	echo ""	
	echo "Lights/Groups"
	echo "=========================================================================="
	if [[ $hueApiHash == "" ]]; then
		echo "[-] Hue: Failed to get IDs from API! Please edit your global variabales"
		exit 1
	fi
	curl -S --max-time ${hueTimeOut} --silent --request GET ${hueBaseUrl}/lights | jq -r 'keys[] as $k | "Light \($k)        :  \(.[$k] | .name)"'
	curl -S --max-time ${hueTimeOut} --silent --request GET ${hueBaseUrl}/groups | jq -r 'keys[] as $k | "Group \($k)        :  \(.[$k] | .name)"'
	echo ""
	exit 1
}

function huePower() {
	local hueType=${1}
	local hueTypeNumber=${2}
	local hueState=${3}

	if [[ ${hueTypeNumber} != *[[:digit:]]* ]]; then
		echo "[-] Hue: ${hueType} number: ${hueTypeNumber} is not a number."
		exit 1
	fi
	
	case ${hueType} in
		light) hueUrl="${hueBaseUrl}/lights/${hueTypeNumber}/state" ;;
		group) hueUrl="${hueBaseUrl}/groups/${hueTypeNumber}/action" ;;
		*) echo "[-] Hue: The hue device mode is not light or group."; exit 1 ;;
	esac
	
	case ${hueState} in
		on) hueJsonData='{"on":true}' ;;
		off) hueJsonData='{"on":false}' ;;
		*) echo "[-] Hue: The hue state can only be on or off."; exit 1 ;;
	esac
	
	curl --max-time ${hueTimeOut} --silent --request PUT --data ${hueJsonData} ${hueUrl} &> /dev/null
	
	if [ ${?} -ne 0 ]; then
		echo "[-] Hue: Failed to send power command to ${hueType}/${hueTypeNumber}."
		exit 1
	fi

	echo "[+] Hue: Power command send successfully to ${hueType}/${hueTypeNumber}."
}

function hueSaturation() {
	local hueType=${1}
	local hueTypeNumber=${2}
	local hueState=${3}
	
	if [[ ${hueTypeNumber} != *[[:digit:]]* ]]; then 
                echo "[-] Hue: ${hueType} number: ${hueTypeNumber} is not a number."
                exit 1
        fi
	
	case ${hueType} in
                light) hueUrl="${hueBaseUrl}/lights/${hueTypeNumber}/state" ;;
                group) hueUrl="${hueBaseUrl}/groups/${hueTypeNumber}/action" ;;
                *) echo "[-] Hue: The Hue device mode is not light or group."; exit 1 ;;
        esac
	
	if [[ ${hueState} != *[[:digit:]]* ]]; then
		echo "[-] Hue: Saturation value: ${hueState} is not a number."
		exit 1
	fi 

	if [ ${hueState} -lt 0 -o ${hueState} -gt 255 ]; then
		echo "[-] Hue: Saturation value must be between 0 and 255."
		exit 1
	fi
	
	curl --max-time ${hueTimeOut} --silent --request PUT --data '{"sat":'${hueState}'}' ${hueUrl} &> /dev/null
	
	if [ ${?} -ne 0 ]; then
		echo "[-] Hue: Failed to send saturation command to ${hueType}/${hueTypeNumber}."
		exit 1
	fi
	
	echo "[+] Hue: Saturation command send successfully to ${hueType}/${hueTypeNumber}."
}

function hueBrightness() {
        local hueType=${1}
        local hueTypeNumber=${2}
        local hueState=${3}

        if [[ ${hueTypeNumber} != *[[:digit:]]* ]]; then 
                echo "[-] Hue: ${hueType} number: ${hueTypeNumber} is not a number."
                exit 1
        fi

        case ${hueType} in
                light) hueUrl="${hueBaseUrl}/lights/${hueTypeNumber}/state" ;;
                group) hueUrl="${hueBaseUrl}/groups/${hueTypeNumber}/action" ;;
                *) echo "[-] Hue: The Hue device mode is not light or group."; exit 1 ;;
        esac

	if [[ ${hueState} != *[[:digit:]]* ]]; then
                echo "[-] Hue: Brightness value: ${hueState} is not a number."
                exit 1
        fi

        if [ ${hueState} -lt 0 -o ${hueState} -gt 255 ]; then
                echo "[-] Hue: Brightness value must be between 0 and 255."
                exit 1
        fi

        curl --max-time ${hueTimeOut} --silent --request PUT --data '{"bri":'${hueState}'}' ${hueUrl} &> /dev/null

        if [ ${?} -ne 0 ]; then
                echo "[-] Hue: Failed to send brightness command to ${hueType}/${hueTypeNumber}."
                exit 1
        fi

        echo "[+] Hue: Brightness command send successfully to ${hueType}/${hueTypeNumber}."
}

function hueHue() {
        local hueType=${1}
        local hueTypeNumber=${2}
        local hueState=${3}

        if [[ ${hueTypeNumber} != *[[:digit:]]* ]]; then 
                echo "[-] Hue: ${hueType} number: ${hueTypeNumber} is not a number."
                exit 1
        fi

        case ${hueType} in
                light) hueUrl="${hueBaseUrl}/lights/${hueTypeNumber}/state" ;;
                group) hueUrl="${hueBaseUrl}/groups/${hueTypeNumber}/action" ;;
                *) echo "[-] Hue: The Hue device mode is not light or group."; exit 1 ;;
        esac
	
	if [[ ${hueState} != *[[:digit:]]* ]]; then
                echo "[-] Hue: Hue value: ${hueState} is not a number."
                exit 1
        fi

        if [ ${hueState} -lt 0 -o ${hueState} -gt 65535 ]; then
                echo "[-] Hue: Hue value must be between 0 and 65535."
                exit 1
        fi

        curl --max-time ${hueTimeOut} --silent --request PUT --data '{"hue":'${hueState}'}' ${hueUrl} &> /dev/null

        if [ ${?} -ne 0 ]; then
                echo "[-] Hue: Failed to send hue command to ${hueType}/${hueTypeNumber}."
                exit 1
        fi

        echo "[+] Hue: Hue command send successfully to ${hueType}/${hueTypeNumber}."
}

function hueXy() {
	local hueType=${1}
        local hueTypeNumber=${2}
        local hueState1=${3}
        local hueState2=${4}

	if [[ ${hueTypeNumber} != *[[:digit:]]* ]]; then
                echo "[-] Hue: ${hueType} number: ${hueTypeNumber} is not a number."
                exit 1
        fi

        case ${hueType} in
                light) hueUrl="${hueBaseUrl}/lights/${hueTypeNumber}/state" ;;
                group) hueUrl="${hueBaseUrl}/groups/${hueTypeNumber}/action" ;;
                *) echo "[-] Hue: The xy device mode is not light or group."; exit 1 ;;
        esac

        if [[ ${hueState1} != *[[:digit:]]* ]]; then
                echo "[-] Hue: Xy value1: ${hueState1} is not a number."
                exit 1
        fi

        if [[ ${hueState2} != *[[:digit:]]* ]]; then
                echo "[-] Hue: Xy value2: ${hueState2} is not a number."
                exit 1
        fi	
	
	if (( $(bc <<< "${hueState1} <= 0") == 1 )) || (( $(bc <<< "${hueState1} >= 1") == 1 )); then
		echo "[-] Hue: Xy value1 must be between 0.0 and 1.0."
		exit 1
	fi
	
	if (( $(bc <<< "${hueState2} <= 0") == 1 )) || (( $(bc <<< "${hueState2} >= 1") == 1 )); then
                echo "[-] Hue: Xy value2 must be between 0.0 and 1.0."
                exit 1
        fi

	curl --max-time ${hueTimeOut} --silent --request PUT --data '{"xy":['${hueState1}','${hueState2}']}' ${hueUrl} &> /dev/null
	
	if [ ${?} -ne 0 ]; then
		echo "[-] Hue: Failed to send xy command to ${hueType}/${hueTypeNumber}."
                exit 1
        fi

        echo "[+] Hue: Xy command send successfully to ${hueType}/${hueTypeNumber}." 
}

function hueCt() {
	local hueType=${1}
        local hueTypeNumber=${2}
        local hueState=${3}

        if [[ ${hueTypeNumber} != *[[:digit:]]* ]]; then
                echo "[-] Hue: ${hueType} number: ${hueTypeNumber} is not a number."
                exit 1
        fi

        case ${hueType} in
                light) hueUrl="${hueBaseUrl}/lights/${hueTypeNumber}/state" ;;
                group) hueUrl="${hueBaseUrl}/groups/${hueTypeNumber}/action" ;;
                *) echo "[-] Hue: The Hue device mode is not light or group."; exit 1 ;;
        esac

        if [[ ${hueState} != *[[:digit:]]* ]]; then
                echo "[-] Hue: Ct  value: ${hueState} is not a number."
                exit 1
        fi

        if [ ${hueState} -lt 153 -o ${hueState} -gt 500 ]; then
                echo "[-] Hue: Ct value must be between 0 and 255."
                exit 1
        fi

        curl --max-time ${hueTimeOut} --silent --request PUT --data '{"ct":'${hueState}'}' ${hueUrl} &> /dev/null

        if [ ${?} -ne 0 ]; then
                echo "[-] Hue: Failed to send ct command to ${hueType}/${hueTypeNumber}."
                exit 1
        fi

        echo "[+] Hue: Ct command send successfully to ${hueType}/${hueTypeNumber}."
}

function hueCycle() {
	local hueType=${1}
        local hueTypeNumber=${2}
        local hueState1=${3}
	local hueState2=${4}
	
	if [[ ${hueTypeNumber} != *[[:digit:]]* ]]; then
                echo "[-] Hue: ${hueType} number: ${hueTypeNumber} is not a number."
                exit 1
        fi

        case ${hueType} in
                light) hueUrl="${hueBaseUrl}/lights/${hueTypeNumber}/state" ;;
                group) hueUrl="${hueBaseUrl}/groups/${hueTypeNumber}/action" ;;
                *) echo "[-] Hue: The cycle device mode is not light or group."; exit 1 ;;
        esac

        if [[ ${hueState1} != *[[:digit:]]* ]]; then
                echo "[-] Hue: Cycle value1: ${hueState1} is not a number."
                exit 1
        fi
	
	if [[ ${hueState2} != *[[:digit:]]* ]]; then
                echo "[-] Hue: Cycle value2: ${hueState2} is not a number."
                exit 1
        fi
	
	if [ ${hueState1} -lt 0 -o ${hueState1} -gt 65535 ]; then
		echo "[-] Hue: Cycle value1 must be between 0 and 65535."
		exit 1
	fi
	
	if [ ${hueState2} -lt 0 -o ${hueState2} -gt 65535 ]; then
                echo "[-] Hue: Cycle value2 must be between 0 and 65535."
                exit 1
        fi
	
	if [ ${hueState1} -ge ${hueState2} ]; then
		echo "[-] Hue: Cycle value1 must be smaller then cycle value2."
		exit 1
	fi
	
	curl --max-time ${hueTimeOut} --silent --request PUT --data '{"on":true,"bri":254,"hue":54000,"sat":255}' ${hueUrl} &> /dev/null
	
	if [ ${?} -ne 0 ]; then
		echo "[-] Hue: Failed to send reset command to ${hueType}/${hueTypeNumber}."
	fi
	
	for (( hueValue=${hueState1}; hueValue<=${hueState2}; hueValue+=1000 )); do
		curl --max-time ${hueTimeOut} --silent --request PUT --data '{"hue":'${hueValue}'}' ${hueUrl} &> /dev/null
		
		if [ ${?} -ne 0 ]; then
			echo "[-] Hue: Failed to send cycle command to ${hueType}/${hueTypeNumber}, Hue is: ${hueValue}."
		else
			echo "[ ] Hue: Cycle command successfully send to ${hueType}/${hueTypeNumber}, Hue is: ${hueValue}."
		fi

		sleep 1
	done
}

# main script
if [ -z $(which jq) ]; then
        echo "[-] Hue: jq is not installed. This script needs jq to get the group or light id form the hue api."
        echo "[-] Hue: Please install jq and try again."
        exit 1
fi

if [ ${#} -lt 4 ]; then
	usage
fi

if [ -z $(which curl) ]; then
	echo "[-] Hue: curl is not installed. This script needs curl to communicate with the hue api."
	echo "[-] Hue: Please install curl and try again."
	exit 1
fi

hueDevice=${1}
hueDeviceNumber=${2}
hueDeviceAction=${3}
hueDeviceActionValue1=${4}
hueDeviceActionValue2=${5}

case ${hueDeviceAction} in
	state) huePower ${hueDevice} ${hueDeviceNumber} ${hueDeviceActionValue1} ;;
	sat) hueSaturation ${hueDevice} ${hueDeviceNumber} ${hueDeviceActionValue1} ;;
	bri) hueBrightness ${hueDevice} ${hueDeviceNumber} ${hueDeviceActionValue1} ;;
	hue) hueHue ${hueDevice} ${hueDeviceNumber} ${hueDeviceActionValue1} ;;
	xy) hueXy ${hueDevice} ${hueDeviceNumber} ${hueDeviceActionValue1} ${hueDeviceActionValue2} ;;
	ct) hueCt ${hueDevice} ${hueDeviceNumber} ${hueDeviceActionValue1} ;;
	cycle) hueCycle ${hueDevice} ${hueDeviceNumber} ${hueDeviceActionValue1} ${hueDeviceActionValue2} ;;
	*) usage ;;
esac

exit 0

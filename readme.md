# Philips Hue
Philips hue combines brilliant LED light with intuitive technology. Then puts it in the palm of your hand.

Together, the bulbs, the bridge and the app will change the way you use light. Forever. Experiment with shades of white, from invigorating blue/white to cozy yellow/white. Or play with all the colours in the spectrum.

hue can wake you up. Help protect your home. Relive your favourite memories. Improve your mood. Even keep you informed about the weather.

Not just stunning, hue is smart too. And it’s tailored for you.

## Philips Hue bash script
With this script you can interact with the Philips Hue lightbulb or Philips Hue LED strip. You can change the brightness, saturation and the hue of the lights, and create every color you desire.

    Usage:            hue.sh <light|group> <number> <action> <value> [<value>]
    ==========================================================================
    power usage    :  hue.sh light 1 state <on|off>
    saturation     :  hue.sh light 1 sat <0-255>
    brightness     :  hue.sh light 1 bri <0-255>
    hue            :  hue.sh light 1 hue <0-65535>
    xy             :  hue.sh light 1 xy <0.0-1.0> <0.0-1.0>
    ct             :  hue.sh light 1 ct <153-500>
    color cycle    :  hue.sh light 1 cycle <0-65535> <0-65535>
    
    Lights/Groups
    ==========================================================================
    Light 1        :  Tree Lamp
    Light 2        :  Home
    Group 1        :  Garden
    Group 2        :  Living room


## Installation
This script needs some modification to work for you. The only things you need to install/edit are:

    # install packages
        -   curl                    # for commmunication with the HUE HTTP API
        -   jp                      # to parse data from the API

    # global variables
    hueBridge='<ip-address>'        # this is the ip-address of the hue bridge
    hueApiHash='<api-hash>'        # this is you hue api hash.

Phillips HUE developer documentation: https://developers.meethue.com/develop/get-started-2/


    
   

# Philips Hue
Philips hue combines brilliant LED light with intuitive technology. Then puts it in the palm of your hand.

Together, the bulbs, the bridge and the app will change the way you use light. Forever. Experiment with shades of white, from invigorating blue/white to cozy yellow/white. Or play with all the colours in the spectrum.

hue can wake you up. Help protect your home. Relive your favourite memories. Improve your mood. Even keep you informed about the weather.

Not just stunning, hue is smart too. And it’s tailored for you.

## Philips Hue bash script
With this script you can interact with the Philips Hue lightbulb or Philips Hue LED strip. You can change the brightness, saturation and the hue of the ligh
ts, and create every color you desire.

    Usage:        hue.sh <light|group> <number> <state> <value> [<value>]
    =====================================================================
    power usage    :  hue.sh light 1 state <on|off>
    saturation     :  hue.sh light 1 sat <0-255>
    brightness     :  hue.sh light 1 bri <0-255>
    hue            :  hue.sh light 1 hue <0-65535>
    color cycle    :  hue.sh light 1 cycle <0-65535> <0-65535>

This script needs some modification to work for you. The only things you need to edit are:

    # global variables
    hueBridge='10.0.20.2'      # this is the ip-address of the hue bridge
    hueApiHash='huedeveloper'  # this is you hue api user.



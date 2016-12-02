#!/usr/bin/env bash
#Cascadia Now!
config="$HOME/.$(basename "${0}").conf"
touch "$config"
. "$config"


_lookup_devices(){
    OLDIFS="$IFS"
    device_list=("$(ffmpeg -hide_banner -f avfoundation -list_devices true -i "" -f null /dev/null 2>&1 | cut -d ' ' -f6- | sed -e                  '1,/AVFoundation audio devices:/d' | grep -v '^$'| tr '\n' ',' )")
    IFS=',' read -r -a DEVICES <<< "$device_list"
    IFS="$OLDIFS"
    
}

_master_gui(){
_lookup_devices    
gui_conf="
# Set transparency: 0 is transparent, 1 is opaque
*.transparency=0.95
# Set window title
*.title = Welcome to Skookum Player!
# intro text
intro.width = 300
intro.type = text
intro.text = hello
#Capture Device
device.type = popup
device.label = Select Audio Capture Device
device.option = ${DEVICES[0]}
device.option = ${DEVICES[1]}
device.option = ${DEVICES[2]}
device.option = ${DEVICES[3]}
device.default = "$device"
#Sample Rate
sample_rate.type = radiobutton
sample_rate.label = Select Sample Rate
sample_rate.option = 44.1 kHz
sample_rate.option = 48 kHz
sample_rate.option = 96 kHz
sample_rate.default = "$sample_rate"
#Bit Depth
bit_depth.type = radiobutton
bit_depth.label = Select Bit Depth
bit_depth.option = 16
bit_depth.option = 24
bit_depth.default = "$bit_depth"
#Cancel Button
cb.type = cancelbutton
cb.label = Cancel
"

pashua_configfile=`/usr/bin/mktemp /tmp/pashua_XXXXXXXXX`
echo "$gui_conf" > $pashua_configfile
pashua_run
rm $pashua_configfile
}
pashua_run() {
    # Wrapper function for interfacing to Pashua. Written by Carsten
    # Bluem <carsten@bluem.net> in 10/2003, modified in 12/2003 (including
    # a code snippet contributed by Tor Sigurdsson), 08/2004 and 12/2004.
    # Write config file

    # Find Pashua binary. We do search both . and dirname "$0"
    # , as in a doubleclickable application, cwd is /
    # BTW, all these quotes below are necessary to handle paths
    # containing spaces.
    bundlepath="Pashua.app/Contents/MacOS/Pashua"
    mypath=$(dirname "$0")
    for searchpath in "$mypath/Pashua" "$mypath/$bundlepath" "./$bundlepath" \
                      "/Applications/$bundlepath" "$HOME/Applications/$bundlepath"
    do
        if [ -f "$searchpath" -a -x "$searchpath" ] ; then
            pashuapath=$searchpath
            break
        fi
    done
    if [ ! "$pashuapath" ] ; then
        echo "Error: Pashua is used to edit vrecord options but is not found."
        if [[ "${pashuainstall}" = "" ]] ; then
            echo "Attempting to run: brew cask install pashua"
            if [[ "${pashuainstall}" != "Y" ]] ; then
                brew cask install pashua
                pashuainstall="Y"
                pashua_run
            else
                break 2
            fi
        fi
    else
        encoding=""
        # Get result
        result=`"$pashuapath" $encoding $pashua_configfile | sed 's/ /;;;/g'`

        # Parse result
        for line in $result ; do
            key=`echo $line | sed 's/^\([^=]*\)=.*$/\1/'`
            value=`echo $line | sed 's/^[^=]*=\(.*\)$/\1/' | sed 's/;;;/ /g'`
            varname=$key
            varvalue="$value"
            eval $varname='$varvalue'
        done
    fi
} # pashua_run()

_master_gui
{
    echo "device=\"$device\""
    echo "sample_rate=\"$sample_rate\""
    echo "bit_depth=\"$bit_depth\""
} > "$config"


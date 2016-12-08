#!/usr/bin/env bash
#Cascadia Now!
config="$HOME/.$(basename "${0}").conf"
touch "$config"
. "$config"



OPTIND=1
while getopts "ep" opt ; do
    case "${opt}" in
        e) runtype="edit";;
        p) runtype="passthrough";;
        *)
    esac
done

_lookup_devices(){
    OLDIFS="$IFS"
    device_list=("$(ffmpeg -hide_banner -f avfoundation -list_devices true -i "" -f null /dev/null 2>&1 | cut -d ' ' -f6- | sed -e                  '1,/AVFoundation audio devices:/d' | grep -v '^$'| tr '\n' ',' )")
    IFS=',' read -r -a DEVICES <<< "$device_list"
    IFS="$OLDIFS"
}
_lookup_sample_rate(){
    case "${1}" in
        "44.1 kHz")
        SAMPLE_RATE_NUMERIC="44100"
        ;;
        "48 kHz")
        SAMPLE_RATE_NUMERIC="48000"
        ;;
        "96 kHz")
        SAMPLE_RATE_NUMERIC="96000"
        ;;
    esac
}

_lookup_bit_depth(){
    case "${1}" in
        "16 bit")
        CODEC="pcm_s16le"
        ;;
        "24 bit")
       CODEC="pcm_s24le"
        ;;
    esac
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
device.default = "${device}"
#Sample Rate
sample_rate.type = radiobutton
sample_rate.label = Select Sample Rate
sample_rate.option = 44.1 kHz
sample_rate.option = 48 kHz
sample_rate.option = 96 kHz
sample_rate.default = "${sample_rate}"
#Bit Depth
bit_depth.type = radiobutton
bit_depth.label = Select Bit Depth
bit_depth.option = 16 bit
bit_depth.option = 24 bit
bit_depth.default = "${bit_depth}"
#Cancel Button
cb.type = cancelbutton
cb.label = Cancel
"

pashua_configfile=`/usr/bin/mktemp /tmp/pashua_XXXXXXXXX`
echo "${gui_conf}" > "${pashua_configfile}"
pashua_run
rm "${pashua_configfile}"
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
    mypath=$(dirname "${0}")
    for searchpath in "$mypath/Pashua" "$mypath/$bundlepath" "./$bundlepath" \
                      "/Applications/$bundlepath" "$HOME/Applications/$bundlepath"
    do
        if [ -f "$searchpath" -a -x "$searchpath" ] ; then
            pashuapath=$searchpath
            break
        fi
    done
    if [ ! "$pashuapath" ] ; then
        echo "Error: Pashua is not found."
                break 2
            fi
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
} # pashua_run()

if [ "${runtype}" = "edit" ] ; then
_master_gui

{
    echo "device=\"${device}\""
    echo "sample_rate=\"${sample_rate}\""
    echo "bit_depth=\"${bit_depth}\""
} > "${config}"
fi

if [ -n "${sample_rate}" ] ; then
    _lookup_sample_rate "${sample_rate}"
else 
    echo "Please Select Sample Rate"
    ## add options here later!!
fi
if [ -n "${bit_depth}" ] ; then
    _lookup_bit_depth  "${bit_depth}"
else 
    echo "Please Select Bit depth"
    ## add options here later!!
fi
if [ -n "${device}" ] ; then
    DEVICE_NUMBER=$(echo "${device}" | cut -c 2)
else 
    echo "Please Select Audio Capture Device"
    ## add options here later!!
fi



if [ "${runtype}" = "passthrough" ] ; then
    ffmpeg -f avfoundation -i "none:"${DEVICE_NUMBER}"" -f flac -ar 48000 - |\
    mpv - --title="Skookum Player" -lavfi-complex "[aid1]asplit=6[ao][a][b][c][d][e],\
    [e]showvolume=w=700:r=25[e1],\
    [a]showfreqs=mode=bar:cmode=separate:size=300x300:colors=magenta|yellow[a1],\
    [a1]drawbox=12:0:3:300:white@0.2[a2],[a2]drawbox=66:0:3:300:white@0.2[a3],[a3]drawbox=135:0:3:300:white@0.2[a4],[a4]drawbox=202:0:3:300:white@0.2[a5],[a5]drawbox=271:0:3:300:white@0.2[aa],\
    [b]avectorscope=s=300x300:r=25:zoom=5[b1],\
    [b1]drawgrid=x=150:y=150:c=white@0.3[bb],\
    [c]showspectrum=s=400x600:mode=combined:color=rainbow:scale=sqrt:saturation=5[cc],\
    [d]astats=metadata=1:reset=2,adrawgraph=lavfi.astats.Overall.Peak_level:max=0:min=-30.0:size=700x256:bg=Black[dd],\
    [dd]drawbox=0:0:700:42:hotpink@0.2:t=42[ddd],\
    [aa][bb]vstack[aabb],[aabb][cc]hstack[aabbcc],[aabbcc][ddd]vstack[aabbccdd],[e1][aabbccdd]vstack[z],\
    [z]drawtext=fontfile=/Library/Fonts/Andale Mono.ttf: text='%{pts \\: hms}':x=460: y=50:fontcolor=white:fontsize=30:box=1:boxcolor=0x00000000@1[fps],[fps]fps=fps=27[vo]"
    exit
fi



ffmpeg -f avfoundation -i "none:"${DEVICE_NUMBER}"" -f wav -c:a "${CODEC}" -ar "${SAMPLE_RATE_NUMERIC}" -y ~/desktop/test.wav -f flac -ar 48000 - |\
mpv - --title="Skookum Player" -lavfi-complex "[aid1]asplit=6[ao][a][b][c][d][e],\
[e]showvolume=w=700:r=25[e1],\
[a]showfreqs=mode=bar:cmode=separate:size=300x300:colors=magenta|yellow[a1],\
[a1]drawbox=12:0:3:300:white@0.2[a2],[a2]drawbox=66:0:3:300:white@0.2[a3],[a3]drawbox=135:0:3:300:white@0.2[a4],[a4]drawbox=202:0:3:300:white@0.2[a5],[a5]drawbox=271:0:3:300:white@0.2[aa],\
[b]avectorscope=s=300x300:r=25:zoom=5[b1],\
[b1]drawgrid=x=150:y=150:c=white@0.3[bb],\
[c]showspectrum=s=400x600:mode=combined:color=rainbow:scale=sqrt:saturation=5[cc],\
[d]astats=metadata=1:reset=2,adrawgraph=lavfi.astats.Overall.Peak_level:max=0:min=-30.0:size=700x256:bg=Black[dd],\
[dd]drawbox=0:0:700:42:hotpink@0.2:t=42[ddd],\
[aa][bb]vstack[aabb],[aabb][cc]hstack[aabbcc],[aabbcc][ddd]vstack[aabbccdd],[e1][aabbccdd]vstack[z],\
[z]drawtext=fontfile=/Library/Fonts/Andale Mono.ttf: text='%{pts \\: hms}':x=460: y=50:fontcolor=white:fontsize=30:box=1:boxcolor=0x00000000@1[fps],[fps]fps=fps=27[vo]"

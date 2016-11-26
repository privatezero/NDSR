##Current build w/kexp input
ffmpeg -i http://live-mp3-128.kexp.org/ -f flac -ar 48000 pipe:1 | ffplay -window_title "Skookum Player" -f lavfi \
"amovie='pipe\:0',asplit=6[out1][a][b][c][d][e],\
[e]showvolume=w=700:c=0xff0000:r=60[e1],\
[a]showfreqs=mode=bar:cmode=separate:size=300x300:colors=magenta|yellow[a1],\
[a1]drawbox=12:0:3:300:white@0.2[a2],[a2]drawbox=66:0:3:300:white@0.2[a3],[a3]drawbox=135:0:3:300:white@0.2[a4],[a4]drawbox=202:0:3:300:white@0.2[a5],[a5]drawbox=271:0:3:300:white@0.2[aa],\
[b]avectorscope=s=300x300:r=60:zoom=5[bb],\
[c]showspectrum=s=400x600:mode=combined:color=rainbow:scale=log[cc],\
[d]astats=metadata=1:reset=1,adrawgraph=lavfi.astats.Overall.Max_level:max=20000:size=700x256[dd],\
[aa][bb]vstack[aabb],[aabb][cc]hstack[aabbcc],[aabbcc][dd]vstack[aabbccdd],[e1][aabbccdd]vstack[out0]"







##Current Recording build w/kexp input
ffmpeg -i http://live-mp3-128.kexp.org/ -f wav -c:a pcm_s24le -ar 96000 -y PIPE2REC -f flac -ar 48000 -y PIPE2PLAY | ffplay -window_title "Skookum Player"  -f lavfi \
"amovie='PIPE2PLAY',asplit=6[out1][a][b][c][d][e],\
[e]showvolume=w=700:c=0xff0000:r=60[e1],\
[a]showfreqs=mode=bar:cmode=separate:size=300x300:colors=magenta|yellow[a1],\
[a1]drawbox=12:0:3:300:white@0.2[a2],[a2]drawbox=66:0:3:300:white@0.2[a3],[a3]drawbox=135:0:3:300:white@0.2[a4],[a4]drawbox=202:0:3:300:white@0.2[a5],[a5]drawbox=271:0:3:300:white@0.2[aa],\
[b]avectorscope=s=300x300:r=60:zoom=5[bb],\
[c]showspectrum=s=400x600:mode=combined:color=rainbow:scale=log[cc],\
[d]astats=metadata=1:reset=1,adrawgraph=lavfi.astats.Overall.Max_level:max=20000:size=700x256[dd],\
[aa][bb]vstack[aabb],[aabb][cc]hstack[aabbcc],[aabbcc][dd]vstack[aabbccdd],[e1][aabbccdd]vstack[out0]" | ffmpeg -i PIPE2REC -c copy ~/desktop/test.wav 









ffmpeg -f avfoundation -i ":0" -f nut pipe:1 | ffplay -f lavfi "amovie='pipe\:0',asplit=2[out1][a],[a]avectorscope[out0]"


Random example
ffmpeg -f avfoundation -i ":0" -f flac -ar 48000 pipe:1 | ffplay -window_title "Skookum Player" -f lavfi "amovie='pipe\:0',asplit=4[out1][a][b][c],[a]showfreqs=mode=line:cmode=separate:size=400x400:colors=magenta[aa],[b]avectorscope=r=60:zoom=5[bb],[c]showspectrum=s=400x800:mode=combined:color=rainbow:scale=log[cc],[aa][bb]vstack[aabb],[aabb][cc]hstack[out0]"


Example with KEXP for input signal
ffmpeg -i http://live-mp3-128.kexp.org/ -f flac -ar 48000 pipe:1 | ffplay -window_title "Skookum Player" -f lavfi "amovie='pipe\:0',asplit=4[out1][a][b][c],[a]showfreqs=mode=line:cmode=separate:size=400x400:colors=magenta|yellow[aa],[b]avectorscope=r=60:zoom=5[bb],[c]showspectrum=s=400x800:mode=combined:color=rainbow:scale=log[cc],[aa][bb]vstack[aabb],[aabb][cc]hstack[out0]"


Example with KEXP and Mean_diff graph
ffmpeg -i http://live-mp3-128.kexp.org/ -f flac -ar 48000 pipe:1 | ffplay -window_title "Skookum Player" -f lavfi "amovie='pipe\:0',asplit=5[out1][a][b][c][d],[a]showfreqs=mode=line:cmode=separate:size=300x300:colors=magenta|yellow[aa],[b]avectorscope=s=300x300:r=60:zoom=5[bb],[c]showspectrum=s=400x600:mode=combined:color=rainbow:scale=log[cc],[d]astats=metadata=1:reset=1,adrawgraph=lavfi.astats.Overall.Mean_difference:max=8000:size=700x256[dd],[aa][bb]vstack[aabb],[aabb][cc]hstack[aabbcc],[aabbcc][dd]vstack[out0]"

Example of showfreqs
-f lavfi "amovie='input',showfreqs=mode=line:size=400x400:colors=magenta[out]"

example of adrawgraphs for maxdiff (needs refinemen to be useful)
astats=metadata=1:reset=1,adrawgraph=lavfi.astats.Overall.Max_difference:max=1000

Generate and pipe sine wave
ffmpeg -f lavfi -i "sine=frequency=400" -f flac pipe:1 |

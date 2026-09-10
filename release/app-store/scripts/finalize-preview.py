#!/usr/bin/env python3
"""Convert inspected HyperFrames masters to the App Store delivery profile."""
from pathlib import Path
import subprocess
root=Path(__file__).resolve().parents[1]
for lang in ['en-US','ko']:
 source=root/'videos/source'/f'Next-App-Preview-{lang}-master-v2.mp4'
 out=root/'videos'/f'Next-App-Preview-{lang}.mp4'
 subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-threads','2','-i',str(source),'-f','lavfi','-i','anullsrc=r=48000:cl=stereo','-map','0:v:0','-map','1:a:0','-t','28','-c:v','libx264','-preset','fast','-threads','2','-profile:v','high','-level:v','4.0','-pix_fmt','yuv420p','-r','30','-g','30','-keyint_min','30','-b:v','11M','-minrate','11M','-maxrate','11M','-bufsize','22M','-x264-params','nal-hrd=cbr:force-cfr=1','-c:a','aac','-b:a','256k','-ar','48000','-ac','2','-movflags','+faststart','-y',str(out)],check=True)
 print(out.name,flush=True)

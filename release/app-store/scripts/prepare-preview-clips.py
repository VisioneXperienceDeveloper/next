#!/usr/bin/env python3
"""Trim real interactions at normal speed and normalize the simulator's VFR capture."""
from pathlib import Path
import subprocess,json
root=Path(__file__).resolve().parents[1]
target=root/'creative/next-editorial/assets';target.mkdir(parents=True,exist_ok=True)
source=root/'videos/source/Next-Release-Capture.mp4'
clips=[('vision',348,7.25),('focus',1249.5,7.25),('reflect',779,7.25),('journey',1447.4,7.75)]
for name,start,duration in clips:
 out=target/(name+'.mp4')
 subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-threads','2','-ss',str(start),'-i',str(source),'-t',str(duration),'-vf','fps=30,scale=886:1920:flags=lanczos,setsar=1','-an','-c:v','libx264','-preset','fast','-crf','16','-profile:v','high','-level','4.0','-pix_fmt','yuv420p','-threads','2','-g','30','-keyint_min','30','-movflags','+faststart','-y',str(out)],check=True)
 print(name,start,duration,flush=True)
(root/'evidence/preview-edit-decision-list.json').write_text(json.dumps({'source':str(source.relative_to(root)),'speed':1,'output_size':[886,1920],'fps':30,'scenes':[{'name':n,'source_start':s,'duration':d,'timeline_start':i*6.75} for i,(n,s,d) in enumerate(clips)]},indent=2)+'\n')

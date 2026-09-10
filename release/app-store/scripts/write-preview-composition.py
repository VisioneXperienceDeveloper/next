#!/usr/bin/env python3
from pathlib import Path
import json,shutil
root=Path(__file__).resolve().parents[1]
project=root/'creative/next-editorial'
copy={
 'en-US':[
  ('','One vision.','One next step.'),
  ('FOCUS','One clear step.','Your full attention.'),
  ('REFLECT','Keep what','you learn.'),
  ('JOURNEY','See how far','you’ve come.')
 ],
 'ko':[
  ('','하나의 비전','오늘의 한 걸음'),
  ('집중','지금은 하나에','집중할 시간'),
  ('회고','한 걸음에서','배운 것을 기록해요'),
  ('여정','지나온 걸음을','돌아보세요')
 ]
}
for lang,scenes in copy.items():
 sections=[];videos=[]
 for i,((label,line1,line2),name) in enumerate(zip(scenes,['vision','focus','reflect','journey'])):
  start=i*6.75;duration=7.75 if i==3 else 7.25
  # Video timing belongs to video itself, never to an ancestor wrapper.
  videos.append(f'<div class="footage" id="vwrap{i+1}"><video class="clip" id="v{i+1}" src="assets/{name}.mp4" data-start="{start}" data-duration="{duration}" data-track-index="{i}" muted playsinline></video></div>')
  sections.append(f'<section class="clip caption scene{i+1}" id="s{i+1}" data-start="{start}" data-duration="{duration}" data-track-index="{i+5}"><div class="scene-content"><p class="eyebrow">{label}</p><h1><span class="line first">{line1}</span><span class="line second">{line2}</span></h1></div></section>')
 html='''<!doctype html><html lang="LANG"><head><meta charset="utf-8"><title>Next — App Preview</title>
<style>
@font-face{font-family:Baskerville;src:local('Baskerville Italic');font-style:italic;font-weight:400}
@font-face{font-family:'Helvetica Neue';src:local('Helvetica Neue Bold');font-weight:700}
@font-face{font-family:'Helvetica Neue';src:local('Helvetica Neue Medium');font-weight:500}
@font-face{font-family:'Apple SD Gothic Neo';src:local('Apple SD Gothic Neo Bold'),local('AppleSDGothicNeo-Bold');font-weight:700}
@font-face{font-family:'Apple SD Gothic Neo';src:local('Apple SD Gothic Neo Medium'),local('AppleSDGothicNeo-Medium');font-weight:500}
@font-face{font-family:AppleMyungjo;src:local('AppleMyungjo');font-weight:400}
@font-face{font-family:'Arial Unicode MS';src:local('Arial Unicode MS')}
*{box-sizing:border-box}html,body{margin:0;padding:0;background:#ffffff;color:#121312}
body{font-family:"Helvetica Neue",Arial,sans-serif}
[data-composition-id="next-editorial"]{position:relative;width:886px;height:1920px;overflow:hidden;background:#ffffff}
.footage{position:absolute;inset:0;width:886px;height:1920px;background:#fff}
video{width:886px;height:1920px;object-fit:contain}
.caption{position:absolute;inset:0;width:886px;height:1920px;pointer-events:none}
.scene-content{display:flex;flex-direction:column;align-items:center;width:100%;height:100%;padding:1400px 50px 0;text-align:center}
.scene1 .scene-content{padding-top:1430px}.scene3 .scene-content{padding-top:1150px}
.eyebrow{margin:0 0 30px;color:#626661;font-size:34px;font-weight:500;line-height:1.1;letter-spacing:.8px}
h1{margin:0;font-size:76px;line-height:1.1;font-weight:700;letter-spacing:-2px;max-width:790px}
.line{display:block;white-space:nowrap}
.scene1 .eyebrow{display:none}.scene1 .first{font-family:Baskerville,Georgia,serif;font-style:italic;font-weight:400;font-size:118px;line-height:1.05;letter-spacing:-3px}
.scene1 .second{margin-top:10px;font-size:76px}
html[lang="ko"] body{font-family:"Apple SD Gothic Neo","Arial Unicode MS",sans-serif}
html[lang="ko"] h1{font-size:82px;line-height:1.16;letter-spacing:-2.7px}
html[lang="ko"] .scene1 .first{font-family:AppleMyungjo,serif;font-style:normal;font-size:105px;letter-spacing:-4px}
html[lang="ko"] .scene1 .second{font-size:86px;margin-top:22px}
html[lang="ko"] .scene3 h1{font-size:79px}
</style></head><body><div data-composition-id="next-editorial" data-start="0" data-duration="28" data-width="886" data-height="1920">VIDEOS SECTIONS</div>
<script src="gsap.min.js"></script><script>
const tl=gsap.timeline({paused:true});
for(let i=1;i<=4;i++){
 const t=(i-1)*6.75;
 // Scene crossfade is the exit; content remains visible until this handoff.
 if(i>1){tl.to('#vwrap'+(i-1),{opacity:0,duration:.5,ease:'power2.inOut'},t);tl.to('#s'+(i-1),{opacity:0,duration:.5,ease:'power2.inOut'},t);}
 tl.from('#vwrap'+i,{opacity:0,duration:.5,ease:'power1.out'},t+(i===1?.1:0));
 if(i>1)tl.from('#s'+i+' .eyebrow',{opacity:0,y:10,duration:.5,ease:'sine.out'},t+.15);
 tl.from('#s'+i+' .first',{opacity:0,y:18,duration:.65,ease:'power2.out'},t+.25);
 tl.from('#s'+i+' .second',{opacity:0,y:12,duration:.6,ease:'sine.out'},t+.38);
}
window.__timelines={'next-editorial':tl};
</script></body></html>'''.replace('LANG',lang).replace('VIDEOS','\n'.join(videos)).replace('SECTIONS','\n'.join(sections))
 target=project if lang=='en-US' else root/'creative/next-editorial-ko'
 target.mkdir(exist_ok=True)
 if lang=='ko':
  for name in ['hyperframes.json','gsap.min.js','DESIGN.md','STORYBOARD.md']:
   shutil.copyfile(project/name,target/name)
  pkg=json.loads((project/'package.json').read_text());pkg['name']='next-editorial-ko'
  (target/'package.json').write_text(json.dumps(pkg,indent=2)+'\n')
  shutil.copytree(project/'assets',target/'assets',dirs_exist_ok=True)
 (target/'index.html').write_text(html)
print('Wrote English and Korean compositions.')

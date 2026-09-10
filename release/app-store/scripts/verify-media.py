#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,struct,subprocess,zipfile
root=Path(__file__).resolve().parents[1]
result={'date':'2026-09-10','app_version':'1.0.0 (1)','screenshots':[],'videos':[]}
files=[]
for lang in ['en-US','ko']:
 shots=sorted((root/'screenshots/editorial'/lang).glob('*.png'))
 assert len(shots)==4
 for p in shots:
  data=p.read_bytes();w,h,depth,color=struct.unpack('>IIBB',data[16:26]);assert (w,h)==(1320,2868) and color==2
  # Read PNG chunks, avoiding false matches in compressed image bytes.
  offset=8;chunks=[]
  while offset<len(data):
   n=int.from_bytes(data[offset:offset+4],'big');chunks.append(data[offset+4:offset+8].decode());offset+=12+n
  assert 'tRNS' not in chunks
  result['screenshots'].append({'file':str(p.relative_to(root)),'size':[w,h],'color':'RGB','alpha':False,'sha256':hashlib.sha256(data).hexdigest()});files.append(p)
 p=root/'videos'/f'Next-App-Preview-{lang}.mp4'
 d=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_format','-show_streams','-of','json',str(p)]))
 v=next(s for s in d['streams'] if s['codec_type']=='video');a=next(s for s in d['streams'] if s['codec_type']=='audio')
 assert (v['width'],v['height'])==(886,1920) and v['codec_name']=='h264' and v['profile']=='High' and v['level']==40 and v['r_frame_rate']=='30/1'
 assert v['pix_fmt']=='yuv420p' and v['color_space']=='bt709'
 assert 10_000_000<=int(v['bit_rate'])<=12_000_000
 assert 27.99<=float(d['format']['duration'])<=28.05 and p.stat().st_size<500_000_000
 assert a['codec_name']=='aac' and a['channels']==2 and a['sample_rate']=='48000'
 subprocess.run(['ffmpeg','-v','error','-threads','2','-i',str(p),'-f','null','-'],check=True)
 result['videos'].append({'file':str(p.relative_to(root)),'size':[v['width'],v['height']],'duration':d['format']['duration'],'fps':v['r_frame_rate'],'codec':v['codec_name'],'profile':v['profile'],'level':v['level'],'bit_rate':v['bit_rate'],'audio':{'codec':a['codec_name'],'channels':a['channels'],'sample_rate':a['sample_rate'],'intentional_silence':True},'bytes':p.stat().st_size,'decode':'PASS','sha256':hashlib.sha256(p.read_bytes()).hexdigest()});files.append(p)
report=root/'evidence/media-verification.json';report.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
archive=root.parent/'Next-AppStore-Media.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for p in files+[root/'screenshots/editorial/Contact-en-US.png',root/'screenshots/editorial/Contact-ko.png',report]:z.write(p,p.relative_to(root))
 z.writestr('README.md','# Next — App Store media\n\nNext 1.0.0 (1), 10 September 2026.\n\n- `screenshots/editorial/ko`: Korean captions, four 1320 × 2868 PNGs.\n- `screenshots/editorial/en-US`: English captions, four 1320 × 2868 PNGs.\n- Order: 01 Vision, 02 Focus, 03 Reflect, 04 Journey.\n- `videos`: Korean and English 28-second App Previews, 886 × 1920, 30 fps, H.264 High Level 4.0, approximately 11 Mbps, silent AAC stereo.\n- Upload to the iPhone 6.9-inch media slot for the matching locale.\n- `Contact-*.png` files are overview sheets for review, not App Store uploads.\n- App UI is English; Korean is the marketing-caption language.\n- Real Next Release app footage with fictional sample entries; no reference-app assets are reused.\n- `evidence/media-verification.json` contains dimensions, codec checks and SHA-256 hashes.\n')
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
print(json.dumps({'result':'PASS','screenshots':len(result['screenshots']),'videos':len(result['videos']),'archive':str(archive),'archive_bytes':archive.stat().st_size},indent=2))

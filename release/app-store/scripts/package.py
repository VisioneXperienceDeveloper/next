#!/usr/bin/env python3
"""Package final release assets without account logs, signing files, or caches."""
from pathlib import Path
import hashlib,json,zipfile
root=Path(__file__).resolve().parents[3]
kit=root/'release/app-store'
excluded={'node_modules','.hyperframes','.agents','.claude','__pycache__','xcuserdata','snapshots'}
evidence={'app-store-state.json','media-verification.json','editorial-layout-verification.json','ipa-signing-verification.json','build2-verification.json','app-icon-verification.json','preview-edit-decision-list.json'}
def include(p):
 rel=p.relative_to(kit)
 if not p.is_file() or any(x in excluded for x in rel.parts):return False
 if p.suffix in {'.log','.pyc','.zip'} or p.name.startswith('work-'):return False
 if rel.parts[0]=='evidence':return p.name in evidence or (len(rel.parts)==3 and rel.parts[1]=='release-capture' and p.suffix=='.png')
 if rel.parts[0]=='videos':return rel.as_posix() in {'videos/Next-App-Preview-ko.mp4','videos/Next-App-Preview-en-US.mp4'}
 if rel.parts[0]=='screenshots' and len(rel.parts)>1:return rel.parts[1] in {'editorial','README.md'}
 return p.name not in {'SHA256.json','AGENTS.md'}
files=sorted(p for p in kit.rglob('*') if include(p))
manifest={str(p.relative_to(kit)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
(kit/'SHA256.json').write_text(json.dumps(manifest,indent=2)+'\n')
files.append(kit/'SHA256.json')
archive=root/'release/Next-1.0-AppStore-Kit.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for p in files:z.write(p,p.relative_to(kit.parent))
source=root/'release/Next-1.0-Source.zip'
with zipfile.ZipFile(source,'w',zipfile.ZIP_DEFLATED) as z:
 for folder in ['Next','NextTests','NextUITests','Next.xcodeproj','scripts','docs']:
  for p in sorted((root/folder).rglob('*')):
   if p.is_file() and not any(x in excluded for x in p.parts):z.write(p,p.relative_to(root))
 for p in files:z.write(p,p.relative_to(root))
 z.write(root/'README.md','README.md')
for p in [archive,source]:
 with zipfile.ZipFile(p) as z:
  assert z.testzip() is None
  assert not any('/node_modules/' in name or name.endswith('.log') for name in z.namelist())
 print(p.name,round(p.stat().st_size/1024/1024,2),'MiB',hashlib.sha256(p.read_bytes()).hexdigest())

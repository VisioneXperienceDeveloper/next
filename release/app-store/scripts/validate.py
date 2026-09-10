#!/usr/bin/env python3
"""Validate artifacts separately from human-confirmed release gates."""
import argparse,json,plistlib,re,struct,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser();parser.add_argument('--submission',action='store_true');args=parser.parse_args()
errors=[]
def check(ok,message):
 if not ok: errors.append(message)
for lang in ['en-US','ko']:
 for key,limit in [('name',30),('subtitle',30),('promotional-text',170),('description',4000)]:
  p=root/'metadata'/lang/(key+'.txt');text=p.read_text().strip()
  check(0<len(text)<=limit,f'{lang}/{key}: {len(text)} characters (limit {limit})')
 keywords=(root/'metadata'/lang/'keywords.txt').read_text().strip()
 check(len(keywords.encode())<=100,f'{lang} keywords: {len(keywords.encode())} bytes')
 check(all(len(x.strip())>2 for x in keywords.split(',')),f'{lang} keyword shorter than 3 characters')
notes=(root/'review/notes.en.txt').read_text().strip();check(len(notes.encode())<=4000,'Review notes exceed 4000 bytes')
for p in root.rglob('*.md'):
 if any(part in {'node_modules','.hyperframes','.agents','.claude'} for part in p.parts) or p.name=='AGENTS.md': continue
 for target in re.findall(r'\[[^\]]+\]\(([^)]+)\)',p.read_text()):
  if '://' not in target and not target.startswith('#'):
   check((p.parent/target.split('#')[0]).exists(),f'Broken local link: {p.relative_to(root)} -> {target}')
shots=[]
for lang in ['en-US','ko']:
 group=list((root/'screenshots/editorial'/lang).glob('*.png'));check(len(group)==4,f'Expected 4 final screenshots: {lang}');shots.extend(group)
for p in shots+list((root/'assets').glob('Next-v1*.png')):
 data=p.read_bytes();width,height,depth,color=struct.unpack('>IIBB',data[16:26])
 expected=(1320,2868) if p in shots else (1024,1024)
 check((width,height)==expected,f'{p.name} size {width}x{height}, expected {expected}')
 check(color in [0,2,3],f'{p.name} has alpha')
 check(b'tRNS' not in data,f'{p.name} includes transparency')
config=json.loads((root/'release-config.json').read_text())
check(config['bundle_id']=='com.visionexperiencedeveloper.next','Incorrect Bundle ID')
project=(root.parents[1]/'Next.xcodeproj/project.pbxproj').read_text()
check('com.visionexperiencedeveloper.next' in project,'Project Bundle ID missing')
with (root/'ExportOptions.plist').open('rb') as f: export=plistlib.load(f)
if args.submission:
 for key in ['team_id','registered_bundle_id','app_store_id','sku','price','territories','eu_trader_status','privacy_effective_date']:
  check(config.get(key) is not None and config.get(key)!='' and config.get(key)!=[],f'Unconfirmed: {key}')
 check(config.get('review_contact_verified_in_app_store_connect'),'Review contact missing in App Store Connect')
 for key in ['privacy_answers_confirmed','age_rating_confirmed','content_rights_confirmed','public_urls_verified','signed_ipa_verified','metadata_matches_release_build','app_icon_verified_in_uploaded_build','pricing_confirmed_in_app_store_connect','territories_confirmed_in_app_store_connect','binary_uploaded','editorial_screenshots_uploaded','app_previews_uploaded','app_preview_processing_complete']:
  check(config.get(key) is True,f'Release gate pending: {key}')
 check(config.get('build_attached')==config.get('release_build'),'Latest build not attached')
 check(export['teamID']==config.get('team_id'),'ExportOptions teamID must match confirmed Team')
 check('REPLACE_' not in (root/'ExportOptions.plist').read_text(),'ExportOptions placeholder remains')
 for p in (root/'legal').glob('privacy.*.md'):
  check('Publication draft' not in p.read_text() and '공개 전 검토용' not in p.read_text(),f'Policy not finalized: {p.name}')
if errors:
 print('\n'.join('FAIL '+e for e in errors));sys.exit(1)
print(f'PASS: metadata limits, review notes, local links, {len(shots)} screenshots, 3 icon formats, and project identity.')
print('Submission field checks passed; this does not prove review acceptance.' if args.submission else 'This does not certify App Store submission readiness.')
if not config.get('device_and_testflight_qa_passed'):print('NOT RUN: physical-device and TestFlight manual QA.')

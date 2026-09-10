#!/usr/bin/env python3
"""Render reviewed local copy to self-contained, tracker-free HTML. Never deploys."""
import html,re
from pathlib import Path
root=Path(__file__).resolve().parents[1]
css='''body{margin:0;background:#fbfaf5;color:#172f24;font:18px/1.75 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}main{max-width:760px;margin:auto;padding:64px 24px 100px}h1{font-size:40px;line-height:1.2;letter-spacing:-1px}h2{font-size:23px;margin-top:40px}a{color:inherit;text-underline-offset:4px}nav{display:flex;gap:24px;margin-bottom:48px;font-size:15px}.note{padding:16px 20px;background:#e9eee8;border-radius:12px;font-size:15px}footer{margin-top:60px;font-size:14px} @media(prefers-color-scheme:dark){body{background:#101b15;color:#e1ebe3}.note{background:#203026}}'''
def render(text):
 blocks=[]
 for block in text.strip().split('\n\n'):
  if block.startswith('# '): blocks.append('<h1>'+html.escape(block[2:])+'</h1>')
  elif block.startswith('## '): blocks.append('<h2>'+html.escape(block[3:])+'</h2>')
  else:
   t=html.escape(block)
   t=re.sub(r'\*\*(.+?)\*\*',r'<strong>\1</strong>',t)
   t=re.sub(r'https://[^\s<]+',lambda m:'<a href="'+m[0]+'">'+m[0]+'</a>',t)
   blocks.append('<p>'+t.replace('\n','<br>')+'</p>')
 return '\n'.join(blocks)
for category in ['privacy','support']:
 for language in ['en','ko']:
  source=root/'legal'/f'{category}.{language}.md'
  out=root/'web-preview'/f'{category}-{language}.html';out.parent.mkdir(exist_ok=True)
  out.write_text(f'''<!doctype html><html lang="{language}"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex"><title>Next · {category.title()}</title><style>{css}</style><main><nav><a href="privacy-{language}.html">Privacy</a><a href="support-{language}.html">Support</a><a href="{category}-{'ko' if language=='en' else 'en'}.html">{'한국어' if language=='en' else 'English'}</a></nav>{render(source.read_text())}<footer>VXDeveloper · <a href="mailto:visionexperiencedeveloper@gmail.com">visionexperiencedeveloper@gmail.com</a></footer></main></html>''')
print('Rendered 4 self-contained preview pages. No upload performed.')

const fs=require('node:fs/promises');
const path=require('node:path');
const {pathToFileURL}=require('node:url');
let chromium;
for(const candidate of [process.env.NEXT_PLAYWRIGHT_MODULE,path.resolve(__dirname,'../../website-worktree/apps/web/node_modules/@playwright/test'),'playwright','@playwright/test'].filter(Boolean)){
 try{chromium=require(candidate).chromium;break}catch(error){if(error.code!=='MODULE_NOT_FOUND')throw error}
}
if(!chromium)throw new Error('Install Playwright, or set NEXT_PLAYWRIGHT_MODULE to its installed module path.');
const root=path.resolve(__dirname,'..');
(async()=>{
 const browser=await chromium.launch({headless:true});
 const page=await browser.newPage({viewport:{width:1320,height:2868},deviceScaleFactor:1});
 const evidence=[];
 for(const lang of ['en-US','ko']){
  const folder=path.join(root,'screenshots','editorial',lang);await fs.mkdir(folder,{recursive:true});
  for(let i=0;i<4;i++){
   await page.goto(pathToFileURL(path.join(root,'creative','store-art.html')).href+'?lang='+lang+'&slide='+i);
   await page.evaluate(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(i=>i.decode()));});
   const layout=await page.evaluate(()=>[...document.querySelectorAll('.headline>*')].map(e=>{const b=e.getBoundingClientRect();return{text:e.textContent,x:b.x,y:b.y,width:b.width,height:b.height,right:b.right,bottom:b.bottom}}));
   if(layout.some(x=>x.x<50||x.right>1270||x.bottom>824))throw new Error('Headline overflow '+lang+' '+i+' '+JSON.stringify(layout));
   const file=path.join(folder,`${String(i+1).padStart(2,'0')}-${['Vision','Focus','Reflect','Journey'][i]}.png`);
   await page.screenshot({path:file,omitBackground:false});evidence.push({lang,slide:i+1,file:path.relative(root,file),layout});
  }
 }
 for(const lang of ['en-US','ko']){
  await page.setViewportSize({width:1840,height:1110});
  const files=evidence.filter(e=>e.lang===lang).map(e=>pathToFileURL(path.join(root,e.file)).href);
  await page.setContent(`<style>*{box-sizing:border-box}body{margin:0;background:#e8e8e4;font-family:Arial,sans-serif;padding:42px 38px}header{display:flex;justify-content:space-between;color:#353c35;margin-bottom:25px;font-size:24px}b{font-weight:500}.row{display:flex;gap:20px}.row img{width:426px;height:925.58px;border-radius:34px}</style><header><b>Next · App Store</b><span>${lang==='ko'?'한국어':'English'}</span></header><div class="row">${files.map(s=>`<img src="${s}">`).join('')}</div>`);
  await page.evaluate(async()=>{await Promise.all([...document.images].map(i=>i.decode()));});
  await page.screenshot({path:path.join(root,'screenshots','editorial',`Contact-${lang}.png`)});
 }
 await fs.writeFile(path.join(root,'evidence','editorial-layout-verification.json'),JSON.stringify({date:'2026-09-10',canvas:[1320,2868],source:'Release simulator screenshots; HTML/CSS typography and device shell',assets:evidence},null,2)+'\n');
 await browser.close();console.log(`PASS: rendered ${evidence.length} store images and two contact sheets; headline bounds verified.`);
})().catch(e=>{console.error(e);process.exit(1)});

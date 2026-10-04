// 部署前把 sw.js 與 index.html 的版本號換成目前時間（兩邊一定相同）
const fs = require('fs');
const path = require('path');
const d = new Date();
const p = (n) => String(n).padStart(2, '0');
const ver = `${d.getFullYear()}.${p(d.getMonth() + 1)}.${p(d.getDate())}-${p(d.getHours())}${p(d.getMinutes())}`;
for (const f of ['public/sw.js', 'public/index.html']) {
  const file = path.join(__dirname, '..', f);
  const src = fs.readFileSync(file, 'utf8');
  const out = src.replace(/const APP_VERSION = '[^']*';/, `const APP_VERSION = '${ver}';`);
  if (out === src) { console.error(`找不到版本號：${f}`); process.exit(1); }
  fs.writeFileSync(file, out, 'utf8');
}
console.log(`新版本號：${ver}`);

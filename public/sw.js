// 版本號由 deploy.bat 自動更新，請勿手動修改
const APP_VERSION = 'dev';
// 只管理以這個前綴開頭的快取，絕不碰使用者資料（IndexedDB / localStorage）
const CACHE_PREFIX = 'food-order-shell-';
const CACHE_NAME = CACHE_PREFIX + APP_VERSION;
const SHELL = ['./', './index.html', './manifest.json',
  './icons/icon-180.png', './icons/icon-192.png', './icons/icon-512.png'];

// 安裝：背景下載新版介面；任何一個檔案失敗就整個不啟用，繼續用舊版
self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await cache.addAll(SHELL.map((url) => new Request(url, { cache: 'reload' })));
    await self.skipWaiting();
  })());
});

// 啟用：只刪除本 App 的舊版介面快取
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys
      .filter((key) => key.startsWith(CACHE_PREFIX) && key !== CACHE_NAME)
      .map((key) => caches.delete(key)));
    await self.clients.claim();
  })());
});

// 讀取：同網域的 GET 先用快取，沒有才連網；外部網址（例如 Google 字型）不處理
self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== self.location.origin) return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    if (req.mode === 'navigate') {
      return (await cache.match('./index.html')) || fetch(req);
    }
    return (await cache.match(req, { ignoreSearch: true })) || fetch(req);
  })());
});

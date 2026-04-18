const CACHE_NAME = 'mycre-v9';
const ASSETS = [
  '/manifest.json',
  '/icon-192.svg',
  '/icon-512.svg',
];
// index.html은 캐시하지 않음 — 항상 최신 버전을 네트워크에서 가져옴

// 설치 — 즉시 활성화
self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS))
  );
  self.skipWaiting(); // 대기 없이 즉시 교체
});

// 활성화 — 모든 이전 캐시 삭제 + 즉시 제어
self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim(); // 즉시 모든 탭 제어
});

// 요청 가로채기
self.addEventListener('fetch', (e) => {
  // Supabase API, Google Fonts, auth callback → 네트워크 직접 (가로채지 않음)
  if (e.request.url.includes('supabase.co') || e.request.url.includes('googleapis.com')) return;
  if (e.request.url.includes('code=') || e.request.url.includes('access_token=') || e.request.url.includes('_logout=') || e.request.url.includes('_deleted=')) return;

  // HTML 요청 → 항상 네트워크 (최신 코드 보장)
  if (e.request.mode === 'navigate' || e.request.url.endsWith('.html')) {
    e.respondWith(
      fetch(e.request).catch(() => caches.match('/index.html'))
    );
    return;
  }

  // 나머지 (아이콘, manifest) → 네트워크 우선, 실패 시 캐시
  e.respondWith(
    fetch(e.request)
      .then(response => {
        if (response.ok) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(e.request, clone));
        }
        return response;
      })
      .catch(() => caches.match(e.request))
  );
});

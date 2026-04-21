const CACHE_NAME = 'byetmaru-v11';
const ASSETS = [
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png',
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
  // ── 가로채지 않는 요청 ──
  // 1) GET이 아닌 요청 (POST/PUT/DELETE 등) — Cache API는 GET만 저장 가능
  if (e.request.method !== 'GET') return;
  // 2) http/https가 아닌 스킴 (chrome-extension://, data:, blob: 등)
  const url = e.request.url;
  if (!url.startsWith('http://') && !url.startsWith('https://')) return;
  // 3) Supabase API, Google Fonts, auth callback → 네트워크 직접
  if (url.includes('supabase.co') || url.includes('googleapis.com')) return;
  if (url.includes('code=') || url.includes('access_token=') || url.includes('_logout=') || url.includes('_deleted=')) return;

  // HTML 요청 → 항상 네트워크 (최신 코드 보장)
  if (e.request.mode === 'navigate' || url.endsWith('.html')) {
    e.respondWith(
      fetch(e.request).catch(() => caches.match('/index.html'))
    );
    return;
  }

  // 나머지 (아이콘, manifest) → 네트워크 우선, 실패 시 캐시
  e.respondWith(
    fetch(e.request)
      .then(response => {
        // 캐시 가능 조건: 응답 OK + basic/cors 타입 (opaque 등은 put 시 이슈 가능)
        if (response.ok && (response.type === 'basic' || response.type === 'cors')) {
          const clone = response.clone();
          caches.open(CACHE_NAME)
            .then(cache => cache.put(e.request, clone))
            .catch(() => {}); // 캐시 실패는 무시 (쿼터 초과 등)
        }
        return response;
      })
      .catch(() => caches.match(e.request))
  );
});

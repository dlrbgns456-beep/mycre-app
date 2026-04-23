const CACHE_NAME = 'byetmaru-v17';
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

// 활성화 — 모든 이전 캐시 삭제 + 즉시 제어 + 열린 클라이언트에 업데이트 알림
self.addEventListener('activate', (e) => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)));
    await self.clients.claim();
    // 열린 모든 탭/PWA 인스턴스에 '새 버전' 메시지 전송
    const all = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    all.forEach(c => c.postMessage({ type: 'SW_UPDATED', version: CACHE_NAME }));
  })());
});

// 클라이언트 → SW: 즉시 skipWaiting 요청
self.addEventListener('message', (e) => {
  if (e.data && e.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
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

// ══════════════════════════════
// Web Push 수신 처리
// ══════════════════════════════
self.addEventListener('push', (e) => {
  if (!e.data) return;
  let data;
  try { data = e.data.json(); }
  catch (err) { data = { title: '볏마루도감', body: e.data.text() }; }

  const title = data.title || '볏마루도감';
  const options = {
    body: data.body || '',
    icon: '/icon-192.png',
    badge: '/icon-192.png',
    vibrate: [200, 100, 200],
    tag: data.tag || 'byetmaru',
    renotify: true,
    data: { url: data.url || '/' },
  };
  e.waitUntil(self.registration.showNotification(title, options));
});

// 알림 클릭 → 앱 열기 / 기존 탭 포커스
self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  const url = e.notification.data?.url || '/';
  e.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
      for (const client of list) {
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          return client.focus();
        }
      }
      return self.clients.openWindow(url);
    })
  );
});

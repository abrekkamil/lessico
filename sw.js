// Cache the shell so the app opens with no signal. The collection itself
// lives in IndexedDB, not here.
const CACHE = 'lessico-v11';
const SHELL = ['./', './index.html', './manifest.webmanifest', './icon.svg',
               './reading/it.json', './reading/tr.json', './grammar/index.json',
               './grammar/it/it.a1.nouns.gender.json'];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

// a new version clears the old caches, including any database answers an
// earlier version kept
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// Only the app's own files are cached. Requests to the database (another
// origin) go straight to the network, so its answers are never stored here
// and, with no signal, they fail as network errors instead of being answered
// with a page.
self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) return;
  event.respondWith(
    fetch(request)
      .then(response => {
        if (response.ok) {
          const copy = response.clone();
          caches.open(CACHE).then(c => c.put(request, copy));
        }
        return response;
      })
      .catch(() => caches.match(request).then(hit => hit ||
        (request.mode === 'navigate' ? caches.match('./index.html') : Response.error())))
  );
});

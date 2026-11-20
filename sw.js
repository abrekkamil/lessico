// Cache the shell so the app opens with no signal. The collection itself
// lives in IndexedDB, not here.
const CACHE = 'lessico-v12';
const SHELL = ['./', './index.html', './manifest.webmanifest', './icon.svg',
               './reading/it.json', './reading/tr.json', './grammar/index.json'];

// every grammar lesson the index lists comes too, so a lesson opens offline
// even before it was first opened; one that fails to load does not stop the rest
async function precache() {
  const cache = await caches.open(CACHE);
  await cache.addAll(SHELL);
  try {
    const index = await (await cache.match('./grammar/index.json')).json();
    await Promise.all((index.topics || []).map(topic =>
      cache.add('./grammar/' + topic.file).catch(() => {})));
  } catch (e) { /* the lessons load when first opened instead */ }
}

self.addEventListener('install', event => {
  event.waitUntil(precache().then(() => self.skipWaiting()));
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

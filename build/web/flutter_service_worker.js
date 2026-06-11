'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "888949f686426d330a640259f93b5d08",
"assets/AssetManifest.bin.json": "543595c177bb3a1c229d9876790e31bc",
"assets/assets/assets/extremadura.geojson": "bae63310bdcd02068f5a4ee535915c4e",
"assets/assets/fonts/RobotoCondensed-Black.ttf": "4bba8e49dc4fb58d473d6748a0af5f5c",
"assets/assets/fonts/RobotoCondensed-BlackItalic.ttf": "6ac2d3ce3ed25e8e50660d0b8a2e40fb",
"assets/assets/fonts/RobotoCondensed-Bold.ttf": "e8363d9ba4eeb7014fccafa926e02bf2",
"assets/assets/fonts/RobotoCondensed-BoldItalic.ttf": "2690b7b10da7bfe5c965076e253eff99",
"assets/assets/fonts/RobotoCondensed-ExtraBold.ttf": "ed6f26263c522a525b445c070fe0975f",
"assets/assets/fonts/RobotoCondensed-ExtraBoldItalic.ttf": "b987efeb42a34201ff68ce577e6411c2",
"assets/assets/fonts/RobotoCondensed-ExtraLight.ttf": "4ac4fcda84a7511b2a41fb9d153b4840",
"assets/assets/fonts/RobotoCondensed-ExtraLightItalic.ttf": "6296567138ce179a14ee3e26a9fac01c",
"assets/assets/fonts/RobotoCondensed-Italic.ttf": "6bbe98a7304f3d2beacf97b6558a6d18",
"assets/assets/fonts/RobotoCondensed-Light.ttf": "ba5fff40603f54684fae8d4ae097efdb",
"assets/assets/fonts/RobotoCondensed-LightItalic.ttf": "9593a2a3f00c76017f8c4f111ff8db5c",
"assets/assets/fonts/RobotoCondensed-Medium.ttf": "085059177d317447a8e08ac35a6f98b7",
"assets/assets/fonts/RobotoCondensed-MediumItalic.ttf": "0ef61f1a906d0294b2f04425d4a822a8",
"assets/assets/fonts/RobotoCondensed-Regular.ttf": "68297c594eb0b804f02ca8ba0918b98f",
"assets/assets/fonts/RobotoCondensed-SemiBold.ttf": "8cf8d15fdaedb0afd9d9c9f9f79bff99",
"assets/assets/fonts/RobotoCondensed-SemiBoldItalic.ttf": "b9f5961b8d6013b8c3023f88cb67236c",
"assets/assets/fonts/RobotoCondensed-Thin.ttf": "e632e18575b9aad8a3bc769d55eb1856",
"assets/assets/fonts/RobotoCondensed-ThinItalic.ttf": "81c594a62ae0c2b6d92e77f3f3e549fe",
"assets/assets/iconos/actividad_etiquetas.svg": "e225c157d4fc1b48f3e28fb107853e00",
"assets/assets/iconos/alojamientos_etiqueta.svg": "08c39d189442128000762b2bed662a03",
"assets/assets/iconos/apartamento.svg": "8c151036f3133955075126e015abe4c6",
"assets/assets/iconos/aviso.svg": "669a92cbe39b75af55e973a5fd0a3b7a",
"assets/assets/iconos/buscar.svg": "e2773ac0eebfd6015cda4789a0fb0de4",
"assets/assets/iconos/cafeteria.svg": "b95a307d778403c9f5f05cbd33ce0b9c",
"assets/assets/iconos/cafeteria_etiquetas.svg": "68377328b5ce4ecd5db4536e7eac9c1a",
"assets/assets/iconos/calendario.svg": "f807fb53d59b1e1b3702ec8857284025",
"assets/assets/iconos/calendario_filtro.svg": "9e84c719f2acf407e8b6f6c4ba324bde",
"assets/assets/iconos/calendario_registro.svg": "2cf9117a8f2367542bb4844a5a9642f6",
"assets/assets/iconos/candado_contrasenia.svg": "0ac3ffb12451f400710980fe650f8c22",
"assets/assets/iconos/casa_rural.svg": "99511f47f93c61788359e2a2edec2f49",
"assets/assets/iconos/cerveceria.svg": "4d4a6aab43e123be04330e8a1c8b4b1c",
"assets/assets/iconos/compartir.svg": "31b58f0c2338e901ea9830c43dc32541",
"assets/assets/iconos/contactar_nosotros.svg": "365e526e9637d44996e9083685d096b0",
"assets/assets/iconos/con_notificacion.svg": "6cdf0cc717c537028a922392efdcfbba",
"assets/assets/iconos/copas.svg": "1f261c9f73c17a9c5c182b4a4506e402",
"assets/assets/iconos/cuadrado_marcado.svg": "46a79204573c15f004c2dcdc97779af0",
"assets/assets/iconos/cuadrado_sin_marcar.svg": "19570ef662d2cd5f1a37c342072be8a6",
"assets/assets/iconos/editar_perfil.svg": "d4f682325664364162e90f99e2b02947",
"assets/assets/iconos/error_x.svg": "a02715b9f70d150882fe8295bcbb056f",
"assets/assets/iconos/flecha_anterior.svg": "0fdad45a61964a5bf1d0211ab47a0047",
"assets/assets/iconos/flecha_siguiente.svg": "f57d1aaa1e587749023c4c8f97bdc959",
"assets/assets/iconos/guardados.svg": "337eead4c4e2149916138c6d15f907fc",
"assets/assets/iconos/home.svg": "a6ba21758af34cf713260006120a9666",
"assets/assets/iconos/hostal.svg": "ef42514ca4f8c0068f6618b6dc531499",
"assets/assets/iconos/hotel.svg": "90d723730effc6f6e252dbbad43594c3",
"assets/assets/iconos/idiomas.svg": "81777eaa6b30334c6816f9a4fea76c89",
"assets/assets/iconos/invitado.svg": "cb390a340674060b92c03c6c9fa630b6",
"assets/assets/iconos/maps.svg": "331e0227686f08515c2d9b24d717f571",
"assets/assets/iconos/mostrar_contrasenia.svg": "6f11bd4ac4a471289ccaf0ff86d39e9b",
"assets/assets/iconos/mostrar_notificacion.svg": "d875088960295b909f3d0dc9d0c1bf34",
"assets/assets/iconos/ocultar_contrasenia.svg": "c6dfd703326d7d31f401856f5d215e74",
"assets/assets/iconos/perfil.svg": "c35e150ecd0091f2a14ae0d846893f9c",
"assets/assets/iconos/politica_privacidad.svg": "9c2d1341c4c7137bd8c72bf758f4ca70",
"assets/assets/iconos/reloj.svg": "fbecb95c292b3409aef70e1a7650cfe7",
"assets/assets/iconos/restaurantes.svg": "b984046bde2dcffa3f194f777327def2",
"assets/assets/iconos/servicios.svg": "b8bd0d71c968f643cf62b2e62ba48b78",
"assets/assets/iconos/sin_notificaciones.svg": "c59c6312ff649c44bb32fed5ca533713",
"assets/assets/iconos/terminos_condiciones.svg": "e38431041cfd895d2e685217600c69c8",
"assets/assets/iconos/ticker.svg": "d12421d927f35adbc9c74970b3e332c5",
"assets/assets/iconos/ubicar.svg": "f32943c1fdebd387457542a7ddb5637b",
"assets/assets/iconos/valido_tick.svg": "f2daca9456e36f6f4bf4dd4ec76d873f",
"assets/assets/images/extrem.png": "49febc2c0a70426509ad52c0c756c03e",
"assets/assets/images/imagen_splash.png": "5dcef82afceacaa99ba53216e0b12794",
"assets/assets/images/logo.png": "a10ecbe3f457af26b47ce408d36b48e2",
"assets/assets/images/logo_kultux.png": "b326238f6187ebb8d4f1b07807a75d4f",
"assets/assets/images/logo_login.png": "5e600a27c21a1b00eeb103c4ceada62d",
"assets/assets/images/logo_registro.png": "14fa3fd7320c040ff8ca16f205efc19c",
"assets/assets/images/mapas.png": "8bc530933e8f529e7550660dde7031ee",
"assets/assets/images/mapa_extr.png": "ae41858f66c0f020cd90df4985ebd01e",
"assets/FontManifest.json": "3736d0ffbf74ff95486402e4cc31a5c1",
"assets/fonts/MaterialIcons-Regular.otf": "fb0bae96b6e9886cdf996164c12e70a4",
"assets/NOTICES": "ff5effa1454f7a43960fda420c532c40",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/wimp.js": "6ca1dec094cc8d3ccd0c53b04d56caaf",
"canvaskit/wimp.js.symbols": "a29ac641a93a1d14ac7ef09206e90a14",
"canvaskit/wimp.wasm": "33dd67ff4c0ed7c123720365dcfddc0c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "47ce1e632f092b23135ab57eb787056e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "6e374c005fb0d15717631af4704079d5",
"/": "6e374c005fb0d15717631af4704079d5",
"logo_kultux.png": "b326238f6187ebb8d4f1b07807a75d4f",
"main.dart.js": "697738fc4c6b06bcf81b5f7f94eed339",
"manifest.json": "8054958b9a08b581ec4e93d85897c7dd",
"splash/img/dark-1x.png": "9cd3678dff42d0e78e44254203b84a05",
"splash/img/dark-2x.png": "06988aeb913f204853733c89c2ad5beb",
"splash/img/dark-3x.png": "70ce991a527145101c259665676f7d3a",
"splash/img/dark-4x.png": "eaf72acbd062b58c5f54bb81619edfee",
"splash/img/light-1x.png": "9cd3678dff42d0e78e44254203b84a05",
"splash/img/light-2x.png": "06988aeb913f204853733c89c2ad5beb",
"splash/img/light-3x.png": "70ce991a527145101c259665676f7d3a",
"splash/img/light-4x.png": "eaf72acbd062b58c5f54bb81619edfee",
"version.json": "37cbf25a6b56e07869595df8e0048f58"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

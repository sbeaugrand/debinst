# dnsfilter : objectifs et état actuel

## Objectifs

- Filtrer le DNS des smartphones de la maison avec dnscrypt-proxy (`/etc/dnscrypt-proxy/blocked-names.txt`).
- Bloquer la télémétrie, la publicité, le pistage et le contournement du filtre (VPN, DoH, relais privés), ainsi que les contenus indésirables (adulte, streaming illégal, APK hors store, arnaques).
- Garder ce qui est nécessaire au fonctionnement normal : système Android/Samsung/iOS, ENT et outils scolaires, applis utilisées.
- Réduire chaque semaine la sortie de `make S=1w` (check.sh) aux seuls domaines encore à classer.

## Fonctionnement

| Fichier | Rôle |
|---|---|
| `/etc/dnscrypt-proxy/blocked-names.txt` | Seule liste appliquée. `domaine.tld` bloque aussi les sous-domaines, `*` est un joker. |
| `deny` | Généré par `make` depuis blocked-names.txt. Sert uniquement à check.sh. |
| `allow.in` → `allow` | Motifs grep (pas des domaines) des noms déjà vus et acceptés. Sert uniquement à masquer ces noms dans check.sh. |
| `deny-suggest.txt` | Propositions à copier dans blocked-names.txt. Sans ligne vide ni commentaire en fin de ligne : la règle `deny:` du Makefile ne les retire pas, et une ligne vide dans `grep -f` correspond à tout. |
| `allow-suggest.in` | Propositions à copier dans allow.in (commentaires ` # ...` acceptés en fin de ligne). |
| `check-1w.out` | Sortie de `make S=1w` : les noms ni dans allow ni dans deny, avec leur nombre de requêtes. |

Les deux listes peuvent se chevaucher sans problème. dnscrypt-proxy n'utilise que la liste de blocage (pas de `allowed_names`), donc un nom présent dans les deux reste bloqué. Ce chevauchement est même voulu quand on autorise un domaine mais qu'on bloque un de ses sous-domaines (par exemple `static.microsoft` autorisé et `otelrules.svc.static.microsoft` bloqué).

Le seul effet du chevauchement concerne le rapport : un motif large dans allow.in (`facebook.com`, `weward`, `mozilla.org`…) masque aussi les nouveaux sous-domaines de ce domaine, y compris un futur traceur. On accepte ce compromis pour les domaines de confiance, mais pas pour les autres. Ainsi, le 2026-11-08, `yandex.` (qui recouvrait mc.yandex, appmetrica et startup.mobile.yandex) a été remplacé par les seuls noms de la recherche (`yandex.ru`, `yandex.com`, `ya.ru`, `familysearch.yandex`, `yastatic.net`, `avatars.mds.yandex.net`).

Chevauchements restants (motif d'allow.in → nombre d'entrées bloquées qu'il recouvre) : `fbcdn.net` 5, `vinted` 3, `cloudflare.com` 3, `scdn.co` 2, `clients6.google.com` 2, puis une quinzaine de motifs qui en recouvrent un seul. Prochains candidats à réduire : `cloudflare.com` et `scdn.co`. Ce dernier n'est pas ancré, il correspond donc aussi à `sascdn.com`, une régie publicitaire.

## Décisions prises

- **Autorisés** : Facebook/Messenger (graph, mqtt, z-m-gateway, fbsbx, fbcdn, Meta AI) et WeWard (weward.*, cdn-weward.app, verisoul.ai, revenuecat, expo.dev, wonderpush, mapbox, Google Fit). Restent bloqués : `facebook.net` (pixel et SDK sur les sites), `an.facebook.com` (régie Audience Network), les sondes réseau netseer/traffic-nts et `events.mapbox.com`.
- **Bloqués** : Snapchat (`*snapchat*` et maintenant `sc-cdn.net`, `sc-static.net`, `snap.com`, `snapkit.com`, `bitmoji.com`…).
- **Sondages rémunérés et offerwalls** (Prime Opinion/Insights, CloudResearch, Cint, Lucid, ayet, besitos, Mistplay…) : bloqués. Ils viennent probablement des fonctions « gagner plus » de WeWard. Le podomètre de WeWard devrait continuer à fonctionner (à vérifier). Pour réactiver ces fonctions, retirer la section correspondante de deny-suggest.txt.
- **CapCut** est autorisé, donc les CDN ByteDance (ibyteimg, byteoversea, tiktokcdn…) le sont aussi.
- **TikTok** est autorisé sur le PC et bloqué sur les téléphones par nft, pas par le DNS. Il ne figure donc pas dans blocked-names.txt, et `tiktok.com` et `tiktokv.com` sont dans allow.in.
- **Epic Games / Fortnite** : autorisé (`epicgames.com`, `epicgames.dev`, `unrealengine.com`). Sa télémétrie (tracking, datarouter, faro-receiver) reste bloquée.
- **SDK d'applis non identifiés** (everestop, mossturbo, rqmob, zipoapps, vgamepop, snapplay) : bloqués le 2026-11-08 après deux semaines de présence. Si une appli ou un jeu ne marche plus, regarder d'abord de ce côté.
- **Stores d'APK hors Play Store** (Aptoide, APKMirror, Aurora Store, F-Droid) : bloqués. Aptoide a servi à installer Fortnite.
- **Huya** (`cdnws.api.huya.com`) et **`dcg.microsoft.com`** : bloqués le 2026-11-08 sans en connaître le rôle. Il faut vérifier que rien ne casse (une appli sur les téléphones pour Huya, Windows ou Office sur le PC pour Microsoft).
- **Ezoic** (`ezoic.net`, `ezojs.com`, `ezodn.com`, vidéo `open.video`, `bidsystem.ai`) : bloqué le 2026-11-15. C'était le premier poste de la semaine (environ 400 requêtes). Son bandeau cookies `gatekeeperconsent.com` reste autorisé, comme les autres bandeaux.
- **Qihoo 360** (`360.cn`, `360safe.com`) : bloqué le 2026-11-15. Ces requêtes viennent d'un antivirus ou nettoyeur chinois, souvent porteur de pub. Il faut chercher sur quel appareil il est installé.
- **HubSpot** : les formulaires (`hsforms.com`) et le bandeau (`hs-banner.com`) sont autorisés, le suivi (`hs-scripts.com`, `hs-analytics.net`, `hscollectedforms.net`) est bloqué.
- **Samsung** : `api.mop.apps.samsung.com` et `stc.samsungdis.com` sont bloqués le 2026-11-15 sans en connaître le rôle, après deux semaines de présence (même règle que pour les SDK inconnus). Si une appli Samsung ne marche plus (Galaxy Store, Samsung Members, thèmes), regarder d'abord de ce côté. `1.ssiloc.com` (localisation probable) et `dvs.samsungmobile.com` sont autorisés.
- **Telegram** : autorisé le 2026-11-15 (`telegram.org`, `telegram.me`, `t.me`).
- **CloudFront** : les distributions anonymes (`d` suivi de 12 ou 13 caractères, puis `.cloudfront.net`) sont masquées dans le rapport par un motif ancré d'allow.in, parce qu'on ne peut pas les classer par le nom. Elles n'ont jamais été bloquées. En contrepartie, un traceur hébergé sur CloudFront n'apparaît plus. Les noms personnalisés en `*.cloudfront.net`, s'il y en a, restent visibles.
- **Paiement et protection des applis bancaires** (SumUp, Worldline Sips, Klarna, Zimperium) : autorisés. `6f74656c.sumup.com` est bloqué : `6f74656c` est « otel » en hexadécimal, c'est-à-dire la télémétrie OpenTelemetry.
- **Bandeaux cookies** (Didomi, Cookiebot, Usercentrics, OneTrust, Axeptio, Pandectes…) : autorisés, car les bloquer casse souvent l'affichage des sites et de certaines applis. Les gestionnaires de balises (TagCommander, Adobe DTM) et LiveRamp (privacymanager.io) sont bloqués.

## Historique

| Date | Requêtes non classées en entrée | Après les suggestions | Notes |
|---|---|---|---|
| 2026-10-25 | ~15 500 | ~4 100 (74 % classées) | Première passe : listes de base. |
| 2026-11-01 | 4 912 (729 noms) | 478 (97 noms, 90 % classées) | Facebook et WeWard autorisés, Snapchat bloqué, sondages bloqués. |
| 2026-11-08 | 1 064 (341 noms) | 233 (79 noms, 78 % classées) | Stores d'APK bloqués, Epic Games autorisé, Huya, dcg.microsoft et SDK inconnus bloqués, `yandex.` réduit. |
| 2026-11-15 | 1 468 (344 noms) | 83 (37 noms, 94 % classées) | Ezoic, Qihoo 360, Hotjar, ShareThis, Outbrain (images) bloqués. Telegram, les distributions CloudFront anonymes, beaucoup de sites marchands et de sites sur l'audition autorisés. |

## À décider ou à identifier

Restants de la semaine du 2026-11-15, par volume (après application des suggestions) :

- `storage.yandexcloud.net` (9, troisième semaine) : stockage générique, on ne sait pas qui l'utilise.
- `event-portal.dailyinnovation.biz` (7), `welkit.com` (6), `webservices.mor-hermes.com` (4), `applets.ebxcdn.com` (4), `powl.io` (8), `kimeratechnologies.com` (6) : rôle inconnu, probablement des widgets de boutiques.
- `voilatile-pa.googleapis.com` (3) : service Google dont on ne connaît pas le rôle.
- `cdn.pddmoonstatic.com` (Temu), `binfenxie.com`, `ankhx.com`, `pahter.tech`, `solarsmashonline.com` : une ou deux requêtes chacun. À surveiller : ils pourraient venir d'applis ou de jeux douteux.
- Des noms techniques de CDN (akamai, herokudns, elb/execute-api amazonaws, kxcdn, cdn77) : ce sont les cibles CNAME d'autres noms, on peut les ignorer.

## Pistes hors de ce répertoire

- Dans `cloaking-rules.txt`, seul `yandex.ru` est redirigé vers le safe search. `yandex.com` (7 requêtes) ne l'est pas : ajouter `yandex.com familysearch.yandex.com`.
- `www.qwant.com` et `fr.search.yahoo.com` ne permettent pas d'imposer le safe search par DNS. Il reste à les tolérer ou à les bloquer.

## Procédure pour la prochaine fois

1. Copier dans blocked-names.txt les sections de deny-suggest.txt qui ne s'y trouvent pas encore. Tout ce qui précède « Ajouts du 2026-11-15 » y est déjà, il ne reste donc que cette dernière section à copier. Pour le vérifier : `grep -v '^#' deny-suggest.txt | grep -vxF -f /etc/dnscrypt-proxy/blocked-names.txt`.
2. Copier allow-suggest.in à la fin d'allow.in.
3. Redémarrer dnscrypt-proxy, attendre une semaine, puis lancer `make S=1w > check-1w.out`.
4. Demander à Claude d'affiner à partir de ce fichier, de `check-1w.out`.
5. Mettre à jour le tableau « Historique » et la liste « À décider ».

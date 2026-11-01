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

Le seul effet du chevauchement concerne le rapport : un motif large dans allow.in (`facebook.com`, `weward`, `mozilla.org`…) masque aussi les nouveaux sous-domaines de ce domaine, y compris un futur traceur. On accepte ce compromis pour les domaines de confiance.

## Décisions prises

- **Autorisés** : Facebook/Messenger (graph, mqtt, z-m-gateway, fbsbx, fbcdn, Meta AI) et WeWard (weward.*, cdn-weward.app, verisoul.ai, revenuecat, expo.dev, wonderpush, mapbox, Google Fit). Restent bloqués : `facebook.net` (pixel et SDK sur les sites), `an.facebook.com` (régie Audience Network), les sondes réseau netseer/traffic-nts et `events.mapbox.com`.
- **Bloqués** : Snapchat (`*snapchat*` et maintenant `sc-cdn.net`, `sc-static.net`, `snap.com`, `snapkit.com`, `bitmoji.com`…).
- **Sondages rémunérés et offerwalls** (Prime Opinion/Insights, CloudResearch, Cint, Lucid, ayet, besitos, Mistplay…) : bloqués. Ils viennent probablement des fonctions « gagner plus » de WeWard. Le podomètre de WeWard devrait continuer à fonctionner (à vérifier). Pour réactiver ces fonctions, retirer la section correspondante de deny-suggest.txt.
- **CapCut** est autorisé, donc les CDN ByteDance (ibyteimg, byteoversea, tiktokcdn…) le sont aussi. TikTok lui-même n'est pas tranché (voir plus bas).
- **Bandeaux cookies** (Didomi, Cookiebot, Usercentrics, OneTrust…) : autorisés, car les bloquer casse souvent l'affichage des sites et de certaines applis. Les gestionnaires de balises (TagCommander, Adobe DTM) et LiveRamp (privacymanager.io) sont bloqués.

## Historique

| Date | Requêtes non classées en entrée | Après les suggestions | Notes |
|---|---|---|---|
| 2026-10-25 | ~15 500 | ~4 100 (74 % classées) | Première passe : listes de base. |
| 2026-11-01 | 4 912 (729 noms) | 478 (97 noms, 90 % classées) | Facebook et WeWard autorisés, Snapchat bloqué, sondages bloqués. |

## À décider ou à identifier

Restants de la semaine du 2026-11-01, par volume :

- `www.tiktok.com` (64) : bloquer TikTok ? Ajouter `tiktok.com` et `tiktokv.com` au deny, sans toucher aux CDN utilisés par CapCut.
- `cdnws.api.huya.com` (35) : Huya (streaming chinois), probablement intégré à une appli. Il est déjà en suspens depuis la semaine dernière.
- `prod-celltw.secb2b.com` (18), `api.mop.apps.samsung.com` (15), `stc.samsungdis.com` (5), `1.ssiloc.com` (5), `d-ipv6.mmapiws.com` (4) : services Samsung/Knox mal identifiés.
- `dcg.microsoft.com` (16) : Microsoft, rôle inconnu.
- `edi5on.com` (14), `config.toto.zipoapps.com` (13), `distribution.rqmob.com` (11), `x.everestop.io` (10), `api.mossturbo.com` (9), `prod.rtymgt.com` (8), `conword.io` (7) : SDK d'applis inconnus, peut-être de la pub. À bloquer si rien ne casse.
- Une quinzaine de `*.cloudfront.net` anonymes : impossible de les classer par le nom seul.
- Des sites web vus une ou deux fois (recettes, fonds d'écran, actualité tech) : à ajouter à allow.in au fil de l'eau.

## Pistes hors de ce répertoire

- Dans `cloaking-rules.txt`, seul `yandex.ru` est redirigé vers le safe search. `yandex.com` (7 requêtes) ne l'est pas : ajouter `yandex.com familysearch.yandex.com`.
- `www.qwant.com` et `fr.search.yahoo.com` ne permettent pas d'imposer le safe search par DNS. Il reste à les tolérer ou à les bloquer.

## Procédure pour la prochaine fois

1. Copier dans blocked-names.txt les sections de deny-suggest.txt qui ne s'y trouvent pas encore. Depuis le 2026-11-01, ce sont celles qui suivent « Ajouts du 2026-11-01 ».
2. Copier les ajouts d'allow-suggest.in dans allow.in.
3. Redémarrer dnscrypt-proxy, attendre une semaine, puis lancer `make S=1w > check-1w.out`.
4. Demander à Claude d'affiner à partir de ce fichier, de `check-1w.out` et de `claude.txt`.
5. Mettre à jour le tableau « Historique » et la liste « À décider ».

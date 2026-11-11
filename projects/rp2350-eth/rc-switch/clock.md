# Horloge NTP

Affichage de l'heure sur 2 afficheurs 7 segments doubles DC56-11EWA
(cathode commune), heure récupérée par NTP via le CH9120.

## Compilation
```sh
mkdir -p build && cd build
cmake .. -DPICO_SDK_PATH=~/data/tmp/install-build/pico-sdk -DPICO_BOARD=waveshare_rp2350_eth -DNTP_CLOCK=ON
make -j`nproc`
```
Sans `-DNTP_CLOCK=ON`, le firmware rc-switch est inchangé.

## Fichiers
- `clock.c` / `clock.h` : multiplexage de l'affichage, requête NTP,
  heure locale.
- `main.c` : sous `#ifdef NTP_CLOCK`, synchro au démarrage puis toutes
  les 24 h, nouvel essai au bout de 60 s en cas d'échec.
- `CMakeLists.txt` : option `NTP_CLOCK` (ajoute `clock.c` et la
  définition `NTP_CLOCK`).

Le répertoire `../CH9120` n'est pas modifié : `clock.c` déclare lui-même
les fonctions et variables de `CH9120.c` qu'il utilise.

## Fonctionnement
- **Un seul socket :** le CH9120 n'en a qu'un. Pendant la synchro,
  `clock_sync()` le passe en UDP client vers le serveur NTP, puis le remet
  en TCP serveur. Le service rc-switch est donc coupé quelques secondes une
  fois par jour.
- **Serveur NTP :** le CH9120 ne fait pas de DNS, l'IP est fixe :
  time.cloudflare.com (`162.159.200.1`), modifiable avec `NTP_SERVER`.
- **Entre deux synchros :** l'heure est tenue par le timer du RP2350, à
  partir du décalage mesuré.
- **Heure de Paris :** UTC+1, heure d'été du dernier dimanche de mars au
  dernier dimanche d'octobre (1 h UTC). Calcul comparé à
  `TZ=Europe/Paris` toutes les ~30 min de 2000 à 2100 : aucun écart.
- **Affichage :** `HH MM`, sans zéro devant les heures, le point décimal
  du 2ᵉ chiffre clignote à la seconde. `----` tant qu'aucune synchro n'a
  réussi. Le multiplexage tourne sur interruption timer (2,5 ms par
  chiffre) et continue pendant l'émission radio.

## Câblage
Numéros de GPIO modifiables avec `SEG_PIN` et `DIG_PIN` dans `clock.c`.

| Fonction                                         | GPIO                                     |
|--------------------------------------------------|------------------------------------------|
| segments a b c d e f g dp                        | GP0 … GP7 (actif haut), avec résistance  |
| cathodes chiffres 1 à 4 (dizaines h → unités min) | GP8 … GP11, chacun vers un NPN          |

- **Segments :** chaque segment est relié en parallèle sur les 4 chiffres.
  Résistance d'environ 220 Ω par segment (~5 mA crête, 40 mA au total
  avec 8 segments allumés). Sortance des GPIO réglée à 8 mA.
- **Transistors :** un NPN par chiffre (BC547 ou 2N3904), émetteur à la
  masse, collecteur sur la cathode commune, base reliée au GPIO par
  2,2 kΩ.

## À savoir
- **EEPROM du CH9120 :** sa bibliothèque enregistre la configuration en
  EEPROM à chaque changement de mode, soit 2 écritures par jour.
- **DC56-11EWA :** vérifier sur la datasheet si les segments des deux
  chiffres sont reliés en interne. Sinon, relier soi-même les broches de
  même segment aux mêmes GPIO.

rem W-i systeme, a propos de, parametres avances du systeme, performances, effets visuels: miniatures et polices seulement
rem W-i personnalisation, demarrer, activer seulement les applications
rem W-i applications, demarrage, desactiver toutes les applications au demarrage
rem W-i applications, desinstaller outlook (dans office)
rem W-i applications, desinstaller google chrome (installer firefox et chromium)
rem W-i comptes, ne pas se connecter au compte

rem supression des suggestions
reg add HKCU\Software\Policies\Microsoft\Windows\Explorer /v DisableSearchBoxSuggestions /t reg_dword /d 1

rem suppression des mises a jour adobe
sc config adobearmservice start= disabled

rem suppression du service des paiements nfc
sc config semgrsvc start= disabled

rem https://lecrabeinfo.net/desactiver-services-inutiles-windows-10.html
rem scanner sc config stisvc start= disabled
rem ipv6 sc config iphlpsvc start= disabled
sc config lmhosts start= disabled
sc config scardsvr start= disabled
sc config trkwks start= disabled
sc config sessionenv start= disabled
sc config wpcmonsvc start= disabled
sc config diagtrack start= disabled
rem inconnu sc config cscservice start= disabled
sc config mapsbroker start= disabled
sc config rasauto start= disabled
sc config rasman start= disabled
sc config xblauthmanager start= disabled
sc config vmicguestinterface start= disabled
sc config xblgamesave start= disabled
sc config netlogon start= disabled
sc config seclogon start= disabled
sc config sharedaccess start= disabled
sc config remoteregistry start= disabled
sc config vmicvss start= disabled
sc config remoteaccess start= disabled
sc config frameserver start= disabled
sc config vmicshutdown start= disabled
sc config bthavctpsvc start= disabled
sc config diagnosticshub.standardcollector.service start= disabled
sc config wbiosrvc start= disabled
sc config bdesvc start= disabled
sc config retaildemo start= disabled
sc config lfsvc start= disabled
sc config pcasvc start= disabled
sc config xboxnetapisvc start= disabled
sc config nettcpportsharing start= disabled
sc config cdpsvc start= disabled
sc config bthserv start= disabled
sc config wersvc start= disabled
sc config dps start= disabled
sc config vmicrdv start= disabled
sc config tabletinputservice start= disabled
rem restaurations sc config fhsvc start= disabled
sc config scdeviceenum start= disabled
sc config vmicvmsession start= disabled
sc config msiscsi start= disabled
sc config wmpnetworksvc start= disabled
sc config icssvc start= disabled
sc config vmicheartbeat start= disabled
sc config smsrouter start= disabled
sc config vmictimesync start= disabled
sc config phonesvc start= disabled
sc config wisvc start= disabled
sc config vmickvpexchange start= disabled
rem imprimante sc config spooler start= disabled
sc config scpolicysvc start= disabled
sc config fax start= disabled
sc config tapisrv start= disabled
sc config webclient start= disabled
sc config wsearch start= disabled

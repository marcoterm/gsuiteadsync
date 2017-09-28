# gsuiteadsync
Script per la sincronizzazione degli utenti di un dominio G Suite in Active Directory

## Cosa fa
Questo piccolo script in bash, attraverso le API di [Google Admin SDK](https://developers.google.com/admin-sdk/), utilizzando [GAM](https://github.com/jay0lee/GAM) come interprete, legge gli ultimi utenti creati in giornata in uno specifico dominio G Suite (configurato in GAM) e li ricrea in Active Directory. Per il momento è pensato per girare una volta al giorno (prima che scatti la giornata successiva), attraverso Task Scheduler


## Dipendenze
Lo script è scritto in bash: occorre installare quindi [Cygwin](https://www.cygwin.com/) per farlo girare su Windows. Inoltre utilizza GAM per interfacciarsi con Google G Suite e le sue API: occorre installare e [configurare](https://github.com/jay0lee/GAM/wiki#windows-users), con apposito progetto su Google Cloud Console, anche quest'ultima dipendenza. 
Si fa notare che la versione di Cygwin installata è a 64bit: occorre eventualmente adattare il path di esecuzione dello script nella Pianificazione Eventi di Windows
Lo script è pensato per lavorare su Windows in quanto utilizza gli esguibili di sistema dsadd.exe, dsmod.exe, dsrm.exe di Active Directory Service. Lo script deve girare, così come è progettato, direttamente in un Domain Controller.
Si precisa che Cygwin vuole come terminazione di linea lo unix like.


## Cosa modificare
La prima decina di righe dello script gsync.sh sono le opzioni: i path ed il dominio di Active Directory. Inoltre occorre eventualmente adattare anche i path del task schedulato gsync_TaskScheduler.xml, oltre che modificarne il nome utente di esecuzione.
Inoltre, le unità organizzative del dominio G Suite (for Education), così come le OU in Active Directory rispecchiano quelle di una scuola: occorre eventualmente adattare quindi anche i DN e il sistema di ricerca delle OU di G Suite (il `case in`)

Le password degli utenti di Active Directory create, non sapendo la password usata in G Suite, sono del tipo $cognome$anno (esempio: rossi2017). È possibile adattare questa impostazione (inserendo una password standard, uguale per tutti, o uno stile diverso) modificando la variabile password, all'interno del ciclo `while` NUOVI UTENTI CREATI

## Sviluppi futuri
Attualmente lo script si occupa solo di creare i nuovi utenti creati in G Suite, ignorando gli utenti rinominati e cancellati. La sincronizzazione delle utenze è quindi molto monodirezionale (G Suite --> AD). In ogni caso, lo script si salva anche gli utenti rinominati ed eliminati (lasciando quindi poi all'amministratore di sistema il compito di ripulire o rinominare gli utenti di AD). Fortunatamente l'operazione non è frequente. Con lo stesso stile della creazione, come si evince dai commenti a fine file, si può procedere anche con queste altre due operazioni.

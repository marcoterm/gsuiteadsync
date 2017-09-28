#!/bin/bash

gam="/cygdrive/c/GAM/gam.exe"
dsadd="/cygdrive/c/Windows/System32/dsadd.exe"
dsmod="/cygdrive/c/Windows/System32/dsmod.exe"
dsmove="/cygdrive/c/Windows/System32/dsmove.exe"
workdir="gsuitesync"
basedir="OU=Liceo,DC=LICEO-AMALDI,DC=locale"
addomain="LICEO-AMALDI.locale"

oggi=$(date +%Y-%m-%d)
anno=$(date +%Y)
mkdir -p $workdir

cd $workdir
mkdir -p logs

### NUOVI UTENTI CREATI #####
$gam report admin event CREATE_USER | grep $oggi | cut -f11 -d"," > utenticreatioggi.csv

while read riga; do

cognome=$(echo $riga | cut -f1 -d '.' )
nome=$(echo $riga | cut -f2 -d '.' | cut -f1 -d '@')
username=$(echo $riga | cut -f1 -d '@' )
password=$cognome$anno

# Cerco di capire in che Google OU si trova, per sapere dove metterlo

$gam info user $riga > /dev/null 2>&1
	if [ $? -eq 148 ]; then
		echo "l'utenza $riga è stata eliminata. Non la creerò" >> logs/debug_$oggi.log
		creo=2
	else
		echo "l'utenza $riga risulta esistere. Cerco di identificare la OU di G Suite" >> logs/debug_$oggi.log
		oug=$($gam info user $riga | grep "Google Org Unit Path" | cut -f2 -d '/' | sed "s/\r//" | sed "s/'//")
		echo "Organizzazione di G Suite: $oug" >> logs/debug_$oggi.log
		case "$oug" in
			Docenti)
			oudir="OU=Docenti,"
			creo=0
			;;
			Studenti)
				annata=$($gam info user $riga | grep "Google Org Unit Path" | cut -f3 -d "/" | sed "s/\\r//" | sed "s/'//")
				classe=$($gam info user $riga | grep "Google Org Unit Path" | cut -f4 -d "/" | sed "s/\r//" | sed "s/'//")
			oudir="OU=$classe,OU=Studenti,"
			creo=0
			;;
			Esterni)
			oudir=""
			creo=1
			;;
			ATA)
			oudir="OU=ATA,"
			;;  
			*)
			creo=1
		esac

		if [ $creo -eq 0 ]; then
			# Aggiungo l'utente in Active Directory
			echo "Creo l'utente $cognome $nome, mail $riga, password $password" >> logs/debug_$oggi.log
			$dsadd user "cn=$cognome $nome,$oudir$basedir" -fn $cognome -ln $nome  -samID $username -upn $username@$addomain  -pwd $password -mustchpwd yes -email $riga
			echo "$dsadd user \"cn=$cognome $nome,$oudir$basedir\" -fn $cognome -ln $nome  -samID $username -upn $username@$addomain  -pwd $password -mustchpwd yes -email $riga" >> logs/debug_$oggi.log
		fi
	fi
done < utenticreatioggi.csv


### UTENTI ELIMINATI ###

$gam report admin event DELETE_USER | grep $oggi | cut -f11 -d"," >> utentieliminati.csv

### UTENTI RINOMINATI ###
$gam report admin event RENAME_USER | grep $oggi | >> utentirinominat.csv

#while read riga; do
#vecchiamail=$(echo $riga | cut -f11 -d",")
#nuovamail=$(echo $riga | cut -f11 -d",")
#
#vecchiousername=$(echo $riga | cut -f1 -d '@' )
#
#
#done < utentirinominatioggi.csv
#
#RENAME_USER old:11 new:13
#dsmove <ObjectDN> [-newname <NewRDN>] [-u <UserName>]
#dsmod user <NewUserDN> -upn <UPN> -fn <FirstName> -ln <LastName> -email <E-mailAddress>

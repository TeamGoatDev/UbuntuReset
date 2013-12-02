#!/bin/bash
:<<CommentaireMultiLigne
Créé le : 25 novembre 2013
Par : Xavier Hudon-Dansereau
Modifications : Mixbo
#Team Goat https://github.com/TeamGoatDev
Version : 1.0

CommentaireMultiLigne

if [ "$(lsb_release -r | cut -b 10-14)" != '13.04' ];
then
	echo "Tu n'utilises pas la version 13.04! Les fichiers .manifest sont peut-être erronnés"
	read -p "Es-tu certain de vouloir continuer?" choix
	case $choi in
		[Oo]* ) 
			echo "Chill. Tu choisis";;
		[Nn]* )
			echo "Sage decision"
			exit 1;;	
	esac

fi

comm -3 <(cat filesystem.manifest | awk '{print $1}' | sort) <(cat filesystem.manifest-remove | sort) > default.txt
echo "le fichier contenant les apps par défaut  a été créé"

dpkg --get-selections | awk '{print $1}' | sort > current.txt
echo "le fichier contenant tout les apps installé en ce moment a été créé"

diff -u default.txt current.txt | grep "^+[^+]" | cut -c 2- > installed.txt
echo "le fichier contenant les apps installé par l'utilisateur a été créé"

diff -u default.txt current.txt | grep "^-[^-]" | cut -c 2- > uninstalled.txt
echo "le fichier contenant les apps par défaut désinstallé par l'usager a été créé"



read -p "Es-tu certain de vouloir reset ubuntu par défaut? (o/n)" choix
case $choix in 
	[Oo]* ) while read line 
		do
			aSupprimer = true
			
			while read otherline
			do
				if [line == otherline] 
				then
					aSupprimer = false
				fi		
			done < ./default.txt
			
			if [$aSupprimer == true]
			then	
				sudo apt-get purge --auto-remove -y $line 
				echo -n "\n \n $line supprimé!!! \n \n"
			fi
		done < ./installed.txt
		
		sudo apt-get autoremove -y
		sudo apt-get update
		
		while read line 
		do 
			sudo apt-get install -y $line 
			echo -n"\n \n$line Installé!!! \n \n"
		done < ./uninstalled.txt
		
		sudo apt-get update;;

	[Nn]* ) echo "Peut-être une autre fois!";;
esac

read -p "Veux-tu garder les fichier de travail? (o/n)" choix
case $choix in 
	[Nn]* ) rm -f default.txt current.txt installed.txt uninstalled.txt;;
	[Oo]* ) exit 1;;
	* ) exit 1;;
esac





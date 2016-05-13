<?php

/********************************************************* 
 * Nom : ListingAudioFiles.php
 * Auteur : Cédric Chambaz
 * Date de création : Lundi 2 mai 2016
 * But : Retourne l'ensemble des fichiers audio se trouvant
 *       sur le serveur
 *********************************************************/

/******************* Modification ************************ 
 * Auteur : 
 * Date de modification : 
 * Raison : 
 *********************************************************/

    $mainDirectory = ("Audio/");                                                                        // Défini le répertoire ou sont stockées les pistes audio
    $returnString = "";                                                                                 // Variable retournée
    $openMainDirectory = opendir($mainDirectory);                                                       // Ouverture du répertoire

    while($folder = readdir($openMainDirectory)) {                                                      // Parcours l'ensemble des dossier contenu
        if($folder != ".." && $folder != ".") {                                                         // Vérifie que le dossier n'est pas parent
            $secondDirectory = opendir($mainDirectory."/".$folder);                                     // Ouvre le second répertoire
            while($content = readdir($secondDirectory)) {                                               // Parcours le dossier actif
                if($content != ".." && $folder != ".") {                                                // Vérifie que le fichier n'est pas un dossier parent
                    if($content."-".$folder != ".-".$folder) {                                          // Vérifie à nouveau (nécessaire même si doublon...)
                        $file = $mainDirectory.$folder."/".$content;                                    // Construit le chemin complet du fichier
                        $content = str_replace(".wav", "", $content);                                   // Supprime l'extension pour le retour à l'application
                        if($returnString != "") {                                                       // Vérifie qu'il ne s'agit pas de la première entrée
                            $returnString = $returnString."|".$content."-".wavDur($file)."-".$folder;   // Ajoute une nouvelle entrée
                        } else {
                            $returnString = $content."-".wavDur($file)."-".$folder;                     // Ajoute la première entrée
                        }
                    } 
                }
            }
        }
    } 
    echo $returnString;                                                                                 // Retourne le résultat
    
    /********************************************************* 
     * Nom : wavDur
     * Auteur : Shailesh Singh
     * Lien : https://shaileshmanojsingh.wordpress.com/2013/03/16/get-duration-of-audio-file-in-php/
     * Date d'implémentation : Lundi 3 mai 2016 
     * But : Récupère la durée d'un fichier wav
     * Paramètre : $file : Fichier cible
     * Retour : $sec : Durée du fichier cible en secondes
     *********************************************************/
    
    /******************* Modification ************************ 
     * Auteur : Cédric Chambaz
     * Date de modification : Lundi 3 mai 2016
     * Raison : La durée retournée de base était en mm:ss,
     *          changement pour retourner le nombre totale
     *          de seconde à la place
     *********************************************************/
    function wavDur($file) {
        $fp = fopen($file, 'r');
        if (fread($fp,4) == "RIFF") {
            fseek($fp, 20);
            $rawheader = fread($fp, 16);
            $header = unpack('vtype/vchannels/Vsamplerate/Vbytespersec/valignment/vbits',$rawheader);
            $pos = ftell($fp);
            while (fread($fp,4) != "data" && !feof($fp)) {
                $pos++;
                fseek($fp,$pos);
            }
            $rawheader = fread($fp, 4);
            $data = unpack('Vdatasize',$rawheader);
            return $sec = $data[datasize]/$header[bytespersec];
        }
    }

//
//  Function.swift
//  iBineuralBeat
//
//  Created by Cédric Chambaz on 11.05.16.
//  Copyright © 2016 Cédric Chambaz. All rights reserved.
//

import Foundation
import UIKit
/***************************************************************/
/* Nom :                                                       */
/***************************************************************/
/* Paramètres :                                                */
/***************************************************************/
/* Description :                                               */
/***************************************************************/
/* Retour :                                                    */
/***************************************************************/

class Function {
    /***************************************************************/
    /* Nom : getConfiguration                                      */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Récupère la configuration défini dans le      */
    /*               fichier iBBConfiguration.txt                  */
    /***************************************************************/
    /* Retour : Content: Contenu du fichier de configuration       */
    /***************************************************************/
    func getConfiguration () -> String {
        var Content = String()                                                                      // Variable contenant l'URL finale après traitement
        
        let FilePath = NSBundle.mainBundle().pathForResource("iBBConfiguration", ofType: "txt")     // Récupère le chemin du fichier de configuration
        let FileContent = try? NSString(contentsOfFile: FilePath!, encoding: NSUTF8StringEncoding)  // Récupère le contenu du fichier de configuration
        
        Content = FileContent!.stringByReplacingOccurrencesOfString("Optional(", withString: "")    // Retire le "Optional(" au début du contenu récupéré
        Content = FileContent!.stringByReplacingOccurrencesOfString(")", withString: "")            // Retire le ")" à la fin du contenu récupéré
        
        return Content                                                                              // Retourne l'URL du serveur
    }
    
    /***************************************************************/
    /* Nom : ModavConfiguration                                    */
    /***************************************************************/
    /* Paramètres : str_Configuration : chaîne de caractère        */
    /*                                  contenant la configuration */
    /***************************************************************/
    /* Description : Met à jours le fichier de configuration       */
    /***************************************************************/
    /* Retour : Message de succès ou d'échec, concerne l'URL du    */
    /*          serveur qui est testée avant d'être approuvée      */
    /***************************************************************/
    func ModavConfiguration (str_Configuration: String) -> String {
        var textTable = getListOfAudioFiles(str_Configuration.componentsSeparatedByString("\n")[0])        // Vérifie que l'adresse du serveur est compatible avec l'application
        
        if textTable[0].containsString("Connexion failed") {                                               // Dans le cas ou la connexion à échouée
            return textTable[0]                                                                            // Retourne le message d'erreur
        } else {
            let filePath = NSBundle.mainBundle().pathForResource("iBBConfiguration", ofType: "txt")        // Récupère le chemin du fichier de configuration
            try? str_Configuration.writeToFile(filePath!, atomically: true, encoding: NSUTF8StringEncoding)// Modifie l'URL contenu dans le fichier par la nouvelle URL spécifié
        }
        
        return "Success"                                                                                   // Retourne nul
    }
    
    /***************************************************************/
    /* Nom : GetListOfAudioFiles                                   */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Récupère l'ensemble des fichiers audio contenu*/
    /*               sur le serveur spécifié                       */
    /***************************************************************/
    /* Retour : dataTable : Tableau contenant les description des  */
    /*                      pistes audios du serveur               */
    /***************************************************************/
    func getListOfAudioFiles (str_URL: String) -> [String] {
        var dataTable = [String]()                                                                               // Tableau retourné contenant les différentes pistes audios
        
        let request = NSMutableURLRequest(URL: NSURL(string: str_URL + "ListingAudioFiles.php")!)         // Préparation de la requête
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {                                   // Lancement de la requête
            data, response, error in
            
            if error != nil                                                                                      // Vérifie si une erreur est survenue
            {
                print("error=" + String(error))                                                                  // Affiche l'erreur
                return
            }
            
            let HTTPResponse = response as? NSHTTPURLResponse                                                    // Récupère les information envoyées par le serveur
            let statusCode = HTTPResponse?.statusCode                                                            // Récupère le code HTTP renvoyé
            if statusCode == 200 {                                                                               // Verifie que le serveur a bien répondu
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)!                      // Récupère les données envoyées par le serveur
                
                dataTable = (responseString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "|")))   // Transforme la chaîne de caractère en tableau
            } else {
                dataTable.append("Connexion failed, Status code : " + String(statusCode))                       // Affiche le code HTTP retourné
                dataTable[0] = "Connexion failed, Status code : " + String(statusCode)
            }
        }
        task.resume()
        
        while dataTable.count == 0 {                                                                            // Boucle d'attente d'exécution de la requête
            
        }
        
        return dataTable                                                                                        // Retourne le tableau contenant les pistes audios
    }
    
    /***************************************************************/
    /* Nom : searchInTable                                         */
    /***************************************************************/
    /* Paramètres : table_Search : Tableau contenant les résultats */
    /*                             d'une recherche                 */
    /*              table_Data : Tableau contenant l'ensemble des  */
    /*                           données                           */
    /*              exact_Value (Opt) : Valeur exacte recherchée   */
    /*                                  dans le tableau            */
    /***************************************************************/
    /* Description : Compare le tableau de recherche au tableau de */
    /*               donnée principale                             */
    /***************************************************************/
    /* Retour : Résultat de la comparaison ou nul si aucun résultat*/
    /*          trouvé                                             */
    /***************************************************************/
    func searchInTable (table_Search: [String], table_Data: [[String]], exact_Value: String?) -> [String]? {
        if exact_Value == nil {                 // Trouve la première occurence dans le tableau de donnée correspondant au tableau de recherche si valeur exacte non spécifiée
            for x in table_Search {             // Parcours le tableau de recherche
                for y in table_Data {           // Parcours le tableau de donnée
                    if x == y[0] {              // Dans le cas ou la recherche et la donnée sont égaux
                        return y                // Retourne la ligne de donnée correspondante
                    }
                }
            }
        } else {                                // Trouve l'occurence exacte dans le tableau de donnée correspondant à la valeur recherchée acctive
            for x in table_Data {               // Parcours le tableau de donnée
                if exact_Value == x[0] {        // Dans le cas ou la valeur exacte recherchée est trouvée
                    return x                    // Retourne la ligne de donnée correspondante
                }
            }
        }
        return nil                              // Dans le cas ou aucun résultat n'est trouvé, retourne nul
    }
    
    /***************************************************************/
    /* Nom : convertSecToHHMMSS                                    */
    /***************************************************************/
    /* Paramètres : dataTable : Tableau contenant les données de   */
    /*                          bases                              */
    /***************************************************************/
    /* Description : Converti une durée en seconde en hh:mm:ss     */
    /***************************************************************/
    /* Retour : resultTable : Contient les heures, minutes et      */
    /*                        secondes en position 0,1 et 2        */
    /***************************************************************/
    func convertSecToHHMMSS (dataTable: [String]) -> [String] {
        var duration = Int(dataTable[1])!                                   // Récupère la durée de la séquence
        var resultTable = [String()]                                        // Déclare le tableau contenant le résultat
        if duration >= 3600 {                                                // Vérifie si la durée est supérieur à 1 heure
            if duration / 3600 < 10 {                                       // Vérifie si le nombre d'heure est inférieur à 10
                resultTable.append("0" + String(duration / 3600))           // Ajoute au tableau le nombre d'heure précedé d'un 0
            } else {
                resultTable.append(String(duration / 3600))                 // Ajoute au tableau le nombre d'heure
            }
            duration -= (duration / 3600) * 3600                            // Retire les heures de la durée totale
        } else {
            resultTable.append("00")                                        // Ajoute au tableau un nombre d'heure nul
        }
        
        if (duration / 60) >= 10 {                                          // Traitement des minutes
            resultTable.append(String(duration / 60))                       // Dans le cas ou le nombre de minutes est supérieur à 10, l'insère dans le tableau
        } else {
            resultTable.append("0" + String(duration / 60))                 // Dans le cas ou le nombre de minutes est inférieur à 10, l'insère dans le tableau précédé d'un 0
        }
        
        
        if duration % 60 != 0 {                                             // Traitement des secondes si nécessaire (dans le cas ou il y a un reste)
            if duration % 60 <= 10 {                                        // Si le nombre de seconde est inférieur à 10
                resultTable.append("0" + String(duration % 60))             // Rajoute un 0 avant le nombre de seconde
            } else {
                resultTable.append(String(duration % 60))                   // Défini le nombre de secondes
            }
        } else {                                                            // Dans le cas ou il n'y a pas de secondes (reste nul)
            resultTable.append("00")                                        // assigne la valeur 00
        }
        
        resultTable.removeFirst()                                           // Retire la première cellule du tableau (toujours nul)
        
        return resultTable                                                  // Retourne le résultat
    }
    
    /***************************************************************/
    /* Nom : checkTextBoxNumFormat                                 */
    /***************************************************************/
    /* Paramètres : tf_Checked : zone de text dont la valeur va    */
    /*                           être vérifiée                     */
    /***************************************************************/
    /* Description : Vérifie que la valeur de la zone de texte est */
    /*               bien un nombre                                */
    /***************************************************************/
    /* Retour : Valeur contenu par la zone de text ou 0 si elle ne */
    /*          possède pas de valeur numérique                    */
    /***************************************************************/
    func checkTextBoxNumFormat (tf_Checked: UITextField) -> Int {
        // Vérifie que la zone de text contient bien un chiffre
        if Int(tf_Checked.text!) != nil {
            return Int(tf_Checked.text!)!                    // Retourne le nombre contenu dans la zone de text
        } else {
            return 0                                         // Retourne 0 dans le cas ou la zone de text ne contient pas un chiffre
        }
    }
    
    /***************************************************************/
    /* Nom : defineNumericValueFormat                              */
    /***************************************************************/
    /* Paramètres : int_Number : Nombre à analyser                 */
    /***************************************************************/
    /* Description : Vérifie la valeur entrée et la met en forme   */
    /*               pour utilisation en texte                     */
    /***************************************************************/
    /* Retour : Charactère au bon format selon la valeur numérique */
    /***************************************************************/
    func defineNumericValueFormat (int_Number: Int) -> String {
        // Vérifie que la valeur numérique est comprise entre 0 et 10
        if int_Number < 10 && int_Number >= 0 {
            return "0" + String(int_Number)             // Retourne le nombre sous format texte en ajoutant un 0 en première position
        } else if int_Number < 0 {                      // Vérifie que le nombre est inférieur à 0
            return "00"                                 // Retourne 00
        } else {
            return String(int_Number)                   // Retourne le nombre sous format texte
        }
    }
}
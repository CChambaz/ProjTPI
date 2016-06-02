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
    /* Retour : Tableau contenant la configuration                 */
    /***************************************************************/
    func getConfiguration () -> [String] {
        // Récupère le chemin du fichier de configuration
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let filePath = documentPath[0].stringByAppendingString("/iBBConfiguration.txt")
        
        // Récupère le contenu du fichier de configuration
        let FileContent = try? NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        
        // Retourne le contenu du fichier de configuration dans un tableau
        return FileContent!.componentsSeparatedByString("\n")
    }
    
    /***************************************************************/
    /* Nom : modavConfiguration                                    */
    /***************************************************************/
    /* Paramètres : str_Configuration : chaîne de caractère        */
    /*                                  contenant la configuration */
    /***************************************************************/
    /* Description : Met à jours le fichier de configuration       */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func modavConfiguration (str_Configuration: String) {
        // Récupère le chemin du fichier de configuration
        let Path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let filePath = Path[0].stringByAppendingString("/iBBConfiguration.txt")
            
        // Modifie le fichier de configuration avec la nouvelle configuration
        do {
            try str_Configuration.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    /***************************************************************/
    /* Nom : getListOfAudioFiles                                   */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Récupère l'ensemble des fichiers audio contenu*/
    /*               sur le serveur spécifié                       */
    /***************************************************************/
    /* Retour : str_DataTable : Tableau contenant les description  */
    /*                          des pistes audios du serveur       */
    /***************************************************************/
    func getListOfAudioFiles (str_URL: String) -> [String] {
        var str_DataTable = [String]()

        // Préparation de la requête
        let request = NSMutableURLRequest(URL: NSURL(string: str_URL + "ListingAudioFiles.php")!)
        
        // Lancement de la requête
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Récupère les information envoyées par le serveur
            let HTTPResponse = response as? NSHTTPURLResponse
            
            // Récupère le code HTTP renvoyé
            let int_StatusCode = HTTPResponse?.statusCode
            
            if int_StatusCode == 200 {
                
                // Récupère les données envoyées par le serveur
                let str_Response = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                
                // Transforme la chaîne de caractère en tableau
                str_DataTable = (str_Response.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "|")))
            } else {
                // Ajoute une message d'echec
                str_DataTable.append("Connexion failed|" + String(int_StatusCode))    
            }
        }
        task.resume()
        
        // Boucle d'attente d'exécution de la requête
        while str_DataTable.count == 0 {
            
        }

        // Retourne le tableau contenant les pistes audios
        return str_DataTable
    }
    
    /***************************************************************/
    /* Nom : searchInTable                                         */
    /***************************************************************/
    /* Paramètres : str_TableData : Tableau contenant l'ensemble   */
    /*                              des données                    */
    /*              str_Value : Valeur exacte recherchée           */
    /*                          dans le tableau                    */
    /***************************************************************/
    /* Description : Recherche une valeur dans le tableau spécifié */
    /***************************************************************/
    /* Retour : Résultat de la comparaison ou nul si aucun résultat*/
    /*          trouvé                                             */
    /***************************************************************/
    func searchInTable (str_TableData: [[String]], str_Value: String?) -> [String]? {
        // Parcours le tableau de donnée
        for x in str_TableData {
            if str_Value == x[0] {
                // Retourne la ligne de donnée correspondante
                return x
            }
        }
        // Dans le cas ou aucun résultat n'est trouvé, retourne nul
        return nil
    }
    
    /***************************************************************/
    /* Nom : convertSecToHHMMSS                                    */
    /***************************************************************/
    /* Paramètres : str_DataTable : Tableau contenant les données  */
    /*                              de la piste audio              */
    /***************************************************************/
    /* Description : Converti une durée en seconde en hh:mm:ss     */
    /***************************************************************/
    /* Retour : str_ResultTable : Contient les heures, minutes et  */
    /*                            secondes en position 0,1 et 2    */
    /***************************************************************/
    func convertSecToHHMMSS (str_DataTable: [String]) -> [String] {
        // Récupère la durée de la séquence
        var int_Duration = Int(str_DataTable[1])!
        
        // Déclare le tableau contenant le résultat
        var str_ResultTable = [String()]
        
        // Traitement du nombre d'heure
        if int_Duration >= 3600 {
            if int_Duration / 3600 < 10 {
                str_ResultTable.append("0" + String(int_Duration / 3600))
            } else {
                str_ResultTable.append(String(int_Duration / 3600))
            }
            // Retire le nombre d'heure à la durée totale
            int_Duration -= (int_Duration / 3600) * 3600
        } else {
            // Ajoute au tableau un nombre d'heure nul
            str_ResultTable.append("00")
        }
        
        // Traitement des minutes
        if (int_Duration / 60) >= 10 {
            str_ResultTable.append(String(int_Duration / 60))
        } else {
            str_ResultTable.append("0" + String(int_Duration / 60))
        }
        
        // Retire le nombre de minutes à la durée totale
        int_Duration = int_Duration % 60
        
        // Traitement des secondes
        if int_Duration != 0 {
            if int_Duration <= 10 {
                str_ResultTable.append("0" + String(int_Duration))
            } else {
                str_ResultTable.append(String(int_Duration))
            }
        } else {
            str_ResultTable.append("00")
        }
        
        // Retire la première cellule du tableau (toujours nul)
        str_ResultTable.removeFirst()
        
        // Retourne le résultat
        return str_ResultTable
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
            // Retourne le nombre contenu dans la zone de text
            return Int(tf_Checked.text!)!
        } else {
            // Retourne 0
            return 0
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
        if int_Number < 10 && int_Number >= 0 {
            return "0" + String(int_Number)
        } else if int_Number < 0 {
            return "00"
        } else {
            return String(int_Number)
        }
    }
}
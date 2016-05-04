//
//  ViewController.swift
//  iBineuralBeat
//
//  Created by Cédric Chambaz on 28.04.16.
//  Copyright © 2016 Cédric Chambaz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Propriétés
    @IBOutlet weak var btn_Categorie1: UIButton!            // Bouton de sélection pour la catégorie 1
    @IBOutlet weak var btn_Categorie2: UIButton!            // Bouton de sélection pour la catégorie 2
    @IBOutlet weak var btn_Categorie3: UIButton!            // Bouton de sélection pour la catégorie 3
    @IBOutlet weak var btn_SoundControl: UIButton!          // Bouton permettant de lancer et mettre en pause la lecture audio
    @IBOutlet weak var btn_SoundStop: UIButton!             // Bouton permettant d'arrêter la lecture audio
    @IBOutlet weak var btn_Settings: UIButton!              // Bouton permettant d'accéder aux paramètres
    @IBOutlet weak var pv_Selection: UIPickerView!          // PickerView permettant de sélectionner la piste audio
    @IBOutlet weak var tf_Search: UITextField!              // Zone de texte permettant la recherche dans la PickerView
    @IBOutlet weak var tf_Houres: UITextField!              // Zone de texte définissant le nombre d'heure de la piste audio
    @IBOutlet weak var tf_Minutes: UITextField!             // Zone de texte définissant le nombre de minutes de la piste audio
    @IBOutlet weak var tf_Seconds: UITextField!             // Zone de texte définissant le nombre de secondes de la piste audio
    @IBOutlet weak var sw_Illimited: UISwitch!              // Switch définissant si la piste audio doit sans contrainte de temps
    
    var str_RecupDatas = [String()]                         // Tableau contenant l'ensemble des pistes audio
    var str_Categorie1Datas = [[String()]]                  // Tableau contenant l'ensemble des pistes audio de la catégorie 1
    var str_Categorie2Datas = [[String()]]                  // Tableau contenant l'ensemble des pistes audio de la catégorie 2
    var str_Categorie3Datas = [[String()]]                  // Tableau contenant l'ensemble des pistes audio de la catégorie 3
    var str_ActiveCategorieDatas = [[String()]]             // Tableau contenant l'ensemble des pistes audio de la catégorie active
    var str_SearchResults = [String()]                      // Tableau contenant les résultats de recherche
    var str_FileName = String()                             // Chaîne de caractère contenant le nom de la piste audio sélectionnée
    var int_ActiveCategorie = Int()                         // Nombre entier définissant la catégorie active
    var int_Duration = Int()                                // Nombre entier définissant la durée totale de la lecture
    var bool_IsSearching = Bool()                           // Booléen définissant si une recherche est en cours
    
    var playerItem:AVPlayerItem?                            // Variable définissant la piste à lire
    var player:AVPlayer?                                    // Lecteur utilisé pour lire la piste
    
    // MARK: Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        // Assignation des valeurs de bases
        int_ActiveCategorie = 1                             // Défini la catégorie 1 comme catégorie active
        bool_IsSearching = false                            // Indique qu'aucune recherche n'est en cours
        
        // Récupèration des données et les places dans le tableau str_RecupDatas
        str_RecupDatas = getListOfAudioFiles()
        
        // Initialisation des tableaux des différentes catégories
        updateCatTable()
        
        // Préparation de l'affichage
        tf_Houres.enabled = false                           // Vérouille la zone de texte des heures
        tf_Minutes.enabled = false                          // Vérouille la zone de texte des minutes
        tf_Seconds.enabled = false                          // Vérouille la zone de texte des secondes
        pv_Selection.delegate = self                        // Initialise la Picker View
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Défini le nombre de donnée à insérer dans le PickerView selon la catégorie sélectionnée
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if bool_IsSearching == false {                  // Vérifie qu'une recherche n'est pas en cours
            return str_ActiveCategorieDatas.count       // Retourne le nombre de séquence selon la catégorie
        } else {                                        // Dans le cas de recherche
            return str_SearchResults.count              // Retourne le nombre de résultats obtenu
        }
    }
    
    // Défini les données que le PickerView va afficher
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if bool_IsSearching == false {                                                                                           // Vérifie qu'une recherche n'est pas en cours
            updateTimesTextField(str_ActiveCategorieDatas[row])                                                                  // Met à jour les zones de texts concernant les minutes et secondes
            str_FileName = str_ActiveCategorieDatas[row][0]
            return str_ActiveCategorieDatas[row][0]                                                                              // Retourne les séquences (uniquement le nom) de la catégorie active
        } else {                                                                                                                 // Dans le cas de recherche, elle est éffectuée ici selon la catégorie
            updateTimesTextField(searchInTable(str_SearchResults, table_Data: str_ActiveCategorieDatas, exact_Value: str_SearchResults[row])!)   // Met à jour les zones de texts concernant les minutes et secondes
            str_FileName = str_SearchResults[row]
            return str_SearchResults[row]                                                                                        // Retourne les résultats de la recherche
        }
    }
    
    // MARK: Action
    
    // Met en pause ou lance la lecture
    @IBAction func controlSoundStatus(sender: AnyObject) {
        let urlForStream = NSURL(string: getServerURL() + "StreamAudioFile.php?Audio/" + String(int_ActiveCategorie) + "/" + str_FileName + ".wav")                 // Construction du chemin du pour accéder au fichier audio
        
        //let urlForStream = NSMutableURLRequest(URL: filePath!)                // Construction de l'url pour le streaming
        
        print(urlForStream!)
        playerItem = AVPlayerItem(URL: urlForStream!)                                                  // Assigne le fichier à lire selon l'url précedente
        player=AVPlayer(playerItem: playerItem!)                                                       // Assigne le fichier à lire précedent au lecteur
        
        player!.play()                                                                                 // Lancement de la lecture
    }
    
    // Arrête la lecture
    @IBAction func stopSound(sender: AnyObject) {
    }
    
    // Action effectuée lors du changement de valeur du PickerView
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if bool_IsSearching == false {                                                                                           // Vérifie qu'une recherche n'est pas en cours
            updateTimesTextField(str_ActiveCategorieDatas[row])                                                                  // Met à jour les textfields de temps selon la donnée sélectionnée
        } else {                                                                                                                 // Dans le cas de recherche
            updateTimesTextField(searchInTable(str_SearchResults, table_Data: str_ActiveCategorieDatas, exact_Value: str_SearchResults[row])!)  // Met à jour les textfields de temps selon la donnée
        }
    }
    
    // Sélectionne la catégorie 1
    @IBAction func selectCategorie1(sender: AnyObject) {
        int_ActiveCategorie = 1                                 // Sélectionne la catégorie 1 comme catégorie active
        str_ActiveCategorieDatas = str_Categorie1Datas          // Assigne les valeurs correspondantes à la catégorie 1
        pv_Selection.reloadAllComponents()                      // Recharge la Picker View avec les nouvelles données
    }
    
    // Sélectionne la catégorie 2
    @IBAction func selectCategorie2(sender: AnyObject) {
        int_ActiveCategorie = 2                                 // Sélectionne la catégorie 2 comme catégorie active
        str_ActiveCategorieDatas = str_Categorie2Datas          // Assigne les valeurs correspondantes à la catégorie 2
        pv_Selection.reloadAllComponents()                      // Recharge la Picker View avec les nouvelles données
    }
    
    // Sélectionne la catégorie 3
    @IBAction func selectCategorie3(sender: AnyObject) {
        int_ActiveCategorie = 3                                 // Sélectionne la catégorie 3 comme catégorie active
        str_ActiveCategorieDatas = str_Categorie3Datas          // Assigne les valeurs correspondantes à la catégorie 3
        pv_Selection.reloadAllComponents()                      // Recharge la Picker View avec les nouvelles données
    }
    
    // Défini si la lecture doit se faire de manière infini
    @IBAction func isDurationIllimited(sender: AnyObject) {
        if sw_Illimited.on == true {        // Désactive les textfield de temps si la lecture est illimité
            tf_Houres.enabled = false
            tf_Minutes.enabled = false
            tf_Seconds.enabled = false
        } else {                            // Active les textfield de temps si la lecture est illimité
            tf_Houres.enabled = true
            tf_Minutes.enabled = true
            tf_Seconds.enabled = true
        }
    }
    
    /**********************************************************************************
     Remarque : A voir pour la recherche selon le temps, comment faire avec les heures
    **********************************************************************************/
    // Fonction s'occupant de la recherche dans la catégorie active
    @IBAction func searchInActiveCategorie(sender: AnyObject) {
        let str_SearchText = tf_Search.text                     // Récupère le critère de la recherche
        
        str_SearchResults.removeAll()                           // Réinitialise le tableau de recherche
        
        if str_SearchText == "" || str_SearchText == nil {      // Si la recherche est annulée
            btn_Categorie1.enabled = true                       // Active le bouton de la catégorie 1
            btn_Categorie2.enabled = true                       // Active le bouton de la catégorie 2
            btn_Categorie3.enabled = true                       // Active le bouton de la catégorie 3
            
            bool_IsSearching = false                            // Indique que la recherche est terminée
        } else {
            btn_Categorie1.enabled = false                      // Désactive le bouton de la catégorie 1
            btn_Categorie2.enabled = false                      // Désactive le bouton de la catégorie 1
            btn_Categorie3.enabled = false                      // Désactive le bouton de la catégorie 1
            
            bool_IsSearching = true                             // Indique que la recherche est en cours
        }
        
        if Int(str_SearchText!) == nil {                        // Défini si la recherche se base sur le nom ou la durée
            for x in str_ActiveCategorieDatas {                 // Parcours le tableau contenant les séquences de la catégorie active
                if x[0].containsString(str_SearchText!) {       // Dans le cas ou une ressemblance est trouvée
                    str_SearchResults.append(x[0])              // Ajoute le nom au tableau de la recherche
                }
            }
        } else {
            for x in str_ActiveCategorieDatas {                                     // Parcours le tableau contenant les séquences de la catégorie active
                if convertSecToHHMMSS(x)[1].containsString(str_SearchText!) {       // Converti la durée en minutes et dans le cas ou la durée est semblable
                    str_SearchResults.append(x[0])                                  // Ajoute le nom au tableau de la recherche
                }
            }
        }
        
        pv_Selection.reloadAllComponents()                      // Recharge le PickerView
    }
    
    /**********************************************************************************
     Remarque : Partie incertaine, pour le moment, aucun moyen de spécifier une durée,
                se base uniquement à la durée du fichier
     **********************************************************************************/
    // Vérification des données entrées dans la zone de texte des heures
    @IBAction func checkCustomHoures(sender: AnyObject) {
        if Int(tf_Houres.text!) == nil {            // Vérifie si la valeurs rentrée correspond bien à un chiffre
            tf_Houres.text = "00"                   // Remplace la valeur invalide par 00
        } else {
            if ((tf_Houres.text?.containsString("-")) != nil) {                                             // Vérifie que la valeur n'est pas négative
                tf_Houres.text = tf_Houres.text?.stringByReplacingOccurrencesOfString("-", withString: "")  // Supprime le -
            } else if ((tf_Houres.text?.containsString("+")) != nil) {                                      // Vérifie que la valeur ne possède pas de signe positif
                tf_Houres.text = tf_Houres.text?.stringByReplacingOccurrencesOfString("+", withString: "")  // Supprime le +
            }
            
            if Int(tf_Houres.text!) < 10 {                                                          // Vérifie que le nombre d'heures est inférieur à 10
                tf_Houres.text = "0" + tf_Houres.text!                                              // Ajoute un 0 avant le nombre d'heures
            }
        }
    }
    
    // Vérification des données entrées dans la zone de texte des minutes
    @IBAction func checkCustomMinutes(sender: AnyObject) {
        if Int(tf_Minutes.text!) == nil {            // Vérifie si la valeurs rentrée correspond bien à un chiffre
            tf_Minutes.text = "00"                   // Remplace la valeur invalide par 00
        } else {
            if ((tf_Minutes.text?.containsString("-")) != nil) {                                                // Vérifie que la valeur n'est pas négative
                tf_Minutes.text = tf_Minutes.text?.stringByReplacingOccurrencesOfString("-", withString: "")    // Supprime le -
            } else if ((tf_Houres.text?.containsString("+")) != nil) {                                          // Vérifie que la valeur ne possède pas de signe positif
                tf_Minutes.text = tf_Minutes.text?.stringByReplacingOccurrencesOfString("+", withString: "")    // Supprime le +
            }
            
            if Int(tf_Minutes.text!) >= 60 {                                                        // Vérifie que les minutes sont inférieur à une heure
                tf_Houres.text = String(Int(tf_Houres.text!)! + (Int(tf_Minutes.text!)! / 60))      // Ajoute le nombre d'heures présentes dans le nombre de minutes à la zone de text des heures
                tf_Minutes.text = String(Int(tf_Minutes.text!)! % 60)                               // Récupère et assigne la valeur correct des minutes
                
                if Int(tf_Houres.text!) < 10 {                                                      // Vérifie que le nombre d'heures est inférieur à 10
                    tf_Houres.text = "0" + tf_Houres.text!                                          // Ajoute un 0 avant le nombre d'heures
                }
            }
            
            if Int(tf_Minutes.text!) < 10 {                                                         // Vérifie que le nombre de minutes est inférieur à 10
                tf_Minutes.text = "0" + tf_Minutes.text!                                            // Ajoute un 0 avant le nombre de minutes
            }
        }
    }
    
    // Vérification des données entrées dans la zone de texte des secondes
    @IBAction func checkCustomSeconds(sender: AnyObject) {
        if Int(tf_Seconds.text!) == nil {
            tf_Seconds.text = "00"
        } else {
            if ((tf_Seconds.text?.containsString("-")) != nil) {                                                // Vérifie que la valeur n'est pas négative
                tf_Seconds.text = tf_Seconds.text?.stringByReplacingOccurrencesOfString("-", withString: "")    // Supprime le -
            } else if ((tf_Seconds.text?.containsString("+")) != nil) {                                         // Vérifie que la valeur ne possède pas de signe positif
                tf_Seconds.text = tf_Seconds.text?.stringByReplacingOccurrencesOfString("+", withString: "")    // Supprime le +
            }
            
            if Int(tf_Seconds.text!) >= 60 {                                                        // Vérifie que les secondes sont inférieur à une minutes
                tf_Minutes.text = String(Int(tf_Minutes.text!)! + (Int(tf_Seconds.text!)! / 60))    // Ajoute le nombre de minutes présentes dans le nombre de secondes à la zone de text des minutes
                tf_Seconds.text = String(Int(tf_Seconds.text!)! % 60)                               // Récupère et assigne la valeur correct des minutes
            }
            
            if Int(tf_Seconds.text!) < 10 {                                                         // Vérifie que le nombre de secondes est inférieur à 10
                tf_Seconds.text = "0" + tf_Seconds.text!                                            // Ajoute un 0 avant le nombre de secondes
            }
            
            if Int(tf_Minutes.text!) < 10 {                                                         // Vérifie que le nombre de minutes est inférieur à 10
                tf_Minutes.text = "0" + tf_Minutes.text!                                            // Ajoute un 0 avant le nombre de minutes
            } else if Int(tf_Minutes.text!) >= 60 {                                                 // Vérifie que les minutes sont inférieur à une heure
                tf_Houres.text = String(Int(tf_Houres.text!)! + (Int(tf_Minutes.text!)! / 60))      // Ajoute le nombre d'heures présentes dans le nombre de minutes à la zone de text des heures
                tf_Minutes.text = String(Int(tf_Minutes.text!)! % 60)                               // Récupère et assigne la valeur correct des minutes
                
                if Int(tf_Minutes.text!) < 10 {                                                     // Vérifie que le nombre de minutes est inférieur à 10
                    tf_Minutes.text = "0" + tf_Minutes.text!                                        // Ajoute un 0 avant le nombre de minutes
                }
                
                if Int(tf_Houres.text!) < 10 {                                                      // Vérifie que le nombre d'heures est inférieur à 10
                    tf_Houres.text = "0" + tf_Houres.text!                                          // Ajoute un 0 avant le nombre d'heures
                }
            }
        }
    }
    
    // MARK: Fonction
    
    /***************************************************************/
    /* Nom : UpdateCatTable                                        */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Rempli les tableaux des différentes catégories*/
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func updateCatTable () {
        for x in str_RecupDatas {
            switch x.componentsSeparatedByString("-")[2] {                        // Défini dans quelle tableau les données seront entrées selon la catégorie
            case "2":
                str_Categorie2Datas.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 2 correspondant
            case "3":
                str_Categorie3Datas.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 3 correspondant
            default:
                str_Categorie1Datas.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 1 correspondant
            }
        }
        
        // Retire la première valeur de chaque tableau (nul)
        str_Categorie1Datas.removeAtIndex(0)
        str_Categorie2Datas.removeAtIndex(0)
        str_Categorie3Datas.removeAtIndex(0)
        
        // Initialise le tableau selon la catégorie active
        switch int_ActiveCategorie {
        case 2:
            str_ActiveCategorieDatas = str_Categorie2Datas
        case 3:
            str_ActiveCategorieDatas = str_Categorie3Datas
        default:
            str_ActiveCategorieDatas = str_Categorie1Datas
        }
    }
    
    /***************************************************************/
    /* Nom : UpdateTimesTextField                                  */
    /***************************************************************/
    /* Paramètres : table_Data : Tableau contenant les données     */
    /*                           utilisées                         */
    /***************************************************************/
    /* Description : Met à jours les différents champs de temps    */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func updateTimesTextField (table_Data: [String]) {
        var detailTable = convertSecToHHMMSS(table_Data)  // Converti la durée en minutes et secondes
        
        tf_Houres.text = detailTable[0]
        tf_Minutes.text = detailTable[1]             // Met à jour la valeur contenu par la textfield des minutes
        tf_Seconds.text = detailTable[2]             // Met à jour la valeur contenu par la textfield des secondes
    }
    
    /***************************************************************/
    /* Nom : startStreaming                                        */
    /***************************************************************/
    /* Paramètres : filePath : Chemin du fichier audio à lire      */
    /***************************************************************/
    /* Description : Lance le streaming de la piste désirée        */
    /***************************************************************/
    /* Retour : Flux audio de la piste désirée                     */
    /***************************************************************/
    func startStreaming (filePath: String) {
        let urlForStream = NSURL(fileURLWithPath: getServerURL() + "StreamAudioFile.php?" + filePath)   // Construction de l'url pour le streaming
        
        self.playerItem = AVPlayerItem(URL: urlForStream)                                                // Assigne le fichier à lire selon l'url précedente
        self.player=AVPlayer(playerItem: self.playerItem!)                                               // Assigne le fichier à lire précedent au lecteur
        
        self.player!.play()                                                                              // Lancement de la lecture
    }
}

/***************************************************************/
/* Nom : GetServerURL                                          */
/***************************************************************/
/* Paramètres : -                                              */
/***************************************************************/
/* Description : Récupère l'adresse du serveur utilisé dans le */
/*               fichier iBBConfiguration.txt                  */
/***************************************************************/
/* Retour : NSURL                                              */
/***************************************************************/
public func getServerURL () -> String {
    var Content = String()                                                                      // Variable contenant l'URL finale après traitement
    
    let FilePath = NSBundle.mainBundle().pathForResource("iBBConfiguration", ofType: "txt")     // Récupère le chemin du fichier de configuration
    let FileContent = try? NSString(contentsOfFile: FilePath!, encoding: NSUTF8StringEncoding)  // Récupère le contenu du fichier de configuration
    
    Content = FileContent!.stringByReplacingOccurrencesOfString("Optional(", withString: "")    // Retire le "Optional(" au début du contenu récupéré
    Content = FileContent!.stringByReplacingOccurrencesOfString(")", withString: "")            // Retire le ")" à la fin du contenu récupéré
    
    return Content                                                                              // Retourne l'URL du serveur
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
public func getListOfAudioFiles () -> [String] {
    var dataTable = [String]()                                                                               // Tableau retourné contenant les différentes pistes audios
    
    let request = NSMutableURLRequest(URL: NSURL(string: getServerURL() + "ListingAudioFiles.php")!)         // Préparation de la requête
    
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
public func searchInTable (table_Search: [String], table_Data: [[String]], exact_Value: String?) -> [String]? {
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
public func convertSecToHHMMSS (dataTable: [String]) -> [String] {
    var duration = Int(dataTable[1])!                                   // Récupère la durée de la séquence
    var resultTable = [String()]                                        // Déclare le tableau contenant le résultat
    if duration > 3600 {                                                // Vérifie si la durée est supérieur à 1 heure
        if duration / 3600 < 10 {                                       // Vérifie si le nombre d'heure est inférieur à 10
            resultTable.append("0" + String(duration / 3600))           // Ajoute au tableau le nombre d'heure précedé d'un 0
        } else {
            resultTable.append(String(duration / 3600))                 // Ajoute au tableau le nombre d'heure
        }
        duration -= (duration / 3600) * 3600                            // Retire les heures de la durée totale
    } else {
        resultTable.append("00")                                        // Ajoute au tableau un nombre d'heure nul
    }
    
    resultTable.append(String(duration / 60))                           // Défini le nombre de minutes
    
    if duration % 60 != 0 {                                             // Traitement des secondes si nécessaire (dans le cas ou il y a un reste)
        if duration % 60 < 10 {                                         // Si le nombre de seconde est inférieur à 10
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
/* Nom :                                                       */
/***************************************************************/
/* Paramètres :                                                */
/***************************************************************/
/* Description :                                               */
/***************************************************************/
/* Retour :                                                    */
/***************************************************************/
//
//  ViewController.swift
//  Test_Affichage
//
//  Created by Cédric Chambaz on 18.04.16.
//  Copyright © 2016 Cédric Chambaz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Propriétés
    @IBOutlet weak var pw_Seq: UIPickerView!
    @IBOutlet weak var btn_CatCon: UIButton!
    @IBOutlet weak var btn_CatRel: UIButton!
    @IBOutlet weak var btn_CatAutre: UIButton!
    @IBOutlet weak var btn_Param: UIButton!
    @IBOutlet weak var btn_ValidateParam: UIButton!
    @IBOutlet weak var btn_CancelParam: UIButton!
    @IBOutlet weak var btn_SoundControl: UIButton!
    @IBOutlet weak var btn_SoundStop: UIButton!
    @IBOutlet weak var textfield_Min: UITextField!
    @IBOutlet weak var textfield_Sec: UITextField!
    @IBOutlet weak var textfield_ServerURL: UITextField!
    @IBOutlet weak var switch_Illimited: UISwitch!
    @IBOutlet weak var textfield_Search: UITextField!
    @IBOutlet weak var label_MidTime: UILabel!
    @IBOutlet weak var label_Duree: UILabel!
    @IBOutlet weak var label_Illimite: UILabel!
    @IBOutlet weak var label_Serveur: UILabel!
    
    var SeqAll = ["Concentration-1980-1", "Relaxation-1800-2", "Autre-2340-3", "Seconde-1380-1"]    // Tableau contenant l'ensemble des séquences
    var Sequence_Cat_1_Detail = [[String()]]                                                        // Tableau contenant les détails des séquences de catégorie 1
    var Sequence_Cat_2_Detail = [[String()]]                                                        // Tableau contenant les détails des séquences de catégorie 2
    var Sequence_Cat_3_Detail = [[String()]]                                                        // Tableau contenant les détails des séquences de catégorie 3
    var Sequence_Cat_Active = [[String()]]                                                          // Tableau contenant les détails des séquences de la catégorie active
    var Recherche = [String]()                                                                      // Tableau contenant les résultats de la recherche
    var ActiveCat = 1                                                                               // Variable qui défini la catégorie active
    
    var IsSearching = false                                                                         // Variable définissant si l'action de recherche est active
    var Minutes = Int()                                                                             // Variable contenant le nombre de minutes
    var Seconds = Int()                                                                             // Variable contenant le nombre de secondes
    var ServerURL = NSURL()                                                                         // Variable contenant l'adresse du serveur
    
    // MARK: Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Récupère l'URL du serveur
        ServerURL = GetServerURL()
        
        /*-----------------------------------------------------------------------------------------------------------
        Récuperation des séquences depuis le serveur et les entrepose dans le tableau SeqAll, a voir des que possible
        -----------------------------------------------------------------------------------------------------------*/
        
        // Préparation des tableaux de chaques catégories
        UpdateCatTable()
        
        // Prépare l'affichage
        pw_Seq.delegate = self
        textfield_Sec.enabled = false
        textfield_Min.enabled = false
        ShowHideParam(true)
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
        if IsSearching == false {               // Vérifie qu'une recherche n'est pas en cours
            return Sequence_Cat_Active.count    // Retourne le nombre de séquence selon la catégorie
        } else {                                // Dans le cas de recherche
            return Recherche.count              // Retourne le nombre de résultats obtenu
        }
    }
    
    // Défini les données que le PickerView va afficher
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if IsSearching == false {                                                                                           // Vérifie qu'une recherche n'est pas en cours
            UpdateTimesTextField(Sequence_Cat_Active[row])                                                                  // Met à jour les zones de texts concernant les minutes et secondes
            return Sequence_Cat_Active[row][0]                                                                              // Retourne les séquences (uniquement le nom) de la catégorie active
        } else {                                                                                                            // Dans le cas de recherche, elle est éffectuée ici selon la catégorie
            UpdateTimesTextField(SearchInTable(Recherche, table_Data: Sequence_Cat_Active, exact_Value: Recherche[row])!)   // Met à jour les zones de texts concernant les minutes et secondes
            return Recherche[row]                                                                                           // Retourne les résultats de la recherche
        }
    }
    
    // MARK: Action
    
    // Action effectuée lors du changement de valeur du PickerView
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if IsSearching == false {                                                                                           // Vérifie qu'une recherche n'est pas en cours
            UpdateTimesTextField(Sequence_Cat_Active[row])                                                                  // Met à jour les textfields de temps selon la donnée sélectionnée
        } else {                                                                                                            // Dans le cas de recherche
            UpdateTimesTextField(SearchInTable(Recherche, table_Data: Sequence_Cat_Active, exact_Value: Recherche[row])!)   // Met à jour les textfields de temps selon la donnée
        }
    }
    
    // Sélection de la catégorie 1
    @IBAction func SelectCatCon(sender: AnyObject) {
        ActiveCat = 1                                                                   // Modifie la catégorie
        Sequence_Cat_Active = Sequence_Cat_1_Detail                                     // Modifie le contenu du tableau de la catégorie active
        pw_Seq.reloadAllComponents()                                                    // Recharge les données du PickerView
    }
    
    // Sélection de la catégorie 2
    @IBAction func SelectCatRel(sender: AnyObject) {
        ActiveCat = 2                                                                   // Modifie la catégorie
        Sequence_Cat_Active = Sequence_Cat_2_Detail                                     // Modifie le contenu du tableau de la catégorie active
        pw_Seq.reloadAllComponents()                                                    // Recharge les données du PickerView
    }
    
    // Sélection de la catégorie 3
    @IBAction func SelectCatAutre(sender: AnyObject) {
        ActiveCat = 3                                                                   // Modifie la catégorie
        Sequence_Cat_Active = Sequence_Cat_3_Detail                                     // Modifie le contenu du tableau de la catégorie active
        pw_Seq.reloadAllComponents()                                                    // Recharge les données du PickerView
    }
    
    // Défini si la séquence doit être lu de manière ilimité ou non
    @IBAction func IllimitedOnOff(sender: AnyObject) {
        if switch_Illimited.on == false {       // Active les textfield de minutes et secondes si la lecture de séquence est limitée
            textfield_Sec.enabled = true
            textfield_Min.enabled = true
        } else {                                // Désactive les textfield de minutes et secondes si la lecture de séquence est ilimité
            textfield_Sec.enabled = false
            textfield_Min.enabled = false
        }
    }
    
    // Effectue la recherche
    @IBAction func Search(sender: AnyObject) {
        let SearchText = textfield_Search.text          // Récupère la base de la recherche
        
        Recherche.removeAll()                           // Réinitialise le tableau de recherche
        
        if SearchText == "" || SearchText == nil {      // Si la recherche est annulée
            btn_CatCon.enabled = true                   // Active le bouton de la catégorie 1
            btn_CatRel.enabled = true                   // Active le bouton de la catégorie 2
            btn_CatAutre.enabled = true                 // Active le bouton de la catégorie 3
            
            IsSearching = false                         // Indique que la recherche est terminée
        } else {
            btn_CatCon.enabled = false                  // Désactive le bouton de la catégorie 1
            btn_CatRel.enabled = false                  // Désactive le bouton de la catégorie 1
            btn_CatAutre.enabled = false                // Désactive le bouton de la catégorie 1
            
            IsSearching = true                          // Indique que la recherche est en cours
        }
        
        if Int(SearchText!) == nil {                    // Défini si la recherche se base sur le nom ou la durée
            for x in Sequence_Cat_Active {              // Parcours le tableau contenant les séquences de la catégorie active
                if x[0].containsString(SearchText!) {   // Dans le cas ou une ressemblance est trouvée
                    Recherche.append(x[0])              // Ajoute le nom au tableau de la recherche
                }
            }
        } else {
            for x in Sequence_Cat_Active {                                  // Parcours le tableau contenant les séquences de la catégorie active
                if ConvertSecToMMSS(x)[0].containsString(SearchText!) {     // Converti la durée en minutes et dans le cas ou la durée est semblable
                    Recherche.append(x[0])                                  // Ajoute le nom au tableau de la recherche
                }
            }
        }
        
        pw_Seq.reloadAllComponents()                    // Recharge le PickerView
    }
    
    // Traitement de la donnée entrée dans la zone de text des minutes et mise à jour de la variable des minutes
    @IBAction func CustomDurationMinutes(sender: AnyObject) {
        if Int(textfield_Min.text!) == nil {            // Vérifie si la valeurs rentrée correspond bien à un chiffre
            textfield_Min.text = ""                     // Supprime la valeur invalide
        } else {
            if ((textfield_Min.text?.containsString("-")) != nil) {                                                 // Vérifie que la valeur n'est pas négative
                textfield_Min.text = textfield_Min.text?.stringByReplacingOccurrencesOfString("-", withString: "")  // Supprime le -
            } else if ((textfield_Min.text?.containsString("+")) != nil) {                                          // Vérifie que la valeur ne possède pas de signe positif
                textfield_Min.text = textfield_Min.text?.stringByReplacingOccurrencesOfString("+", withString: "")  // Supprime le +
            }
            Minutes = Int(textfield_Min.text!)!         // Récupère la valeur du champ
        }
    }
    
    // Traitement de la donnée entrée dans la zone de text des secondes et mise à jour de la variable des secondes
    @IBAction func CustomDurationSeconds(sender: AnyObject) {
        if Int(textfield_Sec.text!) == nil {            // Vérifie si la valeurs rentrée correspond bien à un chiffre
            textfield_Sec.text = ""                     // Supprime la valeur invalide
        } else {
            if ((textfield_Sec.text?.containsString("-")) != nil) {                                                 // Vérifie que la valeur n'est pas négative
                textfield_Sec.text = textfield_Sec.text?.stringByReplacingOccurrencesOfString("-", withString: "")  // Supprime le -
            } else if ((textfield_Sec.text?.containsString("+")) != nil) {                                          // Vérifie que la valeur ne possède pas de signe positif
                textfield_Sec.text = textfield_Sec.text?.stringByReplacingOccurrencesOfString("+", withString: "")  // Supprime le +
            }
            Seconds = Int(textfield_Sec.text!)!         // Récupère la valeur du champ
            
            if Seconds > 59 {                           // Vérifie que le nombre de seconde est compris entre 0 et 60
                Minutes += Seconds / 60                 // Ajoute le nombre de secondes en trop au nombre de minutes
                textfield_Min.text = String(Minutes)    // Met à jour l'affichage des minutes
                
                Seconds = Seconds % 60                  // Récupère le nombre réel de secondes
                textfield_Sec.text = String(Seconds)    // Met à jour l'affichage des secondes
            }
        }
    }
    
    @IBAction func OpenParam(sender: AnyObject) {
        ShowHideParam(false)                            // Masque l'affichage de base et affiche les paramètres
        textfield_ServerURL.text = String(ServerURL)    // Défini l'URL actuellement active comme valeur à la zone de text de l'URL du serveur
    }
    
    @IBAction func ValidateParam(sender: AnyObject) {
        ModavServerURL(textfield_ServerURL.text!)       // Met à jour l'URL du fichier Configuration.txt selon la valeur entrée par l'utilisateur
        ServerURL = GetServerURL()                      // Met à jour la variable contenant l'URL
        ShowHideParam(true)                             // Affiche l'affichage de base et masque les paramètres
    }
    
    @IBAction func CancelParam(sender: AnyObject) {
        ShowHideParam(true)                             // Affiche l'affichage de base et masque les paramètres
    }
    
    // MARK: Fonction
    
    // Met à jour les textfield et variables des minutes et secondes
    func UpdateTimesTextField (table_Data: [String]) {
        var DetailTable = ConvertSecToMMSS(table_Data)  // Converti la durée en minutes et secondes
        
        textfield_Min.text = DetailTable[0]             // Met à jour la valeur contenu par la textfield des minutes
        textfield_Sec.text = DetailTable[1]             // Met à jour la valeur contenu par la textfield des secondes
        
        Minutes = Int(DetailTable[0])!                  // Met à jour la variable des minutes
        Seconds = Int(DetailTable[1])!                  // Met à jour la variable des secondes
    }
    
    // Modifie l'affichage: Param = true => masque les paramètres, = false => affiche les paramètres
    func ShowHideParam (Param: Bool) {
        var Other = false
        
        // Défini si il faut afficher les élements de base
        if Param == false {
            Other = true
        }
        
        // Affiche/Masque les élements de base
        btn_Param.hidden = Other
        btn_CatCon.hidden = Other
        btn_CatRel.hidden = Other
        btn_CatAutre.hidden = Other
        btn_SoundStop.hidden = Other
        btn_SoundControl.hidden = Other
        textfield_Min.hidden = Other
        textfield_Sec.hidden = Other
        textfield_Search.hidden = Other
        switch_Illimited.hidden = Other
        pw_Seq.hidden = Other
        label_Duree.hidden = Other
        label_MidTime.hidden = Other
        label_Illimite.hidden = Other
        
        // Affiche/Masque les élements des paramètre
        btn_ValidateParam.hidden = Param
        btn_CancelParam.hidden = Param
        textfield_ServerURL.hidden = Param
        label_Serveur.hidden = Param
    }
    
    // Rempli les tableaux des différentes catégories et rempli le tableau de la catégorie active
    func UpdateCatTable () {
        for x in SeqAll {
            switch x.componentsSeparatedByString("-")[2] {                          // Défini dans quelle tableau les données seront entrées selon la catégorie
            case "2":
                Sequence_Cat_2_Detail.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 2 correspondant
            case "3":
                Sequence_Cat_3_Detail.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 3 correspondant
            default:
                Sequence_Cat_1_Detail.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 1 correspondant
            }
        }
        
        // Retire la première valeur de chaque tableau (nul)
        Sequence_Cat_1_Detail.removeAtIndex(0)
        Sequence_Cat_2_Detail.removeAtIndex(0)
        Sequence_Cat_3_Detail.removeAtIndex(0)
        
        // Initialise le tableau selon la catégorie active
        switch ActiveCat {
        case 2:
            Sequence_Cat_Active = Sequence_Cat_2_Detail
        case 3:
            Sequence_Cat_Active = Sequence_Cat_3_Detail
        default:
            Sequence_Cat_Active = Sequence_Cat_1_Detail
        }
    }
}

// Convertie le temps donné en seconde d'une ligne de tableau en minutes et secondes
public func ConvertSecToMMSS (table: [String]) -> [String] {
    let Duration = Int(table[1])!                                       // Récupère la durée de la séquence
    var Table = [String()]                                              // Déclare le tableau contenant le résultat
    
    Table.append(String(Duration / 60))                                 // Défini le nombre de minutes
    
    if Duration % 60 != 0 {                                             // Traitement des secondes si nécessaire (dans le cas ou il y a un reste)
        if Duration % 60 < 10 {                                         // Si le nombre de seconde est inférieur à 10
            Table.append("0" + String(Duration % 60))                   // Rajoute un 0 avant le nombre de seconde
        } else {
            Table.append(String(Duration % 60))                         // Défini le nombre de secondes
        }
    } else {                                                            // Dans le cas ou il n'y a pas de secondes (reste nul)
        Table.append("00")                                              // assigne la valeur 00
    }
    
    Table.removeFirst()                                                 // Retire la première cellule du tableau (toujours nul)
    
    return Table                                                        // Retourne le résultat
}

// Effectue la recherche dans le tableau de donné
public func SearchInTable (table_Search: [String], table_Data: [[String]], exact_Value: String?) -> [String]? {
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

// Récupère et traite l'URL contenu dans le fichier Configuration.txt
public func GetServerURL () -> NSURL {
    let FilePath = NSBundle.mainBundle().pathForResource("Configuration", ofType: "txt")        // Récupère le chemin du fichier de configuration
    let FileContent = try? NSString(contentsOfFile: FilePath!, encoding: NSUTF8StringEncoding)  // Récupère le contenu du fichier de configuration
    var Content = String()                                                                      // Variable contenant l'URL finale après traitement
    
    Content = FileContent!.stringByReplacingOccurrencesOfString("Optional(", withString: "")    // Retire le "Optional(" au début du contenu récupéré
    Content = FileContent!.stringByReplacingOccurrencesOfString(")", withString: "")            // Retire le ")" à la fin du contenu récupéré
    
    return NSURL(string: Content)!                                                              // Retourne l'URL du serveur
}

// Modifie l'URL contenu dans le fichier Configuration.txt
public func ModavServerURL (URL: String) {
    let FilePath = NSBundle.mainBundle().pathForResource("Configuration", ofType: "txt")        // Récupère le chemin du fichier de configuration
    try? URL.writeToFile(FilePath!, atomically: true, encoding: NSUTF8StringEncoding)           // Modifie l'URL contenu dans le fichier par la nouvelle URL spécifié
}
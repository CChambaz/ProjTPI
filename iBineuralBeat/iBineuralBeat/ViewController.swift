//
//  ViewController.swift
//  iBineuralBeat
//
//  Created by Cédric Chambaz on 28.04.16.
//  Copyright © 2016 Cédric Chambaz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate {
    // MARK: Propriétés
    @IBOutlet weak var btn_Categorie1: UIButton!            // Bouton de sélection pour la catégorie 1
    @IBOutlet weak var btn_Categorie2: UIButton!            // Bouton de sélection pour la catégorie 2
    @IBOutlet weak var btn_Categorie3: UIButton!            // Bouton de sélection pour la catégorie 3
    @IBOutlet weak var btn_SoundControl: UIButton!          // Bouton permettant de lancer ou mettre en pause la lecture audio
    @IBOutlet weak var btn_StopSound: UIButton!             // Bouton permettant d'arrêter la lecture audio
    @IBOutlet weak var btn_Settings: UIButton!              // Bouton permettant d'accéder aux paramètres
    @IBOutlet weak var pv_Selection: UIPickerView!          // PickerView permettant de sélectionner la piste audio
    @IBOutlet weak var tf_Search: UITextField!              // Zone de texte permettant la recherche dans la PickerView
    @IBOutlet weak var tf_Houres: UITextField!              // Zone de texte définissant le nombre d'heure de la piste audio
    @IBOutlet weak var tf_Minutes: UITextField!             // Zone de texte définissant le nombre de minutes de la piste audio
    @IBOutlet weak var tf_Seconds: UITextField!             // Zone de texte définissant le nombre de secondes de la piste audio
    @IBOutlet weak var sw_Illimited: UISwitch!              // Switch définissant si la piste audio doit sans contrainte de temps
    
    let function = Function()                               // Constante regroupant les fonctions général
    
    var str_ConfigurationDatas = [String()]                 // Tableau contenant l'ensemble de la configuration
    var str_RecupDatas = [String()]                         // Tableau contenant l'ensemble des pistes audio
    var str_Categorie1Datas = [[String()]]                  // Tableau contenant l'ensemble des pistes audio de la catégorie 1
    var str_Categorie2Datas = [[String()]]                  // Tableau contenant l'ensemble des pistes audio de la catégorie 2
    var str_Categorie3Datas = [[String()]]                  // Tableau contenant l'ensemble des pistes audio de la catégorie 3
    var str_ActiveCategorieDatas = [[String()]]             // Tableau contenant l'ensemble des pistes audio de la catégorie active
    var str_SearchResults = [String()]                      // Tableau contenant les résultats de recherche
    var str_FileName = String()                             // Chaîne de caractère contenant le nom de la piste audio sélectionnée
    var int_ActiveCategorie = Int()                         // Nombre entier définissant la catégorie active
    var int_Duration = Int()                                // Nombre entier définissant la durée totale de la lecture
    var int_Counter = Int()                                 // Nombre entier définissant la durée actuellement passé à lire une piste
    var int_Categorie1Count = Int()                         // Nombre entier permettant la vérification des données de la catégorie 1
    var int_Categorie2Count = Int()                         // Nombre entier permettant la vérification des données de la catégorie 2
    var int_Categorie3Count = Int()                         // Nombre entier permettant la vérification des données de la catégorie 3
    var bool_IsSearching = Bool()                           // Booléen définissant si une recherche est en cours
    var bool_IsPlaying = Bool()                             // Booléen définissant si une lecture est active
    var bool_IsPause = Bool()                               // Booléen définissant si une lecture est en pause
    var bool_IsFadeInActivated = Bool()                     // Booléen définissant si la fonction de Fade In doit être utilisée
    var bool_IsFadeOutActivated = Bool()                    // Booléen définissant si la fonction de Fade Out doit être utilisée
    
    var playerItem:AVPlayerItem?                            // Variable définissant la piste à lire
    var player:AVPlayer?                                    // Lecteur utilisé pour lire la piste
    var mainTimer:NSTimer?                                  // Timer utilisé pour lire la piste sur un temps défini
    var fadeTimer:NSTimer?                                  // Timer utilisé pour effectué une action de fade in/out sur la piste en cours de lecture
    
    // MARK: Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assignation des valeurs de bases
        str_ConfigurationDatas = function.getConfiguration().componentsSeparatedByString("\n")      // Récupère la configuration de l'application
        
        int_ActiveCategorie = 1                             // Défini la catégorie 1 comme catégorie active
        bool_IsSearching = false                            // Indique qu'aucune recherche n'est en cours
        bool_IsPause = false                                // Indique que le lecteur n'est pas en pause

        updateGlobalConfiguration()                         // Initialisation des tableaux des différentes catégories
        
        // Préparation de l'affichage
        tf_Houres.enabled = false                           // Vérouille la zone de texte des heures
        tf_Minutes.enabled = false                          // Vérouille la zone de texte des minutes
        tf_Seconds.enabled = false                          // Vérouille la zone de texte des secondes

        pv_Selection.delegate = self                        // Initialise la Picker View
        
        setButtonFormat(btn_Categorie1)                     // Modifie le format du bouton de la catégorie 1
        setButtonFormat(btn_Categorie2)                     // Modifie le format du bouton de la catégorie 2
        setButtonFormat(btn_Categorie3)                     // Modifie le format du bouton de la catégorie 3
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
            updateTimesTextField(function.searchInTable(str_SearchResults, table_Data: str_ActiveCategorieDatas, exact_Value: str_SearchResults[row])!)   // Met à jour les zones de texts concernant les minutes et secondes
            str_FileName = str_SearchResults[row]
            return str_SearchResults[row]                                                                                        // Retourne les résultats de la recherche
        }
    }
    
    // MARK: Action
    
    // Lance la lecture
    @IBAction func SoundControl(sender: AnyObject) {
        if btn_SoundControl.currentImage == UIImage(named: "PlayButton") {                                     // Vérifie si la fonction demandée est la pause ou la lecture
            if bool_IsPlaying == true {                                                                        // Vérifie si une lecture est déjà en cours
                bool_IsPause = false                                                                           // Indique que la lecture à été reprise
                player?.play()                                                                                 // Relance la lecture
            } else {
                let urlForStream = NSURL(string: str_ConfigurationDatas[0] + "StreamAudioFile.php?filePath=Audio/" + String(int_ActiveCategorie) + "/" + str_FileName + ".wav")                 // Construction de l'url pour lancer le streaming depuis la page PHP
                playerItem = AVPlayerItem(URL: urlForStream!)                                                  // Assigne le fichier à lire selon l'url précedente

                player=AVPlayer(playerItem: playerItem!)                                                       // Assigne le fichier à lire précedent au lecteur
                
                if sw_Illimited.on == true {                                                                   // Dans le cas ou la lecture se fait sans limite de temps
                    player?.actionAtItemEnd = .None                                                            // Défini qu'aucune action n'est menée à la fin de la lecture
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.loopPlayerItem), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)            // Création de la notification qui va lancer la fonction pour répeter la lecture une fois terminée
                } else {
                    int_Duration = getCustomDuration()                                                      // Récupère la durée personnalisé
                    int_Counter = 0                                                                         // Assigne la valeur de base au compteur
                    mainTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.timerFunction), userInfo: nil, repeats: true)
                    player?.actionAtItemEnd = .None                                                         // Défini qu'aucune action n'est menée à la fin de la lecture
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.loopPlayerItem), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)        // Création de la notification qui va lancer la fonction pour répeter la lecture une fois terminée
                }
                
                player!.play()                                                                                  // Lancement de la lecture

                // Lance la fonction de Fade In si cette dernière est activée
                if bool_IsFadeInActivated == true {
                    player?.volume = 0                                                                          // Défini que le volume initial du lecteur est nul
                    fadeTimer = NSTimer.scheduledTimerWithTimeInterval(0.29, target: self, selector: #selector(ViewController.fadeInFunction), userInfo: nil, repeats: true)
                }
                
                bool_IsPlaying = true                                                                           // Indique qu'une lecture est en cours
            }
            btn_SoundControl.setImage(UIImage(named: "PauseButton"), forState: .Normal)                         // Modifie l'image du bouton SoundControl
        } else {
            player?.pause()                                                                                     // Met en pause la lecture
            bool_IsPause = true                                                                                 // Indique que la lecture est en pause
            btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)                          // Modifie l'image du bouton SoundControl
        }
    }
    
    // Arrête la lecture
    @IBAction func stopSound(sender: AnyObject) {
        if bool_IsFadeOutActivated == true && sw_Illimited.on == true {
            fadeTimer = NSTimer.scheduledTimerWithTimeInterval(0.29, target: self, selector: #selector(ViewController.fadeOutFunction), userInfo: nil, repeats: true)   // Initialise le timer pour la fonction de Fade Out
        } else {
            player?.pause()                                                             // Arrète la lecture
            bool_IsPlaying = false                                                      // Indique que la lecture est terminée
            bool_IsPause = false                                                        // Indique que la lecture n'est pas en pause
            mainTimer?.invalidate()                                                     // Arrete le timer principale
            fadeTimer?.invalidate()                                                     // Arrete le timer secondaire
            btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)  // Modifie l'image du bouton SoundControl
        }
    }
    
    // Action effectuée lors du changement de valeur du PickerView
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if bool_IsSearching == false {                                                                                           // Vérifie qu'une recherche n'est pas en cours
            updateTimesTextField(str_ActiveCategorieDatas[row])                                                                  // Met à jour les textfields de temps selon la donnée sélectionnée
        } else {                                                                                                                 // Dans le cas de recherche
            updateTimesTextField(function.searchInTable(str_SearchResults, table_Data: str_ActiveCategorieDatas, exact_Value: str_SearchResults[row])!)  // Met à jour les textfields de temps selon la donnée
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
        if sw_Illimited.on == true {        // Désactive les textfield de temps et indique que la lecture est illimité
            tf_Houres.enabled = false
            tf_Minutes.enabled = false
            tf_Seconds.enabled = false
        } else {                            // Active les textfield de temps si la lecture est illimité
            tf_Houres.enabled = true
            tf_Minutes.enabled = true
            tf_Seconds.enabled = true
        }
    }
    
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
                if String(Int(x[1])! / 60).containsString(str_SearchText!) {        // Converti la durée en minutes et dans le cas ou la durée est semblable
                    str_SearchResults.append(x[0])                                  // Ajoute le nom au tableau de la recherche
                }
            }
        }
        
        pv_Selection.reloadAllComponents()                      // Recharge le PickerView
    }
    
    // Vérification des zone de textes concernant la durée lors de la modification par l'utilisateur
    @IBAction func checkCustomDuration(sender: AnyObject) {
        // Déclaration des variables de temps et assigantion des valeurs correspondante
        var int_Houres = function.checkTextBoxNumFormat(tf_Houres)
        var int_Minutes = function.checkTextBoxNumFormat(tf_Minutes)
        var int_Seconds = function.checkTextBoxNumFormat(tf_Seconds)
        
        // Traitement du nombre de secondes éxedentaire si nécessaire
        if int_Seconds > 60 {
            int_Minutes = int_Minutes + (int_Seconds / 60)          // Incrémente le nombre de minutes totale par le nombre de secondes éxedentaires
            int_Seconds = int_Seconds % 60                          // Retourne le nombre réel de secondes
        }
        
        // Traitement du nombre de minutes éxedentaire si nécessaire
        if int_Minutes > 60 {
            int_Houres = int_Houres + (int_Minutes / 60)            // Incrémente le nombre d'heures par le nombre de minutes éxedentaires
            int_Minutes = int_Minutes % 60                          // Retourne le nombre réel de minutes
        }
        
        // Défini la valeur des zones de texts
        tf_Houres.text = function.defineNumericValueFormat(int_Houres)
        tf_Minutes.text = function.defineNumericValueFormat(int_Minutes)
        tf_Seconds.text = function.defineNumericValueFormat(int_Seconds)
    }
    
    
    // MARK: Navigation
    
    // Action effectué lors de la transition d'une autre page à celle-ci
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {
        str_ConfigurationDatas = function.getConfiguration().componentsSeparatedByString("\n")      // Mise à jour de la configuration
        
        updateGlobalConfiguration()             // Met à jours les tableaux des catégories
        
        // Réinitialise les tableaux contenant les données des différentes catégories
        str_Categorie1Datas = str_Categorie1Datas.reverse()
        str_Categorie2Datas = str_Categorie2Datas.reverse()
        str_Categorie3Datas = str_Categorie3Datas.reverse()
        
        pv_Selection.reloadAllComponents()      // Recharge les données du Picker View
    }
    
    // MARK: Fonction
    
    /***************************************************************/
    /* Nom : updateGlobalConfiguration                             */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Met à jour la configuration globale           */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func updateGlobalConfiguration () {
        // Récupèration des données et les places dans le tableau str_RecupDatas
        str_RecupDatas = function.getListOfAudioFiles(str_ConfigurationDatas[0])
        
        // Préparation des variables
        int_Categorie1Count = 0
        int_Categorie2Count = 0
        int_Categorie3Count = 0
        
        for x in str_RecupDatas {
            switch x.componentsSeparatedByString("-")[2] {                        // Défini dans quelle tableau les données seront entrées selon la catégorie
            case "2":
                str_Categorie2Datas.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 2 correspondant
                int_Categorie2Count += 1                                          // Incrémente la variable contenant la quantité de données insérées pour la catégorie 2
            case "3":
                str_Categorie3Datas.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 3 correspondant
                int_Categorie3Count += 1                                          // Incrémente la variable contenant la quantité de données insérées pour la catégorie 3
            default:
                str_Categorie1Datas.append(x.componentsSeparatedByString("-"))    // Ajout des détails dans le tableau de la catégorie 1 correspondant
                int_Categorie1Count += 1                                          // Incrémente la variable contenant la quantité de données insérées pour la catégorie 1
            }
        }
        
        // Vérifie que le bon nombre de donnée ont été rentrée
        if str_RecupDatas.count < str_Categorie1Datas.count + str_Categorie2Datas.count + str_Categorie3Datas.count {
            for _ in str_Categorie1Datas {                              // Parcours le tableau de la catégorie 1
                if str_Categorie1Datas.count > int_Categorie1Count {    // Verifie que le nombre de données contenu est différent du nombre de données insérées
                    str_Categorie1Datas.removeFirst()                   // Retire l'actuel valeur
                } else {
                    break                                               // Sort de la boucle
                }
            }
            
            for _ in str_Categorie2Datas {                              // Parcours le tableau de la catégorie 2
                if str_Categorie2Datas.count > int_Categorie2Count {    // Verifie que le nombre de données contenu est différent du nombre de données insérées
                    str_Categorie2Datas.removeFirst()                   // Retire l'actuel valeur
                } else {
                    break                                               // Sort de la boucle
                }
            }
            
            for _ in str_Categorie3Datas {                              // Parcours le tableau de la catégorie 3
                if str_Categorie3Datas.count > int_Categorie3Count {    // Verifie que le nombre de données contenu est différent du nombre de données insérées
                    str_Categorie3Datas.removeFirst()                   // Retire l'actuel valeur
                } else {
                    break                                               // Sort de la boucle
                }
            }
        }
        
        // Initialise le tableau selon la catégorie active
        switch int_ActiveCategorie {
        case 2:
            str_ActiveCategorieDatas = str_Categorie2Datas
        case 3:
            str_ActiveCategorieDatas = str_Categorie3Datas
        default:
            str_ActiveCategorieDatas = str_Categorie1Datas
        }
        
        // Défini si la fonction de Fade In est activée
        if str_ConfigurationDatas[1] == "true" {
            bool_IsFadeInActivated = true
        } else {
            bool_IsFadeInActivated = false
        }
        
        // Défini si la fonction de Fade Out est activée
        if str_ConfigurationDatas[2] == "true" {
            bool_IsFadeOutActivated = true
        } else {
            bool_IsFadeOutActivated = false
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
        var detailTable = function.convertSecToHHMMSS(table_Data)   // Converti la durée en minutes et secondes
        
        tf_Houres.text = detailTable[0]                             // Met à jour la valeur contenu par la textfield des heures
        tf_Minutes.text = detailTable[1]                            // Met à jour la valeur contenu par la textfield des minutes
        tf_Seconds.text = detailTable[2]                            // Met à jour la valeur contenu par la textfield des secondes
    }
    
    /***************************************************************/
    /* Nom : loopPlayerItem                                        */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Relance la lecture                            */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func loopPlayerItem () {
        let speceficTimeToGo = CMTime(seconds: 0.0, preferredTimescale: 1)         // Temps spécifique pour relancer la lecture
        self.player?.seekToTime(speceficTimeToGo)                                  // Défini la position de lecture du lecteur selon le temps spécifique
        self.player!.play()                                                        // Relance la lecture
    }
    
    /***************************************************************/
    /* Nom : playerItemDidReachEnd                                 */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Indique que la lecture est terminée           */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func playerItemDidReachEnd () {
        bool_IsPlaying = false                                                      // Défini qu'aucune lecture n'est en cours
        btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)  // Modifie l'image du bouton SoundControl
    }
    
    /***************************************************************/
    /* Nom : setButtonFormat                                       */
    /***************************************************************/
    /* Paramètres : button : Bouton à mettre au format             */
    /***************************************************************/
    /* Description : Applique une bordure au bouton cible          */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func setButtonFormat (button: UIButton) {
        button.layer.borderWidth = 2                                    // Défini la largeur de la bordure
        button.layer.borderColor = UIColor.lightGrayColor().CGColor     // Défini la couleur de la bordure
    }
    
    /***************************************************************/
    /* Nom : getCustomDuration                                     */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Défini la durée entrée par l'utilisateur      */
    /***************************************************************/
    /* Retour : Nombre de secondes totale                          */
    /***************************************************************/
    func getCustomDuration () -> Int{
        let int_Seconds = Int(tf_Seconds.text!)                             // Récupère le nombre de secondes
        let int_Minutes = Int(tf_Minutes.text!)                             // Récupère le nombre de minutes
        let int_Houres = Int(tf_Houres.text!)                               // Récupère le nombre d'heures
        
        return int_Seconds! + (int_Minutes! * 60) + (int_Houres! * 3600)    // Additionne l'ensemble des temps et retourne le temps totale en secondes
    }
    
    /***************************************************************/
    /* Nom : timerFunction                                         */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Fonction se lancant à chaque tic du timer     */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func timerFunction() {
        if bool_IsPause == false {                                                          // Vérifie que la lecture n'est pas en pause
            int_Counter += 1                                                                // Incrémente le compteur
            if int_Counter >= int_Duration {                                                // Vérifie si la lecture touche à son terme
                mainTimer?.invalidate()                                                     // Arrète le timer
                player?.pause()                                                             // Met en pause la lecture
                bool_IsPlaying = false                                                      // Défini qu'aucune lecture n'est en cours
                btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)  // Modifie l'image du bouton SoundControl
            }
            
            if int_Duration - int_Counter == 30 && bool_IsFadeOutActivated == true{         // Dans le cas ou l'option Fade Out est activée et que la durée restante est de 30 secondes
                fadeTimer = NSTimer.scheduledTimerWithTimeInterval(0.29, target: self, selector: #selector(ViewController.fadeOutFunction), userInfo: nil, repeats: true)   // Initialise le timer pour la fonction de Fade Out
            }
            print(int_Counter)
        }
    }
    
    /***************************************************************/
    /* Nom : fadeInFunction                                        */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Permet de monter le volume progressivement du */
    /*               volume de base (0 normalement) à 1            */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func fadeInFunction() {
        if bool_IsPause == false {                  // Vérifie que le lecteur n'est pas en pause
            if player?.volume < 1 {                 // Vérifie que le volume n'a pas encore atteint la valeur maximal
                player!.volume += 0.01              // Incrémente le volume du lecteur
            } else {
                fadeTimer?.invalidate()             // Arrete le timer de fade
            }
        }
    }
    
    /***************************************************************/
    /* Nom : fadeInFunction                                        */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Permet de baisser le volume progressivement du*/
    /*               volume de base (1 normalement) à 0, puis      */
    /*               arrete le lecteur                             */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func fadeOutFunction() {
        if bool_IsPause == false {                  // Vérifie que le lecteur n'est pas en pause
            if player?.volume > 0 {                 // Vérifie que le volume n'a pas encore atteint la valeur minimale
                player!.volume -= 0.01              // Décrémente le volume du lecteur
            } else {
                fadeTimer?.invalidate()             // Arrete le timer de fade
                player?.pause()                     // Arrete le lecteur
                bool_IsPlaying = false              // Défini qu'aucune lecture n'est en cours
                bool_IsPause = false                // Défini que le lecteur n'est pas en pause
                btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)  // Modifie l'image du bouton SoundControl
            }
        }
    }
}
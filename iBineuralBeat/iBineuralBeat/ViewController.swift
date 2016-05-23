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
    
    // Boutons de sélection de la catégorie
    @IBOutlet weak var btn_Categorie1: UIButton!
    @IBOutlet weak var btn_Categorie2: UIButton!
    @IBOutlet weak var btn_Categorie3: UIButton!
    
    // Bouton permettant la gestion de la lecture audio
    @IBOutlet weak var btn_SoundControl: UIButton!
    @IBOutlet weak var btn_StopSound: UIButton!
    
    // Bouton permettant d'accéder aux paramètres
    @IBOutlet weak var btn_Settings: UIButton!
    
    // PickerView permettant de sélectionner la piste audio
    @IBOutlet weak var pv_Selection: UIPickerView!
    
    // Zone de texte permettant la recherche dans la PickerView
    @IBOutlet weak var tf_Search: UITextField!
    
    // Zone de texte s'occupant de la durée de la piste audio
    @IBOutlet weak var tf_Houres: UITextField!
    @IBOutlet weak var tf_Minutes: UITextField!
    @IBOutlet weak var tf_Seconds: UITextField!
    
    // Switch définissant si la piste audio doit sans contrainte de temps
    @IBOutlet weak var sw_Illimited: UISwitch!
    
    // Constante regroupant les fonctions général
    let function = Function()
    
    // Tableau contenant l'ensemble de la configuration
    var str_ConfigurationDatas = [String()]
    
    // Tableau contenant l'ensemble des pistes audio
    var str_RecupDatas = [String()]
    
    // Tableau contenant l'ensemble des pistes audio spécifiques à une catégorie
    var str_Categorie1Datas = [[String()]]
    var str_Categorie2Datas = [[String()]]
    var str_Categorie3Datas = [[String()]]
    
    // Tableau contenant l'ensemble des pistes audio de la catégorie active
    var str_ActiveCategorieDatas = [[String()]]
    
    // Tableau contenant les résultats de recherche
    var str_SearchResults = [String()]
    
    // Chaîne de caractère contenant le nom de la piste audio sélectionnée
    var str_FileName = String()
    
    // Nombre entier définissant la catégorie active
    var int_ActiveCategorie = Int()
    
    // Nombre entier définissant la durée totale de la lecture
    var int_Duration = Int()
    
    // Nombre entier utiliser pour définir la durée actuellement passé à lire une piste
    var int_Counter = Int()
    
    // Nombre entier permettant la vérification des données des différentes catégories
    var int_Categorie1Count = Int()
    var int_Categorie2Count = Int()
    var int_Categorie3Count = Int()
    
    // Booléen définissant si une recherche est en cours
    var bool_IsSearching = Bool()
    
    // Booléen définissant le statut de la lecture
    var bool_IsPlaying = Bool()
    var bool_IsPause = Bool()
    
    // Booléen définissant si les fonction de Fade In/Out doivent être utilisées
    var bool_IsFadeInActivated = Bool()
    var bool_IsFadeOutActivated = Bool()
    
    // Variable utilisé pour la lecture
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    
    // Timer utilisé durant la lecture
    var mainTimer:NSTimer?
    var fadeTimer:NSTimer?
    
    // MARK: Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Récupère la configuration de l'application
        str_ConfigurationDatas = function.getConfiguration()
        
        // Défini la catégorie 1 comme catégorie active
        int_ActiveCategorie = 1
        
        // Indique qu'aucune recherche n'est en cours
        bool_IsSearching = false
        
        // Indique que le lecteur n'est pas en pause
        bool_IsPause = false
        
        // Initialisation des tableaux des différentes catégories
        updateGlobalConfiguration()
        
        // Vérouille les zones de textes concernant la durée
        tf_Houres.enabled = false
        tf_Minutes.enabled = false
        tf_Seconds.enabled = false
        
        // Initialise la Picker View
        pv_Selection.delegate = self
        
        // Modifie le format des boutons concernant les catégories
        setButtonFormat(btn_Categorie1)
        setButtonFormat(btn_Categorie2)
        setButtonFormat(btn_Categorie3)
        
        // Met en évidence le bouton de la catégorie 1 (active par défaut)
        btn_Categorie1.backgroundColor = UIColor.lightGrayColor()
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
        if bool_IsSearching == false {
            // Retourne le nombre de piste audio selon la catégorie
            return str_ActiveCategorieDatas.count
        } else {
            // Retourne le nombre de résultats obtenu
            return str_SearchResults.count
        }
    }
    
    // Défini les données que le PickerView va afficher et les actions effectuées lors du changement de valeur
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if bool_IsSearching == false {
            // Met à jour les zones de texts concernant la durée
            updateTimesTextField(str_ActiveCategorieDatas[row])
            
            // Défini que le nom du fichier est celui sélectionné
            str_FileName = str_ActiveCategorieDatas[row][0]
            
            // Retourne les noms des séquences de la catégorie active
            return str_ActiveCategorieDatas[row][0]
        } else {
            // Met à jour les zones de texts concernant la durée
            updateTimesTextField(function.searchInTable(str_ActiveCategorieDatas, str_Value: str_SearchResults[row])!)
            
            // Défini que le nom du fichier est celui sélectionné
            str_FileName = str_SearchResults[row]
            
            // Retourne les résultats de la recherche
            return str_SearchResults[row]
        }
    }
    
    // MARK: Action
    
    // Lance la lecture
    @IBAction func SoundControl(sender: AnyObject) {
        // Vérifie si la fonction demandée est la pause ou la lecture
        if btn_SoundControl.currentImage == UIImage(named: "PlayButton") {
            if bool_IsPlaying == true {
                // Indique que la lecture à été reprise
                bool_IsPause = false
                
                // Relance la lecture
                player?.play()
            } else {
                // Construction de l'url pour lancer le streaming depuis la page PHP
                let urlForStream = NSURL(string: str_ConfigurationDatas[0] + "StreamAudioFile.php?filePath=Audio/"
                    + String(int_ActiveCategorie) + "/" + str_FileName + ".wav")
                
                // Défini le fichier à lire selon l'url précedente
                playerItem = AVPlayerItem(URL: urlForStream!)
                
                // Assigne le fichier à lire précedent au lecteur
                player=AVPlayer(playerItem: playerItem!)
                
                if sw_Illimited.on == true {
                    // Défini qu'aucune action n'est menée à la fin de la lecture
                    player?.actionAtItemEnd = .None
                    
                    // Création de la notification qui va lancer la fonction pour répeter la lecture une fois terminée
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.loopPlayerItem), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
                } else {
                    // Récupère la durée personnalisé
                    int_Duration = getCustomDuration()
                    
                    // Assigne la valeur de base au compteur
                    int_Counter = 0
                    
                    // Initialise le timer principale
                    mainTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.timerFunction),
                                                                       userInfo: nil, repeats: true)
                    
                    // Défini qu'aucune action n'est menée à la fin de la lecture
                    player?.actionAtItemEnd = .None
                    
                    // Création de la notification qui va lancer la fonction pour répeter la lecture une fois terminée
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.loopPlayerItem), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
                }
                
                // Lancement de la lecture
                player!.play()
                
                // Lance la fonction de Fade In si cette dernière est activée
                if bool_IsFadeInActivated == true {
                    // Défini que le volume initial du lecteur est nul
                    player?.volume = 0
                    
                    // Initialise le timer de fade
                    fadeTimer = NSTimer.scheduledTimerWithTimeInterval(0.29, target: self, selector: #selector(ViewController.fadeInFunction), userInfo: nil, repeats: true)
                }
                
                // Indique qu'une lecture est en cours
                bool_IsPlaying = true
            }
            
            // Modifie l'image du bouton SoundControl
            btn_SoundControl.setImage(UIImage(named: "PauseButton"), forState: .Normal)
        } else {
            // Met en pause la lecture
            player?.pause()
            
            // Indique que la lecture est en pause
            bool_IsPause = true
            
            // Modifie l'image du bouton SoundControl
            btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)
        }
    }
    
    // Arrête la lecture
    @IBAction func stopSound(sender: AnyObject) {
        if bool_IsFadeOutActivated == true && sw_Illimited.on == true {
            // Désactive le bouton de lancement de la lecture
            btn_SoundControl.enabled = false
            
            // Initialise le timer pour la fonction de Fade Out
            fadeTimer = NSTimer.scheduledTimerWithTimeInterval(0.29, target: self, selector: #selector(ViewController.fadeOutFunction), userInfo: nil, repeats: true)
        } else {
            // Arrète la lecture
            player?.pause()
            
            // Indique que la lecture est terminée
            bool_IsPlaying = false
            
            // Indique que la lecture n'est pas en pause
            bool_IsPause = false
            
            // Arrete le timer principale
            mainTimer?.invalidate()
            
            // Arrete le timer secondaire
            fadeTimer?.invalidate()
            
            // Modifie l'image du bouton SoundControl
            btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)
        }
    }
    
    // Sélectionne la catégorie 1
    @IBAction func selectCategorie1(sender: AnyObject) {
        // Défini la catégorie 1 comme catégorie active
        int_ActiveCategorie = 1
        
        // Assigne les valeurs de la catégorie 1 au tableau de la catégorie active
        str_ActiveCategorieDatas = str_Categorie1Datas
        
        // Modifie la couleur des autres boutons concernant la catégorie
        btn_Categorie2.backgroundColor = UIColor.init(red: 0.74748, green: 0.769587, blue: 0.771041, alpha: 1)
        btn_Categorie3.backgroundColor = UIColor.init(red: 0.74748, green: 0.769587, blue: 0.771041, alpha: 1)
        
        // Met en évidence le bouton de la catégorie active
        btn_Categorie1.backgroundColor = UIColor.lightGrayColor()
        
        // Recharge la Picker View
        pv_Selection.reloadAllComponents()
    }
    
    // Sélectionne la catégorie 2
    @IBAction func selectCategorie2(sender: AnyObject) {
        // Sélectionne la catégorie 2 comme catégorie active
        int_ActiveCategorie = 2
        
        // Assigne les valeurs de la catégorie 2 au tableau de la catégorie active
        str_ActiveCategorieDatas = str_Categorie2Datas
        
        // Modifie la couleur des autres boutons concernant la catégorie
        btn_Categorie1.backgroundColor = UIColor.init(red: 0.74748, green: 0.769587, blue: 0.771041, alpha: 1)
        btn_Categorie3.backgroundColor = UIColor.init(red: 0.74748, green: 0.769587, blue: 0.771041, alpha: 1)
        
        // Met en évidence le bouton de la catégorie active
        btn_Categorie2.backgroundColor = UIColor.lightGrayColor()
        
        // Recharge la Picker View
        pv_Selection.reloadAllComponents()
    }
    
    // Sélectionne la catégorie 3
    @IBAction func selectCategorie3(sender: AnyObject) {
        // Sélectionne la catégorie 3 comme catégorie active
        int_ActiveCategorie = 3
        
        // Assigne les valeurs de la catégorie 3 au tableau de la catégorie active
        str_ActiveCategorieDatas = str_Categorie3Datas
        
        // Modifie la couleur des autres boutons concernant la catégorie
        btn_Categorie2.backgroundColor = UIColor.init(red: 0.74748, green: 0.769587, blue: 0.771041, alpha: 1)
        btn_Categorie1.backgroundColor = UIColor.init(red: 0.74748, green: 0.769587, blue: 0.771041, alpha: 1)
        
        // Met en évidence le bouton de la catégorie active
        btn_Categorie3.backgroundColor = UIColor.lightGrayColor()
        
        // Recharge la Picker View
        pv_Selection.reloadAllComponents()
    }
    
    // Défini si la lecture doit se faire de manière infini
    @IBAction func isDurationIllimited(sender: AnyObject) {
        if sw_Illimited.on == true {
            // Désactive les textfield de temps
            tf_Houres.enabled = false
            tf_Minutes.enabled = false
            tf_Seconds.enabled = false
        } else {
            // Active les textfield de temps
            tf_Houres.enabled = true
            tf_Minutes.enabled = true
            tf_Seconds.enabled = true
        }
    }
    
    // Fonction s'occupant de la recherche dans la catégorie active
    @IBAction func searchInActiveCategorie(sender: AnyObject) {
        // Récupère le critère de recherche
        let str_SearchText = tf_Search.text
        
        // Réinitialise le tableau de recherche
        str_SearchResults.removeAll()
        
        // Active ou désactive les boutons de sélection des catégories selon le critère de recherche
        if str_SearchText == "" || str_SearchText == nil {
            btn_Categorie1.enabled = true
            btn_Categorie2.enabled = true
            btn_Categorie3.enabled = true
            
            // Indique qu'aucune recherche n'est en cours
            bool_IsSearching = false
        } else {
            btn_Categorie1.enabled = false
            btn_Categorie2.enabled = false
            btn_Categorie3.enabled = false
            
            // Indique que la recherche est en cours
            bool_IsSearching = true
        }
        
        // Défini si la recherche se base sur le nom ou la durée
        if Int(str_SearchText!) == nil {
            // Parcours le tableau contenant les séquences de la catégorie active
            for x in str_ActiveCategorieDatas {
                if x[0].containsString(str_SearchText!) {
                    // Ajoute le nom au tableau de la recherche
                    str_SearchResults.append(x[0])
                }
            }
        } else {
            for x in str_ActiveCategorieDatas {
                // Converti la durée en minutes et la compare avec le critère de recherche
                if String(Int(x[1])! / 60).containsString(str_SearchText!) {
                    str_SearchResults.append(x[0])
                }
            }
        }
        
        // Recharge le PickerView
        pv_Selection.reloadAllComponents()
    }
    
    // Vérification des zone de textes concernant la durée lors de la modification par l'utilisateur
    @IBAction func checkCustomDuration(sender: AnyObject) {
        // Déclaration des variables de temps et assigantion des valeurs correspondante
        var int_Houres = function.checkTextBoxNumFormat(tf_Houres)
        var int_Minutes = function.checkTextBoxNumFormat(tf_Minutes)
        var int_Seconds = function.checkTextBoxNumFormat(tf_Seconds)
        
        // Traitement du nombre de secondes éxedentaire
        if int_Seconds > 60 {
            // Incrémente le nombre de minutes totale par le nombre de secondes éxedentaires
            int_Minutes = int_Minutes + (int_Seconds / 60)
            
            // Retourne le nombre réel de secondes
            int_Seconds = int_Seconds % 60
        }
        
        // Traitement du nombre de minutes éxedentaire
        if int_Minutes > 60 {
            // Incrémente le nombre d'heures par le nombre de minutes éxedentaires
            int_Houres = int_Houres + (int_Minutes / 60)
            
            // Retourne le nombre réel de minutes
            int_Minutes = int_Minutes % 60
        }
        
        // Défini la valeur des zones de texts
        tf_Houres.text = function.defineNumericValueFormat(int_Houres)
        tf_Minutes.text = function.defineNumericValueFormat(int_Minutes)
        tf_Seconds.text = function.defineNumericValueFormat(int_Seconds)
    }
    
    
    // MARK: Navigation
    
    // Action effectué lors de la transition d'une autre page à celle-ci
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {
        // Mise à jour du tableau contenant la configuration
        str_ConfigurationDatas = function.getConfiguration()
        
        // Met à jours les tableaux des catégories et paramètres
        updateGlobalConfiguration()
        
        // Recharge les données du Picker View
        pv_Selection.reloadAllComponents()
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
        // Récupèration des données
        str_RecupDatas = function.getListOfAudioFiles(str_ConfigurationDatas[0])
        
        // Préparation des variables
        int_Categorie1Count = 0
        int_Categorie2Count = 0
        int_Categorie3Count = 0
        
        for x in str_RecupDatas {
            // Défini dans quelle tableau les données seront entrées selon la catégorie
            switch x.componentsSeparatedByString("-")[2] {
            case "2":
                // Ajout des détails dans le tableau de la catégorie correspondante
                str_Categorie2Datas.append(x.componentsSeparatedByString("-"))
                
                // Incrémente la variable contenant la quantité de données insérées pour la catégorie actuel
                int_Categorie2Count += 1
            case "3":
                str_Categorie3Datas.append(x.componentsSeparatedByString("-"))
                int_Categorie3Count += 1
            default:
                str_Categorie1Datas.append(x.componentsSeparatedByString("-"))
                int_Categorie1Count += 1
            }
        }
        
        // Vérifie que le bon nombre de donnée ont été rentrée
        if str_RecupDatas.count < str_Categorie1Datas.count + str_Categorie2Datas.count + str_Categorie3Datas.count {
            // Parcours le tableau de la catégorie 1
            for _ in str_Categorie1Datas {
                // Verifie que le nombre de données contenu est différent du nombre de données insérées
                if str_Categorie1Datas.count > int_Categorie1Count {
                    // Retire l'actuel valeur
                    str_Categorie1Datas.removeFirst()
                } else {
                    // Sort de la boucle
                    break
                }
            }
            
            // Parcours le tableau de la catégorie 2
            for _ in str_Categorie2Datas {
                if str_Categorie2Datas.count > int_Categorie2Count {
                    str_Categorie2Datas.removeFirst()
                } else {
                    break
                }
            }
            
            // Parcours le tableau de la catégorie 3
            for _ in str_Categorie3Datas {
                if str_Categorie3Datas.count > int_Categorie3Count {
                    str_Categorie3Datas.removeFirst()
                } else {
                    break
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
    /* Nom : updateTimesTextField                                  */
    /***************************************************************/
    /* Paramètres : str_DataTable : Tableau contenant les données  */
    /*                           utilisées                         */
    /***************************************************************/
    /* Description : Met à jours les différents champs de temps    */
    /***************************************************************/
    /* Retour : -                                                  */
    /***************************************************************/
    func updateTimesTextField (str_DataTable: [String]) {
        // Convertie les secondes en heures, minutes et secondes
        var str_DetailTable = function.convertSecToHHMMSS(str_DataTable)
        
        // Met à jour les valeurs contenu par les zones de textes concernant la durée
        tf_Houres.text = str_DetailTable[0]
        tf_Minutes.text = str_DetailTable[1]
        tf_Seconds.text = str_DetailTable[2]
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
        // Position ou doit retourner le lecteur
        let TimeToGo = CMTime(seconds: 0.0, preferredTimescale: 1)
        
        // Défini la position de lecture du lecteur
        self.player?.seekToTime(TimeToGo)
        
        // Relance la lecture
        self.player!.play()
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
        // Défini la largeur de la bordure
        button.layer.borderWidth = 2
        
        // Défini la couleur de la bordure
        button.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    /***************************************************************/
    /* Nom : getCustomDuration                                     */
    /***************************************************************/
    /* Paramètres : -                                              */
    /***************************************************************/
    /* Description : Défini la durée de lecture                    */
    /***************************************************************/
    /* Retour : Nombre de secondes totale                          */
    /***************************************************************/
    func getCustomDuration () -> Int{
        // Récupère les différentes valeurs
        let int_Seconds = Int(tf_Seconds.text!)
        let int_Minutes = Int(tf_Minutes.text!)
        let int_Houres = Int(tf_Houres.text!)
        
        // Additionne l'ensemble des temps et retourne le temps totale en secondes
        return int_Seconds! + (int_Minutes! * 60) + (int_Houres! * 3600)
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
        if bool_IsPause == false {
            // Incrémente le compteur
            int_Counter += 1
            
            // Vérifie si la lecture touche à son terme
            if int_Counter >= int_Duration {
                // Arrète le timer
                mainTimer?.invalidate()
                
                // Met en pause la lecture
                player?.pause()
                
                // Défini qu'aucune lecture n'est en cours
                bool_IsPlaying = false
                
                // Modifie l'image du bouton SoundControl
                btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)
            }
            
            // Dans le cas ou l'option Fade Out est activée et que la durée restante est de 30 secondes
            if int_Duration - int_Counter == 30 && bool_IsFadeOutActivated == true {
                // Initialise le timer pour la fonction de Fade Out
                fadeTimer = NSTimer.scheduledTimerWithTimeInterval(0.29, target: self, selector: #selector(ViewController.fadeOutFunction), userInfo: nil, repeats: true)
            }
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
                btn_SoundControl.enabled = true
                btn_SoundControl.setImage(UIImage(named: "PlayButton"), forState: .Normal)  // Modifie l'image du bouton SoundControl
            }
        }
    }
}
//
//  ConfigurationView.swift
//  iBineuralBeat
//
//  Created by Cédric Chambaz on 11.05.16.
//  Copyright © 2016 Cédric Chambaz. All rights reserved.
//

import UIKit
import Foundation

class ConfigurationView: UIViewController {
    // MARK: Propriétés
    @IBOutlet weak var btn_Save: UIBarButtonItem!                       // Bouton pour sauvegarder les données
    @IBOutlet weak var tf_ServerURL: UITextField!                       // Zone de text permettant l'édition de l'URL du serveur actif
    @IBOutlet weak var sw_FadeIn: UISwitch!                             // Switch définissant si l'option du Fade In est activée
    @IBOutlet weak var sw_FadeOut: UISwitch!                            // Switch définissant si l'option du Fade Out est activée
    
    var str_ConfigurationDatas = Function().getConfiguration().componentsSeparatedByString("\n")    // Variable contenant la configuration actuel
    var str_NewConfiguration = String()                                 // Variable contenant la nouvelle configuration
    var bool_IsFadeInActivated = Bool()                                 // Booléen définissant si l'option du Fade In est activé
    var bool_IsFadeOutActivated = Bool()                                // Booléen définissant si l'option du Fade Out est activé
    var str_Verification: String?                                       // Variable de vérification de l'URL du serveur
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        tf_ServerURL.text = str_ConfigurationDatas[0]                           // Assigne l'URL du serveur actif comme text pour la zone de texte correspondante
        
        if str_ConfigurationDatas[1] == "true" {
            bool_IsFadeInActivated = true
        } else {
            bool_IsFadeInActivated = false
        }
        
        if str_ConfigurationDatas[2] == "true" {
            bool_IsFadeOutActivated = true
        } else {
            bool_IsFadeOutActivated = false
        }
        
        sw_FadeIn.on = bool_IsFadeInActivated
        sw_FadeOut.on = bool_IsFadeOutActivated
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        str_NewConfiguration = tf_ServerURL.text! + "\n" + String(sw_FadeIn.on) + "\n" + String(sw_FadeOut.on)
        print(str_NewConfiguration)
        str_Verification = Function().ModavConfiguration(str_NewConfiguration)  // Récupère le résultat obtenu lors de la modification de l'URL du serveur
        if str_Verification!.containsString("Success") == true {                // Dans le cas ou le résultat est concluant
            Function().ModavConfiguration(str_NewConfiguration)                 // Modifie l'adresse du serveur
        } else {
            str_NewConfiguration = str_ConfigurationDatas[0] + "\n" + String(sw_FadeIn.on) + "\n" + String(sw_FadeOut.on)   // Dans le cas contraire, garde l'ancienne adresse et retourne sur la page principale
        }
    }
}

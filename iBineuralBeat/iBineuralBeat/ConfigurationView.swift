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
    
    // Bouton permettant de sauvegarder les données
    @IBOutlet weak var btn_Save: UIBarButtonItem!
    
    // Zone de text permettant l'édition de l'URL du serveur actif
    @IBOutlet weak var tf_ServerURL: UITextField!
    
    // Switch définissant si les options de Fade sont activés
    @IBOutlet weak var sw_FadeIn: UISwitch!
    @IBOutlet weak var sw_FadeOut: UISwitch!
    
    // Tableau contenant la configuration actuel
    var str_ConfigurationDatas = Function().getConfiguration()
    
    // Booléens définissant si les options de Fade sont activés
    var bool_IsFadeInActivated = Bool()
    var bool_IsFadeOutActivated = Bool()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Assigne l'URL du serveur actif comme text pour la zone de texte correspondante
        tf_ServerURL.text = str_ConfigurationDatas[0]
        
        // Converti la valeur contenu par la configuration concernant le Fade In en booléen
        if str_ConfigurationDatas[1] == "true" {
            bool_IsFadeInActivated = true
        } else {
            bool_IsFadeInActivated = false
        }
        
        // Converti la valeur contenu par la configuration concernant le Fade Out en booléen
        if str_ConfigurationDatas[2] == "true" {
            bool_IsFadeOutActivated = true
        } else {
            bool_IsFadeOutActivated = false
        }
        
        // Défini si l'option de Fade In/Out est activée
        sw_FadeIn.on = bool_IsFadeInActivated
        sw_FadeOut.on = bool_IsFadeOutActivated
    }
    
    // Modification de la configuration et retour sur la page principale
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        Function().modavConfiguration(tf_ServerURL.text! + "\n" + String(sw_FadeIn.on) + "\n" + String(sw_FadeOut.on))

    }
    
    // Masque le clavier lorsque l'utilisateur clique ailleur
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//
//  ViewController.swift
//  Test_AudioKit
//
//  Created by Cédric Chambaz on 13.04.16.
//  Copyright © 2016 Cédric Chambaz. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    // MARK: Propriétés
    @IBOutlet weak var textfield_Freq: UITextField!
    @IBOutlet weak var textfield_Amp: UITextField!
    @IBOutlet weak var textfield_FreqDual: UITextField!
    @IBOutlet weak var textfield_AmpDual: UITextField!
    @IBOutlet weak var textfield_Carrier: UITextField!
    @IBOutlet weak var textfield_ModIndex: UITextField!
    @IBOutlet weak var textfield_ModMulti: UITextField!
    @IBOutlet weak var btn_Change: UIButton!
    @IBOutlet weak var label_Type: UILabel!
    @IBOutlet weak var btn_Control: UIButton!
    @IBOutlet weak var btn_Stop: UIButton!
    
    // Différent type de séquence
    let Basic = AKOscillator()
    let FMOscillator = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))
    
    // Variables concernant Basic
    var Freq = 30               // Fréquence
    var Amp = 30                // Amplitude
    
    // Variables concernant FMOscillator
    var FreqFM = 24             // Fréquence
    var AmpFM = 30              // Amplitude
    var FM_Carrier = 2          // Fréquence du transporteur (=FreqFM * FM_Carrier)
    var FM_ModIndex = 5         // Modulation de l'amplitude (=FreqFM * FM_ModIndex)
    var FM_ModMulti = 0.3       // Modulation de la fréquence (=FM_ModIndex * FM_ModMulti)
    
    // Variables ne concernant pas diréctement les séquences
    var Selection = 0           // Choix de la séquence
    
    // MARK: Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise les propriétés de la séquence basic
        Basic.frequency = Double(Freq)
        Basic.amplitude = Double(Amp)
        
        // Initialise les propriétés de la séquence FM
        FMOscillator.baseFrequency = Double(FreqFM)
        FMOscillator.carrierMultiplier = Double(FM_Carrier)
        FMOscillator.modulationIndex = Double(FM_ModIndex)
        FMOscillator.modulatingMultiplier = Double(FM_ModMulti)
        FMOscillator.amplitude = Double(AmpFM)
        
        // Défini la séquence basic comme output par défaut
        AudioKit.output = Basic
        
        // Désactive le bouton Stop
        btn_Stop.enabled = false
        
        // Affiche les valeurs de bases dans les champs prévus à cette effet
        textfield_Freq.text = String(Freq)
        textfield_Amp.text = String(Amp)
        textfield_FreqDual.text = String(FreqFM)
        textfield_AmpDual.text = String(AmpFM)
        textfield_Carrier.text = String(FM_Carrier)
        textfield_ModIndex.text = String(FM_ModIndex)
        textfield_ModMulti.text = String(FM_ModMulti)
        label_Type.text = "Basic"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Contrôle du son
    @IBAction func SoundControl(sender: AnyObject) {
        // Mise à jour des paramêtres de la séquence Basic
        Basic.frequency = Double(textfield_Freq.text!)!
        Basic.amplitude = Double(textfield_Amp.text!)!
        
        // Mise à jour des paramêtres de la séquence FMOscillator
        FMOscillator.baseFrequency = Double(textfield_FreqDual.text!)!
        FMOscillator.amplitude = Double(textfield_AmpDual.text!)!
        FMOscillator.carrierMultiplier = Double(textfield_Carrier.text!)!
        FMOscillator.modulatingMultiplier = Double(textfield_ModMulti.text!)!
        FMOscillator.modulationIndex = Double(textfield_ModIndex.text!)!
        
        // Lancement de la séquence
        AudioPlay(Selection, Sequence1: FMOscillator, Sequence2: GeneratorPlayer(FMOscillator, Sequence2: Basic), Sequence3: Basic)
        
        // Désactive le bouton Play (btn_Control) et active le bouton Stop (btn_Stop)
        btn_Stop.enabled = true
        btn_Control.enabled = false
    }
    
    @IBAction func SoundStop(sender: AnyObject) {
        // Arrêt de la séquence active
        AudioKit.stop()
        
        // Désactive le bouton Stop et active le bouton Playß
        btn_Stop.enabled = false
        btn_Control.enabled = true
    }
    
    @IBAction func ChangeType(sender: AnyObject) {
        // Arrète la séquence en cours d'exécution
        AudioKit.stop()
        
        // Désactive le bouton Stop et active le bouton Play
        btn_Stop.enabled = false
        btn_Control.enabled = true
        
        // Modifie la séquence jouée
        switch Selection {
        case 0:
            Selection = 1
            label_Type.text = "FM"
        case 1:
            Selection = 2
            label_Type.text = "Dual"
        default:
            Selection = 0
            label_Type.text = "Basic"
        }
    }
    //******************************************************************************//
}

// MARK: Fonctions
public func GeneratorPlayer (Sequence1: AKFMOscillator, Sequence2: AKOscillator) -> AKOperationGenerator {
    // Création des séquences qui seront superposée
    let SineWave1 = AKOperation.sineWave(frequency: Sequence1.baseFrequency, amplitude: Sequence1.amplitude)
    let SineWave2 = AKOperation.sineWave(frequency: Sequence2.frequency, amplitude: Sequence2.amplitude)
    
    // Retourne la séquence regroupant les deux précedente
    return AKOperationGenerator(left: SineWave1, right: SineWave2)
}

public func AudioPlay (Type: Int, Sequence1: AKFMOscillator?, Sequence2: AKOperationGenerator?, Sequence3: AKOscillator?) -> Void {
    // Arrète la séquence en cours d'exécution
    AudioKit.stop()
    
    // Lance la séquence selon le Type
    switch Type {
    case 1:
        AudioKit.output = Sequence1
        AudioKit.start()
        Sequence1!.start()
    case 2:
        AudioKit.output = Sequence2
        AudioKit.start()
        Sequence2!.start()
    default:
        AudioKit.output = Sequence3
        AudioKit.start()
        Sequence3!.start()
    }
}


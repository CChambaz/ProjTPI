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
    
    // Différent type d'écoute
    let Basic = AKOscillator()
    let FMOscillator = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))
    var Generator: AKOperationGenerator!
    
    // Variables concernant Basic
    var Freq = 30               // Fréquence
    var Amp = 30                // Amplitude
    
    // Variables concernant FMOscillator
    var FreqFM = 24             // Fréquence
    var AmpFM = 30
    var FM_Carrier = 2          // Fréquence du transporteur (=Freq * FM_Carrier)
    var FM_ModIndex = 5         // Modulation de l'amplitude (=Freq * FM_ModIndex)
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
        // Lancement de la séquence selon la sélection
        switch Selection {
        case 1:
            AudioKit.start()
            
            FMOscillator.start()
        case 2:
            AudioKit.start()
            Generator.start()
        default:
            AudioKit.start()
            
            Basic.start()
        }
        
        // Désactive le bouton Play (btn_Control) et active le bouton Stop (btn_Stop)
        btn_Stop.enabled = true
        btn_Control.enabled = false
    }
    
    @IBAction func SoundStop(sender: AnyObject) {
        // Arrêt de la séquence active
        switch Selection {
        case 1:
            FMOscillator.stop()
        case 2:
            Generator.stop()
        default:
            Basic.stop()
        }
        
        btn_Stop.enabled = false
        btn_Control.enabled = true
    }
    
    // MARK: Modification des paramètres
    
    @IBAction func ChangeFreq(sender: AnyObject) {
        // Modification de la fréquence
        Basic.frequency = Double(textfield_Freq.text!)!
    }
    
    @IBAction func ChangeAmp(sender: AnyObject) {
        // Modification de l'amplitude
        Basic.amplitude = Double(textfield_Amp.text!)!
    }
    
    @IBAction func ChangeFreqDual(sender: AnyObject) {
        // Modification de la fréquence
        FMOscillator.baseFrequency = Double(textfield_FreqDual.text!)!
    }
    
    @IBAction func ChangeAmpDual(sender: AnyObject) {
        FMOscillator.amplitude = Double(textfield_AmpDual.text!)!
    }
    
    @IBAction func ChangeCarrier(sender: AnyObject) {
        // Modification du transporteur
        FMOscillator.carrierMultiplier = Double(textfield_Carrier.text!)!
    }
    
    @IBAction func ChangeModMulti(sender: AnyObject) {
        // Modification de la modulation de la fréquence
        FMOscillator.modulatingMultiplier = Double(textfield_ModMulti.text!)!
    }
    
    @IBAction func ChangeModIndex(sender: AnyObject) {
        // Modification de la modulation de l'amplitude
        FMOscillator.modulationIndex = Double(textfield_ModIndex.text!)!
    }
    
    @IBAction func ChangeType(sender: AnyObject) {
        // Arrète la séquence en cours d'exécution si nécessaire
        if Basic.isStarted{
            Basic.stop()
        }
        if FMOscillator.isStarted {
            FMOscillator.stop()
        }
        
        // Désactive le bouton Stop et active le bouton Play
        btn_Stop.enabled = false
        btn_Control.enabled = true
        
        // Modifie la séquence jouée
        switch Selection {
        case 0:
            Selection = 1
            label_Type.text = "FM"
            
            AudioKit.stop()
            AudioKit.output = FMOscillator
        case 1:
            Selection = 2
            label_Type.text = "Dual"
            
            // Crée les deux séquences nécessaire
            Generator = GeneratorBuilder(FMOscillator, Sequence2: Basic)
            
            AudioKit.stop()
            AudioKit.output = Generator
        default:
            Selection = 0
            label_Type.text = "Basic"
            
            AudioKit.stop()
            AudioKit.output = Basic
        }
    }
    //******************************************************************************//
}

// MARK: Fonctions
public func GeneratorBuilder (Sequence1: AKFMOscillator, Sequence2: AKOscillator) -> AKOperationGenerator {
    let SineWave1 = AKOperation.sineWave(frequency: Sequence1.baseFrequency, amplitude: Sequence1.amplitude)
    let SineWave2 = AKOperation.sineWave(frequency: Sequence2.frequency, amplitude: Sequence2.amplitude)

    return AKOperationGenerator(left: SineWave1, right: SineWave2)
}


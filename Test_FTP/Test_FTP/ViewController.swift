//
//  ViewController.swift
//  Test_FTP
//
//  Created by Cédric Chambaz on 15.04.16.
//  Copyright © 2016 Cédric Chambaz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    // MARK: Propriétés
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var fileTextField: UITextField!
    
    // Déclaration du lecteur
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    
    // Variable de construction de l'url
    var server = "https://s3.amazonaws.com/kargopolov/"
    var file = "BlueCafe.mp3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fileTextField.text = file
    }
    
    // MARK: Initilaisation
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    @IBAction func playButtonTapped(sender: AnyObject) {
        // Permet de modifier le fichier
        file = fileTextField.text!
            
        // Construction de l'url
        let url = NSURL(string: server + file)
            
        // Assignation des valeurs au player
        playerItem = AVPlayerItem(URL: url!)
        player=AVPlayer(playerItem: playerItem!)
        
        // Lancement de la lecture
        player!.play()
    }
    
    @IBAction func stopButtonTapped(sender: AnyObject) {
        // mise en pause de la lecture
        player!.pause()
    }
}
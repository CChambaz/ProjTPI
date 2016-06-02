//
//  iBineuralBeatTests.swift
//  iBineuralBeatTests
//
//  Created by Cédric Chambaz on 28.04.16.
//  Copyright © 2016 Cédric Chambaz. All rights reserved.
//

import XCTest
@testable import iBineuralBeat

class iBineuralBeatTests: XCTestCase {
    // Test de la fonction intéragissant avec le serveur
    func testServerResponse() {
        // Test avec une URL invalide
        let falseUrl = Function().getListOfAudioFiles("www.somefalseURL.com/forTest")
        XCTAssertTrue(falseUrl[0].containsString("Connexion failed"), "Il est possible de se connecter avec une fausse URL")
        
        // Test avec URL vide
        let nilURL = Function().getListOfAudioFiles("")
        XCTAssertTrue(nilURL[0].containsString("Connexion failed"), "Il est possible de se connecter avec une URL nul")
        
        // Test avec URL valide
        let validURL = Function().getListOfAudioFiles("http://www.ibineuralbeat.inf.etmlnet.local/Alternatif/")
        XCTAssertFalse(validURL[0].containsString("Connexion failed"), "Il est impossible de connecter avec une URL valide")
    }
}

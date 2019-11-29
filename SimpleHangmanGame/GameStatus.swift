//
//  GameStatus.swift
//  SimpleHangmanGame
//
//  Created by kaww on 16/11/2019.
//  Copyright © 2019 KAWRANTIN LE GOFF. All rights reserved.
//

import UIKit

struct GameStatus: Codable {
    var highScore: Int
    var lifes: Int
    var word: String
    var wordLabelText: String
    var attemptsLettersLabelText: String
}

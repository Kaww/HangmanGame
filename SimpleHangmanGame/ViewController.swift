//
//  ViewController.swift
//  SimpleHangmanGame
//
//  Created by kaww on 15/11/2019.
//  Copyright © 2019 KAWRANTIN LE GOFF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var attemptsLettersLabel: UILabel!
    @IBOutlet var lifeLabel: UILabel!
    
    @IBOutlet var playButton: UIButton!
    
    var words = [String]()
    
    let fullLife = 10
    
    var word: String?
    var life: Int? {
        didSet {
            lifeLabel.text = "Lifes: \(life!)"
        }
    }
    
    var highScore: Int? {
        didSet {
            title = "HighScore: \(highScore!)"
        }
    }
    
    var gameStatus: GameStatus!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        navigationItem.leftBarButtonItem?.tintColor = .orange
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "FR", style: .done, target: self, action: #selector(changeLanguage))
        navigationItem.rightBarButtonItem?.tintColor = .orange
        
        title = "HighScore: X"
        
        playButton.layer.cornerRadius = 25
        
        if let wordsFileUrl = Bundle.main.url(forResource: "french", withExtension: "txt") {
            if let file = try? String(contentsOf: wordsFileUrl) {
                words = file.components(separatedBy: "\n")
                print(words.count)
            }
        }
        
        let defaults = UserDefaults.standard
        
        if let savedGameStatus = defaults.object(forKey: "gameStatus") as? Data {
            let decoder = JSONDecoder()
            
            do {
                gameStatus = try decoder.decode(GameStatus.self, from: savedGameStatus)
                continueGame()
                return
            } catch {
                print("Failed to load game status.")
            }
        }
        
        startGame()
    }
    
    @objc func changeLanguage() {
        
    }
    
    func continueGame() {
        word = gameStatus.word
        wordLabel.text = gameStatus.wordLabelText
        attemptsLettersLabel.text = gameStatus.attemptsLettersLabelText
        life = gameStatus.lifes
        highScore = gameStatus.highScore
    }
    
    @objc func startGame() {
        life = fullLife
        initWord()
        wordLabel.text = String(repeating: "?", count: word!.count)
        attemptsLettersLabel.text = ""
        highScore = 0
        
        gameStatus = GameStatus(highScore: highScore!, lifes: life!, word: word!, wordLabelText: wordLabel.text!, attemptsLettersLabelText: attemptsLettersLabel.text!)
        save()
    }
    
    @objc func restartGame() {
        life = fullLife
        gameStatus.lifes = life!
        
        initWord()
        gameStatus.word = word!
        
        wordLabel.text = String(repeating: "?", count: word!.count)
        gameStatus.wordLabelText = wordLabel.text!
        
        attemptsLettersLabel.text = ""
        gameStatus.attemptsLettersLabelText = attemptsLettersLabel.text!
        
        save()
    }
    
    func initWord() {
        word = words.randomElement()
        
        if word == nil {
            word = "error"
        }
        
        word = word?.uppercased()
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(gameStatus) {
            let defaults = UserDefaults.standard
            
            defaults.set(savedData, forKey: "gameStatus")
        } else {
            print("Failed to save game status.")
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: wordLabel.text, message: "Used letters: \(attemptsLettersLabel.text!)\n\nChoose a letter.", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Try", style: .default) { [weak self, weak ac] _ in
            guard let res = ac?.textFields?[0].text else { return }
            
            if res.count == 1 && res.isAlpha {
                self?.attempt(with: res.uppercased().first!)
            } else {
                self?.showInputError(res)
            }
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func showInputError(_ res: String) {
        let ac = UIAlertController(title: "Error", message: "\"\(res)\" is not a valid output.\nPlease enter only one letter.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    func attempt(with letter: Character) {
        if let attemptsLetters = attemptsLettersLabel.text {
            if !attemptsLetters.contains(letter) {
                if word!.contains(letter) {
                    var newWord = ""
                    
                    for (i, c) in word!.enumerated() {
                        if c == letter {
                            newWord.append(letter)
                        } else {
                            newWord.append(wordLabel.text![i])
                        }
                    }
                    
                    wordLabel.text = newWord
                    gameStatus.wordLabelText = wordLabel.text!
                    
                    if (!newWord.contains("?")) {
                        victory()
                    }
                } else {
                    life! -= 1
                    gameStatus.lifes = life!
                }
                
                attemptsLettersLabel.text?.append(letter)
                gameStatus.attemptsLettersLabelText = attemptsLettersLabel.text!
            } else {
                life! -= 1
                gameStatus.lifes = life!
            }
            
            if life! == 0 {
                loose()
            } else {
                save()
            }
            
        }
    }
    
    func victory() {
        if life! > highScore! {
            highScore = life!
            gameStatus.highScore = life!
        }
        
        let ac = UIAlertController(title: "Victory !", message: "You won this game !", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.restartGame()
        })
        
        present(ac, animated: true)
    }
    
    func loose() {
        let ac = UIAlertController(title: "Game over !", message: "You loose this game !\nThe word was \(word!).", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try Again", style: .destructive) { [weak self] _ in
            self?.restartGame()
        })
        
        present(ac, animated: true)
    }
    
}

extension String {
    
    var isAlpha: Bool {
        let alphaSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        for letter in self {
            if !alphaSet.contains(letter) {
                return false
            }
        }
        
        return true
    }
    
    var length: Int {
      return count
    }

    subscript (i: Int) -> String {
      return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
      return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
      return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
      let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                          upper: min(length, max(0, r.upperBound))))
      let start = index(startIndex, offsetBy: range.lowerBound)
      let end = index(start, offsetBy: range.upperBound - range.lowerBound)
      return String(self[start ..< end])
    }
    
}

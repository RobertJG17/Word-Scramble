//
//  ViewController.swift
//  Word Scramble
//
//  Created by Robert Guerra on 7/18/20.
//  Copyright © 2020 Robert Guerra. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    // MARK: - Properties
    var allWords = [String]()
    var usedWords = [String]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(generateNewWord))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: .newlines)
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        startGame()
    }
    
    // MARK: - Selectors
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc func generateNewWord() {
        startGame()
    }
    
    // MARK: - Helper Functions
    func startGame() {
        title = allWords.randomElement()?.uppercased()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        let upperAnswer = answer.uppercased()
        
        var errorTitle: String
        var errorMessage: String
        
        if isPossible(lowerAnswer) {
            if isOriginal(lowerAnswer) {
                if isReal(lowerAnswer) {
                    usedWords.insert(upperAnswer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make them up, you know!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "Unable to spell \(upperAnswer) from \(title!.uppercased())"
        }
        
        showErrorMessage(errorTitle, errorMessage)
    }
    
    func isPossible(_ word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(_ word: String) -> Bool {
        return !usedWords.contains(word.uppercased())
    }
    
    func isReal(_ word: String) -> Bool {
        if word.count < 3 { return false }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(_ title: String, _ message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: - TableView Override Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}


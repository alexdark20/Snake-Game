//
//  PlayerAccount.swift
//  Snake
//
//  Created by alex on 30.10.2023.
//  Copyright © 2023 Furkan Celik. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameController: GameController!
    var logo : SKLabelNode!
    var highestScore : SKLabelNode!
    var playButton : SKShapeNode!
    var score: SKLabelNode!
    var playerPositions: [(Int, Int)] = []
    var enemySnakes: [EnemySnake] = []
    var background: SKShapeNode!
    var gameArray: [(name: SKShapeNode, x: Int, y: Int)] = []
    var scorePosition: CGPoint?
    var portalPos: (CGPoint?, CGPoint?)
    var quitButton: SKLabelNode!

    
    // Методи для обробки свайпів в різних напрямках і передачі інформації про свайп в об'єкт game.
    @objc func swipeL() {
        gameController.handleSwipe(withDirection: 1)
    }
    @objc func swipeU() {
        gameController.handleSwipe(withDirection: 2)
    }
    @objc func swipeR() {
        gameController.handleSwipe(withDirection: 3)
    }
    @objc func swipeD() {
        gameController.handleSwipe(withDirection: 4)
    }
    
    // Метод викликається при натисканні на кнопку "Exit" та ініціює повернення в головне меню через об'єкт game.
    @objc func exitButtonTapped() {
        gameController.ExitToMainMenu()
    }
    
    // Метод для створення ігрового поля
    private func GenerateGameBoard(width: CGFloat, height: CGFloat){
        
        // розмір комірки
        let cellWidth: CGFloat = 27.5
        
        // кількість рядків і стовпців
        let numRows = 40
        let numCols = 20
        
        // ініціалізація початкових координат
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2)
        
        // Створення комірок на дошці
        for i in 0...numRows-1 {
            for j in 0...numCols-1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                
                // додавання комірки в масив і на ігровий екран
                gameArray.append((name: cellNode, x: i, y: j))
                background.addChild(cellNode)
                
                // перехід до наступної позиції за X
                x += cellWidth
            }
            // скидання координат за X, перехід до наступного рядка
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
    }
    
    // Метод викликається під час виведення сцени і виконує необхідні ініціалізації
    override func didMove(to skView: SKView) {
        СonfigureMenu()
        
        // створення екземпляра GameManager і передача поточної сцени
        gameController = GameController(scene: self)
        
        СonfigureGameView()
        
        // Додавання обробників жестів свайпа для керування напрямком змійки
        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
        swipeRight.direction = .right
        skView.addGestureRecognizer(swipeRight)
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
        swipeLeft.direction = .left
        skView.addGestureRecognizer(swipeLeft)
        
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
        swipeUp.direction = .up
        skView.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
        swipeDown.direction = .down
        skView.addGestureRecognizer(swipeDown)
    }
    
    
    // Метод викликається під час торкання екрана
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // перебір всіх торкань
        for t in touches {
            // отримання місця розташування торкання в сцені
            let touchLocation = t.location(in: self)
            // отримання вузлів, на які вказує дотик
            let nodesTouched = self.nodes(at: touchLocation)
            for node in nodesTouched {
                if node == quitButton {
                    // виклик методу для обробки торкання на кнопці виходу
                    exitButtonTapped()
                } else if node.name == "play_button" {
                    // Виклик методу для обробки торкання на кнопці для гри
                    InitiateGame()
                }
            }
        }
    }
    
    
    // Метод для запуску гри або початку нового рівня
    private func InitiateGame() {
        print("start game")
        // анімація переміщення логотипу гри
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.logo.isHidden = true
        }
        logo.run(SKAction.move(by: CGVector(dx: -100, dy: 600), duration: 0.5)) {
            self.logo.isHidden = true
        }
        
        // встановлення верхнього кута для анімації переміщення найкращого рахунку
        let upperCorner = CGPoint(x: 180, y: (frame.size.height / 2) - 100)
        
        highestScore.run(SKAction.move(to: upperCorner, duration: 0.4)) {
            // встановлення початкових параметрів для ігрового фону та поточного рахунку
            self.background.setScale(0)
            self.score.setScale(0)
            
            // відображення ігрового фону
            self.background.isHidden = false
            
            // анімація зменшення розміру НР з подальшим збільшенням розміру шрифту
            self.highestScore.run(SKAction.scale(to: 0.5, duration: 0.3)){
                self.highestScore.fontSize = 40
                self.score.isHidden = false
                self.quitButton.isHidden = false
                
                // анімація збільшення розміру ігрового фону та поточного рахунку
                self.background.run(SKAction.scale(to: 1, duration: 0))
                self.score.run(SKAction.scale(to: 1, duration: 0.4))
                
                // ініціалізація ігрового процесу
                self.gameController.InitiateGame()
            }
        }
    }
    
    
    // Метод оновлення сцени на кожному кадрі
    override func update(_ presentTime: TimeInterval) {
        gameController.RefreshGameState(time: presentTime)
    }
    
    // Функція для перевірки наявності значення в масиві кортежів
    func Contains(in array: [(Int, Int)], value: (Int, Int)) -> Bool {
        // Поділ кортежу на окремі компоненти
        let (value1, value2) = value
        
        // пошук збігу в масиві
        for (element1, element2) in array {
            if element1 == value1 && element2 == value2 {
                return true
            }
        }
        return false
    }
    
    
    // Метод для налаштування головного меню гри
    private func СonfigureMenu() {
        // Заголовок гри
        logo = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        logo.zPosition = 1
        logo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        logo.fontSize = 60
        logo.text = "SNAKE"
        logo.fontColor = SKColor.green
        // додавання кнопки до поточної сцени
        self.addChild(logo)
        
        // Найкращий результат
        highestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        highestScore.zPosition = 1
        highestScore.position = CGPoint(x: 0, y: logo.position.y - 50)
        highestScore.fontSize = 40
        highestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
        highestScore.fontColor = SKColor.white
        self.addChild(highestScore)
        
        // Кнопка для гри
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 400)
        playButton.fillColor = SKColor.gray
        let topCorner = CGPoint(x: -100, y: 100), bottomCorner = CGPoint(x: -100, y: -100), middle = CGPoint(x: 100, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        self.addChild(playButton)
        
        // Кнопка виходу
        quitButton = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        quitButton.fontSize = 40
        quitButton.text = "Exit"
        quitButton.position = CGPoint(x: -220, y: 568)
        quitButton.fontColor = SKColor.red
        quitButton.zPosition = 1
        self.addChild(quitButton)
        self.quitButton.isHidden = true
    }
    
    private func СonfigureGameView() {
        // Поточний рахунок
        score = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        score.zPosition = 1
        score.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        score.fontSize = 40
        score.isHidden = true
        score.text = "Score: 0"
        score.fontColor = SKColor.white
        self.addChild(score)
        
        // Розміри ігрового поля
        let width = frame.size.width - 200
        let height = frame.size.height - 236
        
        // Створення прямокутника для ігрового поля
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        background = SKShapeNode(rect: rect, cornerRadius: 0.02)
        background.fillColor = SKColor.darkGray
        background.zPosition = -2
        background.isHidden = true
        self.addChild(background)
        
        // Створення ігрового поля
        GenerateGameBoard(width: width, height: height)
    }
}

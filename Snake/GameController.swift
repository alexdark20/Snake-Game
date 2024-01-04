//
//  PlayerAccount.swift
//  Snake
//
//  Created by alex on 30.10.2023.
//  Copyright © 2023 Furkan Celik. All rights reserved.
//

import SpriteKit


class GameController {
    
    // Посилання на сцену гри
    var gameScene: GameScene!
    
    // Змінні для керування часом і напрямком руху
    var nextTime: Double?
    var timeExtension: Double = 0.2
    var playDirection: Int = 1
    
    var currScore: Int = 0
    
    // Таймери для порталів
    var portalTimer: Timer = Timer()
    var portalGenTimer: Timer = Timer()
    
    // Час, через який генерується портал
    private var secondsForPortal = 5
    
    init(scene: GameScene) {
        self.gameScene = scene
    }
    
    // Метод для початку гри
    func InitiateGame() {
        // початкове положення змії
        gameScene.playerPositions += [(10, 10), (10, 11), (10, 12)]
        
        // оновлення сцени гри
        UpdateDisplay()
        
        // генерація нового елемента для набору очок
        CreateNewScoreItem()
        
        // генерація нового порталу
        GeneratePortal()
    }
    
    
    // Метод для оновлення відображення ігрового поля
    func UpdateDisplay() {
        for (node, x, y) in gameScene.gameArray {
            // Перевірка, чи є поточна позиція частиною тіла змії
            if gameScene.Contains(in: gameScene.playerPositions, value: (x, y)) {
                node.fillColor = SKColor.green
            } else {
                node.fillColor = SKColor.clear
                
                // Перевірка, чи є поточна позиція місцем для набору очок
                if gameScene.scorePosition != nil {
                    if Int((gameScene.scorePosition?.y)!) == x && Int((gameScene.scorePosition?.x)!) == y{
                        node.fillColor = SKColor.white
                    }
                }
                
                // Перевірка, чи є поточна позиція місцем для порталу
                if gameScene.portalPos.0 != nil {
                    if( (Int((gameScene.portalPos.0?.y)!)) == x && Int((gameScene.portalPos.0?.x)!) == y ||
                        (Int((gameScene.portalPos.1?.y)!)) == x && Int((gameScene.portalPos.1?.x)!) == y) {
                        node.fillColor = SKColor.blue
                    }
                }
                
                // Перевірка, чи є поточна позиція частиною тіла ворожої змії
                for enemy in gameScene.enemySnakes {
                    if gameScene.Contains(in: enemy.snakePositionsArray, value: (x, y)) {
                        node.fillColor = SKColor.red
                    }
                }
            }
        }
    }
    
    
    // Метод для оновлення позиції гравця залежно від напрямку руху
    private func ChangePlayerPosition() {
        
        // зміна координат для кожного напрямку руху
        var xChange = -1
        var yChange = 0
        
        // визначення змін координат залежно від напрямку руху
        switch playDirection {
        case 0: // мертвий
            xChange = 0
            yChange = 0
            break
        case 1: // ліворуч
            xChange = -1
            yChange = 0
            break
        case 2: // вгору
            xChange = 0
            yChange = -1
            break
        case 3: // праворуч
            xChange = 1
            yChange = 0
            break
        case 4: // вниз
            xChange = 0
            yChange = 1
            break
            
        default:
            break
        }
        
        // Оновлення позиції змії
        if !gameScene.playerPositions.isEmpty {
            // переміщення всіх сегментів змії на позицію попереднього сегмента
            for index in stride(from: gameScene.playerPositions.count - 1, through: 1, by: -1) {
                gameScene.playerPositions[index] = gameScene.playerPositions[index - 1]
            }
            
            // перший сегмент змії оновлюється з урахуванням змін напрямку
            gameScene.playerPositions[0].0 += yChange
            gameScene.playerPositions[0].1 += xChange
            
            // Корекція координат змії при досягненні меж поля
            // Перевірка, що у змії є хоча б один сегмент
            if gameScene.playerPositions.count > 1 {
                // поточні координати першого сегмента
                let x = gameScene.playerPositions[0].1
                let y = gameScene.playerPositions[0].0
                
                if y > 39 {
                    gameScene.playerPositions[0].0 = 0
                }else if y < 0 {
                    gameScene.playerPositions[0].0 = 40
                }else if x > 19 {
                    gameScene.playerPositions[0].1 = 0
                }else if x < 0 {
                    gameScene.playerPositions[0].1 = 20
                }
            }
            
            // Оновлення відображення ігрового поля відповідно до поточних позицій змії
            UpdateDisplay()
        }
    }
    
    
    // Метод для обробки напрямків руху
    func handleSwipe(withDirection ID: Int) {

        // Перевірка, чи не є новий напрямок протилежним до поточного
        let isOppositeDirection = (ID == 2 && playDirection == 4) ||
        (ID == 4 && playDirection == 2) ||
        (ID == 1 && playDirection == 3) ||
        (ID == 3 && playDirection == 1)
            
        if !isOppositeDirection && playDirection != 0 {
            // оновлюємо напрямок якщо новий напрямок не є протилежним і поточний напрямок не є "мертвим"
            playDirection = ID
        }
    }
    
    
    // Метод для оновлення стану гри після певного часу
    func RefreshGameState(time: Double) {
        if nextTime == nil {
            nextTime = time + timeExtension
        } else {
            // перевірка, чи пройшов достатній час для оновлення стану
            if time >= nextTime! {
                nextTime = time + timeExtension
                
                // оновлення позиції гравця і ворожих змій
                ChangePlayerPosition()
                for enemySnake in gameScene.enemySnakes {
                    enemySnake.Move()
                }
                
                // Перевірка наявності: набраних очок, порталу, зіткнення з ворогами та смерті
                ScoreVerification()
                VerifyPortal()
                СheckEnemyCollision()
                checkSnakeDeath()
                completeAnimation()
                
                // Запуск таймера для появи порталу, якщо він неактивний і час не дорівнює нулю
                if !portalTimer.isValid && secondsForPortal != 0 {
                    portalTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(updatePortalTimer)), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    
    // оновлення таймера порталу
    @objc func updatePortalTimer() {
        secondsForPortal -= 1
        if secondsForPortal == 0 {
            portalTimer.invalidate()
        }
    }
    
    // оновлення таймера генерації порталу
    @objc func UpdateGenerationTimer() {
        GeneratePortal()
    }
    
    
    // Функція для створення нового елемента рахунку
    private func CreateNewScoreItem() {
        // генерація випадкових координат X та Y
        var randX = CGFloat(arc4random_uniform(19))
        var randY = CGFloat(arc4random_uniform(39))
        
        // Перевіряємо, чи вже існує елемент гри з такими координатами
        // Якщо так, то генеруємо нові координати
        while gameScene.Contains(in: gameScene.playerPositions, value: (Int(randX), Int(randY))) {
            randX = CGFloat(arc4random_uniform(19))
            randY = CGFloat(arc4random_uniform(39))
        }
        
        // Встановлюємо нову позицію для елемента рахунку
        gameScene.scorePosition = CGPoint(x: randX, y: randY)
    }
    
    
    // Функція для генерації порталу
    private func GeneratePortal() {
        // Перевірка, чи таймер генерації порталу не активний
        if !portalGenTimer.isValid {
            // Якщо не активний, то запуск таймера
            portalGenTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(UpdateGenerationTimer)), userInfo: nil, repeats: false)
            
            // генерація випадкового числа для можливості створення порталу
            var possibility = CGFloat(arc4random_uniform(100))
                    
            // Якщо число більше 75 (ймовірність 25%) і портал ще не створено
            if possibility > 75 && secondsForPortal == 0 {
                // генерація випадкових координат для порталу
                let randomX1 = CGFloat(arc4random_uniform(19)), randomX2 = CGFloat(arc4random_uniform(19))
                let randomY1 = CGFloat(arc4random_uniform(39)), randomY2 = CGFloat(arc4random_uniform(39))
                        
                // встановлення позиції порталу
                gameScene.portalPos = (CGPoint(x: randomX1, y: randomY1), CGPoint(x: randomX2, y: randomY2))
                        
                // встановлення таймера для порталу
                secondsForPortal = 5
                        
                print("Portal created")
            } else {
                possibility = CGFloat(arc4random_uniform(100))
            }
            
            if secondsForPortal == 0 {
                gameScene.portalPos = (nil, nil)
            }
        }
    }
    
    
    // Перевірка зіткнення із порталами
    private func VerifyPortal() {
        // Перевірка, чи існує портал і чи гравець має позиції
        if gameScene.portalPos.0 != nil && gameScene.playerPositions.count != 0 {
            
            // Перебір позицій гравця
            for i in 0...gameScene.playerPositions.count-1 {
                let playerPos = CGPoint(x: gameScene.playerPositions[i].1, y: gameScene.playerPositions[i].0)
                
                // Переміщення гравця в інший кінець порталу, якщо він перебуває в одній із його точок
                if  playerPos == gameScene.portalPos.0 {
                    gameScene.playerPositions[i] = (Int(gameScene.portalPos.1!.y), Int(gameScene.portalPos.1!.x))
                } else if playerPos == gameScene.portalPos.1 {
                    gameScene.playerPositions[i] = (Int(gameScene.portalPos.0!.y), Int(gameScene.portalPos.0!.x))
                }
            }
            
            // Перебір ворожих змій
            for e in gameScene.enemySnakes {
                for i in 0...e.snakePositionsArray.count-1 {
                    let enemyPos = CGPoint(x: e.snakePositionsArray[i].1, y: e.snakePositionsArray[i].0)
                    
                    if enemyPos == gameScene.portalPos.0 {
                        e.snakePositionsArray[i] = (Int(gameScene.portalPos.1!.y), Int(gameScene.portalPos.1!.x))
                    }else if enemyPos == gameScene.portalPos.1 {
                        e.snakePositionsArray[i] = (Int(gameScene.portalPos.0!.y), Int(gameScene.portalPos.0!.x))
                    }
                }
            }
            
            // Скидання порталу, якщо час минув
            if secondsForPortal == 0 {
                gameScene.portalPos = (nil, nil)
            }
        } else if secondsForPortal == 0 && gameScene.portalPos.0 != nil {
            gameScene.portalPos = (nil, nil)
        } else {
            GeneratePortal()
        }
    }
    
    
    // Перевірка зіткнення гравця з елементом для набору досвіду (ScoreItem)
    private func ScoreVerification() {
        
        // Перевірка наявності елемента для набору досвіду
        guard let scorePosition = gameScene.scorePosition else { return }
        
        let playerX = gameScene.playerPositions[0].0
        let playerY = gameScene.playerPositions[0].1
        
        // Якщо координати гравця збігаються з координатами елемента для набору досвіду
        if Int(scorePosition.x) == playerY && Int(scorePosition.y) == playerX {
            // збільшення рахунку та оновлення відображення рахунку
            currScore += 1
            gameScene.score.text = "Score: \(currScore)"
            
            // створення нового елемента ScoreItem
            CreateNewScoreItem()
            
            // збільшення довжини змії
            for _ in 0..<3 {
                gameScene.playerPositions.append(gameScene.playerPositions.last!)
            }
        } else {
            // перевірка зіткнення з ScoreItem у ворожих змій
            for enemy in gameScene.enemySnakes {
                if Int(scorePosition.x) == enemy.snakePositionsArray[0].1 && Int(scorePosition.y) == enemy.snakePositionsArray[0].0 {
                    CreateNewScoreItem()
                    enemy.snakePositionsArray.append(enemy.snakePositionsArray.last!)
                }
            }
        }
    }
    
    
    // Перевірка зіткнення гравця з ворожими зміями та обробка подій
    private func СheckEnemyCollision() {
        // Перевірка наявності ворогів і гравця
        guard !gameScene.enemySnakes.isEmpty, !gameScene.playerPositions.isEmpty else { return }
        
        for enemy in gameScene.enemySnakes {
            var positions = enemy.snakePositionsArray
            
            // Перебір позицій ворожої змії
            for i in 0..<positions.count {
                // Перевірка зіткнення голови ворожої змії з головою гравця
                if positions[i] == gameScene.playerPositions[0] {
                    // Перевірка, чи знаходиться зіткнення на певній відстані від голови ворожої змії
                    if i >= 5 {
                        // Створення нової ворожої змії та вставка її позицій перед колізією
                        let newEnemy = CreateEnemy(_scene: gameScene)
                        for j in (i..<positions.count).reversed() {
                            newEnemy.snakePositionsArray.insert(positions[j], at: 0)
                            positions.remove(at: j)
                        }
                        gameScene.enemySnakes.append(newEnemy)
                    } else {
                        // Збільшення рахунку гравця і видалення ворожої змії з масиву
                        currScore += positions.count / 2
                        gameScene.enemySnakes.removeAll { $0.snakePositionsArray[0] == positions[0] }
                    }
                }
            }
            
            // Оновлення позицій ворожої змії після обробки зіткнення
            enemy.snakePositionsArray = positions
            
            // Видалення ворожої змії з масиву, якщо у неї мало позицій
            if enemy.snakePositionsArray.count <= 3 {
                gameScene.enemySnakes.removeAll { $0.snakePositionsArray[0] == positions[0] }
            }
        }
    }
    
    
    // Повертає координати наступної клітини в напрямку руху голови змії
    private func getFrontPosition() -> (Int, Int){
        // Перевірка наявності гравця
        guard let headOfSnake = gameScene.playerPositions.first else { return (0, 0) }
        
        // Повернення позиції залежно від напрямку руху
        switch playDirection {
        case 1: //ліворуч
            return (headOfSnake.0, headOfSnake.1 - 1)
        case 2: //вгору
            return (headOfSnake.0 - 1, headOfSnake.1)
        case 3: //праворуч
            return (headOfSnake.0, headOfSnake.1 + 1)
        case 4: //вниз
            return (headOfSnake.0 + 1, headOfSnake.1)
        default:
            return (0, 0)
        }
    }
    
    
    // Функція для перевірки смерті змії
    private func checkSnakeDeath() {
        if gameScene.playerPositions.count > 0 {
            var positions = gameScene.playerPositions
            let snakeHead = positions[0]
            positions.remove(at: 0)
            
            // Якщо голова змії зіткнулася з тілом
            if gameScene.Contains(in: positions, value: snakeHead) {
                // Якщо довжина змії менша за 12, змія вважається мертвою
                if gameScene.playerPositions.count < 12 {
                    playDirection = 0
                }else {
                    for i in 1...gameScene.playerPositions.count-1 {
                        if snakeHead == gameScene.playerPositions[i] {
                            // Якщо голова змії збігається з позицією іншої частини тіла
                            if i < positions.count-3 {
                                // Створення нового ворога і додавання йому частину тіла змії
                                let newEnemy = CreateEnemy(_scene: gameScene)
                                for j in (i + 1...positions.count-1).reversed() {
                                    newEnemy.snakePositionsArray.append(positions[j])
                                    positions.remove(at: j)
                                }
                                positions.remove(at: i)
                                gameScene.enemySnakes.append(newEnemy)
                            }
                        }
                    }
                    
                    // Оновлення позиції гравця, видалення позиції голови з масиву і вставка її на початок масиву
                    gameScene.playerPositions = positions
                    gameScene.playerPositions.insert(snakeHead, at: 0)
                }
            }
        }
    }
    
    
    // Функція для завершення анімації та закінчення гри
    private func completeAnimation() {
        // Якщо напрямок руху дорівнює 0 (мертвий) і у гравця є позиції
        if playDirection == 0 && gameScene.playerPositions.count > 0 {
            var isFinished = true
            let snakeHead = gameScene.playerPositions[0]
            
            // Якщо всі позиції збігаються з головою змії
            for pos in gameScene.playerPositions {
                if snakeHead != pos {
                    isFinished = false
                }
            }
            
            if isFinished {
                print("End game")
                
                // Оновлення рахунку
                UpdateScore()
                
                // Встановлення напрямку руху вниз (змушує змію зупинитися)
                playDirection = 4
                
                // Скидання позиції елемента для набору очок
                gameScene.scorePosition = nil
                
                // Очищення позицій гравця
                gameScene.playerPositions.removeAll()
                
                // Оновлення відображення
                UpdateDisplay()
                
                // Анімація зникнення рахунку та перехід до головного меню
                gameScene.score.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.gameScene.score.isHidden = true
                    self.ExitToMainMenu()
                }
            }
        }
    }

    
    // Функція для виходу в головне меню з анімацією
    func ExitToMainMenu() {
        print("Exit game")

        // Анімація зникнення фону
        gameScene.background.run(SKAction.scale(to: 0, duration: 0.4)) {
            // Приховування фону
            self.gameScene.background.isHidden = true
            
            // Показ логотипу
            self.gameScene.logo.isHidden = false
            
            // Приховування рахунку
            self.gameScene.score.isHidden = true
            
            // Приховування кнопки виходу
            self.gameScene.quitButton.isHidden = true
            
            // Встановлення напрямку руху вниз (змушує змію зупинитися)
            self.playDirection = 4
            
            // Скидання позиції елемента для набору очок
            self.gameScene.scorePosition = nil
            
            // Очищення позицій гравця
            self.gameScene.playerPositions.removeAll()
            
            // Оновлення відображення
            self.UpdateDisplay()
            
            // Створюємо дію переміщення gameLogo і зміни розміру bestScore одночасно
            let moveResizeAct = SKAction.group([
                SKAction.move(to: CGPoint(x: 0, y: (self.gameScene.frame.size.height / 2) - 200), duration: 0.5),
                SKAction.scale(to: 1, duration: 0.5)
            ])
            
            // Анімація переміщення та зміни розміру логотипа
            self.gameScene.logo.run(moveResizeAct) {
                self.gameScene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                
                // Продовження з анімацією переміщення і зміни розміру bestScore
                self.gameScene.highestScore.run(SKAction.group([
                    SKAction.move(to: CGPoint(x: 0, y: self.gameScene.logo.position.y - 50), duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ]))
            }
        }
    }
    
    
    // Функція для створення ворожої змії залежно від випадкового відсоткового значення
    private func CreateEnemy(_scene: GameScene) -> EnemySnake {
        let percent = Int.random(in: 0...99)
        
        // Залежно від відсоткового значення створюємо певний тип ворожої змії
        if percent < 100 {
            // Ворожа змія загального типу
            return EnemySnake(scene: _scene)
        }else if percent < 0 {
            // Ворожа змія з хрестоподібним рухом
            return CrossMoveEnemySnake(scene: _scene)
        }else {
            // Ворожа змія-хижак
            return HunterSnake(scene: _scene)
        }
    }


    // Функція для оновлення рахунку та найкращого результату
    private func UpdateScore() {
        // Порівнюємо поточний рахунок із найкращим результатом у UserDefaults
        if currScore > UserDefaults.standard.integer(forKey: "bestScore") {
            // Якщо поточний рахунок кращий, оновлюємо кращий результат
            UserDefaults.standard.set(currScore, forKey: "bestScore")
        }
        currScore = 0
        gameScene.score.text = "Score: 0"
        gameScene.highestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
    }
}

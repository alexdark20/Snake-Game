//
//  PlayerAccount.swift
//  Snake
//
//  Created by alex on 30.10.2023.
//  Copyright © 2023 Furkan Celik. All rights reserved.
//

import SpriteKit

class EnemySnake {
    // масив позицій змії в ігровому полі
    var snakePositionsArray: [(Int, Int)] = []
    
    // напрямок руху змії
    var snakeDir: Int = 1
    
    // посилання на екземпляр GameScene, що представляє ігрову сцену
    var gameScene: GameScene!
    
    init(scene: GameScene) {
        self.gameScene = scene
    }
    
    
    // Функція для переміщення ворожої змії
    func Move(shouldChangeDirection: Bool = true, shouldAdjustCorner: Bool = true) {
        
        var changeInX = -1
        var changeInY = 0
        
        // Якщо потрібно змінити напрямок, викликаємо функцію для встановлення напрямку
        if shouldChangeDirection {
            SetSnakeDirection()
        }
        
        // Визначаємо зміни координат залежно від напрямку змії
        switch snakeDir {
        case 0: //Мертвий
            changeInX = 0
            changeInY = 0
            break
        case 1: //ліворуч
            changeInX = -1
            changeInY = 0
            break
        case 2: //вгору
            changeInX = 0
            changeInY = -1
            break
        case 3: //праворуч
            changeInX = 1
            changeInY = 0
            break
        case 4: //вниз
            changeInX = 0
            changeInY = 1
            break
        default:
            break
        }
        
        
        // Якщо у змії є позиції, переміщуємо її
        if snakePositionsArray.count > 0 {
            var startPosition = snakePositionsArray.count - 1
            while startPosition > 0 {
                // Зсуваємо кожен елемент тіла змії на одну позицію вперед
                snakePositionsArray[startPosition] = snakePositionsArray[startPosition - 1]
                startPosition -= 1
            }
            snakePositionsArray[0] = (snakePositionsArray[0].0 + changeInY, snakePositionsArray[0].1 + changeInX)
        }
        
        // Якщо потрібна корекція кутів, викликаємо відповідну функцію
        if shouldAdjustCorner {
            AdjustCorner()
        }
    }
    
    
    // Функція для встановлення напрямку руху змії
    func SetSnakeDirection() {
        // Якщо позиція поточного елемента існує
        if let scorePosition = gameScene.scorePosition {
            // Отримуємо координати X і Y позиції рахунку
            let scorePositionX = scorePosition.x
            let scorePositionY = scorePosition.y
            
            // Отримуємо координати X і Y голови змії
            let snakeHeadPositionX = CGFloat(snakePositionsArray[0].1)
            let snakeHeadPositionY = CGFloat(snakePositionsArray[0].0)
            
            // Якщо позиція рахунку і голови змії знаходяться на одній горизонтальній лінії і змія не мертва
            if scorePositionX == snakeHeadPositionX && snakeDir != 0 {
                // якщо позиція score нижче голови змії, встановлюємо напрямок руху вниз, інакше - вгору
                snakeDir = scorePositionY > snakeHeadPositionY ? 4 : 2
            
            // Якщо позиція рахунку і голови змії знаходяться на одній вертикальній лінії
            } else if scorePositionY == snakeHeadPositionY {
                // якщо позиція score ліворуч від голови змії, встановлюємо напрямок руху ліворуч, інакше - праворуч
                snakeDir = scorePositionX == snakeHeadPositionX ? 1 : 3
            }
        }
        // функція для виявлення зіткнень із ворогами
        CheckCollision(remainingAttempts: 5)
    }
    
    
    // Функція для визначення зіткнення змії
    internal func CheckCollision(remainingAttempts: Int) {
        // Перевірка зіткнення з передньою коміркою і наявності спроб, що залишилися
        if gameScene.Contains(in: gameScene.playerPositions, value: GetFrontCell()) && remainingAttempts > 0 {
            // Зміна напрямку руху змії на наступний за годинниковою стрілкою
            snakeDir = (snakeDir + 1)
            
            // якщо новий напрямок перевищує 4, то він збільшується на 1
            if snakeDir > 4 {
                snakeDir += 1
            }
            CheckCollision(remainingAttempts: remainingAttempts - 1)
        } else if remainingAttempts == 0 {
            // якщо спроби, що залишилися, вичерпані, то встановлюється напрямок для "мертвої" змії
            snakeDir = 0
        }
    }
    
    
    // Функція для визначення комірки перед "головою" змії залежно від напрямку
    internal func GetFrontCell() -> (Int, Int){
        
        // Перевірка, чи є комірки в змії
        if snakePositionsArray.count > 0 {
            // отримання масиву позицій змії
            let positionsArray = snakePositionsArray
            
            // отримання "голови" змії (перший елемент масиву)
            let snakeHead = positionsArray[0]
            
            // залежно від напрямку повертається комірка перед "головою" змії
            switch snakeDir {
            case 1: //ліворуч
                return (snakeHead.0, snakeHead.1 - 1)
            case 2: //вгору
                return (snakeHead.0 - 1, snakeHead.1)
            case 3: //праворуч
                return (snakeHead.0, snakeHead.1 + 1)
            case 4: //вниз
                return (snakeHead.0 + 1, snakeHead.1)
            default:
                break
            }
        }
        return (0, 0)
    }
    
    
    // Корекція позиції змії при досягненні межі ігрового поля
    internal func AdjustCorner() {
        if snakePositionsArray.count > 1 {
            let x = snakePositionsArray[0].1
            let y = snakePositionsArray[0].0
            
            if y > 39 {
                snakePositionsArray[0].0 = 0
            }else if y < 0 {
                snakePositionsArray[0].0 = 39
            }else if x > 19 {
                snakePositionsArray[0].1 = 0
            }else if x < 0 {
                snakePositionsArray[0].1 = 19
            }
        }
    }
    
    
    // Перевантаження оператора != для порівняння двох об'єктів типу EnemySnake
    static func !=(left: EnemySnake, right: EnemySnake) -> Bool {
        return left.snakePositionsArray[0] != right.snakePositionsArray[0]
    }
}

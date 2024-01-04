//
//  PlayerAccount.swift
//  Snake
//
//  Created by alex on 30.10.2023.
//  Copyright © 2023 Furkan Celik. All rights reserved.
//

import Foundation

class CrossMoveEnemySnake: EnemySnake {
    var nextSnakeDir: Int = 1
    var crossMove: Int = 1
    
    
    // Перевизначена функція руху змії з додатковими параметрами для контролю зміни напрямку та корекції кутів.
    override func Move(shouldChangeDirection: Bool = false, shouldAdjustCorner: Bool = false) {
        
        // Якщо наступний напрямок відрізняється від поточного і поточний напрямок не є "мертвим",
        // то змінюється напрямок і викликається суперклас для виконання базового руху.
        if nextSnakeDir != snakeDir && snakeDir != 0 {
            snakeDir = nextSnakeDir
            super.Move(shouldChangeDirection: false)
            return
        }
        
        // Встановлюємо напрямок змії залежно від типу руху CrossMove.
        SetSnakeDirection()
        // обробка можливих типів руху для змії
        switch crossMove {
        case 0: //Мертвий
            snakeDir = 0
            super.Move(shouldChangeDirection: false, shouldAdjustCorner: false)
            break
        case 1: //ліворуч вгору
            snakeDir = 1 //ліворуч
            super.Move(shouldChangeDirection: false, shouldAdjustCorner: false)
            nextSnakeDir = 2 //вгору
            break
        case 2: //ліворуч вниз
            snakeDir = 1 //ліворуч
            super.Move(shouldChangeDirection: false, shouldAdjustCorner: false)
            nextSnakeDir = 4 //вниз
            break
        case 3: //праворуч вниз
            snakeDir = 3 //праворуч
            super.Move(shouldChangeDirection: false, shouldAdjustCorner: false)
            nextSnakeDir = 4 //вниз
            break
        case 4: //праворуч вгору
            snakeDir = 3 //праворуч
            super.Move(shouldChangeDirection: false, shouldAdjustCorner: false)
            nextSnakeDir = 2 //вгору
            break
        default:
            break
        }
        
    
        // Перевірка наявності позицій сегментів змії
        if snakePositionsArray.count > 0 {
            // Оновлюємо позиції змії в масиві.
            var start = snakePositionsArray.count - 1
            while start > 0 {
                snakePositionsArray[start] = snakePositionsArray[start - 1]
                start -= 1
            }
            
            // Перевірка на вихід за межі ігрового поля
            if snakePositionsArray.count > 1 {
                let x = snakePositionsArray[0].1
                let y = snakePositionsArray[0].0
                
                if y > 39 {
                    crossMove = 0
                }else if y < 0 {
                    crossMove = 0
                }else if x > 19 {
                    crossMove = 0
                }else if x < 0 {
                    crossMove = 0
                }
            }
        }
    }
    
    
    // Перевизначена функція перевірки колізії з додатковим параметром
    override func CheckCollision(remainingAttempts: Int) {
        
        // Перевірка колізії з передньою коміркою змії
        if gameScene.Contains(in: gameScene.playerPositions, value: GetFrontCell()) && remainingAttempts > 0 {
            crossMove += 1
            if crossMove > 4 {
                crossMove += 1
            }
            // Рекурсивний виклик зі зменшенням спроб, що залишилися
            CheckCollision(remainingAttempts: remainingAttempts - 1)
        } else if remainingAttempts == 0 {
            crossMove = 0
        }
    }
}

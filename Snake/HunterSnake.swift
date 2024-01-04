//
//  PlayerAccount.swift
//  Snake
//
//  Created by alex on 30.10.2023.
//  Copyright © 2023 Furkan Celik. All rights reserved.
//

import Foundation

class HunterSnake: EnemySnake {
    
    // Перевизначена функція руху
    override func Move(shouldChangeDirection: Bool = false, shouldAdjustCorner: Bool = true) {
        // встановлення напрямку змії
        SetSnakeDirection()
        // Виклик батьківської функції руху
        super.Move(shouldChangeDirection: false, shouldAdjustCorner: true)
    }
    
    // Перевизначена функція встановлення напрямку змії
    override func SetSnakeDirection() {
        // Отримання координат голови хижака і гравця
        let enemyHead = snakePositionsArray[0]
        let gamerHead = gameScene.playerPositions[0]
        
        // Визначення напрямку руху хижака на основі координат голів гравця та хижака
        if gamerHead.0 > enemyHead.0 {
            snakeDir = 2 //вгору
        }else if gamerHead.0 < enemyHead.0 {
            snakeDir = 4 //вниз
        } else if gamerHead.1 > enemyHead.1 {
            snakeDir = 3 //праворуч
        }else {
            snakeDir = 1 //ліворуч
        }
    }
}

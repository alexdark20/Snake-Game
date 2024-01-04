//
//  PlayerAccount.swift
//  Snake
//
//  Created by alex on 30.10.2023.
//  Copyright © 2023 Furkan Celik. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let userDefaults = UserDefaults.standard
        let initialValues = ["bestScore": 0]
        userDefaults.register(defaults: initialValues)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Метод для переходу програми з активного стану в неактивний.
        // (наприклад, вхідний телефонний дзвінок або SMS-повідомлення) або коли користувач виходить з програми і вона починає перехід у фоновий стан.
        // використання при: призупиненні поточних завдань, вимкненні таймерів та скасуванні викликів рендерингу графіки.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Метод для: звільнення спільних ресурсів, збереження даних користувача, анулювання таймера та збереження достатньої інформації про стан програми, щоб відновити її поточний стан у разі завершення роботи.
        // Якщо програма підтримує фонове виконання, цей метод викликається замість applicationWillTerminate: коли користувач виходить.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Викликається як частина переходу з фонового в активний стан; можна скасувати багато змін, зроблених при переході у фоновий стан.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Перезапуск усіх завдань, які були призупинені (або ще не запущені), поки програма була неактивною.
        // Якщо програма раніше працювала у фоновому режимі, за бажанням оновити інтерфейс користувача.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Викликається, коли програма завершує роботу. При необхідності зберігаюься дані.
    }


}


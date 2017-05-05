//
//  Defines.swift
//  GlobalQuizMain
//
//  Created by Alexander Lukashevich  on 5/4/17.
//  Copyright © 2017 Alexander Lukashevich . All rights reserved.
//

import Foundation

let gameTypes:Array = ["Правильные ответы",
                       "Кто быстрее",
                      "Кто быстрее2"]
  
  
//  ["Правильные ответы",
//                       "5 первых правильных ответов",
//                       "Кто быстрее",
//                       "Кто быстрее 2"]

//enum GameType : String {
//  case GameTypeRightAnswers = "Правильные ответы"
//  case GameTypeFiveFastestAnswers = "5 первых правильных ответов"
//  case GameTypeFasterByPlaceAnswers = "Кто быстрее"
//  case GameTypeFasterByTimeAnswers = "Кто быстрее 2"
//  
//  private static let _count: GameType.RawValue = {
//    // find the maximum enum value
//    var maxValue: UInt32 = 0
//    while let _ = GameType(rawValue: GameTypeFasterByTimeAnswers) {
//      maxValue += 1
//    }
//    return GameTypeFasterByTimeAnswers.rawValue
//  }()
//  
//  static func randomGeometry() -> GameType {
//    // pick and return a new value
//    let rand = arc4random_uniform(_count)
//    return GameType(rawValue: rand)!
//  }
//}

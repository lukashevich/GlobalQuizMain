//
//  GQGameViewController.swift
//  GlobalQuizMain
//
//  Created by Alexander Lukashevich  on 5/4/17.
//  Copyright © 2017 Alexander Lukashevich . All rights reserved.
//

import UIKit
import Alamofire
import CoreBluetooth

class GQGameViewController: UIViewController {
  
  var data:NSMutableData?

  let serverName = "http://quiz.vany.od.ua/wp-json/quiz"
  
  var gameData:[[String:Any]]?
  var themes:[String:Any]?
  var gameRound = 0
  var rightAnswer = 0

  var playersCount:Int!
  var gettedAnswers:NSMutableArray = NSMutableArray()
  var roundResults:[String:Any] = [String:Any]()
  
  var playersPoints:[String:Int] = [String:Int]()
  var timer = Timer()
  var seconds:Int = Int(roundTimerValue)

  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var pickerView: UIView!
  
  @IBOutlet weak var questionView: UIVisualEffectView!
  @IBOutlet weak var firstAnswer: UILabel!
  @IBOutlet weak var secondAnswer: UILabel!
  @IBOutlet weak var thirdAnswer: UILabel!
  @IBOutlet weak var fourthAnswer: UILabel!
  @IBOutlet weak var questionLabel: UILabel!
  
  var questionTime:TimeInterval!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    for i in 1...playersCount {
      roundResults[String(i)] = NSMutableArray()
      playersPoints[String(i)] = 0
    }

    pickerView.bringSubview(toFront: questionView)

    data = NSMutableData()
    
    requestForThemes(forRound: gameRound)
    
  }
  
  func requestForThemes(forRound:Int)  {
    

    questionLabel.text = gameTypes[gameRound%(gameTypes.count)]
    
    let nextTryData:Data = "{\"id1\":\"Название темы1\", \"id2\":\"Название темы2\", \"id3\":\"Название темы3\", \"id4\":\"Название темы4\"}".data(using: .utf8)!
    
    self.themes = try! JSONSerialization.jsonObject(with:nextTryData,
                                                      options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : Any]
    showThemes(theme: self.themes!)
    self.pickerView.isHidden = false

    
    let data:Data = "firstPicked".data(using: .utf8)!
    perform(#selector(themeGetted), with: data, afterDelay: 2.0)

    

  }

  func requestForQuestions(theme:String){
    
    let themeName = theme
    
    let requestStr = serverName + "/" + themeName + "/"
    
    Alamofire.request(requestStr).responseJSON { response in
      
      let nextTryData:Data = (response.result.value as! String).data(using: .utf8)!
      
      self.gameData = try! JSONSerialization.jsonObject(with:nextTryData,
                                                        options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String : Any]]
      
      self.perform(#selector(self.startGame), with: nil, afterDelay: kGameRoundDelay)
      
    }

  }
  

  
  func runTimer() {
    stopTimer()
    timerLabel.isHidden = false
    timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(GQGameViewController.updateTimer)), userInfo: nil, repeats: true)
  }
  func updateTimer() {
    seconds -= 1     //This will decrement(count down)the seconds.
    
    if seconds == 0 {
      finishRound()
    }
    timerLabel.text = "\(seconds)" //This will update the label.
  }
  
  func stopTimer(){
    timer.invalidate()
    seconds = Int(roundTimerValue)    //Here we manually enter the restarting point for the seconds, but it would be wiser to make this a variable or constant.
    timerLabel.text = "\(seconds)"
  }
  
  func startGame() {
    
    showQuestion(question: (self.gameData?.first!)!)
    
  }
  
  func finishRound(){
    
    stopTimer()
    
    print(gettedAnswers)

    print(playersPoints)
    
    guard ((self.gameData?.count)! > 1) else {
      pickerView.isHidden = true
      
      self.perform(#selector(requestForThemes), with: gameRound, afterDelay: kGameRoundDelay)
      
      return
    }
    
    setPointsToPlayers()
    
    self.gameData?.removeFirst()
    showQuestion(question: (self.gameData?.first!)!)

  }
  
  func showQuestion(question:[String:Any]){
    
    print(playersPoints)
    
    questionTime = Date().timeIntervalSince1970
    
    self.pickerView.isHidden = false
    self.questionLabel.text = question["question"] as! String?
    
    rightAnswer = Int((question["correct"] as! String?)!)!
   
    self.firstAnswer.text =   (question["answers"] as! Array)[0]
    self.secondAnswer.text =  (question["answers"] as! Array)[1]
    self.thirdAnswer.text =   (question["answers"] as! Array)[2]
    self.fourthAnswer.text =  (question["answers"] as! Array)[3]
    
    runTimer()
   
//    for playerId in 1...playersCount-1 {
//      let randomAnswer = Int(arc4random_uniform(3)+1)
//      let randomAnswerTime = 1+CGFloat(Float(arc4random()) / Float(UINT32_MAX))
//      let data:Data = "{\"id\":\(playerId),\"time\":\(randomAnswerTime),\"answer\":\(randomAnswer)}".data(using: .utf8)!
//      perform(#selector(answerGetted), with: data, afterDelay: TimeInterval(randomAnswerTime))
//    }
    
    
    

  }
  
  func showThemes(theme:[String:Any]){
    
    self.questionLabel.text = gameTypes[gameRound%(gameTypes.count)]
    
    let keys = Array(theme.keys)
    
    self.firstAnswer.text =   theme[keys[0]] as? String
    self.secondAnswer.text =  theme[keys[1]] as? String
    self.thirdAnswer.text =   theme[keys[2]] as? String
    self.fourthAnswer.text =  theme[keys[3]] as? String

  }
  
  
  func themeGetted(data:Data){
    
    pickerView.isHidden = true
    gameRound = gameRound + 1
    gettedAnswers.removeAllObjects()
    self.perform(#selector(requestForQuestions), with:  "test", afterDelay: kGameRoundDelay)
  }

  
  
  func answerGetted(data:Data){
    
    let gettedAnswer:String = String.init(data: data, encoding: .utf8)!
    
    let answerComponents = gettedAnswer.components(separatedBy: ",")
    
    let playerRes:NSMutableDictionary = NSMutableDictionary()
    playerRes.setObject((Int(answerComponents.first!) == rightAnswer), forKey: "isCorrect" as NSCopying)
    playerRes.setObject(Date().timeIntervalSince1970 - questionTime, forKey: "time" as NSCopying)
    playerRes.setObject(answerComponents.last!, forKey: "id" as NSCopying)

    (roundResults[playerRes["id"] as! String] as! NSMutableArray).add(playerRes)

    gettedAnswers.add(playerRes)
    
    guard gettedAnswers.count == playersCount else {
      return
    }
    
    stopTimer()
    
    guard ((self.gameData?.count)! > 1) else {
      pickerView.isHidden = true
      
      self.perform(#selector(requestForThemes), with: gameRound, afterDelay: kGameRoundDelay)

      return
    }
    
    setPointsToPlayers()

    self.gameData?.removeFirst()
    showQuestion(question: (self.gameData?.first!)!)
    
  }
  
  func setPointsToPlayers() {

    guard gettedAnswers.count > 0 else {
      return
    }
    
    let sortedArray = (gettedAnswers as NSArray).sortedArray(using: [NSSortDescriptor(key: "isCorrect", ascending: false)]) as! [[String:AnyObject]]
    
    for i in 0...sortedArray.count-1 {
      let item = sortedArray[i]
      if ((item as [String:Any])["isCorrect"] as! Bool) {
        let playerPoints:Int = playersPoints[(item as [String:Any])["id"] as! String]!
        var pointsToAdd = 0
        
        switch gameRound%(gameTypes.count) + 1 {
          
        case 1:
          pointsToAdd = 100
          playersPoints[(item as [String:Any])["id"] as! String] = playerPoints + pointsToAdd
          break
          
        case 2:
          pointsToAdd = 100*(playersCount-i)
          playersPoints[(item as [String:Any])["id"] as! String] = playerPoints + pointsToAdd
          break
          
        case 3:
          let x = round(((item as [String:Any])["time"] as! Double)*1000)
          let y = Double(round(100*x)/1000)
          pointsToAdd = Int(100*y)
          break
          
        case 4:
          break
          
          
        default:
          break
        }
        
        playersPoints[(item as [String:Any])["id"] as! String] = playerPoints + pointsToAdd

      }
    }

    gettedAnswers.removeAllObjects()

  }
  
  func getRoundWinner(round: Int) -> Int {
    
    let pointsArray:NSMutableDictionary = NSMutableDictionary()
    
    let keys = Array(roundResults.keys)

    for key in keys {
      var points = 0
      for i in 0...(roundResults[key] as! NSMutableArray).count-1 {
        let res:NSMutableDictionary = (roundResults[key] as! NSMutableArray)[i] as! NSMutableDictionary
        points = points + (res["isCorrect"] as! Bool).hashValue
      }
      pointsArray.setObject(points, forKey: key as NSCopying)
    }
    
    return 0
  }
  
  
}

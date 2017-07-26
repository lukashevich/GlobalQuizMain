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
  
  let getQategoriesMethod = "qategories?played="
  let getQuestionsForQategoryMethod = "questions?qategory=18&n=1"
  let getQategoriesMethod2 = "qategories"

  
  var gameData:[[String:Any]]?
  var themes:[[String:Any]]?
  var gameRound = 0
  var rightAnswer = 0

  var playersNames:[String:String]!
  var gettedAnswers:NSMutableArray = NSMutableArray()
  var pickedThemes:NSMutableArray = NSMutableArray()
  var roundResults:[String:Any] = [String:Any]()
  
  var playersPoints:[String:Int] = [String:Int]()
  var timer = Timer()
  var seconds:Int = Int(roundTimerValue)
  
  var isThemePicking:Bool = false

  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var pickerView: UIView!
  
  @IBOutlet weak var questionView: UIVisualEffectView!
  @IBOutlet weak var firstAnswer: UILabel!
  @IBOutlet weak var secondAnswer: UILabel!
  @IBOutlet weak var thirdAnswer: UILabel!
  @IBOutlet weak var fourthAnswer: UILabel!
  @IBOutlet weak var questionLabel: UILabel!
 
  @IBOutlet weak var topView: UIVisualEffectView!
  
  var questionTime:TimeInterval!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    questionLabel.adjustsFontSizeToFitWidth = true
    questionLabel.minimumScaleFactor = 0.2
    
    for i in 1...playersNames.count {
      roundResults[String(i)] = NSMutableArray()
      playersPoints[String(i)] = 0
    }

    pickerView.bringSubview(toFront: questionView)

    data = NSMutableData()
    
    requestForThemes(forRound: gameRound)
    
  }
  
  
  func requestForThemes(forRound:Int)  {
    
    isThemePicking = true
    
    var pickedThemesString = ""
    for i in 0 ..< pickedThemes.count {
      pickedThemesString.append(",\(pickedThemes[i])")
    }
    if pickedThemes.count != 0 {
      pickedThemesString.remove(at: pickedThemesString.startIndex)
    }
    
    let requestStr = serverName+"/"+getQategoriesMethod+pickedThemesString
    print(requestStr)
    Alamofire.request(requestStr).responseJSON { response in
      
      print(response.result.value)
      
      
      let nextTryData:Data = (response.result.value as! String).data(using: .utf8)!
      
      self.themes = try! JSONSerialization.jsonObject(with:nextTryData,
                                                      options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String : Any]]
            
      self.showThemes(theme: self.themes!)
      self.pickerView.isHidden = false
    
//      let data:Data = "firstPicked".data(using: .utf8)!
//      self.perform(#selector(self.themeGetted), with: data, afterDelay: 2.0)

    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "endGameSegue" {
      let endGame:GQEndGameViewController = (segue.destination as! GQEndGameViewController)
      endGame.winners = playersPoints
      endGame.playersNames = playersNames
    }
  }

  
  func requestForQuestions(theme:String){
    
    isThemePicking = false
    
    let themeName = theme
    
    let requestStr = serverName + "/" + themeName + "/"
    print(requestStr)

    Alamofire.request(requestStr).responseJSON { response in
      
      let nextTryData:Data = (response.result.value as! String).data(using: .utf8)!
      print(response.result.value)

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
    
//    print(gettedAnswers)
//
//    print(playersPoints)
    
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
    
    timerLabel.isHidden = false

//    print(playersPoints)
    
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
  
  func showThemes(theme:[[String:Any]]){
    
    timerLabel.isHidden = true
    
     //[["qategory": Шахматы, "ID": 27], ["qategory": Биология, "ID": 6], ["qategory": Мосты, "ID": 49]]
    
    self.questionLabel.text = gameTypes[gameRound%(gameTypes.count)]
    
    self.firstAnswer.text =   theme[0]["qategory"] as? String
    self.secondAnswer.text =  theme[1]["qategory"] as? String
    self.thirdAnswer.text =   theme[2]["qategory"] as? String
    self.fourthAnswer.text =  theme[3]["qategory"] as? String

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
    
    if isThemePicking {

      let pickedTheme = self.themes?[Int(answerComponents.first!)! - 1]
      let themeId:Int = Int(pickedTheme?["ID"] as! String)!
      let theme = "questions?qategory=\(themeId)&n=\(kQuestionCount)"
      pickedThemes.add(themeId)
      requestForQuestions(theme: theme)
      
      
    } else {
      let playerRes:NSMutableDictionary = NSMutableDictionary()
      playerRes.setObject((Int(answerComponents.first!) == rightAnswer), forKey: "isCorrect" as NSCopying)
      playerRes.setObject(Date().timeIntervalSince1970 - questionTime, forKey: "time" as NSCopying)
      playerRes.setObject(answerComponents.last!, forKey: "id" as NSCopying)
      
      
      if !checkForSecondAnswer(playerId:(playerRes["id"] as! String)) {
        (roundResults[playerRes["id"] as! String] as! NSMutableArray).add(playerRes)
        gettedAnswers.add(playerRes)

      }
      
      guard gettedAnswers.count >= playersNames.count else {
        return
      }
      
      setPointsToPlayers()
      
      stopTimer()

      guard ((self.gameData?.count)! > 1) else {
        
        guard kGameRoundCount > pickedThemes.count else {
          performSegue(withIdentifier: "endGameSegue", sender: self)
          return
        }
        
        pickerView.isHidden = true
        
        self.perform(#selector(requestForThemes), with: gameRound, afterDelay: kGameRoundDelay)
        
        return
      }
      
      self.performSelector(onMainThread: #selector(showRightAnswerAndNextQuestion), with: nil, waitUntilDone: true)
    }
    
  }
  
  func showRightAnswerAndNextQuestion() {
    var viewForAnimate:UILabel?
    
    switch rightAnswer {
    case 1:
      viewForAnimate = firstAnswer
      break;
      
    case 2:
      viewForAnimate = secondAnswer
      
      break;
      
    case 3:
      viewForAnimate = thirdAnswer
      
      break;
      
    case 4:
      viewForAnimate = fourthAnswer
      
      break;
      
    default:
      viewForAnimate = nil
    }
    
    UIView.animate(withDuration: 0.25, animations: {
      viewForAnimate!.alpha = 0.0
    }) { (true) in
      UIView.animate(withDuration: 0.25, animations: {
        viewForAnimate!.alpha = 1.0
      }) { (true) in
        self.gameData?.removeFirst()
        self.showQuestion(question: (self.gameData?.first!)!)
      }
      
    }
    
  }
  
  
  func checkForSecondAnswer(playerId:String) -> Bool {
    print(gettedAnswers)

    for i in 0 ..< gettedAnswers.count {
      if ((gettedAnswers[i] as! Dictionary<String, Any>)["id"]! as! String).isEqual(playerId) {
        return true
      }
    }
    
    return false
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
          pointsToAdd = 100*(playersNames.count-i)
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
        
        
        var id:NSNumber?
        if let myInteger = Int((item as [String:Any])["id"] as! String) {
          id = NSNumber(value:myInteger)
        }
        
        print(id!)
        
        let playerLabel = topView.viewWithTag(id as! Int) as! UILabel
        playerLabel.text = "ID \(playerLabel.tag):\(playerPoints + pointsToAdd)"

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

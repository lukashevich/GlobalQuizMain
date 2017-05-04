//
//  GQThemePickerViewController.swift
//  GlobalQuizMain
//
//  Created by Alexander Lukashevich  on 5/4/17.
//  Copyright © 2017 Alexander Lukashevich . All rights reserved.
//

import UIKit
import Alamofire

class GQThemePickerViewController: UIViewController {

  @IBOutlet weak var roundTypeLabel: UILabel!
  
  @IBOutlet weak var secondTheme: UILabel!
  @IBOutlet weak var firstTheme: UILabel!
  @IBOutlet weak var thirdTheme: UILabel!
  @IBOutlet weak var fourthTheme: UILabel!
  
  var gameData:[String:Any]?

  
  let serverName = "http://quiz.vany.od.ua/wp-json/quiz"

    override func viewDidLoad() {
        super.viewDidLoad()

      requestToServer(methodName: "test")

        // Do any additional setup after loading the view.
    }

  func requestToServer(methodName:String){
    
    print("Request")
    
    let serverMethodName = methodName
    
    let requestStr = serverName + "/" + serverMethodName + "/"
    print(requestStr)
    
//    Alamofire.request(requestStr).responseJSON { response in
    
//      let nextTryData:Data = (response.result.value as! String).data(using: .utf8)!
      
      
      let nextTryData:Data = "{\"id1\":\"Название темы1\", \"id2\":\"Название темы2\", \"id3\":\"Название темы3\", \"id4\":\"Название темы4\"}".data(using: .utf8)!
      
      self.gameData = try! JSONSerialization.jsonObject(with:nextTryData,
                                                        options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : Any]
      
      self.startGame()
      
//    }
  }
  
  func startGame() {
    showThemes(theme: self.gameData!)
  }
  
  func showThemes(theme:[String:Any]){
    
    self.roundTypeLabel.text = "THEME"//theme["question"] as! String?
    
    let keys = Array(theme.keys)
    
    self.firstTheme.text =   keys[0]
    self.secondTheme.text =  keys[1]
    self.thirdTheme.text =   keys[2]
    self.fourthTheme.text =  keys[3]
    
    //    if((self.gameData?.count)! > 1) {
    //      self.gameData?.removeFirst()
    //      perform(#selector(startGame), with: nil, afterDelay: 2.0)
    //    }
    //    else {
    //      perform(#selector(requestToServer), with: "test", afterDelay: 2.0)
    //    }
  }



}

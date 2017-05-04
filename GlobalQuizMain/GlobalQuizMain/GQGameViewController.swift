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
  
  //    let PERIPHERAL_UUID =
  //        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74aa")
  //
  //    let PERIPHERAL_SERVICE_UUID =
  //        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74aa")
  //
  //    let PERIPHERAL_START_GAME_CHAR =
  //        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74dd")
  //
  //    let PERIPHERAL_ENABLE_ANSWER_CHAR =
  //        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74bb")
  //
  //    let PERIPHERAL_ANSWER_CHAR =
  //        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74db")
  //
  //  var centralManager:CBCentralManager?
  //  var discoveredPeripheral:CBPeripheral?
  //    var peripherals:NSMutableArray?
  var data:NSMutableData?
  //  var manager:CBCentralManager!
  //  var peripheral:CBPeripheral!
  let serverName = "http://quiz.vany.od.ua/wp-json/quiz"
  
  //    let serverName = "http://quiz.vany.od.ua"
  
  //  quiz.vany.od.ua/wp-json/quiz/test
  var gameData:[[String:Any]]?
  var themes:[String:Any]?
var gameRound = 1
  var rightAnswer = 0

  
  @IBOutlet weak var pickerView: UIView!
  
  @IBOutlet weak var questionView: UIVisualEffectView!
  @IBOutlet weak var firstAnswer: UILabel!
  @IBOutlet weak var secondAnswer: UILabel!
  @IBOutlet weak var thirdAnswer: UILabel!
  @IBOutlet weak var fourthAnswer: UILabel!
  @IBOutlet weak var questionLabel: UILabel!
  
  //  let BEAN_SCRATCH_UUID =
  //    CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
  //  let BEAN_SERVICE_UUID =
  //    CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
  //    let BEAN_SERVICE_2_UUID =
  //        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74db")
  //
  //    let BEAN_CHAR_UUID =
  //        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74da")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pickerView.bringSubview(toFront: questionView)
    //    peripherals = NSMutableArray()
    //    print("viewDidLoad")
    //
    //    centralManager = CBCentralManager.init(delegate: self, queue: nil)
    data = NSMutableData()
    
    requestForThemes(forRound: gameRound)
    
  }
  
  func requestForThemes(forRound:Int)  {
    print("Request")
    
//    let serverMethodName = methodName
//    
//    let requestStr = serverName + "/" + serverMethodName + "/"
//    print(requestStr)
    
    //    Alamofire.request(requestStr).responseJSON { response in
    
    //      let nextTryData:Data = (response.result.value as! String).data(using: .utf8)!

    
    questionLabel.text = gameTypes[gameRound%(gameTypes.count)]
    
    let nextTryData:Data = "{\"id1\":\"Название темы1\", \"id2\":\"Название темы2\", \"id3\":\"Название темы3\", \"id4\":\"Название темы4\"}".data(using: .utf8)!
    
    self.themes = try! JSONSerialization.jsonObject(with:nextTryData,
                                                      options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : Any]
    showThemes(theme: self.themes!)
    self.pickerView.isHidden = false

    
    let data:Data = "firstPicked".data(using: .utf8)!
    perform(#selector(themeGetted), with: data, afterDelay: 2.0)

    
    //    }

  }
  
  //  func centralManagerDidUpdateState(_ central: CBCentralManager) {
  //
  //    switch central.state {
  //    case .unauthorized:
  //      print("This app is not authorised to use Bluetooth low energy")
  //    case .poweredOff:
  //      print("Bluetooth is currently powered off.")
  //    case .poweredOn:
  //      print("Bluetooth is currently powered on and available to use.")
  //
  ////      let services = [PERIPHERAL_SENDING_CHAR, PERIPHERAL_SERVICE_UUID]
  //      centralManager?.scanForPeripherals(withServices: nil, options: nil)
  //    default:break
  //    }
  //  }
  //
  //  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
  //    print("DIscovered ")
  //    print(peripheral.name ?? "NOTHING")
  //    print(RSSI)
  //    print("\n")
  //    print(peripherals ?? "FUCK")
  //
  //    if discoveredPeripheral != peripheral {
  //      discoveredPeripheral = peripheral
  //        peripheral.delegate = self
  //        peripherals?.add(peripheral)
  ////      centralManager?.connect(peripheral, options: nil)
  //
  //    }
  //}
  //
  //    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
  //        print("didModifyServices")
  //        print(invalidatedServices)
  //    }
  
  func requestForQuestions(theme:String){
  
    print("Request")
    
    let themeName = theme
    
    let requestStr = serverName + "/" + themeName + "/"
    print(requestStr)
    
    Alamofire.request(requestStr).responseJSON { response in
      
      let nextTryData:Data = (response.result.value as! String).data(using: .utf8)!
      
      self.gameData = try! JSONSerialization.jsonObject(with:nextTryData,
                                                        options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String : Any]]
      self.pickerView.isHidden = false

      
      self.startGame()
      
    }

  
  }
  
//  func requestToServer(methodName:String){
//    
//    print("Request")
//    
//    let serverMethodName = methodName
//    
//    let requestStr = serverName + "/" + serverMethodName + "/"
//    print(requestStr)
//    
//    Alamofire.request(requestStr).responseJSON { response in
//      
//      let nextTryData:Data = (response.result.value as! String).data(using: .utf8)!
//      
//      self.gameData = try! JSONSerialization.jsonObject(with:nextTryData,
//                                                        options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String : Any]]
//      
//      self.startGame()
//      
//    }
//  }
  
  func startGame() {
    
    showQuestion(question: (self.gameData?.first!)!)
    
  }
  
  func showQuestion(question:[String:Any]){
    
    self.questionLabel.text = question["question"] as! String?
    
    rightAnswer = Int((question["correct"] as! String?)!)!
   
    self.firstAnswer.text =   (question["answers"] as! Array)[0]
    self.secondAnswer.text =  (question["answers"] as! Array)[1]
    self.thirdAnswer.text =   (question["answers"] as! Array)[2]
    self.fourthAnswer.text =  (question["answers"] as! Array)[3]
    
    
    let data:Data = "4".data(using: .utf8)!
    perform(#selector(answerGetted), with: data, afterDelay: 1)
    
    //    if((self.gameData?.count)! > 1) {
    //      self.gameData?.removeFirst()
    //      perform(#selector(startGame), with: nil, afterDelay: 2.0)
    //    }
    //    else {
    //      perform(#selector(requestToServer), with: "test", afterDelay: 2.0)
    //    }
  }
  
  func showThemes(theme:[String:Any]){
    
    self.questionLabel.text = gameTypes[gameRound%(gameTypes.count)]
    
    let keys = Array(theme.keys)
    
    self.firstAnswer.text =   theme[keys[0]] as? String
    self.secondAnswer.text =  theme[keys[1]] as? String
    self.thirdAnswer.text =   theme[keys[2]] as? String
    self.fourthAnswer.text =  theme[keys[3]] as? String
    
    //    if((self.gameData?.count)! > 1) {
    //      self.gameData?.removeFirst()
    //      perform(#selector(startGame), with: nil, afterDelay: 2.0)
    //    }
    //    else {
    //      perform(#selector(requestToServer), with: "test", afterDelay: 2.0)
    //    }
  }
  
  
  
  //  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
  //    print("didDiscoverServices")
  //    for service:CBService in peripheral.services! {
  //      peripheral.discoverCharacteristics([PERIPHERAL_START_GAME_CHAR, PERIPHERAL_ENABLE_ANSWER_CHAR, PERIPHERAL_ANSWER_CHAR], for: service)
  //    }
  //  }
  //
  //  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
  //     print("didDiscoverCharacteristicsFor")
  //    print(service.characteristics)
  //    print(service.uuid)
  //    for char:CBCharacteristic in service.characteristics! {
  //        print(char.uuid)
  //
  //      if  char.uuid.isEqual(PERIPHERAL_START_GAME_CHAR) {
  ////        peripheral.setNotifyValue(true, for: char)
  //
  //        print(NSKeyedArchiver.archivedData(withRootObject: (self.gameData?.first!)!))
  //
  //        peripheral.writeValue("Start".data(using:String.Encoding.utf8)!, for:char, type:CBCharacteristicWriteType.withResponse)
  //
  //        //peripheral.writeValue(NSKeyedArchiver.archivedData(withRootObject: (self.gameData?.first!)!), for:char, type:CBCharacteristicWriteType.withResponse)
  //
  //      } else if char.uuid.isEqual(PERIPHERAL_ANSWER_CHAR) {
  //        peripheral.setNotifyValue(true, for: char)
  //
  //        }
  //    }
  //  }
  //
  //
  
  func themeGetted(data:Data){
    
    pickerView.isHidden = true
    print( NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String)
    requestForQuestions(theme: "test")

//    requestForQuestions(theme: NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String)
    
    //    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "FUCK")
    //
    //    if((self.gameData?.count)! > 1) {
    //      self.gameData?.removeFirst()
    //      startGame()
    //      //        perform(#selector(startGame), with: nil, afterDelay: 2.0)
    //    }
    //    else {
    //      requestToServer(methodName: "test")
    //      //        perform(#selector(requestToServer), with: "test", afterDelay: 2.0)
    //    }
    
  }

  
  
  func answerGetted(data:Data){
    
    if(NSString(data: data, encoding: String.Encoding.utf8.rawValue)?.isEqual(to: String(rightAnswer)))!{
      print("RIGHT")
    }else {
      print("WRONG")
    }
//    pickerView.isHidden = true

    //    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "FUCK")
    //
        if((self.gameData?.count)! > 1) {
          self.gameData?.removeFirst()
          showQuestion(question: (self.gameData?.first!)!)
          //        perform(#selector(startGame), with: nil, afterDelay: 2.0)
        }
        else {
           pickerView.isHidden = true
          gameRound = gameRound + 1
          requestForThemes(forRound: gameRound)
          //        perform(#selector(requestToServer), with: "test", afterDelay: 2.0)
        }
    
  }
  
  //  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
  //
  //    let data:Data = characteristic.value!
  //
  //
  //    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "FUCK")
  //
  //    if((self.gameData?.count)! > 1) {
  //        self.gameData?.removeFirst()
  //        startGame()
  ////        perform(#selector(startGame), with: nil, afterDelay: 2.0)
  //    }
  //    else {
  //        requestToServer(methodName: "test")
  ////        perform(#selector(requestToServer), with: "test", afterDelay: 2.0)
  //    }
  //
  //  }
  //
  //  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
  //
  //    print(error.debugDescription)
  //
  //    if characteristic.isNotifying {
  //        characteristic.value
  //      print("Notification begins")
  //    } else {
  //        print("didUpdateNotificationStateFor")
  //    }
  //  }
  //
  //
  //  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
  //     print("didConnect")
  //    peripheral.discoverServices([PERIPHERAL_SERVICE_UUID])
  //
  //     print(peripheral.services ?? "nothing")
  //
  //    centralManager?.scanForPeripherals(withServices: [PERIPHERAL_SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
  //  }
  //
  ////  @IBAction func aswerPressed(_ sender: Any) {
  ////    let answerButton:UIButton = sender as! UIButton
  ////
  ////    requestToServer(methodName: "test")
  ////
  ////    switch answerButton {
  ////    case firstAnswer :
  ////      print("firstAnswer")
  ////      break
  ////    case secondAnswer :
  ////      print("secondAnswer")
  ////      break
  ////    case thirdAnswer :
  ////      print("thirdAnswer")
  ////      break
  ////    case fourthAnswer :
  ////      print("fourthAnswer")
  ////      break
  ////      
  ////    default:
  ////      print("WTF !?")
  ////      
  ////    }
  ////    
  ////    
  ////  }
  
  
}

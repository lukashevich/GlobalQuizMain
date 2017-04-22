//
//  ViewController.swift
//  GlobalQuizMain
//
//  Created by Alexander Lukashevich  on 2/1/17.
//  Copyright © 2017 Alexander Lukashevich . All rights reserved.
//

import UIKit
import Alamofire
import CoreBluetooth

//public let DEVICE_INFO_UUID = CBUUID(string: "180B")
//public let DEVICE_ANSWER_UUID = CBUUID(string: "180A")

class ViewController: UIViewController {
  
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
//    peripherals = NSMutableArray()
//    print("viewDidLoad")
//    
//    centralManager = CBCentralManager.init(delegate: self, queue: nil)
    data = NSMutableData()
    
    requestToServer(methodName: "test")

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
    
  func requestToServer(methodName:String){
    
    print("Request")

    let serverMethodName = methodName
    
    let requestStr = serverName + "/" + serverMethodName + "/"
    print(requestStr)
    
    Alamofire.request(requestStr).responseJSON { response in

      let nextTryData:Data = (response.result.value as! String).data(using: .utf8)!
      
      self.gameData = try! JSONSerialization.jsonObject(with:nextTryData,
                                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String : Any]]
      
      self.startGame()
      
    }
  }
  
  func startGame() {
    
    showQuestion(qusestion: (self.gameData?.first!)!)
    
  }
  
  func showQuestion(qusestion:[String:Any]){
    
    self.questionLabel.text = qusestion["question"] as! String?
    
    self.firstAnswer.text =   (qusestion["answers"] as! Array)[0]
    self.secondAnswer.text =  (qusestion["answers"] as! Array)[1]
    self.thirdAnswer.text =   (qusestion["answers"] as! Array)[2]
    self.fourthAnswer.text =  (qusestion["answers"] as! Array)[3]
    
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
  
  func answerGetted(data:Data){
    
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




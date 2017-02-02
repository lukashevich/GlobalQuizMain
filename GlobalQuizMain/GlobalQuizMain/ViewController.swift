//
//  ViewController.swift
//  GlobalQuizMain
//
//  Created by Alexander Lukashevich  on 2/1/17.
//  Copyright © 2017 Alexander Lukashevich . All rights reserved.
//

import UIKit

import UIKit
import CoreBluetooth
import Alamofire

public let DEVICE_INFO_UUID = CBUUID(string: "180B")
public let DEVICE_ANSWER_UUID = CBUUID(string: "180A")

class ViewController: UIViewController ,CBCentralManagerDelegate, CBPeripheralDelegate {
  
  var centralManager:CBCentralManager?
  var discoveredPeripheral:CBPeripheral?
  
  var data:NSMutableData?
  //  var manager:CBCentralManager!
  //  var peripheral:CBPeripheral!
  let serverName = "http://quiz.vany.od.ua/wp-json/quiz"
  
//    let serverName = "http://quiz.vany.od.ua"
  
  //  quiz.vany.od.ua/wp-json/quiz/test
  
  @IBOutlet weak var firstAnswer: UILabel!
  @IBOutlet weak var secondAnswer: UILabel!
  @IBOutlet weak var thirdAnswer: UILabel!
  @IBOutlet weak var fourthAnswer: UILabel!
  
  @IBOutlet weak var questionLabel: UILabel!
  
  let BEAN_NAME = "Robu"
  let BEAN_SCRATCH_UUID =
    CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
  let BEAN_SERVICE_UUID =
    CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("viewDidLoad")
    
    centralManager = CBCentralManager.init(delegate: self, queue: nil)
    data = NSMutableData()
    
    requestToServer(methodName: "test")

  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
    switch central.state {
    case .unauthorized:
      print("This app is not authorised to use Bluetooth low energy")
    case .poweredOff:
      print("Bluetooth is currently powered off.")
    case .poweredOn:
      print("Bluetooth is currently powered on and available to use.")
      
      let services = [DEVICE_INFO_UUID, DEVICE_ANSWER_UUID]
      centralManager?.scanForPeripherals(withServices: nil, options: nil)
    default:break
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("DIscovered ")
    print(peripheral.name ?? "NOTHING")
    print(peripheral.services)
    print(RSSI)
    
    if discoveredPeripheral != peripheral {
      discoveredPeripheral = peripheral
      print("Connecting ")
      centralManager?.connect(peripheral, options: nil)
      
    }
    
    print("\n\n\n\n\n\n\n\n\n\n\n")
    
    
  }
  
  func requestToServer(methodName:String){
    
    print("Request")

    let serverMethodName = methodName
    
    let requestStr = serverName + "/" + serverMethodName + "/"
    print(requestStr)
    
    Alamofire.request(requestStr).responseJSON { response in
      print(response.request ?? "")  // original URL request
      print("\n")
      print(response.response ?? "") // HTTP URL response
      print("\n")
      print(response.data ?? "")     // server data
      
      print("\n")
      print(response.result.value ?? "response")

//      let res:String = "[{"question":"Как называют списки редких и находящихся под угрозой исчезновения видов растений и животных?","answers":"Синяя книга","Красная книга","Белая книга","Зеленая книга","correct":"2"},{"question":"К какой части света относится Шотландия?","answers":"Европа","Азия","Америка","Австралия","correct":"1"},{"question":"Что в анатомии не относят к туловищу?","answers":"Таз","Голову","Грудь","Живот","correct":"2"},{"question":"Крупнейшим городом какой страны является Нью-Йорк?","answers":"Испания","Великобритания","США","Австралия","correct":"3"}]"
      
      let nextTry:String = "{"+(response.result.value as! String)+"}"
      let nextTryData:Data = nextTry.data(using: .utf8)!
      
//      let jsonObject = try! JSONSerialization.jsonObject(with: nextTryData,
//                                                              options: JSONSerialization.ReadingOptions.mutableContainers)
      
      self.questionLabel.text = "Как называют списки редких и находящихся под угрозой исчезновения видов растений и животных?"
      
      self.firstAnswer.text =  "Синяя книга"
      self.secondAnswer.text =  "Красная книга"
      self.thirdAnswer.text =  "Белая книга"
      self.fourthAnswer.text =  "Зеленая книга"
      
      
//       print("JSON: \(jsonObject)")
      //      print(response.request )   // result of response serialization
      //
//      if let JSON:[[String:AnyObject]] = response.result.value as? [[String:AnyObject]]{
//        
//        print("JSON: \(JSON)")
//      }
    }
    
    
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    for service:CBService in peripheral.services! {
      peripheral.discoverCharacteristics([BEAN_SERVICE_UUID], for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    for char:CBCharacteristic in service.characteristics! {
      if  char.uuid.isEqual(BEAN_SERVICE_UUID) {
        peripheral.setNotifyValue(true, for: char)
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    let strFromData:NSString = NSString.init(data: data?.copy() as! Data, encoding: String.Encoding.utf8.rawValue)!
    
    if strFromData.isEqual("EOM") {
      
      peripheral.setNotifyValue(false, for: characteristic)
      centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    data?.append(characteristic.value!)
    
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    
    if characteristic.isNotifying {
      print("Notification begins")
    } else {
      centralManager?.cancelPeripheralConnection(peripheral)
    }
  }
  
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    discoveredPeripheral = nil
    centralManager?.scanForPeripherals(withServices: [BEAN_SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
  }
  
//  @IBAction func aswerPressed(_ sender: Any) {
//    let answerButton:UIButton = sender as! UIButton
//    
//    requestToServer(methodName: "test")
//    
//    switch answerButton {
//    case firstAnswer :
//      print("firstAnswer")
//      break
//    case secondAnswer :
//      print("secondAnswer")
//      break
//    case thirdAnswer :
//      print("thirdAnswer")
//      break
//    case fourthAnswer :
//      print("fourthAnswer")
//      break
//      
//    default:
//      print("WTF !?")
//      
//    }
//    
//    
//  }
  
  
}




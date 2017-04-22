//
//  GQLobbyViewController.swift
//  GlobalQuizMain
//
//  Created by Alexander Lukashevich  on 4/22/17.
//  Copyright © 2017 Alexander Lukashevich . All rights reserved.
//

import UIKit
import CoreBluetooth

class GQLobbyViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{

  let PERIPHERAL_UUID =
    CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74aa")
  
  let PERIPHERAL_SERVICE_UUID =
    CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74aa")
  
  let PERIPHERAL_START_GAME_CHAR =
    CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74dd")
  
  let PERIPHERAL_ENABLE_ANSWER_CHAR =
    CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74bb")
  
  let PERIPHERAL_ANSWER_CHAR =
    CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74db")
  
  var centralManager:CBCentralManager?
  var discoveredPeripheral:CBPeripheral?
  var peripherals:NSMutableArray = NSMutableArray()
  var validatedPeripherals:NSMutableArray = NSMutableArray()

  var iPadPeripheral:CBPeripheral?
  var iPhonePeripheral:CBPeripheral?
  var finded:[String:CBPeripheral] = [String:CBPeripheral]()
  
  var game:ViewController?
  
  @IBOutlet weak var peripheralsTableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      peripheralsTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "peripheralCell")
      peripheralsTableView.isUserInteractionEnabled = false
      
      
      centralManager = CBCentralManager.init(delegate: self, queue: nil)
    }


  @IBAction func startGamePressed(_ sender: Any) {
    centralManager?.stopScan()

    for peripheral in peripherals {
      print((peripheral as! CBPeripheral).state.rawValue)
      centralManager?.connect(finded[(peripheral as! CBPeripheral).name!]!, options: nil)
    }
    
//    centralManager?.connect(iPadPeripheral!, options: nil)
//
//    centralManager?.connect(iPhonePeripheral!, options: nil)

    
    performSegue(withIdentifier: "startGameSegue", sender: self)
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    for peripheral in peripherals {
      print((peripheral as! CBPeripheral).state.rawValue)
      
    }

    print("validatedPeripherals")

    print(validatedPeripherals)

    if segue.identifier == "startGameSegue" {
      game = (segue.destination as! ViewController)
    }
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
    switch central.state {
    case .unauthorized:
      print("This app is not authorised to use Bluetooth low energy")
    case .poweredOff:
      print("Bluetooth is currently powered off.")
    case .poweredOn:
      print("Bluetooth is currently powered on and available to use.")
      
//            let services = [PERIPHERAL_START_GAME_CHAR, PERIPHERAL_ENABLE_ANSWER_CHAR, PERIPHERAL_ANSWER_CHAR]
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    default:
      print(central.state.rawValue)

      break
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("DIscovered ")
    print(peripheral.name ?? "NOTHING")
    print("\n")
//    print(advertisementData.description )
    
    if !peripherals.contains(peripheral){
      
      peripheral.delegate = self
      
      if  peripheral.name == "iPad mini" ||
          peripheral.name == "Lukashevich\'s iPhone" ||
          peripheral.name == "Moto G (4)" {
      
//        peripherals.add(peripheral)

        if  peripheral.name == "iPad mini" {
          iPadPeripheral = peripheral
          peripherals.add(iPadPeripheral ?? peripheral)

        }
      
        if  peripheral.name == "Lukashevich\'s iPhone" {
          iPhonePeripheral = peripheral
          peripherals.add(iPhonePeripheral ?? peripheral)
          
        }
        
        finded.updateValue(peripheral, forKey: peripheral.name!)

        peripheralsTableView.reloadData()
      }
      
//     centralManager?.connect(peripheral, options: nil)
      
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    print("didModifyServices")
    print(invalidatedServices)
  }


  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print("didDiscoverServices")
    for service:CBService in peripheral.services! {
      peripheral.discoverCharacteristics([PERIPHERAL_START_GAME_CHAR, PERIPHERAL_ENABLE_ANSWER_CHAR, PERIPHERAL_ANSWER_CHAR], for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    
    validatedPeripherals.add(peripheral)
//    centralManager?.cancelPeripheralConnection(peripheral)
    
    print("didDiscoverCharacteristicsFor")
    print(service.characteristics)
    print(service.uuid)
    for char:CBCharacteristic in service.characteristics! {
      print(char.uuid)
      
      if  char.uuid.isEqual(PERIPHERAL_START_GAME_CHAR) {
        //        peripheral.setNotifyValue(true, for: char)
        
        
        peripheral.writeValue("Start".data(using:String.Encoding.utf8)!, for:char, type:CBCharacteristicWriteType.withResponse)
        
        //peripheral.writeValue(NSKeyedArchiver.archivedData(withRootObject: (self.gameData?.first!)!), for:char, type:CBCharacteristicWriteType.withResponse)
        
      } else if char.uuid.isEqual(PERIPHERAL_ANSWER_CHAR) {
        peripheral.setNotifyValue(true, for: char)
        
      }
    }
  }
  
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    game?.answerGetted(data: characteristic.value!)
    
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    
    print(error.debugDescription)
    
    if characteristic.isNotifying {
      characteristic.value
      print("Notification begins")
    } else {
      print("didUpdateNotificationStateFor")
    }
  }
  
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("didConnect")
    peripheral.discoverServices([PERIPHERAL_SERVICE_UUID])
    
    print(peripheral.services ?? "nothing")
    
//    centralManager?.scanForPeripherals(withServices: [PERIPHERAL_SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
  }
  


}

extension GQLobbyViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peripherals.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell")!
    
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "peripheralCell")
    }
    cell.backgroundColor = UIColor.white
    let peripheral:CBPeripheral = peripherals[indexPath.row] as! CBPeripheral
    cell.textLabel?.textColor = UIColor.gray
//    cell.textLabel?.text = "Player "+String(indexPath.row+1)
    cell.textLabel?.text = peripheral.name

    return cell
  }
}

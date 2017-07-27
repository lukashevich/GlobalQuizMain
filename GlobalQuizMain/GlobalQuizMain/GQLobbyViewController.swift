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
  
  let PERIPHERAL_PAUSE_CHAR =
    CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74ad")
//  let PERIPHERAL_PAUSE_CHAR =
//    CBUUID(string: "259e766c-15c3-4824-80e6-2ecf897cc497")
  
  let PERIPHERAL_END_CHAR =
    CBUUID(string: "6a5d8a8a-718d-4ebf-a86f-85c2375d245f")
  
  let PERIPHERAL_THEME_CHAR =
    CBUUID(string: "b495ff20-c5b1-4b44-b512-1370f02d74db")
  
  
  var centralManager:CBCentralManager?
  var discoveredPeripheral:CBPeripheral?
  var peripherals:NSMutableArray = NSMutableArray()
  var validatedPeripherals:NSMutableArray = NSMutableArray()
  var playersNames:[String:String] = [String:String]()

  var iPadPeripheral:CBPeripheral?
  var iPhonePeripheral:CBPeripheral?
  var finded:[String:CBPeripheral] = [String:CBPeripheral]()
  
  var game:GQGameViewController?
  
  
  
  
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
      for char:CBCharacteristic in ((peripheral as! CBPeripheral).services?.first?.characteristics!)! {
        print("\n")
        print(char)
        print("\n")

        if  char.uuid.isEqual(PERIPHERAL_START_GAME_CHAR) {
          //        peripheral.setNotifyValue(true, for: char)
          
          let playerId:Int = (peripherals.index(of: peripheral))
          
          (peripheral as! CBPeripheral).writeValue("Start,\(playerId+1)".data(using:String.Encoding.utf8)!, for:char, type:CBCharacteristicWriteType.withResponse)
          playersNames.updateValue((peripheral as! CBPeripheral).name!, forKey: String(playerId+1))
          //        let playerIdData = Data(bytes: &playerId,
          //                             count: MemoryLayout.size(ofValue: playerId))
          //        peripheral.writeValue(playerIdData, for:char, type:CBCharacteristicWriteType.withResponse)
          
          //peripheral.writeValue(NSKeyedArchiver.archivedData(withRootObject: (self.gameData?.first!)!), for:char, type:CBCharacteristicWriteType.withResponse)
          
        } else if char.uuid.isEqual(PERIPHERAL_ANSWER_CHAR) {
          (peripheral as! CBPeripheral).setNotifyValue(true, for: char)
          
        } else if char.uuid.isEqual(PERIPHERAL_PAUSE_CHAR) {
          (peripheral as! CBPeripheral).setNotifyValue(true, for: char)
          
        } else if char.uuid.isEqual(PERIPHERAL_END_CHAR) {
          (peripheral as! CBPeripheral).setNotifyValue(true, for: char)
          
        }
      }

    }
    
    performSegue(withIdentifier: "startGameSegue", sender: self)
    
  }
  
  func endGame(){
    
    for peripheral in peripherals {
      for char:CBCharacteristic in ((peripheral as! CBPeripheral).services?.first?.characteristics!)! {
        //        print(char.uuid)
        
        if  char.uuid.isEqual(PERIPHERAL_END_CHAR) {
          
          
          (peripheral as! CBPeripheral).writeValue("End".data(using:String.Encoding.utf8)!, for:char, type:CBCharacteristicWriteType.withResponse)

          centralManager?.cancelPeripheralConnection(peripheral as! CBPeripheral)
          
        }
      }
      
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if segue.identifier == "startGameSegue" {
      game = (segue.destination as! GQGameViewController)
      game?.playersNames = playersNames
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
    
    peripheral.delegate = self
    
    if  peripheral.name != nil {
      finded.updateValue(peripheral, forKey: peripheral.name!)
    }
    
    centralManager?.connect(peripheral, options: nil)
    
  }
  
  func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    print("didModifyServices")
    print(invalidatedServices)
  }


  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print("didDiscoverServices")
    for service:CBService in peripheral.services! {
      peripheral.discoverCharacteristics([PERIPHERAL_START_GAME_CHAR, PERIPHERAL_ENABLE_ANSWER_CHAR, PERIPHERAL_ANSWER_CHAR, PERIPHERAL_PAUSE_CHAR], for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    
    if (peripheral.services?.first?.uuid.isEqual(PERIPHERAL_UUID))! {
      if !validatedPeripherals.contains(peripheral) {
        validatedPeripherals.add(peripheral)
        peripherals.add(peripheral)
        finded.updateValue(peripheral, forKey: peripheral.name!)
        peripheralsTableView.reloadData()
      }

    } else {
      centralManager?.cancelPeripheralConnection(peripheral)
      return
    }
    
    print("didDiscoverCharacteristicsFor")

    }
  
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    if characteristic.uuid.isEqual(PERIPHERAL_ANSWER_CHAR) {
       game?.answerGetted(data: characteristic.value!)
    } else if characteristic.uuid.isEqual(PERIPHERAL_PAUSE_CHAR) {
      game?.pauseGame(data: characteristic.value!)
    } else if characteristic.uuid.isEqual(PERIPHERAL_END_CHAR) {
      endGame()
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    
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

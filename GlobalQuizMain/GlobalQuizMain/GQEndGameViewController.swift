//
//  GQEndGameViewController.swift
//  GlobalQuizMain
//
//  Created by Alexander Lukashevich  on 7/26/17.
//  Copyright © 2017 Alexander Lukashevich . All rights reserved.
//

import Foundation
import UIKit

class GQEndGameViewController: UIViewController {
  
  @IBOutlet weak var winnersTableView: UITableView!
  var winners:[String:Int] = [String:Int]()
  var sortedWinners:NSMutableArray = NSMutableArray()
  var playersNames:[String:String]!

  override func viewDidLoad() {
    super.viewDidLoad()
    winnersTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "peripheralCell")
    winnersTableView.isUserInteractionEnabled = false
    

    sortWinners()
    print(sortedWinners)

  }
  
  func sortWinners() {
    for key in winners.keys {
      sortedWinners.add([key:winners[key]])
    }
  }
}

extension GQEndGameViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sortedWinners.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell")!
    
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "peripheralCell")
    }
    
    cell.backgroundColor = UIColor.white
    cell.textLabel?.textColor = UIColor.gray
    
    let key = (sortedWinners[indexPath.row] as! [String:Int]).keys.first

    print(String(describing: winners[key!]))

    cell.textLabel?.text = playersNames[key!]!+": \(winners[key!]!)"
    
    return cell
  }
}



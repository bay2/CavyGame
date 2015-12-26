//
//  SetViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/1.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    


    var cellInof = [["title":Common.LocalizedStringForKey("set_cell_title_1"), "info":Common.LocalizedStringForKey("set_cell_info_1"), "Identifier":"wifi"],
                    ["title":Common.LocalizedStringForKey("set_cell_title_2"), "info":Common.LocalizedStringForKey("set_cell_info_2"), "Identifier":"install"]]

    @IBOutlet weak var setTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("main_leftview_title_setting")
        
        setTableView.delegate = self
        setTableView.dataSource = self
        
        
        var view = UIView()
        
        view.backgroundColor = UIColor.clearColor()
        
        setTableView.tableFooterView = view
        setTableView.tableHeaderView = view
        setTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SetViewController : UITableViewDataSource, UITableViewDelegate, SwitchDelegate{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("setCell", forIndexPath: indexPath) as! SetTableViewCell
        
        cell.setTitleLabel.text = cellInof[indexPath.row]["title"]
        cell.setInfoLabel.text = cellInof[indexPath.row]["info"]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.switchDelegate = self
        cell.setSwitch.restorationIdentifier = cellInof[indexPath.row]["Identifier"]
        
        if let switchOn = NSUserDefaults.standardUserDefaults().valueForKey(cellInof[indexPath.row]["Identifier"]!) as? Bool {
            
            cell.setSwitch.on = switchOn
            
        } else {
            
            NSUserDefaults.standardUserDefaults().setObject(cell.setSwitch.on, forKey: cellInof[indexPath.row]["Identifier"]!)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if cellInof.count - 1 == indexPath.row {
            
            cell.bottomLine.hidden = true
            
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellInof.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 91
        
    }
    
    func switchChange(sender: UISwitch) {
        
        NSUserDefaults.standardUserDefaults().setObject(sender.on, forKey: sender.restorationIdentifier!)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
}
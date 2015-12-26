//
//  AboutTableViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/31.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    @IBOutlet weak var versionLable: UILabel!
    @IBOutlet weak var aboutTitle1: UILabel!
    @IBOutlet weak var aboutTitle2: UILabel!
    @IBOutlet weak var aboutTitle3: UILabel!
    @IBOutlet weak var aboutTitle4: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("main_leftview_title_about")
        
        aboutTitle1.text = Common.LocalizedStringForKey("aboutTitle1")
        aboutTitle2.text = Common.LocalizedStringForKey("aboutTitle2")
        aboutTitle3.text = Common.LocalizedStringForKey("aboutTitle3")
        aboutTitle4.text = Common.LocalizedStringForKey("aboutTitle4")
        
        
        var view = UIView()
        view.backgroundColor = UIColor.clearColor()
        
        tableView.tableFooterView = view
        tableView.tableHeaderView = view
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        versionLable.text = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        
    }

    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 5
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if 4 == indexPath.row {
            
            UIApplication.sharedApplication().openURL(NSURL(string : "http://www.tunshu.com")!)
            
        }
        
    }

}

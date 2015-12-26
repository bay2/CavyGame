//
//  ProtocolViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/11.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class ProtocolViewController: UIViewController {
    @IBOutlet var protocolVc: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("protocolBtn")
        protocolVc.scalesPageToFit = true
        protocolVc.loadRequest(NSURLRequest(URL: NSURL(string: "http://bbs.tunshu.com/r/cms/www/blue/bbs_forum/img/top/phone_xieyi.html")!))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

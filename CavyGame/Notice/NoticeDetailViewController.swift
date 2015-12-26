//
//  NoticeDetailViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/1.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class NoticeDetailViewController: UIViewController {

    @IBOutlet weak var web: UIWebView!
    var loadhttp : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if nil != loadhttp {
            
            var url =  NSURL(string: loadhttp!)
            
            if nil != url {
                
                web.scalesPageToFit = true
                web.loadRequest(NSURLRequest(URL: url!))
            }
            
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    

}

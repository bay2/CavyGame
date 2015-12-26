//
//  FeedbackViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/7/20.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextViewDelegate{

    
    @IBOutlet weak var feedbackText: UITextView!
    @IBOutlet weak var contactText: UITextField!
    @IBOutlet weak var commitBarItem: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("main_leftview_title_feedback")
        feedbackText.delegate = self
    
        commitBarItem.title = Common.LocalizedStringForKey("commit")
        contactText.placeholder = Common.LocalizedStringForKey("contactText")
        
        feedbackText.font = UIFont.systemFontOfSize(16)
  //      feedbackText.placeholderColor = UIColor(hexString: "B6B6BD")
        feedbackText.placeholder = Common.LocalizedStringForKey("feedbackview_text_feedback")
        
        
        // Do any additional setup after loading the view.
    }



    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func onClickCommet(sender: UIBarButtonItem) {
        
        if feedbackText.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("feedbackveiw_text_feedback_prompt"), delayTime: Common.alertDelayTime)
            
            return
        }
        
        if 3 > count(feedbackText.text) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("alert_review_msg"), delayTime: Common.alertDelayTime)
            return
        }
        
        if (true != Common.isTelNumber(contactText.text)) && (true != Common.isEmall(contactText.text)) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("feedbackveiw_text_contact_prompt"), delayTime: Common.alertDelayTime)
            return
        }
        
        var language = Common.getPreferredLanguage()
        
        var loadView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("SDRefreshViewRefreshingStateText"), isClickDisappeared: true)
        
        //提交反馈意见
        HttpHelper<CommmonMsgRet>.feedback(feedbackText.text, contactText: contactText.text, completionHandlerRet: {(result)->()  in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                FVCustomAlertView.shareInstance.hideAlert(loadView!)
                
                if nil == result!.code {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    return
                    
                }
                
                
                
                FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.mainView, withTitle: result!.msg!, delayTime: Common.alertDelayTime)
                
                if "1001" == result!.code {
                    self.navigationController?.popViewControllerAnimated(false)
                }
                
            })
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

            
        var toString = textView.text + (text as String)
            
            
        if 200 < count(toString) && "" != toString  {
                
            return false
                
        }

        
        return true
    }

}


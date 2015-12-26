//
//  KeyboardTextField.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/23.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class KeyboardTextField: UIView, HPGrowingTextViewDelegate{
    
    var textField : HPGrowingTextView?
    var parentView : UIView?
    var delegate : KeyboardTextFieldDelegate?
    var button : UIButton?
    
    convenience init(view : UIView) {
        
        self.init()
        
        addTextField(view)
    }
    
    /**
    添加浮动在键盘上方的文本输入框
    
    :param: view 父视图
    */
    func addTextField(view : UIView) {
        
        parentView = view
        
        self.frame = CGRectMake(0, parentView!.frame.height - 40, parentView!.frame.width, 40)
        self.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(self)
        
        textField = HPGrowingTextView(frame: CGRectMake(10, 5, parentView!.frame.width - 70, 30))
        
        textField?.layer.masksToBounds = true
        textField?.layer.borderWidth = 1
        textField?.layer.borderColor = UIColor(hexString: "ebebeb")?.CGColor
        textField?.layer.cornerRadius = 5
        textField?.isScrollable = false
        textField?.placeholder = "输入评论..."
        textField?.returnKeyType = UIReturnKeyType.Send
        textField?.growingHeightEnaled = true
        
        self.addSubview(textField!)
        
        button = UIButton(frame: CGRectMake(parentView!.frame.width - 60, 5, 50, 30))
        
        button!.setTitle("发送", forState: UIControlState.Normal)
        button!.setTitleColor(UIColor(red: 254/255.0, green: 124/255.0, blue: 148/255.0, alpha: 1), forState: UIControlState.Normal)
        
        self.addSubview(button!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        
        button!.addTarget(self, action: "SendMessage:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.hidden = true
        
    }
    
    func keyboardWillChangeFrame(notification : NSNotification) {
        
        var userInfo : NSDictionary = notification.userInfo!
        
        var duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        var keyboardF = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        
        UIView.animateWithDuration(duration!, animations: { () -> Void in
            
            // 工具条的Y值 == 键盘的Y值 - 工具条的高度
            if (keyboardF!.origin.y > self.parentView!.frame.height)  {
                self.frame.origin.y = self.parentView!.frame.height - self.frame.height
                
            } else {
                self.frame.origin.y = self.parentView!.frame.height - (keyboardF!.height + self.frame.height)
            }
            
        })
    }
    
    func showView() {
        
        textField?.becomeFirstResponder()
        self.hidden = false

    }
    
    func hiddenView() {
        
        self.hidden = true
        textField?.resignFirstResponder()
    }
    
    /**
    发送消息
    */
    func SendMessage(sender: AnyObject) {
        
        delegate?.onClickSendMessage?()
    
    }

}

@objc protocol KeyboardTextFieldDelegate : NSObjectProtocol {
    
    optional func onClickSendMessage()
}

//
//  NikeNameTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/8.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class NikeNameTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        var titleLabel = self.contentView.viewWithTag(2) as! UILabel
        titleLabel.text = Common.LocalizedStringForKey("usercenter_title2")
        nikeName.delegate = self
        nikeName.autocorrectionType = UITextAutocorrectionType.No
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name: UITextFieldTextDidChangeNotification, object: nil)
        
    }
    
    func textChange(notification : NSNotification) {
        
        var newstring = nikeName.text as NSString
        
        if nikeName.markedTextRange != nil {
            return
        }
        
        nikeName.text = StrLength(nikeName.text) as String
        
    }

    @IBOutlet weak var nikeName: UITextField!
    var delegate : NikeNameDelegate?
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func nikeNameDidEndOnExit(sender: UITextField) {
        
        sender.becomeFirstResponder()
        
        Common.rootViewController.leftViewController.userCenterVc!.datePicker.hidden = true
        Common.rootViewController.leftViewController.userCenterVc!.localPicker.hidden = true
        Common.rootViewController.leftViewController.userCenterVc!.genderPicker.hidden = true
        Common.rootViewController.leftViewController.userCenterVc!.userCenterControl.nikename = sender.text
        
    }

    func StrLength(text : NSString) -> NSString {
        
        var asciiLength = 0;
        var newstring = ""
        
        var length = 32
        
        var newtext = text as String
        
        var i = 0
        
        for character in newtext {
            
            var uc = text.characterAtIndex(i)
            
            if 0 != isascii(Int32(uc)) {
                
                asciiLength = asciiLength + 1
                
            } else {
                
                asciiLength = asciiLength + 2
                
            }
            
            if asciiLength > length  {
                break
            }
            
            newstring = newstring + String(character)
            
            i++
        }
        
        
        
        return newstring

    }
    
}

protocol NikeNameDelegate {
    
    func textFieldShouldReturn(textField: UITextField)
    
}


extension NikeNameTableViewCell : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        delegate?.textFieldShouldReturn(textField)
        
        return true
    }
//
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        
//        var toString = textField.text + string
//        
//        if 32 < StrLength(toString) && "" != string  {
//            
//            return false
//            
//        }
//        
//        return true
//        
//    }
//    
}

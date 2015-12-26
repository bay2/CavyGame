//
//  UIImageView+WebImage.swift
//  LIJWebImage
//
//  Created by  李俊 on 15/7/15.
//  Copyright (c) 2015年  李俊. All rights reserved.
//

import Foundation
import UIKit


private var xoAssociationKey: String = "likumb.com.LIJWebImage"
private var reTimeAssociationKey: String = "reloadWebImageTime.com.LIJWebImage"
private var maxReloadWebImageTime : Int = 5 // 最多重复加载次数

extension UIImageView {
   
    var urlParh: String?{
        get{
            return objc_getAssociatedObject(self, &xoAssociationKey) as? String
            
        }
        set{
            
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, UInt(OBJC_ASSOCIATION_COPY_NONATOMIC))
        }
    }
    
    // 重复加载的次数
    var reloadWebImageTime : Int?{
        
        get{
            return objc_getAssociatedObject(self, &reTimeAssociationKey) as? Int
        }
        set{
            objc_setAssociatedObject(self, &reTimeAssociationKey, newValue, UInt(OBJC_ASSOCIATION_COPY_NONATOMIC))
        }
    }
    
    func setWebImage(path: String, network needfromNetwork : Bool){
        
        if path.isEmpty{
            return
        }
        
        urlParh = path
        reloadWebImageTime = 1
        
        if WebImageManager.sharedInstance.isDownloading(path){
            
            reloadImg(path)
            
        }else{
            WebImageManager.sharedInstance.downloadWebImage(urlParh!, network : needfromNetwork, complition: { (image) -> () in
                
                self.image = image
                
                self.urlParh = nil
            })
        }
    }
    
    func reloadImg(path: String){
        if reloadWebImageTime < maxReloadWebImageTime{
            self.delay(2.0, closure: { () -> () in
                
                if  WebImageManager.sharedInstance.isDownloaded(path){
                    self.image = WebImageManager.sharedInstance.getImg(path)
                    
                    self.urlParh = nil
                }else{
                    self.reloadImg(path)
                }
            })
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func reloadWebImage(path: String, network needfromNetwork : Bool){
        
        if path.isEmpty{
            return
        }
        

        WebImageManager.sharedInstance.receviMomeryWorning()

        
        urlParh = path
        
        WebImageManager.sharedInstance.downloadWebImage(urlParh!, network : needfromNetwork, complition: { (image) -> () in
            
            self.image = image
            
            self.urlParh = nil
        })
        
    }
    
    func setWebImage(path: String, network needfromNetwork : Bool, loadFinish: () -> ()){
        
        if urlParh != nil && urlParh != path{
            
            WebImageManager.sharedInstance.cancelOperation(urlParh!)
            
        }
        
        urlParh = path
        
        WebImageManager.sharedInstance.downloadWebImage(urlParh!, network : needfromNetwork, complition: { (image) -> () in
            
            self.image = image
            
            self.urlParh = nil
            
            loadFinish()
        })
        
        
    }
    
}

extension UIButton {
    
    var urlParh: String?{
        get{
            return objc_getAssociatedObject(self, &xoAssociationKey) as? String
            
        }
        set{
            
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, UInt(OBJC_ASSOCIATION_COPY_NONATOMIC))
        }
    }
    
    // 重复加载的次数
    var reloadWebImageTime : Int?{
        
        get{
            return objc_getAssociatedObject(self, &reTimeAssociationKey) as? Int
        }
        set{
            objc_setAssociatedObject(self, &reTimeAssociationKey, newValue, UInt(OBJC_ASSOCIATION_COPY_NONATOMIC))
        }
    }
    
    func setWebImage(path: String, network needfromNetwork : Bool){
        
        if path.isEmpty{
            return
        }
        
        urlParh = path
        reloadWebImageTime = 1
        
        if WebImageManager.sharedInstance.isDownloading(path){
            
            reloadImg(path)
            
        }else{
            
            WebImageManager.sharedInstance.downloadWebImage(urlParh!, network : needfromNetwork, complition: { (image) -> () in
                
                self.setImage(image, forState: UIControlState.Normal)
                
                self.urlParh = nil
            })
        }
    }
    
    func setWebImage(path: String, network needfromNetwork : Bool, loadFinish: () -> ()){
        
        if urlParh != nil && urlParh != path{
            
            WebImageManager.sharedInstance.cancelOperation(urlParh!)
            
        }
        
        urlParh = path
        
        WebImageManager.sharedInstance.downloadWebImage(urlParh!, network : needfromNetwork, complition: { (image) -> () in
            
            self.setImage(image, forState: UIControlState.Normal)
            
            self.urlParh = nil
            
            loadFinish()
        })
        
        
    }
    
    func reloadImg(path: String){
        if reloadWebImageTime < maxReloadWebImageTime{
            self.delay(2.0, closure: { () -> () in
                
                if  WebImageManager.sharedInstance.isDownloaded(path){

                    self.setImage(WebImageManager.sharedInstance.getImg(path), forState: UIControlState.Normal)
                    
                    self.urlParh = nil
                }else{
                    self.reloadImg(path)
                }
            })
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

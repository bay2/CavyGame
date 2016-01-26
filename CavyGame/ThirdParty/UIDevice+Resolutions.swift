//
//  UIDevice+Resolutions.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/8.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation

    enum UIDeviceResolution{
    
        case UIDeviceResolution_Unknown
        case UIDeviceResolution_iPhoneStandard  // iPhone 1,3,3GS Standard Display  (320x480px)
        case UIDeviceResolution_iPhoneRetina35  // iPhone 4,4S Retina Display 3.5"  (640x960px)
        case UIDeviceResolution_iPhoneRetina4   // iPhone 5 Retina Display 4"       (640x1136px)
        case UIDeviceResolution_iPhoneRetina47  // iPhone 6 Retina Display 4.7"     (750x1334px)
        case UIDeviceResolution_iPhoneRetina55  // iPhone 6 Plus Retina Display 5.5"     (1080x1920px)
        case UIDeviceResolution_iPadStandard    // iPad 1,2 Standard Display        (1024x768px)
        case UIDeviceResolution_iPadRetina      // iPad 3 Retina Display            (2048x1536px)
    }
    
    func resolution() -> UIDeviceResolution {
        
        var resolution = UIDeviceResolution.UIDeviceResolution_Unknown
        
        var mainScreen = UIScreen.mainScreen()
        
        var scale = mainScreen.scale
        
        var pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale)
        
        var model : String = UIDevice.currentDevice().model
        if model.componentsSeparatedByString("iPhone").count > 1 {
            
            if scale == 2.0 {
                
                if (pixelHeight == 960.0) {
                    resolution = UIDeviceResolution.UIDeviceResolution_iPhoneRetina35
                } else if (pixelHeight == 1136.0) {
                    resolution = UIDeviceResolution.UIDeviceResolution_iPhoneRetina4
                } else if (pixelHeight == 1334.0) {
                    resolution = UIDeviceResolution.UIDeviceResolution_iPhoneRetina47
                }
            }
            
            if scale == 3.0 {
                resolution = UIDeviceResolution.UIDeviceResolution_iPhoneRetina55
            }
            
        }else{
            
            if (pixelHeight == 2048.0) {
                resolution = UIDeviceResolution.UIDeviceResolution_iPadRetina
                
            } else {
                resolution = UIDeviceResolution.UIDeviceResolution_iPadStandard
            }
            
            
        }
        
        return resolution
        
    }

    func isIPhone() -> Bool {
        
        var model : String = UIDevice.currentDevice().model
        if model.componentsSeparatedByString("iPhone").count > 1 {
            return true
        }
        
        return false
        
    }

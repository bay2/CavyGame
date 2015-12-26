//
//  UIDevice+DeviceInfo.swift
//  CavyGame
//
//  Created by xuemincai on 15/12/1.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation


extension UIDevice {
    
    static func platformRawString() -> String {
        
        var size : Int = 0 // as Ben Stahl noticed in his answer
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](count: Int(size), repeatedValue: 0)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String.fromCString(machine)!
    }
    
    
    
    static func deviceModelDataForMachineIDs() -> String {
        
        var platform : NSString = platformRawString()
        
        if (platform.isEqualToString("iPhone1,1")) { return "iPhone1G"  }
        if (platform.isEqualToString("iPhone1,2")) { return  "iPhone3G" }
        if (platform.isEqualToString("iPhone2,1")) { return "iPhone3GS" }
        if (platform.isEqualToString("iPhone3,1") || platform.isEqualToString("iPhone3,2") || platform.isEqualToString("iPhone3,3")) { return "iPhone4"  }
        if (platform.isEqualToString("iPhone4,1")) { return "iPhone4S" }
        if (platform.isEqualToString("iPhone5,1") || platform.isEqualToString("iPhone5,2")) { return "iPhone5" }
        if (platform.isEqualToString("iPhone5,3") || platform.isEqualToString("iPhone5,4"))     { return "iPhone5C" }
        if (platform.isEqualToString("iPhone6,1") || platform.isEqualToString("iPhone6,2"))     { return "iPhone5S" }
        if (platform.isEqualToString("iPhone7,2")) { return "iPhone6" }
        if (platform.isEqualToString("iPhone7,1")) { return "iPhone6Plus" }
        if (platform.isEqualToString("iPhone8,1")) { return "iPhone6S" }
        if (platform.isEqualToString("iPhone8,1")) { return "iPhone6SPlus" }
        if (platform.isEqualToString("iPod1,1"))   { return "iPodTouch1G" }
        if (platform.isEqualToString("iPod2,1"))   { return "iPodTouch2G" }
        if (platform.isEqualToString("iPod3,1"))   { return "iPodTouch3G" }
        if (platform.isEqualToString("iPod4,1"))   { return "iPodTouch4G" }
        if (platform.isEqualToString("iPod5,1"))   { return "iPodTouch5G" }
        if (platform.isEqualToString("iPod7,1"))   { return "iPodTouch6G" }
        if (platform.isEqualToString("iPad1,1"))   { return "iPad1" }
        if (platform.isEqualToString("iPad2,1"))   { return "iPad2(WiFi)" }
        if (platform.isEqualToString("iPad2,2"))   { return "iPad2(GSM)" }
        if (platform.isEqualToString("iPad2,3"))   { return "iPad2(CDMA)" }
        if (platform.isEqualToString("iPad2,4"))   { return "iPad2((WiFi Rev A))" }
        if (platform.isEqualToString("iPad3,1"))   { return "iPad3(WiFi)" }
        if (platform.isEqualToString("iPad3,2"))   { return "iPad3(GSM+CDMA)" }
        if (platform.isEqualToString("iPad3,3"))   { return "iPad3(GSM)" }
        if (platform.isEqualToString("iPad3,4"))   { return "iPad4(WiFi)" }
        if (platform.isEqualToString("iPad3,5"))   { return "iPad4(GSM+CDMA)" }
        if (platform.isEqualToString("iPad3,6"))   { return "iPad4(GSM)" }
        if (platform.isEqualToString("iPad4,1"))   { return "iPadAir(WiFi)" }
        if (platform.isEqualToString("iPad4,2") || platform.isEqualToString("iPad4,3"))   { return "iPadAir" }
        if (platform.isEqualToString("iPad5,3") || platform.isEqualToString("iPad5,4"))   { return "iPadAir2" }
        if (platform.isEqualToString("iPad6,7") || platform.isEqualToString("iPad6,8"))   { return "iPadPro" }
        if (platform.isEqualToString("iPad2,5"))   { return "iPad mini(WiFi)" }
        if (platform.isEqualToString("iPad2,6"))   { return "iPad mini(GSM)" }
        if (platform.isEqualToString("iPad2,7"))   { return "iPad mini(GSM+CDMA)" }
        if (platform.isEqualToString("iPad4,4") || platform.isEqualToString("iPad4,5") || platform.isEqualToString("iPad4,6"))   { return "iPad mini 2" }
        if (platform.isEqualToString("iPad4,7") || platform.isEqualToString("iPad4,8") || platform.isEqualToString("iPad4,9"))   { return "iPad mini 3" }
        if (platform.isEqualToString("iPad5,1") || platform.isEqualToString("iPad5,2"))   { return "iPad mini 4 " }
        if (platform.isEqualToString("i386"))      { return "Simulator" }
        if (platform.isEqualToString("x86_64"))    { return "Simulator" }
        
        
        return platform as String;
    }

    
}




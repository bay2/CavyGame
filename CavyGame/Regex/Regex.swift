//  正值表达式类
//  Regex.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/7.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation

/// 正值表达式类
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    /**
    校验是否与表达式匹配
    
    :param: input 匹配字符串
    
    :returns: 匹配 － true, 不匹配 - false
    */
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0,count(input)))
        return matches.count > 0
    }
}
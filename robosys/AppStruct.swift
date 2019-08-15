//
//  AppStruct.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

///全局变量
///备注：
struct const
{
    
    static let globalColor = UIColor(red: 169/255, green: 185/255, blue: 234/255, alpha: 1)
    static let telPatten = "^1+[3578]+\\d{9}"
    static let pswPatten = "^[\\x21-\\x7eA-Za-z0-9]{6,16}$"//"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,32}$"
    static let chinesePatten = "^[\\u4e00-\\u9fa5]{1,8}$"
    static let hostReach = Reachability(hostName: "www.baidu.com")
    static let speedPattern = "^\\+?[1-9][0-9]*$"
    static var mediaID = 0
}

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
enum Date
{
    case None
    case Day
    case Week
    case TwoWeek
    case Month
    case Year
}
enum Week
{
    case Sunday
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
}

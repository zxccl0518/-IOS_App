//
//  AppExtension.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork


extension UITextField
{
    ///初始化图片LeftView
    /**
     imgName:图片名
     */
    ///备注：
    func initImgLeftView(imgName:String)
    {
        let leftV = UIView(frame: CGRectMake(0,0,30,frame.size.height))
        
        let leftViewSub1 = UIImageView(frame: CGRectMake(5, 8, 15, frame.size.height - 16))
        leftViewSub1.image = UIImage(named: imgName)
        leftViewSub1.contentMode  = .ScaleAspectFit
        
        let leftViewSub2 = UIImageView(frame: CGRectMake(27, 8, 2, frame.size.height - 16))
        leftViewSub2.image = UIImage(named: "分割线")
        
        leftV.addSubview(leftViewSub1)
        leftV.addSubview(leftViewSub2)
        
        (valueForKey("placeholderLabel") as! UILabel).textColor = const.globalColor
        (valueForKey("placeholderLabel") as! UILabel).font = UIFont(name: "RTWS yueGothic Trial", size: 13)
        
        leftViewMode = .Always
        leftView = leftV
    }
    
    ///初始化文字LeftView
    /**
     labelText:Label名
     */
    ///备注：
    func initTxtLeftView(labelText:String)
    {
        let font = UIFont(name: "RTWS yueGothic Trial", size: 13)
        let leftV = UIView(frame: CGRectMake(0,0,80,frame.size.height))
        
        let leftViewSub1 = UILabel(frame: CGRectMake(12, 5, CGFloat(labelText.characters.count * 15), frame.size.height - 15))
        leftViewSub1.font = font
        leftViewSub1.textColor = .whiteColor()
        leftViewSub1.text = labelText
        
        let leftViewSub2 = UIImageView(frame: CGRectMake(77, 5, 2, frame.size.height - 10))
        leftViewSub2.image = UIImage(named: "分割线")
        
        leftV.addSubview(leftViewSub1)
        leftV.addSubview(leftViewSub2)
        
        (valueForKey("placeholderLabel") as! UILabel).textColor = const.globalColor
        (valueForKey("placeholderLabel") as! UILabel).font = font
        
        leftViewMode = .Always
        leftView = leftV
    }
}
extension UIView
{
    ///获取当前控制器
    ///备注：
    func getCurrentVC()->UIViewController
    {
        for (var next = superview;next != nil; next = next?.superview)
        {
            let nextRes:UIResponder = (next?.nextResponder())!
            if nextRes.isKindOfClass(UIViewController.classForCoder())
            {
                return nextRes as! UIViewController
            }
        }
        return UIViewController()
    }
    
    ///提示框
    /**
     code:执行代码
     title:标题
     message:详细内容
     */
    ///备注：
    func Alert(code:()->(),title:String,message:String)
    {
//        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title:title, message:message, preferredStyle: .Alert)
            getCurrentVC().presentViewController(alert, animated: true, completion: nil)
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.5 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
            {
                alert.dismissViewControllerAnimated(true, completion:
                    {
                        code()
                })
            }

//        }
//        else
//        {
//            // Fallback on earlier versions
//            let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "")
//            alert.show()
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
//            {
//               alert.dismissWithClickedButtonIndex(0, animated: false)
//                 code()
//            }
//        }
    }
    
    
    ///自定义UITextField
    /**
     TxtField:目标UITextField
     string:LeftView的文字
     type:LeftView的type
     */
    ///备注：
    func initTxtField(TxtField:UITextField,string:String,type:String)
    {
        switch type
        {
        case "text" : TxtField.initTxtLeftView(string)
        case "image" : TxtField.initImgLeftView(string)
            
        default:break
        }
        
        TxtField.layer.borderColor = UIColor(red: 30/255, green: 144/255, blue: 1, alpha: 1).CGColor//	30	144	255
        TxtField.layer.borderWidth = 1.0
        TxtField.layer.cornerRadius = 5.0
    }
    
    ///拿到WIFI的SSID
    ///备注：模拟器上无用
    func getSSID()->(success:Bool,ssid:String,bssid:String)
    {

        if let cfa:NSArray = CNCopySupportedInterfaces()
        {
            for x in cfa
            {
                if let dict = CFBridgingRetain(CNCopyCurrentNetworkInfo(x as! CFString))
                {
                    let ssid = dict["SSID"]!
                    let bssid = dict["BSSID"]!
                    return (true,ssid as! String,bssid as! String)
                }
            }
        }
        return (false,"","")
    }
}

extension UIViewController
{
    ///提示框
    /**
     code:执行代码
     title:标题
     message:详细内容
     */
    ///备注：
    func Alert(code:()->(),title:String,message:String)
    {
        
        let alert = UIAlertController(title:title, message:message, preferredStyle: .Alert)
            
            if let vc = UIApplication.sharedApplication().keyWindow!.rootViewController
            {
                vc.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.5 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
            {
                alert.dismissViewControllerAnimated(true, completion:
                    {
                        code()
                })
            }
    }
    
    ///自定义UITextField
    /**
     TxtField:目标UITextField
     string:LeftView的文字
     type:LeftView的type
     */
    ///备注：
    func initTxtField(TxtField:UITextField,string:String,type:String)
    {
        switch type
        {
        case "text" : TxtField.initTxtLeftView(string)
        case "image" : TxtField.initImgLeftView(string)
            
        default:break
        }
        
        TxtField.layer.borderColor = UIColor(red: 30/255, green: 144/255, blue: 1, alpha: 1).CGColor//	30	144	255
        TxtField.layer.borderWidth = 1.0
        TxtField.layer.cornerRadius = 5.0
    }  
}

extension String
{
    ///正则匹配
    /**
     patten:匹配规则
     */
    ///备注：
    func checkMatch(patten:String)->Bool
    {
        let pred = NSPredicate(format: "SELF MATCHES %@", patten)
        let isMatch = pred.evaluateWithObject(self)
        return isMatch
    }
    
    var md5 : String
    {
        let str = cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen);
        
        CC_MD5(str!, strLen, result);
        
        let hash = NSMutableString();
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i]);
        }
        result.destroy();
        
        return String(format: hash as String)
    }
}

extension UIScrollView
{
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nextResponder()?.touchesBegan(touches, withEvent: event)
        super.touchesBegan(touches, withEvent: event)
    }
}
extension NSDate
{
    /**
     /////  和当前时间比较
     ////   1）1分钟以内 显示        :    刚刚
     ////   2）1小时以内 显示        :    X分钟前
     ///    3）今天或者昨天 显示      :    今天 xx:xx   昨天 xx:xx
     ///    4) 今年显示             :   xx月xx日
     ///    5) 大于本年      显示    :    20xx/xx/xx
     **/
    class func formateDate(dateStr:String,formate:String)->String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formate
        var res = dateStr
        
        if let needFormatDate = dateFormatter.dateFromString(dateStr)
        {

        let nowDate = NSDate()
        
        //今年之后,显示年月日
        if Int((dateStr as NSString).substringToIndex(4)) > Int((dateFormatter.stringFromDate(nowDate) as NSString).substringToIndex(4))
        {
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            res = dateFormatter.stringFromDate(needFormatDate)
        }
        // 今年之内
        else 
        {
            dateFormatter.dateFormat = "MM月"
            //本月
            if  dateFormatter.stringFromDate(needFormatDate) == dateFormatter.stringFromDate(nowDate)
            {
                dateFormatter.dateFormat = "dd日"
                //本日
                if dateFormatter.stringFromDate(needFormatDate) == dateFormatter.stringFromDate(nowDate)
                {
                    dateFormatter.dateFormat = "HH时"
                    //本小时
                    if dateFormatter.stringFromDate(needFormatDate) == dateFormatter.stringFromDate(nowDate)
                    {
                        dateFormatter.dateFormat = "mm分"
                        
                        let count = Int((dateFormatter.stringFromDate(needFormatDate) as NSString).substringToIndex(2))! - Int((dateFormatter.stringFromDate(nowDate)as NSString).substringToIndex(2))!
                        
                        res = "\(abs(count))分钟" + (count < 0 ? "前" : "后")
                    }
                    //显示相差小时
                    else
                    {
                        let count = Int((dateFormatter.stringFromDate(needFormatDate) as NSString).substringToIndex(2))! - Int((dateFormatter.stringFromDate(nowDate)as NSString).substringToIndex(2))!
                        
                        if abs(count) == 1
                        {
                            dateFormatter.dateFormat = "mm分"
                            let time = Int((dateFormatter.stringFromDate(needFormatDate) as NSString).substringToIndex(2))! + 60 - Int((dateFormatter.stringFromDate(nowDate)as NSString).substringToIndex(2))!
                            if time <= 59
                            {
                                res = "\(abs(time))分钟" + (count < 0 ? "前" : "后")
                                return res
                            }
                        }
                        
                        res = "\(abs(count))小时" + (count < 0 ? "前" : "后")
                    }
                }
                //显示相差日期
                else
                {
                    let count = Int((dateFormatter.stringFromDate(needFormatDate) as NSString).substringToIndex(2))! - Int((dateFormatter.stringFromDate(nowDate)as NSString).substringToIndex(2))!
                    
                    res = abs(count) == 1 ? "\(count < 0 ? "昨" : "明")天":"\(abs(count))天\(count < 0 ? "前":"后")"
                }
            }
            //显示相差月份
            else
            {
                let count = Int((dateFormatter.stringFromDate(needFormatDate) as NSString).substringToIndex(2))! - Int((dateFormatter.stringFromDate(nowDate)as NSString).substringToIndex(2))!
                
                if count < 0
                {
                    print(res)
                    return (res as NSString).substringToIndex(11)
                }
                else
                {
                    res = "\(count)个月后"
                }
            }
        }
    }
    return res
    }
}

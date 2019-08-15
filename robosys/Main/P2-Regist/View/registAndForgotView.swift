//
//  registAndForgotView.swift
//  robosys
//
//  Created by Cheer on 16/5/24.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class registAndForgotView: AppView
{
    private var recordBtn:UIButton!
    
    internal var phoneNum:String!
    
    lazy var isClickCaptcha = false
    lazy var timer = NSTimer()
    
    private lazy var time = 60
    
    private lazy var dateStr:String =
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        if let old = NSUserDefaults.standardUserDefaults().valueForKey("date")
        {
            //之前
            if  old as! String != dateFormatter.stringFromDate(NSDate())
            {
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: old as! String)
            }
        }
        
        //保存现在
        NSUserDefaults.standardUserDefaults().setValue(dateFormatter.stringFromDate(NSDate()), forKey: "date")
        
        return dateFormatter.stringFromDate(NSDate())
    }()
    
    private lazy var captchaView:AppCaptchaView =
    {
        let view = UINib(nibName: "AppCaptchaView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppCaptchaView
        return view
    }()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    func getCap(captchaBtn:UIButton)
    {
        recordBtn = captchaBtn
        tempTextField.resignFirstResponder()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(registAndForgotView.changeSecurity), userInfo: nil, repeats: true)
        
        var count = NSUserDefaults.standardUserDefaults().integerForKey(dateStr + "-" + phoneNum)

        if count != 0
        {
            if count > 3
            {
                captchaView.frame = CGRectMake(0, 0, 300, 240)
                let alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: captchaView,currentView:self,autoHidden: false)
                alert.isNeedTouch = true
            }
            
            if count > 10
            {
                Alert({
                    [unowned self] in
                    
                    self.captchaView.removeFromSuperview()
                    self.timer.invalidate()
                    self.recordBtn.setTitle("获取验证码", forState: UIControlState.Normal)

                    }, title: "抱歉，您今日获取验证码的请求次数已超过10次，今日无法再获取验证码", message: "")
                return
            }
            count += 1
            NSUserDefaults.standardUserDefaults().setInteger(count, forKey: dateStr + "-" + phoneNum)
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: dateStr + "-" + phoneNum)
        }
    }
    
    func changeSecurity()
    {
        time -= 1
        
        recordBtn.enabled = false
        recordBtn.setAttributedTitle(NSAttributedString(string:"已发送\(time)秒",attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 12)!]), forState: .Normal)
        if time < 1
        {
            timer.invalidate()
            recordBtn.enabled = true
            recordBtn.setAttributedTitle(NSAttributedString(string:"获取验证码",attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 12)!]), forState: .Normal)
            time = 60
            return
        }
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
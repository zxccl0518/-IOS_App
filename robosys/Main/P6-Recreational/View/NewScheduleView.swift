//
//  NewScheduleView.swift
//  robosys
//
//  Created by Cheer on 16/7/15.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class NewScheduleView: AppView
{
    //添加新事项
    @IBOutlet weak var inputName: UITextView!
    //重复
    @IBOutlet weak var repeatView: UIView!
    //提醒
    @IBOutlet weak var remindView: UIView!
    //开始时间
    @IBOutlet weak var timeView: UIView!
    
    //开始label
    @IBOutlet weak var timeLabel: UILabel!
    //提醒label
    @IBOutlet weak var remindLabel: UILabel!
    //重复label
    @IBOutlet weak var repeatLabel: UILabel!
    
    //
    internal var modelArr:[scheduleModel]!
    
    //提醒的总的model
    internal var scheduleM:scheduleModel!
    internal var index:Int!
    
    private var btnArr:[UIButton]!
    private var datepicker:APPDatePicker1!
    //提醒
    internal var remindCount:Int32!
    //重复
    internal var repeatCount:Int32!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("新建", imageName: "返回")
        
        //加边框
        addBorder(inputName)
        addBorder(remindView)
        addBorder(repeatView)
        addBorder(timeView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewScheduleView.dropWords(_:)), name: UITextViewTextDidChangeNotification, object: inputName)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewScheduleView.cleanWords(_:)), name: UITextViewTextDidBeginEditingNotification, object: inputName)
        
    }
    
    func cleanWords(sender:NSNotification)
    {
        let textView = sender.object as! UITextView
        if textView.text == "添加新事项"
        {
            textView.text = ""
        }
    }
    
    func dropWords(sender:NSNotification)
    {
        let textView = sender.object as! UITextView
        if textView.text?.characters.count > 50
        {
            textView.text = (textView.text! as NSString).substringToIndex(50)
        }
    }
    
    @IBAction func clickTime(sender: UIButton)
    {
        inputName.resignFirstResponder()
        
        datepicker =  UINib(nibName: "APPDatePicker1", bundle: nil).instantiateWithOwner(nil, options: nil).first as! APPDatePicker1
        datepicker.frame.size.width = 280
        datepicker.lastView = self
        datepicker.code =
        {
            [weak self] in
            
            self!.datepicker.yearString = self!.handleNullDate(self!.datepicker.yearString, formatString: "yyyy")
            self!.datepicker.monthString = self!.handleNullDate(self!.datepicker.monthString, formatString: "MM")
            self!.datepicker.dayString = self!.handleNullDate(self!.datepicker.dayString, formatString: "dd")
            self!.datepicker.hourString = self!.handleNullDate(self!.datepicker.hourString, formatString: "HH")
            self!.datepicker.minuteString = self!.handleNullDate(self!.datepicker.minuteString, formatString: "mm")
            
            let text = self!.datepicker.yearString + "年" + self!.datepicker.monthString + "月" + self!.datepicker.dayString + "日" + self!.datepicker.hourString + "时" + self!.datepicker.minuteString + "分"
            
            let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyyMMdd"
            if "\(self!.datepicker.yearString + self!.datepicker.monthString + self!.datepicker.dayString)" < fmt.stringFromDate(NSDate())
            {
                self!.Alert({}, title: "请选择有效时间", message: "")
                return
            }
            
            self!.timeLabel.text = NSDate.formateDate(text, formate: "yyyy年MM月dd日HH时mm分")
        }
        
        _ = AppAlert(frame: UIScreen.mainScreen().bounds, view: datepicker, currentView: self, autoHidden: false)
    }
    
    func handleNullDate(dateString:String,formatString:String)->String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formatString
        
        if dateString == ""
        {
            return  dateFormatter.stringFromDate(NSDate())
        }
        else
        {
            return dateString
        }
    }
    
    @IBAction func clickRemind(sender: UIButton)
    {
        clickLabelButton(remindLabel)
    }
    
    @IBAction func clickRepeat(sender: UIButton)
    {
        clickLabelButton(repeatLabel)
    }
    
    func clickLabelButton(sender: UILabel)
    {
        let vc = RemindDetailsViewController(nibName: "RemindDetailsView",bundle: nil)
        
//        (vc.view as! RemindDetailsView).textArr.first = true
        
        (vc.view as! RemindDetailsView).text = sender.text!
        
        (vc.view as! RemindDetailsView).headView.titleLabel.text =  sender == repeatLabel ? "重复":"提醒"
        
        (vc.view as! RemindDetailsView).isRepeat =  sender == repeatLabel
        
        (vc.view as! RemindDetailsView).code =
        {
            [weak self] in
            
            var text = ""
            
            for str in (vc.view as! RemindDetailsView).textArr
            {
                 print("str ====== \(str)")
                
                if str.characters.count > 0
                {
                    text += str + " "
                }
            }
            sender.text = text
            
            //大的新建模型
            if self!.scheduleM != nil
            {
                sender == self!.remindLabel ?  (self!.scheduleM.remind = text) : (self!.scheduleM.repeats = text)
            }
            
            (vc.view as! RemindDetailsView).isRepeat ? self!.repeatCount = (vc.view as! RemindDetailsView).clickRow.last : (self!.remindCount = (vc.view as! RemindDetailsView).clickRow.last)
        }
 
        jump2AnyController(vc)
    }
    
    @IBAction func finish(sender: UIButton)
    {
        guard inputName.text != "" else
        {
            Alert({}, title: "请设置提醒内容", message: "")
            return
        }
        if datepicker == nil && remindCount == nil
        {
            Alert({}, title: "请设置开始时间", message: "")
            return
        }
        guard remindCount != nil else
        {
            Alert({}, title: "请设置提醒时间", message: "")
            return
        }
        guard repeatCount != nil else
        {
            Alert({}, title: "请设置重复时间", message: "")
            return
        }
        
        let nav = (getCurrentVC() as! UINavigationController)
        
        if scheduleM == nil
        {
            scheduleM = scheduleModel.createInstance()
        }
        
        var timeString = ""
        
        if datepicker != nil
        {
            timeString = datepicker.yearString + datepicker.monthString + datepicker.dayString + datepicker.hourString + datepicker.minuteString
            
            scheduleM.date = "\(datepicker.hourString):\(datepicker.minuteString)" + "  \(datepicker.yearString).\(datepicker.monthString).\(datepicker.dayString)"
        }
        
        if timeString == ""
        {
            let tempArr = scheduleM.date.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " :."))
            timeString = tempArr[2] + tempArr[3] +  tempArr[4] +  tempArr[0] +  tempArr[1]
        }

        
        (scheduleM.time,scheduleM.repeats,scheduleM.name,scheduleM.remind) = (timeLabel.text,repeatLabel.text,inputName.text,remindLabel.text)
        
        if index != nil
        {
            //告诉机器人更新闹铃
            print("\(remindCount)-\(repeatCount)")
            dispatch_async(dispatch_get_global_queue(0, 0), {
                
                self.control.didUpdateAlarm(self.inputName.text, timeString: timeString, remind: self.remindCount , repeat: self.repeatCount, index:  Int32(self.scheduleM.ID)!)
            })
        }
        else
        {
            print("\(remindCount)-\(repeatCount)")
            dispatch_async(dispatch_get_global_queue(0, 0), { 
                self.control.didSetAlarm(self.inputName.text, timeString: timeString, remind:self.remindCount , repeat: self.repeatCount)
            })
        }
        
        nav.popViewControllerAnimated(true)
    }
    
    @IBAction func cancel(sender: UIButton)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        (getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        inputName.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    @IBAction func input(sender: UITextField)
    {
        if sender.text?.characters.count > 12
        {
            sender.text = (sender.text! as NSString).substringToIndex(12)
        }
    }

}

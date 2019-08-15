//
//  APPDatePicker.swift
//  robosys
//
//  Created by Cheer on 16/6/29.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class APPDatePicker: UIView,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    
    internal lazy var lastView = UIView()
    
    internal lazy var year = UITableView()
    internal lazy var month = UITableView()
    internal lazy var day = UITableView()
    internal lazy var hour = UITableView()
    internal lazy var minute = UITableView()
    
    internal lazy var content = UIView()
    internal var code = {}

    internal var (yearStr,monthStr,dayStr) = ("1990","01","01")
    
    internal lazy var months = [1,2,3,4,5,6,7,8,9,10,11,12,
                               1,2,3,4,5,6,7,8,9,10,11,12,
                               1,2,3,4,5,6,7,8,9,10,11,12]
    
    internal lazy var days = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,
                             1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,
                             1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    
    internal lazy var hours = [
                                0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,
                                0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,
                                0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    
    internal lazy var minutes = [
                                0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
                                31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
                                
                                0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
                                31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
                                
                                0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
                                31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59]
    
    
    private lazy var currentYear:Int =
        {
            let dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "yyyy";
            
            let currentYear = Int(dateFormatter.stringFromDate(NSDate()))!
            return currentYear
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = yearStr + "年" + monthStr + "月" + dayStr + "日"

        addSubview(content)
    }
    
    @IBAction func clickEnsure(sender: UIButton)
    {
        
        if self.superview != nil {
            
            self.superview?.removeFromSuperview()
        }
        
        
        var dateString : String?
        
        if lastView.classForCoder == PersonalInformationView.classForCoder()
        {
            dateString = yearStr + "-" + monthStr + "-" + dayStr
            
            (lastView as! PersonalInformationView).pickerBtn.setTitle(dateString, forState:.Normal)
            
            registModel.sharedInstance.birthday = dateString
            
            dispatch_async(dispatch_get_global_queue(0, 0), {
                
                RobotConnect.shareInstance().didSetUserInfo(loginModel.sharedInstance.num, token: loginModel.sharedInstance.token, birthday: registModel.sharedInstance.birthday)
            })
          
        }
        else if lastView.classForCoder == SettingView.classForCoder()
        {
            dateString = yearStr + "-" + monthStr + "-" + dayStr

            (lastView as! SettingView).pickerBtn.setTitle(dateString, forState:.Normal)
        }
        
        
    }
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        content.frame = CGRectMake(8, (frame.height - 160 + 10) * 0.5, frame.width - 2 * 8, 160)
        
        setUpTable(year,frame:CGRectMake(0, 0, content.frame.width / 3, content.frame.height))
        setUpTable(month,frame:CGRectMake(content.frame.width / 3, 0, content.frame.width / 3, content.frame.height))
        setUpTable(day,frame:CGRectMake(content.frame.width * 2 / 3, 0, content.frame.width / 3, content.frame.height))
    }
    
    func setUpTable(tableView:UITableView,frame:CGRect)
    {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = frame
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .None
        tableView.backgroundColor = .clearColor()
        content.addSubview(tableView)
        
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        if tableView == year
        {
            tableView.contentOffset.y  = (tableView.frame.height / 3) * 49
        }
        else if tableView == month
        {
            tableView.contentOffset.y  = (tableView.frame.height / 3) * (CGFloat(months.count) / 3 - 1)
        }
        else if tableView == day
        {
            tableView.contentOffset.y  = (tableView.frame.height / 3) * (CGFloat(days.count) / 3 - 1)
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
        case year:
            return 100
        case month:
            return months.count
        case day:
            return days.count
        case hour:
            return hours.count
        case minute:
            return minutes.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return year.frame.height / 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        for v in cell.subviews
        {
            if v.classForCoder  == UILabel.classForCoder()
            {
                v.removeFromSuperview()
            }
        }
        let label = UILabel(frame: CGRectMake(0,0,tableView.frame.width,tableView.frame.height / 3))
        
        
        
        if tableView == year
        {
            let temp = 40 + indexPath.row
            label.attributedText = NSAttributedString(string:"\(19 + temp / 100)" + String(format: "%02d", temp % 100) ,attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
        }
        else if tableView == month
        {
            label.attributedText = NSAttributedString(string:String(format: "%02d", months[indexPath.row]),attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
        }
        else if tableView == day
        {
            label.attributedText = NSAttributedString(string: String(format: "%02d", days[indexPath.row]), attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
        }
        
        label.textAlignment = .Center
        cell.backgroundColor = .clearColor()
        cell.selectionStyle = .None
        cell.addSubview(label)
        
        return cell
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        animation(scrollView)
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        animation(scrollView)
    }
    
    func animation(scrollView:UIScrollView)
    {
        if scrollView == year && (scrollView.contentOffset.y <= 0 || scrollView.contentOffset.y >= (year.frame.height / 3) * CGFloat(100 - 3))
        {
            return
        }
        
        let offsetY =  scrollView.contentOffset.y % (scrollView.frame.height / 3)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.Linear)
        
        scrollView.contentOffset.y += scrollView.frame.height / 3 - offsetY
        
        UIView.commitAnimations()
        
        if scrollView == year
        {
            yearStr = "\(Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 3) + 1941)"
        }
        else if scrollView == month
        {
            changeDays(month, row:Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 3) + 1)
            
            monthStr = String(format: "%02d",months[Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 3)] + 1)
        }
        else if scrollView == day
        {
            dayStr = String(format: "%02d",days[Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 3)] + 1)
        }
        titleLabel.text = yearStr + "年" + monthStr + "月" + dayStr + "日"
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let temp = scrollView.contentOffset.y
        
        if scrollView == month
        {
            if temp < 0 || temp > (month.frame.height / 3) * CGFloat(months.count - 3)
            {
                month.contentOffset.y  = (month.frame.height / 3) * (CGFloat(months.count) / 3 - 1)
            }
        }
        else if scrollView == day
        {
            if temp < 0 || temp > (day.frame.height / 3) * CGFloat(days.count - 3)
            {
                day.contentOffset.y  = (day.frame.height / 3) * (CGFloat(days.count) / 3 - 1)
            }
        }

    }
    func changeDays(tableView:UITableView,row: Int)
    {
        if tableView == month
        {
            switch row
            {
            case 1,3,5,8,10,
                 13,15,17,20,22,
                 25,27,29,32,34:
                
                if days.count == 93
                {
                    days.removeAtIndex(30)
                    days.removeAtIndex(60)
                    days.removeAtIndex(90)
                    day.reloadData()
                    day.contentOffset.y -= tableView.frame.height / 3
                }
                
            default:
                if days.count == 90
                {
                    days.insert(31, atIndex: 30)
                    days.insert(31, atIndex: 61)
                    days.append(31)
                    day.reloadData()
                    day.contentOffset.y += tableView.frame.height / 3
                }
                
            }
            
        }
        
    }
}

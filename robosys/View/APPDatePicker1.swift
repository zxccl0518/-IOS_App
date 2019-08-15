//
//  APPDatePicker1.swift
//  robosys
//
//  Created by Cheer on 16/7/20.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class APPDatePicker1: APPDatePicker
{
    @IBOutlet weak var ensureBtn: UIButton!
    
    override func awakeFromNib()
    {
        addSubview(content)
    }
    
    internal var (yearString,monthString,dayString,hourString,minuteString) = ("","","","","")
    
    override func layoutSubviews()
    {
        content.frame = CGRectMake(0, (frame.height - 170) * 0.5, frame.width, 160)
        
        setUpTable(year,  frame:CGRectMake(0,                           0, content.frame.width / 5, content.frame.height))
        setUpTable(month, frame:CGRectMake(content.frame.width / 5,     0, content.frame.width / 5, content.frame.height))
        setUpTable(day,   frame:CGRectMake(content.frame.width * 2 / 5, 0, content.frame.width / 5, content.frame.height))
        setUpTable(hour,  frame:CGRectMake(content.frame.width * 3 / 5, 0, content.frame.width / 5, content.frame.height))
        setUpTable(minute,frame:CGRectMake(content.frame.width * 4 / 5, 0, content.frame.width / 5, content.frame.height))
    }
    
    @IBAction override func clickEnsure(sender: UIButton)
    {
       
        if self.superview != nil {
            
            self.superview?.removeFromSuperview()
        }
        
        code()
    }
    override func setUpTable(tableView:UITableView,frame:CGRect)
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
        
        let formatter = NSDateFormatter()

        
        if tableView == year
        {
            tableView.contentOffset.y  = 117 * (tableView.frame.height / 5)
        }
        else if tableView == month
        {
            formatter.dateFormat = "MM"
            
            tableView.contentOffset.y  = (tableView.frame.height / 5) * CGFloat(Int(formatter.stringFromDate(NSDate()))! - 3)
        }
        else if tableView == day
        {
            formatter.dateFormat = "dd"
            
            tableView.contentOffset.y  = (tableView.frame.height / 5) * CGFloat(Int(formatter.stringFromDate(NSDate()))! - 3)
        }
        else if tableView == hour
        {
            formatter.dateFormat = "HH"
            tableView.contentOffset.y  = (tableView.frame.height / 5) * CGFloat(Int(formatter.stringFromDate(NSDate()))! - 2)
        }
        else if tableView == minute
        {
            formatter.dateFormat = "mm"
            tableView.contentOffset.y  = (tableView.frame.height / 5) * CGFloat(Int(formatter.stringFromDate(NSDate()))! - 2)
        }
    }
}



extension APPDatePicker1
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
        case year:
            return 205
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return year.frame.height / 5
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        for v in cell.subviews
        {
            if v.classForCoder  == UILabel.classForCoder()
            {
                v.removeFromSuperview()
            }
        }
        let label = UILabel(frame: CGRectMake(0,0,tableView.frame.width,tableView.frame.height / 5))
        
        
        
        if tableView == year
        {
            var string = ""

            if indexPath.row > 1 && indexPath.row < 203
            {
                string = "\(19 + (indexPath.row - 2) / 100)" + String(format: "%02d", (indexPath.row - 2) % 100)
            }
            
            label.attributedText = NSAttributedString(string: string ,attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
        }
        else if tableView == month
        {
            label.attributedText = NSAttributedString(string:String(format: "%02d", months[indexPath.row]),attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
        }
        else if tableView == day
        {
            label.attributedText = NSAttributedString(string: String(format: "%02d", days[indexPath.row]), attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
        }
        else if tableView == hour
        {
            label.attributedText = NSAttributedString(string: String(format: "%02d", hours[indexPath.row]), attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
        }
        else if tableView == minute
        {
            label.attributedText = NSAttributedString(string: String(format: "%02d", minutes[indexPath.row]), attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            
        }
        
        label.textAlignment = .Center
        cell.backgroundColor = .clearColor()
        cell.selectionStyle = .None
        cell.addSubview(label)
        
        return cell
        
    }
    override func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let temp = scrollView.contentOffset.y

        if scrollView == month
        {
            if  temp > (month.frame.height / 5) * CGFloat(months.count - 5) || temp < 0
            {
                month.contentOffset.y  = (month.frame.height / 5) * (CGFloat(months.count) / 3)
            }
        }
        else if scrollView == day
        {
            if temp < 0 || temp > (day.frame.height / 5) * CGFloat(days.count - 5)
            {
                day.contentOffset.y  = (day.frame.height / 5) * (CGFloat(days.count) / 3)
            }
        }
        else if scrollView == hour
        {
            if temp < 0 || temp > (hour.frame.height / 5) * CGFloat(hours.count - 5)
            {
                hour.contentOffset.y  = (hour.frame.height / 5) * (CGFloat(hours.count) / 3)
            }
        }
        else if scrollView == minute
        {
            if temp < 0 || temp > (minute.frame.height / 5) * CGFloat(minutes.count - 5)
            {
                minute.contentOffset.y  = (minute.frame.height / 5) * (CGFloat(minutes.count) / 3)
            }
        }
    }
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        ensureBtn.enabled = false
//    }
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        animation(scrollView)
//        
//        if decelerate
//        {
//            ensureBtn.enabled = true
//        }
    }
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        animation(scrollView)
    }
    
    override func animation(scrollView:UIScrollView)
    {
        if scrollView == year && (scrollView.contentOffset.y <= 0 || scrollView.contentOffset.y >= (year.frame.height / 5) * CGFloat(205 - 3))
        {
            return
        }
        
        let offsetY =  scrollView.contentOffset.y % (scrollView.frame.height / 5)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.Linear)
        
        scrollView.contentOffset.y += scrollView.frame.height / 5 - offsetY
        
        UIView.commitAnimations()
        
        if scrollView == year
        {
            changeDays(year, row:Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 5) + 1)
        }
        else if scrollView == month
        {
            changeDays(month, row:Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 5) + 1)
            
            let count = (months[Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 5)] + 2)
            
            monthString = String(format: "%02d", count > 12 ? (count % 12 == 0 ? 12 : count % 12) : count)
        }
        else if scrollView == day
        {
            let count = days[Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 5)] + 2
            
            dayString = String(format: "%02d",count > 31 ? (count % 31 == 0 ? 31 : count % 31) : count)
        }
        else if scrollView == hour
        {
            let count = hours[Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 5)] + 2
            hourString = String(format: "%02d",count >= 24 ? count % 24 : count)
        }
        else if scrollView == minute
        {
            let count = minutes[Int(scrollView.contentOffset.y) / Int(scrollView.frame.height / 5)] + 2
            minuteString = String(format: "%02d",count >= 60 ? count % 60 : count)
        }
        yearString = "\(Int(year.contentOffset.y) / Int(year.frame.height / 5) + 1900)"
    }
    override func changeDays(tableView:UITableView,row: Int)
    {
        if tableView == year
        {
            switch (Int(month.contentOffset.y) / Int(month.frame.height / 5))
            {
            case 1,11,23:
                if (Int(year.contentOffset.y) / Int(year.frame.height / 5)) % 4 != 0 && days.count == 87
                {
                    days.removeAtIndex(86)
                    days.removeAtIndex(57)
                    days.removeAtIndex(28)
                }
                else if (Int(year.contentOffset.y) / Int(year.frame.height / 5)) % 4 == 0 && days.count == 84
                {
                    days.insert(29, atIndex: 28)
                    days.insert(29, atIndex: 57)
                    days.append(29)
                }
                
                day.reloadData()
                day.contentOffset.y = tableView.frame.height / 5 * CGFloat(days.count / 3 - 3)
                
            default:
                break
            }
        }
        
        if tableView == month
        {
            switch row
            {
            case 2,4,7,9,
                 14,16,19,21,
                 26,28,31,33:
                
                if days.count == 93
                {
                    days.removeAtIndex(30)
                    days.removeAtIndex(60)
                    days.removeAtIndex(90)
                }
                
            case 0,12,24:
                if days.count == 93
                {
                    if (Int(year.contentOffset.y) / Int(year.frame.height / 5)) % 4 != 0
                    {
                        days.removeAtIndex(92)
                        days.removeAtIndex(91)
                        days.removeAtIndex(90)
                        days.removeAtIndex(61)
                        days.removeAtIndex(60)
                        days.removeAtIndex(59)
                        days.removeAtIndex(30)
                        days.removeAtIndex(29)
                        days.removeAtIndex(28)
                    }
                    else
                    {
                    days.removeAtIndex(92)
                    days.removeAtIndex(91)
                    days.removeAtIndex(61)
                    days.removeAtIndex(60)
                    days.removeAtIndex(30)
                    days.removeAtIndex(29)
                    }
                }
                
            default:
                if days.count == 90
                {
                    days.insert(31, atIndex: 30)
                    days.insert(31, atIndex: 61)
                    days.append(31)
                }
                else if days.count == 87
                {
                    days.insert(30, atIndex: 29)
                    days.insert(31, atIndex: 30)
                    days.insert(30, atIndex: 60)
                    days.insert(31, atIndex: 61)
                    days.insert(30, atIndex: 91)
                    days.append(31)
                }
                else if days.count == 84
                {
                    days.insert(29, atIndex: 28)
                    days.insert(30, atIndex: 29)
                    days.insert(31, atIndex: 30)
                    days.insert(29, atIndex: 59)
                    days.insert(30, atIndex: 60)
                    days.insert(31, atIndex: 61)
                    days.insert(29, atIndex: 90)
                    days.insert(30, atIndex: 91)
                    days.append(31)
                }
            }
            day.reloadData()
            day.contentOffset.y = tableView.frame.height / 5 * CGFloat(days.count / 3 - 3)
        }
        
    }

}

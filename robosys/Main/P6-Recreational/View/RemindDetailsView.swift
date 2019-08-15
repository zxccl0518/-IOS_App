//
//  RemindDetailsView.swift
//  robosys
//
//  Created by Cheer on 16/7/21.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class RemindDetailsView: AppView,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var table: UITableView!
    
    private lazy var repeatData = ["不重复","每天","每周","每两周","每月","每年"]
    private lazy var remindData = ["正点提醒","5分钟前","10分钟前","15分钟前","30分钟前","1小时前","2小时前","1天前","2天前","1周前",]
    private lazy var isClick = false
    internal lazy var index = [-1]
    
    internal var headView:MainHeadView!
    
    internal var text = ""
    
     internal var lastIndex = -1
    
    //点击后执行的闭包
    internal var code:(()->())!
    
    internal var textArr = [String]()
    
    internal var clickRow = [Int32]()
    
    internal var isRepeat = false
    {
        didSet
        {
            
            for i in 0..<(isRepeat ? repeatData.count : remindData.count)
            {
                textArr.append("")
                
                if isRepeat
                {
                    if text.hasPrefix(repeatData[i])
                    {
                        index = [i]
                        lastIndex = i
                        clickRow = [Int32(i)]
                        textArr = [repeatData[i]]
                    }
                }
                else
                {
                    
                    if text.hasPrefix(remindData[i])
                    {
                        index = [i]
                        lastIndex = i
                        clickRow = [Int32(i)]
                        textArr = [remindData[i]]
                    }
                }
            }
        }
    }
  
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        headView = initMainHeadView(isRepeat ? "重复" : "提醒", imageName: "返回")
    }
    
    @IBAction func clickSave(sender: UIButton)
    {
        code()
 
        (getCurrentVC() as! UINavigationController).popViewControllerAnimated(true)
    }
}

extension RemindDetailsView
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return isRepeat ? repeatData.count : remindData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UINib(nibName: "RemindDetailsCell", bundle: nil).instantiateWithOwner(nil, options: nil).first as! RemindDetailsCell
        
        cell.label.text = isRepeat ? repeatData[indexPath.row] : remindData[indexPath.row]
        
        for i in 0..<index.count
        {
            
            if indexPath.row == index[i] || indexPath.row == 0
            {
                isClick = true
                lastIndex = 0
                clickRow = [Int32(indexPath.row)]
                textArr = [cell.label.text!]
                cell.imgView.highlighted = true
            }
        }
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
//        if isRepeat
//        {
            if lastIndex != -1
            {
                let cell = table.cellForRowAtIndexPath(NSIndexPath(forRow: lastIndex, inSection: 0)) as! RemindDetailsCell
//                textArr = [cell.label.text!]
                cell.imgView.highlighted = !cell.imgView.highlighted
            }
  
            //不是第 -1 个
            let cell = table.cellForRowAtIndexPath(indexPath) as! RemindDetailsCell
            if indexPath.row == lastIndex && cell.imageView?.highlighted == true
            {
                //如果是高亮状态 不做操作
                return
            }
            cell.imgView.highlighted = !cell.imgView.highlighted
        
        
            clickRow = [Int32(indexPath.row)]
            textArr = [cell.label.text!]
            
            lastIndex = indexPath.row
        
        isClick = true
    }
}

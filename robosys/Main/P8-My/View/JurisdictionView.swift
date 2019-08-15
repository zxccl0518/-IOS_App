//
//  JurisdictionView.swift
//  robosys
//
//  Created by Cheer on 16/5/30.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class JurisdictionView: UIView,UIAlertViewDelegate
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    @IBAction func removeJurisdiction(sender: UIButton)
    {
       
            let alert = UIAlertController(title: "是否解除管理员权限", message: "", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Destructive) { (_) in
                
            }
            let action1 = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(action1)
            getCurrentVC().navigationController?.presentViewController(alert, animated: false, completion: nil)
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 0
        {
            
        }
        else
        {
            
        }
    }
    @IBAction func setJurisdiction(sender: UIButton)
    {
        Alert({}, title: "功能暂未开放", message: "")
    }
    @IBAction func moveJurisdiction(sender: UIButton)
    {
         Alert({}, title: "功能暂未开放", message: "")
    }
}

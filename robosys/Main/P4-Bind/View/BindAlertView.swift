//
//  BindAlertView.swift
//  robosys
//
//  Created by Cheer on 16/6/23.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class BindAlertView: AppView
{
    
    @IBOutlet weak var ensureBtn: UIButton!
    @IBOutlet weak var txtField: UITextField!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    
    @IBAction func textChange(sender: UITextField)
    {
       ensureBtn.enabled = txtField.text == "" ? false : true
    }
    
    
    @IBAction func clickEnsure(sender: UIButton)
    {
        if txtField.text!.checkMatch(const.chinesePatten)
        {
            jump2AnyController(MainViewController())
        }
        else
        {
            Alert({}, title: "请输入全中文，8个汉字以内", message: "")
        }
    }

}

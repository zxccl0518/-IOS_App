//
//  MySettingView.swift
//  robosys
//
//  Created by Cheer on 16/7/7.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit


class MySettingView: AppView
{
    @IBOutlet weak var newInformationView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var protocalView: UIView!
    @IBOutlet weak var aboutView: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        initMainHeadView("系统设置", imageName: "返回")
        
        addBorder(newInformationView)
        addBorder(feedbackView)
        addBorder(helpView)
        addBorder(protocalView)
        addBorder(aboutView)
    }
    @IBAction func clearBtn(sender: UIButton)
    {
        let cache = NSURLCache.sharedURLCache()
        cache.removeAllCachedResponses()
        cache.diskCapacity = 0
        cache.memoryCapacity = 0
        Alert({}, title: "清除完毕", message: "")
    }
    
    
    
    @IBAction func logout(sender: UIButton)
    {
        connect.didLogout(loginM.num, token: loginM.token)
        loginM.isAutoLogin = false
        (getCurrentVC() as! UINavigationController).popToRootViewControllerAnimated(true)
    }

    @IBAction func jump2Feedback(sender: UIButton)
    {
        jump2AnyController(FeedBackViewController(nibName: "FeedBackView", bundle: nil))
    }
    
    @IBAction func jump2Help(sender: UIButton)
    {
        jump2AnyController(HelpViewController(nibName: "HelpView", bundle: nil))
    }
    @IBAction func jump2Prorocol(sender: UIButton)
    {
        jump2AnyController(ProtocolViewController())
    }
    @IBAction func jump2About(sender: UIButton)
    {
        jump2AnyController(AboutViewController(nibName: "About", bundle: nil))
    }
  
}

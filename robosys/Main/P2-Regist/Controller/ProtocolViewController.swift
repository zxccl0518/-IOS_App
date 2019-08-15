//
//  ProtocolViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ProtocolViewController: AppViewController,UIWebViewDelegate
{
    
    lazy var textView: UITextView = {
        
       let textView = UITextView()
        textView.frame = CGRect(x: 0, y: 150, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height - 150)
        textView.textColor = UIColor.whiteColor()
        textView.editable = false
        textView.backgroundColor = UIColor.clearColor()
        return textView
    }()
    
    
    //-MARK:生命周期
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let bgImgView = UIImageView(frame: UIScreen.mainScreen().bounds)
        bgImgView.image = UIImage(named: "首页-背景")
        view.addSubview(bgImgView)
        
        initHeadView("协议",imageName: "返回")
        setupUI()
        view.addSubview(textView)

    }
    
    func setupUI() {
        let urlStr = "http://www.robo-sys.com/release/mrbox/roboapp/notice.txt"
        let url = NSURL(string:urlStr)
        let htmlStr = try! String(contentsOfURL: url!, encoding: NSUTF8StringEncoding)
        self.textView.text = htmlStr
    }

    //-MARK:初始化
    func initHeadView(text:String,imageName:String)
    {

        let  headView = AppHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,140))
        view.addSubview(headView)
        
        headView.titleLabel.text = text
        
        guard imageName != "" else
        {
            headView.leftBtn.hidden = true
            
            return
        }
        headView.leftBtn.setImage(UIImage(named: imageName), forState: .Normal)
    }

    deinit
    {
        print("\(classForCoder)--hello there")
    }
}

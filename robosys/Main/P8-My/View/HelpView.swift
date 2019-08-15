//
//  HelpView.swift
//  robosys
//
//  Created by Cheer on 16/7/15.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import SnapKit
class HelpView: AppView,UIWebViewDelegate
{
  
    //导航栏
    private lazy var navBar : UIView = {
       
        let v = UIView()
        v.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        
        return v
    }()
    
    private lazy var backBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named:"返回"), forState: .Normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(self.backClick), forControlEvents: .TouchUpInside)
        return btn
    }()
    
    func backClick(){
        
//        self.getCurrentVC().navigationController?.popViewControllerAnimated(true)
        jump2AnyController(MySettingViewController(nibName: "MySettingView", bundle: nil))
//        ConnectWiFiViewController(nibName: "ConnectWiFiView",bundle: nil)
    }
    
    
    
    @IBOutlet weak var webView: UIWebView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
//        initMainHeadView("说明书", imageName: "返回")
        
        setupUI()
        
//        测试:http://192.168.0.111/faxian/instructions2.html
        //线上:http://robosys.cc:6789/faxian/instructions.html
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://robosys.cc:6789/faxian/instructions.html")!))
        webView.opaque = false
        
        webView.scrollView.bounces = false
       
        webView.delegate = self
    }
    
    func setupUI(){
        
        self.addSubview(navBar)
        self.navBar.addSubview(backBtn)
        
        navBar.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(64)
        }
        
        backBtn.snp_makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(34)
        }
        
    }
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        HYBProgressHUD.show("正在加载")
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        HYBProgressHUD.dismiss()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
        print("\(error)")
    }
}

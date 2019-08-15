//
//  About.swift
//  robosys
//
//  Created by Cheer on 16/7/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class About: AppView,UIWebViewDelegate
{
    @IBOutlet weak var webView: UIWebView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("关于", imageName: "返回")
        
//        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://robosys.test.vdcs.cc/apps/common/about.html")!))
        webView.loadRequest(NSURLRequest(URL:NSURL(string: "http://robosys.test.vdcs.cc/apps/common/about.html")!))
        
        webView.opaque = false

        webView.scrollView.bounces = false
        
        webView.delegate = self
    }
    func webViewDidStartLoad(webView: UIWebView)
    {
        HYBProgressHUD.show("正在加载")
    }
    func webViewDidFinishLoad(webView: UIWebView)
    {
        HYBProgressHUD.dismiss()
    }
}

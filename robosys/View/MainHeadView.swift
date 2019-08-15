//
//  MainHeadView.swift
//  robosys
//
//  Created by Cheer on 16/6/27.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import SnapKit
class MainHeadView: AppView
{
 
    lazy var titleLabel: UILabel = {
        
        let titleLab = UILabel()
//        titleLab.hidden = false
        titleLab.textColor = UIColor.whiteColor()
        titleLab.font = UIFont.init(name: "RTWS yueGothic Trial", size: 17)
        return titleLab
    }()
    
    lazy var leftBtn: UIButton = {
        
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.back), forControlEvents: .TouchUpInside)
        return btn
    }()
    
    lazy var imageV : UIImageView = UIImageView(image: UIImage(named: "主标题"))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setupUI(){
        
        self.addSubview(imageV)
        imageV.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.addSubview(leftBtn)
        self.addSubview(titleLabel)
        
        
        leftBtn.snp_makeConstraints { (make) in
            
            make.centerY.equalTo(self).offset(-20)
            make.left.equalTo(18)
            make.width.equalTo(40)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            
            make.height.equalTo(20.5)
            make.centerX.equalTo(self)
            make.centerY.equalTo(leftBtn)
        }
        
    }
    
    func back() {
        
//        dispatch_async(dispatch_get_main_queue()) {
//        
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.01 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
////        {
////            [unowned self] in
        
            let vc = self.getCurrentVC()
            
            if let main = vc.navigationController?.visibleViewController  where main is MainViewController && ( vc is RecreationalViewController || vc is MyViewController || vc is LearnViewController)
            {
                (main as! MainViewController).leftView.show()
                return
            }
                vc.navigationController!.popViewControllerAnimated(true)
//                self.navigationController?.pushViewController(MainViewController(), animated: true)
//        }
        
    }
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}

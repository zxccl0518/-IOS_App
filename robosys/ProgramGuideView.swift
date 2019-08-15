//
//  ProgramGuideView.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/24.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class ProgramGuideView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.addSubview(self.createView(1))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView(pageCount:Int) -> UIImageView {
        
        let bounds = UIScreen.mainScreen().bounds
        let scale = UIScreen.mainScreen().scale
        let imageName = "program_guide_\(pageCount)_\((Int(bounds.size.height))*(Int(scale)))_\((Int(bounds.size.width)*(Int(scale))))"
        
        let imageView = UIImageView.init(frame: bounds)
        imageView.userInteractionEnabled = true
        imageView.image = UIImage.init(named: imageName)
        
        switch pageCount {
        case 1:
            self.handleImageView1(imageView)
            break
        case 2:
            self.handleImageView2(imageView)
            break
        case 3:
            self.handleImageView3(imageView)
            break
        case 4:
            self.handleImageView4(imageView)
            break
        case 5:
            self.handleImageView5(imageView)
            break
        case 6:
            self.handleImageView6(imageView)
            break
        case 7:
            self.handleImageView7(imageView)
            break
        default:

            break
        }
        
        return imageView
        
    }
    
    func handleImageView1(imageView:UIImageView) {
        
        
        let bounds = UIScreen.mainScreen().bounds
        let widthAndHeight = "\(Int(bounds.size.width))_\(Int(bounds.size.height))"
        
        let btn = UIButton.init(type: .Custom)
        btn.tag = 1
        btn.addTarget(self, action: #selector(ProgramGuideView.btnClick(_:)), forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.clearColor()
        imageView.addSubview(btn)
        
        
        switch widthAndHeight {
            
        case "\(480)_\(320)":
            btn.frame = CGRectMake(0, 320-125, 70, 70)
            
            break
        case "\(568)_\(320)":
            btn.frame = CGRectMake(0, 320-125, 70, 70)
            
            break
        case "\(667)_\(375)":
            btn.frame = CGRectMake(0, 375-125, 70, 70)
            
            break
        case "\(736)_\(414)":
            btn.frame = CGRectMake(0, 414-125, 70, 70)
            
            break
            
            
        default:
            break
        }
        
    }
    
    func handleImageView2(imageView:UIImageView) {
        
        
        let bounds = UIScreen.mainScreen().bounds
        let widthAndHeight = "\(Int(bounds.size.width))_\(Int(bounds.size.height))"
        
        let btn = UIButton.init(type: .Custom)
        btn.tag = 2
        btn.addTarget(self, action: #selector(ProgramGuideView.btnClick(_:)), forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.clearColor()
        imageView.addSubview(btn)
        
        
        switch widthAndHeight {
            
        case "\(480)_\(320)":
            btn.frame = CGRectMake(70, 320-125, 70, 70)
            
            break
        case "\(568)_\(320)":
            btn.frame = CGRectMake(70, 320-125, 70, 70)
            
            break
        case "\(667)_\(375)":
            btn.frame = CGRectMake(70, 375-125, 70, 70)
            
            break
        case "\(736)_\(414)":
            btn.frame = CGRectMake(70, 414-125, 70, 70)
            
            break
            
            
        default:
            break
        }
        
    }
    
    func handleImageView3(imageView:UIImageView) {
        
        
        let bounds = UIScreen.mainScreen().bounds
        let widthAndHeight = "\(Int(bounds.size.width))_\(Int(bounds.size.height))"
        
        let btn = UIButton.init(type: .Custom)
        btn.tag = 3
        btn.addTarget(self, action: #selector(ProgramGuideView.btnClick(_:)), forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.clearColor()
        imageView.addSubview(btn)
        
        let width = bounds.size.width/2.0 + 12.0
        
        
        switch widthAndHeight {
            
        case "\(480)_\(320)":
            btn.frame = CGRectMake(width, bounds.size.height/2 + 17, 150, 35)
            
            break
        case "\(568)_\(320)":
            btn.frame = CGRectMake(width, bounds.size.height/2 + 17, 150, 35)
            
            break
        case "\(667)_\(375)":
            btn.frame = CGRectMake(width, bounds.size.height/2 + 17, 150, 35)
            
            break
        case "\(736)_\(414)":
            btn.frame = CGRectMake(width, bounds.size.height/2 + 17, 150, 35)
            
            break
            
            
        default:
            break
        }
        
    }
    
    func handleImageView4(imageView:UIImageView) {
        
        
        let bounds = UIScreen.mainScreen().bounds
        let widthAndHeight = "\(Int(bounds.size.width))_\(Int(bounds.size.height))"
        
        let btn = UIButton.init(type: .Custom)
        btn.tag = 4
        btn.addTarget(self, action: #selector(ProgramGuideView.btnClick(_:)), forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.clearColor()
        imageView.addSubview(btn)
        
        
        switch widthAndHeight {
            
        case "\(480)_\(320)":
            btn.frame = CGRectMake(170, 320-125, 70, 70)
            
            break
        case "\(568)_\(320)":
            btn.frame = CGRectMake(170, 320-125, 70, 70)
            
            break
        case "\(667)_\(375)":
            btn.frame = CGRectMake(170, 375-125, 70, 70)
            
            break
        case "\(736)_\(414)":
            btn.frame = CGRectMake(170, 414-125, 70, 70)
            
            break
            
            
        default:
            break
        }
        
    }
    
    func handleImageView5(imageView:UIImageView) {
        
        
        let bounds = UIScreen.mainScreen().bounds
        let widthAndHeight = "\(Int(bounds.size.width))_\(Int(bounds.size.height))"
        
        let btn = UIButton.init(type: .Custom)
        btn.tag = 5
        btn.addTarget(self, action: #selector(ProgramGuideView.btnClick(_:)), forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.clearColor()
        imageView.addSubview(btn)
        
        
        switch widthAndHeight {
            
        case "\(480)_\(320)":
            btn.frame = CGRectMake(bounds.size.width - 135, 0, 44, 44)
            
            break
        case "\(568)_\(320)":
            btn.frame = CGRectMake(bounds.size.width - 135, 0, 44, 44)
            
            break
        case "\(667)_\(375)":
            btn.frame = CGRectMake(bounds.size.width - 135, 0, 44, 44)
            
            break
        case "\(736)_\(414)":
            btn.frame = CGRectMake(bounds.size.width - 135, 0, 44, 44)
            
            break
            
            
        default:
            break
        }
        
    }
    
    func handleImageView6(imageView:UIImageView) {
        
        
        let bounds = UIScreen.mainScreen().bounds
        let widthAndHeight = "\(Int(bounds.size.width))_\(Int(bounds.size.height))"
        
        let btn = UIButton.init(type: .Custom)
        btn.tag = 6
        btn.addTarget(self, action: #selector(ProgramGuideView.btnClick(_:)), forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.clearColor()
        imageView.addSubview(btn)
        
        switch widthAndHeight {
            
        case "\(480)_\(320)":
            btn.frame = CGRectMake(bounds.size.width - 44, 0, 44, 44)
            
            break
        case "\(568)_\(320)":
            btn.frame = CGRectMake(bounds.size.width - 44, 0, 44, 44)
            
            break
        case "\(667)_\(375)":
            btn.frame = CGRectMake(bounds.size.width - 44, 0, 44, 44)
            
            break
        case "\(736)_\(414)":
            btn.frame = CGRectMake(bounds.size.width - 44, 0, 44, 44)
            
            break
            
            
        default:
            break
        }
        
    }
    
    func handleImageView7(imageView:UIImageView) {
        
        
        let bounds = UIScreen.mainScreen().bounds
        let widthAndHeight = "\(Int(bounds.size.width))_\(Int(bounds.size.height))"
        
        let btn = UIButton.init(type: .Custom)
        btn.tag = 7
        btn.addTarget(self, action: #selector(ProgramGuideView.btnClick(_:)), forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.clearColor()
        imageView.addSubview(btn)
        
        let width = bounds.size.width/2.0 + 12.0

        switch widthAndHeight {
            
        case "\(480)_\(320)":
            btn.frame = CGRectMake(width, bounds.size.height/2 + 17, 140, 35)
            
            break
        case "\(568)_\(320)":
            btn.frame = CGRectMake(width, bounds.size.height/2 + 17, 140, 35)
            
            break
        case "\(667)_\(375)":
            btn.frame = CGRectMake(width, bounds.size.height/2 + 17, 140, 35)
            
            break
        case "\(736)_\(414)":
            btn.frame = CGRectMake(width, bounds.size.height/2 + 17, 140, 35)
            
            break
            
            
        default:
            break
        }
        
    }
    
    func btnClick(btn:UIButton) {
        
        switch btn.tag {
        case 1:
            self.addSubview(self.createView(2))

            break
        case 2:
            self.addSubview(self.createView(3))

            break
        case 3:
            self.addSubview(self.createView(4))

            break
        case 4:
            self.addSubview(self.createView(5))

            break
        case 5:
            self.addSubview(self.createView(6))

            break
        case 6:
            self.addSubview(self.createView(7))

            break
        case 7:
            
            self.removeFromSuperview()

            break
        
        default:
            break
        }
        
    }
    
    
}

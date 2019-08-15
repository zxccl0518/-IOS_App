//
//  ProgramSliderView.swift
//  robosys
//
//  Created by Cheer on 16/6/15.
//  Copyright © 2016年 joekoe. All rights reserved.
//

class ProgramSliderView : UIView
{
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var subRightLabel: UILabel!
    @IBOutlet weak var subLeftLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!

    
    var setFrame : CGRect!
    {
        didSet
        {
            frame = setFrame
        }
    }
    private var subLabel:String!
    {
        didSet
        {
            if oldValue != nil { subLabel = oldValue }
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        slider.setThumbImage(UIImage(named: "进度"), forState: .Normal)
        slider.setThumbImage(UIImage(named: "进度-按下"), forState: .Selected)
//        slider.setMinimumTrackImage(UIImage(named: "设置条"), forState: .Normal)
        slider.setMaximumTrackImage(UIImage(named: "设置条"), forState: .Normal)
        slider.backgroundColor = .clearColor()
        slider.value = 0.0
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        
        slider.addTarget(self, action: #selector(ProgramSliderView.valueChanged), forControlEvents: .ValueChanged)
        
        rightLabel.layer.borderColor = UIColor(red: 30/255, green: 144/255, blue: 1, alpha: 1).CGColor//	30	144	255
        rightLabel.layer.borderWidth = 1.0
        rightLabel.layer.cornerRadius = 5.0
        
        
    }
    
    func valueChanged()
    {
        if let _ = slider.currentThumbImage where bgImage.frame.size.width < slider.frame.width - slider.currentThumbImage!.size.width
        {
            bgImage.frame.size.width = CGFloat(slider.value) * slider.frame.width
        }
        
        if subRightLabel.text!.containsString(":")
        {
            let (minR,secR) = ((subRightLabel.text! as NSString).substringToIndex(2),(subRightLabel.text! as NSString).substringFromIndex(3))
            
            let (minL,secL) = ((subLeftLabel.text! as NSString).substringToIndex(2),(subLeftLabel.text! as NSString).substringFromIndex(3))
            
            let total = (Int(minR)! - Int(minL)!) * 60 + (Int(secR)! - Int(secL)!)
            
            let res = Float(total) * slider.value
 
            rightLabel.text = (Int(res / 60) < 10 ? "0\(Int(res / 60))" : "\(Int(res / 60))") + (Int(res % 60) < 10 ? ":0\(Int(res % 60))" : ":\(Int(res % 60))")
            
            if let superV = superview as? ProgramAlertView
            {
                var result = true
                
                for view in superV.subviews
                {
                    if let v = view as? ProgramSliderView where v.rightLabel.text == "00:00"
                    {
                        result = false
                    }
                    
                    if view.classForCoder == UIView.classForCoder()
                    {
                        for subView in view.subviews
                        {
                            if let v = subView as? UITextField where v.text == ""
                            {
                                result = false
                            }
                        }
                    }
                }
                
                superV.ensureBtn.enabled = result
            }
            
            return
        }
        if rightLabel.text!.containsString("次")
        {
            subLabel = (rightLabel.text! as NSString).substringFromIndex(1)
            
            rightLabel.text = String(format: "%.0f", Float(Int(subRightLabel.text!)! - Int(subLeftLabel.text!)!) * slider.value + Float(Int(subLeftLabel.text!)!)) + subLabel
            
            if let superV = superview as? ProgramAlertView
            {
                var result = true
                
                for view in superV.subviews
                {
                    if let v = view as? ProgramSliderView where v.rightLabel.text == "0次"
                    {
                        result = false
                    }
                }
                superV.ensureBtn.enabled = result
            }
            
            return
        }
        
        subLabel = (rightLabel.text! as NSString).substringFromIndex(1)
        rightLabel.text = String(format: "%.0f", Float(Int(subRightLabel.text!)! - Int(subLeftLabel.text!)!) * slider.value + Float(Int(subLeftLabel.text!)!)) + subLabel
    }
}

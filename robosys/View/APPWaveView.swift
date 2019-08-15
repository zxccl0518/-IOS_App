//
//  APPWaveView.swift
//  robosys
//
//  Created by Cheer on 16/6/27.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit


class WaterWaveView: UIView
{
    var percent:CGFloat!
    
    var waveDisplaylink:CADisplayLink!
    var waveLayer = CAShapeLayer()
    
    var waveAmplitude:CGFloat!  // 波纹振幅
    var waveCycle:CGFloat!       // 波纹周期
    var waveSpeed:CGFloat!       // 波纹速度
    var waterWaveHeight:CGFloat!
    
    var waveGrowth:CGFloat = 0.0       // 波纹上升速度
    var waterWaveWidth:CGFloat = 0.0
    var offsetX:CGFloat = 0.0            // 波浪x位移
    var currentWavePointY:CGFloat = 0.0  // 当前波浪上市高度Y（高度从大到小 坐标系向下增长）
    var variable:CGFloat = 0.0      //可变参数 更加真实 模拟波纹
    
    var increase:Bool!       // 增减变化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    override var frame: CGRect
    {
        didSet
        {
            waterWaveHeight = self.frame.size.height/2;
            waterWaveWidth  = self.frame.size.width;
            if (waterWaveWidth > 0) {
                waveCycle =  1.29 * CGFloat(M_PI) / waterWaveWidth;
            }
            
            if (currentWavePointY <= 0) {
                currentWavePointY = self.frame.size.height;
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp()
    {
        waterWaveHeight = frame.size.height * 0.5
        waterWaveWidth  = frame.size.width
       
     
        waveGrowth = 0.85
        waveSpeed = 0.4 / CGFloat(M_PI)
        
        resetProperty()
    }
    func resetProperty()
    {
        currentWavePointY = frame.size.height
        
        variable = 1.6
        increase = false
        
        offsetX = 0
    }
    func startWave()
    {
        layer.addSublayer(waveLayer)
        
        if (waveDisplaylink == nil) {
            // 启动定时调用
            waveDisplaylink = CADisplayLink(target: self, selector: #selector(WaterWaveView.getCurrentWave))
        
            waveDisplaylink.addToRunLoop(.mainRunLoop(), forMode: NSRunLoopCommonModes)
        }
    }
    func getCurrentWave()
    {
        animate()
        
        if ( waveGrowth > 0 && currentWavePointY > 2 * waterWaveHeight * (1 - percent)) {
            // 波浪高度未到指定高度 继续上涨
            currentWavePointY -= waveGrowth
        }
        else if (waveGrowth < 0 && currentWavePointY < 2 * waterWaveHeight * (1 - percent)){
            currentWavePointY -= waveGrowth
        }
        // 波浪位移
        offsetX += waveSpeed
        
        setCurrentWaveLayerPath()
    
    }
    func animate()
    {
        variable += increase == true ? 0.01 : -0.01
        
        if variable <= 1
        {
            increase = true
        }
        if variable >= 1.6
        {
            increase = false
        }
        waveAmplitude = variable
    }
    func setCurrentWaveLayerPath()
    {
        let path = CGPathCreateMutable()
        var y = currentWavePointY
        CGPathMoveToPoint(path, nil, 0, currentWavePointY)
 
        for x in CGFloat(0).stride(to: waterWaveWidth, by: 1)
        {
            y = waveAmplitude * sin(waveCycle * x + offsetX) + currentWavePointY
            CGPathAddLineToPoint(path, nil, x, y)
        }
        
        CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height)
        CGPathAddLineToPoint(path, nil, 0, self.frame.size.height)
        CGPathCloseSubpath(path)
        
        waveLayer.path = path
        CGPathCloseSubpath(path)
    }
    func stopWave()
    {
        if waveDisplaylink != nil
        {
            waveDisplaylink.invalidate()
            waveDisplaylink = nil
        }
    }
    func reset()
    {
        stopWave()
        resetProperty()
        
        waveLayer.removeFromSuperlayer()
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}

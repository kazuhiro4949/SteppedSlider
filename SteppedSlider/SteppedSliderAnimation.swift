//
//  SteppedSliderAnimation.swift
//  SteppedSlider
//
//  Created by Kazuhiro Hayashi on 2020/08/23.
//  Copyright © 2020 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

class SteppedSliderAnimation: NSObject {
    private var displaylink: CADisplayLink!
    private let animationSpeed: CGFloat
    private let beginTime: TimeInterval
    private let endTime: TimeInterval
    
    private let begin: Double
    private let end: Double
    
    private let update: (SteppedSliderAnimation, Double) -> Void
    private let complesion: (SteppedSliderAnimation) -> Void
    
    init(animationSpeed: CGFloat, begin: Double, end: Double, update: @escaping (SteppedSliderAnimation, Double) -> Void, complesion: @escaping (SteppedSliderAnimation) -> Void) {
        beginTime = Date.timeIntervalSinceReferenceDate
        endTime = beginTime + TimeInterval(animationSpeed)
        
        self.begin = begin
        self.end = end
        self.animationSpeed = animationSpeed
        self.update = update
        self.complesion = complesion
        
        super.init()
        
        displaylink = CADisplayLink(target: self, selector: #selector(update(_:)))
    }
    
    func start() {
        displaylink.add(to: RunLoop.main, forMode: .common)
    }
    
    func interrupt() {
        displaylink.invalidate()
    }
    
    @objc func update(_ displaylink: CADisplayLink) {
        let currentTime = Date.timeIntervalSinceReferenceDate
        guard currentTime <= endTime else {
            self.displaylink.invalidate()
            update(self, end)
            complesion(self)
            return
        }
        
        let currentPercent = (currentTime - beginTime) / (endTime - beginTime)
        let currentValue = (end - begin) * currentPercent + begin
        update(self, currentValue)
    }
}

//
//  SteppedSlider.swift
//  SteppedSlider
//
//  Created by Kazuhiro Hayashi on 2020/08/17.
//  Copyright © 2020 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

open class SteppedSlider: UIControl {
    open override var contentMode: UIView.ContentMode {
        didSet {
            stackView.arrangedSubviews.forEach {
                $0.contentMode = contentMode
            }
        }
    }
    
    /// default 0. this value will be pinned to min/max
    open var value: Double = 0 {
        didSet {
            value = max(min(value, maximumValue), minimumValue)
            reset()
        }
    }
    
    /// default 0 the current value may change if outside new min value
    open var minimumValue: Double = 0 {
        didSet {
            minimumValue = min(minimumValue, maximumValue)
        }
    }

    /// default 5. the current value may change if outside new max value
    open var maximumValue: Double = 5 {
        didSet {
            maximumValue = max(minimumValue, maximumValue)
        }
    }
    
    /// default 1. must be greater than 0
    open var stepValue: Double = 1{
        didSet {
            if stepValue <= 0 {
                stepValue = 1
            }
        }
    }
    
    /// default is nil. image that appears to left of control (e.g. speaker off)
    open var currentMinimumTrackImage: UIImage? = UIImage(systemName: "star.fill") {
        didSet {
            reset()
        }
    }
    
    // default is nil. image that appears to right of control (e.g. speaker max)
    open var currentMaximumTrackImage: UIImage? = UIImage(systemName: "star") {
        didSet {
            reset()
        }
    }

    
    /// default is yello. image that appears to left of control (e.g. speaker off)
    open var minimumTrackTintColor: UIColor? = .systemYellow {
        didSet {
            reset()
        }
    }
    
    /// default is gray. image that appears to left of control (e.g. speaker off)
    open var maximumTrackTintColor: UIColor? = .systemGray4 {
        didSet {
            reset()
        }
    }
    
    /// move slider at fixed velocity (i.e. duration depends on distance). does not send action
    open func setValue(_ value: Int, animated: Bool) {
        
    }
    
    open var numberOfValues: Int {
       Int((maximumValue - minimumValue) / stepValue) + 1
    }
    
    open var numberOfItems: Int {
       Int((maximumValue - minimumValue) / stepValue)
    }
    
    func getValue(from item: Int) -> Double {
        let itemOffset = Double(item + 1) * stepValue
        return minimumValue + itemOffset
    }
    
    func getItem(from value: Double) -> Int? {
        let valueOffset = min(maximumValue, max(minimumValue, value - minimumValue))
        let itemOffset = Int(valueOffset / stepValue)
        
        if itemOffset == 0  {
            return nil
        } else {
            return itemOffset - 1
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public var spacing: CGFloat = 4 {
        didSet {
            stackView.spacing = spacing
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()
    
    private var touchingState: SteppedSliderImageView.State?
    
    private func commonInit() {
        stackView.frame = bounds
        addSubview(stackView)
        reset()
    }
    
    private func reset() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        (0..<numberOfItems).forEach { item in
            let imageView = SteppedSliderImageView(
                activeImage: currentMinimumTrackImage,
                inactiveImage: currentMaximumTrackImage,
                activeTintColor: minimumTrackTintColor,
                inactiveTintColor: maximumTrackTintColor)
            imageView.item = item
            imageView.contentMode = .scaleAspectFit
            imageView.layer.masksToBounds = true
            stackView.addArrangedSubview(imageView)
            
            if value < getValue(from: item) {
                imageView.state = .inactive
            } else {
                imageView.state = .active
            }
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        guard let imageView = hitTest(touch.location(in: self), with: event) as? SteppedSliderImageView,
            let item = imageView.item else {
            return
        }
        imageView.state.toggle()
        touchingState = imageView.state

        updateImageStates(item: item)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let hitTestPoint = CGPoint(x: touch.location(in: self).x, y: stackView.bounds.midY)
        guard let imageView = hitTest(hitTestPoint, with: event) as? SteppedSliderImageView,
            let item = imageView.item else {
                updateStateIfExceeded(point: hitTestPoint)
                return
        }

        if let touchingState = touchingState {
            imageView.state = touchingState
        }
        
        updateImageStates(item: item)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchingState = nil
    }
    
    private func updateStateIfExceeded(point: CGPoint) {
        if let lastImageView = stackView.subviews.last as? SteppedSliderImageView, lastImageView.frame.maxX < point.x {
            lastImageView.state = .active
        } else if let firstImageView = stackView.subviews.first as? SteppedSliderImageView, point.x < firstImageView.frame.minX {
            firstImageView.state = .inactive
        }
    }
    
    
    private func updateImageStates(item: Int) {
        let newValue = getValue(from: item)
        let oldItem = getItem(from: self.value) ?? 0
        
        if self.value < newValue {
            (oldItem..<item).forEach {
                (stackView.subviews[$0] as? SteppedSliderImageView)?.state = .active
            }
        } else if newValue < self.value {
            (item+1...oldItem).forEach {
                (stackView.subviews[$0] as? SteppedSliderImageView)?.state = .inactive
            }
        }

        value = newValue
    }

    /// if YES, value wraps from min <-> max. default = false
//    open var wraps: Bool = false
    
//    open var isContiuous: Bool = true
//
//    open var animationSpeed: CGFloat = 0.4
//
//    func preferredImage(for state: UIControl.State) -> UIImage? {
//        return nil
//    }
//
//    func setPreferredImage(_ image: UIImage, for state: UIControl.State) {
//
//    }
//
//    func setImage(at index: Int, for state: UIControl.State) {
//
//    }
//
//
//    func image(at index: Int,for state: UIControl.State) -> UIImage? {
//        nil
//    }
}

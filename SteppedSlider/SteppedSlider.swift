//
//  SteppedSlider.swift
//  SteppedSlider
//
//  Copyright (c) 2020 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
    open var value: Double {
        set {
            if let item = getItem(from: rawValue) {
                updateImageStates(item: item)
            } else {
                rawValue = newValue
                reset()
            }
        }
        get {
            return rawValue
        }
    }
    
    private var rawValue: Double = 0 {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    
    private var animator: SteppedSliderAnimation?
    
    /// default 0 the current value may change if outside new min value
    open var minimumValue: Double = 0 {
        didSet {
            minimumValue = min(minimumValue, maximumValue)
            reset()
        }
    }

    /// default 5. the current value may change if outside new max value
    open var maximumValue: Double = 5 {
        didSet {
            maximumValue = max(minimumValue, maximumValue)
            reset()
        }
    }
    
    /// default 1. must be greater than 0
    open var stepValue: Double = 1{
        didSet {
            if stepValue <= 0 {
                stepValue = 1
            }
            reset()
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
    open func setValue(_ value: Double, animated: Bool) {
        if animated {
            animator = SteppedSliderAnimation(
                animationSpeed: animationSpeed,
                begin: rawValue,
                end: value,
                update: { [weak self] (_, value) in
                    if let item = self?.getItem(from: value) {
                        self?.updateImageStates(item: item)
                    }
                },
                complesion: { [weak self] (_) in
                    self?.animator = nil
                }
            )
            animator?.start()
        } else {
            self.value = value
        }
    }
    
    open var numberOfValues: Int {
       Int(ceil((maximumValue - minimumValue) / stepValue)) + 1
    }
    
    open var numberOfItems: Int {
       Int(ceil((maximumValue - minimumValue) / stepValue))
    }
    
    open var isContinuous: Bool = true
    
    open func getValue(from item: Int) -> Double {
        let itemOffset = Double(item + 1) * stepValue
        return min(maximumValue, minimumValue + itemOffset)
    }
    
    func getItem(from value: Double) -> Int? {
        let maximumRelativeValue = maximumValue - minimumValue
        let relativeValue = value - minimumValue
        let valueOffset = min(maximumRelativeValue, max(0, relativeValue))
        let itemOffset = Int(ceil(valueOffset / stepValue))
        
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
        
    private func commonInit() {
        stackView.frame = bounds
        addSubview(stackView)
        reset()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        guard let imageView = hitTest(touch.location(in: self), with: event) as? SteppedSliderImageView,
            let item = imageView.item else {
            return
        }
        
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

        updateImageStates(item: item)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }

    private func reset() {
        rawValue = minimumValue
        if isContinuous {
            resetContinuously()
        } else {
            resetDiscontinuously()
        }
    }
    
    private func resetContinuously() {
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
            
            if rawValue < getValue(from: item) {
                imageView.state = .inactive
            } else {
                imageView.state = .active
            }
        }
    }
    
    private func resetDiscontinuously() {
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
            
            if rawValue == getValue(from: item) {
                imageView.state = .active
            } else {
                imageView.state = .inactive
            }
        }
    }
    
    private func updateImageStates(item: Int) {
        if isContinuous {
            updateImageStatesContinuously(item: item)
        } else {
            updateImageStatesDiscontinuously(item: item)
        }
    }
    
    private func updateImageStatesContinuously(item: Int) {
        let newValue = getValue(from: item)
        let oldItem = getItem(from: rawValue) ?? 0
        
        if rawValue < newValue {
            (oldItem...item).forEach {
                (stackView.subviews[$0] as? SteppedSliderImageView)?.state = .active
            }
        } else if newValue < rawValue {
            (item+1...oldItem).forEach {
                (stackView.subviews[$0] as? SteppedSliderImageView)?.state = .inactive
            }
        }

        rawValue = newValue
    }
    
    private func updateImageStatesDiscontinuously(item: Int) {
        let newValue = getValue(from: item)
        let oldItem = getItem(from: rawValue) ?? 0
        
        (stackView.subviews[item] as? SteppedSliderImageView)?.state = .active
        
        if rawValue < newValue {
            (oldItem..<item).forEach {
                (stackView.subviews[$0] as? SteppedSliderImageView)?.state = .inactive
            }
        } else if newValue < rawValue {
            (item+1...oldItem).forEach {
                (stackView.subviews[$0] as? SteppedSliderImageView)?.state = .inactive
            }
        }

        rawValue = newValue
    }
    
    
    private func updateStateIfExceeded(point: CGPoint) {
        if let lastImageView = stackView.subviews.last as? SteppedSliderImageView, lastImageView.frame.maxX < point.x {
            lastImageView.state = .active
            rawValue = maximumValue
        } else if let firstImageView = stackView.subviews.first as? SteppedSliderImageView, point.x < firstImageView.frame.minX {
            firstImageView.state = .inactive
            rawValue = minimumValue
        }
    }
    
    open var animationSpeed: CGFloat = 0.2
    
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

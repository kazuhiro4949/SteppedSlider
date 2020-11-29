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
    /// default scaleToFill. content mode for each slider element
    open override var contentMode: UIView.ContentMode {
        didSet {
            listController.contentMode = contentMode
        }
    }
    
    /// default 0. this value will be pinned to min/max, dose not send action
    open var value: Double {
        set {
            listController.updateImageStates(from: newValue)
        }
        get {
            return listController.rawValue
        }
    }
    
    private let listController = SteppedSliderListController()
    
    private var animator: SteppedSliderAnimation?
    
    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    /// default 0 the current value may change if outside new min value
    open var minimumValue: Double = 0 {
        didSet {
            listController.minimumValue = minimumValue
            reset()
        }
    }

    /// default 5. the current value may change if outside new max value
    open var maximumValue: Double = 5 {
        didSet {
            listController.maximumValue = maximumValue
            reset()
        }
    }
    
    /// valid range of value
    open var values: ClosedRange<Double> {
        set {
            minimumValue = newValue.lowerBound
            maximumValue = newValue.upperBound
        }
        get {
            (minimumValue...maximumValue)
        }
    }
    
    /// default 1. must be greater than 0
    open var stepValue: Double = 1{
        didSet {
            listController.stepValue = stepValue
            reset()
        }
    }
    
    /// default is nil. image that appears to left of control (e.g. speaker off)
    open var currentMinimumTrackImage: UIImage? = UIImage(systemName: "star.fill") {
        didSet {
            listController.currentMinimumTrackImage = currentMinimumTrackImage
            reset()
        }
    }
    
    // default is nil. image that appears to right of control (e.g. speaker max)
    open var currentMaximumTrackImage: UIImage? = UIImage(systemName: "star") {
        didSet {
            listController.currentMaximumTrackImage = currentMaximumTrackImage
            reset()
        }
    }

    
    /// default is yello. image that appears to left of control (e.g. speaker off)
    open var minimumTrackTintColor: UIColor? = .systemYellow {
        didSet {
            listController.minimumTrackTintColor = minimumTrackTintColor
            reset()
        }
    }
    
    /// default is gray. image that appears to left of control (e.g. speaker off)
    open var maximumTrackTintColor: UIColor? = .systemGray4 {
        didSet {
            listController.maximumTrackTintColor = maximumTrackTintColor
        }
    }

    /// move slider at fixed velocity (i.e. duration depends on distance). does not send action
    open func setValue(_ value: Double, animated: Bool) {
        if animated {
            animator = SteppedSliderAnimation(
                animationSpeed: animationSpeed,
                begin: listController.rawValue,
                end: value,
                update: { [weak self] (_, value) in
                    self?.listController
                        .updateImageStates(from: value)
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
    
    /// numberOfValues is numberOfItems + 1, because empty slider has a value.
    open var numberOfValues: Int {
        listController.numberOfValues
    }
    
    open var numberOfItems: Int {
        listController.numberOfItems
    }
    
    /// if set, value change events are generated any time the value changes due to dragging. default = false
    open var isContinuous: Bool {
        set {
            listController.isContinuous = newValue
            reset()
        }
        get {
            listController.isContinuous
        }
    }
    
    /// this value will be pinned to min/max,
    open func getValue(from item: Int) -> Double {
        listController.getValue(from: item)
    }
    
    /// velocity of slider
    open var animationSpeed: CGFloat = 0.2
    
    /// this value will be pinned to min/max,
    func getItem(from value: Double) -> Int {
        listController.getItem(from: value)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // defalut 4; spaces between elements
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
        feedbackGenerator.prepare()
        stackView.frame = bounds
        addSubview(stackView)
        reset()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        guard let imageView = hitTest(touch.location(in: self), with: event) as? SteppedSliderImageView else {
            return
        }
        
        listController.updateImageStates(from: imageView.item) { [weak self] (_, _) in
            self?.feedbackGenerator.impactOccurred()
            self?.sendActions(for: .valueChanged)
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let hitTestPoint = CGPoint(x: touch.location(in: self).x, y: stackView.bounds.midY)
        guard let imageView = hitTest(hitTestPoint, with: event) as? SteppedSliderImageView else {
            listController.updateStateIfExceeded(point: hitTestPoint) { [weak self] _, _ in
                self?.feedbackGenerator.impactOccurred()
                self?.sendActions(for: .valueChanged)
            }
            sendActions(for: .valueChanged)
            return
        }

        listController.updateImageStates(from: imageView.item) { [weak self] (_, _) in
            self?.feedbackGenerator.impactOccurred()
            self?.sendActions(for: .valueChanged)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }

    private func reset() {
        stackView.removeArrangedSubviewsCompletely()
        listController.reset()
        
        (0..<numberOfItems).forEach { item in
            let imageView = listController.generateImageView(item: item)
            imageView.value = getValue(from: item)
            stackView.addArrangedSubview(imageView)
        }
    }
    
    deinit {
        animator?.interrupt()
    }
}

extension UIStackView {
    func removeArrangedSubviewsCompletely() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}

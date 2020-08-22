//
//  SteppedSliderImageView.swift
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

class SteppedSliderImageView: UIImageView {
    enum State {
        case active
        case inactive
        
        mutating func toggle() {
            switch self {
            case .active:
                self = .inactive
            case .inactive:
                self = .active
            }
        }
    }
    
    var state: State = .inactive {
        didSet {
            switch state {
            case .active:
                image = activeImage
                tintColor = activeTintColor
            case .inactive:
                image = inactiveImage
                tintColor = inactiveTintColor
            }
        }
    }
    
    private var activeImage: UIImage?
    private var inactiveImage: UIImage?
    private var activeTintColor: UIColor?
    private var inactiveTintColor: UIColor?
    
    var item: Int?
    
    init(activeImage: UIImage?, inactiveImage: UIImage?, activeTintColor: UIColor?, inactiveTintColor: UIColor?) {
        super.init(frame: CGRect.zero)
        
        self.activeImage = activeImage
        self.inactiveImage = inactiveImage
        self.activeTintColor = activeTintColor
        self.inactiveTintColor = inactiveTintColor
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        true
    }
}

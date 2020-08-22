//
//  SteppedSliderImageView.swift
//  SteppedSlider
//
//  Created by kahayash on 2020/08/22.
//  Copyright © 2020 Kazuhiro Hayashi. All rights reserved.
//

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

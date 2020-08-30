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

class SteppedSliderListController {
    
    static let emptyIndex: Int = -1

    var elements = [SteppedSliderImageView]()
    
    var rawValue: Double = 0
    var currentItem: Int = emptyIndex
    
    var contentMode: UIView.ContentMode = .scaleToFill {
        didSet {
            elements.forEach {
                $0.contentMode = contentMode
            }
        }
    }
    
    var currentIndex: Int {
        min(max(0, currentItem), numberOfItems)
    }
    
    /// default 0 the current value may change if outside new min value
    var minimumValue: Double = 0 {
        didSet {
            minimumValue = min(minimumValue, maximumValue)
        }
    }

    /// default 5. the current value may change if outside new max value
    var maximumValue: Double = 5 {
        didSet {
            maximumValue = max(minimumValue, maximumValue)
        }
    }
    
    
    var isContinuous: Bool = true
     
    var currentMinimumTrackImage: UIImage? = UIImage(systemName: "star.fill")
    
    // default is nil. image that appears to right of control (e.g. speaker max)
    var currentMaximumTrackImage: UIImage? = UIImage(systemName: "star")
    
    /// default is yello. image that appears to left of control (e.g. speaker off)
    var minimumTrackTintColor: UIColor? = .systemYellow
    
    /// default is gray. image that appears to left of control (e.g. speaker off)
    var maximumTrackTintColor: UIColor? = .systemGray4
    
    var numberOfValues: Int {
       Int(ceil((maximumValue - minimumValue) / stepValue)) + 1
    }
    
    var numberOfItems: Int {
       Int(ceil((maximumValue - minimumValue) / stepValue))
    }
    
    var stepValue: Double = 1 {
        didSet {
            if stepValue <= 0 {
                stepValue = 1
            }
        }
    }
    
    open func getValue(from item: Int) -> Double {
        let itemOffset = Double(item + 1) * stepValue
        return min(maximumValue, minimumValue + itemOffset)
    }
    
    func getItem(from value: Double) -> Int {
        if value <= minimumValue {
            return SteppedSliderListController.emptyIndex
        } else if let view = elements.first(where: { $0.value <= value }) {
            return view.item
        } else {
            return max(0, (elements.count - 1))
        }
    }
    
    func reset() {
        rawValue = minimumValue
        currentItem = SteppedSliderListController.emptyIndex
        elements = []
    }
    
    func updateImageStates(from value: Double) {
        updateImageStates(from: getItem(from: value))
    }
    
    func updateImageStates(from item: Int) {
        if isContinuous {
            updateImageStatesContinuously(item: item)
        } else {
            updateImageStatesDiscontinuously(item: item)
        }
        
        rawValue = getValue(from: item)
        currentItem = item
    }
    
    func updateImageStatesContinuously(item: Int) {
        if currentItem < item {
            (currentIndex...item).forEach {
                elements[$0].state = .active
            }
        } else if item < currentItem {
            (item+1...currentIndex).forEach {
                elements[$0].state = .inactive
            }
        }
    }
    
    func updateImageStatesDiscontinuously(item: Int) {
        elements[item].state = .active
        
        if currentItem < item {
            (currentItem..<item).forEach {
                elements[$0].state = .inactive
            }
        } else if item < currentItem {
            (item+1...currentItem).forEach {
                elements[$0].state = .inactive
            }
        }
    }
    
    func updateStateIfExceeded(point: CGPoint) {
        if let lastImageView = elements.last,
            lastImageView.frame.maxX < point.x {
            lastImageView.state = .active
            rawValue = maximumValue
            currentItem = elements.endIndex - 1
        } else if let firstImageView = elements.first,
            point.x < firstImageView.frame.minX {
            firstImageView.state = .inactive
            rawValue = minimumValue
            currentItem = SteppedSliderListController.emptyIndex
        }
    }
    
    func generateImageView(item: Int) -> SteppedSliderImageView {
        let imageView = SteppedSliderImageView(
            item: item, activeImage: currentMinimumTrackImage,
            inactiveImage: currentMaximumTrackImage,
            activeTintColor: minimumTrackTintColor,
            inactiveTintColor: maximumTrackTintColor)
        imageView.state = isActive(at: item) ? .active : .inactive
        elements.append(imageView)
        
        return imageView
    }
    
    private func isActive(at item: Int) -> Bool {
        if isContinuous {
            return rawValue >= getValue(from: item)
        } else {
            return rawValue == getValue(from: item)
        }
    }
}

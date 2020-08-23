//
//  ViewController.swift
//  iOS Sample
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
import SteppedSlider

class ViewController: UIViewController {
    @IBOutlet weak var slider: SteppedSlider!
    @IBOutlet weak var textLabel: UILabel!
    
    var observer = [NSKeyValueObservation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.minimumValue = 1
        slider.maximumValue = 10
//        slider.currentMaximumTrackImage = UIImage(systemName: "smiley")
//        slider.currentMinimumTrackImage = UIImage(systemName: "smiley.fill")
        slider.isContinuous = true
        
        
        slider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }

    @objc func valueChanged(_ slider: SteppedSlider) {
        textLabel.text = "\(slider.value)"
    }
}


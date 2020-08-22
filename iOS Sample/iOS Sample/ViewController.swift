//
//  ViewController.swift
//  iOS Sample
//
//  Created by Kazuhiro Hayashi on 2020/08/21.
//  Copyright © 2020 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import SteppedSlider

class ViewController: UIViewController {
    @IBOutlet weak var slider: SteppedSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.currentMaximumTrackImage = UIImage(systemName: "smiley")
        slider.currentMinimumTrackImage = UIImage(systemName: "smiley.fill")
    }


}


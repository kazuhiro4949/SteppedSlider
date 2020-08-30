# SteppedSlider

![Swift 5.3](https://img.shields.io/badge/Swift-5.3-orange.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

SteppedSlider has features of UISlider and UIStepper.

# What's this?
SteppedSlider represents values as lined symbols. It supports touch and pan gesture to select the values.

<img src="https://user-images.githubusercontent.com/18320004/91662151-6e931a00-eb1b-11ea-9f3f-e48aa1ecbd31.gif" width=300></img>

# Feature
- [x] selecting discrete numbers with slider UI
- [x] Inheriting UIControl.
- [x] Custamizable API like UIStepper and UISlider

# Requirements
+ iOS 13.0+
+ Xcode 11.0+
+ Swift 5.3

# Installation

## Swift Package Manager
open Swift Packages (which is next to Build Settings). You can add and remove packages from this tab.

See [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)


## Carthage
+ Install Carthage from Homebrew
```
> ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
> brew update
> brew install carthage
```
+ Move your project dir and create Cartfile
```
> touch Cartfile
```
+ add the following line to Cartfile
```
github "kazuhiro4949/SteppedSlider"
```
+ Create framework
```
> carthage update --platform iOS
```

+ In Xcode, move to "Genera > Build Phase > Linked Frameworks and Library"
+ Add the framework to your project
+ Add a new run script and put the following code
```
/usr/local/bin/carthage copy-frameworks
```
+ Click "+" at Input file and Add the framework path
```
$(SRCROOT)/Carthage/Build/iOS/SteppedSlider.framework
```
+ Write Import statement on your source file
```
import SteppedSlider
```

# Usage
SteppedSlider is one of UICnotrol. So you can use it easily.

1. Add View on Storyboard and input SteppedSlider class and module in Custom Class.
<img width="500" src="https://user-images.githubusercontent.com/18320004/91662359-f4fc2b80-eb1c-11ea-9e9f-8e9f4fc0d406.png">

2. Connect IBOutlet to a soruce code
```swift
class ViewController: UIViewController {
    @IBOutlet weak var slider: SteppedSlider!
    //...
}
```

2. Set minimum, maximam and step values like UIStepper

```swift
override func viewDidLoad() {
    //...
    slider.minimumValue = 0
    slider.maximumValue = 5
    slider.stepValue = 1
}
```

3. Set minimum and maximum track images like UISlider (default values are star and star.fill in SF Symbol)
```swift

override func viewDidLoad() {
    //...
    slider.currentMaximumTrackImage = UIImage(systemName: "smiley")
    slider.currentMinimumTrackImage = UIImage(systemName: "smiley.fill")
}
```

4. make Target Action event to SteppedSlider.
```swift
override func viewDidLoad() {
    //...
    slider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
}

@IBAction func stepperValueChanged(_ sender: UIStepper) {
        stepperTextLabel.text = "\(sender.value)"
}
```

That's it.

# License

Copyright (c) 2020 Kazuhiro Hayashi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


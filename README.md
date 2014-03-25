# CoreTextLabel

With CoreTextLabel you are able draw NSAttributedString or HTML with custom font and color in iOS (>= 5.0) applications. 
**numberOfLines** and **truncation** (*NSLineBreakByTruncatingTail*) is also supported.

[![Build Status](https://api.travis-ci.org/appfarms/CoreTextLabel.png)](https://api.travis-ci.org/appfarms/CoreTextLabel.png)

## Example

``` objective-c
    CoreTextLabel * label  = [[CoreTextLabel alloc] initWithFrame:frame];
    label.html             = htmlString;
    [label sizeToFit];
    [self.view addSubview:label];
```

<br style="display: block;" />
<img src="https://raw.github.com/dkuhnke/CoreTextLabel/master/Sample/Screenshot-1.png" style="float: left; margin: 10px;" />
<img src="https://raw.github.com/dkuhnke/CoreTextLabel/master/Sample/Screenshot-2.png" style="float: left; margin: 10px;" />
<br style="display: block;" />

## Install

Add CoreTextLabel pod to your [Podfile](https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile).

```
$ vim Podfile
```

```ruby
platform :ios, '5.0'
pod 'CoreTextLabel', :head
```

And then you [install the dependencies](https://github.com/CocoaPods/CocoaPods/wiki/Creating-a-project-that-uses-CocoaPods) in your project.

```
$ pod install
```

Remember to always open the Xcode workspace instead of the project file when you're building.

```
$ open App.xcworkspace
```

## Requirements

CoreTextLabel 1.0 and higher requires iOS 5.0 and above.

### Framework dependencies

- QuartzCore
- CoreText

### ARC

CoreTextLabel uses ARC.

If you are using CoreTextLabel in your non-arc project, you will need to set a `-fobjc-arc` compiler flag on all of the CoreTextLabel source files.

To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Now select all CoreTextLabel source files, press Enter, insert `-fobjc-arc` or `-fno-objc-arc` and then "Done" to enable or disable ARC for CoreTextLabel.

## Credits

CoreTextLabel was created by [Daniel Kuhnke](https://github.com/appfarms/) for [appfarms GmbH & Co. KG](http://www.appfarms.com)

## License

CoreTextLabel is available under the MIT license. See the LICENSE file for more info.

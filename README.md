CoreTextLabel
=============

Simple UILabel replacement to display NSAttributedString by HTML in iOS applications (>= 3.2).

## Example

``` objective-c
    CoreTextLabel * label  = [[CoreTextLabel alloc] initWithFrame:frame];
    label.string           = [label attributedStringByHTML:htmlString];
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

CoreTextLabel 1.0 and higher requires iOS 3.2 and above.

### Framework dependencies

- QuartzCore
- CoreText

### ARC

CoreTextLabel uses ARC as of its 1.0 release.

If you are using CoreTextLabel 1.0 in your non-arc project, you will need to set a `-fobjc-arc` compiler flag on all of the CoreTextLabel source files.

To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Now select all CoreTextLabel source files, press Enter, insert `-fobjc-arc` or `-fno-objc-arc` and then "Done" to enable or disable ARC for CoreTextLabel.

## Credits

CoreTextLabel was created by [Daniel Kuhnke](https://github.com/dkuhnke/) for [appfarms GmbH & Co. KG](http://www.appfarms.com)


## License

CoreTextLabel is available under the MIT license. See the LICENSE file for more info.
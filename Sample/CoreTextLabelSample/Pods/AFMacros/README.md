# AFMacros

AFMacros brings some handy macros for validation and accessing of common directories or info-plist values

## Example

``` objective-c
    CoreTextLabel * label = (id)@"String"; // Assign object of wrong type
    if (AF_VALID(label, CoreTextLabel)) 
    {
        ZLog(@"%p is valid", label);
    }
    else
    {
        ZLog(@"%p is not valid", label);
    }
	
    NSArray * array = @[@"abc", @"def"]; // Array with two items
    if (AF_VALID_NOTEMPTY(array, NSArray)) 
    {
        ZLog(@"%p is valid and contains at least one object", label);
    }
    else
    {
        ZLog(@"%p is not valid or empty", label);
    }

    // This will print item at index 1
    ZLog(@"Object at index '%d' has value '%@'", 1, AF_ARRAY_OBJECT_AT_INDEX(array, 1));

    // This will print 'nil' for invalid index 99
    ZLog(@"Object at index '%d' has value '%@'", 99, AF_ARRAY_OBJECT_AT_INDEX(array, 99));
```

## Install

Add AFMacros pod to your [Podfile](https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile).

```
$ vim Podfile
```

```ruby
platform :ios, '5.0'
pod 'AFMacros', :head
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

AFMacros 1.0 and higher requires iOS 5.0 and above.

### ARC

AFMacros uses ARC.

If you are using AFMacros in your non-arc project, you will need to set a `-fobjc-arc` compiler flag on all of the AFMacros source files.

To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Now select all AFMacros source files, press Enter, insert `-fobjc-arc` or `-fno-objc-arc` and then "Done" to enable or disable ARC for AFMacros.

## Credits

AFMacros was created by [Daniel Kuhnke](https://github.com/appfarms/) for [appfarms GmbH & Co. KG](http://www.appfarms.com)


## License

AFMacros is available under the MIT license. See the LICENSE file for more info.
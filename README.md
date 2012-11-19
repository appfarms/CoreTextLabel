CoreTextLabel
=============

Simple UILabel replacement to display NSAttributedString in iOS applications.

## Example

``` objective-c
    CGFloat padding = 10.f;
    CGFloat width   = self.view.frame.size.width;
    CGRect frame    = CGRectMake(padding, padding, width-padding*2.f, 800);

    NSString * htmlPath   = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"html"];
    NSString * htmlString = [NSString stringWithContentsOfFile:htmlPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];

    CoreTextLabel * label  = [[CoreTextLabel alloc] initWithFrame:frame];
    label.defaultFontSize  = 20.f;
    label.attributedString = [label attributedStringByHTML:htmlString];
    [label sizeToFit];
    [self.view addSubview:label];
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
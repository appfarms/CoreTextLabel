CoreTextLabel
=============

Simple UILabel replacement to display NSAttributedString in iOS applications

## Requirements

CoreTextLabel 1.0 and higher requires iOS 3.2 and above.

For compatibility with iOS 4.3, use the latest 0.10.x release.

### ARC

CoreTextLabel uses ARC as of its 1.0 release.

If you are using CoreTextLabel 1.0 in your non-arc project, you will need to set a `-fobjc-arc` compiler flag on all of the CoreTextLabel source files.

To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Now select all CoreTextLabel source files, press Enter, insert `-fobjc-arc` or `-fno-objc-arc` and then "Done" to enable or disable ARC for CoreTextLabel.

## Credits

CoreTextLabel was created by [Daniel Kuhnke](https://github.com/dkuhnke/) for [appfarms GmbH & Co. KG](http://www.appfarms.com)


## License

CoreTextLabel is available under the MIT license. See the LICENSE file for more info.
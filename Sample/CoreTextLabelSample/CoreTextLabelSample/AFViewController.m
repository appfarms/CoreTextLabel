//
//  AFViewController.m
//  CoreTextLabelSample
//
//  Created by Daniel Kuhnke on 19.11.12.
//  Copyright (c) 2012 Daniel Kuhnke appfarms GmbH & Co. KG (http://www.appfarms.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//  and associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to
//  do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "AFViewController.h"
#import "CoreTextLabel.h"

@interface AFViewController ()

@end

@implementation AFViewController

- (void) loadView
{
    [super loadView];

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
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

@end

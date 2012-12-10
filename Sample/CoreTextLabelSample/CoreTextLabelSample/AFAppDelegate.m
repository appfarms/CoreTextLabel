//
//  AFAppDelegate.m
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

#import "AFAppDelegate.h"

#import "AFViewController.h"

@implementation AFAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.viewController = [[AFViewController alloc] initWithNibName:@"AFViewController_iPhone" bundle:nil];
    }
    else
    {
        self.viewController = [[AFViewController alloc] initWithNibName:@"AFViewController_iPad" bundle:nil];
    }

    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    nc.navigationBarHidden      = YES;
    
    self.window.rootViewController = nc;
    
    [self.window makeKeyAndVisible];

    return YES;
}

@end

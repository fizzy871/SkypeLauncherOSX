//
//  AppDelegate.m
//  test
//
//  Created by Алексей Саечников on 10.02.14.
//  Copyright (c) 2014 unknown corp. All rights reserved.
//

#import "AppDelegate.h"
#import "skypeLauncher.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [skypeLauncher users];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

@end

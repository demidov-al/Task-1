//
//  AppDelegate.m
//  task_1_OpenGL
//
//  Created by Alexander Demidov on 01.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSSize p = {800, 600};
    [self.window setContentAspectRatio:p];
}

@end

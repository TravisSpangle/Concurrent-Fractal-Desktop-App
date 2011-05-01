//
// IPHONE AND COCOA DEVELOPMENT AUSP10
//	
//  DesktopServiceAppDelegate.h
//	HW5
//
//  Copyright 2010 Chris Parrish
//
// Desktop application that will
// advertise a network service available via bonjour

#import <Cocoa/Cocoa.h>
#import "ApplicationController.h"


@interface DesktopServiceAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow*				window;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ApplicationController* appController;

@end

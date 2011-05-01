//
// IPHONE AND COCOA DEVELOPMENT AUSP10
//	
//  DesktopServiceAppDelegate.m
//	HW5
//
//  Copyright 2010 Chris Parrish
//
// Desktop application that will
// advertise a network service available via bonjour

#import "DesktopServiceAppDelegate.h"

@implementation DesktopServiceAppDelegate

@synthesize window;
@synthesize appController;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [appController startService];
}

- (void)dealloc
{
    [appController release];
    appController = nil;
    
    [super dealloc];
}

@end

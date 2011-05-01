//
// IPHONE AND COCOA DEVELOPMENT AUSP10
//	
//  DesktopServiceAppDelegate.h
//	HW5
//
//  Copyright 2010 Chris Parrish
//
//  App controller is a singleton object

#import <Cocoa/Cocoa.h>
#import "FractalGenerator.h"

@class FractalControl;
@class ListenService;

@interface ApplicationController : NSObject
{
}

@property (assign) IBOutlet NSWindow*               window;
@property (assign) IBOutlet NSTextView*             logTextField;
@property (assign) IBOutlet FractalControl*         fractalControl;
@property (assign) IBOutlet NSProgressIndicator*	progressIndicator;
@property (assign) IBOutlet NSButton*               resetButton;
@property (assign) IBOutlet NSButton*               zoomInButton;
@property (assign) IBOutlet NSButton*               zoomOutButton;

// BONJOUR SERVICE

- (void) startService;
- (void) appendStringToLog:(NSString*)logString;

// ACTIONS

- (IBAction)	resetPressed:(id)sender;
- (IBAction)	zoomInPressed:(id)sender;
- (IBAction)	zoomOutPressed:(id)sender;
- (IBAction)	regionChanged:(id)sender;

@end

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
@class NetworkListener;

@interface ApplicationController : NSObject
{
    NetworkListener *listener_;
    
    NSMutableArray* generators;
    NSOperationQueue *queue;
}

@property (assign) IBOutlet NSWindow*               window;
@property (assign) IBOutlet NSTextView*             logTextField;
@property (assign) IBOutlet FractalControl*         fractalControl;
@property (assign) IBOutlet NSProgressIndicator*	progressIndicator;
@property (assign) IBOutlet NSButton*               resetButton;
@property (assign) IBOutlet NSButton*               cancelButton;
@property (assign) IBOutlet NSButton*               zoomInButton;
@property (assign) IBOutlet NSButton*               zoomOutButton;

// BONJOUR SERVICE
@property (nonatomic, retain) NetworkListener *listener_;
- (void) startService;
- (void) appendStringToLog:(NSString*)logString;

// ACTIONS

- (IBAction)	resetPressed:(id)sender;
- (IBAction)	zoomInPressed:(id)sender;
- (IBAction)	zoomOutPressed:(id)sender;
- (IBAction)	regionChanged:(id)sender;
- (IBAction)    cancelPressed:(id)sender;

@end

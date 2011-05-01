//
// IPHONE AND COCOA DEVELOPMENT AUSP10
//	
//  FractalView.m
//	HW5
//
//  Copyright 2010 Chris Parrish
//
// Class that draws a fractal image and tracks mouse drags
// inside the view to allow 'zooming' in on the displayed fractal
// Adapated from Advanced Mac OS X Programming 
// by Mark Dalrymple and Aaron Hillegass 

#import "FractalControl.h"
#import "FractalGenerator.h"

const			NSRect		kDefaultRegion  = {-2.0, -1.2, 3, 2.4};
	// Start with a nice high-level view of the set


@interface FractalControl () 

- (NSRect)selectedRect;


@end

@implementation FractalControl

@synthesize region = region_;
@synthesize fractalBitmap = fractalBitmap_;
@synthesize target, action, disabled;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.disabled = NO;
		fractalBitmap_ = nil;
		region_ = kDefaultRegion;		
    }
    return self;
}

- (void) dealloc
{
	[fractalBitmap_ release];
	fractalBitmap_ = nil;
	
	[super dealloc];
}


#pragma mark - 
#pragma mark Properties

- (void) setFractalBitmap:(NSBitmapImageRep *)fractalBitmap
{
	if ( fractalBitmap_ == fractalBitmap )
		return;
	
	[fractalBitmap_ release];
	fractalBitmap_ = [fractalBitmap retain];
	[self setNeedsDisplay:YES];
}


- (void) resetToDefaultRegion
{
	self.region = kDefaultRegion;
}

- (void) zoomIn
{
	NSRect region = self.region;
	
	// inset by 20% of the width and height to zoom in
	float delta_x	=	region.size.width * 0.2f;
	float delta_y	=	region.size.height * 0.2f;
	
	self.region = NSInsetRect(region, delta_x, delta_y);
}

- (void) zoomOut
{
	NSRect region = self.region;
	
	// inset by 20% of the width and height to zoom in
	float delta_x	=	region.size.width * 0.2f;
	float delta_y	=	region.size.height * 0.2f;
	
	self.region = NSInsetRect(region, -delta_x, -delta_y);
}

#pragma mark -
#pragma mark NSView

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    
    // Draw a white background
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];
    
	[fractalBitmap_ draw];
    
    // If the user is dragging, show the selected rect
    if (dragging_)
	{
        NSRect box		= [self selectedRect];
		box				= NSIntegralRect(box);
		box.origin.x	= box.origin.x + 0.5f;
		box.origin.y	= box.origin.y + 0.5f;
		
        [[NSColor redColor] set];
		[NSBezierPath strokeRect:box];

		// WHY THE HALF PIXEL?
		// Adjusting the selected rectangle to boundaries that are
		// 1/2 way between points ensures that when we stroke this rectangle 
		// the stroke falls exactly on a pixel boundary, leading to a sharp line
		// if we didn't do this, the line would sometimes be thicker and fuzzy
		// because of anti-aliasing. We will talk about this more in a later class
		
    }
}

- (void)mouseDown:(NSEvent *)event
{
	if ( !self.disabled )
	{
        dragging_ = YES;
        NSPoint p = [event locationInWindow];
        downPoint_ = [self convertPoint:p  fromView:nil];
        currentPoint_ = downPoint_;
	}
}
- (void)mouseDragged:(NSEvent *)event
{
    if (dragging_)
	{
        NSPoint p = [event locationInWindow];
        currentPoint_ = [self convertPoint:p  fromView:nil];
        [self setNeedsDisplay:YES];
    }
}
- (void)mouseUp:(NSEvent *)event
{
    NSRect r, bounds;
    NSRect newRegion;
    if (dragging_)
	{
        dragging_ = NO;
        NSPoint p = [event locationInWindow];
        currentPoint_ = [self convertPoint:p  fromView:nil];
        bounds = [self bounds];
        r = [self selectedRect];
        
        // Calculate newRegion as if in the unit square
        newRegion.origin.x = r.origin.x / bounds.size.width;
        newRegion.origin.y = r.origin.y / bounds.size.height;
        newRegion.size.width = r.size.width /bounds.size.width;
        newRegion.size.height = r.size.height / bounds.size.height;

        // Scale to region's size
        newRegion.origin.x = region_.origin.x + newRegion.origin.x * region_.size.width;
        newRegion.origin.y = region_.origin.y + newRegion.origin.y * region_.size.height;
        newRegion.size.width = region_.size.width * newRegion.size.width;
        newRegion.size.height = region_.size.height * newRegion.size.height;

        self.region = newRegion;        
		[self sendAction:[self action] to:[self target]];
    }
}

- (NSRect)selectedRect
{
    float minX = MIN(downPoint_.x, currentPoint_.x);
    float maxX = MAX(downPoint_.x, currentPoint_.x);
    float minY = MIN(downPoint_.y, currentPoint_.y);
    float maxY = MAX(downPoint_.y, currentPoint_.y);

    return NSMakeRect(minX, minY, maxX-minX,  maxY-minY);
}


@end

//
// IPHONE AND COCOA DEVELOPMENT AUSP10
//	
//  DesktopServiceAppDelegate.h
//	HW5
//
//  Copyright 2010 Chris Parrish
//

#import "ApplicationController.h"
#import "FractalControl.h"
#import "FractalGenerator.h"
#import <mach/mach_time.h>


// Constants and Globals


#pragma mark Private

@interface ApplicationController()


//@property (retain)   ListenService*      listenService;

@property (retain)   NSBitmapImageRep*   fractalBitmap;
@property (assign)   uint64_t            startTime;
@property (assign)   BOOL                fractalInProgress;


- (void) generateFractal;
- (void) fractalOperationCompleted;

- (void) startTiming;
- (float) endTiming;

- (void) updateForGenerationInProgress:(BOOL)inProgress;
- (void) disableControls:(BOOL)disabled;


@end

@implementation ApplicationController

@synthesize window;
@synthesize logTextField, fractalControl, progressIndicator;
@synthesize resetButton, zoomInButton, zoomOutButton;
//@synthesize listenService;
@synthesize fractalBitmap, startTime;
@synthesize fractalInProgress;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.fractalInProgress = NO;
    }
    return self;
}


- (void) dealloc
{
    [fractalBitmap release];
	fractalBitmap = nil;
    
	[super dealloc];	
}


#pragma mark -
#pragma mark Nib Loading

-(void) awakeFromNib
{	
	[self.progressIndicator setHidden:YES];
	[self generateFractal];
}

#pragma mark -
#pragma mark Action


- (IBAction) zoomInPressed:(id)sender
{
	[self.fractalControl zoomIn];
	[self generateFractal];
}

- (IBAction) zoomOutPressed:(id)sender
{
	[self.fractalControl zoomOut];
	[self generateFractal];
}

- (IBAction) resetPressed:(id)sender
{
	[self.fractalControl resetToDefaultRegion];
	[self generateFractal];
}

- (IBAction) regionChanged:(id)sender
{
	[self generateFractal];
}


#pragma mark -
#pragma mark Fractal Computation


- (void) generateFractal
{
    if ( self.fractalInProgress )
    {
        // Guard against starting a new fractal rendering while one
        // is already in progress. If you implement canceling, 
        // you can instead cancel and start or queue up a new generation instead
        return;
    }
    
    [self appendStringToLog:@"New fractal generation starting"];
    self.fractalInProgress = YES;
	
	// start timing and progress indication
	[self startTiming];
	
	// Disable anything that recomputes the fractal
	// while we are working on computing it
		
    [self updateForGenerationInProgress:YES];
    
    // Create 1 generator per row of pixels
    // You can adjust this to fit the model you choose for concurrency
    // Ideas include :
    //   divide bitmap in half and make 2 regions
    //   divide bitmap in some other number of regions 4, 8 , 12?
    //   continue with 1 generator per row
    //   one generator per pixel
    // Each of these had differnet trade offs and benefits
    // and the best choice will also be dependent on how you implement your
    // concurrent solution
    
    NSRect bounds = [self.fractalControl bounds];

    NSInteger pixelsHigh = bounds.size.height;
    NSInteger pixelsWide = bounds.size.width;
    
    NSUInteger rowsPerGenerator = 1;
    NSUInteger generatorCount   = pixelsHigh;
        
    // Create the image rep the threaded generators will draw into
	
	[self.fractalBitmap release];
    self. fractalBitmap = [[NSBitmapImageRep alloc] 
						    initWithBitmapDataPlanes:NULL
						    pixelsWide:pixelsWide
						    pixelsHigh:pixelsHigh
						    bitsPerSample:8 
						    samplesPerPixel:3
						    hasAlpha:NO
						    isPlanar:NO
						    colorSpaceName:NSCalibratedRGBColorSpace
						    bytesPerRow:3*pixelsWide 
						    bitsPerPixel:0];

    // Get the pointer to the raw data
	// Each generator will write pixel data to this shared memory
	// It is 'thread-safe' because we make sure that no two generators
	// are writting to the same region of this bitmap
    unsigned char* bitmap = [self.fractalBitmap bitmapData];
	
    CGFloat maxY = NSMaxY(self.fractalControl.region);
    CGFloat maxX = NSMaxX(self.fractalControl.region);
    CGFloat deltaY = self.fractalControl.region.size.height / pixelsHigh;
    
	// create 1 generator per region
    
    NSMutableArray* generators = [NSMutableArray arrayWithCapacity:generatorCount];
    
    for (int i = 0; i < generatorCount; i++)
	{
		FractalGenerator* generator = [[[FractalGenerator alloc] init] autorelease];
		
		// setup the region the generator will draw into
		generator.minimumX		= self.fractalControl.region.origin.x;
		generator.minimumY		= maxY - deltaY;
		generator.maximumX		= maxX;
		generator.maximumY		= maxY;
		generator.width			= pixelsWide;
		generator.height		= rowsPerGenerator;
		generator.pixelBuffer	= bitmap;
		
        // Move down the image
        maxY = maxY - deltaY;
        
        // Move to next region in bitmapData
        bitmap = bitmap + (pixelsWide * rowsPerGenerator * 3);
        
        [generators addObject:generator];
    }
    

	// HW_TODO : 
	//
	// Change this synchronous, sequential computation that follows
	// to instead use concurrent execution with NSOperations and NSOperationsQueues
	//
    // - Decide how you will divide up the work. How many operations and generators
    //   will you have to compute a fractal?
    //
    
    // - Decide if you want to use NSBlockOperation, NSInvocationOperation or a custom
    //   sub-class of NSOperation
    
 	// - Have each generator perform its fill method
	//   in the operation(s) that you queue
    
	// - Decide how you will know when the generation is complete
    //   options include (but not limited to) :
    //      completion block(s) for block operations
    //      KVO to watch when an operation completes
    //      explicit method call from concurrent operations to note completion
    //      tracking how many generators are running and when it reaches zero, finishsed!
    //   You might have to think about making sure that any UI updates
    //   that happen because of completion should be on the main thread
    //   any properties or methods your operations access on single instances of other
    //   objects like this controller have to be thread-safe
	//

	// - don't update the FractalControl image until all the generators are finished
	
    
	// - Only stop the progress indicator and re-enable the
	//   controls when all the generators have finished 
    //   you don't want to start computing another fractal while one is ongoing
    //   if you do the bonus work, you can handle this better
    //------------------------------------------------------------------------
    
    
    // execute the generators in order, with no concurreny.
    // Note that the main thread will block here!
    
    for ( FractalGenerator* generator in generators)
    {
        [generator fill];
    }
    
    // now update everything since we have finsihed rendering the fractal bitmap
    // this will update the user interface
    
    [self fractalOperationCompleted];
    
}

- (void) fractalOperationCompleted
{    
    self.fractalInProgress = NO;
    
    float millisecondsElapsed = [self endTiming];
    

    [self appendStringToLog:[NSString stringWithFormat:@"Fractal rendering complete %5.2f milliseconds", millisecondsElapsed]];
        
    self.fractalControl.fractalBitmap	= self.fractalBitmap;        

    [self updateForGenerationInProgress:NO];
}



- (void) updateForGenerationInProgress:(BOOL)inProgress
{
    // Disable controls so that we don't try to start a second
    // fractal generation while one is in progress
    
    [self disableControls:inProgress];
    
    [self.progressIndicator setHidden:!inProgress];
    
    if (inProgress)
        [self.progressIndicator startAnimation:nil];
    else
        [self.progressIndicator stopAnimation:nil];
            
}

- (void) disableControls:(BOOL)disabled
{
	self.fractalControl.disabled = disabled;
	[self.zoomInButton setEnabled:!disabled];
	[self.zoomOutButton setEnabled:!disabled];
	[self.resetButton setEnabled:!disabled];
}


- (void) startTiming
{
	self.startTime = mach_absolute_time();
}

- (float) endTiming
{
	mach_timebase_info_data_t info;
	uint64_t end, elapsed;
	mach_timebase_info( &info );
    
	end = mach_absolute_time();
	
	elapsed = end - self.startTime;
	float millis = elapsed * (info.numer / info.denom) * pow(10.0f, -6.0f);
	return millis;
}

#pragma mark -
#pragma mark Service

- (void) appendStringToLog:(NSString*)logString
{
	NSString* newString = [NSString stringWithFormat:@"%@\n", logString];
	[[[self.logTextField textStorage] mutableString] appendString: newString];
	NSUInteger lastPosition = [[self.logTextField string] length];
	[self.logTextField scrollRangeToVisible:NSMakeRange(lastPosition, 1)];
}

- (void) startService
{
    
   	NSLog(@"Start Service is not implemented");
	
	[self appendStringToLog:@"Service is not implemented in this project skeleton!"];
	// HW_TODO :
	// This project skeleton does not have the listen service implemented
	// Provide from your own solution for Homework 3
	// or wait for me to post the solution the HW3 solution
    
	return;
}





@end






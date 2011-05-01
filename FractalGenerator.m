//
// IPHONE AND COCOA DEVELOPMENT AUSP10
//	
//  FractalGenerator.h
//	HW5
//
//  Copyright 2010 Chris Parrish
//
// Class that computes a fractal image
// by providing RGB pixel data for the region of the fractal to be calculated
//
// Adapated from Advanced Mac OS X Programming 
// by Mark Dalrymple and Aaron Hillegass 

#import "FractalGenerator.h"
#import "ApplicationController.h"
#include <complex.h>

// Constants
// 
// Both of these values will influence the display of the fractal image

const				int			kMaximumIterations		=	2000; //300;
	// the number of iterations will influece the coloring of the fractal
	// and how long it take to compute the fractal
const				double		kMagnitudeLimit			=	2.0f;
	// 2 is cited by as a reasonable limit for a good approximation
	// of the limit for the mandlebrot equation
	// adjusting this will effect the color of the fractal 

@interface FractalGenerator ()

- (void) setRGBPixelData:(unsigned char*)pixelBuffer forX:(double)x_value Y:(double)y_value;
- (void) setPixelData:(unsigned char*)buffer forIterations:(int)iterations;
@end


@implementation FractalGenerator

@synthesize minimumX	= minimumX_;
@synthesize minimumY	= minimumY_;
@synthesize maximumX	= maximumX_;
@synthesize maximumY	= maximumY_;
@synthesize width		= width_;
@synthesize height		= height_;
@synthesize pixelBuffer = pixelBuffer_;


- (id) init
{
	self = [super init];
	if (self != nil)
	{
		minimumX_		= 0.0f;
		maximumX_		= 0.0f;
		minimumY_		= 0.0f;
		maximumY_		= 0.0f;
		width_			= 0;
		height_			= 0;
		pixelBuffer_	= 0;
	}
	return self;
}


- (void) fill
{
	
	if ( pixelBuffer_ == nil )
	{
		@throw [NSException exceptionWithName:@"FractalGenerator Exception" reason:@"pixelBuffer can not be nil" userInfo:nil];
	}
	
    unsigned char*	ptr = nil;

	int		x			=	0;
	int		y			=	0;
	float	region_X	=	0.0f;
	float	region_Y	=	0.0f;
        
    // What is the size of the region?
    float	region_W = maximumX_ - minimumX_;
    float	region_H = maximumY_ - minimumY_;
    
    ptr = self.pixelBuffer;
    
    for (y = 0; y < height_; y++)
	{
        // Calculate where on the set this y is
        region_Y = maximumY_ - (region_H * (float)y) / (float)height_;
        for (x = 0; x < width_; x++)
		{
            // Calculate where on the set this x is
            region_X = minimumX_ + (region_W * (float)x) / (float)width_;
            
            // Do the calculation and color the pixel.
            [self setRGBPixelData:ptr forX:region_X Y:region_Y];
            
            // move the next pixel
            ptr += 3;
        }
    }
}


- (void) setRGBPixelData:(unsigned char*)pixelBuffer forX:(double)x_value Y:(double)y_value;
{
    // computing a fractal by interpreting x and y point as a complex number
	// and testing for membership in the mandlebrot set
	//
	// point is assumed to be in the set if its absolute value is greater than 
	// a specificed limit after a maximum number of iterations
	// this an approximation of determining if recursive function 
	// goes to infinity for an infinte number of iterations of the loop
	//
	// coloring comes from points not in the set and how many iterations
	// were required for that point to pass the limit
	
	
    _Complex double z,c;
	
    c = x_value + (y_value * 1.0i);
    z = 0;
    
    for (int i = 0; i < kMaximumIterations; i++)
	{
        z = z * z + c ;
        if ( cabs(z) > kMagnitudeLimit)
		{
            [self setPixelData:pixelBuffer forIterations:i];
            return;
        }
    }
	[self setPixelData:pixelBuffer forIterations:0];
}

// This maps colors to a specific # of iterations of the loop
// before the result of the equation was deemed to go off to infinity
// You can make adjustments here to change the colors displayed
// and adjust the resolution.

- (void) setPixelData:(unsigned char*)buffer forIterations:(int)iterations
{
	const	float		kScaleFactor		= 3.0;
	
    unsigned char *ptr = buffer;
	
	float	red		=	0.0f;
	float	green	=	0.0f;
	float	blue	=	0.0f;
	
	float input = (float)iterations / kMaximumIterations;	
	
	if ( input <= (1.0f / 3.0f) )
	{
		blue = powf(input * kScaleFactor, 0.3333f);
	}
	else if ( input > (1.0f / 3.0f) && input <= (2.0f / 3.0f) )
	{
		green	= powf((input - ( 1.0f / 3.0f )) * kScaleFactor, 0.3333f);
		blue	= 1.0f;
		//blue	= 1.0f / green;	
	}
	else
	{
		red		= powf((input - (2.0f / 3.0f) ) * kScaleFactor, 0.3333f);
		blue	= 1.0f;
		green	= 1.0f;
		//green	= 1.0f / red;
	}
	
	*ptr++		=	MIN(red * 255.0f, 255.0f);
	*ptr++		=	MIN(green * 255.0f, 255.0f);
	*ptr		=	MIN(blue * 255.0f, 255.0f);	
}


@end

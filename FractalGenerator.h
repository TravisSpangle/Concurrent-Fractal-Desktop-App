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

#import <Cocoa/Cocoa.h>


@protocol FractalGeneratorDelegate;

@interface FractalGenerator : NSObject
{
	float				minimumX_;
	float				maximumX_;
	float				minimumY_;
	float				maximumY_;
	int					width_;
	int					height_;
	unsigned char*		pixelBuffer_;
}

@property (nonatomic, assign)	float				minimumX;
@property (nonatomic, assign)	float				minimumY;
@property (nonatomic, assign)	float				maximumX;
@property (nonatomic, assign)	float				maximumY;
@property (nonatomic, assign)	int					width;
@property (nonatomic, assign)	int					height;
@property (nonatomic, assign)	unsigned char*		pixelBuffer;

- (void) fill;
	// fills the pixel buffer with the fractal image
	// using the the min, max, width and height properties set before calling

@end

//
//  Failter.m
//  Anypic
//
//  Created by James Urquhart on 27/07/2012.
//
//

#import "Failter.h"
#import "MagickWand.h"

#define ThrowWandException(wand) { \
char * description; \
ExceptionType severity; \
\
description = MagickGetException(wand,&severity); \
(void) fprintf(stderr, "%s %s %lu %s\n", GetMagickModule(), description); \
description = (char *) MagickRelinquishMemory(description); \
return nil; \
}

@implementation Failter

@synthesize seed;
@synthesize ops;
@synthesize name;

- (id)init{
    if (self = [super init]) {
        current_magick = NULL;
        ops = nil;
    }
    
    return self;
}

-(id) copyWithZone: (NSZone *) zone
{
    Failter *failCopy = [[Failter allocWithZone: zone] init];
    
    failCopy.ops = ops;
    return failCopy;
}

- (id)initWithName:(NSString*)aName operations:(NSArray*)operations
{
    if (self = [super init]) {
        current_magick = NULL;
        self.name = aName;
        self.ops = operations;
    }
    
    return self;
}

+ (id)failterWithRandomOpsCalled:(NSString*)theName
{
    NSMutableArray *ops = [NSMutableArray array];
    
    NSArray *opList = [NSArray arrayWithObjects:@"emboss", @"frame", @"blur", @"motion_blur", @"negate", @"oil",  @"roll", nil];
    
    for (int i=0; i<3; i++) {
        [ops addObject:[opList objectAtIndex:arc4random() % [opList count]]];
    }
    
    Failter *failter = [[Failter alloc] initWithName:(theName) operations:ops];
    failter.seed = arc4random();
    return failter;
}


+ (id)failterWithOps:operations called:(NSString*)theName
{
    Failter *failter = [[Failter alloc] initWithName:theName operations:operations];
    return failter;
}

CGImageRef createStandardImage(CGImageRef image, void **out_data) {
	const size_t width = CGImageGetWidth(image);
	const size_t height = CGImageGetHeight(image);
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    void *data = malloc(width*height*4);
    *out_data = data;
	CGContextRef ctx = CGBitmapContextCreate(data, width, height, 8, 4*width, space,
											 kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(space);
	CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), image);
	CGImageRef dstImage = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return dstImage;
}


- (UIImage*)applyToImage:(UIImage*)image
{
    CGImageRef srcCGImage = [image CGImage];
	const unsigned long width = CGImageGetWidth(srcCGImage);
	const unsigned long height = CGImageGetHeight(srcCGImage);
    
    void *bytes = NULL;
	const char *map = "ARGB"; // hard coded
	const StorageType inputStorage = CharPixel;
	CGImageRef standardized = createStandardImage(srcCGImage, &bytes);
    
	MagickWandGenesis();
	MagickWand * magick_wand_local= NewMagickWand();
    current_magick = magick_wand_local;
	MagickBooleanType status = MagickConstituteImage(magick_wand_local, width, height, map, inputStorage, bytes);
	if (status == MagickFalse) {
		ThrowWandException(magick_wand_local);
	}
    
    // Perform filters
    srand(seed);
    for (NSString *method in ops) {
        SEL selector = NSSelectorFromString(method);
        [self performSelector:selector];
    }
    
    // Output to image
	const int bitmapBytesPerRow = (width * strlen(map));
	const int bitmapByteCount = (bitmapBytesPerRow * height);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	char *trgt_image = malloc(bitmapByteCount);
	status = MagickExportImagePixels(magick_wand_local, 0, 0, width, height, map, CharPixel, trgt_image);
	if (status == MagickFalse) {
		ThrowWandException(magick_wand_local);
	}
	magick_wand_local = DestroyMagickWand(magick_wand_local);
	MagickWandTerminus();
    
	CGImageRelease(standardized); free(bytes);
	CGContextRef context = CGBitmapContextCreate (trgt_image,
												  width,
												  height,
												  8, // bits per component
												  bitmapBytesPerRow,
												  colorSpace,
												  kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);
	CGImageRef cgimage = CGBitmapContextCreateImage(context);
	
    
    UIImage *outImage = [[UIImage alloc] initWithCGImage:cgimage];
	CGImageRelease(cgimage);
	CGContextRelease(context);
	free(trgt_image);
	return outImage;
}

- (void)emboss
{
    MagickEmbossImage(current_magick, 1.0, 0.0);
}

- (void)frame
{
    PixelWand *p_wand = NewPixelWand();
    PixelSetColor(p_wand, "0xcccccc");
    MagickFrameImage(current_magick, p_wand, 25, 25, 6, 6);
}

- (void)blur
{
    MagickGaussianBlurImage(current_magick, 0.0, 3.0);
}

- (void)motion_blur
{
    MagickMotionBlurImage(current_magick, 0.0, 2.0, (rand()/(float)INT_MAX));
}

- (void)negate
{
    MagickNegateImage(current_magick, false);
}

- (void)oil
{
    MagickOilPaintImage(current_magick, (rand()/(float)INT_MAX) + 0.5);
}

- (void)dither
{
    OrderedDitherImage(current_magick);
}

- (void)roll
{
    MagickRollImage(current_magick, rand()%256, rand()%256);
}

@end

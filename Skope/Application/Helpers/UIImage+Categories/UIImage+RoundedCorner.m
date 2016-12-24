// UIImage+RoundedCorner.m
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"

@implementation UIImage (RoundedCorner)

// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a transparent border of the given size will also be added
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    CGFloat scale = MAX(self.scale,1.0f);
    NSUInteger scaledBorderSize = borderSize * scale;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 image.size.width*scale,
                                                 image.size.height*scale,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
    
    // Create a clipping path with rounded corners
    
    CGContextBeginPath(context);
    [self addRoundedRectToPath:CGRectMake(scaledBorderSize, scaledBorderSize, image.size.width*scale - borderSize * 2, image.size.height*scale - borderSize * 2)
                       context:context
                     ovalWidth:cornerSize*scale
                    ovalHeight:cornerSize*scale];
    CGContextClosePath(context);
    CGContextClip(context);
    
    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width*scale, image.size.height*scale), image.CGImage);
    
    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a UIImage from the CGImage
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage scale:self.scale orientation:UIImageOrientationUp];
    
    CGImageRelease(clippedImage);
    
    return roundedImage;
}

#pragma mark -
#pragma mark Private helper methods

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

-(UIImage *)imageByCenterSquareCircleImageToFitSquare:(float)square_edge_length  borderWidth:(CGFloat)border_width borderColor:(UIColor*)color
{
    CGSize squareSize = (self.size.height > self.size.width)?CGSizeMake(self.size.width, self.size.width):CGSizeMake(self.size.height, self.size.height);
    const CGSize size = self.size;
    CGFloat x, y;
    x = (size.width - squareSize.width) * 0.5f;
    y = (size.height - squareSize.height) * 0.5f;
    if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored || self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored)
    {
        CGFloat temp = x;
        x = y;
        y = temp;
    }
    
    CGRect cropRect = CGRectMake(x * self.scale, y * self.scale, squareSize.width * self.scale, squareSize.height * self.scale);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage* squareImage = [UIImage imageWithCGImage:croppedImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(croppedImageRef);
    
    //Crop image
    CGSize newsize = CGSizeMake(ceilf(square_edge_length), ceilf(square_edge_length));
    UIGraphicsBeginImageContextWithOptions(newsize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, ceilf(square_edge_length)/2, ceilf(square_edge_length)/2, ceilf(square_edge_length)/2, 0, 2*M_PI, YES);
    CGContextClip (context);
    CGContextSaveGState(context);
    [squareImage drawInRect:CGRectMake(border_width/2, border_width/2, ceilf(square_edge_length)-border_width,ceilf(square_edge_length)-border_width)];
    
    UIGraphicsEndImageContext();
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, squareImage.size.width, squareImage.size.height);
    imageLayer.contents = (id) squareImage.CGImage;
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = MIN(squareImage.size.height/2,squareImage.size.width/2);
    imageLayer.borderWidth = border_width;
    imageLayer.borderColor = color.CGColor;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(squareImage.size, NO, 0.0f);
    } else {
        UIGraphicsBeginImageContext(squareImage.size);
    }
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    /*
     //Add stroke for context
     CGContextSetLineCap(context, kCGLineCapRound);
     CGContextSetLineWidth(context, border_width);
     CGContextSetAllowsAntialiasing(context, YES);
     CGContextSetShouldAntialias(context, YES);
     CGContextSetStrokeColorWithColor(context,color.CGColor);
     CGContextBeginPath(context);
     CGContextAddArc(context, ceilf(square_edge_length)/2, ceilf(square_edge_length)/2, ceilf(square_edge_length)/2, 0, 2*M_PI, YES);
     CGContextStrokePath(context);
     UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     */
    
    return roundedImage;
    
}

-(UIImage *)imageByCenterSquareCornerImageToFitSquare:(float)square_edge_length  borderWidth:(CGFloat)border_width borderColor:(UIColor*)color radius:(float)radius
{
    
    CGSize squareSize = (self.size.height > self.size.width)?CGSizeMake(self.size.width, self.size.width):CGSizeMake(self.size.height, self.size.height);
    const CGSize size = self.size;
    CGFloat x, y;
    x = (size.width - squareSize.width) * 0.5f;
    y = (size.height - squareSize.height) * 0.5f;
    if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored || self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored)
    {
        CGFloat temp = x;
        x = y;
        y = temp;
    }
    CGRect cropRect = CGRectMake(x * self.scale, y * self.scale, squareSize.width * self.scale, squareSize.height * self.scale);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage* squareImage = [UIImage imageWithCGImage:croppedImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(croppedImageRef);
    
    //Crop image
    CGSize newsize = CGSizeMake(square_edge_length, square_edge_length);
    UIGraphicsBeginImageContextWithOptions(newsize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClip (context);
    CGContextSaveGState(context);
    [squareImage drawInRect:CGRectMake(border_width/2, border_width/2, ceilf(square_edge_length)-border_width,ceilf(square_edge_length)-border_width)];
    squareImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, squareImage.size.width, squareImage.size.height);
    imageLayer.contents = (id) squareImage.CGImage;
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = (radius<squareImage.size.width/2 && radius<squareImage.size.height/2)?radius:((squareImage.size.width>squareImage.size.height)?squareImage.size.height/2:squareImage.size.width/2);
    imageLayer.borderWidth = border_width;
    imageLayer.borderColor = color.CGColor;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(squareImage.size, NO, 0.0f);
    } else {
        UIGraphicsBeginImageContext(squareImage.size);
    }
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundedImage;
}

-(UIImage *)imageByRoundedImageWithborderWidth:(CGFloat)border_width borderColor:(UIColor*)color radius:(float)radius
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    imageLayer.contents = (id) self.CGImage;
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = (radius<self.size.width/2 && radius<self.size.height/2)?radius:((self.size.width>self.size.height)?self.size.height/2:self.size.width/2);
    imageLayer.borderWidth = border_width;
    imageLayer.borderColor = color.CGColor;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    } else {
        UIGraphicsBeginImageContext(self.size);
    }
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundedImage;
}

@end

//
//  UIImage+Resize.m
//  XNYImagesKit
//
//  Created by @XNY0uf on 02/05/11.
//  Copyright 2012 XNY0uf. All rights reserved.
//  www.cocoaintheshell.com
//


#import "UIImage+Resizing.h"


@implementation UIImage (Resizing)

-(UIImage*)cropToSize:(CGSize)newSize usingMode:(XNYCropMode)cropMode
{
    float imageScaleFactor = 1.0;
	if ([self respondsToSelector:@selector(scale)]) {
		imageScaleFactor = [self scale];
	}
	float sourceWidth = [self size].width ;//* imageScaleFactor;
	float sourceHeight = [self size].height ;//* imageScaleFactor;
	const CGSize source_size = CGSizeMake(sourceWidth, sourceHeight);
    const CGSize redraw_Size = CGSizeMake(newSize.width, newSize.height);
	CGFloat x, y;
	switch (cropMode)
	{
		case XNYCropModeTopLeft:
			x = y = 0.0f;
			break;
		case XNYCropModeTopCenter:
			x = (source_size.width - redraw_Size.width) * 0.5f;
			y = 0.0f;
			break;
		case XNYCropModeTopRight:
			x = source_size.width - redraw_Size.width;
			y = 0.0f;
			break;
		case XNYCropModeBottomLeft:
			x = 0.0f;
			y = source_size.height - redraw_Size.height;
			break;
		case XNYCropModeBottomCenter:
			x = (source_size.width - redraw_Size.width) * 0.5f;
			y = source_size.height - redraw_Size.height;
			break;
		case XNYCropModeBottomRight:
			x = source_size.width - redraw_Size.width;
			y = source_size.height - redraw_Size.height;
			break;
		case XNYCropModeLeftCenter:
			x = 0.0f;
			y = (source_size.height - redraw_Size.height) * 0.5f;
			break;
		case XNYCropModeRightCenter:
			x = source_size.width - redraw_Size.width;
			y = (source_size.height - redraw_Size.height) * 0.5f;
			break;
		case XNYCropModeCenter:
			x = (source_size.width - redraw_Size.width) * 0.5f;
			y = (source_size.height - redraw_Size.height) * 0.5f;
			break;
		default: // Default to top left
			x = y = 0.0f;
			break;
	}
    
	if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored || self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored)
	{
		CGFloat temp = x;
		x = y;
		y = temp;
	}
    
	CGRect redrawRect = CGRectMake(x * self.scale, y * self.scale, redraw_Size.width * self.scale, redraw_Size.height * self.scale);
    CGRect gettingRect = CGRectMake(0, 0, newSize.width, newSize.height);
    
    // Create appropriately modified image.
	UIImage *image = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	CGImageRef sourceImg = nil;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(gettingRect.size, NO, 0.f); // 0.f for scale means "scale for device's main screen".
		sourceImg = CGImageCreateWithImageInRect([self CGImage], redrawRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg scale:self.scale orientation:self.imageOrientation]; // create cropped UIImage.
		
	} else {
		UIGraphicsBeginImageContext(gettingRect.size);
		sourceImg = CGImageCreateWithImageInRect([self CGImage], redrawRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg]; // create cropped UIImage.
	}
	CGImageRelease(sourceImg);
	//[image drawInRect:gettingRect]; // the actual scaling happens here, and orientation is taken care of automatically.
	//image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
#endif
	if (!image) {
		// Try older method.
        CGImageRef sourceImg = CGImageCreateWithImageInRect([self CGImage], redrawRect);
		image = [UIImage imageWithCGImage:sourceImg scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(sourceImg);
        
	}
    return image;
}

/* Convenience method to crop the image from the top left corner */
-(UIImage*)cropToSize:(CGSize)newSize
{
	return [self cropToSize:newSize usingMode:XNYCropModeTopLeft];
}

-(UIImage*)scaleByFactor:(float)scaleFactor
{
	CGSize scaledSize = CGSizeMake(self.size.width * scaleFactor, self.size.height * scaleFactor);
	return [self scaleToFillSize:scaledSize];
}

-(UIImage*)scaleToSize:(CGSize)newSize usingMode:(XNYResizeMode)resizeMode
{
	switch (resizeMode)
	{
		case XNYResizeModeAspectFit:
			return [self scaleToAspectFitSize:newSize];
		case XNYResizeModeAspectFill:
			return [self scaleToAspectFillSize:newSize];
		default:
			return [self scaleToFillSize:newSize];
	}
}

/* Convenience method to scale the image using the XNYResizeModeScaleToFill mode */
-(UIImage*)scaleToSize:(CGSize)newSize
{
	return [self scaleToFillSize:newSize];
}

-(UIImage*)scaleToFillSize:(CGSize)newSize
{
    float imageScaleFactor = 1.0;
	if ([self respondsToSelector:@selector(scale)]) {
		imageScaleFactor = [self scale];
	}
	float sourceWidth = [self size].width * imageScaleFactor;
	float sourceHeight = [self size].height * imageScaleFactor;
    
    size_t gettingWidth = (size_t)(newSize.width);
	size_t gettingHeight = (size_t)(newSize.height);
	if (self.imageOrientation == UIImageOrientationLeft
		|| self.imageOrientation == UIImageOrientationLeftMirrored
		|| self.imageOrientation == UIImageOrientationRight
		|| self.imageOrientation == UIImageOrientationRightMirrored)
	{
		size_t temp = gettingWidth;
		gettingWidth = gettingHeight;
		gettingHeight = temp;
	}
    
	// Calculate compositing rectangles
    CGRect redrawRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
    CGRect gettingRect = CGRectMake(0, 0, gettingWidth, gettingHeight);
    
	// Create appropriately modified image.
	UIImage *image = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	CGImageRef sourceImg = nil;
	if ([UIScreen instancesRespondToSelector:@selector(scale)])
    {
		UIGraphicsBeginImageContextWithOptions(gettingRect.size, NO, 0.0f); // 0.f for scale means "scale for device's main screen".
		sourceImg = CGImageCreateWithImageInRect([self CGImage], redrawRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:self.imageOrientation]; // create cropped UIImage.
	} else {
        UIGraphicsBeginImageContext(gettingRect.size);
		sourceImg = CGImageCreateWithImageInRect([self CGImage], redrawRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg]; // create cropped UIImage.
	}
	CGImageRelease(sourceImg);
	[image drawInRect:gettingRect]; // the actual scaling happens here, and orientation is taken care of automatically.
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
#endif
	if (!image) {
        gettingWidth *= imageScaleFactor;
        gettingHeight *= imageScaleFactor;
        CGContextRef context = CGBitmapContextCreate(NULL, gettingWidth, gettingHeight, 8, (gettingWidth * kNyxNumberOfComponentsPerARBGPixel),CGImageGetColorSpace(self.CGImage),NYXImageHasAlpha(self.CGImage));//XNYCreateARGBBitmapContext(destWidth*imageScaleFactor, destHeight*imageScaleFactor, imageScaleFactor * destWidth * kNyxNumberOfComponentsPerARBGPixel, XNYImageHasAlpha(self.CGImage));
        if (!context)
            return nil;
        
        CGContextSetShouldAntialias(context, true);
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        
        UIGraphicsPushContext(context);
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, gettingWidth, gettingHeight), self.CGImage);
        UIGraphicsPopContext();
        CGImageRef scaledImageRef = CGBitmapContextCreateImage(context);
        image = [UIImage imageWithCGImage:scaledImageRef scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(scaledImageRef);
        CGContextRelease(context);
	}
	return image;
}

-(UIImage*)scaleToAspectFitSize:(CGSize)newSize
{
    return [self scaleToAspectFitSize:newSize upScale:YES];
}

-(UIImage*)scaleToAspectFitSize:(CGSize)newSize upScale:(BOOL)upscale
{
    CGSize originalSize = self.size;
    float Aspect_ratio = originalSize.width/originalSize.height;
	/// Keep aspect ratio
	size_t destWidth, destHeight;
	if (originalSize.width > originalSize.height)
	{
		destWidth = (size_t)newSize.width;
		destHeight = (size_t)(newSize.width/Aspect_ratio);
	}
	else
	{
		destHeight = (size_t)newSize.height;
		destWidth = (size_t)(newSize.height*Aspect_ratio);
	}
	if (destWidth > newSize.width)
	{
		destWidth = (size_t)newSize.width;
		destHeight = (size_t)(newSize.width/Aspect_ratio);
	}
	if (destHeight > newSize.height)
	{
		destHeight = (size_t)newSize.height;
		destWidth = (size_t)(newSize.height*Aspect_ratio);
	}
    float scale_ratio = MIN((destWidth/originalSize.width), (destHeight/originalSize.height));
    if (!upscale) {
        scale_ratio = MIN(scale_ratio, 1);
    }
	return [self scaleToFillSize:CGSizeMake(scale_ratio*originalSize.width, scale_ratio*originalSize.height)];
}

-(UIImage*)scaleToAspectFillSize:(CGSize)newSize
{
	size_t destWidth, destHeight;
	CGFloat widthRatio = newSize.width / self.size.width;
	CGFloat heightRatio = newSize.height / self.size.height;
	/// Keep aspect ratio
	if (heightRatio > widthRatio)
	{
		destHeight = (size_t)newSize.height;
		destWidth = (size_t)(self.size.width * newSize.height / self.size.height);
	}
	else
	{
		destWidth = (size_t)newSize.width;
		destHeight = (size_t)(self.size.height * newSize.width / self.size.width);
	}
	return [self scaleToFillSize:CGSizeMake(destWidth, destHeight)];
}

@end

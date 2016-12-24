//
//  UIImage+Resize.h
//  XNYImagesKit
//
//  Created by @XNY0uf on 02/05/11.
//  Copyright 2012 XNY0uf. All rights reserved.
//  www.cocoaintheshell.com
//


#import "NYXImagesHelper.h"


typedef enum
{
	XNYCropModeTopLeft,
	XNYCropModeTopCenter,
	XNYCropModeTopRight,
	XNYCropModeBottomLeft,
	XNYCropModeBottomCenter,
	XNYCropModeBottomRight,
	XNYCropModeLeftCenter,
	XNYCropModeRightCenter,
	XNYCropModeCenter
} XNYCropMode;

typedef enum
{
	XNYResizeModeScaleToFill,
	XNYResizeModeAspectFit,
	XNYResizeModeAspectFill
} XNYResizeMode;


@interface UIImage (Resizing)

-(UIImage*)cropToSize:(CGSize)newSize usingMode:(XNYCropMode)cropMode;

// XNYCropModeTopLeft crop mode used
-(UIImage*)cropToSize:(CGSize)newSize;

-(UIImage*)scaleByFactor:(float)scaleFactor;

-(UIImage*)scaleToSize:(CGSize)newSize usingMode:(XNYResizeMode)resizeMode;

// XNYResizeModeScaleToFill resize mode used
-(UIImage*)scaleToSize:(CGSize)newSize;

// Same as 'scale to fill' in IB. Not preserves aspect ratio
-(UIImage*)scaleToFillSize:(CGSize)newSize;

// Same as 'aspect fill' in IB. Preserves aspect ratio.
-(UIImage*)scaleToAspectFillSize:(CGSize)newSize;

// Preserves aspect ratio. Same as 'aspect fit' in IB.
-(UIImage*)scaleToAspectFitSize:(CGSize)newSize;

// UpScale=NO => just scale down size
-(UIImage*)scaleToAspectFitSize:(CGSize)newSize upScale:(BOOL)upscale;

@end

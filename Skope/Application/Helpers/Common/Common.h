//
//  Common.h
//  Skope
//
//  Created by CHAU HUYNH on 2/11/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface Common : NSObject
void runOnMainQueueWithoutDeadlocking(void (^block)(void));

+ (NSOperationQueue*)sharedBackgroundOperationQueue;
+ (NSOperationQueue*)sharedBackgroundSerialOperationQueue;
+ (NSOperationQueue*)MAIN_QUEUE;

//===Delete file in application Doc

+ (void)removeFile:(NSURL*)url;
+ (void)removeFileFromAppDirectoryAtPath:(NSString*)videoPath;


//===UIView process

+ (void) circleImageView:(UIView *) imgV;
+ (void) circleImageView:(UIView *)imgV borderWidth:(CGFloat)borderWidth;
+ (void) cornerRadiusForView:(UIView *)view topLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius;
+ (void) cornerRadiusForView:(UIView *)view radius:(float) radius;
+ (void) changeYposisionForView:(UIView *)view Yposision:(float) y;
+ (void) changeXposisionForView:(UIView *)view Xposision:(float) x;
+ (void) changeWidthForView:(UIView *)view width:(float) width;
+ (void) changeHeightForView:(UIView *)view height:(float) height;
+ (void) changeXYForView:(UIView *)view Xpossiosion:(CGFloat)x Xpossiosion:(CGFloat)y;
+ (void) changeSizeForView:(UIView *)view width:(CGFloat)width height:(CGFloat)height;

//===TestSize calculator

+ (CGFloat) getHeightOfText:(NSString*)string widthConstraint:(CGFloat)width font:(UIFont *)font;
+ (CGFloat) getHeightString:(NSString*)string withAttribute:(NSDictionary*)attr widthConstraint:(CGFloat)width;
+ (CGFloat) getHeightAttrString:(NSAttributedString*)attrStr widthConstraint:(CGFloat)width;


//===AlertView and progressHUD

+ (void) showAlertView:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle arrayTitleOtherButtons:(NSArray *)arrayTitleOtherButtons tag:(int)tag;
+ (void) showNetworkActivityIndicator;
+ (void) hideNetworkActivityIndicator;
+ (void) showLoadingViewGlobal:(NSString *) titleaLoading;
+ (void) hideLoadingViewGlobal;


//===Networking Animation

+ (AFHTTPRequestOperationManager *)AFHTTPRequestOperationManagerReturn;
+ (void) requestSuccessWithReponse:(id)result didFinish:(void(^)(BOOL success, NSMutableDictionary *object))block;
+ (BOOL) validateResponse:(id) response;
+ (BOOL) validateLocationCoordinate2DIsValid:(CLLocationCoordinate2D) coordinate;

+ (NSInteger) responseStatusCode:(id) response;
+ (NSString*) errorMessageFromResponseObject:(id)response;
+ (CLLocationCoordinate2D) get2DCoordFromString:(NSString*)coordString;
+ (CGFloat) kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to;
+ (CGFloat) metersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to;
+ (NSString*) convertTimeStampToDate:(double) unixTimeStamp;

+ (NSMutableDictionary*) mutableResponseDataFromResponseData:(id)response;

+ (UIImage*) imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original;
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

+ (NSString*)hiddenName:(NSString*)fullname;

//  Layers Animations

+ (void) addPopAnimationToLayer:(CALayer *)aLayer withBounce:(CGFloat)bounce damp:(CGFloat)damp;

@end

//
//  Common.m
//  Skope
//
//  Created by CHAU HUYNH on 2/11/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "Common.h"


@implementation Common

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


+ (NSOperationQueue*)sharedBackgroundOperationQueue {
    
    static NSOperationQueue* _background_concurrent_queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _background_concurrent_queue = [[NSOperationQueue alloc] init];
        //_defaultQueue.maxConcurrentOperationCount = 100;
    });
    return _background_concurrent_queue;
}

+ (NSOperationQueue*)sharedBackgroundSerialOperationQueue {
    
    static NSOperationQueue* _background_serial_queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _background_serial_queue = [[NSOperationQueue alloc] init];
        _background_serial_queue.maxConcurrentOperationCount = 1;
    });
    return _background_serial_queue;
}

+ (NSOperationQueue*)MAIN_QUEUE {
    
    return [NSOperationQueue mainQueue];
}

//===Delete file in application Doc

+ (void)removeFile:(NSURL*)url {
    
    NSString *videoPath = [url path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:videoPath]) {
        NSError *error;
        //NSString *folderPath = [videoPath stringByDeletingLastPathComponent];
        if ([fileManager removeItemAtPath: /*[videoPath stringByDeletingLastPathComponent]*/ videoPath error: &error] != YES) {
            //NSLog(@"Unable to delete file: %@ \nError: %@", videoPath,[error localizedDescription]);
        } else {
            //NSLog(@"Deleted file: %@",videoPath);
        }
    }
}

+ (void)removeFileFromAppDirectoryAtPath:(NSString*)videoPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *prefixToRemove = @"file:";
    if ([videoPath hasPrefix:prefixToRemove])
        videoPath = [videoPath substringFromIndex:[prefixToRemove length]];
    
    if ([fileManager fileExistsAtPath:videoPath]) {
        NSError *error;
        if ([fileManager removeItemAtPath: videoPath error: &error] != YES) {
            //NSLog(@"Unable to delete file: %@ \nError: %@", videoPath,[error localizedDescription]);
        } else {
            //NSLog(@"Deleted file: %@",videoPath);
        }
    }
}


+ (void)cornerRadiusForView:(UIView *)view topLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
    
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; //holds the corner
        //Determine which corner(s) should be changed
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        roundedView.layer.mask = maskLayer;
        view = roundedView;
    }
}

+ (void) cornerRadiusForView:(UIView *) view radius:(float) radius {
    
    view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
}

+ (void) circleImageView:(UIView *) imgV {
    
    [Common circleImageView:imgV borderWidth:3.0];
}

+ (void) circleImageView:(UIView *)imgV borderWidth:(CGFloat)borderWidth {
    
    imgV.layer.cornerRadius = imgV.frame.size.width / 2;
    imgV.clipsToBounds = YES;
    imgV.layer.borderWidth = borderWidth;
    imgV.layer.borderColor = [UIColor whiteColor].CGColor;
    imgV.contentMode = UIViewContentModeScaleAspectFill;
}

+ (CGFloat) getHeightOfText:(NSString*)string widthConstraint:(CGFloat)width font:(UIFont *)font {
    
    if (string.length == 0) {
        return 0;
    }
    
    CGSize constrainedSize = CGSizeMake(width, CGFLOAT_MAX);

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1; // <--- magic line spacing here!
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          paragraphStyle, NSParagraphStyleAttributeName,
                                          nil];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributesDictionary];
    
    CGRect requiredHeight = [attrString boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
   
    if (requiredHeight.size.width > width) {
        requiredHeight = CGRectMake(0, 0, width, requiredHeight.size.height);
    }
    
    float height_text = requiredHeight.size.height;
    
    return height_text;
}



+ (CGFloat) getHeightString:(NSString*)string withAttribute:(NSDictionary*)attr widthConstraint:(CGFloat)width {
    
    CGSize constrainedSize = CGSizeMake(width, CGFLOAT_MAX);
    
    if (string.length == 0) {
        return 0;
    }
    
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:string attributes:attr];
    return [attributeString boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
}

+ (CGFloat) getHeightAttrString:(NSAttributedString*)attrStr widthConstraint:(CGFloat)width {
    
    CGSize constrainedSize = CGSizeMake(width, CGFLOAT_MAX);
    return [attrStr boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
}

+ (void) showAlertView:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle arrayTitleOtherButtons:(NSArray *)arrayTitleOtherButtons tag:(int)tag {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    alert.tag = tag;
    
    if([arrayTitleOtherButtons count] > 0) {
        for (int i = 0; i < [arrayTitleOtherButtons count]; i++) {
            [alert addButtonWithTitle:arrayTitleOtherButtons[i]];
        }
    }
    
    [alert show];
}

+ (void) showLoadingViewGlobal:(NSString *) titleaLoading {
    
    if (titleaLoading != nil) {
        [SVProgressHUD showWithStatus:titleaLoading maskType:SVProgressHUDMaskTypeGradient];
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    }
}

+ (void) showNetworkActivityIndicator {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (void) hideNetworkActivityIndicator {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (void) hideLoadingViewGlobal {
    
    [SVProgressHUD dismiss];
}

+ (void) changeYposisionForView:(UIView *)view Yposision:(float) y {
    
    CGRect frameT = view.frame;
    frameT.origin.y = y;
    view.frame = frameT;
}

+ (void) changeXposisionForView:(UIView *)view Xposision:(float) x {
    
    CGRect frameT = view.frame;
    frameT.origin.x = x;
    view.frame = frameT;
}

+ (void) changeWidthForView:(UIView *)view width:(float) width {
    
    CGRect frameT = view.frame;
    frameT.size.width = width;
    view.frame = frameT;
}

+ (void) changeHeightForView:(UIView *)view height:(float) height {
    
    CGRect frameT = view.frame;
    frameT.size.height = height;
    view.frame = frameT;
}

+ (void) changeXYForView:(UIView *)view Xpossiosion:(CGFloat)x Xpossiosion:(CGFloat)y {
    
    CGRect frameT = view.frame;
    frameT.origin.x = x;
    frameT.origin.y = y;
    view.frame = frameT;
}
+ (void) changeSizeForView:(UIView *)view width:(CGFloat)width height:(CGFloat)height {
    
    CGRect frameT = view.frame;
    frameT.size.width = width;
    frameT.size.height = height;
    view.frame = frameT;
}

+ (AFHTTPRequestOperationManager *)AFHTTPRequestOperationManagerReturn {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager.requestSerializer setTimeoutInterval:30];
    return manager;
}

+ (void) requestSuccessWithReponse:(id)result didFinish:(void(^)(BOOL success, NSMutableDictionary *object))block
{
    
    if (!result) {
        block(NO,nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSIndexSet *acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
        
        NSMutableDictionary *mutableResponseObject = [Common mutableResponseDataFromResponseData:result];
        
        if ([mutableResponseObject[@"meta"][@"code"] isEqual:[NSNull null]] || ![acceptableStatusCodes containsIndex:[mutableResponseObject[@"meta"][@"code"] intValue]] ) {
            
            runOnMainQueueWithoutDeadlocking(^{
                
                block(NO,mutableResponseObject);
                
            });
    
        } else {
            
            runOnMainQueueWithoutDeadlocking(^{
                
                block(YES,mutableResponseObject);
                
            });
            
        }
        
    });

}

+ (NSString*)errorMessageFromResponseObject:(id)response {
    
    NSDictionary *dicdata = response[@"data"];
    if (dicdata) {
        if (![dicdata[@"message"] isEqual:[NSNull null]] && dicdata[@"message"]) {
            return dicdata[@"message"];
        }
    }
    return nil;
}

+ (BOOL) validateResponse:(id) response {
    
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dicMeta = response[@"meta"];
        NSIndexSet *acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
        
        if (dicMeta) {
            
            if ([acceptableStatusCodes containsIndex:[dicMeta[@"code"] intValue]]) {
                
                return YES;
            }
            
        }
        
    }
        
    return NO;

}

+ (NSInteger) responseStatusCode:(id) response {
    
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dicMeta = response[@"meta"];
        return [dicMeta[@"code"] intValue];
        
    } else {
        
        return 400;
        
    }
}

+ (BOOL) validateLocationCoordinate2DIsValid:(CLLocationCoordinate2D) coordinate {
    
    if (CLLocationCoordinate2DIsValid(coordinate) && (coordinate.latitude != 0 && coordinate.longitude != 0 )) {
        return YES;
    }
    return NO;
}

+ (CLLocationCoordinate2D) get2DCoordFromString:(NSString*)coordString
{
    CLLocationCoordinate2D location;
    NSArray *coordArray = [coordString componentsSeparatedByString: @","];
    location.latitude = ((NSNumber *)coordArray[0]).doubleValue;
    location.longitude = ((NSNumber *)coordArray[1]).doubleValue;
    
    return location;
}

+(CGFloat)kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to  {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userloc distanceFromLocation:dest]/1000;

    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
    
}

+(CGFloat)metersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to  {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userloc distanceFromLocation:dest];

    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
    
}

+ (NSMutableDictionary *)mutableResponseDataFromResponseData:(id)response {
    
    NSMutableDictionary *data ;
    
    if ([response isKindOfClass:[NSData class]]) {
        data = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
    }else{
        NSData *convertData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
        data = [NSJSONSerialization JSONObjectWithData:convertData options:NSJSONReadingMutableContainers error:nil];
    }
    
    return data;
}

+ (NSString *) convertTimeStampToDate:(double) unixTimeStamp {
    
    NSTimeInterval timeInterval=unixTimeStamp/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}

+ (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:original];
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    // Draw your image
    [original drawInRect:imageView.bounds];
    
    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageView.image;
}


+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetIG =
    [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *igError = nil;
    thumbnailImageRef =
    [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                    actualTime:NULL
                         error:&igError];
    
    if (!thumbnailImageRef) {
        
        NSLog(@"thumbnailImageGenerationError %@", igError );
        
    }
    
    UIImage *thumbnailImage = thumbnailImageRef
    ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
    : nil;
    
    return thumbnailImage;
}

+ (NSString*)hiddenName:(NSString*)fullname {
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\S+\\Z" options:0 error:nil];
    NSTextCheckingResult *found = [regex firstMatchInString:fullname options:0 range:NSMakeRange(0, [fullname length])];
    
    NSString *lastName;
    
    if (found.range.location != NSNotFound)
        lastName = [fullname substringWithRange:found.range];

    if (![lastName isEqual:[NSNull null]] && lastName.length > 0) {
        return [[fullname substringToIndex:found.range.location] stringByAppendingString:[NSString stringWithFormat:@"%@",[lastName substringToIndex:1]]];
    } else {
        return fullname;
    }
}

//  Layers Animations


+ (void) addPopAnimationToLayer:(CALayer *)aLayer withBounce:(CGFloat)bounce damp:(CGFloat)damp {
    
    // TESTED WITH BOUNCE = 0.2, DAMP = 0.055
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 1;
    
    int steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double value = 0;
    float e = 2.71;
    for (int t=0; t<100; t++) {
        value = pow(e, -damp*t) * sin(bounce*t) + 1;
        [values addObject:[NSNumber numberWithFloat:value]];
    }
    animation.values = values;
    [aLayer addAnimation:animation forKey:@"appear"];
}


@end

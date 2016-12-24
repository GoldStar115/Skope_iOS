//
//  Macros.h
//  Skope
//
//  Created by Nguyen Truong Luu on 6/9/15.
//  Copyright (c) 2015 Nguyen Truong Luu. All rights reserved.
//

#ifndef Skope_Macros_h
#define Skope_Macros_h

#ifdef DEBUG
#define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define DLog(...) do { } while (0)
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define Assert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)

#define OS_VERSION                          [[[UIDevice currentDevice] systemVersion] floatValue]
#define IS_IPHONE                           ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"])
#define IS_IPHONE_3INCH5                    (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE_4INCH                     (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE_6                         (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE_6P                        (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736)
#define IS_IPOD                             ([[[UIDevice currentDevice ] model] isEqualToString:@"iPod touch"])
#define IS_IPAD                             ([[[UIDevice currentDevice ] model] isEqualToString:@"iPad"] || [[[UIDevice currentDevice ] model] isEqualToString:@"iPad Simulator"])

#define Main_Storyboard                     [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define dispatch_main($block)               (dispatch_get_current_queue() == dispatch_get_main_queue() ? $block() : dispatch_sync(dispatch_get_main_queue(), $block))
#define SHARED_API_CLIENT                   [MyRestAPIClient sharedAPIClient]
#define APPDELEGATE                         (AppDelegate*)[[UIApplication sharedApplication] delegate]
#define BACKGROUND_CONCURRENT_QUEUE         [AppDelegate sharedBackgroundOperationQueue]
#define BACKGROUND_SERIAL_QUEUE             [AppDelegate sharedBackgroundSerialOperationQueue]

#define SCREEN_WIDTH_CALCULATED             (OS_VERSION < 8.0 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height) : [[UIScreen mainScreen] bounds].size.width)

#define SCREEN_HEIGHT_CALCULATED            (OS_VERSION < 8.0 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width) : [[UIScreen mainScreen] bounds].size.height)

#define IS_PORTRAIT                         (SCREEN_WIDTH_CALCULATED < SCREEN_HEIGHT_CALCULATED)

#endif

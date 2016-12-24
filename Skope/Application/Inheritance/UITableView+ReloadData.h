//
//  UITableView+ReloadData.h
//  Skope
//
//  Created by Nguyen Truong Luu on 1/15/15.
//  Copyright (c) 2015 Nguyen Truong Luu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ReloadData)
- (void)reloadData:(BOOL)animated completion:(void (^)(BOOL finished))completion;
@end

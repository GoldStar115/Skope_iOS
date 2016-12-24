//
//  ReportpostView.h
//  Skope
//
//  Created by Nguyen Truong Luu on 7/22/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "PSCustomViewFromXib.h"

@class ReportUserView;

@protocol ReportUserViewDelegate <NSObject>

- (void)reportpostView:(ReportUserView*)view didPressedReportButton:(id)sender;
- (void)reportpostView:(ReportUserView*)view didPressedBlockUserButton:(id)sender;

@end

@interface ReportUserView : PSCustomViewFromXib
@property (nonatomic, strong) id <ReportUserViewDelegate> delegate;
@end

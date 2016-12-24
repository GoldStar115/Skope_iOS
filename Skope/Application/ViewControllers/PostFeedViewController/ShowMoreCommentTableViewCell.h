//
//  ShowMoreCommentTableViewCell.h
//  Skope
//
//  Created by Nguyen Truong Luu on 10/15/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowMoreCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *btn_show_more;
@property (weak, nonatomic) IBOutlet UIView *corner_View;
@property (weak, nonatomic) id<ShowMoreCommentCellDelegate> delegate;
@end

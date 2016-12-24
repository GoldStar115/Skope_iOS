//
//  CommentTableViewCell.h
//  Skope
//
//  Created by Nguyen Truong Luu on 10/15/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>


@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_author_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_comment_content;

@property (weak, nonatomic) IBOutlet UIView *corner_View;
@property (weak, nonatomic) IBOutlet UIView *outer_View;

@property (strong, nonatomic) ASNetworkImageNode *imgView_authorAvatar;

- (void)fillCommentInfoToView:(NSDictionary*)comment;

@property (nonatomic, assign) BOOL isLastCell;

@property (strong, nonatomic) id<CommentCellDelegate> delegate;

@end

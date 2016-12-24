//
//  PostCellDelegateProtocol.h
//  Skope
//
//  Created by Nguyen Truong Luu on 6/6/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

@class ProfilePostCell;
@class ShowMoreCommentTableViewCell;

@protocol PostCellDelegate <NSObject>
@required
- (void)PostCell:(id)cell didClickedAddCommentButton:(id)sender;
- (void)PostCell:(id)cell didClickedLikePostButton:(id)sender;
- (void)PostCell:(id)cell didClickedDislikePostButton:(id)sender;
- (void)PostCell:(id)cell didClickedShowFullPostContentButton:(id)sender;
- (void)PostCell:(id)cell didClickedShowPostImageButton:(id)sender;
- (void)PostCell:(id)cell didClickedReportButton:(id)sender;
- (void)PostCell:(id)cell didClickedOnUserAvatar:(id)sender;
- (void)PostCell:(id)cell wantToOpenURL:(NSURL*)url;
@optional
- (void)PostCell:(id)cell didClickedSaveVideoButton:(id)sender;
@end

@protocol CommentCellDelegate <NSObject>
@optional
- (void)CommentCell:(id)cell didClickedShowFullPostContentButton:(id)sender;
- (void)CommentCell:(id)cell didClickedReportButton:(id)sender;
- (void)CommentCell:(id)cell didClickedOnUserAvatar:(id)sender;
- (void)CommentCell:(id)cell wantToOpenURL:(NSURL*)url;
@end

@protocol ActivityCellDelegate <NSObject>
@optional
- (void)ActivityCell:(id)cell didClickedOnUserAvatar:(id)sender;
@end

@protocol ShowMoreCommentCellDelegate <NSObject>
@required
- (void)ShowMoreCommentTableViewCell:(ShowMoreCommentTableViewCell*)cell didClickedSeeMoreCommentButton:(id)sender;
@end
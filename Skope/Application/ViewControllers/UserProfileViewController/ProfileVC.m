//
//  ProfileVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "ProfileVC.h"
#import <ISDiskCache/ISDiskCache.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "Define.h"
#import "converters.h"
#import "messages.h"

#import "MainViewController.h"
#import "ChatViewController.h"
#import "ReportPostView.h"
#import "UITableView+ReloadData.h"
#import "SVModalWebViewController.h"

#import "BLKDelegateSplitter.h"
#import "SquareCashStyleBehaviorDefiner.h"

#import "UIView+RoundedCorners.h"
#import "OtherUserProfileInfoHeaderView.h"
#import "ProfilePostCell.h"
#import "CommentTableViewCell.h"
#import "ProfilePostCellLastSectionNoComment.h"
#import "CommentTableViewCellLastWithoutLoadMore.h"
#import "ShowMoreCommentTableViewCell.h"
#import "MyProfileVC.h"

#define kCellContentTopPadding          6
#define kCellContentVerticalMargin      10
#define kCellContentLeftPadding         16
#define kContentLabelHeightLimit        150
#define kNormalOneLineTextLabelHeight   18
#define kViewLikeCommentHeight          54
#define kShowAllCommentButtonHeight     35
#define kSeeMorebuttonHeight            35

#define AlertBlockUserTag       66
#define AlertHidePostTag        77
#define AlertReportPostTag      99

#define COUNT_START_MPF_COMMENTS        3
#define ShowMoreButtonHeight            40.0

@interface ProfileVC () <PHFComposeBarViewDelegate,UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MWPhotoBrowserDelegate,UIGestureRecognizerDelegate, UINavigationControllerDelegate,PostCellDelegate, CommentCellDelegate, ShowMoreCommentCellDelegate, UIAlertViewDelegate, ReportpostViewDelegate,PopoverViewDelegate, OtherUserProfileInfoHeaderViewDelegate, ChatViewDelegate>
{
    NSUInteger addCommentAtCellIndexPath;
    NSUInteger paging_offset;
    NSUInteger totalPostInCurrentRegion;
    NSIndexPath       *activeIndexPath;
    
}
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSMutableArray *postsList;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) PHFComposeBarView *composeBarView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, strong) AFHTTPRequestOperation *loadingOperation;

@property (nonatomic, strong) ProfilePostCell *prototypeCellNormal;
@property (nonatomic, strong) ProfilePostCellLastSectionNoComment *prototypeCellLastNoComment;
@property (nonatomic, strong) RZCellSizeManager *cellSizeManager;

@property (nonatomic, strong) CommentTableViewCell *commentprototypeCellNormal;
@property (nonatomic, strong) CommentTableViewCellLastWithoutLoadMore *commentprototypeCellLastNoComment;
@property (nonatomic, strong) RZCellSizeManager *commentcellSizeManager;

@property (nonatomic, strong) OtherUserProfileInfoHeaderView *infoBarView;
@property (nonatomic, strong) BLKDelegateSplitter *delegateSplitter;


@property (nonatomic, strong) NSDictionary *userProfileInfo;

@property (nonatomic, strong) ADNavigationControllerDelegate * navigationDelegate;

@end

@implementation ProfileVC

static NSString * const OtherPeopleProfileCellReuseIdentifier = @"OtherPeopleProfileCell_Identifier_XIB";
static NSString * const LoadingCellReuseIdentifier = @"LoadingCell_Identifier";
static NSString * const ProfilePostCellReuseIdentifier = @"ProfilePostCell_Identifier";
static NSString * const ProfilePostCellLastSectionNoCommentIdentifier = @"ProfilePostCellLastSectionNoComment_Identifier";
static NSString * const CommentCellReuseIdentifier = @"CommentTableViewCell_Identifier";
static NSString * const CommentCellLastWithoutLoadMoreReuseIdentifier = @"CommentTableViewCellLastWithoutLoadMore_Identifier";
static NSString * const ShowMoreCellReuseIdentifier = @"ShowMoreCommentTableViewCell_Identifier";

+ (NSDictionary*)UserNameTextAttributes {
    
    static NSDictionary *_UserNameTextAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *centerAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        centerAlign_paragraphStyle.alignment = NSTextAlignmentCenter;
        _UserNameTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0],
                                     NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                     NSParagraphStyleAttributeName : centerAlign_paragraphStyle };
    });
    return _UserNameTextAttributes;
}

+ (NSDictionary*)PostStringTextAttributes {
    
    static NSDictionary *_PostStringTextAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *centerAlign_paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        centerAlign_paragraphStyle.alignment = NSTextAlignmentCenter;
        _PostStringTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0],
                                       NSForegroundColorAttributeName : APP_COMMON_BLUE_COLOR,
                                       NSParagraphStyleAttributeName : centerAlign_paragraphStyle };
    });
    return _PostStringTextAttributes;
}

- (void)setUserProfileInfo:(NSDictionary *)userProfileInfo {
    
    if (![_userProfileInfo isEqualToDictionary:userProfileInfo]) {
        
        //Do something after have new userProfileInfo
        _userProfileInfo = userProfileInfo;
        
        paging_offset = 0;
        
        totalPostInCurrentRegion = 0;
        
        if (_userProfileInfo) {
            
            _postsList = [[NSMutableArray alloc] init];
            
            //[_postsList addObject:_userProfileInfo];
            [_postsList addObject:@"jummy"];
            [_tableView reloadData:YES completion:^(BOOL finished) {
                //
            }];
            
            if (!isloading && _userProfileInfo[@"id"] != nil) {
                
                isloading = YES;
                [self getPostOfUser:_userProfileInfo[@"id"] limit:LIMIT_LIST_POST];
            }
            
        }
    }
}

- (NSDictionary*)getUserProfileInfo {
    return _userProfileInfo;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _postsList = [[NSMutableArray alloc] init];
        addCommentAtCellIndexPath = -1;
        paging_offset = 0;
        totalPostInCurrentRegion = 0;
        
        if ([nibNameOrNil isEqualToString:@"ProfileVCNavigation"]) {
            
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_ul"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
            backButton.tintColor = [UIColor redColor];
            self.navigationItem.rightBarButtonItem = backButton;
            //self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _postsList = [[NSMutableArray alloc] init];
        addCommentAtCellIndexPath = -1;
        paging_offset = 0;
        totalPostInCurrentRegion = 0;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    [self prepareForSubViews];
}

- (void)prepareForSubViews {
    
    // Register NIB cell for tableView
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:CommentCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShowMoreCommentTableViewCell" bundle:nil] forCellReuseIdentifier:ShowMoreCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfilePostCell" bundle:nil] forCellReuseIdentifier:ProfilePostCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileInfoCell" bundle:nil] forCellReuseIdentifier:OtherPeopleProfileCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfilePostCellLastSectionNoComment" bundle:nil] forCellReuseIdentifier:ProfilePostCellLastSectionNoCommentIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:LoadingCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCellLastWithoutLoadMore" bundle:nil] forCellReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
    
    
    
    
    
    // Init size manager
    
    self.cellSizeManager = [[RZCellSizeManager alloc] init];
    
    [self.cellSizeManager registerCellClassName:NSStringFromClass([ProfilePostCell class]) withNibNamed:@"ProfilePostCell" forReuseIdentifier:ProfilePostCellReuseIdentifier withHeightBlock:^CGFloat(ProfilePostCell *cell, NSMutableDictionary *postInfo) {
        
        if (!self.prototypeCellNormal)
        {
            self.prototypeCellNormal = [self.tableView dequeueReusableCellWithIdentifier:ProfilePostCellReuseIdentifier];
        }
        [self.prototypeCellNormal fillDataToCellWithPostInfo:postInfo tableViewWidth:_tableView.bounds.size.width];
        [self.prototypeCellNormal setNeedsLayout];
        [self.prototypeCellNormal layoutIfNeeded];
        CGSize size = [self.prototypeCellNormal.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
        
    }];
    
    [self.cellSizeManager registerCellClassName:NSStringFromClass([ProfilePostCellLastSectionNoComment class]) withNibNamed:@"ProfilePostCellLastSectionNoComment" forReuseIdentifier:ProfilePostCellLastSectionNoCommentIdentifier withHeightBlock:^CGFloat(ProfilePostCellLastSectionNoComment *cell, NSMutableDictionary *postInfo) {
        
        if (!self.prototypeCellLastNoComment)
        {
            self.prototypeCellLastNoComment = [self.tableView dequeueReusableCellWithIdentifier:ProfilePostCellLastSectionNoCommentIdentifier];
        }
        [self.prototypeCellLastNoComment fillDataToCellWithPostInfo:postInfo tableViewWidth:_tableView.bounds.size.width];
        [self.prototypeCellLastNoComment setNeedsLayout];
        [self.prototypeCellLastNoComment layoutIfNeeded];
        CGSize size = [self.prototypeCellLastNoComment.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
        
    }];
    
    
    
    
    // Comment cell size manager
    
    self.commentcellSizeManager = [[RZCellSizeManager alloc] init];
    
    [self.commentcellSizeManager registerCellClassName:NSStringFromClass([CommentTableViewCell class]) withNibNamed:@"CommentTableViewCell" forReuseIdentifier:CommentCellReuseIdentifier withHeightBlock:^CGFloat(CommentTableViewCell *cell, NSMutableDictionary *commentInfo) {
        
        if (!self.commentprototypeCellNormal)
        {
            self.commentprototypeCellNormal = [self.tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier];
            [self.commentprototypeCellNormal setNeedsLayout];
            [self.commentprototypeCellNormal layoutIfNeeded];
        }
        [self.commentprototypeCellNormal fillCommentInfoToView:commentInfo];
        [self.commentprototypeCellNormal setNeedsLayout];
        [self.commentprototypeCellNormal layoutIfNeeded];
        CGSize size = [self.commentprototypeCellNormal.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
    }];
    
    
    [self.commentcellSizeManager registerCellClassName:NSStringFromClass([CommentTableViewCellLastWithoutLoadMore class]) withNibNamed:@"CommentTableViewCellLastWithoutLoadMore" forReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier withHeightBlock:^CGFloat(CommentTableViewCellLastWithoutLoadMore *cell, NSMutableDictionary *commentInfo) {
        
        if (!self.commentprototypeCellLastNoComment)
        {
            self.commentprototypeCellLastNoComment = [self.tableView dequeueReusableCellWithIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
            [self.commentprototypeCellLastNoComment setNeedsLayout];
            [self.commentprototypeCellLastNoComment layoutIfNeeded];
        }
        [self.commentprototypeCellLastNoComment fillCommentInfoToView:commentInfo];
        [self.commentprototypeCellLastNoComment setNeedsLayout];
        [self.commentprototypeCellLastNoComment layoutIfNeeded];
        CGSize size = [self.commentprototypeCellLastNoComment.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height;
    }];
    
    
    
    
    // ComposerBar container
    
    _container = [self container];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
    _container.hidden = YES;
    
    
    // Setup header View
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.infoBarView = [[OtherUserProfileInfoHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 100.0)];
        self.infoBarView.delegate = self;
        self.infoBarView.backgroundColor = APP_COMMON_LIGHT_GRAY_BACKGROUND_COLOR;

        
        SquareCashStyleBehaviorDefiner *behaviorDefiner = [[SquareCashStyleBehaviorDefiner alloc] init];
        //[behaviorDefiner addSnappingPositionProgress:0.0 forProgressRangeStart:0.0 end:0.5];
        //[behaviorDefiner addSnappingPositionProgress:1.0 forProgressRangeStart:0.5 end:1.0];
        behaviorDefiner.snappingEnabled = YES;
        behaviorDefiner.elasticMaximumHeightAtTop = YES;
        self.infoBarView.behaviorDefiner = behaviorDefiner;
        
        self.delegateSplitter = [[BLKDelegateSplitter alloc] initWithFirstDelegate:behaviorDefiner secondDelegate:self];
        self.tableView.delegate = (id<UITableViewDelegate>)self.delegateSplitter;
        
        [self.containerView addSubview:self.infoBarView];

        self.tableView.contentInset = UIEdgeInsetsMake(self.infoBarView.maximumBarHeight, 0.0, 0.0, 0.0);

        
        
        // Fill Data to headerBarView
        
        
        NSString *displayName = _userProfileInfo[@"name"];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@'s", displayName] attributes:[ProfileVC UserNameTextAttributes]];
        
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" Posts" attributes:[ProfileVC PostStringTextAttributes]]];
        
        self.infoBarView.lbl_UserName.attributedText = attrString;
        
        [self.infoBarView.imgView_UserAvatar sd_setImageWithURL:[NSURL URLWithString:_userProfileInfo[@"avatar"]] placeholderImage:USER_DEFAULT_AVATAR];
        
    });
    
    
    
    
    // Notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataWhenHaveInternetConnection)
                                                 name:kInternetConnectionIsEnableNotification
                                               object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self imageAnimation];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _container.hidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)imageAnimation
{
    CATransition *transition = [CATransition animation];
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.duration = 1.0f;
    transition.type = @"rippleEffect";
    
    [[self.infoBarView.imgView_UserAvatar layer] addAnimation:transition forKey:@"rippleEffect"];
}


- (void)reloadDataWhenHaveInternetConnection {
    
    if (_postsList.count <= 1 && !isloading && _userProfileInfo[@"id"] != nil) {
        isloading = YES;
        [self getPostOfUser:_userProfileInfo[@"id"] limit:LIMIT_LIST_POST];
    }
    
}

#pragma mark - CALL WS

- (void) getPostOfUser:(NSString *)userId limit:(NSUInteger) para_page_limit {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    
    if (!access_token || access_token.length == 0 ) {
        return;
    }
    
    [self.loadingOperation cancel];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    
    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          userId,@"id",
                                          @(paging_offset), @"offset",
                                          @(para_page_limit),@"limit",
                                          nil];
    
    NSDictionary *firstPost = ([_postsList count] > 1 ? [_postsList firstObject] : nil);
    
    if (firstPost) {
        NSString* since = [NSString stringWithFormat:@"%lu",[firstPost[@"created_at"] integerValue] + 1];
        [request_param setObject:since forKey:@"since"];
    }
    
    
    self.loadingOperation = [manager GET:URL_SERVER_API(API_GET_POST_OF_USER(userId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([Common validateResponse:responseObject]) {
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSMutableArray *newObjects = [NSMutableArray new];
                NSMutableArray *newIndexPaths = [NSMutableArray new];
                
                NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
                    if (success && object[@"data"][@"items"] != nil) {
                        if (object[@"data"][@"total"] != nil) {
                            totalPostInCurrentRegion = [object[@"data"][@"total"] intValue];
                        }

                        [object[@"data"][@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            NSMutableDictionary *postObject = obj;
                            
                            postObject[@"show_full_content"] = @"false";

                            [newIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:(_postsList.count-2 + idx + 1)]];
                            
                        }];
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                    }
                }];
                
                [block setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        //[_tableView reloadData];
                        
                        if (success && newObjects.count > 0) {
                            
                            [_tableView beginUpdates];
                            
                            [_postsList insertObjects:newObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_postsList.count - 1, newObjects.count)]];
                            
                            NSIndexPath *firstIndex = newIndexPaths.firstObject;
                            NSIndexSet *newSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstIndex.section, newIndexPaths.count)];
                            [_tableView insertSections:newSection withRowAnimation:UITableViewRowAnimationFade];
                            
                            [_tableView endUpdates];
                            
                            paging_offset+=newObjects.count;
                            
                        } else {
                            
                        }
                        
                        isloading = NO;
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:block];
                
            }];
            
        } else {
            
            isloading = NO;
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        isloading = NO;
        
    }];
    
}

- (void) fetchMoreCommentForPost:(NSMutableDictionary*)postInfo withLimit:(NSUInteger)page_limit forCell:(ShowMoreCommentTableViewCell*)cell//insection:(NSUInteger)section
{
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSMutableArray *comments = postInfo[@"comment"][@"items"];
    NSString *offset = [NSString stringWithFormat:@"%lu",(unsigned long)comments.count];
    NSString *limit = [NSString stringWithFormat:@"%lu",(unsigned long)page_limit];
    NSString *postID = postInfo[@"id"];
    if (!access_token || access_token.length == 0 || !offset || !limit || !postID) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];

    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          offset,@"offset",
                                          limit,@"limit",
                                          nil];
    
    NSArray* allComments = (NSArray*)postInfo[@"comment"][@"items"];
    NSDictionary *firstComment = ([allComments count] > 0 ? [allComments firstObject] : nil);
    
    if (firstComment) {
        //NSString* since = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] + 1];    // + 1 to include first post
        //[request_param setObject:since forKey:@"since"];
        
        NSString* after = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] - 1];    // + 1 to include first post
        [request_param setObject:after forKey:@"after"];
    }
    
    _tableView.scrollEnabled = NO;
    
    [manager GET:URL_SERVER_API(API_COMMENT_FOR_A_POST(postID)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            NSMutableArray *newObjects = [NSMutableArray new];
            NSMutableArray *newIndexPaths = [NSMutableArray new];
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSBlockOperation *blockoperation = [NSBlockOperation blockOperationWithBlock:^{
                    
                    postInfo[@"comment"][@"total"] = object[@"data"][@"total"];
                    
                    if (success &&  object[@"data"][@"items"] != nil) {
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                        NSIndexPath* indexPath = [_tableView indexPathForCell:cell];
                        
                        [(NSArray *) object[@"data"][@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            [newIndexPaths addObject:[NSIndexPath indexPathForRow:comments.count + (idx+1) inSection:indexPath.section]];
                            
                        }];
                        
                    }
                    
                }];
                
                [blockoperation setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
                        
                        if (success &&  newObjects.count > 0) {
                            
                            [_tableView beginUpdates];
                            
                            NSIndexPath* indexPath = [_tableView indexPathForCell:cell];
                            
                            ProfilePostCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
                            [cell.lbl_commentCount setText:[NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments]];
                            
                            if (totalComments <= comments.count + newObjects.count) {
                                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:comments.count+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                            }
                            
                            [comments addObjectsFromArray:newObjects];
                            
                            [_tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                            
                            [_tableView endUpdates];
                            
                        } else {
                            
                            //Have no comment return
                            
                        }
                        
                        _tableView.scrollEnabled = YES;
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:blockoperation];
                
            }];
            
        } else {
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            NSLog(@"Error: %@",errorMsg);
            
            _tableView.scrollEnabled = YES;
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideNetworkActivityIndicator];
        
        _tableView.scrollEnabled = YES;
        
    }];
    
}

- (void) callWSAddComment:(NSMutableDictionary *)postInfo andTextCm:(NSString *) strComment cellIndexPath:(NSIndexPath *)indexPath {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSMutableArray *comments = postInfo[@"comment"][@"items"];
    NSString *offset = [NSString stringWithFormat:@"%lu",(unsigned long)comments.count];
    NSString *limit = [NSString stringWithFormat:@"%lu",(unsigned long)1000];
    NSString *postID = postInfo[@"id"];
    if (!access_token || access_token.length == 0 || !offset || !limit || !postID) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          offset,@"offset",
                                          limit,@"limit",
                                          nil];
    
    NSArray* allComments = (NSArray*)postInfo[@"comment"][@"items"];
    NSDictionary *firstComment = ([allComments count] > 0 ? [allComments firstObject] : nil);
    
    if (firstComment) {
        //NSString* since = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] + 1];    // + 1 to include first post
        //[request_param setObject:since forKey:@"since"];
        
        NSString* after = [NSString stringWithFormat:@"%ld",[firstComment[@"created_at"] integerValue] - 1];    // + 1 to include first post
        [request_param setObject:after forKey:@"after"];
    }
    
    _tableView.scrollEnabled = NO;
    
    [manager GET:URL_SERVER_API(API_COMMENT_FOR_A_POST(postID)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            NSMutableArray *newObjects = [NSMutableArray new];
            NSMutableArray *newIndexPaths = [NSMutableArray new];
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSBlockOperation *blockoperation = [NSBlockOperation blockOperationWithBlock:^{
                    
                    postInfo[@"comment"][@"total"] = object[@"data"][@"total"];
                    
                    if (success &&  object[@"data"][@"items"] != nil) {
                        
                        [newObjects addObjectsFromArray:object[@"data"][@"items"]];
                        
                        //  Add local comment
                        
                        NSMutableDictionary *commentObj = [NSMutableDictionary dictionaryWithObject:strComment forKey:@"content"];
                        NSDictionary *user = [NSDictionary dictionaryWithObjects:@[[UserDefault currentUser].name,[UserDefault currentUser].avatar] forKeys:@[@"name",@"avatar"]];
                        NSString *create_at = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
                        [commentObj setObject:user forKey:@"user"];
                        [commentObj setObject:create_at forKey:@"created_at"];
                        [newObjects addObject:commentObj];
                        
                        [newObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            [newIndexPaths addObject:[NSIndexPath indexPathForRow:comments.count + (idx+1) inSection:indexPath.section]];
                            
                        }];
                        
                    }
                    
                }];
                
                [blockoperation setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue] + 1;   //+1 for newest comment
                        [postInfo[@"comment"] setObject:[NSString stringWithFormat:@"%d",totalComments] forKey:@"total"];
                        
                        if (success &&  newObjects.count > 0) {
                            
                            [_tableView beginUpdates];
                            
                            ProfilePostCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
                            [cell.lbl_commentCount setText:[NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments]];
                            
                            if (totalComments <= comments.count + newObjects.count && [_tableView numberOfRowsInSection:indexPath.section] > comments.count + 1) {
                                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:comments.count+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                            }
                            
                            [comments addObjectsFromArray:newObjects];
                            
                            [_tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                            
                            [_tableView endUpdates];
                            
                        } else {
                            
                            //Have no comment return
                            
                        }
                        
                        _tableView.scrollEnabled = YES;
                        
                        
                        //  Reload firstCell and last cell
                        
                        NSIndexPath *postCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                        ProfilePostCell *cell = [self.tableView cellForRowAtIndexPath:postCellIndexPath];
                        cell.lbl_commentCount.text = [NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalComments];
                        NSIndexPath *lastCell = [NSIndexPath indexPathForRow:comments.count-1 inSection:indexPath.section];
                        [_tableView reloadRowsAtIndexPaths:@[lastCell] withRowAnimation:UITableViewRowAnimationFade];
                        
                        
                        // Call API to add comment to server
                        
                        [Common showNetworkActivityIndicator];
                        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                        
                        NSDictionary *request_param = @{@"access_token":access_token,
                                                        @"content":strComment,
                                                        @"id":postID,
                                                        };
                        
                        [manager POST:URL_SERVER_API(API_COMMENT_FOR_A_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            [Common hideLoadingViewGlobal];
                            [Common hideNetworkActivityIndicator];
                            
                            if ([Common validateResponse:responseObject]) {
                                
                                [postInfo[@"comment"][@"items"] replaceObjectAtIndex:comments.count-1 withObject:responseObject[@"data"][@"comment"]];
                                
                            } else {
                                
                                NSString* errorMsg = [Common errorMessageFromResponseObject:responseObject];
                                if (errorMsg) {
                                    [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                                }
                                
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            
                            [Common hideLoadingViewGlobal];
                            [Common hideNetworkActivityIndicator];
                            
                        }];
                        
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:blockoperation];
                
            }];
            
        } else {
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            NSLog(@"Error: %@",errorMsg);
            
            _tableView.scrollEnabled = YES;
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideNetworkActivityIndicator];
        
        _tableView.scrollEnabled = YES;
        
    }];
    
    
    
    /*
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *postID = postInfo[@"id"];
    
    if (!access_token || access_token.length == 0 || !postID ) {
        return;
    }
    
    // Add local comment first
    
    NSMutableDictionary *commentObj = [NSMutableDictionary dictionaryWithObject:strComment forKey:@"content"];
    NSDictionary *user = [NSDictionary dictionaryWithObjects:@[[UserDefault currentUser].name,[UserDefault currentUser].avatar] forKeys:@[@"name",@"avatar"]];
    NSString *create_at = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    [commentObj setObject:user forKey:@"user"];
    [commentObj setObject:create_at forKey:@"created_at"];
    
    [postInfo[@"comment"][@"items"] insertObject:commentObj atIndex:0];
    NSUInteger totalCm = [postInfo[@"comment"][@"total"] intValue] + 1;
    postInfo[@"comment"][@"total"] = @(totalCm);
    NSIndexPath *postCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
    PostCell *cell = [self.tableView cellForRowAtIndexPath:postCellIndexPath];
    cell.lbl_commentCount.text = [NSString stringWithFormat:@"Comments (%ld)", (unsigned long)totalCm];
    
    [_commentcellSizeManager invalidateCellSizeCache];
    
    
    // Update to tableView
    
    [_tableView beginUpdates];

    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    if (totalCm == COUNT_START_MPF_COMMENTS + 1) {
        
        [postInfo[@"comment"][@"items"] removeLastObject];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:totalCm inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:totalCm-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    if (totalCm == 1) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [_tableView endUpdates];
    
    // Call API to add comment to server
    
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":access_token,
                                    @"content":strComment,
                                    @"id":postID,
                                    };
    
    [manager POST:URL_SERVER_API(API_COMMENT_FOR_A_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            [postInfo[@"comment"][@"items"] replaceObjectAtIndex:0 withObject:responseObject[@"data"][@"comment"]];
            
        } else {
            
            NSString* errorMsg = [Common errorMessageFromResponseObject:responseObject];
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
    }];
     
    */
}

- (void) callWSPfLikeDislikePost:(NSString *)postId andLikeDislike:(NSString *) strLike andIndexPath:(NSIndexPath *)indexPath {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    
    if (!access_token || access_token.length == 0 ) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{
                                    @"access_token":access_token,
                                    @"type":strLike,
                                    @"id":postId,
                                    };
    
    [manager POST:URL_SERVER_API(API_LIKE_DISLIKE_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideNetworkActivityIndicator];
        [Common hideLoadingViewGlobal];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideNetworkActivityIndicator];
        [Common hideLoadingViewGlobal];
        
    }];
    
}

- (void) getCommentsForPost:(NSMutableDictionary*)postInfo offset:(NSUInteger)offset limit:(NSUInteger)limit {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *postId = postInfo[@"id"];
    NSString *str_offset = [NSString stringWithFormat:@"%lu",(unsigned long)offset];
    NSString *str_limit = [NSString stringWithFormat:@"%lu",(unsigned long)limit];
    
    if (!access_token || access_token.length == 0 || !postId || !offset || !str_limit ) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{@"access_token":access_token,
                                    @"id":str_limit,
                                    @"offset":str_offset,
                                    @"limt":str_limit,
                                    };
    
    [manager GET:URL_SERVER_API(API_COMMENT_FOR_A_POST(postInfo[@"id"])) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
        } else {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
    }];
    
}


#pragma mark - COMPOSE POST

- (void)keyboardWillToggle:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]        getValue:&startFrame];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&endFrame];
    
    NSInteger signCorrection = 1;
    if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0)
        signCorrection = -1;
    CGRect newContainerFrame = [[self container] frame];
    newContainerFrame.origin.y = endFrame.origin.y - newContainerFrame.size.height;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [_container setFrame:newContainerFrame];
                     }
                     completion:NULL];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    
    [composeBarView resignFirstResponder];
    _container.hidden = YES;
    NSMutableDictionary *postInfo = [_postsList objectAtIndex:addCommentAtCellIndexPath];
    [self callWSAddComment:postInfo andTextCm:composeBarView.textView.text cellIndexPath:[NSIndexPath indexPathForRow:1 inSection:addCommentAtCellIndexPath]];
    
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
    
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{
    
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
{
    
}

#pragma mark - CREATE VIEWS METHODS

- (UIView *)container {
    if (!_container) {
        
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH_CALCULATED, SCREEN_HEIGHT_CALCULATED);
        
        _container = [[UIView alloc] initWithFrame:frame];
        _container.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionHideKeyboard:)];
        [_container addGestureRecognizer:tapGesture];
    }
    
    return _container;
}


- (PHFComposeBarView *) composeBarView {
    if (!_composeBarView) {
        
        CGRect frame = CGRectMake(0.0f,
                                  CGRectGetHeight(_container.bounds) - PHFComposeBarViewInitialHeight - (self.navigationController?64:0),
                                  SCREEN_WIDTH_CALCULATED,
                                  PHFComposeBarViewInitialHeight);
        
        _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
        [_composeBarView setBackgroundColor:[UIColor whiteColor]];
        _composeBarView.buttonTintColor = COLOR_BUTTON_POST_SEND;
        [_composeBarView.textView setFont:FONT_TEXT_COMPOSE_BAR];
        [_composeBarView setMaxCharCount:160];
        [_composeBarView setMaxLinesCount:5];
        [_composeBarView setMaxHeight:120];
        [_composeBarView setButtonTitle:@"Post"];
        [_composeBarView setPlaceholder:@"Type something..."];
        [_composeBarView.button setTitleColor:COLOR_BUTTON_POST_SEND forState:UIControlStateDisabled];
        _composeBarView.maxCharCount = 0;
        [_composeBarView setDelegate:self];
        
    }
    
    return _composeBarView;
}



#pragma mark - ReportViewDelegate

- (void)reportpostView:(ReportPostView*)view didPressedReportButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to report this post?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertReportPostTag];
    }];
}

- (void)reportpostView:(ReportPostView*)view didPressedHideButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to hide this post?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertHidePostTag];
    }];
}

- (void)reportpostView:(ReportPostView*)view didPressedBlockUserButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to block user and remove all posts?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertBlockUserTag];
    }];
}

#pragma mark - PopoverViewDelegate Methods

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.popoverView = nil;
}

#pragma mark - TABLE DELEAGATE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _postsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == [_postsList count] - 1) {
        
        // For loadmore cell
        
        return 1;
        
    }  else if (section < _postsList.count) {
        
        NSMutableDictionary *postInfo = [_postsList objectAtIndex:section];
        
        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
        
        if (totalComments > 0) {
            
            NSMutableArray *comments = postInfo[@"comment"][@"items"];
            
            if (totalComments > COUNT_START_MPF_COMMENTS) {
                
                // Have loadmore cell
                
                if (totalComments > comments.count) {
                    
                    return comments.count + 1 + 1;  //For Post cell and loadmore cell
                    
                } else {
                    
                    return comments.count + 1;
                }
                
            } else {
                
                // Have no loadmore cell
                
                return comments.count + 1;  //For Post cell
            }
            
        } else {
            
            return 1;
            
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section < 0) {
        
        return 330;
        
    } else {
        
        id object = [_postsList objectAtIndex:indexPath.section];
        
        if ((indexPath.section == _postsList.count - 1) || [object isKindOfClass:[NSString class]]) {
            
            //===jummy cell
            
            if (totalPostInCurrentRegion <= _postsList.count - 1) {
                
                return 0;
                
            } else {
                
                return ShowMoreButtonHeight;
                
            }
            
        } else {
            
            NSDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
            
            NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
            
            if (indexPath.row == 0) {
                
                if (totalComments > 0) {
                    
                    CGFloat rowHeight = [self.cellSizeManager cellHeightForObject:postInfo indexPath:indexPath cellReuseIdentifier:ProfilePostCellReuseIdentifier];
                    return rowHeight;
                    
                } else {
                    
                    CGFloat rowHeight = [self.cellSizeManager cellHeightForObject:postInfo indexPath:indexPath cellReuseIdentifier:ProfilePostCellLastSectionNoCommentIdentifier];
                    return rowHeight;
                }
                
            } else {
                
                if (totalComments > 0) {
                    
                    NSMutableArray *comments = postInfo[@"comment"][@"items"];
                    
                    if (totalComments > COUNT_START_MPF_COMMENTS) {
                        
                        // Have loadmore cell
                        
                        if (totalComments <= comments.count) {
                            
                            if (indexPath.row == comments.count) {
                                
                                // Use last comment cell without loadmore cell
                                
                                NSDictionary *commentObj = comments[indexPath.row - 1];
                                CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
                                return rowHeight;
                                
                            } else {
                                
                                // Normal Comment cell
                                
                                NSDictionary *commentObj = comments[indexPath.row - 1];
                                CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellReuseIdentifier];
                                return rowHeight;
                            }
                            
                        } else {
                            
                            if (indexPath.row == comments.count + 1) {
                                
                                // Load more cell
                                
                                return ShowMoreButtonHeight;
                                
                            } else {
                                
                                // Normal Comment cell
                                
                                NSDictionary *commentObj = comments[indexPath.row - 1];
                                CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellReuseIdentifier];
                                return rowHeight;
                                
                            }
                            
                        }
                        
                    } else {
                        
                        // Have no loadmore cell
                        
                        if (indexPath.row < comments.count) {
                            
                            // Use normal comment cell
                            
                            NSDictionary *commentObj = comments[indexPath.row - 1];
                            CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellReuseIdentifier];
                            return rowHeight;
                            
                        } else {
                            
                            // Use last comment cell without loadmore cell
                            
                            NSDictionary *commentObj = comments[indexPath.row - 1];
                            CGFloat rowHeight = [self.commentcellSizeManager cellHeightForObject:commentObj indexPath:indexPath cellReuseIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier];
                            return rowHeight;
                            
                        }
                    }
                }
            }
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == _postsList.count - 1) {
        
        //  Jummy cell
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellReuseIdentifier forIndexPath:indexPath];
        UIActivityIndicatorView *indicatorV = (UIActivityIndicatorView *)[cell viewWithTag:12];
        
        if (totalPostInCurrentRegion > _postsList.count - 1) {
            [indicatorV startAnimating];
        } else {
            [indicatorV stopAnimating];
        }
        
        return cell;
        
    } else {
        
        NSMutableDictionary *postInfo = [_postsList objectAtIndex:indexPath.section];
        
        NSUInteger totalComments = [postInfo[@"comment"][@"total"] integerValue];
        
        if (indexPath.row == 0) {
            
            //  Normal cell
            
            if (totalComments > 0) {
                
                ProfilePostCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfilePostCellReuseIdentifier forIndexPath:indexPath];
                [cell configureCellDisplayWithPostInfo:postInfo tableViewWidth:tableView.bounds.size.width indexPath:indexPath nodeConstructionQueue:[Common sharedBackgroundOperationQueue]];//[[UIScreen mainScreen] bounds].size.width - 2*kCellContentLeftPadding - 16
                [cell setDelegate:self];
                
                return cell;
                
            } else {
                
                ProfilePostCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfilePostCellLastSectionNoCommentIdentifier forIndexPath:indexPath];
                [cell configureCellDisplayWithPostInfo:postInfo tableViewWidth:tableView.bounds.size.width indexPath:indexPath nodeConstructionQueue:[Common sharedBackgroundOperationQueue]];//[[UIScreen mainScreen] bounds].size.width - 2*kCellContentLeftPadding - 16
                [cell setDelegate:self];
                return cell;
            }
            
        } else {
            
            //  Comment cell and last cell
            
            if (totalComments > 0) {
                
                NSMutableArray *comments = postInfo[@"comment"][@"items"];
                
                if (totalComments > COUNT_START_MPF_COMMENTS) {
                    
                    //  Have loadmore cell
                    
                    if (totalComments <= comments.count) {
                        
                        if (indexPath.row == comments.count) {
                            
                            // Use last comment cell without loadmore cell
                            
                            CommentTableViewCellLastWithoutLoadMore *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier forIndexPath:indexPath];
                            NSDictionary *commentInfo = comments[indexPath.row - 1];
                            [commentCell fillCommentInfoToView:commentInfo];
                            commentCell.isLastCell = YES;
                            commentCell.delegate = self;
                            
                            return commentCell;
                            
                        } else {
                            
                            //  Normal Comment cell
                            
                            CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
                            NSDictionary *commentInfo = comments[indexPath.row - 1];
                            [commentCell fillCommentInfoToView:commentInfo];
                            commentCell.delegate = self;
                            
                            return commentCell;
                            
                        }
                        
                    } else {
                        
                        if (indexPath.row == comments.count + 1) {
                            
                            //  Load more cell
                            
                            ShowMoreCommentTableViewCell *showmoreCell = [tableView dequeueReusableCellWithIdentifier:ShowMoreCellReuseIdentifier forIndexPath:indexPath];
                            showmoreCell.delegate = self;
                            
                            return showmoreCell;
                            
                        } else {
                            
                            //  Normal Comment cell
                            
                            CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
                            NSDictionary *commentInfo = comments[indexPath.row - 1];
                            [commentCell fillCommentInfoToView:commentInfo];
                            commentCell.delegate = self;
                            
                            return commentCell;
                            
                        }
                        
                    }
                    
                } else {
                    
                    //  Have no loadmore cell
                    
                    if (indexPath.row < comments.count) {
                        
                        //  Use normal comment cell
                        
                        CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
                        NSDictionary *commentInfo = comments[indexPath.row - 1];
                        [commentCell fillCommentInfoToView:commentInfo];
                        commentCell.delegate = self;
                        
                        return commentCell;
                        
                    } else {
                        
                        //  Use last comment cell without loadmore cell
                        
                        CommentTableViewCellLastWithoutLoadMore *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellLastWithoutLoadMoreReuseIdentifier forIndexPath:indexPath];
                        NSDictionary *commentInfo = comments[indexPath.row - 1];
                        [commentCell fillCommentInfoToView:commentInfo];
                        commentCell.isLastCell = YES;
                        commentCell.delegate = self;
                        
                        return commentCell;
                        
                    }
                }
            }
            
        }
        
        CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellReuseIdentifier forIndexPath:indexPath];
        
        return commentCell;
        
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section ==  _postsList.count - 2 && totalPostInCurrentRegion >= _postsList.count - 1 && !isloading) {
        isloading = YES;
        [self getPostOfUser:_userProfileInfo[@"id"] limit:LIMIT_LIST_POST];
    }
}

#pragma mark - SHOW MORE COMMENT CELL DELEGATE

- (void)ShowMoreCommentTableViewCell:(ShowMoreCommentTableViewCell*)cell didClickedSeeMoreCommentButton:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSMutableDictionary *postInfo = [_postsList objectAtIndex:indexPath.section];
    [self fetchMoreCommentForPost:postInfo withLimit:LIMIT_LIST_COMMENT forCell:cell];//insection:indexPath.section];
}

#pragma mark - ACTION ON POST CELL

- (void)PostCell:(PostCell*)cell didClickedReportButton:(id)sender {
    
    UIButton *button = (UIButton*) sender;
    activeIndexPath = [_tableView indexPathForCell:cell];
    
    CGRect cellRect = [self.containerView convertRect:[self.tableView convertRect:[cell convertRect:[button.superview convertRect:button.frame toView:cell.contentView] toView:self.tableView] toView:self.containerView] toView:self.view];
    CGPoint showPoint = CGPointMake(CGRectGetMidX(cellRect), CGRectGetMidY(cellRect));
    
    ReportPostView *reportView = [[ReportPostView alloc] init];
    reportView.delegate = self;
    self.popoverView = [PopoverView showPopoverAtPoint:showPoint
                                                inView:self.view
                                              maskType:PopoverMaskTypeGradient
                                       withContentView:reportView
                                              delegate:self];
}

- (void)PostCell:(ProfilePostCell *)cell didClickedShowFullPostContentButton:(id)sender {
    
    NSIndexPath *selectedIndexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:selectedIndexPath.section];
    
    if ([postInfo[@"show_full_content"] isEqualToString:@"false"]) {
        postInfo[@"show_full_content"] = @"true";
    } else {
        postInfo[@"show_full_content"] = @"false";
    }
    
    [self.cellSizeManager invalidateCellSizeAtIndexPath:selectedIndexPath];
    [_tableView reloadRowsAtIndexPaths:@[selectedIndexPath]
                      withRowAnimation:UITableViewRowAnimationFade];
    [cell.contentView updateConstraints];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
}


- (void)PostCell:(ProfilePostCell *)cell didClickedAddCommentButton:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    addCommentAtCellIndexPath = indexPath.section;
    _composeBarView.textView.text = @"";
    _container.hidden = NO;
    [_composeBarView.textView becomeFirstResponder];
    [_composeBarView setUtilityButtonImage:nil];
    
}

- (void)PostCell:(ProfilePostCell *)cell didClickedLikePostButton:(id)sender {
    
    NSIndexPath *selectedIndexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:selectedIndexPath.section];
    
    NSString *userLikedThisPost = postInfo[@"voted_type"];
    NSInteger number_like = [postInfo[@"like"][@"total"] integerValue];
    NSInteger number_dislike = [postInfo[@"dislike"][@"total"] integerValue];
    
    if ([userLikedThisPost isEqualToString:@"dislike"] || userLikedThisPost.length == 0) {
        
        if (number_dislike > 0) {
            number_dislike--;
        }
        number_like++;
        
        postInfo[@"like"][@"total"] = @(number_like);
        postInfo[@"dislike"][@"total"] = @(number_dislike);
        postInfo[@"voted_type"] = @"like";
        
        [self callWSPfLikeDislikePost:postInfo[@"id"] andLikeDislike:@"like" andIndexPath:selectedIndexPath];
    }
}

- (void)PostCell:(ProfilePostCell *)cell didClickedDislikePostButton:(id)sender {
    
    NSIndexPath *selectedIndexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:selectedIndexPath.section];
    
    NSString *userLikedThisPost = postInfo[@"voted_type"];
    NSInteger number_like = [postInfo[@"like"][@"total"] integerValue];
    NSInteger number_dislike = [postInfo[@"dislike"][@"total"] integerValue];
    
    if ([userLikedThisPost isEqualToString:@"like"]  || userLikedThisPost.length == 0) {
        
        number_dislike++;
        if (number_like > 0) {
            number_like--;
        }
        
        postInfo[@"like"][@"total"] = @(number_like);
        postInfo[@"dislike"][@"total"] = @(number_dislike);
        postInfo[@"voted_type"] = @"dislike";

        [self callWSPfLikeDislikePost:postInfo[@"id"] andLikeDislike:@"dislike" andIndexPath:selectedIndexPath];
    }
}


- (void)PostCell:(ProfilePostCell *)cell didClickedShowPostImageButton:(id)sender {
    
    ButtonShowImageSlide *button = (ButtonShowImageSlide *)sender;
    NSArray *arrMedia = [_postsList objectAtIndex:button.indexPathCell.section][@"media"];
    
    if ([arrMedia count] > 0 && [arrMedia objectAtIndex:(int)button.indexImageSelected]!=nil) {
        
        NSDictionary *objSelected = [arrMedia objectAtIndex:(int)button.indexImageSelected];
        
        if ([objSelected[@"type"] isEqualToString:@"video"]) {
            
            if (!_moviePlayer) {
                _moviePlayer = [[MPMoviePlayerViewController alloc] init];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(donefinishedPlayVideo:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:_moviePlayer.moviePlayer];
            
            [_moviePlayer.moviePlayer stop];
            _moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
            [_moviePlayer.moviePlayer setContentURL:[NSURL URLWithString:objSelected[@"src"]]];
            
            _moviePlayer.moviePlayer.shouldAutoplay=YES;
            [_moviePlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            
            [self presentViewController:_moviePlayer animated:YES completion:^{
                [_moviePlayer.moviePlayer play];
            }];
            
        } else {
            
            //Choose array has only images
            
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            BOOL displayActionButton = kAllowUserSaveOtherUserAvatar;
            BOOL displaySelectionButtons = NO;
            BOOL displayNavArrows = NO;
            BOOL enableGrid = NO;
            BOOL startOnGrid = NO;
            int indexRealSelectedImg = (int)button.indexImageSelected;
            
            for (int i = 0; i < [arrMedia count]; i++) {
                NSDictionary *objImg = [arrMedia objectAtIndex:i];
                if ([objImg[@"type"] isEqualToString:@"video"]) {
                    indexRealSelectedImg--;
                }
            }
            
            for (int i = 0; i < [arrMedia count]; i++) {
                NSDictionary *objImg = [arrMedia objectAtIndex:i];
                if ([objImg[@"type"] isEqualToString:@"photo"]) {
                    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:objImg[@"src"]]]];
                }
            }
            
            self.photos = photos;

            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = displayActionButton;
            browser.displayNavArrows = displayNavArrows;
            browser.displaySelectionButtons = displaySelectionButtons;
            browser.alwaysShowControls = displaySelectionButtons;
            browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            browser.enableGrid = enableGrid;
            browser.startOnGrid = startOnGrid;
            browser.enableSwipeToDismiss = YES;
            [browser setCurrentPhotoIndex:indexRealSelectedImg];
            
            // Reset selections
            if (displaySelectionButtons) {
                _selections = [NSMutableArray new];
                for (int i = 0; i < photos.count; i++) {
                    [_selections addObject:[NSNumber numberWithBool:NO]];
                }
            }
            
            // Show Modal
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
            
            
            // Test reloading of data after delay
            double delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            });
            
        }
        
    }
}

- (void)PostCell:(id)cell didClickedOnUserAvatar:(id)sender {
    
}

- (void)PostCell:(id)cell wantToOpenURL:(NSURL *)url {
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[url absoluteString]];
    [self presentViewController:webViewController animated:YES completion:NULL];
}


#pragma mark - ACTION ON COMMENT CELL

- (void)CommentCell:(id)cell didClickedShowFullPostContentButton:(id)sender {
    
}

- (void)CommentCell:(id)cell didClickedReportButton:(id)sender {
    
}

- (void)CommentCell:(id)cell didClickedOnUserAvatar:(id)sender {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSMutableDictionary* postInfo = [_postsList objectAtIndex:indexPath.section];
    NSMutableArray *comments = postInfo[@"comment"][@"items"];
    NSDictionary *commentInfo = comments[indexPath.row - 1];
    NSDictionary *userInfo = commentInfo[@"user"];
    
    if ([userInfo[@"id"] isEqualToString:[UserDefault currentUser].u_id]) {
        
        MyProfileVC *myProfileVC = [[MyProfileVC alloc] initWithNibName:@"MyProfileVC" bundle:nil];//[Main_Storyboard instantiateViewControllerWithIdentifier:@"MyProfileVC"];
        UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:myProfileVC];
        
        __block UIViewController *parentVC = self.presentingViewController;
        
        if (parentVC) {
            [parentVC dismissViewControllerAnimated:NO completion:^{
                [parentVC presentViewController:profileNavVC animated:YES completion:nil];
            }];
        } else {
            [self presentViewController:profileNavVC animated:YES completion:nil];
        }
        
    } else {
        
        ProfileVC *profileVC = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];//[self.storyboard instantiateViewControllerWithIdentifier:@"VIEW_PROFILE"];
        [profileVC setUserProfileInfo:userInfo];
        
        __block UIViewController *parentVC = self.presentingViewController;
        
        if (parentVC) {
            [parentVC dismissViewControllerAnimated:NO completion:^{
                [parentVC presentViewController:profileVC animated:YES completion:nil];
            }];
        } else {
            [self presentViewController:profileVC animated:YES completion:nil];
        }
    }
    
}

- (void)CommentCell:(id)cell wantToOpenURL:(NSURL*)url {
    
}


#pragma mark - ACTIONS

- (IBAction)actionHideKeyboard:(id)sender {
    [_composeBarView resignFirstResponder];
    _container.hidden = YES;
}

- (IBAction)actionBack:(id)sender {
    if([_delegate respondsToSelector:@selector(profileActionBack)])
    {
        [_delegate profileActionBack];
    } else {
        
        if (self.presentingViewController) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
        } else if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Play Video Delegate
- (void) donefinishedPlayVideo:(NSNotification*)aNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_moviePlayer.moviePlayer];
    [_moviePlayer.moviePlayer stop];
    [_moviePlayer dismissViewControllerAnimated:YES completion:^{
        _moviePlayer = nil;
    }];
    
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    //NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    //NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? ALERT_YES_BUTTON : ALERT_NO_BUTTON);
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    //NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Confirm user actions

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        NSString *access_token = [UserDefault currentUser].server_access_token;
        
        NSString *userId = [UserDefault currentUser].u_id;
        
        if (!access_token || access_token.length == 0 || !userId ) {
            return;
        }
        
        switch (alertView.tag) {
                
            case AlertReportPostTag:
            {
                
                NSString *postId = _postsList[activeIndexPath.section][@"id"];
                
                if (!postId) {
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"id":postId,
                                                };
                
                [manager PUT:URL_SERVER_API(API_REPORT_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    if ([Common validateResponse:responseObject]) {
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"Post was reported!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        //[Common showAlertView:APP_NAME message:successMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                        
                    } else {
                        
                        NSString* errorMsg = responseObject[@"data"][@"message"];
                        if (!errorMsg || errorMsg.length == 0) {
                            errorMsg = @"There was an issue while report this post!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while report this post!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while report this post!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];
                
                //NSLog(@"Report post");
            }
                break;
            case AlertHidePostTag:
            {
                NSString *postId = _postsList[activeIndexPath.section][@"id"];
                
                if (!postId) {
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"id":postId,
                                                };
                
                [manager PUT:URL_SERVER_API(API_HIDE_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    if ([Common validateResponse:responseObject]) {
                        
                        totalPostInCurrentRegion--;
                        paging_offset--;
                        
                        [_tableView beginUpdates];
                        [_postsList removeObjectAtIndex:activeIndexPath.section];
                        
                        NSIndexSet *deleteSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(activeIndexPath.section, 1)];
                        [_tableView deleteSections:deleteSection withRowAnimation:UITableViewRowAnimationFade];
                        //[_tableView deleteRowsAtIndexPaths:@[activeIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        
                        [_cellSizeManager invalidateCellSizeCache];
                        [_tableView endUpdates];
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"Post was reported!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:POST_HIDDEN_DELETED_NOTIFICATION object:nil];
                        
                    } else {
                        
                        
                        NSString* errorMsg = responseObject[@"data"][@"message"];
                        if (!errorMsg || errorMsg.length == 0) {
                            errorMsg = @"There was an issue while hide this post!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while hide this post!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while hide this post!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];
                
                //NSLog(@"Hide post");
                
            }
                break;
            case AlertBlockUserTag:
            {
                
                NSDictionary *post_author = _postsList[activeIndexPath.section][@"user"];
                
                NSString *blocked_userId;
                
                if (post_author) {
                    blocked_userId = post_author[@"id"];
                }
                
                if (!blocked_userId) {
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"id":blocked_userId,
                                                };
                
                [manager PUT:URL_SERVER_API(API_BLOCK_USER(blocked_userId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    if ([Common validateResponse:responseObject]) {
                        
                        //Sync block user to Parse
                        
                        NSString *blockUserEmail = post_author[@"email"];
                        
                        if (blockUserEmail) {
                            
                            PFQuery *query = [PFUser query];
                            [query whereKey:@"emailCopy" equalTo:blockUserEmail];
                            [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
                                
                                PFUser *user2 = (PFUser *)object;
                                
                                if (!user2) {
                                    
                                    [Common hideLoadingViewGlobal];
                                    
                                } else {
                                    
                                    //===The find succeeded.
                                    
                                    [PAPUtility blockUserEventually:user2 block:^(BOOL succeeded, NSError *error) {
                                        if (!error) {
                                            
                                        } else {
                                            
                                        }
                                    }];
                                }
                            }];
                        }
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"User was blocked!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                        NSDictionary *userInfo = @{ @"blockedUserId": blocked_userId };
                        [notificationCenter postNotificationName:kUserBlockedPersonNotification object:nil userInfo:userInfo];
                        [notificationCenter postNotificationName:kDecreaseUsersCountNotification object:nil];
                        
                    } else {
                        
                        NSString* errorMsg = responseObject[@"data"][@"message"];
                        if (!errorMsg || errorMsg.length == 0) {
                            errorMsg = @"There was an issue while block this user!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    }
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while block this user!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while block this user!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];
                
                //NSLog(@"Block user");
            }
                break;
            default:
                break;
        }
    }
    
}

#pragma mark - OtherUserProfileInfoHeaderViewDelegate

- (void)OtherUserProfileInfoHeaderViewDidClickShowAvatar:(UIButton*)sender {
    
    
    BOOL displayActionButton = kAllowUserSaveOtherUserAvatar;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    NSString* userAvatar = _userProfileInfo[@"avatar"];
    
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:userAvatar]]];
    
    self.photos = photos;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    // Show Modal
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
}

- (void)OtherUserProfileInfoHeaderViewDidClickSendMSG:(UIButton*)sender {
    
    NSString* receiverEmail = _userProfileInfo[@"email"];
    
    NSString *groupId = [[ISDiskCache sharedCache] objectForKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,receiverEmail]];
    
    if (self.navigationController) {

        ChatViewController *chatView = [Main_Storyboard instantiateViewControllerWithIdentifier:@"CHAT_VC"];
        chatView.fromVCtype = FromUserProfileVC;
        chatView.delegate = self;
        
        //ADTransition * transition = [[ADGhostTransition alloc] initWithDuration:0.5];
        //ADTransition * transition = [[ADSlideTransition alloc] initWithDuration:0.5 orientation:ADTransitionLeftToRight sourceRect:self.view.frame];
        
        //ADTransitioningDelegate * transitioningDelegate = [[ADTransitioningDelegate alloc] initWithTransition:transition];
        //chatView.transitioningDelegate = transitioningDelegate;
        
        //self.navigationDelegate = [[ADNavigationControllerDelegate alloc] init];
        //self.navigationController.delegate = _navigationDelegate;
        
        [self.navigationController pushViewController:chatView animated:YES];
        
        
        if (groupId) {
            
            [chatView setGroupId:groupId];
            
            [chatView setReceiverEmail:receiverEmail];
            
        } else if (receiverEmail) {
            
            [Common showLoadingViewGlobal:nil];
            
            PFUser *user1 = [PFUser currentUser];
            
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"emailCopy" equalTo:receiverEmail];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
                
                PFUser *user2 = (PFUser *)object;
                
                if (!user2) {
                    
                    [Common hideLoadingViewGlobal];
                    
                    NSLog(@"The getFirstObject request failed.");
                    
                } else {
                    
                    //===The find succeeded.
                    
                    NSLog(@"Successfully retrieved the object.");
                    
                    NSString *server_groupId = //([user1.objectId compare:user2.objectId] < 0) ? [NSString stringWithFormat:@"%@%@", user1.objectId, user2.objectId] : [NSString stringWithFormat:@"%@%@", user2.objectId, user1.objectId];
                    StartPrivateChat(user1, user2);
                    
                    //===Changed by Nguyen Truong Luu
                    
                    [chatView setGroupId:server_groupId];
                    
                    [chatView setReceiverEmail:receiverEmail];
                    
                    //===Cache groupdId
                    
                    [[ISDiskCache sharedCache] setObject:server_groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,receiverEmail]];
                    
                    //[[ISDiskCache sharedCache] setObject:groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,user2[PF_MESSAGES_LASTUSER_EMAIL]]];
                }
            }];
            
        } else {
            
        }
        
    } else {
        
        if ([_delegate respondsToSelector:@selector(profileSendMessage:receiverEmail:)]) {
            [_delegate profileSendMessage:groupId receiverEmail:receiverEmail];
        }
        
    }
    
    /*
     if (groupId) {
     
     //===Goto chatVC
     
     if ([_delegate respondsToSelector:@selector(profileSendMessage:receiverEmail:)]) {
     [_delegate profileSendMessage:groupId receiverEmail:_userProfileInfo[@"email"]];
     }
     
     } else {
     
     //===Load GroupId
     
     if (_userProfileInfo[@"email"]) {
     
     PFUser *user1 = [PFUser currentUser];
     PFQuery *query = [PFUser query];
     [query whereKey:@"emailCopy" equalTo:_userProfileInfo[@"email"]];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
     PFUser *user2 = (PFUser *)object;
     if (!user2) {
     NSLog(@"The getFirstObject request failed.");
     } else {
     
     //===The find succeeded.
     
     NSLog(@"Successfully retrieved the object.");
     
     NSString *groupId = //([user1.objectId compare:user2.objectId] < 0) ? [NSString stringWithFormat:@"%@%@", user1.objectId, user2.objectId] : [NSString stringWithFormat:@"%@%@", user2.objectId, user1.objectId];
     StartPrivateChat(user1, user2);
     
     //===Changed by Nguyen Truong Luu
     
     if ([_delegate respondsToSelector:@selector(profileSendMessage:receiverEmail:)]) {
     [_delegate profileSendMessage:groupId receiverEmail:_userProfileInfo[@"email"]];
     }
     
     //===Cache groupdId
     
     [[ISDiskCache sharedCache] setObject:groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,_userProfileInfo[@"email"]]];
     //[[ISDiskCache sharedCache] setObject:groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,user2[PF_MESSAGES_LASTUSER_EMAIL]]];
     }
     }];
     }
     }
     */
    
    
}

#pragma mark - ChatViewDelegate

- (void) chatViewActionBack:(ChatViewController*)chatView {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) chatViewActionBlockUserSuccess:(ChatViewController *)chatView status:(NSString *)status{

    MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
    UserListVC * usersVC = mainVC.listUsersViewController;
    
    if (usersVC) {
        [usersVC setRegionMap:[[mainVC homeViewController] recalculatedRadiusUpdate]];
    }
    
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [SVProgressHUD showInfoWithStatus:status];
        }];
    }
    
}

@end

//
//  UserListVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "UserListVC.h"
#import "ReportUserView.h"
#import "UIImage+RoundedCorner.h"
#import "UITableView+ReloadData.h"

#define AlertBlockUserTag           66
#define AlertReportUserTag          88

@interface UserListVC () <SDWebImageManagerDelegate,UserCellDelegate,ReportUserViewDelegate,PopoverViewDelegate,UIAlertViewDelegate>
{
    CGFloat         regionMapTemp;
    BOOL            isloading;
    NSUInteger      paging_offset;
    NSUInteger      totalUserInCurrentRegion;
    NSIndexPath      *activeIndexPath;
}
@property (nonatomic, strong) PopoverView *popoverView;
@property (nonatomic, strong) NSMutableArray *arrayUsers;
@property (nonatomic, strong) AFHTTPRequestOperation *loadingOperation;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation UserListVC

- (NSArray*)arrayUsers {
    return _arrayUsers;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        _arrayUsers = [[NSMutableArray alloc] init];
        
        isloading = NO;
        paging_offset = 0;
        totalUserInCurrentRegion = 0;
        
    }
    return self;
}

- (void)setRegionMap:(CGFloat)regionMap {
    
    _regionMap = regionMap;
    
    //Do something when have new regionMap
    if ((_regionMap > 0 && _regionMap != regionMapTemp)) {
        
        isloading = YES;
        
        regionMapTemp = _regionMap;
        
        _regionMap = 0;
        
        if (_arrayUsers) {
            
            paging_offset = 0;
            
            totalUserInCurrentRegion = 0;
        }
        
        [self getUsersWithRegionMap:regionMapTemp limit:LIMIT_LIST_USER];
        
    } else {
        
        //Else do nothing

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).locationTracker.delegate = self;
    //_tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    //  Refresh control
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(reloadUserList) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:_refreshControl atIndex:0];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChangedRegionmap:) name:kUserChangedCurrentRegionMapNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userBlockedPerson:) name:kUserBlockedPersonNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataWhenHaveInternetConnection)
                                                 name:kInternetConnectionIsEnableNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userChangedRegionmap:(NSNotification *)notification {
    CGFloat regionMap = [[[notification userInfo] valueForKey:@"regionMap"] floatValue];
    self.regionMap = regionMap;
}

- (void)userBlockedPerson:(NSNotification *)notification {
    
    NSString *blockedUserId = [[notification userInfo] valueForKey:@"blockedUserId"];
    NSString *blockedUserEmail = [[notification userInfo] valueForKey:@"blockedUserEmail"];
    
    if (![self isVisible]) {
        //If viewcontroller is not display , remove user from old data
        
        if (blockedUserId) {
            
            for (NSInteger i = 0; i < _arrayUsers.count; i++) {
                
                NSMutableDictionary *userInfo = _arrayUsers[i];
                
                NSString* userId = userInfo[@"id"];
                
                if ([blockedUserId isEqualToString:userId]) {
                    //Remove
                    
                    NSIndexPath *blockedUserIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    [_tableView beginUpdates];
                    [_arrayUsers removeObjectAtIndex:i];
                    [_tableView deleteRowsAtIndexPaths:@[blockedUserIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];

                    break;
                }
            }
            
        } else if (blockedUserEmail) {
            
            for (NSInteger i = 0; i < _arrayUsers.count; i++) {
                
                NSMutableDictionary *userInfo = _arrayUsers[i];
                
                NSString* userEmail = userInfo[@"email"];
                
                if ([blockedUserEmail isEqualToString:userEmail]) {
                    //Remove
                    
                    NSIndexPath *blockedUserIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    [_tableView beginUpdates];
                    [_arrayUsers removeObjectAtIndex:i];
                    [_tableView deleteRowsAtIndexPaths:@[blockedUserIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];
                    
                    break;
                }
            }
        }
    }
}


- (void)reloadDataWhenHaveInternetConnection {
    
    if (_arrayUsers.count == 0) {
        [self actionReloadUserList];
    }
    
}

#pragma mark - TABLE DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_arrayUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usersCellId" forIndexPath:indexPath];
    cell.delegate = self;
    
    NSMutableDictionary *userInfo = _arrayUsers[indexPath.row];
    
    [cell fillUserInfoToView:userInfo];
    
    return cell;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
    
    //UserCell *cell = (UserCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIImage *roundedImage = [[image scaleToSize:/*cell.imgView_UserAvatar.bounds.size*/CGSizeMake(40, 40)] imageByCenterSquareCircleImageToFitSquare:/*cell.imgView_UserAvatar.bounds.size.width*/20 borderWidth:2.0 borderColor:[UIColor whiteColor]];
    return roundedImage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //[self performSegueWithIdentifier:@"segueToProfile" sender:nil];
    
    if([_delegate respondsToSelector:@selector(userListActionGoProfile:)])
    {
        if ([_arrayUsers count] > 0 && ([_arrayUsers count] > indexPath.row)) {
            [_delegate userListActionGoProfile:_arrayUsers[indexPath.row]];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
     [cell setSeparatorInset:UIEdgeInsetsZero];
     }
     
     if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
     [cell setLayoutMargins:UIEdgeInsetsZero];
     }
     */
    
    if ((indexPath.row ==  [_arrayUsers count] - 2) && totalUserInCurrentRegion > _arrayUsers.count && !isloading) {
        //If scroll to bottom cell and still have mor post => Call to loadmore post
        isloading = YES;
        [self getUsersWithRegionMap:regionMapTemp limit:LIMIT_LIST_USER];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    /*
     if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
     [_tableView setSeparatorInset:UIEdgeInsetsZero];
     }
     
     if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
     [_tableView setLayoutMargins:UIEdgeInsetsZero];
     }
     */
}


#pragma mark - WEBSERVICE FUNCTIONS

- (void)reloadUserList {
    
    if (regionMapTemp > 0) {
        
        isloading = YES;
        
        if (_arrayUsers) {
            
            paging_offset = 0;
            
            totalUserInCurrentRegion = 0;
        }
        
        [self getUsersWithRegionMap:regionMapTemp limit:LIMIT_LIST_USER];
        
    }
    
}

- (void) getUsersWithRegionMap:(CGFloat)regionMap limit:(NSUInteger)limit {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *latitude = [UserDefault currentUser].strLat;
    NSString *longitude = [UserDefault currentUser].strLong;
    
    if (!access_token || access_token.length == 0 || !latitude || !longitude) {
        return;
    }
    
    [Common showNetworkActivityIndicator];
    
    [self.loadingOperation cancel];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSDictionary *request_param = @{
                                    @"access_token":access_token,
                                    @"latitude":latitude,
                                    @"longitude":longitude,
                                    @"distance":@(regionMap),
                                    @"offset":@(paging_offset),
                                    @"limit":@(limit),
                                    };
    
    self.loadingOperation = [manager GET:URL_SERVER_API(API_LIST_USER) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideLoadingViewGlobal];
        
        [Common hideNetworkActivityIndicator];
        
        [self.refreshControl endRefreshing];
        
        if ([Common validateResponse:responseObject]) {
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                //NSLog(@"All user: %@",responseObject[@"data"]);
                
                if (object[@"data"][@"total"] != nil) {
                    totalUserInCurrentRegion = [object[@"data"][@"total"] intValue];
                }
                
                if (paging_offset == 0) {
                    [_arrayUsers removeAllObjects];
                }
                
                NSArray *newUsers;
                
                newUsers = object[@"data"][@"items"];
                
                if (newUsers && newUsers.count > 0) {
                    
                    NSMutableArray *mutableUsers = [NSMutableArray new];
                    
                    [newUsers enumerateObjectsUsingBlock:^(NSDictionary * user, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        NSMutableDictionary *mutableUser = [user mutableCopy];
                        
                        [mutableUsers addObject:mutableUser];
                    }];
                    
                    [_arrayUsers addObjectsFromArray:mutableUsers];
                    
                    paging_offset+=newUsers.count;
                    
                } else {
                    
                    //Have no user
                }
                
                [_tableView reloadData:NO completion:^(BOOL finished) {
                    //
                    
                }];
                
            }];
            

        }
        
        isloading = NO;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
        [self.refreshControl endRefreshing];
        
        isloading = NO;
    }];
    
}

- (IBAction)actionBackOfUser:(id)sender {
    if([_delegate respondsToSelector:@selector(userListActionBack)])
    {
        [_delegate userListActionBack];
    }
}

- (void) actionReloadUserList {
    if (regionMapTemp > 0 && !isloading) {
        isloading = YES;
        [self getUsersWithRegionMap:regionMapTemp limit:LIMIT_LIST_USER];
    }
}

#pragma mark - LOCATION TRACKER DELEGATE
- (void) locationUpdated {
    //NSLog(@"update location...");
    if (regionMapTemp > 0 && !isloading) {
        isloading = YES;
        [self getUsersWithRegionMap:regionMapTemp limit:LIMIT_LIST_USER];
    }
}

#pragma mark - UserCellDelegate

- (void)UserCell:(UserCell*)cell didClickedReportButton:(id)sender {
    
    UIButton *button = (UIButton*) sender;
    
    activeIndexPath = [_tableView indexPathForCell:cell];
    
    NSMutableDictionary* userInfo = [_arrayUsers objectAtIndex:activeIndexPath.row];
    
    CGRect cellRect = [self.tableView convertRect:[cell convertRect:button.frame toView:self.tableView] toView:self.view];
    CGPoint showPoint = CGPointMake(CGRectGetMidX(cellRect), CGRectGetMidY(cellRect));
    
    ReportUserView *reportView = [[ReportUserView alloc] init];
    reportView.delegate = self;
    self.popoverView = [PopoverView showPopoverAtPoint:showPoint
                                                inView:self.view
                                              maskType:PopoverMaskTypeGradient
                                       withContentView:reportView
                                              delegate:self];
    
}

#pragma mark - ReportViewDelegate

- (void)reportpostView:(ReportUserView*)view didPressedReportButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to report this user?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertReportUserTag];
    }];
}

- (void)reportpostView:(ReportUserView*)view didPressedBlockUserButton:(id)sender {
    
    [self.popoverView dismiss:YES completion:^{
        [Common showAlertView:APP_NAME message:@"Do you really want to block user and remove all posts?" delegate:self cancelButtonTitle:ALERT_NO_BUTTON arrayTitleOtherButtons:@[ALERT_YES_BUTTON] tag:AlertBlockUserTag];
    }];
}

#pragma mark - PopoverViewDelegate Methods

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.popoverView = nil;
}

#pragma mark - PopoverMethods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // get new center coords
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    if (_popoverView) {
        // popover is visible, so we need to either reposition or dismiss it (dismising is probably best to avoid confusion)
        bool dismiss = YES;
        if (dismiss) {
            [_popoverView dismiss:NO completion:^{
                //
            }];
        }
        else {
            // move popover
            [_popoverView animateRotationToNewPoint:center
                                             inView:self.view
                                       withDuration:duration];
        }
    }
}

#pragma mark - Confirm user actions

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        //Do action
        
        NSString *access_token = [UserDefault currentUser].server_access_token;
        
        NSString *userId = [UserDefault currentUser].u_id;
        
        NSDictionary *activeUser = _arrayUsers[activeIndexPath.row];
        
        if (!access_token || access_token.length == 0 || !userId ) {
            return;
        }
        
        switch (alertView.tag) {
                
            case AlertReportUserTag:
            {
                //===Report this user
                
                NSString *reported_userId = activeUser[@"id"];
                
                if (!reported_userId) {
                    return;
                }
                
                [Common showNetworkActivityIndicator];
                
                AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
                NSDictionary *request_param = @{@"access_token":access_token,
                                                @"id":reported_userId,
                                                };
                
                [manager PUT:URL_SERVER_API(API_REPORT_USER(reported_userId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
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
                            errorMsg = @"There was an issue while report this user!\nPlease try again later!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:errorMsg];
                        
                        //[Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [Common hideNetworkActivityIndicator];
                    
                    //completion(NO,nil);
                    
                    [SVProgressHUD showInfoWithStatus:@"There was an issue while report this user!\nPlease try again later!"];
                    
                    //[Common showAlertView:APP_NAME message:@"There was an issue while report this user!\nPlease try again later!" delegate:nil cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                }];
                
            }
                break;

            case AlertBlockUserTag:
            {
                
                //===Block this user
                
                NSString *blocked_userId = activeUser[@"id"];
                
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
                        
                        NSString *blockUserEmail = activeUser[@"email"];
                        
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
                        
                        totalUserInCurrentRegion--;
                        paging_offset--;
                        
                        [_tableView beginUpdates];
                        [_arrayUsers removeObjectAtIndex:activeIndexPath.row];
                        [_tableView deleteRowsAtIndexPaths:@[activeIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [_tableView endUpdates];
                        
                        NSString* successMsg = responseObject[@"data"][@"message"];
                        if (!successMsg || successMsg.length == 0) {
                            successMsg = @"User was blocked!";
                        }
                        
                        [SVProgressHUD showInfoWithStatus:successMsg];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDecreaseUsersCountNotification object:nil];
                        
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

@end

//
//  SinglePostVC.m
//  Skope
//
//  Created by Nguyen Truong Luu on 10/26/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import "SinglePostVC.h"

@interface SinglePostVC ()
@property (nonatomic, strong) NSString *postID;
@end

@implementation SinglePostVC

- (void)setPostID:(NSString *)postID {
    _postID = postID;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    //  Style for NavigationBar
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    
    //  Custom navigationBar color
    
    
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    
    
    
    //  Custom NavigationBar back button
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_pl"] style:UIBarButtonItemStylePlain target:self action:@selector(actionPostBack:)];
    backButton.tintColor = APP_COMMON_RED_COLOR;
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    
    //  Remove refreshControl when on singleView VC
    
    [self.tableView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isMemberOfClass:[UIRefreshControl class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    
    
    //  Load single post with postID
    
    [self fetchSinglePostWithPostID:_postID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)fetchSinglePostWithPostID:(NSString*)postID {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    
    if (!access_token || access_token.length == 0 || !postID) {
        return;
    }
    
    [Common showNetworkActivityIndicator];

    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    
    NSMutableDictionary *request_param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          access_token,@"access_token",
                                          postID,@"id",
                                          nil
                                          ];
    
    [manager GET:URL_SERVER_API(API_SINGLE_POST(postID)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
        if ([Common validateResponse:responseObject]) {
            
            NSMutableArray *newObjects = [NSMutableArray new];
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                
                NSBlockOperation *blockoperation = [NSBlockOperation blockOperationWithBlock:^{
                    
                    if (success &&  object[@"data"][@"post"] != nil) {

                        totalPostInCurrentRegion = 1;
                        
                        NSMutableDictionary *postInfo = object[@"data"][@"post"];
                        
                        postInfo[@"show_full_content"] = @"false";
                        
                        NSMutableArray *comments = [postInfo[@"comment"][@"items"] mutableCopy];
                        
                        postInfo[@"comment"][@"items"] = comments;
                        
                        [newObjects addObject:postInfo];
                        
                    }
                    
                }];
                
                [blockoperation setCompletionBlock:^{
                    
                    runOnMainQueueWithoutDeadlocking(^{
                        
                        if (success &&  newObjects.count > 0) {
                            
                            [self.postsList addObjectsFromArray:newObjects];
                            [self.postsList addObject:@"jummy"];
                            
                            [self.tableView reloadData];
                            
                        } else {
                            
                            // Have no post return
                            
                        }
                        
                        isloading = NO;
                    });
                    
                }];
                
                [[[NSOperationQueue alloc] init] addOperation:blockoperation];
                
            }];
            
        } else {
            
            isloading = NO;
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            if (errorMsg) {
                [Common showAlertView:APP_NAME message:errorMsg delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        
        isloading = NO;
        
    }];
}

- (IBAction)actionPostBack:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

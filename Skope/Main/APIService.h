//
//  APIService.h
//  ProjectBase
//
//  Created by CHAU HUYNH on 9/19/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

//------SETUP SERVER IP------//

//SERVER OF ODC TEAM

#define SERVER_PORT @"80"

#define URL_SERVER_API_FULL [NSString stringWithFormat:@"%@:%@", SERVER_IP, SERVER_PORT]
#define URL_SERVER_API(method) [NSString stringWithFormat:@"%@%@",URL_SERVER_API_FULL,method]


#define API_USER_LOGIN                      @"/user/auth"
#define API_USER_LOGOUT                      @"/user/auth"
#define API_GET_USER_POST_LIST              @"/user/stat"
#define API_USER_RADIUS                     @"/user/newpostradius"
#define API_COMPOSE_POST                    @"/user/post"
#define API_UPLOAD_MEDIA(post_id)           [NSString stringWithFormat:@"/post/%@/media", post_id]
#define API_GET_POST_OF_USER(user_id)       [NSString stringWithFormat:@"/user/%@/post", user_id]
#define API_GET_ACTIVITIES_OF_USER          @"/user/activities"
#define API_COMMENT_FOR_A_POST(post_id)     [NSString stringWithFormat:@"/post/%@/comment", post_id]
#define API_RESET_NOTIFICATION              @"/user/notification"
#define API_DEVICE_TOKEN                    @"/user/device_token"
#define API_PUSH_MSG_NOTIFICATION_USERID(user_id)  [NSString stringWithFormat:@"/user/%@/message", user_id]
#define API_PUSH_MSG_NOTIFICATION_EMAIL     @"/user/id/message"

#define API_UPDATE_LOCATION                 @"/user/location"
#define API_LIST_USER                       @"/user/search"
#define API_LIST_POST                       @"/post/search"
#define API_SINGLE_POST(post_id)            [NSString stringWithFormat:@"/post/%@", post_id]
#define API_LIKE_DISLIKE_POST(post_id)      [NSString stringWithFormat:@"/post/%@/vote", post_id]

#define API_CHANGE_NAME_MY_PROFILE @"/user/profile"
#define API_CHANGE_AVATAR_MY_PROFILE @"/user/avatar"

#define API_GET_PROFILE(user_id) [NSString stringWithFormat:@"/user/%@", user_id]
#define KEY_RESPONE_LOGIN_SUCCESS @"success"

//========New report/hide/block functions

#define API_REPORT_USER(user_id)                        [NSString stringWithFormat:@"/user/%@/report", user_id]     //PUT
#define API_REPORT_EMAIL(user_email,access_token)       [NSString stringWithFormat:@"/user/id/report?email=%@&access_token=%@", user_email,access_token]     //PUT
#define API_BLOCK_USER(user_id)                         [NSString stringWithFormat:@"/user/%@/block", user_id]      //PUT
#define API_BLOCK_EMAIL(user_email,access_token)        [NSString stringWithFormat:@"/user/id/block?email=%@&access_token=%@", user_email,access_token]      //PUT
#define API_REPORT_POST(post_id)                        [NSString stringWithFormat:@"/post/%@/report", post_id]     //PUT
#define API_HIDE_POST(post_id)                          [NSString stringWithFormat:@"/post/%@/hide", post_id]       //PUT

#define API_DELETE_POST(post_id)                        [NSString stringWithFormat:@"/post/%@", post_id]            //DELETE



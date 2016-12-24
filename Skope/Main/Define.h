//
//  Define.h
//  Skope
//
//  Created by Huynh Phong Chau on 2/20/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//


#define APP_NAME @"Skope"

#define APP_Terms_of_Service                        @"http://www.speakgeo.com/skope/terms.html"
#define APP_Privacy_Policy                          @"http://www.speakgeo.com/skope/privacy.html"

#ifdef DEBUG
#define SERVER_IP                                   @"http://dev.skope.speakgeo.com"
#define PARSE_APPLICATION_ID                        @"jwbGT0QoS4COKtkJIkm6E1AsEefHxe8Irae9YQTi"
#define PARSE_CLIENT_ID                             @"q6e9fNp9m77zxkCpm3tfdEvHXqSIxkRHZKTaKjY9"
#else
#define SERVER_IP                                   @"http://live.skope.speakgeo.com"
#define PARSE_APPLICATION_ID                        @"PLDnns9YMTJS7Kbge8k2hwAlzhpzWkGt8yxz5rtn"
#define PARSE_CLIENT_ID                             @"PdT06CPwWBXN2ruNNZuXEeekM4o2Eyrw7KQIR4Wb"
#endif

#define LOGENTRIED_TOKEN                            @"533dd11c-2e7b-4ef7-8c60-784a4742f9d1"

#define LINKEDIN_REDIRECT_URI                       @"http://www.speakgeo.com/skope"
#define LINKEDIN_CLIENT_ID                          @"77ppyea0s5da3p"
#define LINKEDIN_CLIENT_SECRET                      @"XVzCztEipewMM54s"

#define QUICKBLOX_PASSWORD                          @"skope123"
#define PARSE_DEFAULT_PASSWORD                      @"Skope@123"

//Unit: mets
#define DISTANCE_FILTER_LOCATION                    100

//Unit : seconds
#define TIME_TO_RECALL_WS_UPDATE_LOCATION           5
#define TIME_TO_RECALL_WS_UPDATE_CHAT               5
#define TIME_TO_RECALL_WS_UPDATE_USERLIST           5

#define TIME_TO_RESTART_CHECKING_LOCATION           5
#define TIME_TO_RESTART_LOCATION                    5

#define APP_DELEGATE                            (AppDelegate *)[UIApplication sharedApplication].delegate

#define IS_OS_8_OR_LATER                        ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_OS_7_OR_LATER                        ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] == NSOrderedDescending)

//===Notifications name


#define NEW_MSG_NOTIFICATION                    @"NEW_MSG_NOTIFICATION"

#define NEW_POST_NOTIFICATION                   @"NEW_POST_NOTIFICATION"

#define NEW_COMMENT_LIKE_NOTIFICATION           @"NEW_COMMENT_LIKE_NOTIFICATION"

#define BAGED_COUNT_CHANGED_NOTIFICATION        @"BAGED_COUNT_CHANGED_NOTIFICATION"

#define APP_DID_BACKGROUND_NOTIFICATION         @"APP_DID_BACKGROUND_NOTIFICATION"

#define APP_DID_ACTIVE_NOTIFICATION             @"APP_DID_ACTIVE_NOTIFICATION"

#define POST_HIDDEN_DELETED_NOTIFICATION        @"POST_HIDDEN_DELETED_NOTIFICATION"

#define APP_DEVICE_TOKEN                        @"current_device_token"

#define kUserChangedCurrentRegionMapNotification    @"UserChangedCurrentRegionMapNotification"
#define kUserChangedCurrentLocationNotification     @"UserChangedCurrentLocationNotification"
#define kUserBlockedPersonNotification              @"UserBlockedPersonNotification"
#define kUserBlockedPersonFromChatVCNotification    @"UserBlockedPersonFromChatVCNotification"
#define kDecreaseUsersCountNotification             @"DecreaseUsersCountNotification"
#define kInternetConnectionIsEnableNotification     @"InternetConnectionIsEnableNotification"

///===Fonts

#define FONT_TEXT_COMPOSE_BAR                   [UIFont fontWithName:@"HelveticaNeue" size:15.0f]
#define FONT_NOTIFICATION_BAGED                 [UIFont fontWithName:@"HelveticaNeue" size:14.0f]
#define FONT_TEXT_BAGED_MESSAGE_COUNT           [UIFont fontWithName:@"HelveticaNeue" size:20.0f]


#define FONT_TEXT_CAMERA_CHOOSE                 [UIFont fontWithName:@"HelveticaNeue" size:20.0f]
#define FONT_TEXT_CAMERA_CHOOSE_BOLD            [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f]

#define FONT_TEXT_POST_AUTHOR_NAME              [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f]
#define FONT_TEXT_POST_CONTENT                  [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]
#define FONT_TEXT_POST_TIME                     [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f]
#define FONT_TEXT_POST_DISTANCE                 [UIFont fontWithName:@"HelveticaNeue" size:12.0f]
#define FONT_TEXT_POST_LIKE_COUNT               [UIFont fontWithName:@"HelveticaNeue" size:15.0f]
#define FONT_TEXT_POST_DISLIKE_COUNT            [UIFont fontWithName:@"HelveticaNeue" size:15.0f]

#define FONT_TEXT_COMMENT_AUTHOR_NAME           [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]
#define FONT_TEXT_COMMENT_CONTENT               [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]
#define FONT_TEXT_COMMENT_TIME                  [UIFont fontWithName:@"HelveticaNeue" size:11.0f]


#define SIZE_IMAGE_AFTER_CAPTURE                CGSizeMake(1600, 1600)

#define HEIGHT_NAME_AREA_POST_LIST              70
#define HEIGHT_LIKE_DISLIKE_AREA_POST_LIST      70
#define WIDTH_CONTENT_AREA_POST_LIST            290

//=====Added by Nguyen Truong Luu
#define WIDTH_CONTENT_AREA_POST_LIST_PROFILE    270
//==========================

#define CELL_CONTENT_CORNER_RADIUS              4.0f
#define WIDTH_A_IMAGE_VIDEO_POST                70

#define LIMIT_LIST_ACVITITY                         10
#define LIMIT_LIST_POST                         10
#define LIMIT_LIST_COMMENT                      10
#define LIMIT_LIST_USER                         100

#define HEIGHT_SLIDE_IMAGE_POST_LIST            250

//=====Login

#define ALERT_YES_BUTTON                        @"Yes"
#define ALERT_NO_BUTTON                         @"No"

#define ALERTVIEW_OK_BUTTON                     @"OK"
#define MSS_LOGIN_TRY_AGAIN                     @"Please log in again!"
#define MSS_NEED_LOGIN                          @"You need to login to access this app!"
#define HAVE_AN_ERROR                           @"Something went wrong"
#define MSS_TRY_AGAIN                           @"Please try again!"

#define maximumCircleSlider                     101.0f
#define minximumCircleSlider                    1.0f
#define unitRadiusCircleSlider                  1000.0f

//======App Features Key=======

#define kImageEncodeQualityForUpload                    0.5
#define kAllowUserSaveOtherUserAvatar                   NO
#define kAllowUserShowCommentAuthorProfile              NO
#define kAllowUserShowActivityAuthorProfile             NO
#define kAllowUserShowPostAuthorProfile                 YES
#define kAllowUserShowFullAvatar                        YES
#define kAllowLinkDetectOnPostContent                   NO
#define kAllowAutoDetectConnectionAndRefreshData        NO

//======NotificationCenter========

#define DROP_DOWN_ALERT_FOLDER_IMG                  [UIImage imageNamed:@"folder.png"]
#define DROP_DOWN_ALERT_BACKGROUND_IMG              [UIImage imageNamed:@"bg-purple.png"]
#define DROP_DOWN_ALERT_TRIANGLE_ALERT_IMG          [UIImage imageNamed:@"dropdown-alert.png"]
#define USER_DEFAULT_AVATAR                         [UIImage imageNamed:@"user_default_avatar.png"]
//======Map========

#define radiusInit 1000

#define APP_COMMON_GREEN_COLOR                  [UIColor colorWithRed:134.0/255 green:208.0/255 blue:61.0/255 alpha:1.0]
#define APP_COMMON_BLUE_COLOR                   [UIColor colorWithRed:21.0/255 green:143.0/255 blue:191.0/255 alpha:1.0]
#define APP_COMMON_RED_COLOR                    [UIColor colorWithRed:204.0/255 green:44.0/255 blue:44.0/255 alpha:1.0]
#define APP_COMMON_LIGHT_GRAY_BACKGROUND_COLOR  [UIColor colorWithRed:231.0/255 green:235.0/255 blue:237.0/255 alpha:1.0]
#define APP_COMMON_LIGHT_GRAY_TEXT              [UIColor lightGrayColor]

#define POST_BORDER_COLOR                       [UIColor colorWithWhite:0.7 alpha:0.8]
#define COLOR_GREEN_LIKE                        APP_COMMON_GREEN_COLOR
#define COLOR_BUTTON_POST_SEND                  APP_COMMON_GREEN_COLOR

//  LIKE DISLIKE FONT AND COLOR

#define COLOR_LIKE_ENABLE                       APP_COMMON_GREEN_COLOR
#define COLOR_DISLIKE_ENABLE                    APP_COMMON_RED_COLOR
#define COLOR_POST_TIME                         APP_COMMON_LIGHT_GRAY_TEXT
#define COLOR_POST_DISTANCE                     APP_COMMON_GREEN_COLOR


#define COLOR_LIKE_DISLIKE_DISABLE              [UIColor lightGrayColor]

//  COMMENT COLORS

#define COLOR_COMMENT_AUTHOR_NAME               APP_COMMON_GREEN_COLOR
#define COLOR_COMMENT_TIME                      APP_COMMON_LIGHT_GRAY_TEXT
#define COLOR_COMMENT_CONTENT                   APP_COMMON_LIGHT_GRAY_TEXT

//  RANGEVIEW COLORS

#define RANGE_VIEW_LIKE_AREA_COLOR              [UIColor colorWithRed:142.0/255 green:197.0/255 blue:33.0/255 alpha:1.0]
#define RANGE_VIEW_DISLIKE_AREA_COLOR           [UIColor colorWithRed:255.0/255 green:44.0/255 blue:45.0/255 alpha:1.0]

#define COLOR_POST_LIKE_COUNT                   RANGE_VIEW_LIKE_AREA_COLOR
#define COLOR_POST_DISLIKE_COUNT                RANGE_VIEW_DISLIKE_AREA_COLOR

#define FONT_NOTIFICATION_TITLE                 [UIFont fontWithName:@"HelveticaNeue" size:17.0f]
#define FONT_NOTIFICATION_CONTENT               [UIFont fontWithName:@"HelveticaNeue" size:13.0f]

#define FONT_LIKE_DISLIKE_BUTTON_ENABLE         [UIFont fontWithName:@"HelveticaNeue" size:13.0f]
#define FONT_LIKE_DISLIKE_BUTTON_DISABLE        [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"		//	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class
//-----------------------------------------------------------------------
#define		PF_USER_CLASS_NAME					@"_User"				//	Class name
#define		PF_USER_OBJECTID					@"objectId"				//	String
#define		PF_USER_USERNAME					@"username"				//	String
#define		PF_USER_PASSWORD					@"password"				//	String
#define		PF_USER_EMAIL						@"email"				//	String
#define		PF_USER_EMAILCOPY					@"emailCopy"			//	String
#define		PF_USER_FULLNAME					@"fullname"				//	String
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"		//	String
#define		PF_USER_FACEBOOKID					@"facebookId"			//	String
#define		PF_USER_PICTURE						@"picture"				//	File
#define		PF_USER_THUMBNAIL					@"thumbnail"			//	File
//-----------------------------------------------------------------------
#define		PF_ACTIVITY_CLASS_NAME              @"Activity"             //	Class name
#define		PF_ACTIVITY_TYPEKEY                 @"type"                 //	String
#define		PF_ACTIVITY_FROMUSERKEY             @"fromUser"             //  _User
#define		PF_ACTIVITY_TOUSERKEY               @"toUser"               //  _User
//-----------------------------------------------------------------------
#define		PF_CHAT_CLASS_NAME					@"Chat"					//	Class name
#define		PF_CHAT_USER						@"user"					//	Pointer to User Class
#define		PF_CHAT_GROUPID						@"groupId"				//	String
#define		PF_CHAT_TEXT						@"text"					//	String
#define		PF_CHAT_PICTURE						@"picture"				//	File
#define		PF_CHAT_VIDEO						@"video"				//	File
#define		PF_CHAT_CREATEDAT					@"createdAt"			//	Date
//-----------------------------------------------------------------------
#define		PF_GROUPS_CLASS_NAME				@"Groups"				//	Class name
#define		PF_GROUPS_NAME						@"name"					//	String
//-----------------------------------------------------------------------
#define		PF_MESSAGES_CLASS_NAME				@"Messages"				//	Class name
#define		PF_MESSAGES_USER					@"user"					//	Pointer to User Class
#define		PF_MESSAGES_GROUPID					@"groupId"				//	String
#define		PF_MESSAGES_DESCRIPTION				@"description"			//	String
#define		PF_MESSAGES_LASTUSER_EMAIL          @"lastUserEmail"			//	String
#define		PF_MESSAGES_LASTUSER				@"lastUser"				//	Pointer to User Class
#define		PF_MESSAGES_LASTMESSAGE				@"lastMessage"			//	String
#define		PF_MESSAGES_COUNTER					@"counter"				//	Number
#define		PF_MESSAGES_STATUS					@"status"				//	String
#define		PF_MESSAGES_UPDATEDACTION			@"updatedAction"		//	Date
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"






//
//  usersCell.m
//  Skope
//
//  Created by CHAU HUYNH on 2/11/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "UserCell.h"

@interface UserCell ()

@end

@implementation UserCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _imgView_UserAvatar.layer.cornerRadius = 35.0;
    _imgView_UserAvatar.layer.masksToBounds = YES;
    //_lbl_DistanceToMe.lineBreakMode = NSLineBreakByTruncatingMiddle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.lbl_UserName.text = @"";
    self.lbl_DistanceToMe.text = @"";
    self.imgView_UserAvatar.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}


- (void)fillUserInfoToView:(NSMutableDictionary*)userInfo {

    NSString *kilometString = [NSString stringWithFormat:@"%.0f km away", [userInfo[@"location"][@"distance"] floatValue]];
    
    self.lbl_DistanceToMe.text = kilometString;
    self.lbl_UserName.text = userInfo[@"name"];
    [self.imgView_UserAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo[@"avatar"]] placeholderImage:USER_DEFAULT_AVATAR];
    
    CGSize constrainedSize = CGSizeZero;
    constrainedSize.width = MAXFLOAT;
    constrainedSize.height = self.lbl_DistanceToMe.bounds.size.height;
    
    CGSize kilometString_size = [kilometString boundingRectWithSize:constrainedSize
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: self.lbl_DistanceToMe.font}
                                                            context:nil].size;
    
    NSString *next_to_distance = userInfo[@"location"][@"next_to_distance"];
    
    if (next_to_distance && next_to_distance.length > 0) {
        
        NSString *nextToDistance = userInfo[@"location"][@"next_to_distance"];
        
        NSString *newLocationString = [NSString stringWithFormat:@"%@ | %@",nextToDistance,self.lbl_DistanceToMe.text];
        
        NSString *substring = @" |";
        
        CGFloat pix = self.lbl_DistanceToMe.bounds.size.width - kilometString_size.width - 5;
        NSString *result = [self truncatedStringFrom:newLocationString toFit:self.lbl_DistanceToMe atPixel:pix atPhrase:substring];
        
        self.lbl_DistanceToMe.text = result;
        
    } else {
        
        CLLocationDegrees lat = [userInfo[@"location"][@"latitude"] floatValue];
        CLLocationDegrees lng = [userInfo[@"location"][@"longitude"] floatValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(),^ {
                
                // do stuff with placemarks on the main thread
                
                if (placemarks.count == 1) {
                    
                    CLPlacemark *place = [placemarks objectAtIndex:0];
                    
                    NSString *city = [place.addressDictionary valueForKey:@"City"];
                    NSString *state = [place.addressDictionary valueForKey:@"State"];
                    
                    NSString *nextToDistance;
                    if (city && state) {
                        nextToDistance = [NSString stringWithFormat:@"%@, %@",city,state];
                    } else {
                        nextToDistance = city?city:(state?state:@"");
                    }
                    
                    NSMutableDictionary *locationInfo = userInfo[@"location"];
                    
                    [locationInfo setObject:nextToDistance forKey:@"next_to_distance"];
                    
                    NSString *newLocationString = [NSString stringWithFormat:@"%@ | %@",nextToDistance,self.lbl_DistanceToMe.text];
                    
                    NSString *substring = @" |";
                    CGSize constrainedSize = CGSizeZero;
                    constrainedSize.width = MAXFLOAT;
                    constrainedSize.height = self.lbl_DistanceToMe.bounds.size.height;
                    
                    CGFloat pix = self.lbl_DistanceToMe.bounds.size.width - kilometString_size.width - 5;
                    
                    NSString *result = [self truncatedStringFrom:newLocationString toFit:self.lbl_DistanceToMe atPixel:pix atPhrase:substring];
                    
                    self.lbl_DistanceToMe.text = result;
                    
                }
                
            });
        }];
        
    }
    
}

- (IBAction)action_report:(id)sender {
    if ([_delegate respondsToSelector:@selector(UserCell:didClickedReportButton:)]) {
        [_delegate UserCell:self didClickedReportButton:sender];
    }
}

- (NSString *)truncatedStringFrom:(NSString *)string toFit:(UILabel *)label
                          atPixel:(CGFloat)pixel atPhrase:(NSString *)substring {
    
    // truncate the part of string before substring until it fits pixel
    // width in label
    
    NSArray *components = [string componentsSeparatedByString:substring];
    NSString *firstComponent = [components objectAtIndex:0];
    //sizeWithFont:label.font
    
    CGSize constrainedSize = CGSizeZero;
    constrainedSize.width = MAXFLOAT;
    constrainedSize.height = label.bounds.size.height;
    
    CGSize size = [firstComponent boundingRectWithSize:constrainedSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: label.font}
                                               context:nil].size;
    
    NSString *truncatedFirstComponent = firstComponent;
    
    while (size.width > pixel) {
        firstComponent = [firstComponent substringToIndex:[firstComponent length] - 1];
        truncatedFirstComponent = [firstComponent stringByAppendingString:@"..."];
        size = [truncatedFirstComponent boundingRectWithSize:constrainedSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: label.font}
                                                     context:nil].size;
    }
    
    NSArray *newComponents = [NSArray arrayWithObjects:truncatedFirstComponent, [components lastObject], nil];
    return [newComponents componentsJoinedByString:substring];
}

@end

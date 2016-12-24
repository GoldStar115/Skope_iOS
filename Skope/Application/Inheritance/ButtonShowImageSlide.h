//
//  ButtonShowImageSlide.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/21/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface ButtonShowImageSlide : ASNetworkImageNode {

}

@property(nonatomic, assign) NSInteger indexImageSelected;
@property(nonatomic, strong) NSIndexPath *indexPathCell;

@end

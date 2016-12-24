//
//  MKMapView+ZoomLevel.h
//  Skope
//
//  Created by Nguyen Truong Luu on 5/5/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
@end

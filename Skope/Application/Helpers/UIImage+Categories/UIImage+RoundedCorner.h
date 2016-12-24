// UIImage+RoundedCorner.h
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Extends the UIImage class to support making rounded corners
@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (UIImage *)imageByCenterSquareCircleImageToFitSquare:(float)square_edge_length borderWidth:(CGFloat)border_width borderColor:(UIColor*)color;
- (UIImage *)imageByCenterSquareCornerImageToFitSquare:(float)square_edge_length  borderWidth:(CGFloat)border_width borderColor:(UIColor*)color radius:(float)radius;
- (UIImage *)imageByRoundedImageWithborderWidth:(CGFloat)border_width borderColor:(UIColor*)color radius:(float)radius;
@end

//
//  UIImage+Utils.h
//  ImageBubble
//
//  Created by Richard Kirby on 3/14/13.
//  Copyright (c) 2013 Kirby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

- (UIImage *)renderAtSize:(const CGSize)size;
- (UIImage *)renderAtAphla:(const float) alpha completion:(void(^)(UIImage *renderedImage))completionHandler;
- (UIImage *) maskWithImage:(const UIImage *) maskImage;
- (UIImage *) maskWithColor:(UIColor *) color;
- (UIImage *)rotateImage:(const UIImage *)aImage;


//颜色转图片
+ (UIImage *) imageWithColor:(UIColor *) color;

+ (UIImage *) compressImageWithOldImage:(UIImage *)oldImage compressSize:(CGSize)size;

+ (UIImage *) scaleToSize:(UIImage *)img size:(CGSize)size;

- (void)saveImageToSandBoxWithFileKey:(NSString *)filekey;

+ (UIImage *)getSandBoxImageWithFilekey:(NSString *)filekey;
/**
 *  制作圆角图
 *
 *  @param image 图片
 *  @param size
 *
 *  @return
 */
+ (UIImage *)createRoundedRectImage:(UIImage*)image size:(CGSize)size;

/* KKK */
/**
 *  切圆形图片
 */
- (UIImage *)clipWithCircle;
/**
 *  切原型图带圈
 *
 *  @param width       圈宽
 *  @param borderColor 圈颜色
 */
- (UIImage *)clipCircleWithBorderWidth:(CGFloat)width borderColor:(UIColor *)borderColor;


/**
 *  重画带背景的图片 图片位于中心
 *
 *  @param name  图片名字(imageNamed)
 *  @param color 颜色
 *  @param size  画出尺寸
 *
 */
+ (UIImage *)placeholderImageWithName:(NSString *)name backgroundColor:(UIColor *)color size:(CGSize)size;

/**
 *  成长记录占位图
 *
 */
+ (UIImage *)growUpRecordPlaceholderImageWithSize:(CGSize)size;

- (UIImage *)fixOrientation;

@end

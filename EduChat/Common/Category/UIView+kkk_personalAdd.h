//
//  UIView+kkk_personalAdd.h
//  EduChat
//
//  Created by KKK on 16/4/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (kkk_personalAdd)

//@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
//@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
//@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
//@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
//@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
//@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
//@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
//@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
//@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
//@property (nonatomic) CGSize  size;        ///< Shortcut for frame.size.

/**
 Returns the view's view controller (may be nil).
 */
@property (nullable, nonatomic, readonly) UIViewController *viewController;

@end

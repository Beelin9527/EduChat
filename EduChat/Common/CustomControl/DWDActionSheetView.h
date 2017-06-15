//
//  DWDActionSheetView.h
//  EduChat
//
//  Created by Catskiy on 2016/12/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDActionSheetView;
@protocol DWDActionSheetDelegate <NSObject>

@required
/**
 *  delegate's method
 *
 *  @param actionIndex     index: top is 0 and 0++ to down but cancelBtn's index is -1
 */
- (void)actionSheet:(DWDActionSheetView *)actionSheet didSelectSheet:(NSInteger)index;

@end

/**
 *  block's call
 *
 *  @param index           the same to the delegate
 */
typedef void (^ActionSheetDidSelectSheetBlock)(DWDActionSheetView *actionSheetView, NSInteger index);


@interface DWDActionSheetView : UIView

@property (nonatomic, weak) id<DWDActionSheetDelegate> delegate;

@property (nonatomic, copy) ActionSheetDidSelectSheetBlock selectSheetBlock;


#pragma mark - Block's way

+ (void)sr_showActionSheetViewWithTitle:(NSString *)title
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                 destructiveButtonTitle:(NSString *)destructiveButtonTitle
                      otherButtonTitles:(NSArray  *)otherButtonTitles
                       selectSheetBlock:(ActionSheetDidSelectSheetBlock)selectSheetBlock;

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray  *)otherButtonTitles
             selectSheetBlock:(ActionSheetDidSelectSheetBlock)selectSheetBlock;


#pragma mark - Delegate's way

+ (void)sr_showActionSheetViewWithTitle:(NSString *)title
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                 destructiveButtonTitle:(NSString *)destructiveButtonTitle
                      otherButtonTitles:(NSArray  *)otherButtonTitles
                               delegate:(id<DWDActionSheetDelegate>)delegate;

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray  *)otherButtonTitles
                     delegate:(id<DWDActionSheetDelegate>)delegate;

@end

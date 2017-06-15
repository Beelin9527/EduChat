//
//  DWDChatEmotionContainer.h
//  EduChat
//
//  Created by Superman on 16/10/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDChatEmotionContainerDelegate <NSObject>
@required
- (void)emotionContainerDidSelectImage:(UIImage *)image;
- (void)emotionContainerDidSelectDefaultEmotionWithEmotionString:(NSString *)emotionString;
- (void)sendText;
@end

@interface DWDChatEmotionContainer : UIView

@property (nonatomic , weak) id<DWDChatEmotionContainerDelegate> delegate;

@end

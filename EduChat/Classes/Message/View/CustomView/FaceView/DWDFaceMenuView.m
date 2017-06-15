//
//  DWDFaceMenuView.m
//  EduChat
//
//  Created by Gatlin on 16/1/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDFaceMenuView.h"

@interface DWDFaceMenuView ()

@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) UIImageView *img;
@end

@implementation DWDFaceMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, DWDLineH)];
        line.backgroundColor = DWDColorSeparator;
        [self addSubview:line];
        
        [self addSubview:self.sendBtn];
        [self addSubview:self.img];
        
        [self.sendBtn setFrame:CGRectMake(frame.size.width - 80, 0, 80, frame.size.height)];
        
        self.img.frame  = CGRectMake(10, self.frame.size.height/2 - 30/2, 30, 30);

    }
    return self;
}



#pragma mark - Getter
- (UIButton *)sendBtn
{
    if (_sendBtn == nil) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_sendBtn setBackgroundColor:DWDColorMain];
        [_sendBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchDown];
    }
    return _sendBtn;

}

- (UIImageView *)img
{
    if (!_img) {
        _img = [[UIImageView alloc] init];
        _img.image = [UIImage imageNamed:@"[smile]"];
    }
    return _img;
}
#pragma mark - Button Action
- (void)sendAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceMenuViewSendData:)]) {
        
        [self.delegate faceMenuViewSendData:self];
    }
}
@end

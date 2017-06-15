//
//  DWDGrowUpDetailContentController.m
//  EduChat
//
//  Created by KKK on 16/3/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGrowUpDetailContentController.h"


#import <YYText.h>
#import <Masonry.h>

@interface DWDGrowUpDetailContentController ()

@property (nonatomic, weak) YYTextView *textView;

@end

@implementation DWDGrowUpDetailContentController

- (void)viewDidLoad {
    
}


- (void)setDetailContentString:(NSString *)detailContentString {
    _detailContentString = detailContentString;
    self.textView.text = detailContentString;
}

- (YYTextView *)textView {
    if (!_textView) {
        YYTextView *textView = [YYTextView new];
        [self.view addSubview:textView];
        [textView makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view).offset(20);
            make.top.equalTo(self.view).offset(10);
            make.left.equalTo(self.view).offset(10);
            make.bottom.equalTo(self.view).offset(-10);
            make.right.equalTo(self.view).offset(-10);
        }];
        _textView = textView;
    }
    return _textView;
}


@end

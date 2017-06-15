//
//  DWDClassSourcePersonalRecordViewController.m
//  EduChat
//
//  Created by Superman on 15/11/27.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSourcePersonalRecordViewController.h"
#import "UIImage+Utils.h"


@interface DWDClassSourcePersonalRecordViewController()

@end

@implementation DWDClassSourcePersonalRecordViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@",_name];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_press"] style:UIBarButtonItemStyleDone target:self action:@selector(more)];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)more{
    DWDLogFunc;
}

@end

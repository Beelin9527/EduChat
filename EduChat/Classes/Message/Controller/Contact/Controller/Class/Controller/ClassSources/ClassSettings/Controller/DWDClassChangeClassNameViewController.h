//
//  DWDClassChangeClassNameViewController.h
//  EduChat
//
//  Created by Bharal on 16/1/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDClassChangeClassNameViewController : UIViewController
@property (copy, nonatomic) NSString *className;
@property (weak, nonatomic) IBOutlet UITextField *tfClassName;
@end

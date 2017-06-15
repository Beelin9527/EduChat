//
//  DWDContactsInviteViewController.h
//  EduChat
//
//  Created by KKK on 16/11/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDContactsInviteViewController : UIViewController

@end


@interface DWDContactsInviteViewController (dwd_contactsCategory)
- (NSArray *)allAvailableContactsArray;
- (UIImage *)headImageWithId:(NSString *)identifier;
@end

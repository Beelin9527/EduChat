//
//  DWDClassNotificationDetailModel.m
//  EduChat
//
//  Created by KKK on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassNotificationDetailModel.h"

//DWDClassNotificationPhotos
//DWDClassNotificationReplyMember
//DWDClassNotificationNotice
//DWDClassNotificationAuthor
//DWDClassNotificationReply

@implementation DWDClassNotificationPhotos

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"photo" : [DWDPhotoMetaModel class],
             };
}

@end

@implementation DWDClassNotificationReplyMember

@end

@implementation DWDClassNotificationNotice
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"photos" : [DWDClassNotificationPhotos class],
             };
}

@end

@implementation DWDClassNotificationAuthor

@end

@implementation DWDClassNotificationReply

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"readeds" : [DWDClassNotificationReplyMember class],
             @"unreads" : [DWDClassNotificationReplyMember class],
             @"joins" : [DWDClassNotificationReplyMember class],
             @"unjoins" : [DWDClassNotificationReplyMember class],
             };
}

@end

@implementation DWDClassNotificationDetailModel

+ (NSDictionary *)modelContainerPropertyGenericClass {

//    @property (nonatomic, strong) DWDClassNotificationNotice *notice;
//    @property (nonatomic, strong) DWDClassNotificationAuthor *author;
//    @property (nonatomic, strong) DWDClassNotificationReply *replys;
    return @{
             @"notice" : [DWDClassNotificationNotice class],
             @"author" : [DWDClassNotificationAuthor class],
             @"replys" : [DWDClassNotificationReply class],
             };
}

@end

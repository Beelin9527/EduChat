//
//  DWDClassNotificationDetailModel.h
//  EduChat
//
//  Created by KKK on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDClassNotificationPhotos : NSObject

@property (nonatomic, strong) DWDPhotoMetaModel *photo;
@property (nonatomic, strong) NSNumber *id;
@end

@interface DWDClassNotificationReplyMember : NSObject <NSCopying>

@property (nonatomic, strong) DWDPhotoMetaModel *photohead;
@property (nonatomic, strong) NSNumber *custId;
@property (nonatomic, copy) NSString *name;
@end

@interface DWDClassNotificationNotice : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSArray<DWDClassNotificationPhotos *> *photos;
@end

@interface DWDClassNotificationAuthor : NSObject

@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, strong) DWDPhotoMetaModel *photohead;
@property (nonatomic, copy) NSString *addTime;
@property (nonatomic, copy) NSString *name;
@end

@interface DWDClassNotificationReply : NSObject

@property (nonatomic, strong) NSArray<DWDClassNotificationReplyMember *> *readeds;
@property (nonatomic, strong) NSArray<DWDClassNotificationReplyMember *> *unreads;
@property (nonatomic, strong) NSArray<DWDClassNotificationReplyMember *> *joins;
@property (nonatomic, strong) NSArray<DWDClassNotificationReplyMember *> *unjoins;
@end

@interface DWDClassNotificationDetailModel : NSObject
@property (nonatomic, strong) DWDClassNotificationNotice *notice;
@property (nonatomic, strong) DWDClassNotificationAuthor *author;
@property (nonatomic, strong) DWDClassNotificationReply *replys;
@end

//
//  DWDGrowUpModel.m
//  EduChat
//
//  Created by KKK on 16/4/5.
//  Copyright © 2016年 dwd. All rights reserved.
//
#import "DWDGrowUpModel.h"

@implementation DWDGrowUpModelAuthor

@end

@implementation DWDGrowUpModelRecord

@end

@implementation DWDGrowUpModelPhoto

//+ (NSDictionary *)modelContainerPropertyGenericClass {
//    //    @property (nonatomic, strong) NSArray<DWDGrowUpModelPhoto *> *photos; //图片信息
//    //    @property (nonatomic, strong) NSArray<DWDGrowUpModelPraise *> *praises; //点赞信息
//    //    @property (nonatomic, strong) NSArray<DWDGrowUpModelComment *> *comments; //评论信息
//    
//    return @{
////             @"photos" : [DWDGrowUpModelPhoto class],
//             //字段 :
//             @"???" : [DWDPhotoMetaModel class],
//             };
//}

@end

@interface DWDGrowUpModelPraise () <NSCopying>

@end
@implementation DWDGrowUpModelPraise
- (id)copyWithZone:(NSZone *)zone {
    DWDGrowUpModelPraise *praise = [[DWDGrowUpModelPraise allocWithZone:zone] init];
//    @property (nonatomic, strong) NSNumber *custId; //点赞人id
//    @property (nonatomic, copy) NSString *nickname; //点赞人名字
    praise.custId = self.custId;
    praise.nickname = self.nickname;
    return praise;
}
@end

@interface DWDGrowUpModelComment () <NSCopying>
@end

@implementation DWDGrowUpModelComment

- (id)copyWithZone:(NSZone *)zone {
    DWDGrowUpModelComment *comment = [[DWDGrowUpModelComment allocWithZone:zone] init];
//    @property (nonatomic, strong) NSNumber *commentId; //评论id
//    
//    @property (nonatomic, strong) NSNumber *custId; //评论人id
//    @property (nonatomic, copy) NSString *nickname; //评论人名字
//    @property (nonatomic, strong) NSNumber *forCustId; //被回复id
//    @property (nonatomic, copy) NSString *forNickname; //被回复名字
//    
//    @property (nonatomic, copy) NSString *photokey; //回复人photokey
//    @property (nonatomic, copy) NSString *commentTxt; //回复内容
//    @property (nonatomic, copy) NSString *addtime; //回复时间
    self.commentId = comment.commentId;
    self.custId = comment.custId;
    self.nickname = comment.nickname;
    self.forNickname = comment.forNickname;
    self.photokey = comment.photokey;
    self.commentTxt = comment.commentTxt;
    self.addtime = comment.addtime;
    
    return self;
}

@end

@implementation DWDGrowUpModel

- (instancetype)init {
    self = [super init];
    
    self.author = [DWDGrowUpModelAuthor new];
    self.record = [DWDGrowUpModelRecord new];
    
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
//    @property (nonatomic, strong) NSArray<DWDGrowUpModelPhoto *> *photos; //图片信息
//    @property (nonatomic, strong) NSArray<DWDGrowUpModelPraise *> *praises; //点赞信息
//    @property (nonatomic, strong) NSArray<DWDGrowUpModelComment *> *comments; //评论信息
    
    return @{
             @"praises" : [DWDGrowUpModelPraise class],
             @"photos" : [DWDGrowUpModelPhoto class],
             @"comments" : [DWDGrowUpModelComment class],
             };
}

@end

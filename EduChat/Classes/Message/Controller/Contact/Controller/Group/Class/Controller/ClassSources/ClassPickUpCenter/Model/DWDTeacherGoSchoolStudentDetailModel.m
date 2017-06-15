//
//  DWDTeacherGoSchoolStudentDetailModel.m
//  EduChat
//
//  Created by KKK on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//


#import "DWDTeacherGoSchoolStudentDetailModel.h"
#import "NSDictionary+dwd_extend.h"
#import "NSString+extend.h"

@implementation DWDTeacherGoSchoolStudentDetailModel

- (instancetype)init {
    self = [super init];
    self.photohead = [DWDPhotoMetaModel new];
    self.punchPhoto = [DWDPhotoMetaModel new];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DWDTeacherGoSchoolStudentDetailModel *model = [[[self class] allocWithZone:zone] init];
    model.custId = self.custId;
    model.educhatAccount = self.educhatAccount;
    model.name = self.name;
    model.nickname = self.nickname;
    model.index = self.index;
    model.photohead = self.photohead;
    model.punchPhoto = self.punchPhoto;
    model.leave = self.leave;
    model.contextual = self.contextual;
    return model;

}

//+ (BOOL)ifTodayModelExists {
//    DWDTeacherGoSchoolStudentDetailModel *model = [[NSUserDefaults standardUserDefaults] objectForKey:kDetailModelStudentsKey];
//    if (model == nil)
//        return NO;
//    if (![model.date isEqualToString:[NSString getTodayDateStr]])
//        return NO;
//    if (<#condition#>) {
//        <#statements#>
//    }
//    return NO;
//}
    
//    @property (nonatomic, copy) NSNumber *custId;
//    @property (nonatomic, copy) NSString *educhatAccount;
//    @property (nonatomic, copy) NSString *name;
//    @property (nonatomic, copy) NSString *nickname;
//    @property (nonatomic, strong) NSNumber *index;
//    @property (nonatomic, strong) DWDPhotoMetaModel *photohead;
//    @property (nonatomic, strong) DWDPhotoMetaModel *punchPhoto;
//    //0-未请假 1 事假；2 病假；3 其他
//    @property (nonatomic, assign) int leave;
//    @property (nonatomic, copy) NSString *contextual;
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.custId forKey:@"custId"];
    [aCoder encodeObject:self.educhatAccount forKey:@"educhatAccount"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.index forKey:@"index"];
    [aCoder encodeObject:self.photohead forKey:@"photohead"];
    [aCoder encodeObject:self.punchPhoto forKey:@"punchPhoto"];
    [aCoder encodeInt:self.leave forKey:@"leave"];
    [aCoder encodeObject:self.contextual forKey:@"contextual"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    self.custId = [aDecoder decodeObjectForKey:@"custId"];
    self.educhatAccount = [aDecoder decodeObjectForKey:@"educhatAccount"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
    self.index = [aDecoder decodeObjectForKey:@"index"];
    self.photohead = [aDecoder decodeObjectForKey:@"photohead"];
    self.punchPhoto = [aDecoder decodeObjectForKey:@"punchPhoto"];
    self.leave = [aDecoder decodeIntForKey:@"leave"];
    self.contextual = [aDecoder decodeObjectForKey:@"contextual"];
    return self;
}

@end

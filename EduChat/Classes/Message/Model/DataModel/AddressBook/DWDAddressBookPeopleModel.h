//
//  DWDAddressBookPeopleModel.h
//  EduChat
//
//  Created by Superman on 15/12/15.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDAddressBookPeopleModel : NSObject
@property (nonatomic , copy) NSString *personName;
@property (nonatomic , copy)NSString *lastname;
@property (nonatomic , copy)NSString *middlename;
@property (nonatomic , copy)NSString *prefix;
@property (nonatomic , copy)NSString *suffix;
@property (nonatomic , copy)NSString *nickname;
@property (nonatomic , copy)NSString *firstnamePhonetic;
@property (nonatomic , copy)NSString *lastnamePhonetic;
@property (nonatomic , copy)NSString *middlenamePhonetic;
@property (nonatomic , copy)NSString *organization;
@property (nonatomic , copy)NSString *jobtitle;
@property (nonatomic , copy)NSString *department;
@property (nonatomic , copy)NSString *note;
@property (nonatomic , copy)NSString *firstknow;
@property (nonatomic , copy)NSString *lastknow;
@property (nonatomic , copy)NSString *emailContent;;
@property (nonatomic , copy)NSString *country;
@property (nonatomic , copy)NSString *city;
@property (nonatomic , copy)NSString *state ;
@property (nonatomic , copy)NSString *street;
@property (nonatomic , copy)NSString *zip;
@property (nonatomic , copy)NSString *coutntrycode;
@property (nonatomic , copy)NSString *datesContent;
@property (nonatomic , copy)NSString *username;
@property (nonatomic , copy)NSString *service;
@property (nonatomic , copy)NSString *mobile;
@property (nonatomic , copy)NSString *urlContent;

@property (nonatomic , assign) NSInteger status;

@end

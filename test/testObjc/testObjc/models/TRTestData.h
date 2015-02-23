

//
//  TRTestData.h
//
//  Created by js2Model on 2015-02-23.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TRFriends; @class TRName; 
@interface TRTestData : NSObject 

@property(strong, nonatomic) NSString * guid;
@property(strong, nonatomic) NSNumber * index;
@property(strong, nonatomic) NSString * favoriteFruit;
@property(strong, nonatomic) NSNumber * latitude;
@property(strong, nonatomic) NSString * email;
@property(strong, nonatomic) NSString * picture;
@property(strong, nonatomic) NSMutableArray * tags;
@property(strong, nonatomic) NSString * company;
@property(strong, nonatomic) NSString * eyeColor;
@property(strong, nonatomic) NSString * phone;
@property(strong, nonatomic) NSString * address;
@property(strong, nonatomic) NSMutableArray * friends;
@property(strong, nonatomic) NSNumber * isActive;
@property(strong, nonatomic) NSString * about;
@property(strong, nonatomic) NSString * balance;
@property(strong, nonatomic) TRName * name;
@property(strong, nonatomic) NSNumber * age;
@property(strong, nonatomic) NSString * registered;
@property(strong, nonatomic) NSString * greeting;
@property(strong, nonatomic) NSNumber * longitude;
@property(strong, nonatomic) NSMutableArray * range;
@property(strong, nonatomic) NSString * Id;

-(instancetype) initWithDict:(NSDictionary *)dict;

-(instancetype) initWithJSONData:(NSData *)data
                            error:(NSError* __autoreleasing *)error;

-(instancetype) initWithJSONFromFileNamed:(NSString *)filename
                                     error:(NSError* __autoreleasing *)error;

+(instancetype) testDataWithDict:(NSDictionary *)dict;

+(instancetype) testDataWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error;

+(instancetype) testDataWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error;

+(NSArray*) testDataArrayWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error;

+(NSArray*) testDataArrayWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error;

@end

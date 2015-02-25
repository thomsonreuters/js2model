

//
//  TRFriends.h
//
//  Created by js2Model on 2015-02-24.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRFriends : NSObject 

@property(strong, nonatomic) NSString * name;
@property(strong, nonatomic) NSNumber * id_;

-(instancetype) initWithDict:(NSDictionary *)dict;

-(instancetype) initWithJSONData:(NSData *)data
                            error:(NSError* __autoreleasing *)error;

-(instancetype) initWithJSONFromFileNamed:(NSString *)filename
                                     error:(NSError* __autoreleasing *)error;

+(instancetype) friendsWithDict:(NSDictionary *)dict;

+(instancetype) friendsWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error;

+(instancetype) friendsWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error;

+(NSArray*) friendsArrayWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error;

+(NSArray*) friendsArrayWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error;

@end

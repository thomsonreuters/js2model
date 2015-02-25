

//
//  TRName.h
//
//  Created by js2Model on 2015-02-24.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRName : NSObject 

@property(strong, nonatomic) NSString * last;
@property(strong, nonatomic) NSString * first;

-(instancetype) initWithDict:(NSDictionary *)dict;

-(instancetype) initWithJSONData:(NSData *)data
                            error:(NSError* __autoreleasing *)error;

-(instancetype) initWithJSONFromFileNamed:(NSString *)filename
                                     error:(NSError* __autoreleasing *)error;

+(instancetype) nameWithDict:(NSDictionary *)dict;

+(instancetype) nameWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error;

+(instancetype) nameWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error;

+(NSArray*) nameArrayWithJSONData:(NSData *)data
                                error:(NSError* __autoreleasing *)error;

+(NSArray*) nameArrayWithJSONFromFileNamed:(NSString *)filename
                                         error:(NSError* __autoreleasing *)error;

@end

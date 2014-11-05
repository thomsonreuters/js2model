//
//  JSONModelSerialize.h
//  JsonModelGenTest
//
//  Created by Kevin on 10/24/14.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONModelSchema;
@class JSONInstanceMeta;

@protocol JSONModelSerialize <NSObject>

@required

+(JSONModelSchema *)modelSchema;

-(JSONInstanceMeta *)objectForPropertyNamed:(NSString*)propertyName;
-(JSONInstanceMeta *)arrayForPropertyNamed:(NSString*)propertyName;

- (instancetype) initWithJSONData:(NSData *)data error:(NSError* __autoreleasing *)error;
- (instancetype) initWithJSONFromFileNamed:(NSString *)filename error:(NSError* __autoreleasing *)error;

-(void)setString:(NSString*)val forProperty:(NSString*)propertyName;
-(void)setNumber:(NSNumber*)val forProperty:(NSString*)propertyName;
-(void)setInteger:(NSNumber*)val forProperty:(NSString*)propertyName;
-(void)setBoolean:(NSNumber*)val forProperty:(NSString*)propertyName;
-(void)setNullForProperty:(NSString*)propertyName;

-(NSMutableDictionary*)additionalProperties;
-(id)valueForAdditionalProperty:(NSString*)propertyName;
-(void)setValue:(id)value forAdditionalProperty:(NSString*)propertyName;

@end

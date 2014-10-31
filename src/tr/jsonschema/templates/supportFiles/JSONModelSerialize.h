//
//  JSONModelSerialize.h
//  JsonModelGenTest
//
//  Created by Kevin on 10/24/14.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONModelSerialize <NSObject>

@required

-(BOOL)isObjectForPropertyNamed:(NSString *)propertyName;
-(BOOL)isArrayForPropertyNamed:(NSString *)propertyName;

-(id<JSONModelSerialize>)getObjectForPropertyNamed:(NSString*)propertyName;
-(NSMutableArray *)getArrayForPropertyNamed:(NSString*)propertyName;

-(void)setString:(NSString*)val forProperty:(NSString*)propertyName;
-(void)setNumber:(NSNumber*)val forProperty:(NSString*)propertyName;
-(void)setInteger:(NSNumber*)val forProperty:(NSString*)propertyName;
-(void)setBoolean:(NSNumber*)val forProperty:(NSString*)propertyName;
-(void)setNullForProperty:(NSString*)propertyName;

@end

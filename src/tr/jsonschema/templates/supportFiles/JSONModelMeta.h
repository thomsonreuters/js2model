//
// Created by Kevin on 10/25/14.
// Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModelSerialize.h"

@interface JSONModelMeta : NSObject

@property(strong, nonatomic) NSMutableDictionary *objectGetters;
@property(strong, nonatomic) NSMutableDictionary *arrayGetters;
@property(strong, nonatomic) NSMutableDictionary *objectSetters;
@property(strong, nonatomic) NSMutableDictionary *arraySetters;
@property(strong, nonatomic) NSMutableDictionary *strings;
@property(strong, nonatomic) NSMutableDictionary *booleans;
@property(strong, nonatomic) NSMutableDictionary *integers;
@property(strong, nonatomic) NSMutableDictionary *doubles;

-(BOOL)propertyIsObject:(NSString *)propertyName;

-(BOOL)propertyIsArray:(NSString *)propertyName;

-(SEL)objectGetterSelectorForProperty:(NSString *)propertyName;

-(SEL)arrayGetterSelectorForProperty:(NSString *)propertyName;

-(SEL)doubleSetterSelectorForProperty:(NSString *)propertyName;

-(SEL)stringSetterSelectorForProperty:(NSString *)propertyName;

-(SEL)booleanSetterSelectorForProperty:(NSString *)propertyName;

-(SEL)integerSetterSelectorForProperty:(NSString *)propertyName;

- (id <JSONModelSerialize>)getObjectForPropertyNamed:(NSString *)propertyName forInstance:(id)instance;

- (NSMutableArray *)getArrayForPropertyNamed:(NSString *)propertyName forInstance:(id)instance;

- (void)setString:(NSString *)val forProperty:(NSString *)propertyName forInstance:(id)instance;

- (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance;

- (void)setDouble:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance;

- (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance;

- (void)setNullForProperty:(NSString *)propertyName forInstance:(id)instance;

@end
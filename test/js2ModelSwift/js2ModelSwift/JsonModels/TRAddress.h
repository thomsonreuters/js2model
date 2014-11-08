//
//  TRAddress.h
//
//  Created by js2Model on 2014-11-06.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "JSONModelSchema.h"



@interface TRAddressSchema : JSONModelSchema

@end

@interface TRAddress : NSObject <JSONModelSerialize>


@property(strong, nonatomic) NSString * county;
@property(strong, nonatomic) NSString * city;
@property(strong, nonatomic) NSString * state;
@property(strong, nonatomic) NSString * street;
@property(strong, nonatomic) NSString * zip;

@end

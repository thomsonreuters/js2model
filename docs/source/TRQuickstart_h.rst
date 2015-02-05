=========================
TRQuickstart.h
=========================

.. highlight:: objective-c

::

   //
   //  TRQuickstart.h
   //
   //  Created by js2Model on 2015-02-04.
   //  Copyright (c) 2014 Thomson Reuters. All rights reserved.
   //
   
   #import <Foundation/Foundation.h>
   #import "JSONModelSchema.h"
   
   @interface TRQuickstartSchema : JSONModelSchema
   @end
   
   @interface TRQuickstart : NSObject <JSONModelSerialize>
   
   @property(strong, nonatomic) NSNumber * county;
   @property(strong, nonatomic) NSNumber * city;
   @property(strong, nonatomic) NSNumber * state;
   @property(strong, nonatomic) NSNumber * street;
   @property(strong, nonatomic) NSNumber * zip;
   
   @end


//
//  TRJsonModelLoader.swift
//  js2ModelSwift
//
//  Created by Kevin on 11/10/14.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

import Foundation


extension Array {

    mutating func push(item:T) {
        append(item);
    }

    mutating func pop() -> T? {
        var item: T? = nil;
        if  count == 0  {
            item = removeLast();
        }
        return item;
    }

    func peek() -> T? {
        var item: T? = nil;
        if (count != 0) {
            item = self[count-1]
        }
        return item;
    }

    func peekTo(countFromTop:Int) -> T? {
        var item: T? = nil;
        if ( count > countFromTop) {
            item = self[count - countFromTop];
        }
        return item;
    }

}

public class TRJsonLoaderPrivate {


    var context: [AnyObject] = [AnyObject]();

    var lastMapKey: String?;
    var object: JsonModelSerialize;

    init(object: JsonModelSerialize) {
        
            self.object = object;
    }
    

    func loadData(jsonData:[Byte]) -> Bool {
        
        var success: Bool

        //TODO: parse data
        
        
        return success;
    }

    
    func startMap() -> Bool {
        
//        TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
//        
//        __unsafe_unretained JsonInstanceMeta *top = [loader.context peek];
//        
//        // If context is empty, then assume we are starting the top level object;
//        if (top == nil) {
//            [loader pushContext:[JSONInstanceMeta initWithInstance:loader.object propertyMeta:nil]];
//        }
//        else {
//            
//            if ( top.propertyMeta && top.propertyMeta.isArray) {
//                
//                JSONInstanceMeta *instanceMeta = [JSONInstanceMeta initWithInstance:[top.propertyMeta newItemObject] propertyMeta:[JSONPropertyMeta initWithGetter:NULL setter:NULL type:top.propertyMeta.itemType]];
//                [(NSMutableArray*)top.instance addObject:instanceMeta.instance];
//                [loader pushContext:instanceMeta];
//            }
//            else{
//                NSCAssert(loader.lastMapKey, @"Expecting a key map");
//                JSONInstanceMeta *instanceMeta = [top.instance objectForPropertyNamed:loader.lastMapKey];
//                
//                if ( instanceMeta ) {
//                    [loader pushContext:instanceMeta];
//                }
//                else {
//                    NSLog(@"No property found in schema for %@", loader.lastMapKey);
//                    return 0;
//                }
//            }
//        }
        
        return true;
    }

    func endMap() -> Bool {
        
//        TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
//        
//        __unsafe_unretained JSONInstanceMeta *top = [loader.context peek];
//        
//        NSCAssert(top != nil, @"Not expecting empty context stack");
//        
//        // If we are about to pop the last object off the context stack, that
//        // means we are done with an instance, so call the completion block.
//        if ( [loader contextPopWillCompleteInstance]) {
//            
//            loader.object = top.instance;
//        }
//        
//        [loader.context pop];
        
        return true;
    }

    func startArray( ) -> Bool {

//        TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
//        
//        __unsafe_unretained JSONInstanceMeta *top = [loader.context count] == 0 ? nil : [loader.context peek];
//        
//        NSCAssert(top != nil, @"Not expecting empty context stack");
//        NSCAssert(loader.lastMapKey, @"Expecting a key map");
//        
//        if (top.propertyMeta && top.propertyMeta.isArray) {
//            [loader pushContext: [JSONInstanceMeta initWithInstance:[top.propertyMeta newItemObject] propertyMeta:[JSONPropertyMeta initWithGetter:NULL setter:NULL type:top.propertyMeta.itemType]]];
//        }
//        else {
//            JSONInstanceMeta *array = [top.instance arrayForPropertyNamed:[loader lastMapKey]];
//            if( array ) {
//                [loader pushContext:array];
//            }
//            else {
//                NSCAssert(NO, @"Expected an Array type");
//            }
//        }
        
        return true;
    }

    func endArray() -> Bool {

//        TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
//        
//        __unsafe_unretained JSONInstanceMeta *top = [loader.context peek];
//        NSCAssert(top.propertyMeta.isArray, @"Expecting to pop NSArray from context");
//        
//        [loader.context pop];
        
        return true;
    }


    func mapKey(keyName:String) -> Bool {
        
//        TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
//        
//        loader.lastMapKey = [[NSString alloc] initWithBytes:stringVal length:stringLen encoding:NSUTF8StringEncoding];
        
        return true;
    }

    func set<T>(value:T, withBlock block:((JSONModelSerialize, String)->void)? ) {
        
        var top: JsonInstanceMeta? = context.peek();
        
        if let t = top  {
            
            if ( top.propertyMeta.isArray ) {
                var array: Array = top.instance;
                array.append(value);
            }
            else{
                assert(lastMapKey, "Expecting a key, but it is nil")
                NSCAssert(block, "Expecting a block, but it is nil")
                
                var obj:JsonModelSerialize = top.instance;
                block(obj, lastMapKey!);
            }
        }
        
        lastMapKey = nil;
    }

//    static int _null(void * ctx){
//        TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
//        //[loader didAdd:nil];
//        
//        __unsafe_unretained JSONInstanceMeta *top = [loader.context peek];
//        NSCAssert(top, @"Expecting an object on the context stack. Top most JSON must be a {}.");
//        
//        if ( top ) {
//            
//            if ( top.propertyMeta.isArray ) {
//                NSCAssert(NO, @"I didn't expect to get here. Handle this situation");
//            }
//            else{
//                NSCAssert(loader.lastMapKey, @"Expecting a key, but it is nil");
//                
//                id<JSONModelSerialize> obj = top.instance;
//                [obj setNullForProperty:loader.lastMapKey];
//            }
//        }
//        
//        [loader clearLastMapKey];
//        
//        return 1;
//    }

    func boolean(value:Bool) {
        
        set(value:value) { (obj, propertyName) in
            obj.set(boolean:value, forProperty:propertyName);
        };
        
        return true;
    }

    //static int _number(void * ctx, const char * s, size_t l){
    //    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
    //
    //    NSString *st = [[NSString alloc] initWithBytes:s length:l encoding:NSUTF8StringEncoding];
    //    __block NSNumber *value = [NSNumber numberWithBool:[[TRJsonLoader numberFormatter] numberFromString:st]];
    //
    //    [loader setValue:value OnCurrentUsingBlock:^(id<JSONModelSerialize> obj, NSString *propertyName) {
    //        [obj setNumber:value forProperty:propertyName];
    //    }];
    //
    //    return 1;
    //}

    func string(value:String){
        
        set(value:value) { (obj, propertyName) in
            obj.set(boolean:value, forProperty:propertyName);
        };
    
        return true;
    }

    func integer(value:Int){

        set(value:value) { (obj, propertyName) in
            obj.set(boolean:value, forProperty:propertyName);
        };
        
        return true;
    }

    func double(value:Double){

        set(value:value) { (obj, propertyName) in
            obj.set(boolean:value, forProperty:propertyName);
        };
    
        return true;
    }

    // callbacks for yajl parser
    // why is _number commented out? Well if you provide it, YAJL will pass all numbers as strings,
    // meaning we have to do a really expensive NSNumberFormatter call. If we skip, we can only accept long longs and doubles
    // but it's about 20% faster for the album dataset

//    static yajl_callbacks callbacks = {
//        _null,
//        _boolean,
//        _integer,
//        _double,
//        NULL /* _number */,
//        _string,
//        _start_map,
//        _map_key,
//        _end_map,
//        _start_array,
//        _end_array
//    };


}
//@interface TRJSONModelLoader ()
//
//@property (strong, nonatomic) TRJsonLoaderPrivate *jsonPrivLoader;
//
//@end
//
//
//@implementation TRJSONModelLoader
//
//- (id) initWithObject:(id)object {
//	if(self = [super init])
//    {
//        _jsonPrivLoader = [[TRJsonLoaderPrivate alloc] initWithObject:object];
//    }
//    
//	return self;
//}
//
//+ (id) load:(id)object withJSONData:(NSData*)data
//                     error:(NSError* __autoreleasing *)error {
//    
//    TRJSONModelLoader *jil = [[TRJSONModelLoader alloc] initWithObject:object];
//    [jil.jsonPrivLoader loadData:data error:error];
//    
//    return jil.jsonPrivLoader.object;
//}
//
//+ (id) load:(id)object
//     withJSONFromFileNamed:(NSString*)filename
//                     error:(NSError* __autoreleasing *)error {
//    
//    NSString * filePath = [[NSBundle bundleForClass:[self class] ] pathForResource:filename ofType:nil];
//    
//    if( filePath == nil && error != NULL )
//    {
//        *error = [NSError errorWithDomain:kJSONLoadedErrorDomain code:0 userInfo:nil];
//        return nil;
//    }
//    
//    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
//    
//    return [self load:object withJSONData:jsonData error:error];
//}
//
//+ (void) load:(id)object withUrl:(NSURL*)url
//                     cachePolicy:(NSURLRequestCachePolicy)cachePolicy
//               onCompletionBlock:(TRJsonCompletedBlock)onCompletionBlock {
//    
//    TRJSONModelLoader *jil = [[TRJSONModelLoader alloc] initWithObject:object];
//    
//    [jil.jsonPrivLoader loadURL:url cachePolicy:cachePolicy onCompletionBlock:onCompletionBlock];
//}
//
//+(ISO8601DateFormatter*)isoDateFormatter {
//    
//    static ISO8601DateFormatter *isoDateFmt;
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        isoDateFmt = [ISO8601DateFormatter new];
//    });
//    
//    return isoDateFmt;
//}
//
////+(NSNumberFormatter*)numberFormatter {
////    static NSNumberFormatter *numberFmt;
////
////    static dispatch_once_t onceToken;
////    dispatch_once(&onceToken, ^{
////        numberFmt = [NSNumberFormatter new];
////        [numberFmt setLenient:YES];
////
////    });
////
////    return numberFmt;
////}
////
//// yes, it's a nasty #def function - but couldn't see a way to use the same block of code twice inline
////#define HANDLE_NUMBER \
////    if([value isKindOfClass:[NSString class]]){ \
////        return [[TRJsonLoader numberFormatter] numberFromString:value];\
////    } else if([value isKindOfClass:[NSNumber class]]){\
////        return value;\
////    }
////
////// TODO optimze NSNumberFormatter creation
////// YAJL is giving us some basic type information, need to check that it matches
////// what's expected for the property
////+ (id) convertJSONValue:(id) value toCorrectTypeForAttributeCString:(const char *) str{
////
////    if(!str || str[0] != 'T')
////        return nil;
////    if(strncmp(str,"T@\"NS",5)==0){ // dealing with an NSObject
////        if(strncmp(str,"T@\"NSNumber\"",12)==0){
////            HANDLE_NUMBER;
////        } else if (strncmp(str,"T@\"NSString\"",12)==0){
////            if([value isKindOfClass:[NSString class]]){
////                return value;
////            }
////        } else if (strncmp(str,"T@\"NSURL\"",9)==0){
////            if([value isKindOfClass:[NSString class]]){
////                return [NSURL URLWithString:value];
////            }
////        } else if (strncmp(str,"T@\"NSDate\"",10)==0){
////            if([value isKindOfClass:[NSString class]]){
////                return [[TRJsonLoader isoDateFormatter] dateFromString:value];
////            }
////        }
////    } else { // dealing with a native type
////        switch(str[1]){
////            case 'B':   if([value isKindOfClass:[NSNumber class]]){
////                            return value;
////                        } else if([value isKindOfClass:[NSString class]]){
////                            return [NSNumber numberWithBool:(
////                                                     [(NSString*)value caseInsensitiveCompare:@"yes"] == NSOrderedSame ||
////                                                     [(NSString*)value isEqualToString:@"1"] ||
////                                                     [(NSString*)value caseInsensitiveCompare:@"true"] == NSOrderedSame)];
////                        }
////                        break;
////            case 'i':
////            case 'd':
////            case 'c':
////            case 'l':
////            case 'I':
////            case 's':
////            case 'q':
////            case 'f':   HANDLE_NUMBER;
////                    break;
////        }
////    }
////    return nil;
////}
//
//@end




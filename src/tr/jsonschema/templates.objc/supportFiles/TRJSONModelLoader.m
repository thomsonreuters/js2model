//
//  TRJsonInstanceLoader.m
//  iOSDataBinding
//
// Copyright © 2012 Thomson Reuters Global Resources. All Rights Reserved.
// Proprietary and confidential information of TRGR. Disclosure, use, or reproduction
// without the written authorization of TRGR is prohibited.
//

#import "TRJSONModelLoader.h"
#import <CFNetwork/CFNetworkErrors.h>
#import "yajl_parse.h"
#import "ISO8601DateFormatter.h"
#import "JSONModelSerialize.h"
#import "JSONModelMeta.h"

//using std::string;

const char *kContainedClassTypeKey = "containedClassType";

NSString * const kJSONLoadedErrorDomain = @"JSONLoadedError";

//=======================================================
// Give stack methods to NSMutableArray
//=======================================================
@interface NSMutableArray (Stack)

- (void) push: (id)item;
- (id) pop;
- (id) peek;
- (id) peekTo:(NSInteger)countFromTop;

@end

@implementation NSMutableArray (Stack)

- (void) push: (id)item {
    [self addObject:item];
}

- (id) pop {
    id item = nil;
    if ([self count] != 0) {
        item = [self lastObject];
        [self removeLastObject];
    }
    return item;
}

- (id) peek {
    id item = nil;
    if ([self count] != 0) {
        item = [self lastObject];
    }
    return item;
}

- (id) peekTo:(NSInteger)countFromTop {
    id item = nil;
    if ([self count] > countFromTop) {
        item = [self objectAtIndex:self.count - countFromTop];
    }
    return item;
}

@end

//=======================================================
// Private class to handle implementation details.
//=======================================================
@interface TRJsonLoaderPrivate : NSObject<NSURLConnectionDelegate>
{
    NSMutableArray *_context;
}

@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (nonatomic) NSString *lastMapKey;
@property (copy, nonatomic) TRJsonCompletedBlock onCompletionBlock;
@property (strong, nonatomic) id object;

-(id)initWithObject:(id)object;

-(BOOL)loadData:(NSData*)jsonData error:(NSError * __autoreleasing *)error;

-(void)loadURL:(NSURL*)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy
    onCompletionBlock:(TRJsonCompletedBlock)onCompletionBlock;

@end

@interface TRJSONModelLoader ()

@property (strong, nonatomic) TRJsonLoaderPrivate *jsonPrivLoader;

@end


@implementation TRJSONModelLoader

- (id) initWithObject:(id)object {
	if(self = [super init])
    {
        _jsonPrivLoader = [[TRJsonLoaderPrivate alloc] initWithObject:object];
    }
    
	return self;
}

+ (id) load:(id)object withJSONData:(NSData*)data
                     error:(NSError* __autoreleasing *)error {
    
    TRJSONModelLoader *jil = [[TRJSONModelLoader alloc] initWithObject:object];
    [jil.jsonPrivLoader loadData:data error:error];
    
    return jil.jsonPrivLoader.object;
}

+ (id) load:(id)object
     withJSONFromFileNamed:(NSString*)filename
                     error:(NSError* __autoreleasing *)error {
    
    NSString * filePath = [[NSBundle bundleForClass:[self class] ] pathForResource:filename ofType:nil];
    
    if( filePath == nil && error != NULL )
    {
        *error = [NSError errorWithDomain:kJSONLoadedErrorDomain code:0 userInfo:nil];
        return nil;
    }
    
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    
    return [self load:object withJSONData:jsonData error:error];
}

+ (void) load:(id)object withUrl:(NSURL*)url
                     cachePolicy:(NSURLRequestCachePolicy)cachePolicy
               onCompletionBlock:(TRJsonCompletedBlock)onCompletionBlock {
    
    TRJSONModelLoader *jil = [[TRJSONModelLoader alloc] initWithObject:object];
    
    [jil.jsonPrivLoader loadURL:url cachePolicy:cachePolicy onCompletionBlock:onCompletionBlock];
}

+(ISO8601DateFormatter*)isoDateFormatter {
    
    static ISO8601DateFormatter *isoDateFmt;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isoDateFmt = [ISO8601DateFormatter new];
    });
    
    return isoDateFmt;
}

//+(NSNumberFormatter*)numberFormatter {
//    static NSNumberFormatter *numberFmt;
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        numberFmt = [NSNumberFormatter new];
//        [numberFmt setLenient:YES];
//        
//    });
//    
//    return numberFmt;
//}
//
// yes, it's a nasty #def function - but couldn't see a way to use the same block of code twice inline
//#define HANDLE_NUMBER \
//    if([value isKindOfClass:[NSString class]]){ \
//        return [[TRJsonLoader numberFormatter] numberFromString:value];\
//    } else if([value isKindOfClass:[NSNumber class]]){\
//        return value;\
//    }
//
//// TODO optimze NSNumberFormatter creation
//// YAJL is giving us some basic type information, need to check that it matches
//// what's expected for the property
//+ (id) convertJSONValue:(id) value toCorrectTypeForAttributeCString:(const char *) str{
//
//    if(!str || str[0] != 'T')
//        return nil;
//    if(strncmp(str,"T@\"NS",5)==0){ // dealing with an NSObject
//        if(strncmp(str,"T@\"NSNumber\"",12)==0){
//            HANDLE_NUMBER;
//        } else if (strncmp(str,"T@\"NSString\"",12)==0){
//            if([value isKindOfClass:[NSString class]]){
//                return value;
//            }
//        } else if (strncmp(str,"T@\"NSURL\"",9)==0){
//            if([value isKindOfClass:[NSString class]]){
//                return [NSURL URLWithString:value];
//            }
//        } else if (strncmp(str,"T@\"NSDate\"",10)==0){
//            if([value isKindOfClass:[NSString class]]){
//                return [[TRJsonLoader isoDateFormatter] dateFromString:value];
//            }
//        }
//    } else { // dealing with a native type
//        switch(str[1]){
//            case 'B':   if([value isKindOfClass:[NSNumber class]]){
//                            return value;
//                        } else if([value isKindOfClass:[NSString class]]){
//                            return [NSNumber numberWithBool:(
//                                                     [(NSString*)value caseInsensitiveCompare:@"yes"] == NSOrderedSame ||
//                                                     [(NSString*)value isEqualToString:@"1"] ||
//                                                     [(NSString*)value caseInsensitiveCompare:@"true"] == NSOrderedSame)];
//                        }
//                        break;
//            case 'i':
//            case 'd':
//            case 'c':
//            case 'l':
//            case 'I':
//            case 's':
//            case 'q':
//            case 'f':   HANDLE_NUMBER;
//                    break;
//        }
//    }
//    return nil;
//}

@end



// Container for caching the type attribute of a property, but only if it
// is a Class.
//typedef std::unordered_map<objc_property_t, Class> PropertyClassMap_t;

@implementation TRJsonLoaderPrivate
{
    @public
    yajl_status _parserStatus;
    NSError *_parserError;
    NSInteger _httpResponseStatusCode;
    //PropertyClassMap_t _propertyClassMap;
    yajl_handle _parser_handle;
    NSOperationQueue *_queue;
    NSString *_lastMapKeyNSString;
}

- (id) initWithObject:(id)object {
	if(self = [super init])
    {
        
        /* ok.  open file.  let's read and parse */
        _parser_handle = yajl_alloc(&callbacks, NULL, (__bridge void *) self);
        yajl_config(_parser_handle, yajl_allow_comments, 1);
        yajl_config(_parser_handle,yajl_allow_multiple_values,1);
        _httpResponseStatusCode = 200;
        _context = [[NSMutableArray alloc] init];
        _queue = [[NSOperationQueue alloc] init];
        _lastMapKeyNSString = nil;
        
        _object = object;
	}
    
	return self;
}

-(void)dealloc{
    yajl_free(_parser_handle);
    
    // no idea why clang is complaining about a missing [super dealloc] here but this silences it.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
  }
#pragma clang diagnostic pop

-(void)setLastMapKey:(NSString*)lastMapKey {
    
    _lastMapKey = lastMapKey;
}

-(void)setLastMapKeyFromCString:(const char *)lastMapKey {
    _lastMapKey = [NSString stringWithUTF8String:lastMapKey];
}

+(NSError*)createNSErrorForYAJLParser:(yajl_handle)handle usingJSON:(NSData*)jsonData andStatus:(yajl_status)stat{
    unsigned char * str = yajl_get_error(handle, 1, (const unsigned char *)[jsonData bytes], (size_t)[jsonData length]);
    NSError *error = [NSError errorWithDomain:@"com.thomsonreuters.iOSDataBinding" code:stat userInfo:@{@"errorText":[NSString stringWithCString:(char*)str encoding:NSUTF8StringEncoding]}];
    yajl_free_error(handle, str);
    return error;
}

-(BOOL)loadData:(NSData*)jsonData error:(NSError * __autoreleasing *)error {
    
    BOOL success = YES;
    yajl_status stat = yajl_parse(_parser_handle,(const unsigned char *) [jsonData bytes], (size_t) [jsonData length]);
    if (stat != yajl_status_ok && error != NULL){
        *error = [TRJsonLoaderPrivate createNSErrorForYAJLParser:_parser_handle usingJSON:jsonData andStatus:stat];
        success = NO;
    }
    return success;
}

-(void)loadURL:(NSURL*)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy
onCompletionBlock:(TRJsonCompletedBlock)onCompletionBlock{
    
    self.onCompletionBlock = onCompletionBlock;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:60];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    
    self.urlConnection = conn;
    
    [self.urlConnection setDelegateQueue:_queue];
    
    [conn start];
    
}

- (void) clearLastMapKey{
    self.lastMapKey = nil;
}


- (void)pushContext:(id)obj{
    NSAssert(obj, @"Trying to push a nil instance.");
    
    if (obj) {
        [_context push:obj];
    }
}

-(NSMutableArray*)context {
    return _context;
}

- (BOOL)contextPopWillCompleteInstance {
    
    return [_context count] == 1 ? YES : NO;
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _httpResponseStatusCode = [((NSHTTPURLResponse *)response) statusCode];
    if (_httpResponseStatusCode >= 400) {
        NSLog(@"HTTP Response error code: %ld",(long)_httpResponseStatusCode);
        _parserError = [NSError errorWithDomain:(NSString*)kCFErrorDomainCFNetwork code:kCFURLErrorBadServerResponse userInfo:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    if (_httpResponseStatusCode >= 400) {
        _parserError = [NSError errorWithDomain:(NSString*)kCFErrorDomainCFNetwork code:kCFURLErrorBadServerResponse userInfo:nil];
    }
    else if (_parserStatus == yajl_status_ok) {
        _parserStatus = yajl_parse(_parser_handle,(const unsigned char *) [data bytes], (size_t) [data length]);
        if (_parserStatus != yajl_status_ok){
            _parserError = [TRJsonLoaderPrivate createNSErrorForYAJLParser:_parser_handle usingJSON:data andStatus:_parserStatus];
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    yajl_complete_parse(_parser_handle);
    if (_onCompletionBlock) {
        _onCompletionBlock(_parserError);
    }
}

#pragma mark YAJL Parser Delegate functions

static int _start_map(void * ctx) {

    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
    
    __unsafe_unretained JSONInstanceMeta *top = [loader.context peek];

    // If context is empty, then assume we are starting the top level object;
    if (top == nil) {
        [loader pushContext:[JSONInstanceMeta initWithInstance:loader.object propertyMeta:nil]];
    }
    else {
        
        if ( top.propertyMeta && top.propertyMeta.isArray) {
            
            JSONInstanceMeta *instanceMeta = [JSONInstanceMeta initWithInstance:[top.propertyMeta newItemObject] propertyMeta:[JSONPropertyMeta initWithGetter:NULL setter:NULL type:top.propertyMeta.itemType]];
            [(NSMutableArray*)top.instance addObject:instanceMeta.instance];
            [loader pushContext:instanceMeta];
        }
        else{
            NSCAssert(loader.lastMapKey, @"Expecting a key map");
            JSONInstanceMeta *instanceMeta = [top.instance objectForPropertyNamed:[loader lastMapKey]];
            
            if ( instanceMeta ) {
                [loader pushContext:instanceMeta];
            }
            else {
                NSCAssert(NO, @"Expected an Object type");
                return 0;
            }
        }
    }
    
    return 1;
}

static int _end_map(void * ctx){
    
    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
    
    __unsafe_unretained JSONInstanceMeta *top = [loader.context peek];
    
    NSCAssert(top != nil, @"Not expecting empty context stack");

    // If we are about to pop the last object off the context stack, that
    // means we are done with an instance, so call the completion block.
    if ( [loader contextPopWillCompleteInstance]) {
        
        loader.object = top.instance;
    }
    
    [loader.context pop];

    return 1;
}

static int _start_array(void * ctx){
    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
    
    __unsafe_unretained JSONInstanceMeta *top = [loader.context count] == 0 ? nil : [loader.context peek];
    
    NSCAssert(top != nil, @"Not expecting empty context stack");
    NSCAssert(loader.lastMapKey, @"Expecting a key map");

    if (top.propertyMeta && top.propertyMeta.isArray) {
        [loader pushContext: [JSONInstanceMeta initWithInstance:[top.propertyMeta newItemObject] propertyMeta:[JSONPropertyMeta initWithGetter:NULL setter:NULL type:top.propertyMeta.itemType]]];
    }
    else {
        JSONInstanceMeta *array = [top.instance arrayForPropertyNamed:[loader lastMapKey]];
        if( array ) {
            [loader pushContext:array];
        }
        else {
            NSCAssert(NO, @"Expected an Array type");
        }
    }

    return 1;
}

static int _end_array(void * ctx){
    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
    
    __unsafe_unretained JSONInstanceMeta *top = [loader.context peek];
    NSCAssert(top.propertyMeta.isArray, @"Expecting to pop NSArray from context");
    
    [loader.context pop];

    return 1;
}


static int _map_key(void * ctx, const unsigned char * stringVal, size_t stringLen){

    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
    
    loader.lastMapKey = [[NSString alloc] initWithBytes:stringVal length:stringLen encoding:NSUTF8StringEncoding];

    return 1;
}

-(void)setValue:(id)value OnCurrentUsingBlock:(void (^)(id<JSONModelSerialize>obj, NSString* propertyName))block {

    __unsafe_unretained JSONInstanceMeta *top = [self.context peek];
    NSCAssert(top, @"Expecting an object on the context stack. Top most JSON must be a {}.");
    
    if ( top ) {
        
        if ( top.propertyMeta.isArray ) {
            NSMutableArray *array = top.instance;
            [array addObject:value];
        }
        else{
            NSCAssert(self.lastMapKey, @"Expecting a key, but it is nil");
            NSCAssert(block, @"Expecting a block, but it is nil");
            
            id<JSONModelSerialize> obj = top.instance;
            block(obj, [self lastMapKey]);
        }
    }
    
    [self clearLastMapKey];
    
}

static int _null(void * ctx){
    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
    //[loader didAdd:nil];

    __unsafe_unretained JSONInstanceMeta *top = [loader.context peek];
    NSCAssert(top, @"Expecting an object on the context stack. Top most JSON must be a {}.");
    
    if ( top ) {
        
        if ( top.propertyMeta.isArray ) {
            NSCAssert(NO, @"I didn't expect to get here. Handle this situation");
        }
        else{
            NSCAssert(loader.lastMapKey, @"Expecting a key, but it is nil");

            id<JSONModelSerialize> obj = top.instance;
            [obj setNullForProperty:loader.lastMapKey];
        }
    }
    
    [loader clearLastMapKey];
    
    return 1;
}

static int _boolean(void * ctx, int boolean){

    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;

    __block NSNumber *value = [NSNumber numberWithBool:boolean];
    
    [loader setValue:value OnCurrentUsingBlock:^(id<JSONModelSerialize> obj, NSString *propertyName) {
        [obj setBoolean:value forProperty:propertyName];
    }];
    
    return 1;
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

static int _string(void * ctx, const unsigned char * stringVal,
                   size_t stringLen){
    
    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;
    __block NSString *value = [[NSString alloc] initWithBytes:stringVal length:stringLen encoding:NSUTF8StringEncoding];

    [loader setValue:value OnCurrentUsingBlock:^(id<JSONModelSerialize> obj, NSString *propertyName) {
        [obj setString:value forProperty:propertyName];
    }];
    
    return 1;
}

static int _integer(void *ctx, long long integerVal){
    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;

    __block NSNumber *value = [NSNumber numberWithLongLong:integerVal];

    [loader setValue:value OnCurrentUsingBlock:^(id<JSONModelSerialize> obj, NSString *propertyName) {
        [obj setInteger:value forProperty:propertyName];
    }];
    
    return 1;
}

static int _double(void *ctx, double doubleVal){
    TRJsonLoaderPrivate *loader = (__bridge TRJsonLoaderPrivate*)ctx;

    __block NSNumber *value = [NSNumber numberWithDouble:doubleVal];
    
    [loader setValue:value OnCurrentUsingBlock:^(id<JSONModelSerialize> obj, NSString *propertyName) {
        [obj setNumber:value forProperty:propertyName];
    }];

    return 1;
}

// callbacks for yajl parser
// why is _number commented out? Well if you provide it, YAJL will pass all numbers as strings,
// meaning we have to do a really expensive NSNumberFormatter call. If we skip, we can only accept long longs and doubles
// but it's about 20% faster for the album dataset

static yajl_callbacks callbacks = {
    _null,
    _boolean,
    _integer,
    _double,
    NULL /* _number */,
   _string,
    _start_map,
    _map_key,
    _end_map,
    _start_array,
    _end_array
};


@end
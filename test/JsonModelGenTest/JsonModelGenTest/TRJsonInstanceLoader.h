//
//  TR_JSON_InstanceLoader.h
//  iOSDataBinding
//
// Copyright © 2012 Thomson Reuters Global Resources. All Rights Reserved.
// Proprietary and confidential information of TRGR. Disclosure, use, or reproduction
// without the written authorization of TRGR is prohibited.
//

#import <UIKit/UIKit.h>
//#import "TR_Abstract_InstanceLoader.h"

typedef enum {
    
    TRJsonInstanceLoaderOptionNone        = (1 << 0),
    TRJsonInstanceLoaderOptionSkipUnknown = (1 << 1)
    
} TRJsonInstanceLoaderOptions;

/** Type definition for block to be called when JSON deserialization is complete.
 @param error Non-nil if any parsings errors occured.
 */
typedef void(^TRJsonCompletedBlock)(NSError *error);

/** Loads JSON file into Objective-C class instances.
 
 Uses reflection to set properties on the instances using the key-value pairs in the given JSON data.
 */
@interface TRJsonInstanceLoader : NSObject

/**---------------------------------------------------------------------------
 * @name Creating a single instance from JSON data
 * ---------------------------------------------------------------------------
 */

/** Parses JSON data and creates an Objective-C instance.
 
 @param cls Class type of top-most instance.
 @param data JSON data to be parsed.
 @param error Non-nil if any parsings errors occured.
 */
+ (id) loadInstanceOfClass:(Class)cls
              withJSONData:(NSData *)data
                     error:(NSError* __autoreleasing *)error;

/** Parses JSON data and creates an Objective-C instance.
 
 @param cls Class type of top-most instance.
 @param filename Name of file with JSON data to be parsed.
 @param error Non-nil if any parsings errors occured.
 */
+ (id) loadInstanceOfClass:(Class)cls
     withJSONFromFileNamed:(NSString *)filename
                     error:(NSError* __autoreleasing *)error;

/**---------------------------------------------------------------------------
 * @name Creating an array of instances from JSON data
 * ---------------------------------------------------------------------------
 */

/** Parses JSON data and creates an array of Objective-C instances.
 
 @param cls Class type of top-most instance.
 @param data JSON data to be parsed.
 @param didCreateNewInstanceBlock Block to be called after each time a new instance is created.
 */
+ (void) loadInstancesOfClass:(Class)cls
                 withJSONData:(NSData*)data
;

/** Parses JSON data and creates an array of Objective-C instances.
 
 @param cls Class type of top-most instance.
 @param filename Name of file with JSON data to be parsed.
 */
+ (void) loadInstancesOfClass:(Class)cls
        withJSONFromFileNamed:(NSString*)filename;


/**---------------------------------------------------------------------------
 * @name Creating a single instance from a URL request
 * ---------------------------------------------------------------------------
 */

/** Requests JSON data from a URL, parses, and creates an Objective-C instance.
 
 @param cls Class type of top-most instance.
 @param url URL to be used to request the JSON data to be parsed.
 @param cachePolicy Cache policy to be applied to NSURLRequest ued to make request.
 @param onCompletionBlock Block to be called when parsing operation completes.
 */
+ (void) loadInstanceOfClass:(Class)cls
                     withUrl:(NSURL*)url
                 cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           onCompletionBlock:(TRJsonCompletedBlock)onCompletionBlock;

/**---------------------------------------------------------------------------
 * @name Creating an array of instances from a URL request
 * ---------------------------------------------------------------------------
 */

/** Requests and parses JSON data and creates an array of Objective-C instances, one for each top level object.
 
 @param cls Class type of top-most instance.
 @param url URL to be used to request the JSON data to be parsed.
 @param cachePolicy Cache policy to be applied to NSURLRequest ued to make request.
 @param onCompletionBlock Block to be called when parsing operation completes.
 */
+ (void) loadInstancesOfClass:(Class)cls
                      withUrl:(NSURL*)url
                  cachePolicy:(NSURLRequestCachePolicy)cachePolicy
            onCompletionBlock:(TRJsonCompletedBlock)onCompletionBlock;

/** Utility method for converting JSON returned types to the correct objective C type based on expected property
 
 @param input the value returned from the JSON parser
 @param str the property definition as returned from property_getAttributes
 */
+ (id) convertJSONValue:(id) input toCorrectTypeForAttributeCString:(const char *) str;

@end

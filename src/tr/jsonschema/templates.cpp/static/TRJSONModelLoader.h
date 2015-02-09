//
//  TR_JSON_InstanceLoader.h
//  iOSDataBinding
//
// Copyright © 2012 Thomson Reuters Global Resources. All Rights Reserved.
// Proprietary and confidential information of TRGR. Disclosure, use, or reproduction
// without the written authorization of TRGR is prohibited.
//

#import <UIKit/UIKit.h>

/** Type definition for block to be called when JSON deserialization is complete.
 @param error Non-nil if any parsings errors occured.
 */
typedef void(^TRJsonCompletedBlock)(NSError *error);

/** Loads JSON file into Objective-C class instances.
 
 Uses reflection to set properties on the instances using the key-value pairs in the given JSON data.
 */
@interface TRJSONModelLoader : NSObject

/**---------------------------------------------------------------------------
 * @name Creating a single instance from JSON data
 * ---------------------------------------------------------------------------
 */

/** Parses JSON data and creates an Objective-C instance.
 
 @param instance instance of top-most type.
 @param data JSON data to be parsed.
 @param error Non-nil if any parsings errors occured.
 */
+(id) load:(id)instance
              withJSONData:(NSData *)data
                     error:(NSError* __autoreleasing *)error;


/** Parses JSON data and creates an array of Objective-C instances.

 The top level JSON structure should be an array, with items of the type described by the object parameter.
 
 @param instance instance of top-most type.
 @param data JSON data to be parsed.
 @param error Non-nil if any parsings errors occured.
 */
+(NSArray*) loadArrayOf:(id)object withJSONData:(NSData *)data
                  error:(NSError* __autoreleasing *)error;

/** Parses JSON data and creates an Objective-C instance.
 
 @param instance instance of top-most type.
 @param filename Name of file with JSON data to be parsed.
 @param error Non-nil if any parsings errors occured.
 */
+(id) load:(id)object withJSONFromFileNamed:(NSString *)filename
     error:(NSError* __autoreleasing *)error;

/** Parses JSON data and creates an Objective-C instance.

 The top level JSON structure should be an array, with items of the type described by the object parameter.

 @param instance instance of top-most type.
 @param filename Name of file with JSON data to be parsed.
 @param error Non-nil if any parsings errors occured.
 */
+(NSArray*) loadArrayOf:(id)instance withJSONFromFileNamed:(NSString *)filename
        error:(NSError* __autoreleasing *)error;

/**---------------------------------------------------------------------------
 * @name Creating a single instance from a URL request
 * ---------------------------------------------------------------------------
 */

/** Requests JSON data from a URL, parses, and creates an Objective-C instance.
 
 @param object Meta class type of top-most instance.
 @param url URL to be used to request the JSON data to be parsed.
 @param cachePolicy Cache policy to be applied to NSURLRequest ued to make request.
 @param onCompletionBlock Block to be called when parsing operation completes.
 */
+(void) load:(id)object
             withUrl:(NSURL*)url
         cachePolicy:(NSURLRequestCachePolicy)cachePolicy
    onCompletionBlock:(TRJsonCompletedBlock)onCompletionBlock;

/** Utility method for converting JSON returned types to the correct objective C type based on expected property
 
 @param input the value returned from the JSON parser
 @param str the property definition as returned from property_getAttributes
 */
//+ (id) convertJSONValue:(id) input toCorrectTypeForAttributeCString:(const char *) str;

@end

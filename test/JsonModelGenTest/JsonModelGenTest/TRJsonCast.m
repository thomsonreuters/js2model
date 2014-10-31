//
//  TRJsonCast.m
//  iOSDataBinding
//
//  Created by kevin on 4/30/13.
//
//

#import "TRJsonCast.h"
#import <objc/runtime.h>

id accessorGetter(id self, SEL _cmd);

void accessorSetter(id self, SEL _cmd, id newValue);

@interface TRJsonCast ()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation TRJsonCast {
}

- (id)init
{
    self = [super init];
    if (self) {
        _dict = [NSMutableDictionary new];
    }
    return self;
}

+(BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *method = NSStringFromSelector(sel);
    
    if ([method hasPrefix:@"set"])
    {
        class_addMethod([self class], sel, (IMP) accessorSetter, "v@:@");
        return YES;
    }
    else
    {
        class_addMethod([self class], sel, (IMP) accessorGetter, "@@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

-(id)objectForKeyedSubscript:(id)key {
    return self.dict[key];
}

-(void)setObject:(id)value forKeyedSubscript:(id)key {
    self.dict[key] = value;
}

@end

id accessorGetter(id self, SEL _cmd)
{
    NSString *method = NSStringFromSelector(_cmd);
    return ((TRJsonCast*)self).dict[method];
}

void accessorSetter(id self, SEL _cmd, id newValue)
{
    NSString *method = NSStringFromSelector(_cmd);
    
    // remove set
    NSString *anID = [[method substringWithRange:NSMakeRange(3, method.length - 4)] lowercaseString];

    ((TRJsonCast*)self).dict[anID] = newValue;
}

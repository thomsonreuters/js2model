//
//  JsonModelSchema.swift
//  js2ModelSwift
//
//  Created by Kevin on 11/7/14.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

import Foundation

public protocol JsonModelSerialize {

    typealias ModelType: JsonModelSerialize

    class func modelSchema() -> JsonModelSchema<ModelType>

    func object(forPropertyNamed propertyName:String) -> JsonInstanceMeta<ModelType, AnyObject>
    func array(forPropertyNamed propertyName:String) ->  JsonInstanceMeta<ModelType, [AnyObject]>

    init()
    init(jsonData:[Byte])
    init(filename:String)

    func set(string val:String, forProperty propertyName:String)
    func set(number val:Double, forProperty propertyName: String)
    func set(integer val:Int, forProperty propetyName:String)
    func set(boolean val:Bool, forProperty propetyName:String)
    func setNil(forProperty propertyName:String)

    var additionalProperties: [String: Any] { get }
    func value(forAdditionalProperty propertyName:String) -> Any
    func set(value:Any, forAdditionalProperty propertyName:String)
}

public class JsonPropertyMeta<M: JsonModelSerialize, T> {
    
    var getter: (M)->T?;
    var setter: (M,T)->Void;
    var newInstance: ()->T;
    var isArray: Bool = false;
    var newItemInstance: (()->T)?;
    
    init(newInstance: ()->T, getter:(M)->T, setter: (M,T)->Void ) {
        self.getter = getter;
        self.setter = setter;
        self.newInstance = newInstance;
    }

    init(newArrayInstance: ()->T, newItemInstance: ()->T, getter:(M)->T, setter: (M,T)->Void) {
        self.getter = getter;
        self.setter = setter;
        self.newInstance = newArrayInstance;
        self.isArray = true;
        self.newItemInstance = newItemInstance;
    }
}

public class JsonInstanceMeta<M: JsonModelSerialize, T> {

    var instance: T;
    var propertyMeta: JsonPropertyMeta<M, T>;

    init(initWithInstance instance:T, propertyMeta:JsonPropertyMeta<M, T>) {
        self.instance = instance;
        self.propertyMeta = propertyMeta;
    }

}

public class JsonModelSchema<M: JsonModelSerialize> {

	var objects =  [String: JsonPropertyMeta<M, AnyObject>]();
	var arrays =   [String: JsonPropertyMeta<M, [AnyObject]>]();
	var strings =  [String: JsonPropertyMeta<M, String>]();
	var booleans = [String: JsonPropertyMeta<M, Bool>]();
	var integers = [String: JsonPropertyMeta<M, Int>]();
	var numbers =  [String: JsonPropertyMeta<M, Double>]();

    init(){}

    func getter<T>(forPropertyName propertyName:String, fromPropertySet propertySet:[String: JsonPropertyMeta<M, T>] ) -> (M)->T? {

        var propMeta = propertySet[propertyName];
        return propMeta!.getter;
    }

    func setter<T>(forPropertyName propertyName:String, fromPropertySet propertySet:[String: JsonPropertyMeta<M, T>] ) -> (M, T)->Void {

        var propMeta = propertySet[propertyName];
        return propMeta!.setter;
    }


    func object<T: JsonModelSerialize>(forPropertyNamed propertyName:(String), fromInstance instance: M, fromPropertySet propertySet:[String: JsonPropertyMeta<M, T>] ) ->
    JsonInstanceMeta<M, T> {
    
        var propMeta = propertySet[propertyName];

        if let pm = propMeta {

            var obj = pm.getter(instance);
            
            if let o = obj  {
                obj = pm.newInstance();
                pm.setter(instance, o);
            }
            
            return JsonInstanceMeta<M,T>(initWithInstance: obj!, propertyMeta: pm);

        }
        else {
            //NSLog(@"Object for property named '%@' not found in schema %@. Adding to additionalProperties.", propertyName, NSStringFromClass([instance class]));
            
            var propGetter:(M)->(Any) = { (m: M) in
                return m.value(forAdditionalProperty:propertyName);
            }
            
            var propSetter:(M,Any)->(Void) = { (m: M, t: Any) in
                m.set(t, forAdditionalProperty: propertyName);
            }
            
            var newInstanceInit: ()->T = { return T() };
            
            var propMeta = JsonPropertyMeta(
                newInstance: newInstanceInit,
                getter: propGetter,
                setter: propSetter
                );
            
            var newPropInstance:T = newInstanceInit()
            
            propSetter(instance, newPropInstance);
            
            return JsonInstanceMeta<M,T>(initWithInstance: newPropInstance, propertyMeta: propMeta);
        }
    }
    
    - (JSONInstanceMeta *)objectForPropertyNamed:(NSString *)propertyName forInstance:(id)instance {
        
        return [self objectForPropertyNamed:propertyName forInstance:instance from:self.objects];
        }
        
        - (JSONInstanceMeta *)arrayForPropertyNamed:(NSString *)propertyName forInstance:(id)instance {
            
            return [self objectForPropertyNamed:propertyName forInstance:instance from:self.arrays];
            }
            
            - (void)setValue:(id)val forProperty:(NSString *)propertyName forInstance:(id)instance inPropertySet:(NSDictionary *)propertySet{
                
                SEL setter = [self setterForProperty:propertyName from:propertySet];
                
                if(setter) {
                    [instance performSelector:setter withObject:val];
                }
                else {
                    NSLog(@"Setter for property named '%@' not found. Adding to additionalProperties", propertyName);
                    [[instance additionalProperties] setValue:val forKey:propertyName];
                }
                }
                
                - (void)setString:(NSString *)val forProperty:(NSString *)propertyName forInstance:(id)instance {
                    
                    [self setValue:val forProperty:propertyName forInstance:instance inPropertySet:self.strings];
                    }
                    
                    - (void)setNumber:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {
                        
                        [self setValue:val forProperty:propertyName forInstance:instance inPropertySet:self.numbers];
                        }
                        
                        - (void)setInteger:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {
                            
                            [self setValue:val forProperty:propertyName forInstance:instance inPropertySet:self.integers];
                            }
                            
                            - (void)setBoolean:(NSNumber *)val forProperty:(NSString *)propertyName forInstance:(id)instance {
                                
                                [self setValue:val forProperty:propertyName forInstance:instance inPropertySet:self.booleans];
                                }
                                
                                - (void)setNullForProperty:(NSString *)propertyName forInstance:(id)instance {
                                    
                                    SEL setter = [self setterForProperty:propertyName];
                                    
                                    if(setter) {
                                        [instance performSelector:setter withObject:nil];
                                    }
                                    else {
                                        NSLog(@"Setter for null property named '%@' not found.", propertyName);
                                    }
                                }
                                

}

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
    typealias ModelSchemaType: JsonModelSchema<ModelType>

    class func modelSchema() -> ModelSchemaType

    func object(forPropertyNamed propertyName:String) -> JsonInstanceMeta<ModelType, Any>
    func array(forPropertyNamed propertyName:String) ->  JsonInstanceMeta<ModelType, [Any]>

    init()
    init(jsonData:[Byte])
    init(filename:String)

    func set(string val:String, forProperty propertyName:String)
    func set(number val:Double, forProperty propertyName: String)
    func set(integer val:Int, forProperty propetyName:String)
    func set(boolean val:Bool, forProperty propetyName:String)

    func value(forAdditionalProperty propertyName:String) -> Any
    func set(value:Any, forAdditionalProperty propertyName:String)
}

public class JsonPropertyMeta<M: JsonModelSerialize, T> {
    
    var getter: (M)->T?;
    var setter: (M,T?)->Void;
    var newInstance: ()->T;
    var isArray: Bool = false;
    var newItemInstance: (()->T)?;
    
    init(newInstance: ()->T, getter:(M)->T?, setter: (M,T?)->Void ) {
        self.getter = getter;
        self.setter = setter;
        self.newInstance = newInstance;
    }

    init(newArrayInstance: ()->T, newItemInstance: ()->T, getter:(M)->T?, setter: (M,T?)->Void) {
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
	var arrays =   [String: JsonPropertyMeta<M, Array<Any>>]();
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


    func instanceMeta<T>(forPropertyNamed propertyName:(String), fromInstance instance: M, fromPropertySet propertySet:[String: JsonPropertyMeta<M, T>] ) -> JsonInstanceMeta<M, T>? {
        
        var propMeta = propertySet[propertyName];
        
        if let pm = propMeta {
            
            var obj: T? = pm.getter(instance);
            
            if( obj == nil ) {
                
                if let o: T = obj  {
                    obj = pm.newInstance();
                    pm.setter(instance, o);
                }
            }
            
            return JsonInstanceMeta(initWithInstance: obj!, propertyMeta: pm);
            
        }
        return nil;
    }
    
    
    func object(forPropertyNamed propertyName:(String), fromInstance instance: M ) -> JsonInstanceMeta<M, AnyObject>? {

        return instanceMeta(forPropertyNamed: propertyName, fromInstance: instance, fromPropertySet: objects);
    }
        
    func array(forPropertyNamed propertyName: String, forInstance instance: M) -> JsonInstanceMeta<M, Array<Any>>?{
        
        return instanceMeta(forPropertyNamed: propertyName, fromInstance: instance, fromPropertySet: arrays);
    }
    
    func set<T>(value val:T?, forProperty propertyName:String, forInstance instance:M, inPropertySet propertySet:[String: JsonPropertyMeta<M, T>]) {
                
        var propMeta = propertySet[propertyName];
        
        if let pm = propMeta {
            pm.setter(instance, val);
        }
        else {
            instance.set(val, forAdditionalProperty: propertyName);
        }
    }

    func set(string val:String, forProperty propertyName:String, forInstance instance:M) {

        set(value:val, forProperty:propertyName, forInstance:instance, inPropertySet:strings);
    }

    func set(number val:Double, forProperty propertyName:String, forInstance instance:M) {

        set(value:val, forProperty:propertyName, forInstance:instance, inPropertySet:numbers);
    }

    func set(integer val:Int, forProperty propertyName:String, forInstance instance:M) {
        
        set(value:val, forProperty:propertyName, forInstance:instance, inPropertySet:integers);
    }
    
    func set(boolean val:Bool, forProperty propertyName:String, forInstance instance:M) {
        
        set(value:val, forProperty:propertyName, forInstance:instance, inPropertySet:booleans);
    }
}

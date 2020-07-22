//
//  RealmHelper.swift

import UIKit
import RealmSwift
import SwiftKeychainWrapper

typealias Success = Bool

protocol DetachableObject: AnyObject {
    func toObject() -> Self
}

extension Object: DetachableObject {
    func toObject() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? DetachableObject {
                detached.setValue(detachable.toObject(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}

extension List: DetachableObject {
    func toObject() -> List<Element> {
        let result = List<Element>()
        forEach {
            result.append($0)
        }
        return result
    }
    
}

extension Object {
    @discardableResult
    func save() -> Success {
        return Realm.save(items: [self])
    }
    
    @discardableResult
    func delete() -> Success {
        return Realm.delete(items: [self])
    }
}

extension Object {
    
    static func find(_ primaryKey: Any) -> Self? {
        return instance().object(ofType: self, forPrimaryKey: primaryKey)
    }
    
    static func all<Element: Object>() -> Results<Element> {
        let items = instance().objects(Element.self)
        return items
    }
    
    static func `where`<Element:Object>(predicate: NSPredicate) -> Results<Element> {
        return all().filter(predicate)
    }
    
    @discardableResult
    static func deleteAll() -> Success  {
        let items: Results<Object> = instance().objects(self)
        
        return Realm.delete(items: items.toArray())
    }
    
    fileprivate static func instance() -> Realm {
        return Realm.instance()
    }
}
extension Realm {
    fileprivate static let KEY_REALM_SCHEMA_VERSION = "UP_Realm_Schema_Version"
    fileprivate static var schemaNumberVersion: NSNumber{
        get {
            return KeychainWrapper.standard.object(forKey: Realm.KEY_REALM_SCHEMA_VERSION) as? NSNumber ?? NSNumber.init(value: 0)
        }
        set {
            KeychainWrapper.standard.set(newValue, forKey: Realm.KEY_REALM_SCHEMA_VERSION)
        }
    }
    
    fileprivate static func instance() -> Realm {
        do {
            let config = Realm.Configuration(schemaVersion: Realm.schemaNumberVersion.uint64Value)
            let realm = try Realm(configuration: config)
            return realm
            
        } catch {
            print("Realm Database: Migration Needed.")
            Realm.schemaNumberVersion = NSNumber.init(value: Realm.schemaNumberVersion.uint64Value + 1)
            
            return instance()
        }
    }
    
    @discardableResult
    static func save(items: [Object]) -> Success {
        let instance = self.instance()
        
        do{
            for item in items {
                
                if let realm = item.realm {
                    try realm.write {
                        realm.create(type(of: item), value: item, update: true)
                    }
                } else {
                    instance.beginWrite()
                    instance.create(type(of: item), value: item, update: true)
                    try instance.commitWrite()
                }
            }
            
            return true
        }catch{
            return false
        }
    }
    
    @discardableResult
    static func delete(items: [Object]) -> Success {
        let instance = self.instance()
        
        instance.beginWrite()
        
        for item in items {
            guard let primaryKey = item.objectSchema.primaryKeyProperty else { continue }
            guard let value = item.value(forKey: primaryKey.name) else { continue }
            
            if let object = instance.dynamicObject(ofType: String(describing: item.classForCoder), forPrimaryKey: value) {
                instance.delete(object)
            }
        }
        
        do {
            try instance.commitWrite()
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult
    static func deleteAll() -> Success {
        let instance = self.instance()
        
        instance.beginWrite()
        
        instance.deleteAll()
        
        do {
            try instance.commitWrite()
            return true
        } catch {
            return false
        }
    }
    
    private static func setRealmConfiguration(){
        let config = Realm.Configuration(schemaVersion: Realm.schemaNumberVersion.uint64Value)
        Realm.Configuration.defaultConfiguration = config
    }
}

extension Array where Element: Object {
    @discardableResult
    func save() -> Success {
        return Realm.save(items: self)
    }
    
    @discardableResult
    func delete() -> Success {
        return Realm.delete(items: self)
    }
}

extension Results where Element: Object {
    func toArray() -> [Element] {
        return self.map({ item -> Element in
            return item.toObject()
        })
    }
    
    @discardableResult
    func delete() -> Success {
        let instance = Realm.instance()
        
        instance.beginWrite()
        
        forEach { (item) in
            instance.delete(item)
        }
        
        do {
            try instance.commitWrite()
            return true
        } catch {
            return false
        }
    }
}

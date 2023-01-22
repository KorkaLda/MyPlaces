//
//  StorageManager.swift
//  UITableViewApp
//
//  Created by Vladimir on 23.01.2023.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place:Place){
        try! realm.write{
            realm.add(place)
        }
    }
}

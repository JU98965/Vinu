//
//  ProjectCoreData+CoreDataProperties.swift
//  Vinu
//
//  Created by 신정욱 on 9/26/24.
//
//

import Foundation
import CoreData


extension ProjectCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectCoreData> {
        return NSFetchRequest<ProjectCoreData>(entityName: "ProjectCoreData")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var date: Date
    @NSManaged public var items: NSOrderedSet

}

// MARK: Generated accessors for items
extension ProjectCoreData {

    @objc(insertObject:inItemsAtIndex:)
    @NSManaged public func insertIntoItems(_ value: VideoCoreData, at idx: Int)

    @objc(removeObjectFromItemsAtIndex:)
    @NSManaged public func removeFromItems(at idx: Int)

    @objc(insertItems:atIndexes:)
    @NSManaged public func insertIntoItems(_ values: [VideoCoreData], at indexes: NSIndexSet)

    @objc(removeItemsAtIndexes:)
    @NSManaged public func removeFromItems(at indexes: NSIndexSet)

    @objc(replaceObjectInItemsAtIndex:withObject:)
    @NSManaged public func replaceItems(at idx: Int, with value: VideoCoreData)

    @objc(replaceItemsAtIndexes:withItems:)
    @NSManaged public func replaceItems(at indexes: NSIndexSet, with values: [VideoCoreData])

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: VideoCoreData)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: VideoCoreData)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSOrderedSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSOrderedSet)

}

extension ProjectCoreData : Identifiable {

}

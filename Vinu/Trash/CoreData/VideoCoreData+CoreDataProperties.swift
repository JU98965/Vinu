//
//  VideoCoreData+CoreDataProperties.swift
//  Vinu
//
//  Created by 신정욱 on 9/26/24.
//
//

import Foundation
import CoreData


extension VideoCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoCoreData> {
        return NSFetchRequest<VideoCoreData>(entityName: "VideoCoreData")
    }

    @NSManaged public var id: UUID
    @NSManaged public var assetID: String
    @NSManaged public var duration: Double
    @NSManaged public var projectData: ProjectCoreData

}

extension VideoCoreData : Identifiable {

}

//
//  CoreDataDisc+CoreDataClass.swift
//  Connect4
//
//  Created by COMP47390 on 21/01/2022.
//  Copyright © 2020 COMP47390. All rights reserved.
//
//

import Foundation
import CoreData

public class CoreDataDisc: NSManagedObject
{
    static func save(positions: [(row: Int, column: Int)], index offset: Int = 1,
                     winningPositions: [(row: Int, column: Int)] = [(Int, Int)](),
                     in managedContext: NSManagedObjectContext) -> [CoreDataDisc]? {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "CoreDataDisc", in: managedContext)
        else { return nil }
        
        var discs = [CoreDataDisc]()
        for (index, position) in positions.enumerated() {
            // Insert and config new discItem
            guard let discItem = NSManagedObject(entity: entity, insertInto: managedContext) as? CoreDataDisc
            else { return nil }
            discItem.row = Int16(position.row)
            discItem.column = Int16(position.column)
            discItem.index = Int16(index + offset)
            discItem.isWinning = winningPositions.contains(where: { $0.row == position.row && $0.column == position.column } )
            discs.append(discItem)
        }
                
        // save
        do { try managedContext.save() }
        catch let error as NSError { print("Could not save. \(error), \(error.userInfo)") }
        
        // return core data session
        return discs
    }
}

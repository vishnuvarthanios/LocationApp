//
//  HomeViewModel.swift
//  TravelHistory
//
//  Created by IOS-Vishnu on 05/08/21.
//

import Foundation
import CoreData
import UIKit

struct LocationDetails {

    var latitude : Double!
    var longitude : Double!
    var address : String!
    var date : String!

    var dictionary : [String : Any] {
        return ["latitude" : latitude as Any, "longitude" : longitude as Any, "address" : address as Any, "date" : date as Any]
    }
    
    var nsDictionary : NSDictionary {
        return dictionary as NSDictionary
    }
}


class HomeViewModel {
    var getLocationdetails = [LocationDetails]()

    func savelocationdata(latitude : Double, longitude : Double, address : String, date : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TravelHistory_Coredata", in: context)
        let savedata = NSManagedObject(entity: entity!, insertInto: context)
        savedata.setValue(latitude, forKey: "latitude")
        savedata.setValue(longitude, forKey: "longitude")
        savedata.setValue(address, forKey: "address")
        savedata.setValue(date, forKey: "date")

        do {
            try context.save()
        } catch {
            print("Failed Saving")
        }
    }
    
    func fetchlocationdata(onSuccess: @escaping (Bool) -> ()) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TravelHistory_Coredata")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let result   = try context.fetch(fetchRequest)
            self.getLocationdetails.removeAll()
            if (result.count) > 0 {
                for order in result {
                    guard let theOrder = order as? TravelHistory_Coredata else {continue}
                    let keys = Array(theOrder.entity.attributesByName.keys)
                    let dict = theOrder.dictionaryWithValues(forKeys: keys)
                    getLocationdetails.append(LocationDetails(latitude: dict["latitude"] as? Double ?? 0.0, longitude: dict["longitude"] as? Double ?? 0.0, address: dict["address"] as? String ?? "", date: dict["date"] as? String ?? ""))
                 }
            }
            onSuccess(true)
        } catch let error as NSError {
          print("Could not fetch \(error)")
        }
    }
}
 

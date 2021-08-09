//
//  ViewController.swift
//  TravelHistory
//
//  Created by IOS-Vishnu on 05/08/21.
//

import UIKit
import CoreData
import CoreLocation

var firstTime = false

class ViewController: UIViewController {
    
    weak var timer: Timer?
    var viewModel = HomeViewModel()
    var locationManager = CLLocationManager()
    @IBOutlet weak var locationTableView: UITableView!
    var addTimer : TimeInterval = 600.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTableView.register(UINib(nibName:"LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        locationTableView.rowHeight = UITableView.automaticDimension
        locationTableView.reloadData()
        
        self.viewModel.fetchlocationdata(onSuccess: { status  in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy, h:mm:ss a"
            let count = self.viewModel.getLocationdetails.count
            if count != 0 {
                if firstTime == true {
                    let startdate = dateFormatter.date(from: self.viewModel.getLocationdetails[count - 1].date ?? "")
                    let timeInterval = Date().timeIntervalSince(startdate ?? Date())
                    print(self.timeString(time: timeInterval))
                    if timeInterval >= 600.0 {
                        self.determineMyCurrentLocation()
                    } else {
                        self.addTimer = 600.0 - timeInterval
                    }
                } else {
                    self.determineMyCurrentLocation()
                }
            } else {
                self.determineMyCurrentLocation()
            }
        })
     }
    
    override func viewDidAppear(_ animated: Bool) {
        self.startTimer()
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestLocation()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: addTimer, repeats: true) { [weak self] _ in
            self?.addTimer = 600.0
            self?.determineMyCurrentLocation()
         }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    deinit {
        stopTimer()
    }
    
    func scrollToLastRow(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.viewModel.getLocationdetails.count-1, section: 0)
            self.locationTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
 
    func timeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60

        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }

 }

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //self.locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        let userLocation:CLLocation = locations[0] as CLLocation
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        location.placemark { placemark, error in
            guard let placemark = placemark else {
                print("Error:", error ?? "nil")
                return
            }
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "MMM dd yyyy, h:mm:ss a"
            let dateString = df.string(from: date)
            let address = placemark.postalAddressFormatted ?? ""
            
            self.viewModel.savelocationdata(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, address: address, date: dateString)
            self.viewModel.fetchlocationdata(onSuccess: { status  in
                
            })
            
            self.locationTableView.reloadData()
            self.scrollToLastRow()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getLocationdetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        
        let address = self.viewModel.getLocationdetails[indexPath.row].address ?? ""
        let date = self.viewModel.getLocationdetails[indexPath.row].date ?? ""
        let lat = self.viewModel.getLocationdetails[indexPath.row].latitude ?? 0.0
        let long = self.viewModel.getLocationdetails[indexPath.row].longitude ?? 0.0
        let finaladdress = "Address : \(address)\nlat & long: \(lat) : \(long)\nDate : \(date)"
        cell.addressLabel.text = finaladdress
        return cell
     }
    
}

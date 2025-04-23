//
//  LocationDemoViewController.swift
//  MyContactList
//
//  Created by Anh Phan on 4/23/25.
//

import UIKit
import CoreLocation

class LocationDemoViewController: UIViewController {
    
    @IBOutlet weak var txtStreet: UITextField!
    
    @IBOutlet weak var txtCity: UITextField!
    
    @IBOutlet weak var txtState: UITextField!
    
    @IBOutlet weak var lblLatitude: UILabel!
    
    @IBOutlet weak var lblLongitude: UILabel!
    
    @IBOutlet weak var lblLocationAccuracy: UILabel!
    
    @IBOutlet weak var lblHeading: UILabel!
    
    @IBOutlet weak var lblHeadingAccuracy: UILabel!
    
    @IBOutlet weak var lblAltitude: UILabel!
    
    @IBOutlet weak var lblAltitudeAccuracy: UILabel!
    
    lazy var geoCoder = CLGeocoder()
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    }
    
    @IBAction func addressToCoordinates(_ sender: Any) {
        let address = "\(txtStreet.text!), \(txtCity.text!), \(txtState.text!)"
        geoCoder.geocodeAddressString(address) {(placemarks, error) in self.processAddressResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    private func processAddressResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print ("Geocode Error: \(error)")
        }
        else {
            var bestMatch: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                bestMatch = placemarks.first?.location
            }
            if let coordinate = bestMatch?.coordinate {
                lblLatitude.text = String(format: "%g\u{00B0}", coordinate.latitude)
                lblLongitude.text = String(format: "%g\u{00B0}", coordinate.longitude)
            }
            else {
                print("Didn't find any matching locations")
            }
        }
    }
    
    @IBAction func deviceCoordinates(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ContactsViewController.swift
//  MyContactList
//
//  Created by Anh Phan on 4/2/25.
//

import UIKit
import CoreData
import AVFoundation


class ContactsViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentContact: Contact?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var txtAddress: UITextField!
    
    @IBOutlet weak var txtCity: UITextField!
    
    @IBOutlet weak var txtState: UITextField!
    
    
    @IBOutlet weak var txtZipcode: UITextField!
    
    @IBOutlet weak var txtCell: UITextField!
    
    @IBOutlet weak var txtPhone: UITextField!
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var lblBirthdate: UILabel!
    
    @IBOutlet weak var btnChange: UIButton!
    
    @IBOutlet weak var imgContactPicture: UIImageView!
    
    @IBOutlet weak var btnTakePicture: UIButton!
    
    @IBOutlet weak var lblPhone: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if currentContact != nil {
            txtName.text = currentContact!.contactName
            txtAddress.text = currentContact!.streetAddress
            txtCity.text = currentContact!.city
            txtState.text = currentContact!.state
            txtZipcode.text = currentContact!.zipCode
            txtPhone.text = currentContact!.phoneNumber
            txtCell.text = currentContact!.cellNumber
            txtEmail.text = currentContact!.email
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            if currentContact!.birthday != nil {
                lblBirthdate.text = formatter.string(from: currentContact!.birthday!)
            }
            
            if let imageData = currentContact?.image as? Data {
                imgContactPicture.image = UIImage(data: imageData)
            }
        }
        
        changeEditMode(self)
        
        let textFields: [UITextField] = [txtName, txtAddress, txtCity, txtState, txtZipcode, txtPhone, txtCell, txtEmail]
        
        for textfield in textFields {
            textfield.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControl.Event.editingDidEnd)
        }
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(callPhone(gesture:)))
        lblPhone.addGestureRecognizer(longPress)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueContactDate") {
            let dateController = segue.destination as! DateViewController
            dateController.delegate = self
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if currentContact == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentContact = Contact (context: context)
        }
        currentContact?.contactName = txtName.text
        currentContact?.streetAddress = txtAddress.text
        currentContact?.city = txtCity.text
        currentContact?.state = txtState.text
        currentContact?.zipCode = txtZipcode.text
        currentContact?.cellNumber = txtCell.text
        currentContact?.phoneNumber = txtPhone.text
        currentContact?.email = txtEmail.text
        return true
    }
    
    func dateChanged(date: Date) {
        if currentContact == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentContact = Contact(context: context)
        }
        
        currentContact?.birthday = date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        lblBirthdate.text = formatter.string(from: date)
    }
    
    @objc func saveContact() {
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
        
        /* to check if data is saving by printing in console
         
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Contact>(entityName: "Contact")

        do {
            let results = try context.fetch(request)
            print("Total contacts saved: \(results.count)")
            for contact in results {
                print("Contact name: \(contact.contactName ?? "No name")")
            }
        } catch {
            print("Error fetching: \(error)")
        }
         
         */
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [txtName, txtAddress, txtCity, txtState, txtZipcode, txtPhone, txtCell, txtEmail]
        if sgmtEditMode.selectedSegmentIndex == 0 {
            for textField in textFields {
                textField.isUserInteractionEnabled = false
                textField.borderStyle = UITextField.BorderStyle.roundedRect
            }
            btnChange.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
        else if sgmtEditMode.selectedSegmentIndex == 1 {
            for textField in textFields {
                textField.isUserInteractionEnabled = true
                textField.borderStyle = UITextField.BorderStyle.roundedRect
            }
            btnChange.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveContact))
        }
    }
    
    @IBAction func changePicture(_ sender: Any) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != AVAuthorizationStatus.authorized {
            let alertController = UIAlertController(title: "Camera Access Denied", message: "In order to take pictures, you need tto allow the app to access the camera in the Settings.", preferredStyle: .alert)
            let actionSettings = UIAlertAction(title: "Open Settings", style: .default) {action in self.openSettings()
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(actionSettings)
            alertController.addAction(actionCancel)
            present(alertController, animated: true, completion: nil)
        }
        else {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraController = UIImagePickerController()
                cameraController.sourceType = .camera
                cameraController.cameraCaptureMode = .photo
                cameraController.delegate = self
                cameraController.allowsEditing = true
                self.present(cameraController, animated: true, completion: nil)
            }
        }
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            imgContactPicture.contentMode = .scaleAspectFit
            imgContactPicture.image = image
            
            if currentContact == nil {
                let context = appDelegate.persistentContainer.viewContext
                currentContact = Contact(context: context)
            }
            currentContact?.image = image.jpegData(compressionQuality: 1.0)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func callPhone(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let number = txtCell.text
            if number!.count > 0 {
                let url = NSURL(string: "telprompt://\(number!)")
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                print("Calling Phone Number: \(url!)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.keyboardDidShow(notification:)), name:UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.height
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
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

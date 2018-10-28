//
//  mainController.swift
//  blink
//
//  Created by Vedant Jain on 27/10/18.
//  Copyright © 2018 Vedant Jain. All rights reserved.
//

import UIKit
import UserNotifications

var inputArray:[String] = []
let bounds = UIScreen.main.bounds

let defaults = UserDefaults.standard

// Receive
//if let name = defaults.stringForKey("inputArray") {
//    print(name)
//    // Will output "theGreatestName"
//}

class inputCell: UICollectionViewCell {
    
    // 0 - no, 1 - blue, 2 - red
    var priority = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
    }
    
    let inputLabel: UILabel = {
        let inputLabel = UILabel()
//        inputLabel.text = inputArray.last
        inputLabel.font = UIFont(name: "Avenir-Medium", size: 15)
        inputLabel.textAlignment = .left
        inputLabel.translatesAutoresizingMaskIntoConstraints = false
        return inputLabel
    }()
    
    
    
    func setupViews() {
        addSubview(inputLabel)
        inputLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        inputLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        inputLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        inputLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class MainController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UNUserNotificationCenterDelegate {
    
    let cellId = "cellId"
    
    let textView: UIView = {
        let view = UIView()
        return view
    }()
    
    let inputField: UITextField = {
        //        let screenWidth = view.bounds.width
        let inputField = UITextField(frame: CGRect(x: 20, y: 100, width: bounds.width, height: 40))
        inputField.placeholder = ""
        inputField.keyboardType = UIKeyboardType.alphabet
        inputField.autocorrectionType = .no
        inputField.font = UIFont(name: "Avenir-Medium", size: 15)
        inputField.backgroundColor = .white
        inputField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.bottom
        inputField.frame.origin.y = bounds.height
        return inputField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //testing notifications
//        let content = UNMutableNotificationContent()
//        content.title = "Title"
//        content.body = "Body"
//        content.sound = UNNotificationSound.default
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        let startDate = Date()
//        let triggerDate = Calendar.current.dateComponents([.weekday,.hour,.minute], from: startDate)
//
//        let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        UNUserNotificationCenter.current().delegate = self
        
        //hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        collectionView?.backgroundColor = .white
        
        view.addSubview(textView)
        
        //idk why
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.collectionView.register(inputCell.self, forCellWithReuseIdentifier: cellId)
        
        self.inputField.delegate = self
        
        //swipe recognizer -- add
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeCollectionView))
        swipe.direction = .up
        view.addGestureRecognizer(swipe)
        
        //double tap recogniser -- delete
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapCollectionView))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        //single tap recognizer -- change priority
        let priority: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTapCollectionView))
        priority.numberOfTapsRequired = 1
        view.addGestureRecognizer(priority)
        
        //adding padding
        collectionView!.contentInset = UIEdgeInsets(top: 40, left: 40, bottom: 10, right: 40)
        
    }
    
    private func setupInputComponents() {
        textView.addSubview(inputField)
        inputField.becomeFirstResponder()
        inputField.frame.origin.y = inputField.frame.origin.y - 334
    }
    
    func textFieldShouldReturn(_ inputField: UITextField) -> Bool {
        inputField.resignFirstResponder()
        inputField.frame.origin.y = bounds.height
        textView.isHidden = true
        
        //create label
        inputArray.append(inputField.text!)
        print(inputArray)
        
        //clear field
        inputField.text = ""
        
        //reload collectionView
        collectionView.reloadData()
        
        return true
    }
    
    @objc func didSwipeCollectionView() {
        print("Recognized - swipe up gesture")
        textView.isHidden = false
        setupInputComponents()
    }
    
    @objc func didDoubleTapCollectionView(gesture: UITapGestureRecognizer) {
        print("Recognized - double tap")
        if let indexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) {
            //cell was tapped
            let cell: inputCell = self.collectionView.cellForItem(at: indexPath) as! inputCell
            print(cell.inputLabel.text ?? String())
            inputArray.remove(at: indexPath.item)
            print("After deletion: ", inputArray)
            collectionView.deleteItems(at: [indexPath])
            //            collectionView.reloadData()
        } else {
            //collectionview was tapped
        }
    }
    
    @objc func didSingleTapCollectionView(gesture: UITapGestureRecognizer) {
        print("Recognized - single tap")
        if let indexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) {
            //cell was tapped
            let cell: inputCell = self.collectionView.cellForItem(at: indexPath) as! inputCell
            cell.priority = (cell.priority + 1) % 3
            switch(cell.priority) {
                case 0:
                    cell.inputLabel.textColor = .black
                    break
                case 1:
                    cell.inputLabel.textColor = .blue
                    print("Scheduled Notification")
                    let content = UNMutableNotificationContent()
                    content.title = cell.inputLabel.text ?? String()
                    var date = DateComponents()
                    date.hour = 8 // 24 hour system
                    date.minute = 00
                    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                    let request = UNNotificationRequest(identifier: cell.inputLabel.text ?? String(), content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    break
                case 2:
                    cell.inputLabel.textColor = .red
                    print("Scheduled Notification")
                    let content = UNMutableNotificationContent()
                    content.title = cell.inputLabel.text ?? String()
                    var date = DateComponents()
                    for i in 1...24 {
                        date.hour = i
                        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                        let request = UNNotificationRequest(identifier: cell.inputLabel.text ?? String(), content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    }
                    break
                default:
                    print("Case statement problem")
            }
            
        } else {
            //collectionview was tapped
            if (inputField.isHidden == false) {
                inputField.resignFirstResponder()
                inputField.frame.origin.y = bounds.height
                textView.isHidden = true
                inputField.text = ""
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Displaying: ", inputArray.count)
        return inputArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:inputCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! inputCell
        cell.inputLabel.text = inputArray[indexPath.item]
        cell.priority = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (inputArray[indexPath.row] as NSString).size(withAttributes: nil)
        return CGSize(width: size.width + 40, height: size.height + 20)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
}

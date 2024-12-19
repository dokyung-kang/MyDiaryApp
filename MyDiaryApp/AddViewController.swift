//
//  AddViewController.swift
//  MyDiaryApp
//
//  Created by DDWU on 12/19/24.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet var titleText: UITextField!
    @IBOutlet var detailText: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var date: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let today = Date()  
        datePicker.date = today

        date = Int32(today.timeIntervalSince1970)
    }
    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender

        date = Int32(datePickerView.date.timeIntervalSince1970)
    }
    
    @IBAction func btnAddItem(_ sender: UIButton) {
        dbManager?.insertData(titleText.text!, date, detailText.text!)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
}

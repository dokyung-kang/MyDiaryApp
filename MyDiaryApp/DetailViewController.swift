//
//  DetailViewController.swift
//  MyDiaryApp
//
//  Created by DDWU on 12/19/24.
//

import UIKit

class DetailViewController: UIViewController {

    var receiveItem: TaskDTO!
    
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblTitle: UITextField!
    @IBOutlet var lblDetail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let date = Date(timeIntervalSince1970: TimeInterval(receiveItem.date))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEE hh:mm a"
        
        lblDate.text = formatter.string(from: date)
        lblTitle.text = receiveItem.title
        lblDetail.text = receiveItem.detail
    }
    

    func receiveItem(_ item: TaskDTO){
        receiveItem = item
    }
    
    @IBAction func btnUpdateItem(_ sender: UIButton) {
        dbManager?.updateData(Int32(receiveItem.id), lblTitle.text!, lblDetail.text!)
        
        _ = navigationController?.popViewController(animated: true)
    }

}

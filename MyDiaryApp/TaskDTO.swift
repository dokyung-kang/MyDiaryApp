//
//  TaskDTO.swift
//  MyDiaryApp
//
//  Created by DDWU on 12/19/24.
//

import Foundation

class TaskDTO {
    var id: Int
    var title: String?
    var date: Int32
    var detail: String?
    var icon: String?
    
    init(id: Int, title: String, date: Int32, detail: String, icon: String) {
        self.id = id
        self.title = title
        self.date = date
        self.detail = detail
        self.icon = icon
    }
}

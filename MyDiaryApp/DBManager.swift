//
//  DBManager.swift
//  MyDiaryApp
//
//  Created by DDWU on 12/19/24.
//

import UIKit
import SQLite3
import Foundation

class DBManager{
    
    let DB_NAME = "my_app_db.sqlite"
    let TABLE_NAME = "my_table"
    let COL_ID = "id"
    let COL_TITLE = "title"
    let COL_DATE = "date"
    let COL_DETAIL = "detail"
    let COL_ICON = "icon"
    
    var db:OpaquePointer? = nil
    var itemDTO: TaskDTO!
    
    func initDatabase(){
        openDatabase()
        createTable()
    }
    
    func openDatabase(){
        let dbFile = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(DB_NAME)
        
        if sqlite3_open(dbFile.path, &db) == SQLITE_OK {
            print("Open!!!")
            print(dbFile)
        } else {
            print("Failed!!!")
        }
    }
    
    func createTable(){
        let createTableString = """
            CREATE TABLE IF NOT EXISTS \(TABLE_NAME) ( \(COL_ID) INTEGER PRIMARY KEY AUTOINCREMENT, \(COL_TITLE) TEXT, \(COL_DATE) INTEGER, \(COL_DETAIL) TEXT, \(COL_ICON) TEXT);
"""
        
        print("TABLE SQL: \(createTableString)")
        
        if sqlite3_exec(db, createTableString, nil, nil, nil) == SQLITE_OK {
            print("The table is created")
        } else {
            let error = String(cString: sqlite3_errmsg(db)!)
            print("Table Creation Error: \(error)")
        }
    }
    
    func insertData(_ title: String, _ date: Int32, _ detail: String){
        
        openDatabase()
        
        var insertStmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "insert into \(TABLE_NAME) values (null, ?, ?, ?, ?)", -1, &insertStmt, nil) == SQLITE_OK {
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

            // title
            if sqlite3_bind_text(insertStmt, 1, title, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Title Text Binding Failure: \(errmsg)")
                return
            }
            
            // date
            if sqlite3_bind_int(insertStmt, 2, date) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Date Int Binding Failure: \(errmsg)")
                return
            }
            
            // detail
            if sqlite3_bind_text(insertStmt, 3, detail, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("detail Text Binding Failure: \(errmsg)")
                return
            }
            
            let randomNum = Int(arc4random_uniform(3)) + 1

            var icon: String

            switch randomNum {
            case 1:
                icon = "pencil.png"
            case 2:
                icon = "clock.png"
            case 3:
                icon = "cart.png"
            default:
                icon = "cart.png"
            }
            
            // icon
            if sqlite3_bind_text(insertStmt, 4, icon, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Icon Text Binding Failure: \(errmsg)")
                return
            }
            
            if sqlite3_step(insertStmt) == SQLITE_DONE{
                print("Successfully inserted")
            } else {
                print("insert error")
            }
            
            sqlite3_finalize(insertStmt)
            closeDatabase()
        } else {
            print("Insert statment is not prepared.")
        }
    }
    
    func selectAll(){
        
        openDatabase()
        
        let sql = "select * from \(TABLE_NAME);"
    
        var queryResult: OpaquePointer?
    
        if sqlite3_prepare(db, sql, -1, &queryResult, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Reading Error : \(errmsg)")
            return
        }
        
        while(sqlite3_step(queryResult) == SQLITE_ROW){
            let id = sqlite3_column_int(queryResult, 0)
            let title = String(cString: sqlite3_column_text(queryResult, 1))
            let date = sqlite3_column_int(queryResult, 2)
            let detail = String(cString: sqlite3_column_text(queryResult, 3))
            let icon = String(cString: sqlite3_column_text(queryResult, 4))
            
            items.append(TaskDTO(id: Int(id), title: title, date: date, detail: detail, icon: icon))
        }
        
        sqlite3_finalize(queryResult)
        closeDatabase()
    }
    
    func updateData(_ id: Int32, _ title: String, _ detail: String){
        
        openDatabase()
        
        let query = "update \(TABLE_NAME) set \(COL_TITLE) = ?, \(COL_DETAIL) = ? where \(COL_ID) = ?;"
            
        var stmt: OpaquePointer?
            
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing update: \(errmsg)")
            return
        }
        
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
        // title
        if sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Title Text Binding Failure: \(errmsg)")
            return
        }
            
        // detail
        if sqlite3_bind_text(stmt, 2, detail, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Detail Text Binding Failure: \(errmsg)")
            return
        }
         
        // id
        if sqlite3_bind_int(stmt, 3, id) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Id Integer Binding Failure: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Update Failure: \(errmsg)")
            return
        }
            
        print("Successfully updated")
            
        sqlite3_finalize(stmt)
        closeDatabase()
    }
    
    func deleteData(_ id: Int32){
        
        openDatabase()
        
        let query = "delete from \(TABLE_NAME) where \(COL_ID) = ?"
        var deleteStmt: OpaquePointer?
            
        if sqlite3_prepare(db, query, -1, &deleteStmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing stmt: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(deleteStmt, 1, id) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Id Integer Binding Failure: \(errmsg)")
            return
        }
            
        if sqlite3_step(deleteStmt) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Delete Failure: \(errmsg)")
            return
        }
            
        sqlite3_finalize(deleteStmt)
        closeDatabase()
    }
    
    func dropTable() {
        
        openDatabase()
        
        if sqlite3_exec(db, "drop table if exists \(TABLE_NAME)", nil, nil, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Drop Error: \(errmsg)")
            return
        }
        
        closeDatabase()
    }
    
    func closeDatabase() {
        sqlite3_close(db)
    }
}

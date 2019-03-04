//
//  ViewController.swift
//  Sqllite_test
//
//  Created by Admin on 4/3/2562 BE.
//  Copyright © 2562 AryMiku. All rights reserved.
//

import UIKit
import SQLite3
class ViewController: UIViewController {
    
    var db: OpaquePointer?
    var pointer:OpaquePointer?
    var stmt: OpaquePointer?
    @IBOutlet weak var selectedDate: UIDatePicker!
    @IBOutlet weak var showResultLabel: UILabel!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldRanking: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBAction func buttonSave(_ sender: Any) {
        
        
        let currentDate = selectedDate.date
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "dd/MM/YYYY"
        let thaiLocale = NSLocale(localeIdentifier: "TH_th")
        myFormatter.locale = thaiLocale as Locale
        let currentDateText = myFormatter.string(from: currentDate)
        showResultLabel.text = currentDateText
//        let name = textFieldName.text?.trimmingCharacters(in:.whitespacesAndNewlines)
//        let powerrank = textFieldRanking.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        let name = textFieldName.text! as NSString
        let powerrank = textFieldRanking.text
//        if(name?.isEmpty)!{
//            print("Name is empty")
//            return;
//        }
//        if(powerrank?.isEmpty)!{
//            print("rank is empty")
//            return;
//        }
        
        
        let insertQuery = "INSERT INTO Heroes (name,powerrank,datess) VALUES (?,?,?)"
        
        if sqlite3_prepare(db,insertQuery,-1,&stmt,nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_bind_text(stmt,1,name.utf8String,-1,nil) != SQLITE_OK{
            print("Error binding name")
        }

        if sqlite3_bind_int(stmt,2,(powerrank! as NSString).intValue) != SQLITE_OK{
            print("Error binding powerrank")
        }
        
        if sqlite3_bind_text(stmt,3,currentDateText,-1,nil) != SQLITE_OK{
            print("Error binding date")
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            print("Hero saved successful")
        }
        
        
        
        select()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask,appropriateFor: nil,create:
            false).appendingPathComponent("HeroDatabase2.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening database")
            return
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,powerrank INTEGER,datess TEXT)"
        
        if sqlite3_exec(db,createTableQuery,nil,nil,nil) != SQLITE_OK{
            print("Error Createing Table")
            return
        }
        
        print ("Evething is fine")
        
        select()
    }
    
    func select(){
        let sql = "SELECT * FROM Heroes"
        sqlite3_prepare(db,sql,-1,&pointer,nil)
        textView.text = ""
        var id : Int32
        var name : String
        var powerrank : Int32
        var datess : String
        
        while(sqlite3_step(pointer) == SQLITE_ROW){
            id = sqlite3_column_int(pointer,0)
            textView.text?.append("id:\(id)\n")
            
            name = String(cString:sqlite3_column_text(pointer,1))
            showResultLabel.text = name
            textView.text?.append("name:\(name)\n")
            
            powerrank = sqlite3_column_int(pointer,2)
            textView.text?.append("number:\(powerrank)\n")
            
            datess = String(cString:sqlite3_column_text(pointer,3))
            textView.text?.append("date:\(datess)\n")
            
        }
    }

}


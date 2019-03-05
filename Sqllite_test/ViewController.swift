//
//  ViewController.swift
//  Sqllite_test
//
//  Created by Admin on 4/3/2562 BE.
//  Copyright © 2562 AryMiku. All rights reserved.
//

import UIKit
import SQLite3
class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priorityTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priorityTypes[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPriority = priorityTypes[row]
        textfiledlike.text = selectedPriority
    }
    
    var selectedPriority : String?
    var priorityTypes = ["ไม่ชอบ","ปานกลาง","ชอบ"]
    
    func createPickerView(){
        let pickerView = UIPickerView()
        pickerView.delegate = self
        textfiledlike.inputView = pickerView
    }
    
    func dissmissPickerView(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dissmissKeyboard))
        toolBar.setItems([doneButton],animated:false)
        toolBar.isUserInteractionEnabled = true
        textfiledlike.inputAccessoryView = toolBar
    }
    
    @objc func dissmissKeyboard(){
        view.endEditing(true)
    }
    
    var db: OpaquePointer?
    var pointer:OpaquePointer?
    var stmt: OpaquePointer?
    @IBOutlet weak var selectedDate: UIDatePicker!
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
//        let name = textFieldName.text?.trimmingCharacters(in:.whitespacesAndNewlines)
//        let powerrank = textFieldRanking.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        let employee = EmployeeName.text! as NSString
        let product = textFieldName.text! as NSString
        let place = textFieldRanking.text! as NSString
        let likee = textfiledlike.text! as NSString
//        if(name?.isEmpty)!{
//            print("Name is empty")
//            return;
//        }
//        if(powerrank?.isEmpty)!{
//            print("rank is empty")
//            return;
//        }
        
        
        let insertQuery = "INSERT INTO Prototype (employee,product,place,datess,likee) VALUES (?,?,?,?,?)"
        
        if sqlite3_prepare(db,insertQuery,-1,&stmt,nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_bind_text(stmt,1,employee.utf8String,-1,nil) != SQLITE_OK{
            print("Error binding name")
        }
        
        if sqlite3_bind_text(stmt,2,product.utf8String,-1,nil) != SQLITE_OK{
            print("Error binding date")
        }
        
        if sqlite3_bind_text(stmt,3,place.utf8String,-1,nil) != SQLITE_OK{
            print("Error binding date")
        }
        
        if sqlite3_bind_text(stmt,4,currentDateText,-1,nil) != SQLITE_OK{
            print("Error binding date")
        }
        
        if sqlite3_bind_text(stmt,5,likee.utf8String,-1,nil) != SQLITE_OK{
            print("Error binding date")
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            print("Hero saved successful")
        }
        
//        textFieldName.text = ""
//        textFieldRanking.text = ""
//        textfiledlike.text = ""
        
        
        select()
        
    }
    @IBAction func ButtonDelete(_ sender: Any) {
        let alert = UIAlertController(title: "ลบข้อมูล", message: "ID ของแถวที่ต้องการจะลบ", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { tf in
            tf.placeholder = "ID ของแถวที่ต้องการลบ"
            tf.font = UIFont.systemFont(ofSize : 18)
            tf.keyboardType = .numberPad
        })
        let btCancel = UIAlertAction(title:"Cancel",style:.cancel,handler:nil)
        let btOK = UIAlertAction(title:"OK",style:.default,handler:{
            _ in guard let id = Int32(alert.textFields!.first!.text!)else{
                return
            }
            let sql = "DELETE FROM Prototype WHERE id = \(id)"
            sqlite3_exec(self.db, sql,nil,nil,nil)
            self.select()
        })
        alert.addAction(btCancel)
        alert.addAction(btOK)
        present(alert,animated:true,completion:nil)
    }
    @IBOutlet weak var textfiledlike: UITextField!
    @IBAction func showorhide(_ sender: Any) {
        if(textView.isHidden){
            textView.isHidden = false;
        }
        else{
            textView.isHidden = true;
        }
    }
    @IBOutlet weak var EmployeeName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        dissmissPickerView()
        
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask,appropriateFor: nil,create:
            false).appendingPathComponent("Prototype2.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening database")
            return
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Prototype (id INTEGER PRIMARY KEY AUTOINCREMENT,employee TEXT,product TEXT,place TEXT,datess TEXT,likee TEXT)"
        
        if sqlite3_exec(db,createTableQuery,nil,nil,nil) != SQLITE_OK{
            print("Error Createing Table")
            return
        }
        
        print ("Evething is fine")
        
        select()
    }
    
    func select(){
        let sql = "SELECT * FROM Prototype WHERE datess"
        sqlite3_prepare(db,sql,-1,&pointer,nil)
        textView.text = ""
        var id : Int32
        var employee : String
        var product : String
        var place : String
        var datess : String
        var likee : String

        while(sqlite3_step(pointer) == SQLITE_ROW){
            id = sqlite3_column_int(pointer,0)
            textView.text?.append("รหัส : \(id)\n")

            employee = String(cString:sqlite3_column_text(pointer,1))
            textView.text?.append("ชื่อพนักงาน :\(employee)\n")

            product = String(cString:sqlite3_column_text(pointer,2))
            textView.text?.append("ชื่อสินค้า :\(product)\n")

            place = String(cString:sqlite3_column_text(pointer,3))
            textView.text?.append("สถานที่ :\(place)\n")

            datess = String(cString:sqlite3_column_text(pointer,4))
            textView.text?.append("วันที่กรอก :\(datess)\n")

            likee = String(cString:sqlite3_column_text(pointer,5))
            textView.text?.append("ความชอบ :\(likee)\n")

            textView.text?.append("------------------\n")
        }
    }

}


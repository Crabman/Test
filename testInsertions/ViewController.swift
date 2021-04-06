//
//  ViewController.swift
//  testInsertions
//
//  Created by Michael Pirotte 3 on 01/04/2021.
//

import UIKit
import GRDB

class ViewController: UIViewController {
    
    @IBOutlet weak var nbInsertsTextField: UITextField!
    var testDatabase:DatabaseQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("insertionsDB.sqlite")
        //print("$$$DBPATH$$$ = \(fileURL)")
        let databasePathFromApp =  Bundle.main.resourcePath?.appending("/insertionsDB.sqlite")
        print(fileURL)
        do {
            if !FileManager.default.fileExists(atPath:fileURL.relativePath){
                try FileManager.default.copyItem(at:URL.init(fileURLWithPath:databasePathFromApp!), to:fileURL)
            }
        }
        catch let error as NSError {
            print("Copy went wrong: \(error)")
        }
        
        
        do {
            var config = Configuration()
            config.prepareDatabase { db in
//                try db.usePassphrase("test")
//                try db.execute(sql: "PRAGMA cipher_page_size = 16384;")
//                try db.execute(sql: "PRAGMA cipher_memory_security = OFF;")
            }
            let dbQueue = try DatabaseQueue(path: fileURL.path, configuration: config)
            testDatabase = dbQueue
        } catch {
            
        }
    }
    
    func performInsertions(_ nbOfInserts:Int) {
        do{
            //print("Inserts started")
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            try testDatabase!.inTransaction { db in
                
                try db.drop(table: "SimpleTable")
                
                let creationRequest = """
                CREATE TABLE "SimpleTable" (
                    "_id"    INTEGER,
                    "value1"    INTEGER,
                    "value2"    INTEGER,
                    "value3"    INTEGER,
                    "value4"    TEXT,
                    "value5"    INTEGER,
                    "value6"    INTEGER,
                    "value7"    INTEGER
                )
                """
                try db.execute(sql: creationRequest)

                var request = "INSERT INTO SimpleTable ('_id', 'value1','value2','value3','value4','value5','value6','value7') VALUES "
                
                var i=0
                while i < nbOfInserts {
                    
                request.append("('\(i)', '1', '2', '3', 'text', '5', '6', '7'),")
                 i+=1
                }
                if request.last == Character(",") {
                    request.removeLast()//removes last ","
                }
                request.append(";")
                try db.execute(sql: request)
                return .commit
            }
            let end = DispatchTime.now()
                        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests

            print("total time to insert \(nbOfInserts) items : \(timeInterval) seconds")
            
        
            
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func insert100000Tap(_ sender: Any) {
        performInsertions(100000)
    }
    @IBAction func insert1millionTap(_ sender: Any) {
        performInsertions(1000000)
    }
    
    @IBAction func insertButtonTap(_ sender: Any) {
        let nbOfInserts = Int(nbInsertsTextField.text ?? "1")
        performInsertions(nbOfInserts!)
    }
}


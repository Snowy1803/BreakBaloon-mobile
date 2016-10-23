//
//  FileSaveHelper.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import UIKit

class FileSaveHelper {
    fileprivate enum FileErrors:Error {
        case fileNotSaved
        case imageNotConvertedToData
        case fileNotRead
        case fileNotFound
    }
    
    enum FileExtension:String {
        case NONE = ""
        case TXT = ".txt"
        case BBTHEME = ".bbtheme"
        case BBTHEME2CODE = ".bbtc"
        case PNG = ".png"
        case GIF = ".gif"
        case WAV = ".wav"
        case M4A = ".m4a"
        case ZIP = ".zip"
        case JAR = ".jar"
    }
    
    fileprivate let directory:FileManager.SearchPathDirectory
    fileprivate let directoryPath:String
    fileprivate let fileManager = FileManager.default
    fileprivate let fileName:String
    fileprivate let filePath:String
    let fullyQualifiedPath:String
    fileprivate let subDirectory:String
    fileprivate(set) var downloadedSuccessfully = false
    fileprivate(set) var downloadError:NSError?
    
    var fileExists:Bool {
        get {
            return fileManager.fileExists(atPath: fullyQualifiedPath)
        }
    }
    
    var directoryExists:Bool {
        get {
            var isDir = ObjCBool(true)
            return fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        }
    }
    
    init(fileName:String, fileExtension:FileExtension, subDirectory:String?, directory:FileManager.SearchPathDirectory) {
        self.fileName = fileName + fileExtension.rawValue
        self.subDirectory = (subDirectory == nil ? "" : "/\(subDirectory!)")
        self.directory = directory
        self.directoryPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0]
        self.filePath = directoryPath + self.subDirectory
        self.fullyQualifiedPath = "\(filePath)/\(self.fileName)"
        createDirectory()
    }
    
    convenience init(fileName:String, fileExtension:FileExtension, subDirectory:String?) {
        self.init(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory, directory: .documentDirectory)
    }
    
    convenience init(fileName:String, fileExtension:FileExtension) {
        self.init(fileName: fileName, fileExtension: fileExtension, subDirectory: nil)
    }
    
    fileprivate func createDirectory() {
        if !directoryExists {
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("An error occured when creating directory")
            }
        }
    }
    
    func saveFile(string fileContents:String) throws {
        do {
            try fileContents.write(toFile: fullyQualifiedPath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            throw error
        }
    }
    
    func saveFile(image:UIImage) throws {
        guard let data = UIImagePNGRepresentation(image) else {
            throw FileErrors.imageNotConvertedToData
        }
        if !fileManager.createFile(atPath: fullyQualifiedPath, contents: data, attributes: nil) {
            throw FileErrors.fileNotSaved
        }
    }
    
    func saveFile(data:Data) throws {
        if !fileManager.createFile(atPath: fullyQualifiedPath, contents: data, attributes: nil) {
            throw FileErrors.fileNotSaved
        }
        print("Saved file!")
    }
    
    func getContentsOfFile() throws -> String {
        guard fileExists else {
            throw FileErrors.fileNotFound
        }
        
        var returnString:String
        do {
            returnString = try String(contentsOfFile: fullyQualifiedPath, encoding: String.Encoding.utf8)
        } catch {
            throw FileErrors.fileNotRead
        }
        return returnString
    }
    
    func getImage() throws -> UIImage {
        guard fileExists else {
            throw FileErrors.fileNotFound
        }
        
        guard let image = UIImage(contentsOfFile: fullyQualifiedPath) else {
            throw FileErrors.fileNotRead
        }
        
        return image
    }
    
    func getData() throws -> Data {
        guard fileExists else {
            throw FileErrors.fileNotFound
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fullyQualifiedPath)) else {
            throw FileErrors.fileNotRead
        }
        
        return data
    }
    
    func download(_ URL: Foundation.URL) {
        do {
            try fileManager.removeItem(atPath: fullyQualifiedPath)
        } catch {
            print(error)
        }
        createDirectory()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(url: URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("Success: \(statusCode)")
                
                do {
                    try self.saveFile(data: data!)
                } catch {
                    print(error)
                }
                
                self.downloadedSuccessfully = true
            } else {
                // Failure
                print("Failure: %@", error!.localizedDescription);
                self.downloadError = error
            }
        })
        task.resume()
    }
}

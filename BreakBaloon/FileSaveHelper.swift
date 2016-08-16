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
    private enum FileErrors:ErrorType {
        case FileNotSaved
        case ImageNotConvertedToData
        case FileNotRead
        case FileNotFound
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
    
    private let directory:NSSearchPathDirectory
    private let directoryPath:String
    private let fileManager = NSFileManager.defaultManager()
    private let fileName:String
    private let filePath:String
    let fullyQualifiedPath:String
    private let subDirectory:String
    private(set) var downloadedSuccessfully = false
    private(set) var downloadError:NSError?
    
    var fileExists:Bool {
        get {
            return fileManager.fileExistsAtPath(fullyQualifiedPath)
        }
    }
    
    var directoryExists:Bool {
        get {
            var isDir = ObjCBool(true)
            return fileManager.fileExistsAtPath(filePath, isDirectory: &isDir)
        }
    }
    
    init(fileName:String, fileExtension:FileExtension, subDirectory:String?, directory:NSSearchPathDirectory) {
        self.fileName = fileName + fileExtension.rawValue
        self.subDirectory = (subDirectory == nil ? "" : "/\(subDirectory!)")
        self.directory = directory
        self.directoryPath = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true)[0]
        self.filePath = directoryPath + self.subDirectory
        self.fullyQualifiedPath = "\(filePath)/\(self.fileName)"
        createDirectory()
    }
    
    convenience init(fileName:String, fileExtension:FileExtension, subDirectory:String?) {
        self.init(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory, directory: .DocumentDirectory)
    }
    
    convenience init(fileName:String, fileExtension:FileExtension) {
        self.init(fileName: fileName, fileExtension: fileExtension, subDirectory: nil)
    }
    
    private func createDirectory() {
        if !directoryExists {
            do {
                try fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("An error occured when creating directory")
            }
        }
    }
    
    func saveFile(string fileContents:String) throws {
        do {
            try fileContents.writeToFile(fullyQualifiedPath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            throw error
        }
    }
    
    func saveFile(image image:UIImage) throws {
        guard let data = UIImagePNGRepresentation(image) else {
            throw FileErrors.ImageNotConvertedToData
        }
        if !fileManager.createFileAtPath(fullyQualifiedPath, contents: data, attributes: nil) {
            throw FileErrors.FileNotSaved
        }
    }
    
    func saveFile(data data:NSData) throws {
        if !fileManager.createFileAtPath(fullyQualifiedPath, contents: data, attributes: nil) {
            throw FileErrors.FileNotSaved
        }
        print("Saved file!")
    }
    
    func getContentsOfFile() throws -> String {
        guard fileExists else {
            throw FileErrors.FileNotFound
        }
        
        var returnString:String
        do {
            returnString = try String(contentsOfFile: fullyQualifiedPath, encoding: NSUTF8StringEncoding)
        } catch {
            throw FileErrors.FileNotRead
        }
        return returnString
    }
    
    func getImage() throws -> UIImage {
        guard fileExists else {
            throw FileErrors.FileNotFound
        }
        
        guard let image = UIImage(contentsOfFile: fullyQualifiedPath) else {
            throw FileErrors.FileNotRead
        }
        
        return image
    }
    
    func getData() throws -> NSData {
        guard fileExists else {
            throw FileErrors.FileNotFound
        }
        
        guard let data = NSData(contentsOfFile: fullyQualifiedPath) else {
            throw FileErrors.FileNotRead
        }
        
        return data
    }
    
    func download(URL: NSURL) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
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
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
    fileprivate enum FileErrors: Error {
        case fileNotSaved
        case imageNotConvertedToData
        case fileNotRead
        case fileNotFound
    }
    
    enum FileExtension: String {
        case none = ""
        case txt = ".txt"
        case bbtheme = ".bbtheme"
        case bbtc = ".bbtc"
        case png = ".png"
        case gif = ".gif"
        case wav = ".wav"
        case m4a = ".m4a"
        case zip = ".zip"
        case jar = ".jar"
        case json = ".json"
    }
    
    private let directory: FileManager.SearchPathDirectory
    private let directoryPath: String
    private let fileManager = FileManager.default
    private let fileName: String
    private let filePath: String
    let fullyQualifiedPath: String
    private let subDirectory: String
    
    var fileExists: Bool {
        fileManager.fileExists(atPath: fullyQualifiedPath)
    }
    
    var directoryExists: Bool {
        var isDir = ObjCBool(true)
        return fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
    }
    
    init(fileName: String, fileExtension: FileExtension, subDirectory: String?, directory: FileManager.SearchPathDirectory) {
        self.fileName = fileName + fileExtension.rawValue
        self.subDirectory = (subDirectory == nil ? "" : "/\(subDirectory!)")
        self.directory = directory
        directoryPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0]
        filePath = directoryPath + self.subDirectory
        fullyQualifiedPath = "\(filePath)/\(self.fileName)"
        createDirectory()
    }
    
    convenience init(fileName: String, fileExtension: FileExtension, subDirectory: String?) {
        self.init(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory, directory: .documentDirectory)
    }
    
    convenience init(fileName: String, fileExtension: FileExtension) {
        self.init(fileName: fileName, fileExtension: fileExtension, subDirectory: nil)
    }
    
    private func createDirectory() {
        if !directoryExists {
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("An error occured when creating directory")
            }
        }
    }
    
    func saveFile(string fileContents: String) throws {
        do {
            try fileContents.write(toFile: fullyQualifiedPath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            throw error
        }
    }
    
    func saveFile(image: UIImage) throws {
        guard let data = image.pngData() else {
            throw FileErrors.imageNotConvertedToData
        }
        if !fileManager.createFile(atPath: fullyQualifiedPath, contents: data, attributes: nil) {
            throw FileErrors.fileNotSaved
        }
    }
    
    func saveFile(data: Data) throws {
        if !fileManager.createFile(atPath: fullyQualifiedPath, contents: data, attributes: nil) {
            throw FileErrors.fileNotSaved
        }
        print("Saved file!")
    }
    
    func getContentsOfFile() throws -> String {
        guard fileExists else {
            throw FileErrors.fileNotFound
        }
        
        var returnString: String
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
    
    func download(_ URL: Foundation.URL, completion: @escaping (Error?) -> Void) {
        createDirectory()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                // Failure
                print("DL Failure")
                print(error)
                completion(error)
                return
            }
            // Success
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("Success: \(statusCode)")
            
            do {
                try self.saveFile(data: data!)
                completion(nil)
            } catch {
                print(error)
                completion(error)
            }
        }
        task.resume()
    }
}

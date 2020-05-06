//
//  FileWriter.swift
//  ImageRenderer
//
//  Created by Scott Tury on 10/2/19.
//  Copyright © 2019 Scott Tury. All rights reserved.
//

import Foundation

/**
Class for creating writing data out to a specific directory. It tries to allow you to set some default folder you want to write into.
 It then uses that to generate all the URL's/file paths for data you want to save to that folder.
*/
public class FileWriter {
    /// Additional Directory path to append to the directory/domainMask you use in the initializer.
    let additionalDirectory : String
    /// The base path to use for new files.
    private let basicPath : String
    /// The computed path combining the basic path plus the additional directory path, where we will actually write files to disk.
    public let computedPath : String
    /// The directory to ask the FileManager for it's location.
    private let directory: FileManager.SearchPathDirectory
    /// The FileManager domainMask to search.
    private let domainMask: FileManager.SearchPathDomainMask
    
    /**
        This constructor allows you to specify the directory, domainMask and any additional path to write out to.
        - parameter directory: Specifies what type of FileManager directory to look for.
        - parameter domainMask: Specifies the domain to search for the specified directory.
        - parameter additionalOutputDirectory: A String specifying the additional folders you want to create, or use when writing files.
     */
    public init( directory: FileManager.SearchPathDirectory = .documentDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask, additionalOutputDirectory: String?) throws {
        
        self.directory = directory
        self.domainMask = domainMask

        self.basicPath = NSSearchPathForDirectoriesInDomains(self.directory, self.domainMask, true)[0]
        if let additionalOutputDirectory = additionalOutputDirectory {
            self.additionalDirectory = additionalOutputDirectory
        }
        else {
            self.additionalDirectory = ""
        }
        
        // Ok, maybe I should do this in another method, but I want to generate the basic path once,
        // and be able to use it over and over again without running through the same code.
        // Plus we need to initialize all of our variables right here in the init!
        if additionalDirectory.count > 0 {
            computedPath = "\(basicPath)/\(additionalDirectory)"
            
            // Check to see if the directory exists already, and if not, create it!
            let fileManager = FileManager.default
            var isDirectory : ObjCBool = true
            if !fileManager.fileExists(atPath: computedPath, isDirectory: &isDirectory ) {
                do {
                    try fileManager.createDirectory(atPath: computedPath, withIntermediateDirectories: true)
                }
                catch {
                    print( error )
                    throw error
                }
            }
         }
        else {
            self.computedPath = basicPath
        }
    }
    
    /**
        This is a convienience initializer where you write to a specified directory in the document directory in the user domain.
        on macOS this turns out to be ~/Docuents/additionalDirectory.
        - parameter additionalOutputDirectory: A String specifying the additional folders you want to create, or use when writing files.
     */
    public convenience init(_ additionalOutputDirectory: String? = nil) throws {
        do {
            try self.init(directory: .documentDirectory, domainMask: .userDomainMask, additionalOutputDirectory: additionalOutputDirectory)
        }
        catch {
            throw error
        }
    }
    
    // MARK: - Writing

    /**
        This function allows you to write out the dile to the configured directory.
        - parameter fileType: A String specifying the file extension of the file you are writing.
        - parameter name: The String name of the filename you want to save.
        - parameter data: A Data object with the contents we want to write to disk,
     */
    @discardableResult public func export(fileType: String, name: String = "maze", data: Data?) -> URL? {
        var result: URL?
        if let documentURL = URL(string: "\(name).\(fileType)", relativeTo: URL(fileURLWithPath: computedPath)) {
            self.write(documentURL, data: data)
            result = documentURL
        }
        return result
    }

    /**
        This function is just a helper method to write a data blob out to the disk.
        - parameter url: A URL specifying where to write the file.
        - parameter data: A Data object with the contents we want to write to disk,
     */
    public func write( _ url:URL, data: Data? ) {
        if let fileData = data {
            do {
                try fileData.write(to: url)
                print( "Wrote file to \(url)" )
            }
            catch {
                print( "ERROR when writing data out to disk.  \(error)" )
            }
        }
    }

    /**
        This function is just a helper method to write a data blob out to the disk.
        - parameter path: A String specifying where to write the file on the disk.
        - parameter data: A Data object with the contents we want to write to disk,
     */
    public func write( _ path:String, data: Data? ) {
        write(URL(fileURLWithPath: path), data: data)
    }
    
    /**
        Simple method to write the data out asyncronously.
        - parameter url: A URL specifying where to write the file to the disk.
        - parameter data: A Data object with the contents we want to write to disk,
        - parameter completion: A closure for calling back after writing the data to disk.
     */
    public func asyncWrite( _ url: URL, data: Data?, completion: @escaping (()->Void) ) {
        DispatchQueue.global().async { [weak self] in
            if let strongSelf = self {
                strongSelf.write(url, data: data)
                completion()
            }
        }
    }
    
    /**
        Simple method to write the data out asyncronously.
        - parameter path: A String specifying where to write the file to the disk.
        - parameter data: A Data object with the contents we want to write to disk,
        - parameter completion: A closure for calling back after writing the data to disk.
     */
    public func asyncWrite( _ path: String, data: Data?, completion: @escaping (()->Void) ) {
        asyncWrite(URL(fileURLWithPath: path), data: data, completion: completion)
    }
    
}

extension FileWriter {
    /**
        Convienience method for writing an image out, using the ImageRenderEnum as the extension of the filename.
        - parameter type: A ImageRenderEnum specifying what type of data you are writing to disk.
        - parameter name: A String specifying the file name you want to write.  (Dont include the file etension, we will use the `type` parameter for generating that.
        - parameter data: A Data object with the contents we want to write to disk
        - returns: An optional URL object.  If you have one, you should be able to get to that to get the image.
     */
    @discardableResult public func export(type: ImageRenderEnum, name: String = "maze", data: Data?) -> URL? {
                return export(fileType: type.rawValue, name: name, data: data)
    }
}

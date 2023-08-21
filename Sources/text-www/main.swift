import Foundation
import ArgumentParser
import AppKit
import TextEmboss
import Swifter

public enum Errors: Error {
    case notFound
    case invalidImage
    case cgImage
    case processError
    case unsupportedOS
}

@available(macOS 10.15, *)
struct TextExtractServer: ParsableCommand {
    
    func run() throws {
        
        let server = HttpServer();
        
        server.post["/upload"] = { r in
            
            print("UPLOAD")
            
            if let myFileMultipart = r.parseMultiPartFormData().filter({ $0.name == "my_file" }).first {
            // if let myFileMultipart = r.parseMultiPartFormData().first {

                    
                guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    print("SAD 1")
                    return .internalServerError
                }
                
                let data: NSData = myFileMultipart.body.withUnsafeBufferPointer { pointer in
                    return NSData(bytes: pointer.baseAddress, length: myFileMultipart.body.count)
                }
                
                guard let fileSaveUrl = NSURL(string: "test.jpg", relativeTo: documentsUrl) else {
                    print("SAD 2")
                    return .internalServerError
                }
                
                print(fileSaveUrl.absoluteString!)
                print(fileSaveUrl.path!)
                data.write(to: fileSaveUrl as URL, atomically: true)
                
                guard let im = NSImage(byReferencingFile:fileSaveUrl.path!) else {
                    // throw(Errors.invalidImage)
                    print("SAD 3")
                    return .internalServerError
                }
                
                guard let cgImage = im.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    print("SAD 4")
                    // throw(Errors.cgImage)
                    return .internalServerError
                }
                
                let te = TextEmboss()
                let rsp = te.ProcessImage(image: cgImage)
                
                switch rsp {
                case .failure(let error):
                    print("SAD 5 \(error)")
                    // throw(error)
                    return .internalServerError
                case .success(let txt):
                    // print(txt)
                    return .ok(.text(txt))
                }
                
            }
            
            print("SAD 6")
            return .internalServerError
        }

        let semaphore = DispatchSemaphore(value: 0)
        
        do {
            try server.start(9099)
            print("Server has started ( port = \(try server.port()) ). Try to connect now...")
            semaphore.wait()
        } catch {
            semaphore.signal()
            throw(error)
        }
        
    }
}

if #available(macOS 10.15, *) {
    TextExtractServer.main()
} else {
    throw(Errors.unsupportedOS)
}

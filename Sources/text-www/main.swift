import Foundation
import ArgumentParser
import AppKit
import TextEmboss
import Swifter
import Logging

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
        let logger = Logger(label: "org.sfomuseum.text-www")
        
        server.post["/upload"] = { r in
                        
            if let myFileMultipart = r.parseMultiPartFormData().filter({ $0.name == "my_file" }).first {
                
                var ext = ".txt"
                
                switch (myFileMultipart.headers["content-type"]){
                case "image/jpeg":
                        ext = ".jpg"
                case "image/png":
                    ext = ".png"
                default:
                    return .badRequest(.text("Invalid format"))
                }
                
                let uuid = UUID().uuidString
                let fname = uuid + ext
                            
                guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    logger.error("Failed to derive documents directory")
                    return .internalServerError
                }
                
                let data: NSData = myFileMultipart.body.withUnsafeBufferPointer { pointer in
                    return NSData(bytes: pointer.baseAddress, length: myFileMultipart.body.count)
                }
                
                guard let fileSaveUrl = NSURL(string: fname, relativeTo: documentsUrl) else {
                    logger.error("Failed to derive file save URL")
                    return .internalServerError
                }
                
                data.write(to: fileSaveUrl as URL, atomically: true)
                
                defer {
                    do {
                        try FileManager.default.removeItem(at: fileSaveUrl as URL)
                    } catch {
                        logger.error("Failed to remove \(fileSaveUrl.path!), \(error)")
                    }
                }
                                
                guard let im = NSImage(byReferencingFile:fileSaveUrl.path!) else {
                    logger.error("Invalid image")
                    return .badRequest(.text("Invalid image"))
                }
                
                guard let cgImage = im.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    logger.error("Failed to derive CG image")
                    return .internalServerError
                }
                
                let te = TextEmboss()
                let rsp = te.ProcessImage(image: cgImage)
                
                switch rsp {
                case .failure(let error):
                    logger.error("Failed to process image, \(error)")
                    return .internalServerError
                case .success(let txt):
                    return .ok(.text(txt))
                }
                
            }
            
            return .internalServerError
        }

        let semaphore = DispatchSemaphore(value: 0)
        
        do {
            try server.start(9099)
            logger.info("Server has started ( port = 9099). Try to connect now...")
            semaphore.wait()
        } catch {
            semaphore.signal()
            logger.error("Failed to start server, \(error)")
            throw(error)
        }
        
    }
}

if #available(macOS 10.15, *) {
    TextExtractServer.main()
} else {
    throw(Errors.unsupportedOS)
}

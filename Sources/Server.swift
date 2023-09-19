import Logging
import Swifter
import TextEmboss

public class HTTPServer {
    
    public var logger: Logger
    public var threads: Int = 1
    
    var host: String = "localhost"
    var port: Int = 1234
    
    public init(logger: Logger, threads: Int) {
        self.threads = threads
        self.logger = logger
    }
    
    public func Run(host: String, port: Int) throws {
        
        self.host = host
        self.port = port
        
        let server = HttpServer();
        
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.error("Failed to derive documents directory")
            // return .internalServerError
            throw(Errors.fileManager)
        }
        
        server.post["/"] = { r in
            
            guard let myFileMultipart = r.parseMultiPartFormData().filter({ $0.name == "image" }).first else {
                logger.error("Request missing image parameter")
                return .badRequest(.text("Request missing image parameter"))
            }
            
            if myFileMultipart.body.count > max_size {
                logger.error("Request too large")
                return .badRequest(.text("Request too large"))
            }
            
            var ext = ""
            
            guard let content_type = myFileMultipart.headers["content-type"] else {
                logger.error("Missing content type")
                return .badRequest(.text("Missing content type"))
            }
            
            switch (content_type){
            case "image/jpeg":
                ext = ".jpg"
            case "image/png":
                ext = ".png"
            case "image/gif":
                ext = ".gif"
            case "image/tiff":
                ext = ".tiff"
            default:
                logger.error("Unsupported content type \(String(describing: content_type))")
                return .badRequest(.text("Invalid format"))
            }
            
            let uuid = UUID().uuidString
            let fname = uuid + ext
            
            let data: NSData = myFileMultipart.body.withUnsafeBufferPointer { pointer in
                return NSData(bytes: pointer.baseAddress, length: myFileMultipart.body.count)
            }
            
            guard let fileSaveUrl = NSURL(string: fname, relativeTo: documentsUrl) else {
                logger.error("Failed to derive file save URL")
                return .internalServerError
            }
            
            guard data.write(to: fileSaveUrl as URL, atomically: true) else {
                logger.error("Failed to write image data")
                return .internalServerError
            }
            
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
        
        let semaphore = DispatchSemaphore(value: 0)
        
        do {
            try server.start(uint16(port))
            let _port = try server.port()
            
            logger.info("Server has started on port \(_port) and is listening for requests.")
            semaphore.wait()
        } catch {
            semaphore.signal()
            logger.error("Failed to start server, \(error)")
            throw(error)
        }
        
    }
}

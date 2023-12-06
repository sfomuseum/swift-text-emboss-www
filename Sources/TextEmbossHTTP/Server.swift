import Logging
import Swifter
import TextEmboss
import Foundation
import CoreGraphics
import CoreGraphicsImage

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public class HTTPServer {
    
    public var logger: Logger
    public var max_size: Int = 10000000 // bytes
    
    var host: String = "localhost"
    var port: Int = 1234
    
    var documentsUrl: URL?
    
    public init(logger: Logger, max_size: Int) throws {
        self.max_size = max_size
        self.logger = logger
        
        guard let u = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.error("Failed to derive documents directory")
            throw(Errors.fileManager)
        }
        
        documentsUrl = u
    }
    
    public func Run(host: String, port: Int) throws {
        
        self.host = host
        self.port = port
        
        let server = HttpServer();
        
        server.post["/"] = { r in
            return self.run(request: r, format: "text")
        }
       
        server.post["/json"] = { r in
            return self.run(request: r, format: "json")
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        do {
            try server.start(UInt16(self.port))
            let _port = try server.port()
            
            logger.info("Server has started on port \(_port) and is listening for requests.")
            semaphore.wait()
        } catch {
            semaphore.signal()
            logger.error("Failed to start server, \(error)")
            throw(error)
        }
    }
    
    internal func run(request: HttpRequest, format: String) -> HttpResponse {
        
        let r = request
        
        guard let myFileMultipart = r.parseMultiPartFormData().filter({ $0.name == "image" }).first else {
            self.logger.error("Request missing image parameter")
            return .badRequest(.text("Request missing image parameter"))
        }
        
        if myFileMultipart.body.count > self.max_size {
            self.logger.error("Request too large")
            return .badRequest(.text("Request too large"))
        }
        
        var ext = ""
        
        guard let content_type = myFileMultipart.headers["content-type"] else {
            self.logger.error("Missing content type")
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
            self.logger.error("Unsupported content type \(String(describing: content_type))")
            return .badRequest(.text("Invalid format"))
        }
        
        let uuid = UUID().uuidString
        let fname = uuid + ext
        
        let data: NSData = myFileMultipart.body.withUnsafeBufferPointer { pointer in
            return NSData(bytes: pointer.baseAddress, length: myFileMultipart.body.count)
        }
        
        guard let fileSaveUrl = NSURL(string: fname, relativeTo: documentsUrl) else {
            self.logger.error("Failed to derive file save URL")
            return .badRequest(.text("Failed to derive image data"))
        }
        
        guard data.write(to: fileSaveUrl as URL, atomically: true) else {
            self.logger.error("Failed to write image data")
            return .badRequest(.text("Failed to derive image data"))
        }
        
        defer {
            do {
                try FileManager.default.removeItem(at: fileSaveUrl as URL)
            } catch {
                self.logger.error("Failed to remove \(fileSaveUrl.path!), \(error)")
            }
        }
        
        var cg_im: CGImage

        let im_rsp = CoreGraphicsImage.LoadFromURL(url: fileSaveUrl as URL)
        
        switch im_rsp {
        case .failure(let error):
            self.logger.error("Failed to load image, \(error)")
            return .badRequest(.text("Invalid image"))
        case .success(let im):
            cg_im = im
        }
        
        let te = TextEmboss()
        let rsp = te.ProcessImage(image: cg_im)
        
        switch rsp {
        case .failure(let error):
            self.logger.error("Failed to process image, \(error)")
            return .badRequest(.text("Failed to process image"))
        case .success(let rsp):
                            
            switch format {
            case "json":
                
                // It seems kind of crazy that I can't do this:
                // return .ok(.json(rsp))
                // But swifter invokes JSONSerialization.isValidJSONObject
                // https://github.com/httpswift/swifter/blob/1e4f51c92d7ca486242d8bf0722b99de2c3531aa/Xcode/Sources/HttpResponse.swift#L36
                // So the following is necessary. Maybe there's a way to add
                // attributes to the `ProcessImageResult` declaration?
                
                let enc = JSONEncoder()
                var data: Data
                var obj: Any
                
                do {
                    data = try enc.encode(rsp)
                    obj = try JSONSerialization.jsonObject(with: data)
                                                 
                } catch {
                    self.logger.error("Failed to process image, \(error)")
                    return .badRequest(.text("Failed to encode result"))
                }
                
                return .ok(.json(obj))
                
            default:
                return .ok(.text(rsp.text))
            }
        }
    }
}

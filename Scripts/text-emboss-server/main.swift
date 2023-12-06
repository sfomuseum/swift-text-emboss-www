import Foundation
import ArgumentParser
import AppKit
import TextEmboss
import TextEmbossHTTP
import Logging



@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
struct TextEmbossServer: ParsableCommand {
    
    @Option(help: "The host name to listen for new connections")
    var host = "localhost"
    
    @Option(help:"The port number to start the server on.")
    var port: Int = 8080
    
    @Option(help:"The maximum allowed size in bytes for uploads.")
    var max_size: Int = 10000000 // bytes
    
    func run() throws {
        
        let logger = Logger(label: "org.sfomuseum.text-emboss-server")

        let s = try TextEmbossHTTP.HTTPServer(logger: logger, max_size: max_size)
        try s.Run(host: host, port:port)            
    }
}

if #available(macOS 10.15, *) {
    TextEmbossServer.main()
} else {
    throw(Errors.unsupportedOS)
}

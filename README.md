# swift-text-emboss-www

A simple HTTP server wrapping the `sfomuseum/swift-text-emboss` package.

## Important

This package has only minimal error reporting and validation. It has no authentication or authorization hooks.

## Example

Building the server.

```
$> swift build
Building for debugging...
[1/1] Compiling plugin GenerateManual
Build complete! (0.11s)
```

Server start-up options.

```
$> ./.build/debug/text-emboss-server -h
USAGE: text-emboss-server [--port <port>] [--max_size <max_size>]

OPTIONS:
  --port <port>           The port number to start the server on. (default: 8080)
  --max_size <max_size>   The maximum allowed size in bytes for uploads. (default: 10000000)
  -h, --help              Show help information.
```

Running the server.

```
$> ./.build/debug/text-emboss-server
2023-08-31T11:36:32-0700 info org.sfomuseum.text-emboss-server : [text_emboss_server] Server has started on port 8080 and is listening for requests.
```

And then (given [this image](https://collection.sfomuseum.org/objects/1779445165/)):

```
$> curl -F image=@1779445839_SfgRA4d51gAzgbClRnghkRVINAw2rOjF_b.jpg http://localhost:8080/
THE SAN FRANCISCO AIRPORTS COMMISSION PRESENTS
TOYS THAT TRAVEL
DECEMBER 14 -
- FEBRUARY 28, 1982
FROM THE COLLECTION OF THE OAKLAND MUSEUM AND PRIVATE COLLECTIONS
SAN FRANCO INTERNATIONAL AIRPORT • NORTH TERMINAL STIR
```

## See also

* https://github.com/sfomuseum/swift-text-emboss
* https://github.com/sfomuseum/swift-text-emboss-cli
* https://github.com/httpswift/swifter
# text-www

A simple HTTP server wrapping the `sfomuseum/swift-text-emboss` package.

## Important

This is experimental work in progress.

It has only minimal error reporting and validation. It has no authentication or authorization hooks.

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
$> ./.build/debug/text-www -h
USAGE: text-extract-server [--port <port>] [--max_size <max_size>]

OPTIONS:
  --port <port>           The port number to start the server on. (default: 8080)
  --max_size <max_size>   The maximum allowed size in bytes for uploads. (default: 10000000)
  -h, --help              Show help information.
```

Running the server.

```
$> ./.build/debug/text-www -h
2023-08-21T17:01:45-0700 info org.sfomuseum.text-www : [text_www] Server has started on port 8080 and is listening for requests.
```

And then (given [this image](https://collection.sfomuseum.org/objects/1779445165/)):

```
$> curl -F image=@1779445839_SfgRA4d51gAzgbClRnghkRVINAw2rOjF_b.jpg http://localhost:8080/upload
THE SAN FRANCISCO AIRPORTS COMMISSION PRESENTS
TOYS THAT TRAVEL
DECEMBER 14 -
- FEBRUARY 28, 1982
FROM THE COLLECTION OF THE OAKLAND MUSEUM AND PRIVATE COLLECTIONS
SAN FRANCO INTERNATIONAL AIRPORT • NORTH TERMINAL STIR
```

## See also

* https://github.com/httpswift/swifter
* https://github.com/sfomuseum/swift-text-emboss
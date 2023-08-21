# text-www

A simple HTTP server wrapping the `sfomuseum/swift-text-emboss` package.

## Important

This is experimental work in progress. It is absolutely not ready for production use.

It has only minimal error reporting and validation. It has no authentication or authorization hooks.

## Example

```
$> swift build && ./.build/debug/text-www
Building for debugging...
[1/1] Compiling plugin GenerateManual
Build complete! (0.12s)
Server has started ( port = 9099 ). Try to connect now...
```

And then (given [this image](https://collection.sfomuseum.org/objects/1779445165/)):

```
$> curl -F my_file=@1779445839_SfgRA4d51gAzgbClRnghkRVINAw2rOjF_b.jpg http://localhost:9099/upload
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
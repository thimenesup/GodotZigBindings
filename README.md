# Zig lang bindings for Godot GDNative

For Zig Version 0.11.0 and Godot 3.2.0+

## Building

To retrieve the headers and generate the bindings

```
zig build -DgetHeaders=true
```

If no arguments are specified, then it'll only generate the bindings without retrieving the headers

```
zig build
```

You may also get the headers without generating the bindings

```
zig build -DgetHeaders=true -Dgenerate=false
```

You can also use the following option to generate the bindings using your custom json api file

```
zig build -Dcustom_api_file="mydir/my_json.api"
```

## Example usage

The "test_example" folder contains an explained minimal example of how to use this as a package, with the build script, library entry point and a sample class included that can be built with

```
zig build
```

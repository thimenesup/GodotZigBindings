# Zig lang bindings for Godot GDNative

For Zig Version 0.11.0 and Godot 3.2.0+

## Building

To retreive the headers

```
zig build
```

You must generate the class files too with this option

```
zig build -Dgenerate_bindings=true
```

You can also use the following option to generate the bindings using your custom json api file

```
zig build -Dgenerate_bindings=true -Dcustom_api_file="mydir/my_json.api"
```

## Example usage

The "test_example" folder contains an explained minimal example of how to use this as a package, with the build script, library entry point and a sample class included that can be built with

```
zig build
```

## Warning

Due to a Zig bug with C ABI compatibility (apparently only on x86_64-windows) https://github.com/ziglang/zig/issues/1481 structs returned from functions with sizeof <= 16 will not be correct and cause undefined behaviour, crashes etc... so if your code is crashing this is likely why

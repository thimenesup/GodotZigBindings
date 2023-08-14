# Zig lang bindings for Godot GDNative

For Zig Version 0.11.0 and Godot 3.2.0+

## Package Usage

Before you use this as a package, you must generate the GDNative and class files for Zig, this is done by bulding with the following options

```
zig build -Dgdnative="mydir/gdnative_api.json" -Dclasses="mydir/api.json"
```

These options correspond to the files that are found in Godot's GDNative, [**which you can get here**](https://github.com/godotengine/godot-headers)

## Example usage

The "test_example" folder contains an explained minimal example of how to use this as a package, with the build script, library entry point and a sample class included that can be built with

```
zig build
```

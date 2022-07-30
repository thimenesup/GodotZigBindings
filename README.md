# Zig lang bindings for Godot GDNative

## Building

Add the "GDNATIVE_HEADERS" environment variable pointing to your header path

For the first time, you must generate the class files too with this option

```
zig build -Dgenerate_bindings=true
```

You can also use the following option to generate the bindings using your custom json api file

```
zig build -Dgenerate_bindings=true -Dcustom_api_file="mydir/my_json.api"
```

After they are generated you can use the regular

```
zig build
```

## Warning

Due to a Zig bug with C ABI compatibility (apparently only on x86_64-windows) https://github.com/ziglang/zig/issues/1481 structs returned from functions with sizeof <= 16 will not be correct and cause undefined behaviour, crashes etc... so if your code is crashing this is likely why
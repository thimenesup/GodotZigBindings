# Zig lang bindings for Godot GDNative

## Building

Add the "GDNATIVE_HEADERS" environment variable pointing to your header path

```
zig build
```

## Progress

Interfacing with godot done

Core variant and array bindings done

TODO:

Core math

## Warning

Due to a Zig bug with C ABI compatibility https://github.com/ziglang/zig/issues/1481 structs returned from functions with sizeof <= 16 will not be correct and cause undefined behaviour, crashes etc... so if your code is crashing this is likely why
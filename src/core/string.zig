const gd = @import("api.zig");
const c = gd.c;

const Variant = @import("variant.zig").Variant;
const Array = @import("array.zig").Array;
const PoolArrays = @import("pool_arrays.zig");
const PoolByteArray = PoolArrays.PoolByteArray;

pub const String = struct {

    godot_string: c.godot_string,

    const Self = @This();

    pub fn deinit(self: *Self) void {
        gd.api.*.godot_string_destroy.?(&self.godot_string);
    }

    pub fn init() Self {
        var self = Self {
            .godot_string = undefined,
        };

        gd.api.*.godot_string_new.?(&self.godot_string);

        return self;
    }

    pub fn initGodotString(p_godot_string: c.godot_string) Self {
        const string = String {
            .godot_string = p_godot_string,
        };

        return string;
    }

    pub fn initUtf8(chars: []const u8) Self {
        var self = Self {
            .godot_string = undefined,
        };

        gd.api.*.godot_string_new.?(&self.godot_string);
        _ = gd.api.*.godot_string_parse_utf8.?(&self.godot_string, @ptrCast([*c]const u8, chars));

        return self;
    }

    pub fn initCopy(other: *const String) Self {
        var self = Self {
            .godot_string = undefined,
        };

        gd.api.*.godot_string_new_copy.?(&self.godot_string, other.godot_string);

        return self;
    }

    pub fn length(self: *const Self) i32 {
        return gd.api.*.godot_string_length.?(&self.godot_string);
    }

    pub fn equal(self: *const Self, other: *const String) bool { // Operator ==
        return gd.api.*.godot_string_operator_equal.?(&self.godot_string, &other.godot_string);
    }

    pub fn notEqual(self: *const Self, other: *const String) bool { // Operator !=
        return !equal(self, other);
    }

    pub fn less(self: *const Self, other: *const String) bool { // Operator <
        return gd.api.*.godot_string_operator_less.?(&self.godot_string, &other.godot_string);
    }

    pub fn lessEqual(self: *const Self, other: *const String) bool { // Operator <=
        return less(self, other) || equal(self, other);
    }

    pub fn more(self: *const Self, other: *const String) bool { // Operator >
        return !lessEqual(self, other);
    }

    pub fn moreEqual(self: *const Self, other: *const String) bool { // Operator >=
        return !less(self, other);
    }

    pub fn plus(self: *const Self, other: *const String) String { // Operator + // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_operator_plus.?(&self.godot_string, &other.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn beginsWith(self: *const Self, p_string: *const String) bool {
        return gd.api.*.godot_string_begins_with.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn beginsWithCharArray(self: *const Self, p_char_array: [*]const u8) bool {
        return gd.api.*.godot_string_begins_with_char_array.?(&self.godot_string, p_char_array);
    }

    pub fn bigrams(self: *const Self, p_string: *const String) Array { // Make sure you call .deinit() on returned struct
        const godot_array = gd.api.*.godot_string_bigrams.?(&self.godot_string, &p_string.godot_string);
        return Array.initGodotArray(godot_array);
    }

    pub fn cEscape(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_c_escape.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn cUnescape(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_c_unescape.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn capitalize(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_capitalize.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn empty(self: *const Self) bool {
        return gd.api.*.godot_string_empty.?(&self.godot_string);
    }

    pub fn endsWith(self: *const Self, p_string: *const String) bool {
        return gd.api.*.godot_string_ends_with.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn erase(self: *Self, position: i32, chars: i32) void {
        gd.api.*.godot_string_erase.?(&self.godot_string, position, chars);
    }

    pub fn find(self: *const Self, p_string: *const String, from: i32) i32 {
        return gd.api.*.godot_string_find.?(&self.godot_string, p_string.godot_string, from);
    }

    pub fn findLast(self: *const Self, p_string: *const String) i32 {
        return gd.api.*.godot_string_find_last.?(&self.godot_string, p_string.godot_string);
    }

    pub fn findn(self: *const Self, p_string: *const String, from: i32) i32 {
        return gd.api.*.godot_string_findn_from.?(&self.godot_string, p_string.godot_string, from);
    }

    pub fn format(self: *const Self, values: *const Variant) String { // Make sure you call .deinit() on returned struct
        return gd.api.*.godot_string_begins_with.?(&self.godot_string, &values.godot_variant);
    }

    pub fn formatPlaceholder(self: *const Self, values: *const Variant, placeholder: *const String) String { // Make sure you call .deinit() on returned struct
        const char_contents = gd.api.*.godot_string_utf8.?(&placeholder.godot_string);
        const data = gd.api.*.godot_char_string_get_data.?(&char_contents);
        const godot_string =  gd.api.*.godot_string_format_with_custom_placeholder.?(&self.godot_string, &values.godot_variant, &placeholder.godot_string, data);
        gd.api.*.godot_char_string_destroy.?(&char_contents);
        return String.initGodotString(godot_string);
    }

    pub fn getBaseDir(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_get_base_dir.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn getBasename(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_get_basename.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn getExtension(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_get_extension.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn getFile(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_get_file.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn hash(self: *const Self) i32 {
        return gd.api.*.godot_string_hash.?(&self.godot_string);
    }

    pub fn hexToInt(self: *const Self) i32 {
        return gd.api.*.godot_string_hex_to_int.?(&self.godot_string);
    }

    pub fn insert(self: *const Self, position: i32, p_string: *const String) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_insert.?(&self.godot_string, position, p_string.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn isAbsPath(self: *const Self) bool {
        return gd.api.*.godot_string_is_abs_path.?(&self.godot_string);
    }

    pub fn isRelPath(self: *const Self) bool {
        return gd.api.*.godot_string_is_rel_path.?(&self.godot_string);
    }

    pub fn isSubsequenceOf(self: *const Self, p_string: *const String) bool {
        return gd.api.*.godot_string_is_subsequence_of.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn isSubsequenceOfi(self: *const Self, p_string: *const String) bool {
        return gd.api.*.godot_string_is_subsequence_ofi.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn isValidFloat(self: *const Self) bool {
        return gd.api.*.godot_string_is_valid_float.?(&self.godot_string);
    }

    pub fn isValidHtmlColor(self: *const Self) bool {
        return gd.api.*.godot_string_is_valid_html_color.?(&self.godot_string);
    }

    pub fn isValidIdentifier(self: *const Self) bool {
        return gd.api.*.godot_string_is_valid_identifier.?(&self.godot_string);
    }

    pub fn isValidInteger(self: *const Self) bool {
        return gd.api.*.godot_string_is_numeric.?(&self.godot_string);
    }

    pub fn isValidIpAddress(self: *const Self) bool {
        return gd.api.*.godot_string_is_valid_ip_address.?(&self.godot_string);
    }

    pub fn jsonEscape(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_json_escape.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn left(self: *const Self, position: i32) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_left.?(&self.godot_string, position);
        return String.initGodotString(godot_string);
    }

    pub fn match(self: *const Self, p_string: *const String) bool {
        return gd.api.*.godot_string_match.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn matchn(self: *const Self, p_string: *const String) bool {
        return gd.api.*.godot_string_matchn.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn md5Buffer(self: *const Self) PoolByteArray { // Make sure you call .deinit() on returned struct
        const godot_array = gd.api.*.godot_string_md5_buffer.?(&self.godot_string);
        return PoolByteArray.initGodotPoolByteArray(godot_array);
    }

    pub fn md5Text(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_md5_text.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn ordAt(self: *const Self, at: i32) i32 {
        return gd.api.*.godot_string_ord_at.?(&self.godot_string, at);
    }

    pub fn padDecimals(self: *const Self, digits: i32) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_pad_decimals.?(&self.godot_string, digits);
        return String.initGodotString(godot_string);
    }

    pub fn padZeros(self: *const Self, digits: i32) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_pad_zeros.?(&self.godot_string, digits);
        return String.initGodotString(godot_string);
    }

    pub fn percentDecode(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_percent_decode.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn percentEncode(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_percent_encode.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn plusFile(self: *const Self, p_string: *const String) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_plus_file.?(&self.godot_string, &p_string.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn replace(self: *const Self, key: *const String, with: *const String) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_replace.?(&self.godot_string, key.godot_string, with.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn replacen(self: *const Self, what: *const String, for_what: *const String) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_replacen.?(&self.godot_string, what.godot_string, for_what.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn rfind(self: *const Self, what: *const String, from: i32) i32 {
        return gd.api.*.godot_string_rfind_from.?(&self.godot_string, what.godot_string, from);
    }

    pub fn rfindn(self: *const Self, what: *const String, from: i32) i32 {
        return gd.api.*.godot_string_rfindn_from.?(&self.godot_string, what.godot_string, from);
    }

    pub fn right(self: *const Self, position: i32) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_right.?(&self.godot_string, position);
        return String.initGodotString(godot_string);
    }

    pub fn sha256Buffer(self: *const Self) PoolByteArray { // Make sure you call .deinit() on returned struct
        const godot_array = gd.api.*.godot_string_sha256_buffer.?(&self.godot_string);
        return PoolByteArray.initGodotPoolByteArray(godot_array);
    }

    pub fn sha256Text(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_sha256_text.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn similarity(self: *const Self, p_string: *const String) f32 {
        return gd.api.*.godot_string_similarity.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn split(self: *const Self, p_string: *const String, allow_empty: bool) Array { // Make sure you call .deinit() on returned struct
        _ = allow_empty;
        const godot_array = gd.api.*.godot_string_split.?(&self.godot_string, &p_string.godot_string);
        return Array.initGodotArray(godot_array);
    }

    pub fn splitInts(self: *const Self, p_string: *const String, allow_empty: bool) Array { // Make sure you call .deinit() on returned struct
        _ = allow_empty;
        const godot_array = gd.api.*.godot_string_split_floats.?(&self.godot_string, &p_string.godot_string);
        return Array.initGodotArray(godot_array);
    }

    pub fn splitFloats(self: *const Self, p_string: *const String, allow_empty: bool) Array { // Make sure you call .deinit() on returned struct
        _ = allow_empty;
        const godot_array = gd.api.*.godot_string_split_floats.?(&self.godot_string, &p_string.godot_string);
        return Array.initGodotArray(godot_array);
    }

    pub fn stripEdges(self: *const Self, p_left: bool, p_right: bool) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_strip_edges.?(&self.godot_string, p_left, p_right);
        return String.initGodotString(godot_string);
    }

    pub fn substr(self: *const Self, from: i32, len: i32) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_substr.?(&self.godot_string, from, len);
        return String.initGodotString(godot_string);
    }

    pub fn toFloat(self: *const Self) f32 {
        return gd.api.*.godot_string_to_float.?(&self.godot_string);
    }

    pub fn toInt(self: *const Self) i32 {
        return gd.api.*.godot_string_to_int.?(&self.godot_string);
    }

    pub fn toLower(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_to_lower.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn toUpper(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_to_upper.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn xmlEscape(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_xml_escape.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn xmlUnescape(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_string_xml_unescape.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn casecmpTo(self: *const Self, p_string: *const String) i8 {
        return gd.api.*.godot_string_casecmp_to.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn nocasecmpTo(self: *const Self, p_string: *const String) i8 {
        return gd.api.*.godot_string_nocasecmp_to.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn naturalnocasecmpTo(self: *const Self, p_string: *const String) i8 {
        return gd.api.*.godot_string_naturalnocasecmp_to.?(&self.godot_string, &p_string.godot_string);
    }

    pub fn dedent(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api_1_1.*.godot_string_dedent.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn rsplit(self: *const Self, p_string: *const String, allow_empty: bool, max_split: i32) Array { // Make sure you call .deinit() on returned struct
        const godot_array = gd.api_1_1.*.godot_string_rsplit.?(&self.godot_string, &p_string.godot_string, allow_empty, max_split);
        return Array.initGodotArray(godot_array);
    }

    pub fn rstrip(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api_1_1.*.godot_string_rstrip.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn trimPrefix(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api_1_1.*.godot_string_trim_prefix.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

    pub fn trimSuffix(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api_1_1.*.godot_string_trim_suffix.?(&self.godot_string);
        return String.initGodotString(godot_string);
    }

};

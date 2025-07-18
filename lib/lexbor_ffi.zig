// zig/lexbor_ffi.zig
const std = @import("std");

// --- Primitive Types and Aliases ---
pub const lxb_status_t = u8;
pub const lxb_char_t = u8;
pub const lxb_tag_id_t = u16;
pub const lxb_ns_id_t = u8;

// --- Constants ---
pub const LXB_STATUS_OK: lxb_status_t = 0x00;
pub const LXB_TAG_BODY_ID_VALUE: lxb_tag_id_t = 10;

// --- Opaque Lexbor Structs and their explicit definitions for casting ---
pub const lxb_dom_node_t = extern struct {}; // Opaque for its own fields

pub const lxb_dom_element_t = extern struct {
    node: lxb_dom_node_t, // CRITICAL: This must be the very first field for casting
    // No other fields needed here unless you access them directly in Zig
};

pub const lxb_html_document_t = extern struct {};
pub const lxb_dom_document_t = extern struct {};
pub const lxb_dom_attr_t = extern struct {};
pub const lxb_dom_text_t = extern struct {};
pub const lxb_dom_comment_t = extern struct {};
pub const lxb_dom_character_data_t = extern struct {};
pub const lexbor_str_t = extern struct {};

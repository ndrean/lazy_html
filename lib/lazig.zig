const std = @import("std");
const beam = @import("beam");
const root = @import("root");
const e = @import("erl_nif");

// Import Lexbor PRIMITIVE TYPES and CONSTANTS, AND EXPLICITLY DEFINED STRUCTS from your custom FFI file
const lxb_types = @import("lexbor_ffi.zig"); // Correct path from lib/ to zig/

// Import your C wrapper functions and their associated OPAQUE STRUCT TYPES
const c_wrappers = @cImport({
    @cInclude("../c_headers/lexbor_bridge.h");
    @cInclude("../c_headers/cimport_stubs.h");
});

const NodeList = std.ArrayList(?*c_wrappers.lxb_dom_node);

const DocumentRef = struct {
    document: ?*c_wrappers.lxb_html_document,
    nodes: NodeList,
    from_selector: bool,

    pub fn init(allocator: std.mem.Allocator) DocumentRef {
        return .{
            .document = null,
            .nodes = std.ArrayList(?*c_wrappers.lxb_dom_node).init(allocator),
            .from_selector = false,
        };
    }
};

const DocClean = struct {
    pub fn dtor(doc_ref_ptr: *DocumentRef) void {
        @breakpoint();
        if (doc_ref_ptr.document) |doc| {
            c_wrappers.lxb_html_document_destroy_wrapper(doc);
        }
        doc_ref_ptr.nodes.deinit();
    }
};

pub const LazigHTML_Resource = beam.Resource(
    DocumentRef,
    root,
    .{
        .Callbacks = DocClean,
    },
);

pub fn from_fragment(html: []const u8) !beam.term {
    const document: ?*c_wrappers.lxb_html_document = c_wrappers.lxb_html_document_create_wrapper();
    if (document == null) {
        return beam.make_error_pair(error.LexborDocumentCreationFailed, .{});
    }

    const dom_document: ?*c_wrappers.lxb_dom_document = c_wrappers.lxb_dom_interface_document_wrapper(document);
    if (dom_document == null) {
        c_wrappers.lxb_html_document_destroy_wrapper(document);
        return beam.make_error_pair(error.LexborDocumentCreationFailed, .{});
    }

    var body_name_len: usize = 0;
    const body_name_ptr: ?*const u8 = c_wrappers.lxb_tag_name_by_id_wrapper(
        lxb_types.LXB_TAG_BODY_ID_VALUE,
        &body_name_len,
    );
    if (body_name_ptr == null) {
        c_wrappers.lxb_html_document_destroy_wrapper(document);
        return beam.make_error_pair(error.LexborElementCreationFailed, .{});
    }

    // FIX START: Declare body_element with its actual return type from the C wrapper
    const body_element: ?*c_wrappers.lxb_dom_element =
        c_wrappers.lxb_dom_document_create_element_wrapper(
            dom_document,
            body_name_ptr,
            body_name_len,
        );

    if (body_element == null) {
        c_wrappers.lxb_html_document_destroy_wrapper(document);
        return beam.make_error_pair(error.LexborElementCreationFailed, .{});
    }

    // lxb_html_document_parse_fragment_wrapper expects `struct lxb_dom_element *` for its element parameter.
    // `body_element` is now correctly `?*c_wrappers.lxb_dom_element`, so no cast is needed here.
    const first_parsed_node: ?*c_wrappers.lxb_dom_node = c_wrappers.lxb_html_document_parse_fragment_wrapper(
        document,
        body_element, // Pass the element pointer directly
        html.ptr,
        html.len,
    );

    std.debug.print("First parsed node: {any}\n", .{first_parsed_node}); // Debugging line

    // If html.len > 0 but no node was returned, consider it a parsing failure.
    if (first_parsed_node == null and html.len > 0) {
        c_wrappers.lxb_html_document_destroy_wrapper(document); // Clean up
        return beam.make_error_pair(error.LexborParsingFailed, .{});
    }

    var doc_ref_data = DocumentRef.init(beam.allocator);
    doc_ref_data.document = document;

    // When calling lxb_dom_node_first_child_wrapper, it expects `struct lxb_dom_node *`.
    // `body_element` is `?*c_wrappers.lxb_dom_element`.
    // To cast from `?*c_wrappers.lxb_dom_element` to `?*c_wrappers.lxb_dom_node`,
    // we need to leverage the explicit struct definition in `lxb_types`.
    // Cast the opaque C element pointer to the explicitly defined Zig element struct pointer,
    // then access its `node` field, and finally cast that address back to the opaque C node pointer
    // that the wrapper expects.
    var current_node: ?*c_wrappers.lxb_dom_node = null;
    if (first_parsed_node != null) {
        current_node = c_wrappers.lxb_dom_node_first_child_wrapper(first_parsed_node.?);
    }
    // FIX END

    while (current_node != null) {
        std.debug.print("Node type: {any}\n", .{current_node}); // Debugging line
        try doc_ref_data.nodes.append(current_node);
        current_node = c_wrappers.lxb_dom_node_next_wrapper(current_node);
    }

    // std.debug.print("{}", .{doc_ref_data.nodes.len});
    const resource_term = try LazigHTML_Resource.create(doc_ref_data, .{});

    return beam.make(.{ .ok, resource_term }, .{});
}

pub fn to_array(one: beam.term, two: beam.term) ![]i8 {
    var arr: [2]i8 = undefined;
    const maybe_one: i8 = try beam.get(i8, one, .{});
    const maybe_two: i8 = try beam.get(i8, two, .{});
    arr[0] = maybe_one;
    arr[1] = maybe_two;
    std.debug.print("{any}\n", .{arr});
    return &arr;
}
// pub fn get_nodes(resource: beam.term) ![]beam.term {
//     // const env = beam.get_env(); // Get env for making list/binaries
//     const doc_ref_ptr = try beam.get(LazigHTML_Resource, resource, .{});

//     // var nodes_list = std.ArrayList(e.ErlNifTerm).init(beam.allocator);
//     // defer nodes_list.deinit();

//     // for (doc_ref_ptr.nodes.items) |node_ptr| {
//     //     const node_binary = try e.make_binary(env, @as(*const u8, node_ptr), @sizeOf(?*c_wrappers.lxb_dom_node));
//     //     try nodes_list.append(node_binary);
//     // }

//     // return e.make_list(env, nodes_list.items);
//     // const nodes = beam.make_list(doc_ref_ptr.unpack().nodes.items, .{});
//     return doc_ref_ptr.unpack().nodes;
// }

// {:ok, r} = LazigHTML.Zigler.from_fragment(~S|<span>Hello</span><span>world</span><div>ok</div>|)
pub fn num_nodes(resource: beam.term) !usize {
    const doc_ref_ptr = try beam.get(LazigHTML_Resource, resource, .{});
    return doc_ref_ptr.unpack().nodes.items.len;
}

// Parse HTML document
// pub fn from_document_zig(html: []const u8) !beam.term {
//     const maybe_document: ?*c.lxb_html_document_t = c.lxb_html_document_create_wrapper();
//     if (maybe_document) |document| {
//         const status = c.lxb_html_document_parse_wrapper(document, html.ptr, html.len);
//         if (status != c.LXB_STATUS_OK) {
//             c.lxb_html_document_destroy_wrapper(document);
//             return beam.make_error_pair(error.ParseError, .{});
//         }

//         var docRef = DocumentRef.init(beam.allocator);

//         // Collect top-level nodes
//         var opt_node = c.lxb_dom_node_first_child_wrapper(c.lxb_dom_interface_node_wrapper(document));
//         while (opt_node) |node| {
//             try (docRef.nodes.append(node));
//             opt_node = c.lxb_dom_node_next_wrapper(node);
//         }

//         const resource = try LazigHTML.create(.{
//             .document = document,
//             .nodes = nodes,
//             .from_selector = false,
//         }, .{});
//         std.debug.print("{any}", .{resource.unpack()});
//         return beam.make(.{ .ok, resource }, .{});
//     } else {
//         return beam.make_error_pair(error.AllocationError, .{});
//     }
// }

// // Convert to HTML string - simplified implementation
// pub fn to_html_zig(resource_term: beam.term, skip_whitespace: bool) ![]const u8 {
//     const resource = try beam.get(LazigHTML_Resource, resource_term, .{});
//     const lazy_html = resource.unpack();
//     _ = skip_whitespace; // unused for now

//     if (lazy_html.document) |document| {
//         const doc_node = c.lxb_dom_interface_node_wrapper(document);
//         if (doc_node == null) {
//             // return beam.make_error_pair(error.ConversionError, .{});
//             return error.ConversionError;
//         }

//         var size: usize = 0;
//         const html_ptr = c.lxb_html_serialize_wrapper(doc_node, &size);
//         if (html_ptr == null) {
//             return error.SerializationError;
//         }
//         defer c.lxb_html_serialize_cleanup_wrapper(html_ptr);

//         const html_slice = @as([*]const u8, @ptrCast(html_ptr))[0..size];
//         return beam.allocator.dupe(u8, html_slice);
//     } else {
//         return error.InvalidResource;
//     }
// }

// // // Get text content - simplified implementation
// pub fn text_zig(resource_term: beam.term) ![]const u8 {
//     const resource = try beam.get(LazigHTML, resource_term, .{});
//     const lazig_html = resource.unpack();

//     if (lazig_html.document) |document| {
//         const doc_node = c.lxb_dom_interface_node_wrapper(document);
//         if (doc_node == null) {
//             return "";
//         }

//         var len: usize = 0;
//         const text_ptr = c.lxb_dom_node_text_content_wrapper(doc_node, &len);
//         if (text_ptr == null) {
//             return "";
//         }
//         defer c.lxb_dom_document_destroy_text_wrapper(c.lxb_dom_interface_document_wrapper(document), text_ptr);

//         const text_slice = @as([*]const u8, @ptrCast(text_ptr))[0..len];
//         return beam.allocator.dupe(u8, text_slice);
//     } else {
//         return "";
//     }
// }

// // // Get single attribute - simplified to return nil for now

// pub fn attribute_zig(resource_term: beam.term, name: []const u8) !?[]const u8 {
//     const resource = try beam.get(LazigHTML, resource_term, .{});
//     const lazig_html = resource.unpack();

//     if (lazig_html.document == null) {
//         return null;
//     }

//     // Get first node (root)
//     if (lazig_html.nodes.items.len == 0) {
//         return null;
//     }
//     const node = lazig_html.nodes.items[0];
//     const element = c.lxb_dom_interface_element_wrapper(node);
//     if (element == null) {
//         return null;
//     }

//     var value_len: usize = 0;
//     const value_ptr = c.lxb_dom_element_get_attribute_wrapper(element, name.ptr, name.len, &value_len);
//     if (value_ptr == null) {
//         return null;
//     }
//     const value_slice = @as([*]const u8, @ptrCast(value_ptr))[0..value_len];
//     return beam.allocator.dupe(u8, value_slice);
// }

// // Get all attributes - simplified to return empty map for now

// pub fn attributes_zig(resource_term: beam.term) ![]struct { name: []const u8, value: []const u8 } {
//     const resource = try beam.get(LazigHTML, resource_term, .{});
//     const lazig_html = resource.unpack();

//     if (lazig_html.document == null or lazig_html.nodes.items.len == 0) {
//         return &[_]struct { name: []const u8, value: []const u8 }{};
//     }
//     const node = lazig_html.nodes.items[0];
//     const element = c.lxb_dom_interface_element_wrapper(node);
//     if (element == null) {
//         return &[_]struct { name: []const u8, value: []const u8 }{};
//     }

//     var attrs = std.ArrayList(struct { name: []const u8, value: []const u8 }).init(beam.allocator);
//     var attr = c.lxb_dom_element_first_attribute_wrapper(element);
//     while (attr != null) : (attr = c.lxb_dom_element_next_attribute_wrapper(attr)) {
//         var name_len: usize = 0;
//         var value_len: usize = 0;
//         const name_ptr = c.lxb_dom_attr_qualified_name_wrapper(attr, &name_len);
//         const value_ptr = c.lxb_dom_attr_value_wrapper(attr, &value_len);
//         const name_slice = @as([*]const u8, @ptrCast(name_ptr))[0..name_len];
//         const value_slice = @as([*]const u8, @ptrCast(value_ptr))[0..value_len];
//         try attrs.append(.{ .name = beam.allocator.dupe(u8, name_slice), .value = beam.allocator.dupe(u8, value_slice) });
//     }
//     return attrs.toOwnedSlice();
// }

// pub fn to_tree_zig(resource_term: beam.term, sort_attributes: bool, skip_whitespace: bool) !beam.term {
//     const resource = try beam.get(LazigHTML, resource_term, .{});
//     const lazig_html = resource.unpack();

//     if (lazig_html.document == null) {
//         return beam.make_error_pair(error.InvalidResource, .{});
//     }

//     var tree = std.ArrayList(beam.term).init(beam.allocator);
//     for (lazig_html.nodes.items) |node| {
//         try tree.append(try node_to_tree(node, sort_attributes, skip_whitespace));
//     }
//     return beam.make_list(tree.toOwnedSlice());
// }

// fn node_to_tree(node: *c.lxb_dom_node_t, sort_attributes: bool, skip_whitespace: bool) !beam.term
// {
//   if (node.type == c.LXB_DOM_NODE_TYPE_ELEMENT)
//   {
//     const element = c.lxb_dom_interface_element_wrapper(node);
//     var name_len: usize = 0;
//     const name_ptr = c.lxb_dom_element_qualified_name_wrapper(element, &name_len);
//     const tag_name = beam.make(.{name_ptr, name_len}, .{});

//     // Attributes
//     var attrs = std.ArrayList(beam.term).init(beam.allocator);
//     var attr = c.lxb_dom_element_first_attribute_wrapper(element);
//     while (attr != null) : (attr = c.lxb_dom_element_next_attribute_wrapper(attr))
//     {
//         var attr_name_len: usize = 0;
//         var attr_value_len: usize = 0;
//         const attr_name_ptr = c.lxb_dom_attr_qualified_name_wrapper(attr, &attr_name_len);
//         const attr_value_ptr = c.lxb_dom_attr_value_wrapper(attr, &attr_value_len);
//         const attr_name = beam.make(.{attr_name_ptr, attr_name_len}, .{});
//         const attr_value = beam.make(.{attr_value_ptr, attr_value_len}, .{});
//         try attrs.append(beam.make(&[_]beam.term{attr_name, attr_value}, .{}));
//     }

//     // Children
//     var children = std.ArrayList(beam.term).init(beam.allocator);
//     var child = c.lxb_dom_node_first_child_wrapper(node);
//     while (child != null) : (child = c.lxb_dom_node_next_wrapper(child))
//     {
//         try children.append(try node_to_tree(child, sort_attributes, skip_whitespace));
//     }

//     return beam.make(&[_]beam.term{
//         tag_name,
//         beam.make(attrs.toOwnedSlice(), .{}),
//         beam.make(children.toOwnedSlice(), .{}),
//     }, .{});
//   }
//   else if (node.type == c.LXB_DOM_NODE_TYPE_TEXT)
//   {
//     const character_data = c.lxb_dom_interface_character_data_wrapper(node);
//     const data = character_data.data;
//     if (skip_whitespace)
//     {
//       var only_whitespace = true;
//       for (data.data[0..data.length]) |ch|
//       {
//         if (ch != ' ' and ch != '\t' and ch != '\n' and ch != '\r')
//         {
//           only_whitespace = false;
//           break;
//         }
//       }
//       if (only_whitespace)
//       {
//         return beam.make(.{"", 0}, .{});
//       }
//     }
//     return beam.make(.{data.data, data.length}, .{});
//   }
//   else if (node.type == c.LXB_DOM_NODE_TYPE_COMMENT)
//   {
//     const character_data = c.lxb_dom_interface_character_data_wrapper(node);
//     const comment = beam.make(.{character_data.data.data, character_data.data.length}, .{});
//     return beam.make(&[_]beam.term{
//         beam.make_into_atom("comment", .{}),
//         comment
//     }, .{});
//   }
//   else
//   {
//       return beam.make(.{"", 0}, .{});
//   }
// }

// Create from tree structure
// fn node_from_tree_item(
//     document: *c.lxb_html_document_t,
//     item: beam.term,
// ) !?*c.lxb_dom_node_t {
//     _ = document;
//     _ = item;
// const empty_list = beam.make_empty_list(.{});

// const items = get_list_cells(item);
// const tag_name = items.head;
// const cell2 = beam.make_list_cell(items.tail, empty_list, .{});

// const cell2_attrs = get_list_cells(cell2);
// const cell3 = beam.make_list_cell(cell2_attrs.tail, empty_list, .{});

// const children = get_list_cells(cell3).head;
// // Element node
// const tag_bin_result = beam.binary_to_slice(tag_name);
// if (tag_bin_result.err) return null;
// const tag_bin = tag_bin_result.ok;
// const element = c.lxb_dom_document_create_element_wrapper(c.lxb_dom_interface_document_wrapper(document), tag_bin.ptr, tag_bin.len);
// const node = c.lxb_dom_interface_node_wrapper(element);
// // Set attributes
// var attr_list_head = attrs;
// while (attr_list_head != empty_list) {
//     const attr_cell = beam.make_list_cell(attr_list_head, empty_list, .{});
//     if (attr_cell.err) break;
//     const attr_tuple = attr_cell.ok.head;
//     const key_cell = beam.make_list_cell(attr_tuple, empty_list, .{});
//     if (!key_cell.err) {
//         const key = key_cell.ok.head;
//         const value_cell = beam.make_list_cell(key_cell.ok.tail, .{});
//         if (!value_cell.err) {
//             const value = value_cell.ok.head;
//             const key_bin_result = beam.binary_to_slice(key);
//             const value_bin_result = beam.binary_to_slice(value);
//             if (!key_bin_result.err and !value_bin_result.err) {
//                 c.lxb_dom_element_set_attribute_wrapper(
//                     element,
//                     key_bin_result.ok.ptr,
//                     key_bin_result.ok.len,
//                     value_bin_result.ok.ptr,
//                     value_bin_result.ok.len,
//                 );
//             }
//         }
//     }
//     attr_list_head = attr_cell.ok.tail;
// }
// // Children
// var child_list_head = children;
// while (child_list_head != empty_list) {
//     const child_cell = beam.make_list_cell(child_list_head, .{});
//     if (child_cell.err) break;
//     const child_item = child_cell.ok.head;
//     const child_node = try node_from_tree_item(beam.allocator, document, child_item);
//     if (child_node) |cn| {
//         c.lxb_dom_node_insert_child_wrapper(node, cn);
//     }
//     child_list_head = child_cell.ok.tail;
// }
// return node;

// // Check for comment tuple: ["comment", content]
// const cell1c = beam.make_list_cell(item, .{});

// const maybe_atom = cell1c.ok.head;
// const cell2c = beam.make_list_cell(cell1c.ok.tail, empty_list, .{});
// if (!cell2c.err) {
//     const content = cell2c.ok.head;
//     var atom_bin_result = beam.binary_to_slice(maybe_atom);
//     if (!atom_bin_result.err and atom_bin_result.ok.len == 7 and
//         std.mem.eql(u8, atom_bin_result.ok.ptr[0..7], "comment"))
//     {
//         const content_bin_result = beam.binary_to_slice(content);
//         if (content_bin_result.err) return null;
//         const comment = c.lxb_dom_document_create_comment_wrapper(c.lxb_dom_interface_document_wrapper(document), content_bin_result.ok.ptr, content_bin_result.ok.len);
//         return c.lxb_dom_interface_node_wrapper(comment);
//     }
// }

// // Fallback: binary text node
// const text_bin_result = beam.binary_to_slice(item);
// if (!text_bin_result.err) {
//     const text = c.lxb_dom_document_create_text_node_wrapper(c.lxb_dom_interface_document_wrapper(document), text_bin_result.ok.ptr, text_bin_result.ok.len);
//     return c.lxb_dom_interface_node_wrapper(text);
// }

// return null;
// }

pub fn from_tuple(term: beam.term) !beam.term {
    // std.debug.print("{any}\n", .{@TypeOf(beam.get_tuple(term, .{}))});
    // @breakpoint();
    return beam.get_tuple(term, .{});
}

pub fn get_list_cells(term: beam.term) ?beam.term {
    var head: beam.term = undefined;
    var tail: beam.term = undefined;
    const env = beam.get_env();

    if (e.enif_get_list_cell(env, term.v, &head.v, &tail.v) == 0) return null;
    return .{ .head = head, .tail = tail };
}

// const MAX_STACK_TUPLE = 64;

pub fn tuple_from_array(terms: []beam.term) beam.term {
    // return beam.make_struct(terms, .{});
    return beam.make_tuple_from_array(terms, .{});
}

pub fn do_undo(terms: []beam.term) !beam.term {
    const tup = beam.make_tuple_from_array(terms, .{});
    return try from_tuple(tup);
    // This function is a placeholder for the undo operation.
    // It currently does nothing and returns an empty list.
    // You can implement your undo logic here if needed.
    // return beam.make_empty_list(.{});
}

// pub fn from_tree_zig(tree: beam.term) !beam.term {
//     const document = c.lxb_html_document_create_wrapper();
//     if (document == null) {
//         return beam.make_error_pair(error.AllocationError, .{});
//     }

//     const tree_root = c.lxb_dom_interface_node_wrapper(document);
//     var nodes = NodeList.init(beam.allocator);

//     var list_head = tree;
//     const empty_list = beam.make_empty_list(.{});
//     while (list_head != empty_list) {
//         // const cell_result = beam.make_list_cell(list_head, empty_list, .{});

//         if (beam.get_list_cell(list_head, .{})) |tree_node| {
//             const tree_head = tree_node.head;
//             if (document) |doc| {
//                 const node = try node_from_tree_item(
//                     doc,
//                     tree_head,
//                 );
//                 if (node != null) {
//                     c.lxb_dom_node_insert_child_wrapper(tree_root, node);
//                     try nodes.append(node.?);
//                 }
//                 list_head = tree_node.tail;
//             }
//         } else {
//             break; // or handle error
//         }
//     }

//     const resource = try LazigHTML.create(.{
//         .document = document,
//         .nodes = nodes,
//         .from_selector = false,
//     }, .{});
//     return beam.make(.{ .ok, resource }, .{});
// }

// pub fn from_tree_zig(tree: beam.term) !beam.term
// {
//   // tree is now a BEAM term (list of tuples/binaries), not a binary

//   // Create a new document
//   const document = c.lxb_html_document_create_wrapper();
//   if (document == null) {
//       return beam.make_error_pair(error.AllocationError, .{});
//   }
//   const root = c.lxb_dom_interface_node_wrapper(document);
//   var nodes = NodeList.init(beam.allocator);

//   // Build nodes from tree list using make_list_cell/3
//   var list_head = tree;
//   while (list_head != beam.make_empty_list(.{}))
//   {
//     var cell_result = beam.make_list_cell(list_head, .{});
//     if (cell_result.err) break;
//     const tree_node = cell_result.ok.head;
//     const node = try node_from_tree_item(tree_node, document);
//     if (node != null)
//     {
//       c.lxb_dom_node_insert_child_wrapper(root, node);
//       try nodes.append(node);
//     }
//     list_head = cell_result.ok.tail;
//   }
// // Helper to recursively build nodes from tree
// fn node_from_tree_item(item: beam.term, document: *c.lxb_html_document_t) !*c.lxb_dom_node_t {
//   // Try to extract tuple3 (element), tuple2 (comment), or binary (text)
//   // Use make_list_cell to check for tuple/list structure
//   // Element: tuple3 {tag, attrs, children}
//   var cell1 = beam.make_list_cell(item, .{});
//   if (!cell1.err) {
//       var tag_name = cell1.ok.head;
//       var cell2 = beam.make_list_cell(cell1.ok.tail, .{});
//       if (!cell2.err) {
//           var attrs = cell2.ok.head;
//           var cell3 = beam.make_list_cell(cell2.ok.tail, .{});
//           if (!cell3.err) {
//               var children = cell3.ok.head;
//               // Element node
//               var tag_bin_result = beam.binary_to_slice(tag_name);
//               if (tag_bin_result.err) return null;
//               var tag_bin = tag_bin_result.ok;
//               var element = c.lxb_dom_document_create_element_wrapper(
//                   c.lxb_dom_interface_document_wrapper(document), tag_bin.ptr, tag_bin.len
//               );
//               var node = c.lxb_dom_interface_node_wrapper(element);
//               // Set attributes
//               var attr_list_head = attrs;
//               while (attr_list_head != beam.make_empty_list(.{})) {
//                   var attr_cell = beam.make_list_cell(attr_list_head, .{});
//                   if (attr_cell.err) break;
//                   var attr_tuple = attr_cell.ok.head;
//                   var key_cell = beam.make_list_cell(attr_tuple, .{});
//                   if (!key_cell.err) {
//                       var key = key_cell.ok.head;
//                       var value_cell = beam.make_list_cell(key_cell.ok.tail, .{});
//                       if (!value_cell.err) {
//                           var value = value_cell.ok.head;
//                           var key_bin_result = beam.binary_to_slice(key);
//                           var value_bin_result = beam.binary_to_slice(value);
//                           if (!key_bin_result.err and !value_bin_result.err) {
//                               _ = c.lxb_dom_element_set_attribute_wrapper(element, key_bin_result.ok.ptr, key_bin_result.ok.len, value_bin_result.ok.ptr, value_bin_result.ok.len);
//                           }
//                       }
//                   }
//                   attr_list_head = attr_cell.ok.tail;
//               }
//               // Children
//               var child_list_head = children;
//               while (child_list_head != beam.make_empty_list(.{})) {
//                   var child_cell = beam.make_list_cell(child_list_head, .{});
//                   if (child_cell.err) break;
//                   var child_item = child_cell.ok.head;
//                   var child_node = try node_from_tree_item(child_item, document);
//                   if (child_node != null) {
//                       c.lxb_dom_node_insert_child_wrapper(node, child_node);
//                   }
//                   child_list_head = child_cell.ok.tail;
//               }
//               return node;
//           }
//       }
//       // Try to extract tuple2 (comment)
//       var cell1c = beam.make_list_cell(item, .{});
//       if (!cell1c.err) {
//           var maybe_atom = cell1c.ok.head;
//           var cell2c = beam.make_list_cell(cell1c.ok.tail, .{});
//           if (!cell2c.err) {
//               var content = cell2c.ok.head;
//               var atom_bin_result = beam.binary_to_slice(maybe_atom);
//               if (!atom_bin_result.err) {
//                   if (atom_bin_result.ok.len == 7 and std.mem.eql(u8, atom_bin_result.ok.ptr[0..7], "comment")) {
//                       var content_bin_result = beam.binary_to_slice(content);
//                       if (content_bin_result.err) return null;
//                       var comment = c.lxb_dom_document_create_comment_wrapper(
//                           c.lxb_dom_interface_document_wrapper(document), content_bin_result.ok.ptr, content_bin_result.ok.len
//                       );
//                       return c.lxb_dom_interface_node_wrapper(comment);
//                   }
//               }
//           }
//       }
//   }
//   // If not a tuple, treat as binary (text node)
//   var text_bin_result = beam.binary_to_slice(item);
//   if (!text_bin_result.err) {
//       var text = c.lxb_dom_document_create_text_node_wrapper(
//           c.lxb_dom_interface_document_wrapper(document), text_bin_result.ok.ptr, text_bin_result.ok.len
//       );
//       return c.lxb_dom_interface_node_wrapper(text);
//   }
//   return null;
// }

//   const resource = try LazigHTML.create(.{
//       .document = document,
//       .nodes = nodes,
//       .from_selector = false,
//   }, .{});
//   return beam.make(.{ .ok, resource }, .{});
// }

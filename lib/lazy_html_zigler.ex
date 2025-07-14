defmodule LazyHTML.Zigler do
  @moduledoc """
  Zig HTML parser implementation.

  This module contains the actual Zig implementation for HTML parsing,
  designed for direct testing against the C++ reference implementation.
  """

  use Zig,
    otp_app: :lazy_html,
    resources: [:LazyHTML],
    nifs: [
      :from_document_zig,
      :from_fragment_zig,
      :to_html_zig,
      :to_tree_zig,
      :text_zig,
      :attribute_zig,
      :attributes_zig,
      :from_tree_zig
    ],
    c: [
      include_dirs: [
        "/Users/nevendrean/code/elixir/lazy_html/c_headers",
        "/Users/nevendrean/code/elixir/lazy_html/_build/c/third_party/lexbor/2.4.0/source"
      ],
      link_lib: [
        "/Users/nevendrean/code/elixir/lazy_html/_build/c/third_party/lexbor/2.4.0/build/liblexbor_static.a"
      ]
    ]

  ~Z"""

  const std = @import("std");
  const beam = @import("beam");
  const e = @import("erl_nif");
  const c = @cImport({
      @cInclude("lexbor_bridge.h");
  });

  const LazyHTMLStruct = struct {
      document: ?*c.lxb_html_document_t,
  };

  const LazyHTMLCallbacks = struct {
      pub fn dtor(env: beam.env, lazy_html: *LazyHTMLStruct) void {
        _ = env;
          if (lazy_html.document) |document| {
              c.lxb_html_document_destroy_wrapper(document);
          }
      }
  };

  const Self = @This();

  pub const LazyHTML = beam.Resource(LazyHTMLStruct, Self, .{.Callbacks = LazyHTMLCallbacks});

  // Parse HTML document
  pub fn from_document_zig(html: []const u8) !beam.term {
      const maybe_document: ?*c.lxb_html_document_t = c.lxb_html_document_create_wrapper();
      if (maybe_document) |document| {
          const status = c.lxb_html_document_parse_wrapper(document, html.ptr, html.len);
          if (status != c.LXB_STATUS_OK) {
              c.lxb_html_document_destroy_wrapper(document);
              return error.ParseError;
          }

          const resource = try LazyHTML.create(.{.document = document}, .{});
          return beam.make(resource, .{});
      } else {
          return error.AllocationError;
      }
  }

  // Parse HTML fragment
  pub fn from_fragment_zig(html: []const u8) !beam.term {
      const maybe_document: ?*c.lxb_html_document_t = c.lxb_html_document_create_wrapper();
      if (maybe_document) |document| {
          const fragment = c.lxb_html_document_parse_fragment_wrapper(document, null, html.ptr, html.len);
          _ = fragment; // unused for now

          const resource = try LazyHTML.create(.{.document = document}, .{});
          return beam.make(resource, .{});
      } else {
          return error.AllocationError;
      }
  }

  // Convert to HTML string - simplified implementation
  pub fn to_html_zig(resource_term: beam.term, skip_whitespace: bool) ![]const u8 {
      const resource = try beam.get(LazyHTML, resource_term, .{});
      const lazy_html = resource.unpack();
      _ = skip_whitespace; // unused for now

      if (lazy_html.document) |document| {
          const doc_node = c.lxb_dom_interface_node_wrapper(document);
          if (doc_node == null) {
              return error.ConversionError;
          }

          var size: usize = 0;
          const html_ptr = c.lxb_html_serialize_wrapper(doc_node, &size);
          if (html_ptr == null) {
              return error.SerializationError;
          }
          defer c.lxb_html_serialize_cleanup_wrapper(html_ptr);

          const html_slice = @as([*]const u8, @ptrCast(html_ptr))[0..size];
          return beam.allocator.dupe(u8, html_slice);
      } else {
          return error.InvalidResource;
      }
  }

  // Get text content - simplified implementation
  pub fn text_zig(resource_term: beam.term) ![]const u8 {
      const resource = try beam.get(LazyHTML, resource_term, .{});
      const lazy_html = resource.unpack();

      if (lazy_html.document) |document| {
          const doc_node = c.lxb_dom_interface_node_wrapper(document);
          if (doc_node == null) {
              return "";
          }

          var len: usize = 0;
          const text_ptr = c.lxb_dom_node_text_content_wrapper(doc_node, &len);
          if (text_ptr == null) {
              return "";
          }
          defer c.lxb_dom_document_destroy_text_wrapper(c.lxb_dom_interface_document_wrapper(document), text_ptr);

          const text_slice = @as([*]const u8, @ptrCast(text_ptr))[0..len];
          return beam.allocator.dupe(u8, text_slice);
      } else {
          return "";
      }
  }

  // Get single attribute - simplified to return nil for now
  pub fn attribute_zig(resource_term: beam.term, name: []const u8) !?[]const u8 {
      const resource = try beam.get(LazyHTML, resource_term, .{});
      const lazy_html = resource.unpack();
      _ = name;

      if (lazy_html.document == null) {
          return null;
      }

      // TODO: Implement attribute lookup
      return null;
  }

  // Get all attributes - simplified to return empty map for now
  pub fn attributes_zig(resource_term: beam.term) !struct {} {
      const resource = try beam.get(LazyHTML, resource_term, .{});
      _ = resource.unpack();

      // Return empty struct for now
      return .{};
  }

  // Convert to tree structure - simplified to return empty string for now
  pub fn to_tree_zig(resource_term: beam.term, sort_attributes: bool, skip_whitespace: bool) ![]const u8 {
      const resource = try beam.get(LazyHTML, resource_term, .{});
      const lazy_html = resource.unpack();
      _ = sort_attributes;
      _ = skip_whitespace;

      if (lazy_html.document == null) {
          return "";
      }

      // TODO: Implement tree conversion
      return "";
  }

  // Create from tree structure - simplified to return error for now
  pub fn from_tree_zig(tree_json: []const u8) !beam.term {
    _ = tree_json;
    return error.NotImplemented;
  }
  """

  # Simple wrapper functions
  def from_document(html) do
    case from_document_zig(html) do
      {:ok, resource} -> %LazyHTML{resource: resource}
      error -> error
    end
  end

  def from_fragment(html) do
    case from_fragment_zig(html) do
      {:ok, resource} -> %LazyHTML{resource: resource}
      error -> error
    end
  end

  def to_html(%LazyHTML{} = lazy_html, skip_whitespace \\ false) do
    to_html_zig(lazy_html.resource, skip_whitespace)
  end

  def text(%LazyHTML{} = lazy_html) do
    text_zig(lazy_html.resource)
  end

  def attribute(%LazyHTML{} = lazy_html, name) do
    case attribute_zig(lazy_html.resource, name) do
      nil -> nil
      value -> value
    end
  end

  def attributes(%LazyHTML{} = lazy_html) do
    attributes_zig(lazy_html.resource)
  end

  def to_tree(%LazyHTML{} = lazy_html, sort_attributes \\ false, skip_whitespace \\ false) do
    to_tree_zig(lazy_html.resource, sort_attributes, skip_whitespace)
  end

  def from_tree(tree_json) when is_binary(tree_json) do
    case from_tree_zig(tree_json) do
      {:ok, resource} -> %LazyHTML{resource: resource}
      error -> error
    end
  end
end

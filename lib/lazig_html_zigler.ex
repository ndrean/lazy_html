defmodule LazigHTML.Zigler do
  @moduledoc """
  Zig HTML parser implementation.

  This module contains the actual Zig implementation for HTML parsing,
  designed for direct testing against the C++ reference implementation.
  """

  use Zig,
    otp_app: :lazy_html,
    resources: [:LazigHTML_Resource],
    leak_check: true,
    nifs: [
      :from_fragment,
      :num_nodes,
      :to_array
      # :get_nodes
    ],
    zig_code_path: "lazig.zig",
    c: [
      include_dirs: [
        "/Users/nevendrean/code/elixir/lazy_html/c_headers",
        "/Users/nevendrean/code/elixir/lazy_html/priv/lib/include"
      ],
      src: [
        "/Users/nevendrean/code/elixir/lazy_html/c_src/lexbor_wrapper.c"
      ],
      link_lib: [
        "/Users/nevendrean/code/elixir/lazy_html/priv/lib/lib/liblexbor_static.a"
      ]
    ]
end

# =================================

# // def from_fragment(html) do
# //   case from_fragment_zig(html) do
# //     {:ok, resource} -> %LazyHTML{resource: resource}
# //     error -> error
# //   end
# // end

# // def to_html(%LazyHTML{} = lazy_html, skip_whitespace \\ false) do
# //   to_html_zig(lazy_html.resource, skip_whitespace)
# // end

# // def text(%LazyHTML{} = lazy_html) do
# //   text_zig(lazy_html.resource)
# // end

# // def attribute(%LazyHTML{} = lazy_html, name) do
# //   case attribute_zig(lazy_html.resource, name) do
# //     nil -> nil
# //     value -> value
# //   end
# // end

# // def attributes(%LazyHTML{} = lazy_html) do
# //   attributes_zig(lazy_html.resource)
# // end

# // def to_tree(%LazyHTML{} = lazy_html, sort_attributes \\ false, skip_whitespace \\ false) do
# //   to_tree_zig(lazy_html.resource, sort_attributes, skip_whitespace)
# // end

# // def from_tree(tree_json) when is_binary(tree_json) do
# //   case from_tree_zig(tree_json) do
# //     {:ok, resource} -> %LazyHTML{resource: resource}
# //     error -> error
# //   end
# // end
# end

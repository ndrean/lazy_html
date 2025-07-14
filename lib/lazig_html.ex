defmodule LazigHTML do
  @moduledoc """
  LazigHTML - LazyHTML with Zig implementation for testing and development.

  This module provides the same interface as LazyHTML but uses our Zigler
  parser implementation. It's used for testing doctests and debugging our
  Zig implementation against the C++ reference implementation.

  Only implements the functions that have working Zig NIFs.
  """

  defstruct [:resource]

  @behaviour Access

  @type t :: %__MODULE__{resource: reference()}

  @doc """
  Parses an HTML document.

  This function expects a complete document, therefore if either of
  `<html>`, `<head>` or `<body>` tags is missing, it will be added,
  which matches the usual browser behaviour. To parse a part of an
  HTML document, use `from_fragment/1` instead.

  ## Examples

      iex> LazigHTML.from_document(~S|<html><head></head><body>Hello world!</body></html>|)
      #LazigHTML<
        1 node
        #1
        <html><head></head><body>Hello world!</body></html>
      >

      iex> LazigHTML.from_document(~S|<div>Hello world!</div>|)
      #LazigHTML<
        1 node
        #1
        <html><head></head><body><div>Hello world!</div></body></html>
      >

  """
  @spec from_document(String.t()) :: t()
  def from_document(html) when is_binary(html) do
    case LazyHTML.Zigler.from_document(html) do
      %LazyHTML{resource: resource} -> %LazigHTML{resource: resource}
      {:error, reason} -> {:error, reason}
      result -> result
    end
  end

  @doc """
  Parses a segment of an HTML document.

  As opposed to `from_document/1`, this function does not expect a full
  document and does not add any extra tags.

  ## Examples

      iex> LazigHTML.from_fragment(~S|<a class="button">Click me</a>|)
      #LazigHTML<
        1 node
        #1
        <a class="button">Click me</a>
      >

      iex> LazigHTML.from_fragment(~S|<span>Hello</span> <span>world</span>|)
      #LazigHTML<
        3 nodes
        #1
        <span>Hello</span>
        #2
        [whitespace]
        #3
        <span>world</span>
      >

  """
  @spec from_fragment(String.t()) :: t()
  def from_fragment(html) when is_binary(html) do
    case LazyHTML.Zigler.from_fragment(html) do
      %LazyHTML{resource: resource} -> %LazigHTML{resource: resource}
      {:error, reason} -> {:error, reason}
      result -> result
    end
  end

  @doc ~S'''
  Serializes `lazy_html` as an HTML string.

  ## Options

    * `:skip_whitespace_nodes` - when `true`, ignores text nodes that
      consist entirely of whitespace, usually whitespace between tags.
      Defaults to `false`.

  ## Examples

      iex> lazy_html = LazigHTML.from_document(~S|<html><head></head><body>Hello world!</body></html>|)
      iex> LazigHTML.to_html(lazy_html)
      "<html><head></head><body>Hello world!</body></html>"

      iex> lazy_html = LazigHTML.from_fragment(~S|<span>Hello</span> <span>world</span>|)
      iex> LazigHTML.to_html(lazy_html)
      "<span>Hello</span> <span>world</span>"

      iex> lazy_html =
      ...>   LazigHTML.from_fragment("""
      ...>   <p>
      ...>     <span> Hello </span>
      ...>     <span> world </span>
      ...>   </p>
      ...>   """)
      iex> LazigHTML.to_html(lazy_html, skip_whitespace_nodes: true)
      "<p><span> Hello </span><span> world </span></p>"

  '''
  @spec to_html(t(), keyword()) :: String.t()
  def to_html(%LazigHTML{} = lazy_html, opts \\ []) when is_list(opts) do
    opts = Keyword.validate!(opts, skip_whitespace_nodes: false)

    # Convert to LazyHTML struct for ZiglerParser
    lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
    LazyHTML.Zigler.to_html(lazy_html_struct, opts[:skip_whitespace_nodes])
  end

  @doc """
  Builds an Elixir tree data structure representing the `lazy_html`
  document.

  ## Options

    * `:sort_attributes` - when `true`, attributes lists are sorted
      alphabetically by name. Defaults to `false`.

    * `:skip_whitespace_nodes` - when `true`, ignores text nodes that
      consist entirely of whitespace, usually whitespace between tags.
      Defaults to `false`.

  ## Examples

      iex> lazy_html = LazigHTML.from_document(~S|<html><head><title>Page</title></head><body>Hello world</body></html>|)
      iex> LazigHTML.to_tree(lazy_html)
      [{"html", [], [{"head", [], [{"title", [], ["Page"]}]}, {"body", [], ["Hello world"]}]}]

      iex> lazy_html = LazigHTML.from_fragment(~S|<div><!-- Link --><a href="https://elixir-lang.org">Elixir</a></div>|)
      iex> LazigHTML.to_tree(lazy_html)
      [
        {"div", [], [{:comment, " Link "}, {"a", [{"href", "https://elixir-lang.org"}], ["Elixir"]}]}
      ]

  You can get a normalized tree by passing `sort_attributes: true`:

      iex> lazy_html = LazigHTML.from_fragment(~S|<div id="root" class="layout"></div>|)
      iex> LazigHTML.to_tree(lazy_html, sort_attributes: true)
      [{"div", [{"class", "layout"}, {"id", "root"}], []}]

  """
  @spec to_tree(t(), keyword()) :: LazyHTML.Tree.t()
  def to_tree(%LazigHTML{} = lazy_html, opts \\ []) when is_list(opts) do
    opts = Keyword.validate!(opts, sort_attributes: false, skip_whitespace_nodes: false)

    # Convert to LazyHTML struct for ZiglerParser
    lazy_html_struct = %LazyHTML{resource: lazy_html.resource}

    LazyHTML.Zigler.to_tree(
      lazy_html_struct,
      opts[:sort_attributes],
      opts[:skip_whitespace_nodes]
    )
  end

  @doc """
  Builds a lazy HTML document from an Elixir tree data structure.

  ## Examples

      iex> tree = [
      ...>   {"html", [], [{"head", [], [{"title", [], ["Page"]}]}, {"body", [], ["Hello world"]}]}
      ...> ]
      iex> LazigHTML.from_tree(tree)
      #LazigHTML<
        1 node
        #1
        <html><head><title>Page</title></head><body>Hello world</body></html>
      >

      iex> tree = [
      ...>   {"div", [], []},
      ...>   {:comment, " Link "},
      ...>   {"a", [{"href", "https://elixir-lang.org"}], ["Elixir"]}
      ...> ]
      iex> LazigHTML.from_tree(tree)
      #LazigHTML<
        3 nodes
        #1
        <div></div>
        #2
        <!-- Link -->
        #3
        <a href="https://elixir-lang.org">Elixir</a>
      >

  """
  @spec from_tree(LazyHTML.Tree.t()) :: t()
  def from_tree(tree) when is_list(tree) do
    case LazyHTML.Zigler.from_tree(tree) do
      %LazyHTML{resource: resource} -> %LazigHTML{resource: resource}
      {:error, reason} -> {:error, reason}
      result -> result
    end
  end

  @doc """
  Returns the text content of all nodes in `lazy_html`.

  ## Examples

      iex> lazy_html = LazigHTML.from_fragment(~S|<div><span>Hello</span> <span>world</span></div>|)
      iex> LazigHTML.text(lazy_html)
      "Hello world"

  If you want to get the text for each root node separately, you can
  use `Enum.map/2`:

      iex> lazy_html = LazigHTML.from_fragment(~S|<div><span>Hello</span> <span>world</span></div>|)
      iex> spans = LazigHTML.query(lazy_html, "span")
      #LazigHTML<
        2 nodes (from selector)
        #1
        <span>Hello</span>
        #2
        <span>world</span>
      >
      iex> Enum.map(spans, &LazigHTML.text/1)
      ["Hello", "world"]

  """
  @spec text(t()) :: String.t()
  def text(%LazigHTML{} = lazy_html) do
    # Convert to LazyHTML struct for ZiglerParser
    lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
    LazyHTML.Zigler.text(lazy_html_struct)
  end

  @doc ~S'''
  Returns all values of the given attribute on the `lazy_html` root
  nodes.

  ## Examples

      iex> lazy_html =
      ...>   LazigHTML.from_fragment("""
      ...>   <div>
      ...>     <span data-id="1">Hello</span>
      ...>     <span data-id="2">world</span>
      ...>     <span>!</span>
      ...>   </div>
      ...>   """)
      iex> spans = LazigHTML.query(lazy_html, "span")
      iex> LazigHTML.attribute(spans, "data-id")
      ["1", "2"]
      iex> LazigHTML.attribute(spans, "data-other")
      []

  Note that attributes without value, implicitly have an empty value:

      iex> lazy_html = LazigHTML.from_fragment(~S|<div><button disabled>Click me</button></div>|)
      iex> button = LazigHTML.query(lazy_html, "button")
      iex> LazigHTML.attribute(button, "disabled")
      [""]

  '''
  @spec attribute(t(), String.t()) :: list(String.t())
  def attribute(%LazigHTML{} = lazy_html, name) when is_binary(name) do
    # Convert to LazyHTML struct for ZiglerParser
    lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
    LazyHTML.Zigler.attribute(lazy_html_struct, name)
  end

  @doc ~S'''
  Returns attribute lists for every root element in `lazy_html`.

  Note that if there are text or comment root nodes, they are ignored,
  and they have no corresponding list in the result.

  ## Examples

      iex> lazy_html =
      ...>   LazigHTML.from_fragment("""
      ...>   <div>
      ...>     <span class="text" data-id="1">Hello</span>
      ...>     <span>world</span>
      ...>   </div>
      ...>   """)
      iex> spans = LazigHTML.query(lazy_html, "span")
      iex> LazigHTML.attributes(spans)
      [
        [{"class", "text"}, {"data-id", "1"}],
        []
      ]

      iex> lazy_html =
      ...>   LazigHTML.from_fragment("""
      ...>   <!-- Comment-->
      ...>   <span class="text">Hello</span>
      ...>   world
      ...>   """)
      iex> LazigHTML.attributes(lazy_html)
      [
        [{"class", "text"}]
      ]

  '''
  @spec attributes(t()) :: list({String.t(), String.t()})
  def attributes(%LazigHTML{} = lazy_html) do
    # Convert to LazyHTML struct for ZiglerParser
    lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
    LazyHTML.Zigler.attributes(lazy_html_struct)
  end

  # Functions not yet implemented in Zig - stub them out for now

  def query(%LazigHTML{} = _lazy_html, _selector) do
    {:error, "query/2 not yet implemented in Zig"}
  end

  def query_by_id(%LazigHTML{} = _lazy_html, _id) do
    {:error, "query_by_id/2 not yet implemented in Zig"}
  end

  def filter(%LazigHTML{} = _lazy_html, _selector) do
    {:error, "filter/2 not yet implemented in Zig"}
  end

  def child_nodes(%LazigHTML{} = _lazy_html) do
    {:error, "child_nodes/1 not yet implemented in Zig"}
  end

  def tag(%LazigHTML{} = _lazy_html) do
    {:error, "tag/1 not yet implemented in Zig"}
  end

  # Access implementation - simplified for now

  @impl true
  def fetch(%LazigHTML{} = _lazy_html, _selector) do
    {:error, "Access.fetch/2 not yet implemented in Zig"}
  end

  @impl true
  def get_and_update(%LazigHTML{}, _index, _update) do
    raise "Access.get_and_update/3 is not supported by LazigHTML"
  end

  @impl true
  def pop(%LazigHTML{}, _index) do
    raise "Access.pop/2 is not supported by LazigHTML"
  end
end

defimpl Inspect, for: LazigHTML do
  import Inspect.Algebra

  def inspect(lazy_html, opts) do
    # For now, we'll use the LazyHTML.NIF.nodes function for inspection
    # since the nodes/1 function isn't implemented in our Zig parser yet
    try do
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
      {nodes, from_selector} = LazyHTML.NIF.nodes(lazy_html_struct)

      info =
        case length(nodes) do
          1 -> "1 node"
          n -> "#{n} nodes"
        end

      info =
        if from_selector do
          info <> " (from selector)"
        else
          info
        end

      inner =
        if nodes == [] do
          empty()
        else
          items = Enum.with_index(nodes, 1)
          {items, last_doc} = apply_limit(items, opts.limit)

          inner =
            concat(
              Enum.map_intersperse(items, concat(separator(), line()), &node_to_doc(&1, opts))
            )

          inner = concat([inner, last_doc])
          concat([separator(), nest(concat(line(), inner), 2)])
        end

      force_unfit(
        concat([
          "#LazigHTML<",
          nest(concat([line(), info]), 2),
          inner,
          line(),
          ">"
        ])
      )
    rescue
      _ ->
        # Fallback if nodes/1 fails
        concat([
          "#LazigHTML<",
          nest(concat([line(), "resource: #{inspect(lazy_html.resource)}"]), 2),
          line(),
          ">"
        ])
    end
  end

  if Application.compile_env(:lazy_html, :inspect_extra_newline, true) do
    defp separator(), do: line()
  else
    defp separator(), do: empty()
  end

  defp apply_limit(items, :infinity), do: {items, empty()}

  defp apply_limit(items, limit) do
    case Enum.split(items, limit) do
      {items, []} -> {items, empty()}
      {items, more} -> {items, concat([separator(), line(), "[#{length(more)} more]"])}
    end
  end

  defp node_to_doc({%LazyHTML{} = node, number}, opts) do
    html_doc =
      node
      |> LazyHTML.to_html()
      |> apply_printable_limit(opts.printable_limit)
      |> String.replace(~r/^\s+/, "[whitespace]")
      |> String.replace(~r/\s+$/, "[whitespace]")
      |> String.split("\n")
      |> Enum.intersperse(line())
      |> concat()

    concat([
      color("##{number}", :atom, opts),
      line(),
      html_doc
    ])
  end

  defp apply_printable_limit(string, :infinity), do: string

  defp apply_printable_limit(string, limit) do
    case String.split_at(string, limit) do
      {left, ""} -> left
      {left, _more} -> left <> "[...]"
    end
  end
end

defimpl Enumerable, for: LazigHTML do
  def count(_lazy_html) do
    {:error, __MODULE__}
  end

  def member?(_lazy_html, _element), do: {:error, __MODULE__}

  def slice(_lazy_html), do: {:error, __MODULE__}

  def reduce(_lazy_html, _acc, _fun) do
    {:error, __MODULE__}
  end
end

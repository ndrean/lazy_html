defmodule DoctestWithZigTest do
  @moduledoc """
  Test LazyHTML doctests using the simple Zig implementation.

  This module creates a simple wrapper that calls LazyHTML.ZigSimple
  functions directly, without complex conditionals or configurations.
  """

  use ExUnit.Case
  doctest LazyHTMLZig, import: true

  # Simple wrapper module that directly calls Zig implementation
  defmodule LazyHTMLZig do
    @moduledoc """
    Simple LazyHTML wrapper that directly calls Zig implementation.

    No conditionals, no complex configuration - just direct calls to
    the Zig functions we have implemented, and placeholder calls to
    C++ functions we haven't implemented yet.
    """

    defstruct [:resource]
    @type t :: %__MODULE__{resource: reference()}

    # Direct calls to Zig implementation
    def from_document(html) when is_binary(html) do
      case LazyHTML.Zigler.from_document(html) do
        %LazyHTML{resource: resource} -> %__MODULE__{resource: resource}
        other -> other
      end
    end

    def from_fragment(html) when is_binary(html) do
      case LazyHTML.Zigler.from_fragment(html) do
        %LazyHTML{resource: resource} -> %__MODULE__{resource: resource}
        other -> other
      end
    end

    def to_html(%__MODULE__{} = lazy_html, opts \\ []) when is_list(opts) do
      opts = Keyword.validate!(opts, skip_whitespace_nodes: false)
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
      LazyHTML.Zigler.to_html(lazy_html_struct, opts[:skip_whitespace_nodes])
    end

    def to_tree(%__MODULE__{} = lazy_html, opts \\ []) when is_list(opts) do
      opts = Keyword.validate!(opts, sort_attributes: false, skip_whitespace_nodes: false)
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}

      LazyHTML.Zigler.to_tree(
        lazy_html_struct,
        opts[:sort_attributes],
        opts[:skip_whitespace_nodes]
      )
    end

    def from_tree(tree) when is_list(tree) do
      case LazyHTML.Zigler.from_tree(tree) do
        %LazyHTML{resource: resource} -> %__MODULE__{resource: resource}
        other -> other
      end
    end

    def text(%__MODULE__{} = lazy_html) do
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
      LazyHTML.Zigler.text(lazy_html_struct)
    end

    def attribute(%__MODULE__{} = lazy_html, name) when is_binary(name) do
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
      LazyHTML.Zigler.attribute(lazy_html_struct, name)
    end

    def attributes(%__MODULE__{} = lazy_html) do
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
      LazyHTML.Zigler.attributes(lazy_html_struct)
    end

    # Placeholder calls to C++ functions we haven't implemented in Zig yet
    def query(%__MODULE__{} = lazy_html, selector) when is_binary(selector) do
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}

      case LazyHTML.NIF.query(lazy_html_struct, selector) do
        %LazyHTML{resource: resource} -> %__MODULE__{resource: resource}
        other -> other
      end
    end

    def query_by_id(%__MODULE__{} = lazy_html, id) when is_binary(id) do
      if id == "" do
        raise ArgumentError, "id cannot be empty"
      end

      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}

      case LazyHTML.NIF.query_by_id(lazy_html_struct, id) do
        %LazyHTML{resource: resource} -> %__MODULE__{resource: resource}
        other -> other
      end
    end

    def filter(%__MODULE__{} = lazy_html, selector) when is_binary(selector) do
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}

      case LazyHTML.NIF.filter(lazy_html_struct, selector) do
        %LazyHTML{resource: resource} -> %__MODULE__{resource: resource}
        other -> other
      end
    end

    def child_nodes(%__MODULE__{} = lazy_html) do
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}

      case LazyHTML.NIF.child_nodes(lazy_html_struct) do
        %LazyHTML{resource: resource} -> %__MODULE__{resource: resource}
        other -> other
      end
    end

    def tag(%__MODULE__{} = lazy_html) do
      lazy_html_struct = %LazyHTML{resource: lazy_html.resource}
      LazyHTML.NIF.tag(lazy_html_struct)
    end

    @doc """
    Parses an HTML document using Zig backend.

    ## Examples

        iex> LazyHTMLZig.from_document("<div>Hello</div>") |> LazyHTMLZig.to_html()
        "<html><head></head><body><div>Hello</div></body></html>"

        iex> LazyHTMLZig.from_document("<div>Hello</div>") |> LazyHTMLZig.text()
        "Hello"

        iex> LazyHTMLZig.from_fragment("<div class='test'>Hello</div>") |> LazyHTMLZig.attribute("class")
        "test"

        iex> LazyHTMLZig.from_fragment("<div class='test' id='main'>Hello</div>") |> LazyHTMLZig.attributes()
        %{"class" => "test", "id" => "main"}

    """
    def test_zig_functions do
      :ok
    end
  end

  # Implement Inspect for LazyHTMLZig similar to LazyHTML
  defimpl Inspect, for: LazyHTMLZig do
    import Inspect.Algebra

    def inspect(lazy_html, opts) do
      # Convert to LazyHTML struct for getting nodes
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
          "#LazyHTMLZig<",
          nest(concat([line(), info]), 2),
          inner,
          line(),
          ">"
        ])
      )
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
end

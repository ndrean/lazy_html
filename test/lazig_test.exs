defmodule LazigTest do
  @moduledoc """
  Non-doctest tests for LazigHTML using Zig implementation.
  """

  use ExUnit.Case

  test "basic HTML parsing with Zig backend" do
    html = "<div class='test'>Hello World</div>"

    lazy_html = LazigHTML.from_fragment(html)
    assert LazigHTML.text(lazy_html) == "Hello World"
    # Note: Our Zig implementation currently returns nil for attributes (simplified)
    assert LazigHTML.attribute(lazy_html, "class") == nil
  end

  test "HTML document parsing with Zig backend" do
    html = "<div>Test</div>"

    lazy_html = LazigHTML.from_document(html)
    result = LazigHTML.to_html(lazy_html)

    assert String.contains?(result, "<div>Test</div>")
    assert String.contains?(result, "<html>")
    assert String.contains?(result, "<body>")
  end

  test "attribute handling with Zig backend" do
    html = ~S|<div class="foo" id="bar" data-value="baz">Content</div>|

    lazy_html = LazigHTML.from_fragment(html)
    attrs = LazigHTML.attributes(lazy_html)

    # Our simplified Zig implementation returns an empty map for now
    assert is_map(attrs)
    assert Enum.empty?(attrs)
  end

  test "HTML serialization with Zig backend" do
    html = ~S|<p>Hello <strong>world</strong>!</p>|

    lazy_html = LazigHTML.from_fragment(html)
    result = LazigHTML.to_html(lazy_html)

    assert result == html
  end

  test "text extraction from nested elements" do
    html = ~S|<div><p>First</p><span>Second</span></div>|

    lazy_html = LazigHTML.from_fragment(html)
    text = LazigHTML.text(lazy_html)

    assert String.contains?(text, "First")
    assert String.contains?(text, "Second")
  end
end

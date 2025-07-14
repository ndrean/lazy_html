#include "lexbor/html/html.h"
#include "lexbor/html/serialize.h"
#include <stdlib.h>
#include <string.h>
#include "lexbor/dom/interfaces/character_data.h"
#include "lexbor/dom/interfaces/attr.h"
#include "lexbor/dom/interfaces/element.h"
#include "lexbor/core/str.h"
#include "lexbor/html/interfaces/template_element.h"

// Wrapper implementations for functions that have circular dependencies in Zig @cImport
// This bridges the gap between Zig's simplified imports and the complex Lexbor API

lxb_dom_node_t *lxb_dom_node_first_child_wrapper(lxb_dom_node_t *node)
{
  if (!node)
    return NULL;
  return node->first_child;
}

lxb_dom_node_t *lxb_dom_node_next_wrapper(lxb_dom_node_t *node)
{
  if (!node)
    return NULL;
  return node->next;
}

lxb_dom_node_t *lxb_dom_node_parent_wrapper(lxb_dom_node_t *node)
{
  if (!node)
    return NULL;
  return node->parent;
}

unsigned int lxb_dom_node_type_wrapper(lxb_dom_node_t *node)
{
  if (!node)
    return 0;
  return node->type;
}

// Document and HTML functions
lxb_html_document_t *lxb_html_document_create_wrapper(void)
{
  return lxb_html_document_create();
}

void lxb_html_document_destroy_wrapper(lxb_html_document_t *document)
{
  lxb_html_document_destroy(document);
}

lxb_status_t lxb_html_document_parse_wrapper(lxb_html_document_t *document,
                                             const lxb_char_t *html, size_t size)
{
  return lxb_html_document_parse(document, html, size);
}

lxb_dom_node_t *lxb_html_document_parse_fragment_wrapper(lxb_html_document_t *document,
                                                         lxb_dom_element_t *element,
                                                         const lxb_char_t *html, size_t size)
{
  return lxb_html_document_parse_fragment(document, element, html, size);
}

lxb_dom_element_t *lxb_dom_document_create_element_wrapper(lxb_dom_document_t *document,
                                                           const lxb_char_t *local_name,
                                                           size_t lname_len,
                                                           void *reserved_for_opt)
{
  return lxb_dom_document_create_element(document, local_name, lname_len, reserved_for_opt);
}

lxb_dom_document_t *lxb_dom_interface_document_wrapper(lxb_html_document_t *document)
{
  return &document->dom_document;
}

lxb_dom_node_t *lxb_dom_interface_node_wrapper(lxb_html_document_t *document)
{
  return lxb_dom_interface_node(document);
}

lxb_dom_element_t *lxb_dom_interface_element_wrapper(lxb_dom_node_t *node)
{
  return lxb_dom_interface_element(node);
}

const lxb_char_t *lxb_dom_element_qualified_name_wrapper(lxb_dom_element_t *element,
                                                         size_t *len)
{
  return lxb_dom_element_qualified_name(element, len);
}

lxb_dom_character_data_t *lxb_dom_interface_character_data_wrapper(lxb_dom_node_t *node)
{
  return lxb_dom_interface_character_data(node);
}

const uint8_t *lxb_dom_attr_value_wrapper(lxb_dom_attr_t *attr, size_t *len)
{
  return lxb_dom_attr_value(attr, len);
}

// Attribute navigation functions
lxb_dom_attr_t *lxb_dom_element_first_attribute_wrapper(lxb_dom_element_t *element)
{
  return lxb_dom_element_first_attribute(element);
}

lxb_dom_attr_t *lxb_dom_element_next_attribute_wrapper(lxb_dom_attr_t *attr)
{
  return lxb_dom_element_next_attribute(attr);
}

const lxb_char_t *lxb_dom_attr_qualified_name_wrapper(lxb_dom_attr_t *attr, size_t *len)
{
  return lxb_dom_attr_qualified_name(attr, len);
}

// Character data access
const lxb_char_t *lxb_dom_character_data_data_wrapper(lxb_dom_character_data_t *character_data, size_t *len)
{
  if (!character_data)
    return NULL;
  if (len)
    *len = character_data->data.length;
  return character_data->data.data;
}

// Character data access wrappers
const uint8_t *lxb_dom_character_data_content_wrapper(lxb_dom_character_data_t *char_data, size_t *len)
{
  if (!char_data)
  {
    *len = 0;
    return NULL;
  }
  *len = char_data->data.length;
  return char_data->data.data;
}

// Constants
const unsigned int LXB_STATUS_OK_WRAPPER = LXB_STATUS_OK;
const unsigned int LXB_STATUS_ERROR_UNEXPECTED_DATA_WRAPPER = LXB_STATUS_ERROR_UNEXPECTED_DATA;
const unsigned int LXB_DOM_NODE_TYPE_TEXT_WRAPPER = LXB_DOM_NODE_TYPE_TEXT;
const unsigned int LXB_DOM_NODE_TYPE_ELEMENT_WRAPPER = LXB_DOM_NODE_TYPE_ELEMENT;
const unsigned int LXB_DOM_NODE_TYPE_COMMENT_WRAPPER = LXB_DOM_NODE_TYPE_COMMENT;

// HTML Tag constants
const unsigned int LXB_TAG_STYLE_WRAPPER = LXB_TAG_STYLE;
const unsigned int LXB_TAG_SCRIPT_WRAPPER = LXB_TAG_SCRIPT;
const unsigned int LXB_TAG_XMP_WRAPPER = LXB_TAG_XMP;
const unsigned int LXB_TAG_IFRAME_WRAPPER = LXB_TAG_IFRAME;
const unsigned int LXB_TAG_NOEMBED_WRAPPER = LXB_TAG_NOEMBED;
const unsigned int LXB_TAG_NOFRAMES_WRAPPER = LXB_TAG_NOFRAMES;
const unsigned int LXB_TAG_PLAINTEXT_WRAPPER = LXB_TAG_PLAINTEXT;
const unsigned int LXB_TAG_TEMPLATE_WRAPPER = LXB_TAG_TEMPLATE;

// Namespace constants
const unsigned int LXB_NS_SVG_WRAPPER = LXB_NS_SVG;

// Lexbor action constants
const unsigned int LEXBOR_ACTION_OK_WRAPPER = LEXBOR_ACTION_OK;

// DOM Document Functions needed for basic parsing
lxb_dom_text_t *lxb_dom_document_create_text_node_wrapper(lxb_dom_document_t *document,
                                                          const lxb_char_t *data, size_t size)
{
  return lxb_dom_document_create_text_node(document, data, size);
}

lxb_dom_comment_t *lxb_dom_document_create_comment_wrapper(lxb_dom_document_t *document,
                                                           const lxb_char_t *data, size_t size)
{
  return lxb_dom_document_create_comment(document, data, size);
}

// Interface Conversion Functions
lxb_dom_document_t *lxb_dom_interface_document_from_node_wrapper(lxb_dom_node_t *node)
{
  return lxb_dom_interface_document(node);
}

lxb_html_template_element_t *lxb_html_interface_template_wrapper(lxb_dom_node_t *node)
{
  return lxb_html_interface_template(node);
}

// Node Navigation and Manipulation Functions
lxb_dom_node_t *lxb_dom_node_insert_child_wrapper(lxb_dom_node_t *to, lxb_dom_node_t *node)
{
  lxb_dom_node_insert_child(to, node);
  return node;
}

lxb_char_t *lxb_dom_node_text_content_wrapper(lxb_dom_node_t *node, size_t *len)
{
  return lxb_dom_node_text_content(node, len);
}

// Element Functions
lxb_dom_attr_t *lxb_dom_element_set_attribute_wrapper(lxb_dom_element_t *element,
                                                      const lxb_char_t *qualified_name, size_t qn_len,
                                                      const lxb_char_t *value, size_t value_len)
{
  return lxb_dom_element_set_attribute(element, qualified_name, qn_len, value, value_len);
}

const lxb_char_t *lxb_dom_element_get_attribute_wrapper(lxb_dom_element_t *element,
                                                        const lxb_char_t *qualified_name, size_t qn_len,
                                                        size_t *value_len)
{
  return lxb_dom_element_get_attribute(element, qualified_name, qn_len, value_len);
}

bool lxb_dom_element_has_attribute_wrapper(lxb_dom_element_t *element,
                                           const lxb_char_t *qualified_name, size_t qn_len)
{
  return lxb_dom_element_has_attribute(element, qualified_name, qn_len);
}

// HTML-specific Functions
bool lxb_html_tree_node_is_wrapper(lxb_dom_node_t *node, lxb_tag_id_t tag_id)
{
  return lxb_html_tree_node_is(node, tag_id);
}

bool lxb_html_node_is_void_wrapper(lxb_dom_node_t *node)
{
  return lxb_html_node_is_void(node);
}

// Document Management (Memory)
void lxb_dom_document_destroy_text_wrapper(lxb_dom_document_t *document, lxb_char_t *text)
{
  lxb_dom_document_destroy_text(document, text);
}

// String Utility Functions
bool lexbor_str_data_ncmp_wrapper(const lxb_char_t *first, const lxb_char_t *second, size_t size)
{
  return lexbor_str_data_ncmp(first, second, size);
}

// Helper Functions
lxb_tag_id_t lxb_dom_node_local_name_wrapper(lxb_dom_node_t *node)
{
  return node->local_name;
}

uintptr_t lxb_dom_node_ns_wrapper(lxb_dom_node_t *node)
{
  return node->ns;
}

void lxb_dom_node_set_ns_wrapper(lxb_dom_node_t *node, uintptr_t ns)
{
  node->ns = ns;
}

lxb_dom_document_fragment_t *lxb_html_template_element_content_wrapper(lxb_html_template_element_t *template_element)
{
  return template_element->content;
}

lxb_dom_node_t *lxb_dom_document_fragment_node_wrapper(lxb_dom_document_fragment_t *fragment)
{
  return &fragment->node;
}

// HTML Serialization Functions
char *lxb_html_serialize_wrapper(lxb_dom_node_t *node, size_t *size)
{
  if (node == NULL || size == NULL)
  {
    return NULL;
  }

  lexbor_str_t str = {0};
  lxb_status_t status = lxb_html_serialize_tree_str(node, &str);

  if (status != LXB_STATUS_OK)
  {
    return NULL;
  }

  *size = str.length;

  // Make a copy of the string for BEAM
  char *result = (char *)malloc(str.length + 1);
  if (result == NULL)
  {
    lexbor_str_destroy(&str, NULL, true);
    return NULL;
  }

  memcpy(result, str.data, str.length);
  result[str.length] = '\0';

  // Clean up lexbor string
  lexbor_str_destroy(&str, NULL, true);

  return result;
}

void lxb_html_serialize_cleanup_wrapper(char *html_str)
{
  if (html_str != NULL)
  {
    free(html_str);
  }
}

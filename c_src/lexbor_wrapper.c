#include <stdlib.h> // For malloc/free
#include <string.h> // For memcpy/strlen

#include <stdint.h> // For uint8_t, uint16_t, uint_fast8_t

// Bridge header (contains your wrapper declarations)
#include "lexbor_bridge.h"

// --- Explicit Lexbor Headers for Implementations ---
// Explicitly including all necessary headers for the functions used.
#include "lexbor/core/base.h" // For lxb_status_t, lxb_char_t, lexbor_free, lxb_ns_id_t
#include "lexbor/core/str.h"  // For lexbor_str_t, lexbor_str_destroy, lexbor_str_data_ncmp

#include "lexbor/html/parser.h" // For lxb_html_document_parse, lxb_html_document_parse_fragment
// #include "lexbor/html/document.h" // User states this doesn't exist. Remains commented.
#include "lexbor/html/tree.h"      // For lxb_html_tree_node_is
#include "lexbor/html/node.h"      // For lxb_html_node_is_void
#include "lexbor/html/serialize.h" // For lxb_html_serialize_tree_str

#include "lexbor/dom/interfaces/node.h"           // For lxb_dom_node_first_child, _next, _parent, _insert_child, _text_content
#include "lexbor/dom/interfaces/element.h"        // For lxb_dom_document_create_element, _qualified_name, _first_attribute, _next_attribute, _set_attribute, _get_attribute, _has_attribute
#include "lexbor/dom/interfaces/document.h"       // For lxb_dom_document_create_text_node, _create_comment, lxb_dom_interface_document
#include "lexbor/dom/interfaces/attr.h"           // For lxb_dom_attr_qualified_name, _value
#include "lexbor/dom/interfaces/character_data.h" // For lxb_dom_interface_character_data
#include "lexbor/dom/dom.h"                       // Often declares general DOM functions. Keep for now.

#include "lexbor/tag/tag.h" // For lxb_tag_name_by_id

// --- Wrapper Function Implementations ---

void lxb_dom_node_insert_child_wrapper(struct lxb_dom_node *to, struct lxb_dom_node *node)
{
  lxb_dom_node_insert_child(to, node);
}

struct lxb_dom_node *lxb_dom_node_first_child_wrapper(struct lxb_dom_node *node)
{
  return lxb_dom_node_first_child(node);
}

struct lxb_dom_node *lxb_dom_node_next_wrapper(struct lxb_dom_node *node)
{
  return lxb_dom_node_next(node);
}

struct lxb_dom_character_data *lxb_dom_interface_character_data_wrapper(struct lxb_dom_node *node)
{
  return lxb_dom_interface_character_data(node);
}

const unsigned char *lxb_dom_attr_value_wrapper(struct lxb_dom_attr *attr, size_t *len)
{
  return lxb_dom_attr_value(attr, len);
}

struct lxb_dom_element *lxb_dom_interface_element_wrapper(struct lxb_dom_node *node)
{
  return lxb_dom_interface_element(node);
}

const unsigned char *lxb_dom_element_qualified_name_wrapper(struct lxb_dom_element *element, size_t *len)
{
  return lxb_dom_element_qualified_name(element, len);
}

// Document functions
struct lxb_html_document *lxb_html_document_create_wrapper(void)
{
  lxb_html_document_t *document = lxb_html_document_create();
  if (document == NULL)
  {
    return NULL;
  }
  return document;
}

void lxb_dom_document_destroy_text_wrapper(struct lxb_dom_document *document, unsigned char *text)
{
  if (text != NULL)
  {
    lexbor_free(text);
  }
}

void lxb_html_document_destroy_wrapper(struct lxb_html_document *document)
{
  if (document != NULL)
  {
    lxb_html_document_destroy(document);
  }
}

uint_fast8_t lxb_html_document_parse_wrapper(struct lxb_html_document *document,
                                             const unsigned char *html, size_t size)
{
  return lxb_html_document_parse(document, html, size);
}

struct lxb_dom_node *lxb_html_document_parse_fragment_wrapper(struct lxb_html_document *document, struct lxb_dom_element *element, const unsigned char *html, size_t html_len)
{
  return lxb_html_document_parse_fragment(document, element, html, html_len);
}

struct lxb_dom_node *lxb_dom_node_parent_wrapper(struct lxb_dom_node *node)
{
  return lxb_dom_node_parent(node);
}

// Removed lxb_dom_node_type_wrapper as it's not found in your Lexbor build.
// unsigned int lxb_dom_node_type_wrapper(struct lxb_dom_node *node)
// {
//   return lxb_dom_node_type(node);
// }

const unsigned char *lxb_tag_name_by_id_wrapper(uint16_t tag_id, size_t *len_out)
{
  return lxb_tag_name_by_id(tag_id, len_out);
}

struct lxb_dom_element *lxb_dom_document_create_element_wrapper(struct lxb_dom_document *document,
                                                                const unsigned char *local_name,
                                                                size_t lname_len)
{
  return lxb_dom_document_create_element(document, local_name, lname_len, NULL);
}

struct lxb_dom_document *lxb_dom_interface_document_wrapper(struct lxb_html_document *document)
{
  if (document == NULL)
  {
    return NULL;
  }
  return &document->dom_document;
}

struct lxb_dom_node *lxb_dom_interface_node_wrapper(struct lxb_html_document *document)
{
  return lxb_dom_interface_node(document);
}

struct lxb_dom_attr *lxb_dom_element_first_attribute_wrapper(struct lxb_dom_element *element)
{
  return lxb_dom_element_first_attribute(element);
}

struct lxb_dom_attr *lxb_dom_element_next_attribute_wrapper(struct lxb_dom_attr *attr)
{
  return lxb_dom_element_next_attribute(attr);
}

const unsigned char *lxb_dom_attr_qualified_name_wrapper(struct lxb_dom_attr *attr, size_t *len)
{
  return lxb_dom_attr_qualified_name(attr, len);
}

// HTML Serialization Wrappers
void lxb_html_serialize_free_wrapper(char *str_to_free)
{
  if (str_to_free != NULL)
  {
    free(str_to_free);
  }
}

char *lxb_html_serialize_wrapper(struct lxb_dom_node *node, size_t *len)
{
  if (node == NULL || len == NULL)
    return NULL;

  lexbor_str_t str = {0};

  lxb_status_t status = lxb_html_serialize_tree_str(node, &str);
  if (status != LXB_STATUS_OK)
  {
    lexbor_str_destroy(&str, NULL, true);
    return NULL;
  }

  char *result = (char *)malloc(str.length + 1);
  if (result == NULL)
  {
    lexbor_str_destroy(&str, NULL, true);
    return NULL;
  }

  memcpy(result, str.data, str.length);
  result[str.length] = '\0';

  lexbor_str_destroy(&str, NULL, true);

  *len = str.length;
  return result;
}

void lxb_html_serialize_cleanup_wrapper(char *html_str)
{
  if (html_str != NULL)
  {
    free(html_str);
  }
}

struct lxb_dom_text *lxb_dom_document_create_text_node_wrapper(struct lxb_dom_document *document, const unsigned char *data, size_t size)
{
  return lxb_dom_document_create_text_node(document, data, size);
}

struct lxb_dom_comment *lxb_dom_document_create_comment_wrapper(struct lxb_dom_document *document, const unsigned char *data, size_t size)
{
  return lxb_dom_document_create_comment(document, data, size);
}

unsigned char *lxb_dom_node_text_content_wrapper(struct lxb_dom_node *node, size_t *len)
{
  return lxb_dom_node_text_content(node, len);
}

struct lxb_dom_attr *lxb_dom_element_set_attribute_wrapper(struct lxb_dom_element *element,
                                                           const unsigned char *qualified_name, size_t qn_len,
                                                           const unsigned char *value, size_t value_len)
{
  return lxb_dom_element_set_attribute(element, qualified_name, qn_len, value, value_len);
}

const unsigned char *lxb_dom_element_get_attribute_wrapper(struct lxb_dom_element *element,
                                                           const unsigned char *qualified_name, size_t qn_len,
                                                           size_t *value_len)
{
  return lxb_dom_element_get_attribute(element, qualified_name, qn_len, value_len);
}

bool lxb_dom_element_has_attribute_wrapper(struct lxb_dom_element *element,
                                           const unsigned char *qualified_name, size_t qn_len)
{
  return lxb_dom_element_has_attribute(element, qualified_name, qn_len);
}

bool lxb_html_tree_node_is_wrapper(struct lxb_dom_node *node, uint16_t tag_id)
{
  return lxb_html_tree_node_is(node, tag_id);
}

bool lxb_html_node_is_void_wrapper(struct lxb_dom_node *node)
{
  return lxb_html_node_is_void(node);
}

bool lexbor_str_data_ncmp_wrapper(const unsigned char *first, const unsigned char *second, size_t size)
{
  return lexbor_str_data_ncmp(first, second, size);
}

// --- NEW HELPER FUNCTION FOR CASTING ELEMENT TO NODE ---
struct lxb_dom_node *lxb_dom_element_as_node_wrapper(struct lxb_dom_element *element)
{
  if (element == NULL)
  {
    return NULL;
  }
  // This cast is safe and standard in C for struct embedding (element contains node as first member)
  return (struct lxb_dom_node *)element;
}
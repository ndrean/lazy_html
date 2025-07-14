#include "lexbor_bridge.h"
#include "lexbor/html/html.h"
#include "lexbor/dom/interfaces/character_data.h"
#include "lexbor/dom/interfaces/attr.h"

// Wrapper implementations for functions that have circular dependencies
// This bridges the gap between our simplified bridge header and the complex Lexbor API

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

lxb_dom_character_data_t *lxb_dom_interface_character_data_wrapper(lxb_dom_node_t *node)
{
  return lxb_dom_interface_character_data(node);
}

const uint8_t *lxb_dom_attr_value_wrapper(lxb_dom_attr_t *attr, size_t *len)
{
  return lxb_dom_attr_value(attr, len);
}

lxb_dom_element_t *lxb_dom_interface_element_wrapper(lxb_dom_node_t *node)
{
  return lxb_dom_interface_element(node);
}

const uint8_t *lxb_dom_element_qualified_name_wrapper(lxb_dom_element_t *element, size_t *len)
{
  return lxb_dom_element_qualified_name(element, len);
}

// Document functions
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

const uint8_t *lxb_dom_character_data_content_wrapper(lxb_dom_character_data_t *char_data, size_t *len)
{
  if (!char_data || !len)
    return NULL;
  *len = char_data->data.length;
  return char_data->data.data;
}

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

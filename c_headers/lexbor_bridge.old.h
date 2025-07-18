// #ifndef LEXBOR_BRIDGE_H
// #define LEXBOR_BRIDGE_H

// #include <stddef.h>  // For size_t
// #include <stdbool.h> //
// #include <stdint.h>

// // All Lexbor-specific includes are intentionally commented out here.
// // Their definitions will be handled by Zig's @cImport block directly.
// // #include "lexbor/html/interface.h"
// // #include "lexbor/core/base.h"
// // #include "lexbor/css/parser.h"
// // #include "lexbor/html/html.h"
// // #include "lexbor/css/selectors/selectors.h"
// // #include "lexbor/css/selectors/specificity.h"

// // Basic wrapper function declarations (removed duplicates for clarity)
// // These rely on types (lxb_html_document_t, lxb_dom_node_t, etc.)
// // that Zig's @cImport needs to pull from other Lexbor headers.
// extern lxb_html_document_t *lxb_html_document_create_wrapper(void);
// extern void lxb_html_document_destroy_wrapper(lxb_html_document_t *document);
// extern lxb_status_t lxb_html_document_parse_wrapper(lxb_html_document_t *document,
//                                                     const lxb_char_t *html, size_t size);
// extern lxb_dom_node_t *lxb_html_document_parse_fragment_wrapper(lxb_html_document_t *document,
//                                                                 lxb_dom_element_t *element,
//                                                                 const lxb_char_t *html, size_t size);

// extern lxb_dom_node_t *lxb_dom_node_first_child_wrapper(lxb_dom_node_t *node);
// extern lxb_dom_node_t *lxb_dom_node_next_wrapper(lxb_dom_node_t *node);

// extern lxb_dom_node_t *lxb_dom_interface_node_wrapper(lxb_html_document_t *document);
// extern lxb_dom_element_t *lxb_dom_document_create_element_wrapper(lxb_dom_document_t *document, const lxb_char_t *local_name, size_t lname_len);
// extern lxb_dom_element_t *lxb_dom_interface_element_wrapper(lxb_dom_node_t *node);
// extern const lxb_char_t *lxb_dom_element_qualified_name_wrapper(lxb_dom_element_t *element, size_t *len);
// extern lxb_dom_attr_t *lxb_dom_element_first_attribute_wrapper(lxb_dom_element_t *element);
// extern lxb_dom_attr_t *lxb_dom_element_next_attribute_wrapper(lxb_dom_attr_t *attr);
// extern const lxb_char_t *lxb_dom_attr_qualified_name_wrapper(lxb_dom_attr_t *attr, size_t *len);
// extern const uint8_t *lxb_dom_attr_value_wrapper(lxb_dom_attr_t *attr, size_t *len);
// extern lxb_dom_text_t *lxb_dom_document_create_text_node_wrapper(lxb_dom_document_t *document, const lxb_char_t *data, size_t size);
// extern lxb_dom_comment_t *lxb_dom_document_create_comment_wrapper(lxb_dom_document_t *document, const lxb_char_t *data, size_t size);
// extern lxb_dom_character_data_t *lxb_dom_interface_character_data_wrapper(lxb_dom_node_t *node);
// extern lxb_char_t *lxb_dom_node_text_content_wrapper(lxb_dom_node_t *node, size_t *len);
// extern void lxb_dom_document_destroy_text_wrapper(lxb_dom_document_t *document, lxb_char_t *text);
// extern lxb_dom_attr_t *lxb_dom_element_set_attribute_wrapper(lxb_dom_element_t *element, const lxb_char_t *qualified_name, size_t qn_len, const lxb_char_t *value, size_t value_len);
// extern const lxb_char_t *lxb_dom_element_get_attribute_wrapper(lxb_dom_element_t *element, const lxb_char_t *qualified_name, size_t qn_len, size_t *value_len);
// extern bool lxb_dom_element_has_attribute_wrapper(lxb_dom_element_t *element, const lxb_char_t *qualified_name, size_t qn_len);
// extern bool lxb_html_tree_node_is_wrapper(lxb_dom_node_t *node, lxb_tag_id_t tag_id);
// extern bool lxb_html_node_is_void_wrapper(lxb_dom_node_t *node);
// extern void lxb_dom_node_insert_child_wrapper(lxb_dom_node_t *to, lxb_dom_node_t *node);

// extern lxb_dom_document_t *lxb_dom_interface_document_wrapper(lxb_html_document_t *document);
// extern char *lxb_html_serialize_wrapper(lxb_dom_node_t *node, size_t *size);
// extern void lxb_html_serialize_free_wrapper(char *str_to_free);

// extern void lxb_html_serialize_cleanup_wrapper(char *html_str);
// extern bool lexbor_str_data_ncmp_wrapper(const lxb_char_t *first, const lxb_char_t *second, size_t size);
// extern const lxb_char_t *lxb_tag_name_by_id_wrapper(lxb_tag_id_t tag_id, size_t *len_out);

// // Constants for Zig compatibility (these are perfectly fine here)
// #define LXB_STATUS_OK_WRAPPER 0x00
// #define LXB_STATUS_ERROR_UNEXPECTED_DATA_WRAPPER 0x001A
// #define LXB_DOM_NODE_TYPE_TEXT_WRAPPER 3
// #define LXB_DOM_NODE_TYPE_ELEMENT_WRAPPER 1
// #define LXB_DOM_NODE_TYPE_COMMENT_WRAPPER 8
// #define LXB_TAG_STYLE_WRAPPER 80
// #define LXB_TAG_SCRIPT_WRAPPER 74
// #define LXB_TAG_XMP_WRAPPER 94
// #define LXB_TAG_IFRAME_WRAPPER 38
// #define LXB_TAG_NOEMBED_WRAPPER 54
// #define LXB_TAG_NOFRAMES_WRAPPER 55
// #define LXB_TAG_PLAINTEXT_WRAPPER 61
// #define LXB_TAG_TEMPLATE_WRAPPER 82
// #define LXB_NS_SVG_WRAPPER 0x02
// #define LEXBOR_ACTION_OK_WRAPPER 0x00

// #endif /* LEXBOR_BRIDGE_H */
#ifndef LEXBOR_BRIDGE_H
#define LEXBOR_BRIDGE_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

// Forward declarations - using void* to avoid type conflicts
typedef void lxb_html_document_t;
typedef void lxb_dom_document_t;
typedef void lxb_dom_node_t;
typedef void lxb_dom_element_t;
typedef void lxb_dom_attr_t;
typedef void lxb_dom_character_data_t;
typedef void lxb_dom_text_t;
typedef void lxb_dom_comment_t;
typedef void lxb_dom_document_fragment_t;
typedef void lxb_html_template_element_t;
typedef void lxb_css_parser_t;
typedef void lxb_css_selector_list_t;
typedef void lxb_selectors_t;
typedef void lxb_css_parser_state_t;
typedef void lxb_css_selector_specificity_t;
typedef unsigned int lxb_status_t;
typedef unsigned int lxb_tag_id_t;
typedef unsigned int lxb_selectors_opt_t;
typedef unsigned int lexbor_action_t;
typedef unsigned char lxb_char_t;

// Basic wrapper function declarations
extern lxb_html_document_t *lxb_html_document_create_wrapper(void);
extern void lxb_html_document_destroy_wrapper(lxb_html_document_t *document);
extern lxb_status_t lxb_html_document_parse_wrapper(lxb_html_document_t *document,
                                                    const lxb_char_t *html, size_t size);
extern lxb_dom_node_t *lxb_html_document_parse_fragment_wrapper(lxb_html_document_t *document,
                                                                lxb_dom_element_t *element,
                                                                const lxb_char_t *html, size_t size);

extern lxb_dom_node_t *lxb_dom_node_first_child_wrapper(lxb_dom_node_t *node);
extern lxb_dom_node_t *lxb_dom_node_next_wrapper(lxb_dom_node_t *node);
extern lxb_dom_node_t *lxb_dom_node_parent_wrapper(lxb_dom_node_t *node);
extern unsigned int lxb_dom_node_type_wrapper(lxb_dom_node_t *node);

extern lxb_dom_element_t *lxb_dom_document_create_element_wrapper(lxb_dom_document_t *document,
                                                                  const lxb_char_t *local_name,
                                                                  size_t lname_len,
                                                                  void *reserved_for_opt);
extern lxb_dom_document_t *lxb_dom_interface_document_wrapper(lxb_html_document_t *document);
extern lxb_dom_node_t *lxb_dom_interface_node_wrapper(lxb_html_document_t *document);
extern lxb_dom_element_t *lxb_dom_interface_element_wrapper(lxb_dom_node_t *node);
extern lxb_dom_character_data_t *lxb_dom_interface_character_data_wrapper(lxb_dom_node_t *node);

extern const lxb_char_t *lxb_dom_element_qualified_name_wrapper(lxb_dom_element_t *element, size_t *len);
extern lxb_dom_attr_t *lxb_dom_element_first_attribute_wrapper(lxb_dom_element_t *element);
extern lxb_dom_attr_t *lxb_dom_element_next_attribute_wrapper(lxb_dom_attr_t *attr);
extern const lxb_char_t *lxb_dom_attr_qualified_name_wrapper(lxb_dom_attr_t *attr, size_t *len);
extern const uint8_t *lxb_dom_attr_value_wrapper(lxb_dom_attr_t *attr, size_t *len);
extern const lxb_char_t *lxb_dom_character_data_data_wrapper(lxb_dom_character_data_t *character_data, size_t *len);
extern const uint8_t *lxb_dom_character_data_content_wrapper(lxb_dom_character_data_t *char_data, size_t *len);

// New DOM Document Functions
extern lxb_dom_text_t *lxb_dom_document_create_text_node_wrapper(lxb_dom_document_t *document,
                                                                 const lxb_char_t *data, size_t size);
extern lxb_dom_comment_t *lxb_dom_document_create_comment_wrapper(lxb_dom_document_t *document,
                                                                  const lxb_char_t *data, size_t size);

// New Interface Conversion Functions
extern lxb_dom_document_t *lxb_dom_interface_document_from_node_wrapper(lxb_dom_node_t *node);
extern lxb_html_template_element_t *lxb_html_interface_template_wrapper(lxb_dom_node_t *node);

// New Node Navigation and Manipulation Functions
extern lxb_dom_node_t *lxb_dom_node_insert_child_wrapper(lxb_dom_node_t *to, lxb_dom_node_t *node);
extern lxb_char_t *lxb_dom_node_text_content_wrapper(lxb_dom_node_t *node, size_t *len);

// New Element Functions
extern lxb_dom_attr_t *lxb_dom_element_set_attribute_wrapper(lxb_dom_element_t *element,
                                                             const lxb_char_t *qualified_name, size_t qn_len,
                                                             const lxb_char_t *value, size_t value_len);
extern const lxb_char_t *lxb_dom_element_get_attribute_wrapper(lxb_dom_element_t *element,
                                                               const lxb_char_t *qualified_name, size_t qn_len,
                                                               size_t *value_len);
extern bool lxb_dom_element_has_attribute_wrapper(lxb_dom_element_t *element,
                                                  const lxb_char_t *qualified_name, size_t qn_len);

// New HTML-specific Functions
extern bool lxb_html_tree_node_is_wrapper(lxb_dom_node_t *node, lxb_tag_id_t tag_id);
extern bool lxb_html_node_is_void_wrapper(lxb_dom_node_t *node);

// New Document Management (Memory)
extern void lxb_dom_document_destroy_text_wrapper(lxb_dom_document_t *document, lxb_char_t *text);

// New String Utility Functions
extern bool lexbor_str_data_ncmp_wrapper(const lxb_char_t *first, const lxb_char_t *second, size_t size);

// Helper Functions
extern lxb_tag_id_t lxb_dom_node_local_name_wrapper(lxb_dom_node_t *node);
extern uintptr_t lxb_dom_node_ns_wrapper(lxb_dom_node_t *node);
extern void lxb_dom_node_set_ns_wrapper(lxb_dom_node_t *node, uintptr_t ns);
extern lxb_dom_document_fragment_t *lxb_html_template_element_content_wrapper(lxb_html_template_element_t *template_element);
extern lxb_dom_node_t *lxb_dom_document_fragment_node_wrapper(lxb_dom_document_fragment_t *fragment);

// Constants (as macros for Zig compatibility)
#define LXB_STATUS_OK 0x0000
#define LXB_STATUS_ERROR_UNEXPECTED_DATA_WRAPPER 0x001A
#define LXB_DOM_NODE_TYPE_TEXT_WRAPPER 3
#define LXB_DOM_NODE_TYPE_ELEMENT_WRAPPER 1
#define LXB_DOM_NODE_TYPE_COMMENT_WRAPPER 8

// HTML Tag constants
#define LXB_TAG_STYLE_WRAPPER 80
#define LXB_TAG_SCRIPT_WRAPPER 74
#define LXB_TAG_XMP_WRAPPER 94
#define LXB_TAG_IFRAME_WRAPPER 38
#define LXB_TAG_NOEMBED_WRAPPER 54
#define LXB_TAG_NOFRAMES_WRAPPER 55
#define LXB_TAG_PLAINTEXT_WRAPPER 61
#define LXB_TAG_TEMPLATE_WRAPPER 82

// CSS Selector constants
#define LXB_SELECTORS_OPT_MATCH_FIRST_WRAPPER 0x01
#define LXB_SELECTORS_OPT_MATCH_ROOT_WRAPPER 0x02

// Namespace constants
#define LXB_NS_SVG_WRAPPER 0x02

// Lexbor action constants
#define LEXBOR_ACTION_OK_WRAPPER 0x00

// HTML Serialization Functions
char *lxb_html_serialize_wrapper(lxb_dom_node_t *node, size_t *size);
void lxb_html_serialize_cleanup_wrapper(char *html_str);

// Additional functions for HTML serialization
extern lxb_dom_document_fragment_t *lxb_html_template_content_wrapper(lxb_html_template_element_t *template_element);

#endif /* LEXBOR_BRIDGE_H */

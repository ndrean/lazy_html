#ifndef LEXBOR_BRIDGE_H
#define LEXBOR_BRIDGE_H

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

// --- FORWARD DECLARATIONS ONLY for Lexbor opaque struct types ---
struct lxb_html_document;
struct lxb_dom_node;
struct lxb_dom_document;
struct lxb_dom_element;
struct lxb_dom_attr;
struct lxb_dom_text;
struct lxb_dom_comment;
struct lxb_dom_character_data;
struct lexbor_str;

// --- Your C Wrapper Function Declarations (MUST MATCH lexbor_wrapper.c EXACTLY) ---
extern void lxb_dom_node_insert_child_wrapper(struct lxb_dom_node *to, struct lxb_dom_node *node);
extern struct lxb_dom_node *lxb_dom_node_first_child_wrapper(struct lxb_dom_node *node);
extern struct lxb_dom_node *lxb_dom_node_next_wrapper(struct lxb_dom_node *node);
extern struct lxb_dom_character_data *lxb_dom_interface_character_data_wrapper(struct lxb_dom_node *node);
extern const unsigned char *lxb_dom_attr_value_wrapper(struct lxb_dom_attr *attr, size_t *len);
extern struct lxb_dom_element *lxb_dom_interface_element_wrapper(struct lxb_dom_node *node);
extern const unsigned char *lxb_dom_element_qualified_name_wrapper(struct lxb_dom_element *element, size_t *len);
extern struct lxb_html_document *lxb_html_document_create_wrapper(void);
extern void lxb_dom_document_destroy_text_wrapper(struct lxb_dom_document *document, unsigned char *text);
extern void lxb_html_document_destroy_wrapper(struct lxb_html_document *document);
extern uint_fast8_t lxb_html_document_parse_wrapper(struct lxb_html_document *document, const unsigned char *html, size_t size);
extern struct lxb_dom_node *lxb_html_document_parse_fragment_wrapper(struct lxb_html_document *document, struct lxb_dom_element *element, const unsigned char *html, size_t html_len);
extern struct lxb_dom_node *lxb_dom_node_parent_wrapper(struct lxb_dom_node *node);

extern const unsigned char *lxb_tag_name_by_id_wrapper(uint16_t tag_id, size_t *len_out);
extern struct lxb_dom_element *lxb_dom_document_create_element_wrapper(struct lxb_dom_document *document, const unsigned char *local_name, size_t lname_len);
extern struct lxb_dom_document *lxb_dom_interface_document_wrapper(struct lxb_html_document *document);
extern struct lxb_dom_node *lxb_dom_interface_node_wrapper(struct lxb_html_document *document);
extern struct lxb_dom_attr *lxb_dom_element_first_attribute_wrapper(struct lxb_dom_element *element);
extern struct lxb_dom_attr *lxb_dom_element_next_attribute_wrapper(struct lxb_dom_attr *attr);
extern const unsigned char *lxb_dom_attr_qualified_name_wrapper(struct lxb_dom_attr *attr, size_t *len);
extern char *lxb_html_serialize_wrapper(struct lxb_dom_node *node, size_t *len);
extern void lxb_html_serialize_cleanup_wrapper(char *html_str);
extern struct lxb_dom_text *lxb_dom_document_create_text_node_wrapper(struct lxb_dom_document *document, const unsigned char *data, size_t size);
extern struct lxb_dom_comment *lxb_dom_document_create_comment_wrapper(struct lxb_dom_document *document, const unsigned char *data, size_t size);
extern unsigned char *lxb_dom_node_text_content_wrapper(struct lxb_dom_node *node, size_t *len);
extern struct lxb_dom_attr *lxb_dom_element_set_attribute_wrapper(struct lxb_dom_element *element, const unsigned char *qualified_name, size_t qn_len, const unsigned char *value, size_t value_len);
extern const unsigned char *lxb_dom_element_get_attribute_wrapper(struct lxb_dom_element *element, const unsigned char *qualified_name, size_t qn_len, size_t *value_len);
extern bool lxb_dom_element_has_attribute_wrapper(struct lxb_dom_element *element, const unsigned char *qualified_name, size_t qn_len);
extern bool lxb_html_tree_node_is_wrapper(struct lxb_dom_node *node, uint16_t tag_id);
extern bool lxb_html_node_is_void_wrapper(struct lxb_dom_node *node);
extern bool lexbor_str_data_ncmp_wrapper(const unsigned char *first, const unsigned char *second, size_t size);

extern struct lxb_dom_node *lxb_dom_element_as_node_wrapper(struct lxb_dom_element *element);

#endif // LEXBOR_BRIDGE_H
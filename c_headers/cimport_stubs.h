// c_headers/cimport_stubs.h
// This header is designed ONLY to help Zig's @cImport resolve circular dependencies.
// It should be included *before* any other Lexbor headers in your Zig @cImport block.

// Forward declarations for the structs involved in the selector function pointer.
// These are essential to allow the function pointer typedef below to be understood.
// Use 'struct' keyword to ensure they are treated as incomplete types.
struct lxb_selectors;
struct lxb_selectors_entry;

// Provide a precise typedef for the problematic function pointer.
// This tells Zig exactly what the type is without pulling in its full definition
// from the actual (problematic) Lexbor selectors header.
typedef struct lxb_selectors_entry *(*lxb_selectors_state_cb_f)(
    struct lxb_selectors *,
    struct lxb_selectors_entry *);
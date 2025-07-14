import Config

# We disable the extra newline in test env, because it breaks doctests.
config :lazy_html, :inspect_extra_newline, config_env() != :test

# Enable Zig backend for development and testing
# config :lazy_html, use_zigler_backend: true

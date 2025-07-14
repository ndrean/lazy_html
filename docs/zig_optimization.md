# Zig Compilation Configuration for LazyHTML

This document describes the compilation options used for building the Zig-based
HTML parser for optimal performance in production environments.

## Optimization Levels

### ReleaseFast (-O ReleaseFast)

- **Used in**: Production builds, precompiled NIFs
- **Benefits**: Maximum runtime performance
- **Trade-offs**: Larger binary size, longer compile time
- **Use case**: Distribution and production deployments

### ReleaseSmall (-O ReleaseSmall)

- **Alternative option** for size-constrained environments
- **Benefits**: Smaller binary size
- **Trade-offs**: Slightly slower runtime performance
- **Use case**: Embedded systems or size-critical deployments

### ReleaseSafe (-O ReleaseSafe)

- **Development option** with runtime safety checks
- **Benefits**: Better debugging, safety checks enabled
- **Trade-offs**: Slower runtime performance
- **Use case**: Development and testing

## Additional Optimization Flags

### -fstrip

- Removes debug symbols from the final binary
- Significantly reduces binary size
- Essential for production distribution

### -fno-stack-check

- Disables stack overflow protection
- Provides small performance improvement
- Safe for NIFs with controlled stack usage

### -fPIC (Position Independent Code)

- Required for shared libraries and NIFs
- Enables dynamic linking
- Standard requirement for Erlang NIFs

## Target Configuration

### native-native

- Compiles for the host architecture
- Enables all available CPU optimizations
- Optimal performance on the build machine

### Cross-compilation options

For distributing to different architectures:

- x86_64-linux-gnu
- aarch64-linux-gnu
- x86_64-windows-gnu
- x86_64-macos
- aarch64-macos

## Build Configurations by Use Case

### 1. Library Author Development

```make
zig build-lib src.zig -O ReleaseSafe -target native-native
```

### 2. Production Library Distribution

```make
zig build-lib src.zig -O ReleaseFast -fstrip -fno-stack-check -target native-native
```

### 3. Multi-platform Distribution

```bash
# Build for multiple targets
for target in x86_64-linux-gnu aarch64-linux-gnu x86_64-macos aarch64-macos; do
  zig build-lib src.zig -O ReleaseFast -fstrip -target $target
done
```

## Performance Characteristics

With ReleaseFast optimizations:

- **HTML parsing**: ~2-3x faster than Debug builds
- **Memory usage**: Optimized allocations and reduced overhead
- **Binary size**: ~40% larger than ReleaseSmall, ~60% smaller than Debug
- **Compile time**: ~2-3x longer than Debug builds

## Integration with Elixir/Erlang

The Zig NIF is compiled with:

- ERL*NIF*\* API compatibility
- Proper resource management
- BEAM allocator integration
- Exception-safe resource cleanup

## Distribution Strategy

1. **Development**: Use Zigler framework with ReleaseSafe
2. **CI/CD**: Build precompiled NIFs with ReleaseFast
3. **Package**: Include precompiled binaries for common platforms
4. **Fallback**: Provide C++ NIF as stable alternative

This ensures optimal performance while maintaining broad compatibility.

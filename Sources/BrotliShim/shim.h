#ifndef BrotliShim_h
#define BrotliShim_h

#if __has_include(<brotli/decode.h>)
    #include <brotli/decode.h>
#endif

#if __has_include(<brotli/encode.h>)
    #include <brotli/encode.h>
#endif

#if __has_include(<brotli/types.h>)
    #include <brotli/types.h>
#endif

#endif
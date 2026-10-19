# V8

> Embedded JavaScript and WebAssembly Engine for R

An R interface to V8: Google's open source JavaScript and WebAssembly
engine. This package can be compiled either with V8 version 6 and up or NodeJS
when built as a shared library.

Soft fork (renamed `v8n`) to avoid JSON serialization. Just so that you can have
both versions installed and use whichever you prefer. It is not intended to
replace the CRAN `V8` package.

Micro-benchmark on M1 Macbook Pro. `"jsonlite"` is what `"V8"` uses:
``` r
tmp <- tempfile(fileext = ".js")
curl::curl_download(
  url = "https://unpkg.com/underscore@1.13.7/underscore-min.js",
  destfile = tmp)

test <- function(backend = NULL, tmp = NULL) {
  ct <- V8n::v8(backend = backend)
  ct$source(tmp)
  ct$call("_.filter", nycflights13::flights, V8n::JS("function(x){return x.arr_delay > 720}"))
}

res <- microbenchmark::microbenchmark(
  test(backend = "native", tmp = tmp),
  test(backend = "jsonlite", tmp = tmp),
  times = 25, unit = "ms"
); res
#> Warning in microbenchmark::microbenchmark(test(backend = "native", tmp = tmp),
#> : less accurate nanosecond times to avoid potential integer overflows
#> Unit: milliseconds
#>                                   expr        min         lq       mean
#>    test(backend = "native", tmp = tmp)   56.62895   57.10136   64.40168
#>  test(backend = "jsonlite", tmp = tmp) 2274.30981 2355.88751 2450.18933
#>      median         uq        max neval
#>    68.34971   70.18064   77.75593    25
#>  2371.64988 2389.83162 4465.66162    25


test <- function(backend = NULL) {
  ct <- V8n::v8(backend = backend)
  ct$assign("flights", nycflights13::flights)
  ct$get("flights")
}

res <- microbenchmark::microbenchmark(
  test(backend = "native"),
  test(backend = "jsonlite"),
  times = 5, unit = "ms"
); res
#> Unit: milliseconds
#>                        expr       min        lq      mean    median        uq
#>    test(backend = "native")  180.5258  191.6021  196.1169  200.2754  201.2445
#>  test(backend = "jsonlite") 6667.8495 6732.6948 7076.6152 6922.6457 7147.1883
#>        max neval
#>   206.9368     5
#>  7912.6979     5
```



###

To see some quick examples in R run:

```r
library(V8n)
example(v8)
```

## Installation

```r
remotes::install_github("JanMarvin/V8", ref = "native_backend")
```

## Hello World

```r
# Create a new context
library(V8n)
ctx <- v8()

# Evaluate some code
ctx$eval("var foo = 123")
ctx$eval("var bar = 456")
ctx$eval("foo+bar")

# Assign / get objects
ctx$assign("foo", JS("function(x){return x*x}"))
ctx$assign("bar", JS("foo(9)"))
ctx$get("bar")
```

Call functions from JavaScript libraries

```r
ctx <- V8n::v8()
ctx$source("https://cdnjs.cloudflare.com/ajax/libs/coffee-script/1.4.0/coffee-script.min.js")
jscode <- ctx$call("CoffeeScript.compile", "square = (x) -> x * x", list(bare = TRUE))
ctx$eval(jscode)
ctx$call("square", 9)
```


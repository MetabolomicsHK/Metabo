# What is the cost of intermediate vector allocation?
library(Rcpp)
library(microbenchmark)

cppFunction("\n  NumericVector add2a(NumericVector a, NumericVector b) {\n    int n = a.size();\n    NumericVector out(n);\n    for (int i = 0; i < n; ++i) {\n      out[i] = a[i] + b[i];\n    }\n    return out;\n  }\n")

cppFunction("\n  NumericVector add3a(NumericVector a, NumericVector b, NumericVector c) {\n    int n = a.size();\n    NumericVector out(n);\n    for (int i = 0; i < n; ++i) {\n      out[i] = a[i] + b[i] + c[i];\n    }\n    return out;\n  }\n")

cppFunction("\n  NumericVector add4a(NumericVector a, NumericVector b, NumericVector c, NumericVector d) {\n    int n = a.size();\n    NumericVector out(n);\n    for (int i = 0; i < n; ++i) {\n      out[i] = a[i] + b[i] + c[i] + d[i];\n    }\n    return out;\n  }\n")

add2b <- function(a, b) a + b
add3b <- function(a, b, c) a + b + c
add4b <- function(a, b, c, d) a + b + c + d

x <- runif(1e+05)

stopifnot(all.equal(add2a(x, x), add2b(x, x)), all.equal(add3a(x, 
    x, x), add3b(x, x, x)), all.equal(add4a(x, x, x, x), add4b(x, 
    x, x, x)))

print(microbenchmark(add2a(x, x), add3a(x, x, x), add4a(x, x, x, 
    x), add2b(x, x), add3b(x, x, x), add4b(x, x, x, x), times = 1000))
# Unit: microseconds expr min lq median uq max neval add2a(x,
# x) 140.4 153 161 173 1307 1000 add3a(x, x, x) 161.8 175 185
# 198 20921 1000 add4a(x, x, x, x) 191.4 207 217 232 20783 1000
# add2b(x, x) 90.8 100 106 115 20949 1000 add3b(x, x, x) 192.9
# 215 229 909 21513 1000 add4b(x, x, x, x) 297.9 337 375 1148
# 21226 1000 

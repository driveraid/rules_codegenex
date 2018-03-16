load("//tools/nugget:defs.bzl", "cc_nugget_library")

cc_nugget_library(
    name = "fish",
    nuggets = ["fish.nugget", "shark.nugget"],
    nugget_deps = [":cod"],
    visibility = ["//visibility:public"]
)

cc_nugget_library(
    name = "cod",
    nuggets = ["cod.nugget"],
)
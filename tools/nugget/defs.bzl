_NUGGET_RULE_SUFFIX = ".nr"
_NUGGET_FILE_SUFFIX = ".nugget"

def _nugget_compile(ctx, unit):
  #
  # Do something real here perhaps? :)
  #
  outputs = []
  for nugget in unit.nuggets:
    output = ctx.actions.declare_file(nugget.basename + ".cc")
    ctx.template_action(
        template = unit.template,
        output = output,
        substitutions = {
          "%{operation}": unit.operation,
          "%{argument}": unit.argument_for_operation,
          "%{nugget}": '// {}'.format(nugget.path),
          "%{nugget_fn}": nugget.basename.split(".")[0],
          "%{nuggets}": '\n'.join(["// {}".format(nugget.path) for nugget in unit.nuggets]),
          "%{commented_transitive_nuggets}": '\n'.join(["// {}".format(nugget.path)
                                                        for subunit in unit.transitive_units
                                                        for nugget in subunit.nuggets]),
          "%{commented_dependent_nuggets}": '\n'.join(["// {}".format(nugget.path)
                                                       for subunit in unit.dependent_units
                                                       for nugget in subunit.nuggets]),
          "%{sum_dependent_nuggets_fn}": "".join([" + {}()".format(nugget.basename.split('.')[0])
                                                  for subunit in unit.dependent_units
                                                  for nugget in subunit.nuggets]),
          "%{fwddecl_dependent_nuggets}": "\n".join(["int {}();".format(nugget.basename.split('.')[0])
                                                     for subunit in unit.dependent_units
                                                     for nugget in subunit.nuggets]),
        }
    )
    outputs.append(output)
  #
  # End/Do something real here perhaps? :)
  #
  return outputs


def _nugget_compile_rule_impl(ctx):
  # Transitives & deps handling
  transitive_units = [unit
                      for dep in ctx.attr.nugget_deps
                      for unit in dep.nugget_compile_result.transitive_units]
  dependent_units = [dep.nugget_compile_result.unit
                     for dep in ctx.attr.nugget_deps]

  # Create a description for everything affecting this compilation unit
  # Both direct dependencies and transitive dependencies are stored
  unit = struct(
      template = ctx.file._template,
      operation = ctx.attr.operation,
      argument_for_operation = ctx.attr.argument_for_operation,
      nuggets = ctx.files.nuggets,
      transitive_units = transitive_units,
      dependent_units = dependent_units,
  )

  # Perform compilation
  outputs = _nugget_compile(ctx, unit)

  return struct(
    files = depset(outputs),
    nugget_compile_result = struct(
      unit = unit,
      transitive_units = transitive_units + [unit],
    )
  )


_nugget_compile_rule = rule(
  implementation = _nugget_compile_rule_impl,
  attrs = {
    "_template": attr.label(
        default = "//tools/nugget:nugget.cc.tpl",
        allow_single_file = True
    ),
    "nuggets": attr.label_list(
        allow_files = [_NUGGET_FILE_SUFFIX]
    ),
    "nugget_deps": attr.label_list(
        providers = ["nugget_compile_result"]
    ),
    "argument_for_operation": attr.string(),
    "operation": attr.string()
  },
  output_to_genfiles = True
)


def cc_nugget_library(name, srcs=None, deps=None, nuggets=None, nugget_deps=None, visibility=None, **kwargs):
  srcs = srcs or []
  nugget_deps = nugget_deps or []
  nuggets = nuggets or []
  visibility = visibility or []
  deps = deps or []

  _nugget_compile_rule(
    name = name + _NUGGET_RULE_SUFFIX,
    nuggets = nuggets,
    nugget_deps = [dep + _NUGGET_RULE_SUFFIX for dep in nugget_deps],   # NOTE! this makes select impossible but it's
                                                                        # the approach chosen in rules_protobuf
    argument_for_operation = name + _NUGGET_RULE_SUFFIX,
    operation = "gen.cc",
    visibility = visibility
  )

  native.cc_library(
    name = name,
    srcs = srcs + [name + _NUGGET_RULE_SUFFIX],
    deps = deps + nugget_deps,
    visibility = visibility,
    **kwargs
  )
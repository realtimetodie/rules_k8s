"""This module implements the kubectl toolchain rule.
"""

KubectlInfo = provider(
    doc = "Information about how to invoke the kubectl executable.",
    fields = {
        "bin": "Executable kubectl binary",
    },
)

def _kubectl_toolchain_impl(ctx):
    binary = ctx.executable.kubectl
    template_variables = platform_common.TemplateVariableInfo({
        "KUBECTL_BIN": binary.path,
    })
    default = DefaultInfo(
        files = depset([binary]),
        runfiles = ctx.runfiles(files = [binary]),
    )
    kubectl_info = KubectlInfo(bin = binary)
    toolchain_info = platform_common.ToolchainInfo(
        kubectl_info = kubectl_info,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]


kubectl_toolchain = rule(
    implementation = _kubectl_toolchain_impl,
    attrs = {
        "kubectl": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    doc = """Defines a kubectl toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)

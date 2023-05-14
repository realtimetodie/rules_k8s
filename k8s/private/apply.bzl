"Implementation details for the apply rule"

load("@aspect_bazel_lib//lib:platform_utils.bzl", "platform_utils")
load("@aspect_bazel_lib//lib:windows_utils.bzl", "create_windows_native_launcher_script")
load("@rules_oci//oci:defs.bzl", "RepositoryInfo")

_DOC = """Apply a configuration to a resource.

```starlark
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_push")
load("//k8s:defs.bzl", "kubectl_apply")

oci_image(
    name = "image",
    architecture = "amd64",
    entrypoint = ["/example"],
    os = "linux",
)

oci_push(
    name = "push_image",
    image = ":image",
    remote_tags = ["v1"],
    repository = "index.docker.io:9899/janedoe/awesomeapp",
)

kubectl_apply(
    name = "pod",
    images = [":push_image"],
    manifest = "pod.yaml",
)
```

When running the pusher, you can pass options:

- Override `registry`; `-r|--registry` flag. e.g. `bazel run //example:pod -- --registry index.docker.io/janedoe`

See the kubectl help for more options when using the apply command

```
kubectl apply --help
```
"""

_attrs = {
    "data": attr.label_list(
        allow_files = True,
        doc = "Runtime dependencies of the program.",
    ),
    "images": attr.label_list(
        doc = "Additional images to resolve in the template",
    ),
    "manifest": attr.label(
        doc = "The manifest that contains the configuration to apply in YAML format.",
        allow_single_file = True,
    ),
    "_launcher_template": attr.label(
        default = Label("//k8s/private:kubectl.sh.tpl"),
        allow_single_file = True,
    ),
    "_resolve_template": attr.label(
        default = Label("//k8s/private:resolve.sh.tpl"),
        allow_single_file = True,
    ),
}

def _expand_image_to_args(image, _):
    repositoryinfo = image[RepositoryInfo]
    
    return ["--image=%s;%s" % (repositoryinfo.registry, repositoryinfo.name)]

def _impl(ctx):
    k8s_toolchain = ctx.toolchains["@rules_k8s//k8s:toolchain_type"]
    yq_toolchain = ctx.toolchains["@aspect_bazel_lib//lib:yq_toolchain_type"]

    files = ctx.files.data[:]

    bash_resolver = ctx.actions.declare_file("%s_resolver.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = ctx.file._resolve_template,
        output = bash_resolver,
        substitutions = {
            "{{yq_path}}": yq_toolchain.yqinfo.bin.path,
        },
        is_executable = True,
    )

    resolved_manifest = ctx.actions.declare_file(ctx.label.name + "_resolved.%s" % ctx.file.manifest.extension)

    args = ctx.actions.args()
    args.add(ctx.file.manifest.short_path, format = "--input=%s")
    args.add(resolved_manifest.path, format = "--output=%s")
    args.add_all(ctx.attr.images, map_each = _expand_image_to_args, expand_directories = False)

    ctx.actions.run(
        inputs = [ctx.file.manifest],
        outputs = [resolved_manifest],
        arguments = [args],
        tools = [yq_toolchain.yqinfo.bin],
        progress_message = "Resolving template %s" % resolved_manifest.short_path,
        executable = bash_resolver,
    )

    files.append(resolved_manifest)

    bash_launcher = ctx.actions.declare_file("%s_launcher.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = ctx.file._launcher_template,
        output = bash_launcher,
        substitutions = {
            "{{kubectl_path}}": k8s_toolchain.kubectl_info.bin.path,
            "{{command}}": "apply",
            "{{options}}": "--filename=\"%s\"" % resolved_manifest.short_path,
        },
        is_executable = True,
    )

    is_windows = platform_utils.host_platform_is_windows()
    launcher = create_windows_native_launcher_script(ctx, bash_launcher) if is_windows else bash_launcher

    runfiles = ctx.runfiles(files = files)
    runfiles = runfiles.merge(k8s_toolchain.default.default_runfiles)
    runfiles = runfiles.merge_all([
        target[DefaultInfo].default_runfiles
        for target in ctx.attr.data
    ])

    return DefaultInfo(
        executable = launcher,
        runfiles = runfiles,
    )

kubectl_apply_lib = struct(
    attrs = _attrs,
    implementation = _impl,
    toolchains = [
        "@aspect_bazel_lib//lib:yq_toolchain_type",
        "@bazel_tools//tools/sh:toolchain_type",
        "@rules_k8s//k8s:toolchain_type",
    ],
)

kubectl_apply = rule(
    doc = _DOC,
    implementation = kubectl_apply_lib.implementation,
    attrs = kubectl_apply_lib.attrs,
    toolchains = kubectl_apply_lib.toolchains,
    executable = True,
)

# Declare the local Bazel workspace.
# This is *not* included in the published distribution.
workspace(name = "rules_k8s")

load(":internal_deps.bzl", "rules_k8s_internal_deps")

# Fetch deps needed only locally for development
rules_k8s_internal_deps()

load("//k8s:dependencies.bzl", "rules_k8s_dependencies")

# Fetch our "runtime" dependencies which users need as well
rules_k8s_dependencies()

load("//k8s:repositories.bzl", "KUBECTL_LATEST_VERSION", "k8s_register_toolchains")

k8s_register_toolchains(
    name = "default_k8s",
    kubectl_version = KUBECTL_LATEST_VERSION,
)

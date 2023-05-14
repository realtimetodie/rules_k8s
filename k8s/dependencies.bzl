"""Starlark helper to fetch rules_swc dependencies.

Should be replaced by bzlmod for users of Bazel 6.0 and above.
"""

load("//k8s/private:maybe.bzl", http_archive = "maybe_http_archive")

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
def rules_k8s_dependencies():
    http_archive(
        name = "bazel_skylib",
        sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
        url = "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "97fa63d95cc9af006c4c7b2123ddd2a91fb8d273012f17648e6423bae2c69470",
        strip_prefix = "bazel-lib-1.30.2",
        url = "https://github.com/aspect-build/bazel-lib/releases/download/v1.30.2/bazel-lib-v1.30.2.tar.gz",
    )

    http_archive(
        name = "rules_oci",
        sha256 = "08d73a9bec22642ee12c0a38c23596cbddaba7422eede74edba3bb1044d579be",
        strip_prefix = "rules_oci-1.0.0-rc0",
        url = "https://github.com/bazel-contrib/rules_oci/releases/download/v1.0.0-rc0/rules_oci-v1.0.0-rc0.tar.gz",
    )

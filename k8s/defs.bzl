"""
To load these rules, add this to the top of your `BUILD` file:

```starlark
load("@rules_k8s//k8s:defs.bzl", ...)
```
"""

load("//k8s/private:apply.bzl", _kubectl_apply = "kubectl_apply")

kubectl_apply = _kubectl_apply

<!-- Generated with Stardoc: http://skydoc.bazel.build -->


To load these rules, add this to the top of your `BUILD` file:

```starlark
load("@rules_k8s//k8s:defs.bzl", ...)
```


<a id="kubectl_apply"></a>

## kubectl_apply

<pre>
kubectl_apply(<a href="#kubectl_apply-name">name</a>, <a href="#kubectl_apply-data">data</a>, <a href="#kubectl_apply-images">images</a>, <a href="#kubectl_apply-manifest">manifest</a>)
</pre>

Apply a configuration to a resource.

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


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="kubectl_apply-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="kubectl_apply-data"></a>data |  Runtime dependencies of the program.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="kubectl_apply-images"></a>images |  Additional images to resolve in the template   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="kubectl_apply-manifest"></a>manifest |  The manifest that contains the configuration to apply in YAML format.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |



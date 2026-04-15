"""Compatibility repository rule for forwarding to an apt hub sysroot target."""

def _sysroot_repository_impl(rctx):
    flat = rctx.attr.flat
    apt_repo_name = flat.workspace_name

    if not apt_repo_name:
        fail("flat must point to a target in an external apt hub repository, got {}".format(flat))

    rctx.file(
        "BUILD.bazel",
        """alias(
    name = \"sysroot\",
    actual = \"@@{}//:sysroot\",
    visibility = [\"//visibility:public\"],
)
""".format(apt_repo_name),
    )

    if hasattr(rctx, "repo_metadata"):
        return rctx.repo_metadata(reproducible = True)
    return None

sysroot_repository = repository_rule(
    implementation = _sysroot_repository_impl,
    attrs = {
        "flat": attr.label(
            mandatory = True,
            doc = "Label to a target in the apt hub repository (for example @ubuntu24_04//:flat). The repository forwards to the hub repo's :sysroot target.",
        ),
    },
)

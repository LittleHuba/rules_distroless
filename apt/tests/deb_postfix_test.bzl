"tests for deb_postfix"

load("//apt/private:deb_postfix.bzl", "deb_postfix")
load("//distroless/tests:asserts.bzl", "assert_tar_listing")

_TEST_SUITE_PREFIX = "deb_postfix/"


def deb_postfix_tests():
    native.genrule(
        name = "_deb_postfix_mergedusr_data",
        outs = ["deb_postfix_data.tar"],
        cmd = """
#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

tmpdir=$$(mktemp -d)
bsdtar="$$(pwd)/$(BSDTAR_BIN)"
out="$$(pwd)/$@"
trap 'rm -rf "$$tmpdir"' EXIT

mkdir -p "$$tmpdir/bin" "$$tmpdir/sbin" "$$tmpdir/lib" "$$tmpdir/usr/share/doc"
: > "$$tmpdir/bin/tool"
: > "$$tmpdir/sbin/helper"
: > "$$tmpdir/lib/libfoo.so"
: > "$$tmpdir/usr/share/doc/keep"

cd "$$tmpdir"
"$$bsdtar" -cf "$$out" ./bin ./sbin ./lib ./usr
""",
        toolchains = ["@bsd_tar_toolchains//:resolved_toolchain"],
    )

    deb_postfix(
        name = "_deb_postfix_mergedusr_layer",
        srcs = [":_deb_postfix_mergedusr_data"],
        outs = ["deb_postfix_layer.tar.gz"],
        mergedusr = True,
    )

    assert_tar_listing(
        name = _TEST_SUITE_PREFIX + "mergedusr",
        actual = ":_deb_postfix_mergedusr_layer",
        expected = """\
./usr/bin/tool
./usr/sbin/helper
./usr/lib/libfoo.so
./usr/
./usr/share/
./usr/share/doc/
./usr/share/doc/keep
""",
    )

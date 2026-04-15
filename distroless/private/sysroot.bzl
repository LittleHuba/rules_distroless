"Extract a tar archive into a directory tree."

load(":tar.bzl", "tar_lib")

_DOC = """Materialize an input tar archive as a directory tree."""


def _sysroot_from_tar_impl(ctx):
    bsdtar = ctx.toolchains[tar_lib.TOOLCHAIN_TYPE]
    output = ctx.actions.declare_directory(ctx.label.name)

    ctx.actions.run_shell(
        inputs = [ctx.file.tar],
        outputs = [output],
        tools = [bsdtar.default.files],
        arguments = [
            output.path,
            ctx.file.tar.path,
            bsdtar.tarinfo.binary.path,
        ],
        command = """mkdir -p "$1" && "$3" --extract --file "$2" --directory "$1" --no-same-owner --no-same-permissions""",
        mnemonic = "MaterializeSysroot",
        progress_message = "Materializing %{label}",
    )

    return [DefaultInfo(files = depset([output]))]


sysroot_from_tar = rule(
    doc = _DOC,
    implementation = _sysroot_from_tar_impl,
    attrs = {
        "tar": attr.label(
            allow_single_file = tar_lib.common.accepted_tar_extensions,
            mandatory = True,
            doc = "Tar archive to unpack into the output directory.",
        ),
    },
    toolchains = [tar_lib.TOOLCHAIN_TYPE],
)

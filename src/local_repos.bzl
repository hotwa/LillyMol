def _local_repos_impl(module_ctx):
    module_ctx.download_and_extract(
        name = "python",
        path = "/opt/conda/envs/lillymol/include/python3.10",
        build_file_content = """
cc_library(
    name = "python",
    hdrs = glob(["**/*.h"]),
    includes = ["."],
    visibility = ["//visibility:public"],
)
    """,
    )

local_repos = module_extension(
    implementation = _local_repos_impl,
)

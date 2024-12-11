# load("@rules_python_pytest//python_pytest:defs.bzl", "py_pytest_test")
# load("@rules_python//python:py_test.bzl", "py_test")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "lillymol_pybind",
    srcs = [
        "lillymol_pybind.cc",
    ],
    copts = [
        "-save-temps",
    ],
    deps = [
        ":molecule",
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
        "//Molecule_Tools:alogp_lib",
        "//Molecule_Tools:xlogp_lib",
        "@pybind11",
        "@python",
#       "@third_party//:python",
    ],
)

cc_shared_library(
    name = "lillymol",
    shared_lib_name = "lillymol.so",
    deps = [
        ":lillymol_pybind",
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
    ],
)

cc_library(
    name = "lillymol_pybind_fingerprints",
    srcs = [
        "lillymol_pybind_fingerprint.cc",
    ],
    deps = [
        ":molecule",
        "//Molecule_Lib:atom_pair_fingerprint",
        "//Molecule_Lib:iwmfingerprint",
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:linear_fingerprint",
        "//Molecule_Lib:moleculeio",
        "//Molecule_Tools:ec_fingerprint_lib",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_fingerprint",
    shared_lib_name = "lillymol_fingerprint.so",
    deps = [
        ":lillymol_pybind_fingerprints",
    ],
)

cc_library(
    name = "lillymol_pybind_substructure_query",
    srcs = [
        "lillymol_pybind_query.cc",
    ],
    deps = [
        ":molecule",
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_query",
    shared_lib_name = "lillymol_query.so",
    deps = [
        ":lillymol_pybind_substructure_query",
    ],
)

cc_library(
    name = "lillymol_pybind_chemical_standardisation",
    srcs = [
        "lillymol_pybind_std.cc",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_standardise",
    shared_lib_name = "lillymol_standardise.so",
    deps = [
        ":lillymol_pybind_chemical_standardisation",
    ],
)

cc_library(
    name = "lillymol_pybind_set_of_atoms",
    srcs = [
        "lillymol_pybind_set_of_atoms.cc",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_set_of_atoms",
    shared_lib_name = "lillymol_set_of_atoms.so",
    deps = [
        ":lillymol_pybind_set_of_atoms",
    ],
)

cc_library(
    name = "lillymol_pybind_ring",
    srcs = [
        "lillymol_pybind_ring.cc",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_ring",
    shared_lib_name = "lillymol_ring.so",
    deps = [
        ":lillymol_pybind_ring",
    ],
)

cc_library(
    name = "lillymol_pybind_atom",
    srcs = [
        "lillymol_pybind_atom.cc",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_atom",
    shared_lib_name = "lillymol_atom.so",
    deps = [
        ":lillymol_pybind_atom",
    ],
)

cc_library(
    name = "lillymol_pybind_bond",
    srcs = [
        "lillymol_pybind_bond.cc",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_bond",
    shared_lib_name = "lillymol_bond.so",
    deps = [
        ":lillymol_pybind_bond",
    ],
)

#cc_library(
#    name = "lillymol_pybind_chiral_centre",
#    srcs = [
#        "lillymol_pybind_chiral_centre.cc",
#    ],
#    deps = [
#        "//Molecule_Lib:iwmolecule",
#        "//Molecule_Lib:moleculeio",
#        "@pybind11",
#        "@python",
#    ],
#)

#cc_shared_library(
#  name = "lillymol_chiral_centre",
#  deps = [
#      ":lillymol_pybind_chiral_centre",
#  ],
#  shared_lib_name = "lillymol_chiral_centre.so",
#)

cc_library(
    name = "lillymol_pybind_io",
    srcs = [
        "lillymol_pybind_io.cc",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_io",
    shared_lib_name = "lillymol_io.so",
    deps = [
        ":lillymol_pybind_io",
    ],
)

cc_library(
    name = "molecule",
    srcs = [
        "molecule.cc",
    ],
    hdrs = [
        "molecule.h",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:moleculeio",
    ],
)

cc_shared_library(
    name = "molecule_shared",
    shared_lib_name = "lillymol_molecule_misc.so",
    deps = [
        ":molecule",
    ],
)

cc_library(
    name = "lillymol_pybind_reaction",
    srcs = [
        "lillymol_pybind_reaction.cc",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:iwreaction",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_reaction",
    shared_lib_name = "lillymol_reaction.so",
    deps = [
        ":lillymol_pybind_reaction",
    ],
)

cc_library(
    name = "tsubstructure",
    srcs = [
        "lillymol_pybind_tsubstructure.cc",
        "tsubstructure.cc",
    ],
    hdrs = [
        "tsubstructure.h",
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:iwreaction",
        "//Molecule_Lib:moleculeio",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "tsubstructure_shared",
    shared_lib_name = "lillymol_tsubstructure.so",
    deps = [
        ":tsubstructure",
    ],
)

cc_library(
    name = "lillymol_tools",
    srcs = [
        "lillymol_pybind_tools.cc",
    ],
    hdrs = [
    ],
    deps = [
        "//Molecule_Lib:iwmolecule",
        "//Molecule_Lib:iwreaction",
        "//Molecule_Lib:moleculeio",
        "//Molecule_Tools:dicer_api",
        "//Molecule_Tools:nvrtspsa",
        "//Molecule_Tools:unique_molecules_api",
        "//Molecule_Tools_Bdb:iwecfp_database_lookup_lib_shared",
        "//Molecule_Tools_Bdb:selimsteg",
        "//Molecule_Tools_Bdb:structure_database_shared",
        "@third_party//:berkeley_shared",
        "@pybind11",
        "@python",
    ],
)

cc_shared_library(
    name = "lillymol_tools_shared",
    shared_lib_name = "lillymol_tools.so",
    deps = [
        ":lillymol_tools",
    ],
)

# Cannot figure out how to make this work. TODO:ianwatson
#py_test(
#    name = "test_lillymol",
#    size = "small",
#    srcs = ["lillymol_test.py"],
#    deps = [
#      ":lillymol_pybind",
#    ],
#)

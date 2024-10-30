#ifndef MOLECULE_TOOLS_MINOR_CHANGES_H
#define MOLECULE_TOOLS_MINOR_CHANGES_H

#include <iostream>
#include <memory>
#include <string>

#define RESIZABLE_ARRAY_IMPLEMENTATION

#include "Foundational/accumulator/accumulator.h"
#include "Foundational/cmdline/cmdline.h"
#include "Foundational/data_source/iwstring_data_source.h"
#include "Foundational/iwaray/iwaray.h"
#include "Foundational/iwstring/iwstring.h"
#include "Foundational/iwstring/iw_stl_hash_set.h"

#include "Molecule_Lib/atom_typing.h"
#include "Molecule_Lib/etrans.h"
#include "Molecule_Lib/iwreaction.h"
#include "Molecule_Lib/molecule.h"
#include "Molecule_Lib/standardise.h"

#ifdef BUILD_BAZEL
#include "Molecule_Tools/dicer_fragments.pb.h"
#include "Molecule_Tools/minor_changes.pb.h"
#else
#include "dicer_fragments.pb.h"
#include "minor_changes.pb.h"
#endif

namespace minor_changes {

class MoleculeData;

// We can add fragments.

class Fragment {
  private:
    Molecule _m;

    atom_number_t _attach;

    uint32_t _atype;

    // Read from the `n` value in the proto.
    uint32_t _number_exemplars;

  // Private functions.
    // Tests whether this fragment has an isotopic atom with a Hydrogen atom.
    int OkForJoining() const;

  public:
    Fragment();

    // Likely DicerFragment protos from get_substituents.
    int Build(const_IWSubstring buffer, uint32_t min_support);

    const Molecule& mol() const {
      return _m;
    }
    Molecule& mol() {
      return _m;
    }

    atom_number_t attachment_point() const {
      return _attach;
    }

    // The attachment point will be discerned from the isotopic information.
    int BuildFromSmiles(const dicer_data::DicerFragment& proto);

    int number_exemplars() const {
      return _number_exemplars;
    }
};

// A fragment with two attachment points.
class BivalentFragment {
  private:
    Molecule _m;

    // Two attachment points
    atom_number_t _attach1;
    atom_number_t _attach2;

    // The number of bonds between the attachment points - if used as
    // a replacement fragment.
    int _bonds_between;

    // Two atom types - same order as _attach1, _attach2
    uint32_t _atype1;
    uint32_t _atype2;

    int _number_exemplars;

  // Private functions.

    int OkForJoining() const;

  public:
    BivalentFragment();

    // Likely DicerFragment protos from get_substituents.
    // Must have two isotopes holding atom types.
    int Build(const_IWSubstring buffer, uint32_t min_support);

    int BuildFromSmiles(const dicer_data::DicerFragment& proto);

    const Molecule& mol() const {
      return _m;
    }
    Molecule& mol() {
      return _m;
    }

    atom_number_t attach1() const {
      return _attach1;
    }
    atom_number_t attach2() const {
      return _attach2;
    }
    uint32_t atype1() const {
      return _atype1;
    }
    uint32_t atype2() const {
      return _atype2;
    }

    int bonds_between() const {
      return _bonds_between;
    }

    int number_exemplars() const {
      return _number_exemplars;
    }
};

// A class that holds all the information needed for the
// application. The idea is that this should be entirely
// self contained. If it were moved to a separate header
// file, then unit tests could be written and tested
// separately.
class Options {
  private:
    int _verbose = 0;

    // The first time we are invoked, we need to do some
    // checks on the startup conditions.
    bool _first_call;

    int _reduce_to_largest_fragment = 0;

    // When reading fragments, we can strip chirality.
    int _remove_chirality = 0;

    Chemical_Standardisation _chemical_standardisation;

    // Not a part of all applications, just an example...
    Element_Transformations _element_transformations;

    Atom_Typing_Specification _atom_typing;

    int _molecules_read = 0;

    int _molecules_generated;

    int _invalid_valence;

    // If only some atoms are to be processed, they can be
    // specified via queries.
    resizable_array_p<Substructure_Query> _only_process_query;

    // Known fragments can be added.
    resizable_array_p<Fragment> _fragment;

    // External fragments can be inserted.
    // These can have either 1 or 2 isotopes.
    resizable_array_p<Fragment> _monovalent_fragment;
    resizable_array_p<BivalentFragment> _bivalent_fragment;

    // Scaffold only reactions that can be applied.
    resizable_array_p<IWReaction> _reaction;

    // We do not generate duplicate molecules.
    IW_STL_Hash_Set _seen;

    // We keep track of how many variants are generated by
    // each molecule.
    extending_resizable_array<int> _variants_generated;

    // Optional behaviours controlled by the config proto.
    // Read from the command line via the -C option.
    minor_changes_data::MinorChangesData _config;
    // If the config file contains reactions or queries, we might
    // need the path name.
    IWString _config_fname;

    // It can be informative to keep track of how productive
    // each of the transformations is.
    Accumulator_Int<uint32_t>* _acc;

    // Each transformation needs an index into the _acc array.
    // Keep the same numbering as in the proto.
    // As values are added, make sure the array in Options::Report is updated.
    enum TransformationType {
      kUnknown = 0,
      kAddFragments = 2,
      kReplaceTerminalFragments = 3,
      kSingleToDoubleBond = 4,
      kDoubleToSingleBond = 5,
      kUnspiro = 6,
      kMakeThreeMemberedRings = 7,
      kChangeCarbonToNitrogen = 8,
      kChangeCarbonToOxygen = 9,
      kChangeNitrogenToCarbon = 10,
      kInsertCH2 = 11,
      kRemoveCH2 = 12,
      kDestroyAromaticRings = 13,
      kDestroyAromaticRingSystems = 14,
      kSwapAdjacentAtoms = 15,
      kRemoveFragment = 16,
      kInsertFragments = 23,
      kReplaceInnerFragments = 24,
      kRemoveFusedArom = 25,
      kReaction = 28,

      // This must be the last entry.
      kHighest = 29,
    };

  // private functions.
    int ReadFragment(const_IWSubstring& buffer);
    int ReadFragments(const_IWSubstring& fname);
    int ReadFragments(iwstring_data_source& input);
    int ReadBivalentFragment(const_IWSubstring& buffer);
    int ReadBivalentFragments(const_IWSubstring& fname);
    int ReadBivalentFragments(iwstring_data_source& input);
    int ReadFragmentsFromConfig();

    int ReadFileOfReactions(const std::string& fname);
    int ReadFileOfReactions(iwstring_data_source& input, const IWString& dirname);
    int ReadReaction(const IWString& buffer, const IWString& dirname);
    int ReadReactionInner(IWString& fname, const IWString& dirname);

    int SetupOnlyProcessQuery(const std::string& qry);
    int SetupOnlyProcessQueries();

    int ReadOptions(const_IWSubstring& fname);
    int ReadOptions(iwstring_data_source& input);

    int AnythingSpecified() const;
    int CheckConditions();

    int GeneratedEnough(const resizable_array_p<Molecule>& results) const;

    int DetermineChangingAtoms(Molecule& m, MoleculeData& molecule_data);

    int Seen(Molecule& m);
    int AddToResultsIfNew(std::unique_ptr<Molecule>& m,
                           resizable_array_p<Molecule>& result);

    int SingleToDoubleBond(Molecule& m,
                           const MoleculeData& molecule_data,
                           resizable_array_p<Molecule>& results);
    int DoubleToSingleBond(Molecule& m,
                           const MoleculeData& molecule_data,
                           resizable_array_p<Molecule>& results);

    int OkLowerBondOrder(Molecule& m,
                  const MoleculeData& molecule_data,
                  const Bond* b) const;

    int ChangeCarbonToNitrogen(Molecule& m,
                               const MoleculeData& molecule_data,
                               resizable_array_p<Molecule>& results);
    int ChangeCarbonToOxygen(Molecule& m,
                              MoleculeData& molecule_data,
                              resizable_array_p<Molecule>& results);
    int ChangeNitrogenToCarbon(Molecule& m,
                              MoleculeData& molecule_data,
                              resizable_array_p<Molecule>& results);
    int ChangeSubstituentToHalogen(Molecule& m,
                              MoleculeData& molecule_data,
                              resizable_array_p<Molecule>& results);
    int RemoveCh2(Molecule& m,
                   const MoleculeData& molecule_data,
                   resizable_array_p<Molecule>& results);
    int InsertCh2(Molecule& m,
                   MoleculeData& molecule_data,
                   resizable_array_p<Molecule>& results);
    int DestroyAromaticRings(Molecule& m,
                              MoleculeData& molecule_data,
                              resizable_array_p<Molecule>& results);
    int DestroyAromaticRingSystems(Molecule& m,
                              MoleculeData& molecule_data,
                              resizable_array_p<Molecule>& results);
    int MakeThreeRing(Molecule& m,
                        MoleculeData& molecule_data,
                        resizable_array_p<Molecule>& results);
    int RemoveFragments(Molecule& m,
                        MoleculeData& molecule_data,
                        resizable_array_p<Molecule>& results);
    int RemoveFragment(Molecule& m,
               atom_number_t a1,
               atom_number_t a2,
               resizable_array_p<Molecule>& results);

    int SwapAdjacentAtoms(Molecule& m,
                           MoleculeData& molecule_data,
                           resizable_array_p<Molecule>& results);
    int SwapAdjacentAtoms(Molecule& m,
                           MoleculeData& molecule_data,
                           atom_number_t a0,
                           atom_number_t a1,
                           atom_number_t a2,
                           atom_number_t a3,
                           resizable_array_p<Molecule>& results);
    int Unspiro(Molecule& m,
                 MoleculeData& molecule_data,
                 resizable_array_p<Molecule>& results);
    int AddFragments(Molecule& m,
                 MoleculeData& molecule_data,
                 resizable_array_p<Molecule>& results);
    int ReplaceTerminalFragments(Molecule& m,
                 MoleculeData& molecule_data,
                 resizable_array_p<Molecule>& results);
    int InsertBivalentFragments(Molecule& m,
                 MoleculeData& molecule_data,
                 resizable_array_p<Molecule>& results);
    int InsertBivalentFragment(const Molecule& m,
                 const MoleculeData& molecule_data,
                 atom_number_t a1,
                 atom_number_t a2,
                 BivalentFragment& frag,
                 resizable_array_p<Molecule>& results);
    int Process(Molecule& m,
                 MoleculeData& molecule_data,
                 resizable_array_p<Molecule>& results);
    int OkAtomTypes(Molecule& m,
            const MoleculeData& molecule_data,
            atom_number_t a1,
            atom_number_t a2,
            const BivalentFragment& frag) const;
    int ReplaceInnerFragments(Molecule& m,
                 MoleculeData& molecule_data,
                 resizable_array_p<Molecule>& results);
    int ReplaceInnerFragment(const Molecule& m,
                              atom_number_t a1,
                              atom_number_t a2,
                              int* shortest_path,
                              const BivalentFragment& frag,
                              resizable_array_p<Molecule>& results);
    int PerformReaction(Molecule& m,
                        MoleculeData& molecule_data,
                        IWReaction& rxn,
                        resizable_array_p<Molecule>& results);
    int RemoveFusedAromatics(Molecule& m,
                            MoleculeData& molecule_data,
                            resizable_array_p<Molecule>& results);
    int RemoveFusedRing(Molecule& m, MoleculeData& molecule_data,
                         int r1number, int r2number,
                         int* in_ring,
                         resizable_array_p<Molecule>& results);
    int RemoveFusedRing(Molecule& m,
                const Ring& ring,
                atom_number_t c1, atom_number_t c2,
                const Set_of_Atoms& anchor,
                Set_of_Atoms& conn,
                resizable_array_p<Molecule>& results);
    int RemoveFusedRing1(std::unique_ptr<Molecule>& m,
                          atom_number_t to_be_removed,
                          atom_number_t c1, atom_number_t c2,
                          atom_number_t exocyclic,
                          resizable_array_p<Molecule>& results);
    int RemoveFusedRing2(std::unique_ptr<Molecule>& m,
                          atom_number_t to_be_removed,
                          atom_number_t c1, atom_number_t c2,
                          atom_number_t exocyclic1, atom_number_t exocyclic2,
                          resizable_array_p<Molecule>& results);

  public:
    Options();
    ~Options();

    int verbose() const {
      return _verbose;
    }

    // Get user specified command line directives.
    int Initialise(Command_Line& cl);

    // Copies to _config and determines what is to be done.
    int SetConfig(const minor_changes_data::MinorChangesData & c);

    // After each molecule is read, but before any processing
    // is attempted, do any preprocessing transformations.
    int Preprocess(Molecule& m);

    // Make variants of `mol` and place in `results`.
    // returns the number if items generated if successful, may be zero.
    // Returns a negative value upon an internal failure.
    int Process(Molecule& mol, resizable_array_p<Molecule>& results);

    // After processing, report a summary of what has been done.
    int Report(std::ostream& output) const;
};


}  // namespace minor_changes

#endif // MOLECULE_TOOLS_MINOR_CHANGES_H

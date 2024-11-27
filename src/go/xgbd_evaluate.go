// Evaluate an xgboost model built with xgbd_make.rb

package main

import(
  "flag"
  "fmt"
  "os"
  "path/filepath"
  pb "xgboost_lib"
  "google.golang.org/protobuf/proto"
)

func usage(rc  int) {
  os.Exit(rc)
}

func main () {
  var mdir string
  var help bool
  var verbose bool

  flag.StringVar (&mdir,             "mdir", "", "Model directory - created by xgbd_make")
  flag.BoolVar   (&help,             "help",     false,     "display help message")
  flag.BoolVar   (&verbose,          "v",     false, "verbose output")

  flag.Parse()

  if len(mdir) == 0 {
    fmt.Fprintln(os.Stderr, "Must specify directory to process with the --mdir option")
    usage(1)
  }

  if 0 == len(flag.Args()) {
    fmt.Fprintln(os.Stderr, "Must specify test set file to process, either smiles or descriptors")
    usage(1)
  }

  if help {
    usage(1)
  }

  metadata_fname := filepath.Join(mdir, "model_metadata.txt")
  data,err := os.ReadFile(metadata_fname)
  if err != nil {
    fmt.Println("Cannot read model metadata %s", metadata_fname)
    os.Exit(1)
  }

  metadata := &xgboost_model.XGBoostModel{};
  if err := proto.Unmarshall(data, metadata); err != nil {
    log.Fatalf("Failed to unmarshal data: %v", err)
  }
}

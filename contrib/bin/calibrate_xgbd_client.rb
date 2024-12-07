#!/usr/bin/env ruby

require 'fileutils'

# Client script for model_calibrate. Builds and scores xgboost models
# using xgbd_make and xgbd_evaluate.

require_relative 'lib/iwcmdline'

def usage(rc)
  exit(rc)
end

def main
  cl = IWCmdline.new("-v-DESC=sfile-TRactivity=sfile-TEactivity=sfile-PRED=s-STATS=s-TMPDIR=s-uid=s")

  unless cl.option_present('DESC')
    $stderr << "Must specify descriptor file via the -DESC option\n"
    usage(1)
  end

  unless cl.option_present('TRactivity')
    $stderr << "Must specify training set activity file via the -TRactivity option\n"
    usage(1)
  end

  unless cl.option_present('TEactivity')
    $stderr << "Must specify testing set activity file via the -TEactivity option\n"
    usage(1)
  end

  unless cl.option_present('PRED')
    $stderr << "Must specify predicted values file via the -PRED option\n"
    usage(1)
  end

  unless cl.option_present('STATS')
    $stderr << "Must specify statistics file via the -STATS option\n"
    usage(1)
  end


  if cl.option_present('TMPDIR')
    tmpdir = cl.value('TMPDIR')
  elsif cl.option_present('uid')
    uid = cl.value('uid')
    tmpdir = "/tmp/calibrate_#{uid}"
  else
    $stderr << "Must specify either -TMPDIR or unique identifier via the -uid option\n"
    usage(1)
  end

  Dir.mkdir(tmpdir) unless File.directory?(tmpdir)

  if cl.unrecognised_options_encountered
    $stderr << "Unrecognised options encountered\n"
    usage(1)
  end

  verbose = cl.option_present('v')

  descriptors = cl.value('DESC')
  train_activity = cl.value('TRactivity')
  test_activity = cl.value('TEactivity')

  predicted = cl.value('PRED')

  results = cl.value('STATS')

  tmptrain = File.join(tmpdir, "train.dat")
  tmptest = File.join(tmpdir, "test.dat")
  mdir = File.join(tmpdir, 'MODEL')

  cmd = "descriptor_file_select_rows #{train_activity} #{descriptors} > #{tmptrain}"
  system(cmd)
  cmd = "descriptor_file_select_rows #{test_activity} #{descriptors} > #{tmptest}"
  system(cmd)

  cmd = "xgbd_make.sh --mdir #{mdir} --activity #{train_activity} #{tmptrain}"
  system(cmd)

  cmd = "xgboost_model_evaluate.sh -mdir #{mdir} #{tmptest} > #{predicted}"
  system(cmd)

  cmd = "iwstats -w -Y allequals -E #{test_activity} -p 2 #{predicted} > #{results}"
  system(cmd)

  FileUtils.rm_rf(tmpdir)

  File.unlink(tmptrain)
  File.unlink(tmptest)
end

main

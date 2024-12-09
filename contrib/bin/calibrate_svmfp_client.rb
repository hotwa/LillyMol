#!/usr/bin/env ruby
#!/usr/bin/env ruby

require 'fileutils'

# Client script for model_calibrate. Builds and scores svmfp models
# using svmfp_make and svmfp_evaluate.

require_relative 'lib/iwcmdline'

def usage(rc)
  exit(rc)
end

def main
  cl = IWCmdline.new("-v-gfp=close-TRSMI=sfile-TESMI=sfile-TRactivity=sfile-TEactivity=sfile-PRED=s-STATS=s-TMPDIR=s-uid=s")

  unless cl.option_present('gfp')
    $stderr << "Must specify fingerprints via the -gfp option\n"
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

  trsmi = cl.value('TRSMI')
  tesmi = cl.value('TESMI')

  Dir.mkdir(tmpdir) unless File.directory?(tmpdir)

  if cl.unrecognised_options_encountered
    $stderr << "Unrecognised options encountered\n"
    usage(1)
  end

  verbose = cl.option_present('v')

  lillymol_home = ENV['LILLYMOL_HOME']
  svmfp_make = "#{lillymol_home}/contrib/bin/svmfp/svmfp_make.sh"
  svmfp_evaluate = "#{lillymol_home}/contrib/bin/svmfp/svmfp_evaluate.sh"

  gfp = cl.value('gfp')
  train_activity = cl.value('TRactivity')
  test_activity = cl.value('TEactivity')

  predicted = cl.value('PRED')

  results = cl.value('STATS')

  mdir = File.join(tmpdir, 'MODEL')

  cmd = "#{svmfp_make} --mdir #{mdir} -gfp #{gfp} -gfp -A #{train_activity} #{trsmi}"
  system(cmd)

  cmd = "#{svmfp_evaluate} -mdir #{mdir} #{tesmi} > #{predicted}"
  system(cmd)

  cmd = "iwstats -w -Y allequals -E #{test_activity} -p 2 #{predicted} > #{results}"
  system(cmd)

  FileUtils.rm_rf(tmpdir)
end

main

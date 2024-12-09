#!/usr/bin/env ruby
# 
require_relative 'lib/iwcmdline'

def usage(rc)
  exit(rc)
end

class TTSplit
  attr_accessor :train_smi, :train_activity, :test_smi, :test_activity
  def initialize(trs, tra, tes, tea)
    @train_smi = trs
    @train_activity = tra
    @test_smi = tes
    @test_activity = tea
  end
end

def read_fingerprints(fnames)
  result = []
  fnames.each do |fname|
    File.readlines(fname).each do |line|
      line.chomp!
      next if line.empty?
      next if line[0] == '#'
      result << line.chomp
    end
  end

  result
end

# For each of `niter` splits, look for the appropriate train/test and
# smi/activity files and if present, create a TTSplit object.
# Return an Array of the TTSplit objects found
def gather_split_files(train_stem, test_stem, niter)
  result = []
  (0...niter).each do |i|
    train_smi = "#{train_stem}#{i}.smi"
    train_activity = "#{train_stem}#{i}.activity"
    test_smi = "#{test_stem}#{i}.smi"
    test_activity = "#{test_stem}#{i}.activity"
    break unless File.file?(train_smi)
    break unless File.file?(train_activity)
    break unless File.file?(test_smi)
    break unless File.file?(test_activity)
    result << TTSplit.new(train_smi, train_activity, test_smi, test_activity)
  end

  result
end

def make_splits(smiles, activity, niter, trpct)
  cmd = "stratified_samples -v -E TEST -R TRAIN -N #{niter} -p #{trpct} -s 1 -S .activity -M #{smiles}  #{activity}"
  unless system(cmd)
    $stderr << "#{cmd} failed\n"
    return []
  end

  return gather_split_files('TRAIN', 'TEST', niter)
end

def main
  cl = IWCmdline.new("-v-A=sfile-S=s-niter=ipos-TRpct=ipos--fp=sfile-appendfp=sfile-DESC=s-PRED=s")

  if cl.unrecognised_options_encountered
    $stderr << "Unrecognised options encountered\n"
    usage(1)
  end

  verbose = cl.option_present('v')

  unless cl.option_present('A')
    $stderr << "Must specify name of activity file via the -A option\n"
    usage(1)
  end

  activity_fname = cl.value('A')

  unless cl.option_present('fp')
    $stderr << "Must specify one or more fingerprint files via the -fp option\n"
    usage(1)
  end

  fingerprints = read_fingerprints(cl.values('fp'))

  $stderr << "Read #{fingerprints.size} fingerprints\n"

  if ARGV.empty?
    $stderr << "No smiles specified\n"
    usage(1)
  end

  if ARGV.size > 1
    $stderr << "Takes just a single argument - the smiles file\n"
    usage(1)
  end

  smiles = ARGV[0]

  niter = if cl.option_present('niter')
            cl.value('niter')
          else
            10
          end

  $stderr << "Will generate #{niter} splits\n" if verbose

  trpct = if cl.option_present('TRpct')
            cl.value('TRpct')
          else
            80
          end

  stats_stem = "A#{trpct}"

  predicted_stem = if cl.option_present('PRED')
                     cl.value('PRED')
                   else
                     'PRED'
                   end

  splits = make_splits(smiles, activity_fname, niter, trpct)
  if splits.empty?
    $stderr << "Split generation failed\n";
  end

  descriptor_files = []
  cl.values('DESC').each do |desc|
    g = Dir.glob(desc)
    if g.empty?
      $stderr << "Descriptor file glob #{desc} no matches\n"
      return 1
    end
    descriptor_files.concat(g)
  end

  $stderr << "Processing #{descriptor_files.size} descriptor files\n" if verbose
  $stderr << descriptor_files << "\n"

  command_file = "model_calibrate.txt"
  write_command_file(splits, descriptor_files, fingerprints, predicted_stem, stats_stem, command_file)

  0
end

def write_command_file(splits, descriptor_files, fingerprints, predicted_stem, stats_stem, command_file)
  $stderr << "Writing #{splits.size} splits with #{fingerprints.size} fingerprints\n"
  file = File.open(command_file, "w")
  fingerprints.each do |fp|
    fptxt = fp.gsub(' ', "")
    splits.each_with_index do |split, ndx|
      file << "calibrate_svmfp_client.sh -gfp #{fp} -gfp " +
              "-TRSMI #{split.train_smi} -TRactivity #{split.train_activity} " +
              "-TESMI #{split.test_smi} -TEactivity #{split.test_activity} " +
              "-PRED #{predicted_stem}.#{fptxt}.#{ndx} -STATS #{stats_stem}.#{fptxt}.#{ndx} " +
              "-uid SVMFP#{fptxt}" +
              "\n"
      $stderr << "Wrote #{fp} split #{ndx}\n"
    end
  end

  descriptor_files.each_with_index do |dfile, dfile_ndx|
    splits.each_with_index do |split, ndx|
      file << "calibrate_xgbd_client.sh -DESC #{dfile} " +
              "-TRactivity #{split.train_activity} " +
              "-TEactivity #{split.test_activity} " +
              "-PRED #{predicted_stem}.DSC.#{dfile_ndx} -STATS #{stats_stem}.DSC.#{dfile_ndx}.#{ndx} " +
              "-uid #{dfile_ndx}.#{ndx}" +
              "\n"
    end
  end

  file.close
end

main

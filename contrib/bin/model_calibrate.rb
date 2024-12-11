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

class Makefile
  def initialize(fname)
    @file = File.open(fname, "w")
    @targets = []
    @dependencies = []
    @commands = []
  end
  def another_target(target, dependency, cmd)
    @targets << target.gsub(/:/, "\\:")
    @dependencies << dependency
    @commands << cmd
  end
  def write
    @file << "all:\n"
    @file << "	"
    @targets.each_with_index do |target, ndx|
      @file << ' ' if ndx > 0
      @file << "#{target}"
    end
    @file << "\n"

    @targets.each_with_index do |target, ndx|
      @file << "#{target}: #{@dependencies[ndx]}\n"
      @file << "	#{@commands[ndx]}"
    end
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
# If niter is set, we look for that many files.
# If niter comes in as zero, we search for files
def gather_split_files(train_stem, test_stem, niter)
  niter = 100000 if niter.zero?

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
  cl = IWCmdline.new("-v-A=sfile-S=s-niter=ipos-TRpct=ipos--fp=sfile-appendfp=sfile-DESC=s-PRED=s-PS=s")

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

  $stderr << "Read #{fingerprints.size} fingerprints\n" if verbose

  if ARGV.empty?
    $stderr << "No smiles specified\n"
    usage(1)
  end

  if ARGV.size > 1
    $stderr << "Takes just a single argument - the smiles file\n"
    usage(1)
  end

  smiles = ARGV[0]

  if cl.option_present('PS')
    if cl.option_present('TRpct')
      $stderr << "Warning, training set percent -TRpct not meaningful with previously split files\n"
    end
    splits = gather_split_files('TRAIN', 'TEST', 0)  # 0 arg means look for files already there.
    if splits.empty?
      $stderr << "Did not find any pre-split files (-PS)\n"
      return 1
    end
    niter = splits.size
    $stderr << "Found #{niter} pre split splits\n" if verbose
  else
    niter = if cl.option_present('niter')
              niter = cl.value('niter')
            else
              niter = 10
            end

    $stderr << "Will generate #{niter} splits\n" if verbose

    splits = make_splits(smiles, activity_fname, niter, trpct)
    if splits.empty?
      $stderr << "Split generation failed\n";
    end
  end

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

  descriptor_files = []
  cl.values('DESC').each do |desc|
    g = Dir.glob(desc.split(','))
    if g.empty?
      $stderr << "Descriptor file glob #{desc} no matches\n"
      return 1
    end
    descriptor_files.concat(g)
  end

  $stderr << "Processing #{descriptor_files.size} descriptor files\n" if verbose
  $stderr << descriptor_files << "\n"

  makefile = Makefile.new("Makefile.calibrate")

  command_file = "model_calibrate.txt"
  write_command_file(splits, descriptor_files, fingerprints, predicted_stem, stats_stem, makefile, command_file)

  makefile.write

  0
end

def write_command_file(splits, descriptor_files, fingerprints, predicted_stem,
                       stats_stem, makefile, command_file)
  $stderr << "Writing #{splits.size} splits with #{fingerprints.size} fingerprints\n"
  file = File.open(command_file, "w")
  fingerprints.each do |fp|
    fptxt = fp.gsub(' ', "")
    $stderr << "Writing #{fp}\n"
    splits.each_with_index do |split, ndx|
      stats_file = "#{stats_stem}.#{fptxt}.#{ndx}"
      cmd = ""
      cmd << "calibrate_svmfp_client.sh -gfp #{fp} -gfp " +
              "-TRSMI #{split.train_smi} -TRactivity #{split.train_activity} " +
              "-TESMI #{split.test_smi} -TEactivity #{split.test_activity} " +
              "-PRED #{predicted_stem}.#{fptxt}.#{ndx} -STATS #{stats_file} " +
              "-uid SVMFP#{fptxt}.#{ndx}" +
              "\n"
      file << cmd
      makefile.another_target(stats_file, "#{split.train_smi}", cmd)
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

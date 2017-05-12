MRuby::Toolchain.new(:afl) do |conf, _params|
  toolchain :gcc # Use gcc as a baseline

  [conf.cc, conf.objc, conf.asm].each do |cc|
    cc.command = ENV['CC'] || 'afl-clang-fast'
  end
  conf.cxx.command = ENV['CXX'] || 'afl-clang-fast++'
  conf.linker.command = ENV['LD'] || 'afl-clang-fast'
  conf.cc.defines << %w(MRB_GC_STRESS)
end

MRuby::Build.new do |conf|
  # load specific toolchain settings
  toolchain :afl

  # Enable below for AddressSanitizer-support.
#conf.cc.flags << '-fsanitize=address -fno-omit-frame-pointer -fPIC'
#conf.linker.flags << '-fsanitize=address -fno-omit-frame-pointer -fPIC'

  enable_debug
  conf.gembox 'default'
end

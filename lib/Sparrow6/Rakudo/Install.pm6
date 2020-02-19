use v6;

unit module Sparrow6::Rakudo::Install;

use Sparrow6::DSL;

our sub tasks (%args) {

  # --------------------------- Variables -------------------------------------------- #
  
  my $user = %args<user>;
  my $rakudo-version = %args<rakudo-version>;
  my $path-to-raku = "/tmp/whateverable/rakudo-moar/$rakudo-version";
  my $path-to-zef = "/home/$user/zef";
  
  # --------------------------- Install Rakudo $rakudo-version ------------------------ #
  
  say "Start Rakudo install, version {$rakudo-version}";
  
  package-install ('wget', 'zstd');
  
  directory "/data/whateverable/", %(
    mode => '755'
  );
  
  unless "/data/whateverable/{$rakudo-version}".IO ~~ :f {
  
    bash "cd /data/whateverable/ && wget -q https://whateverable.6lang.org/{$rakudo-version}", %(
      description => "download https://whateverable.6lang.org/{$rakudo-version}"
    )
  
  }
  
  bash "cd /data/whateverable/ && zstd -dqc -- $rakudo-version | tar -x --absolute-names", %(
      description => "unpack {$rakudo-version}"
  );
  

  # --------------------------- Install Zef ------------------------ #

  say "Installing zef for {$user}";
  
  directory $path-to-zef, %(
    owner => $user
  );
  
  
  git-scm "https://github.com/ugexe/zef.git", %(
    to => $path-to-zef,
    user => $user,
  );

  
  bash "cd {$path-to-zef} && {$path-to-raku}/bin/perl6 -I . bin/zef install . --/test", %(
    description => "Installing zef for user {$user}",
    user => $user,
    debug => False
  );

  # --------------------------- Set $user environment  ------------------------ #

  say "Set user environment";

  file "/home/$user/.rakudoenv.bash", %(
    content => "export PATH={$path-to-raku}:~/.perl6/bin:~/.raku/bin/:\$PATH",
    owner => $user,
    group => $user
  );
  
  bash "cat /home/$user/.rakudoenv.bash >> /home/$user/.bash_profile", %(
    description => "patch user $user .bash_profile with rakudo env"
  );
  
  file-delete "/home/$user/.rakudoenv.bash";
  

  # --------------------------- Dump Rakudo environment  ------------------------ #

  say "Dump Rakudo environment";

  bash "which perl6", %(
    description => "which perl6",
    user => $user,
    debug => True
  );
  
  bash "which zef", %(
    description => "which zef",
    user => $user,
    debug => True
  );
  
  bash "perl6 --version", %(
    description => "perl6 version",
    user => $user,
    debug => True
  );
  
  bash "zef --version", %(
    description => "zef version",
    user => $user,
    debug => True
  );
  

  return

}

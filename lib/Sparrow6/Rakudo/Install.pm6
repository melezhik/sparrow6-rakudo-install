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
  

  say "Installing zef for {$user}";
  
  directory $path-to-zef, %(
    owner => $user
  );
  
  
  git-scm "https://github.com/ugexe/zef.git", %(
    to => $path-to-zef,
    user => $user,
  );

  
  bash "cd {$path-to-zef} && {$path-to-raku}/bin/perl6 -I . bin/zef install .", %(
    description => "Installing zef for user {$user}",
    user => $user,
    debug => True
  );

  # return altered PATH so that a user can start using installed Rakudo and zef

  return "{$path-to-raku}/bin:/home/$user/.perl6/bin:/home/$user/.raku/bin"

}

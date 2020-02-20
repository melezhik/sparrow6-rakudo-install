use v6;

unit module Sparrow6::Rakudo::Install;

use Sparrow6::DSL;


sub dump-rakudo-env (Str $user) {


    say "... Dump Rakudo environment ...";
  
    bash "which perl6", %(
      description => "which perl6",
      user => $user,
      debug => False
    );
    
    bash "which zef", %(
      description => "which zef",
      user => $user,
      debug => False
    );
    
    bash "perl6 --version", %(
      description => "perl6 version",
      user => $user,
      debug => False,
    );
    
    bash "zef --version", %(
      description => "zef version",
      user => $user,
      debug => False,
    );

}

sub set-user-env(Str $user, Str $path-to-raku?){

  say "... Set user environment ...";

  if ($path-to-raku) {

    file "/home/$user/.rakudoenv.bash", %(
      content => "export PATH={$path-to-raku}:~/.perl6/bin:~/.raku/bin/:\$PATH",
      owner => $user,
      group => $user
    );

  } else {

    file "/home/$user/.rakudoenv.bash", %(
      content => "export PATH=~/.perl6/bin:~/.raku/bin/:\$PATH",
      owner => $user,
      group => $user
    );
  
  }

  bash "cat /home/$user/.rakudoenv.bash >> /home/$user/.bash_profile", %(
    description => "patch user $user .bash_profile with rakudo env"
  );

  file-delete "/home/$user/.rakudoenv.bash";

}

our sub tasks (%args) {

  # --------------------------- Variables -------------------------------------------- #
  
  my $user = %args<user>;
  my $rakudo-version = %args<rakudo-version>;
  my $path-to-raku = "/tmp/whateverable/rakudo-moar/$rakudo-version";
  my $path-to-zef = "/home/$user/zef";


  if $rakudo-version eq "default" {

    say "... Using default Rakudo ...";

    set-user-env($user);

    dump-rakudo-env($user);
    
  } elsif os() eq 'debian' {

    say "... Installing Whateverable Rakudo is not supported on ", os(), " using default Rakudo ...";

    set-user-env($user);

    dump-rakudo-env($user);
    
  } else {

  		# --------------------------- Install Rakudo $rakudo-version ------------------------ #
		
  		say "<<< Rakudo Install, version {$rakudo-version} >>>";  
		
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
		
  		say "... Installing zef for user ...";
  		
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
		
		
		
  		set-user-env($user);
		
		
  		dump-rakudo-env($user);

  }
  

  
  return

}


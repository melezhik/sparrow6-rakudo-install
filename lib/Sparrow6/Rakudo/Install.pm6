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

sub set-user-env(Str $user, Bool $patch-profile = True, Str $path-to-raku? ){

  say "... Set user environment ...";

  my $home = %*ENV<HOME> // "/home/$user";

  if ($path-to-raku) {

    file "$home/.rakudoenv.bash", %(
      content => "export PATH={$path-to-raku}:~/.perl6/bin:~/.raku/bin/:\$PATH",
      owner => $user,
      group => $user
    );

  } else {

    file "$home/.rakudoenv.bash", %(
      content => "export PATH=~/.perl6/bin:~/.raku/bin/:\$PATH",
      owner => $user,
      group => $user
    );
  
  }

  if $patch-profile {

    if os() eq "alpine" {

      bash "cat $home/.rakudoenv.bash >> $home/.profile", %(
        description => "patch user $user .profile with rakudo env"
      );

    } else {

      bash "cat $home/.rakudoenv.bash >> $home/.bash_profile", %(
        description => "patch user $user .bash_profile with rakudo env"
      );

    }


    file-delete "$home/.rakudoenv.bash";

  } else {

    say "you are all set, to use new rakudo:";

    say "$home/.rakudoenv.bash".IO.slurp;

  }

}

our sub tasks (%args) {

  # --------------------------- Variables -------------------------------------------- #
  
  my $user = %args<user>;
  my $home = %*ENV<HOME> // "/home/$user";
  my $rakudo-version = %args<rakudo-version>;
  my $path-to-raku = "/tmp/whateverable/rakudo-moar/$rakudo-version";
  my $path-to-zef = "$home/zef";
  my $install-zef = %args<skip-zef> ?? False !! True;

  task-run "install glibc", "alpine-glibc-install" if os() eq "alpine";

  if $rakudo-version eq "default" {

    say "... Using default Rakudo ...";

    set-user-env($user,%args<patch-profile>);

    dump-rakudo-env($user);
    
  } else {

  		# --------------------------- Install Rakudo $rakudo-version ------------------------ #
		
  		say "<<< Rakudo Install, version <{$rakudo-version}> os <{os()}> >>>";  

      unless %args<skip-install-dependencies> {

  		  package-install ('epel-release') if os() ~~ /centos/;

  		  package-install ('wget', 'zstd');
		
      }
  		
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
  		
    if $install-zef {
		
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

		} else {
			say "skip-zef set to {%args<skip-zef>}, don't install zef ...";
		}
		
  	set-user-env($user, %args<patch-profile>, "{$path-to-raku}/bin/");
		
  	dump-rakudo-env($user) if %args<patch-profile>;

  }
  
  return

}


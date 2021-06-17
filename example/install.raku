#user "test123";

use Sparrow6::DSL;

my $sha = "4f61a108b1e717a8e05ee861738a412d55be6ed4";

module-run 'Rakudo::Install', %(
  user => 'root',
  rakudo-version => $sha,
  skip-zef => True,
  patch-profile => False,
);

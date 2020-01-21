# Sparrow6::Rakudo::Install

Sparrow6 plugin to install various versions of Rakudo

# Install

`zef install Sparrow6::Rakudo::Install`

# Usage

Inside your Sparrow scenario:

```
user "test123";

my $path = module-run 'Rakudo::Install', %(
  user => 'test123',
  rakudo-version => '40b13322c503808235d9fec782d3767eb8edb899'
);

# Now you can use installed Rakudo

bash "perl6 --version", %(
  envvar => %( PATH => "{%*ARGS<PATH>}:{$path}" ),
  user => "test123"
)

```

# See also

[Sparrow6 modules](https://github.com/melezhik/Sparrow6/blob/master/documentation/modules.md)


# Author

Alexey Melezhik



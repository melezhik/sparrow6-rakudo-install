# Sparrow6::Rakudo::Install

Sparrow6 plugin to install various versions of Rakudo

# Install

`zef install Sparrow6::Rakudo::Install`

# Usage

Inside your Sparrow scenario:

```
user "test123";

zef "https://github.com/melezhik/sparrow6-rakudo-install.git";

module-run 'Rakudo::Install', %(
  user => 'test123',
  rakudo-version => '40b13322c503808235d9fec782d3767eb8edb899'
);

# Now you can use installed Rakudo and Zef

bash "raku --version", %(
  user => "test123"
)

bash "zef --version", %(
  user => "test123"
)

```

# Parameters 

## user

User to install

## rakudo-version 

Rakudo version, should full SHA, see [https://github.com/rakudo/rakudo/commits/](https://github.com/rakudo/rakudo/commits/)

## skip-install-dependencies

Don't install system dependencies (wget,zstd so on)

## skip-zef

Don't install zef

## patch-profile

Patch user's bash profile. Optional, default value is `True`

# See also

[Sparrow6 modules](https://github.com/melezhik/Sparrow6/blob/master/documentation/modules.md)


# Author

Alexey Melezhik



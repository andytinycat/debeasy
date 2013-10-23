# Debeasy

A really easy way to read the properties of a Debian/Ubuntu (DEB format)
package file. In this way, it's the Debian/Ubuntu companion to
[jordansissel's arr-pm gem](https://github.com/jordansissel/ruby-arr-pm).

## Usage

    require 'debeasy'
    pkg = Debeasy.read("/path/to/package.deb")
    puts pkg.architecture
    => x86_64

All the attributes are the same ones you'd get from `aptitude show`, except
for the purposes of access hyphens (`-`) get replaced with underscores (`_`),
and everything is lowercased.

To see the available fields on a package, do:

    require 'debeasy'
    pkg = Debeasy.read("/path/to/package.deb")
    puts pkg.fields

You can read a field either by calling the method with the field name,
or by using hash access syntax:

    # Equivalent
    pkg.installed_size
    pkg["installed_size"]

You can also read the preinst, prerm, postinst, and postrm scripts
from the package:

    pkg.preinst_contents
    pkg.prerm_contents
    pkg.postinst_contents
    pkg.postrm_contents
    
You can read the entire filelist of a package:

    pkg.filelist

## Installation

Add this line to your application's Gemfile:

    gem 'debeasy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install debeasy

## Installation on Mac OS X

You may (read: will) run into problems getting the `libarchive` gem to
install on Mac OS X. The way to fix this seems to be to tell `bundler` to
supply an option to the `libarchive` build process so it can find `libarchive.h`.

First install libarchive with brew:

    brew install libarchive

Now configure `bundler`:

    bundle config build.libarchive "--with-opt-dir=/usr/local/opt/libarchive"

Now do `bundle install` as normal.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

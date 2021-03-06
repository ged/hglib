# hglib

home
: https://hg.sr.ht/~ged/hglib

code
: https://hg.sr.ht/~ged/hglib

github
: https://github.com/ged/hglib

docs
: http://deveiate.org/code/hglib


## Description

This is a client library for the Mercurial distributed revision control tool
that uses the [Command Server][cmdserver] for efficiency.

[![builds.sr.ht status](https://builds.sr.ht/~ged/hglib.svg)](https://builds.sr.ht/~ged/hglib?)

### Examples

    require 'hglib'

    repo = Hglib.clone( 'https://hg.sr.ht/~ged/hglib' )
    # => #<Hglib::Repo:0x00007fae3880ec90 @path=#<Pathname:/Users/ged/temp/hglib>, @server=nil>


## Prerequisites

* Ruby


## Installation

    $ gem install hglib


## Contributing

You can check out the current development source with Mercurial via its
[project page](https://hg.sr.ht/~ged/hglib). Or if you prefer Git, via
[its Github mirror](https://github.com/ged/hglib).

After checking out the source, run:

    $ gem install -Ng

This will install any missing dependencies, after which you can get a list of
the available development tasks with `rake -T`.


## Authors

- Michael Granger <ged@FaerieMUD.org>


## License

Copyright (c) 2018-2019, Michael Granger
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the author/s, nor the names of the project's
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


[cmdserver]:https://www.mercurial-scm.org/wiki/CommandServer


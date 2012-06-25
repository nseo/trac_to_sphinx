Trac to Sphinx
==============

This is a *very* rough start of a script to help convert Trac to Sphinx friendly syntax.

Requirements
------------

- ruby

How to install
--------------

First, install epel yum repository to install cabal-install.

::

  wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm -O /tmp/epel-release-6-5.noarch.rpm 
  sudo rpm -Uvh /tmp/epel-release-6-5.noarch.rpm

Second, install the `pandoc <http://johnmacfarlane.net/pandoc/>`_ using cabal-install (Haskell package), it may take 15min or more.

::

  sudo yum install cabal-install
  sudo ln -s /root/.cabal/bin/cabal /usr/local/bin/cabal
  sudo cabal update
  sudo cabal install cabal-install
  sudo cabal install json-0.4.4
  sudo cabal install pandoc
  sudo ln -s /root/.cabal/bin/pandoc /usr/local/bin/pandoc

Then, install other required libralies to run convert.rb.

::

  gem install bundler
  bundle install

How to use
----------

- Create a *_source* directory and copy your html files into the directory.

::

  wget \
  --recursive \
  --no-clobber \
  --page-requisites \
  --html-extension \
  --restrict-file-names=nocontrol \
  --domains god.rdc.ricoh.co.jp \
  --no-parent \
  --level 1 \
  http://god.rdc.ricoh.co.jp/trac/nsp/wiki/TitleIndex
  mv god.rdc.ricoh.co.jp _source

- Use convert.rb to convert html into reST using pandoc.

::

  ruby convert.rb

- Use cleanup.sh to cleanup unnecessary files

::

  ./cleanup.sh

- Use format.rb to format converted reST files into sphinx documents.

::

  ruby format.rb
 
- _format is the one created.

Caveats
-------

You still need to look over the markup and fix any mistakes. It isn't perfect by any means, but it will save some time.



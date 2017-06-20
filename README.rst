src.sh
======

Simple shell function to clone and navigate git source respositories in a
golang-style directory layout.

golang dictates a strict directory layout and provides helper programs to
fetch source code into the right structure. Other languages do not mandate such
a layout, but neither do they have any problems if one is used. ``src.sh`` was
written to facilitate managing all of ones source repos in the same structure,
regardless of whether one is programming in go or not.

Installation
------------

Either copy the contents of ``src.sh`` to your ``~/.bash_profile`` or
copy the file into ``/etc/profile.d`` then re-login. It's also possible
to ``source src.sh`` in the current shell if you don't want to re-login.

A new shell function `src` will be available.

Usage
-----

``src.sh`` either clones or changes directories to a given source repo
location.

.. code-block:: bash

  src emonty/src.sh

Results in the ``emonty/src.sh`` repo being cloned to
``~/src/github.com/emonty/src.sh`` if it's not already there and that being set
to the current directory.

Configuration
-------------

``src.sh`` uses the golang source directory layout scheme, but uses
``$SRCSRCDIR`` instead of ``$GOPATH`` as the primary variable. If ``$GOPATH``
is set and ``$SRCSRCDIR`` is not set, ``$SRCSRCDIR`` defaults to
``$GOPATH/src``. If neither are set, ``$SRCSRCDIR`` defaults to ``~/src``.

``$SRCSRCDIR``, while ugly, was chosen because the function is called "src" but
``$SRCDIR`` is much more likely to be already be used, possibly for some other
purpose.

``src.sh`` supports a configurable ordered list of prefixes to try, for folks
who have frequent groups of things they work with. ``$SRCSRCPREFIXES``
defaults to "github.com". For instance:

.. code-block:: bash

  export SRCSRCPREFIXES="git.openstack.org/openstack-infra \
      git.openstack.org/openstack \
      github.com"
  src shade

Results in shade being cloned to
``~/src/git.openstack.org/openstack-infra/shade``.

``src.sh`` defaults to using cd to change directories. Setting
``$SRCSRCUSEPUSHD=1`` will cause it to use pushd instead.

Use of go get by default
------------------------

By default, ``src.sh`` uses ``go get -d`` to do the cloning. If you do not have
``go get`` in your path, it will use a less efficient set of shell commands
and attempt cloning directly. ``go get`` has a better idea of whether or not
you're requesting a full path to something or not, so it's recommended to just
have it installed somewhere in your path.

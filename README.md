# find_cruft

Find cruft files on Gentoo and similar distributions

Author: Martin Väth (martin at mvath.de).

This project is under the BSD license 2.0 (“3-clause BSD license”).
SPDX-License-Identifier: BSD-3-Clause

Gentoo records all installed files in a database.
Files not stored in this database are either manually installed or
intentionally created at runtime or cruft.
`find_cruft` will output all files which might possibly be cruft.

`find_cruft` is extremely configurable (by perl code) and has the possibility
to e.g. check only certain subtrees for cruft.
It can also emulate a chroot to some extent if you have a gentoo installation
in a chroot partition.

For detailed usage instructions, type `find_cruft --man` after installing.

### Installation

For installation, just put the content of bin somewhere into your `$PATH`
and the content of `etc` into `/usr/lib/find_cruft` or into `/etc` or use
later a corresponding `-c` option.

Put your local customization into `/etc/find_cruft.d` or `/etc/find_cruft.pl`
(this will override the corresponding content of `/usr/lib/find_cruft`).
Also put the files of the subdirectory `zsh` into your zsh's `$fpath` to obtain
__zsh completion__ support. (If you do not have root access, you can add the
corresponding directory with `fpath+=("...")` before you
call `compdef` from your __zsh__ initialization files).

For installation under Gentoo, you can use the ebuild from the mv repository
(which is available over eselect-repository or layman).

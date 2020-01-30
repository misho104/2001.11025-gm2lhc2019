gm2lhc2019
==========

This repository stores my contribution to the project "g-2 vs LHC Run2",

  \M. Endo, K. Hamaguchi, S. Iwamoto, T. Kitahara, *Muon g-2 vs LHC Run 2 in Supersymmetric Models*, `arXiv:2001.11025 <https://arxiv.org/abs/2001.11025>`_.


Copyright
---------

© Sho Iwamoto, 2019-2020

Documents written by me (Sho Iwamoto) is licensed under `the Creative Commons CC-BY-NC 4.0 International Public License <https://creativecommons.org/licenses/by-nc/4.0/>`_.
Program codes writen by me is licensed under `the MIT License <https://opensource.org/licenses/MIT>`_.

Note that this repository also includes a draft for publication, external packages, etc., for which, needless to say, copyright notes and licenses are specified elsewhere.
Contact `me <https://www.misho-web.com/phys/>`_ for further inquiry.


Directories
-----------

- **vendor** directory is a special directory, which stores external packages; the usage is described below.
- **notes** directory has internal [#internal]_ notes; all notes (i.e., TeX documents) should be stored here.
- **spectrum** directory contains SLHA spectrum used in the analysis.
- **xs** directory stores codes and data related to production cross sections.
- **lhc** directory stores codes and data related to ATLAS and CMS analyses.
- **plots** directory stores figures for internal notes, the manuscript, and codes to generate them. TeX files in ``notes`` directory have links to the files in this directory so that daily updates are instantly reflected in the notes; hence modification to the files here should be carefully done.


.. [#internal] But become public (as well as the other files) after publication.


Vendor directory
----------------

The codes in this repository depend on various external packages and tools, which are currently categorized as ``pip`` tools and ``submodule`` tools.
``pip`` tools are for Python codes and can be installed by ``pip`` command::

    pip install -r vendor/requirements.txt

However, this command binds the packages to your whole system.
If you are not confident on what you are doing, it may be better to install one-by-one by reading ``requirements.txt``.
Or, you may want to sequester the Python system for this package from the Python system for the whole machine, which is possible by so-called virtualenv mechanism (e.g., ``pyenv-virtualenv``). For details, consult Google.

``submodule`` tools are linked to this repository via ``git-submodule`` mechanism, which is invoked by ::

    git submodule init
    git submodule update

and then the packages are automatically installed in ``vendor`` directory, after which one should compile those packages one by one.

``vendor/Makefile`` is provided to do the above all at once, but it is mainly for convenience of Sho and not prepared for others to invoke it by ``make``; in particular, the ``Makefile`` assumes that one uses ``pyenv``.
Rather, the ``Makefile`` (and the submodule links) is prepared for others to understand which version of tools are used in this analysis and how they are compiled (possibly with patches).


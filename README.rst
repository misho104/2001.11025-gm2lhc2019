gm2lhc2019
==========

This repository stores the codes and data for the project "g-2 vs LHC Run2".

**This repository will be public once the work is published on a journal.**

Currently, the codes are copyrighted by

- Sho Iwamoto

unless otherwise noted, with the help of the collaborators

- Motoi Endo
- Koichi Hamaguchi
- Teppei Kitahara

.. and of   (append when we asked for others' help for coding)



Directories
-----------

- **vendor** directory is a special directory, which stores external packages; the usage is described below.
- **notes** directory has internal [#internal]_ notes; all notes (i.e., TeX documents) should be stored here.
- **spectrum** directory contains SLHA spectrum used in the analysis.
- **xs** directory stores codes and data related to production cross sections.
- **lhc** directory stores codes and data related to ATLAS and CMS analyses.
- **plots** directory stores figures for internal notes, the manuscript, and codes to generate them. TeX files in ``notes`` directory have links to the files in this directory so that daily updates are instantly reflected in the notes; hence modification to the files here should be carefully done.


.. [#internal] But become public (as well as the other files) after publication.

Branches
--------

The `master branch`_ [#]_ stores "established" codes or data, which the author believes won't be not *corrected* or *fixed* in future (but they are expected to be *upgraded*).
Daily analysis or code-writing should not be done in this branch, as described below.

The `working_sho branch`_ stores work-in-progress codes or data written by Sho.
You can view the latest (but WIP) analysis results on this branch, but the data or code is not "final", i.e., Sho is not confident or comfortable with the results.
Thus the data in this branch will be deleted (even the history may be overwritten).
Once it is ready, the content is "merged" to the master branch.

One should not do daily analysis or study on the master branch because the branch is will be public at the last moment with its full history.
Instead, you may create other branches for your "working" branch or for more specific purpose.
For example, if you want to debug a code ``analysis.tex`` in master branch, it is recommended to create a new branch with a name, e.g., "debug_analysis_tex_sept10", and to work on it.
Then, once you are done, you can ask for a pull request, which requests to merge the new branch to the master branch (or other branches).

Meanwhile, history of the working branches may be overwritten, or, in fact, the working branches are expected to be deleted in future.
Then, the content of the deleted branches are lost forever, and shameful bugs in the branches are concealed forever.


.. _`master branch`: https://github.com/misho104/gm2lhc2019
.. _`working_sho branch`: https://github.com/misho104/gm2lhc2019/tree/working_sho

.. [#] A git repository may have multiple branches. On GitHub, one can switch branches via ``Branch: master`` button.


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


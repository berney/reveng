Software for distribution to end users
======================================

Included with your purchase of the DDE is a royalty-free licence to
redistribute this copy of !System, bundled with your software (commercial or
otherwise). It contains the latest version of the Shared C Library, which is
necessary to guarantee that your end users can run software compiled with
this version of the DDE. This is particularly necessary if the end users are
running a version of RISC OS prior to RISC OS 5. This !System can be
installed using any version of the SysMerge application.

Alternatively, you may choose to point your end users at the RISC OS Open
web site. This has the advantage that it will be updated regularly, so will
probably be more up-to-date than this copy. However, the versions hosted on
the web site are not for commercial redistribution. If you choose this
method, direct your users to download and install the "System resources"
from here:

  http://www.riscosopen.org/content/downloads/other-zipfiles

Direct link:

  https://www.riscosopen.org/zipfiles/misc/PlingSystem.zip

You can also redistribute the web site version of !System with a
non-commercial product, as long as you comply with the terms of the shared
source licence. Please include the Licence_v1_1/pdf file if you distribute
the web site version of !System in this way.

Special considerations for RISC OS Select
=========================================

Some versions of RISC OS Select, particulally 4.29, will require a patch
before the 32bit Shared C Library can be loaded. Please note that currently
RISCOS Ltd. will be unable to provide support any system while the new CLib
is in use. This patch can be applied by copying the !Boot shell in the
'Select_429' directory over the existing !Boot.

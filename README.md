verbind
=======

This is a case-study tool to retrieve the version of bind by executing a simple dns query request following the rfc standard.


Howto
-----

    deftcode ~ $ ruby verbind.rb deftcode.local
    > Requesting for version.bind to address: deftcode.local
    + Bind version found: 9.8.4-rpz2+rl005.12-P1


References
----------

* RFC-1035: http://tools.ietf.org/html/rfc1035
* DNS Protocol: http://www.networksorcery.com/enp/protocol/dns.htm
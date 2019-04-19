
This is a buld wrapper for OpenSSH RPMs, to bring the latest OpenSSH
release to RHEL and CentOS . The openssh.spec is from the
openssh-portable repo, modified for compilation on RHEL 7 and Fedora.

To build the RPM locally, use:

    make build

To build various RHEL and Fedora releases using "mock", use:


    make

Nico Kadel-Garcia <nkadel@gmail.com>

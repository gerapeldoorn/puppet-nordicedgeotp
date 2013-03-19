puppet-nordicedgeotp
====================

Manages NordicEdge OTP server

This module installs the NordicEdge (now McAfee) OTPServer using the provided installer.

It is tested on RedHat only, but it should be quite easy to adapt it for use with Debian (or something else). Pull requests are welcome.

You do need to add your own configfile, an empty placeholder is there.

Example Usage:

include nordicedgeotp

Extra configuration:
 Create a license directory for each host and put the XML files in there.
 example: modules/nordicedgeotp/files/hostname-license

 You need a seperate properties file for each server
 It does not overwrite any local changes so you can use the configuring GUI and copy the generated otp file to the puppetmaster.

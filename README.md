puppet-nordicedgeotp
====================

Manages NordicEdge OTP server

Example Usage:

include nordicedgeotp

Extra configuration:
 Create a license directory for each host and put the XML files in there.
 example: modules/nordicedgeotp/files/hostname-license

 You need a seperate properties file for each server
 It does not overwrite any local changes so you can use the configuring GUI and copy the generated otp file to the puppetmaster.
 example: modules/nordicedgeotp/files/hostname.otp.properties

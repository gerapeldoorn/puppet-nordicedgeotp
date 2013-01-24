# Class: nordicedgeotp::params
#
#
class nordicedgeotp::params {

	$otpdownloadurl = hiera( "nordicdownloadurl", "http://download.nordicedge.se/download/otpserver/InstData/Linux/NoVM/otp3install.bin" )
	
	case $::osfamily {
		"redhat": {
			$packages = [ 'java-1.6.0-openjdk', 'urw-fonts' ]
		}
		default: {
			fail ("Sorry, this module is not able to handle ${::operatingsystem} based machines at the moment.")
		}
	}
}
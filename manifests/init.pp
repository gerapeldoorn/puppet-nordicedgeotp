# == Class: nordicedgeotp
#
# This class will install the NordicEdgeotp OTP server and manage it's configfile.
# You will have to add your own answer- and configuration file.
#
#
# === Examples
#
#  include nordicedgeotp
#
# === Authors
#
# Ger Apeldoorn <info@gerapeldoorn.nl>
#
# === Copyright
#
# Copyright 2013 Ger Apeldoorn, unless otherwise noted.
#
class nordicedgeotp inherits nordicedgeotp::params {

	exec { "getOTPinstaller":
		command => "wget -O /tmp/otp3install.bin ${otpdownloadurl}",
		creates => "/tmp/otp3install.bin",
		path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
	}

	# You need a seperate answer file for each server
	file { "/tmp/answers.txt":
		ensure => file,
		source => [ "puppet:///nordicedgeotp/${::hostname}.answers.txt",
					"puppet:///nordicedgeotp/answers.txt" ],
	}

	package { $packages:
		ensure => installed,
	}

	exec { "installOTP":
		command => "/bin/sh /tmp/otp3install.bin -i silent -f /tmp/answers.txt",
		creates => "/opt/McAfee",
		require => [ Exec["getOTPinstaller"], 
					 File["/tmp/answers.txt"], 
					 Package[$packages] ],
	}

	# You need a seperate properties file for each server
	# It does not overwrite any local changes so you can use the configuring GUI and copy the generated otp file to the puppetmaster.
	# example: modules/nordicedgeotp/files/hostname.otp.properties
	file { "/opt/McAfee/OTPServer3/otp.properties":
		ensure  => file,
		source  => [ "puppet:///nordicedgeotp/${::hostname}.otp.properties",
					 "puppet:///nordicedgeotp/otp.properties" ],
		replace => false,
		require => Exec["installOTP"],
		notify  => Service['OTPServer'],
	}

	# This is the template file for the SMS gateway
	file { "/opt/McAfee/OTPServer3/kpntemplate.txt":
		ensure  => file,
		source  => "puppet:///nordicedgeotp/kpntemplate.txt",
		require => Exec["installOTP"],
	}

	# A lovely initscript.
	file { "/etc/init.d/OTPServer":
		ensure  => file,
		source  => "puppet:///nordicedgeotp/init.d-OTPServer",
		mode    => '0755',
		require => Exec["installOTP"],
	}

	service { "OTPServer":
		enable     => true,
		ensure     => running,
		hasrestart => false,
		hasstatus  => false,
		pattern    => "/opt/McAfee/OTPServer3/OTPServer.lax",
		require    => File["/etc/init.d/OTPServer"],
	}

	# Create a license directory for each host and put the XML files in there.
	# example: modules/nordicedgeotp/files/hostname-license
	file { "/opt/McAfee/OTPServer3/license":
		ensure   => directory,
		source   => [ "puppet:///nordicedgeotp/${::hostname}-license",
					  "puppet:///nordicedgeotp/license" ],
		mode     => '0755',
		recurse  => true,
		require  => Exec["installOTP"],
		notify   => Service['OTPServer'],
	}

}
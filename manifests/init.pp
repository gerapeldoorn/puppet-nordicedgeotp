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

	# You need a seperate answer file for each server
	file { "/opt/McAfee/OTPServer3/otp.properties":
		ensure  => file,
		source  => [ "puppet:///nordicedgeotp/${::hostname}.otp.properties",
					 "puppet:///nordicedgeotp/otp.properties" ],
		require => Exec["installOTP"],
		notify  => Service['OTPServer'],
	}

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

}

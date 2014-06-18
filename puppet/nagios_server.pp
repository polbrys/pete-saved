# /etc/puppet/modules/nagios/manifests/nagios_server.pp
# Manifest file for Nagios
# - Verifies Nagios installation was successful and correct
#     permissions are set for files and directories.
#

class mon_server::nagios_server {
    # Base line directories needed for Nagios to run
    #  both as a service and the web GUI.
    $nagios_dirs = [
        '/usr/share/nagios',
        '/usr/share/nagios/html',
        '/usr/lib64/nagios',
        '/etc/nagios',
        '/etc/nagios/apperian',
        '/var/log/nagios',
    ]
    
    # Ensure nagios user exists, and belongs to group nagios.
    #user { 'nagios':
    #    ensure    => 'present',
    #    groups    => 'nagios',
    #}

    # Ensure all Nagios directories exist, and have correct permissions.
    file { $nagios_dirs:
        ensure    => 'directory',
        recurse   => true,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        require   => Package['nagios'],
    }
    # Explicitly setting this file to 644.  The recursion above sets it to 755, but Nagios changes it. 
    file { '/var/log/nagios/status.dat':
        ensure  => present,
        owner   => 'nagios',
        group   => 'nagios',
        mode    => '0664',
        require => File['/var/log/nagios'],
    }

    # Ensure nagios files have correct perms
    file { '/etc/nagios/passwd':
        ensure    => present,
        owner     => 'root',
        group     => 'apache',
        mode      => '0755',
        backup    => 'true',
        source    => 'puppet:///modules/mon_server/passwd'
    }

    # Ensure host specific files
    file { "/etc/nagios/apperian/${hostname}.cfg":
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => true,
        source    => "puppet:///modules/mon_server/${hostname}/${hostname}.cfg",    
        require   => [ File['/etc/nagios/apperian'], ]
    }   
    file { '/etc/nagios/resource.cfg':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => true,
        source    => "puppet:///modules/mon_server/${hostname}/resource.cfg",
        require   => [ File['/etc/nagios'], ]
    }

    # Ensure common Nagios files
    file { '/etc/nagios/nagios.cfg':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => true,
        source    => 'puppet:///modules/mon_server/nagios.cfg',
        require   => [ File['/etc/nagios'], ]
    } 
    file { '/etc/nagios/cgi.cfg':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => true,
        source    => 'puppet:///modules/mon_server/cgi.cfg',
        require   => [ File['/etc/nagios'], ]
    }
    file { '/etc/nagios/apperian/common_cmds.cfg':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => false,
        source    => 'puppet:///modules/mon_server/common_cmds.cfg',
        require   => [ File['/etc/nagios/apperian'], ]
    }
    file { '/etc/nagios/apperian/common_contacts.cfg':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => false,
        source    => 'puppet:///modules/mon_server/common_contacts.cfg',
        require   => [ File['/etc/nagios/apperian'], ]
    }
    file { '/etc/nagios/apperian/common_time.cfg':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => false,
        source    => 'puppet:///modules/mon_server/common_time.cfg',
        require   => [ File['/etc/nagios/apperian'], ]
    }
    file { '/etc/nagios/apperian/common_templates.cfg':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => false,
        source    => 'puppet:///modules/mon_server/common_templates.cfg',
        require   => [ File['/etc/nagios/apperian'], ]
    }
    file { '/etc/nagios/apperian/pagerduty.cfg':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => false,
        source    => 'puppet:///modules/mon_server/pagerduty_nagios.cfg',
        require   => [ File['/etc/nagios/apperian'], ]
    }

    # Push custom checks to server
    file { '/usr/lib64/nagios/plugins/check_apt':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => false,
        source    => 'puppet:///modules/mon_server/nagios_checks/check_apt',
    }
    file { '/usr/lib64/nagios/plugins/check_mdm.sh':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => false,
        source    => 'puppet:///modules/mon_server/nagios_checks/check_mdm.sh',
    }
    file { '/etc/nagios/nrpe.d/check_nagios.cfg':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/mon_server/check_nagios.cfg',
        require => [ File['/etc/nagios/nrpe.d'],
                     Package['nagios-plugins-all'],
                   ],
        notify  => Service['nrpe'],
    }
    file { '/usr/lib64/nagios/plugins/pagerduty.pl':
        ensure    => present,
        owner     => 'nagios',
        group     => 'nagios',
        mode      => '0755',
        backup    => false,
        source    => 'puppet:///modules/mon_server/nagios_checks/pagerduty_nagios.pl',
    }

    cron { 'pagerduty_cron':
        command => '/usr/lib64/nagios/plugins/pagerduty.pl flush',
        user    => 'nagios',
        minute  => '*/1',
        require => [ Package['nagios'],
                     File['/usr/lib64/nagios/plugins/pagerduty.pl'],
                   ],
    }

    # Define the nagios service
    $nagios_subscribe=[ File["/etc/nagios/apperian/${hostname}.cfg"],
                        File['/etc/nagios/resource.cfg'],
                        File['/etc/nagios/nagios.cfg'],
                        File['/etc/nagios/cgi.cfg'],
                        File['/etc/nagios/apperian/common_cmds.cfg'],
                        File['/etc/nagios/apperian/common_contacts.cfg'],
                        File['/etc/nagios/apperian/pagerduty.cfg'],
                        File['/etc/nagios/apperian/common_time.cfg'],
                        File['/etc/nagios/apperian/common_templates.cfg'],
                        Package['nagios'], ]

    service { 'nagios':
        ensure     => running,
        enable     => true,
        require    => Package['nagios'],
        subscribe  => $nagios_subscribe,
        hasrestart => true,
        hasstatus  => true,
    }
   
}

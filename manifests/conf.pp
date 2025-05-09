#
# = Define: network::conf
#
# With this define you can manage any network configuration file
#
# == Parameters
#
# [*template*]
#   String. Optional. Default: undef. Alternative to: source, content.
#   Sets the module path of a custom template to use as content of
#   the config file
#   When defined, config file has: content => content($template),
#   Example: template => 'site/network/my.conf.erb',
#
# [*content*]
#   String. Optional. Default: undef. Alternative to: template, source.
#   Sets directly the value of the file's content parameter
#   When defined, config file has: content => $content,
#   Example: content => "# File manage by Puppet \n",
#
# [*source*]
#   String. Optional. Default: undef. Alternative to: template, content.
#   Sets the value of the file's source parameter
#   When defined, config file has: source => $source,
#   Example: source => 'puppet:///site/network/my.conf',
#
# [*ensure*]
#   String. Default: present
#   Manages config file presence. Possible values:
#   * 'present' - Create and manages the file.
#   * 'absent' - Remove the file.
#
# [*path*]
#   String. Optional. Default: $config_dir/$title
#   The path of the created config file. If not defined a file
#   name like the  the name of the title a custom template to
#   use as content of configfile
#   If defined, configfile file has: content => content("$template")
#
# [*mode*]
# [*owner*]
# [*group*]
# [*replace*]
#   String. Optional. Default: undef
#   All these parameters map directly to the created file attributes.
#   If not defined the module's defaults are used.
#   If defined, config file file has, for example: mode => $mode
#
# [*config_file_notify*]
#   String or Boolean. Optional. Default: 'class_default'
#   Defines the content of the notify argument of the created file.
#   The default string 'class_default' uses $::network::manage_config_file_notify
#   variable from main network class, which can be set via the hiera key:
#   network::config_file_notify.
#   Set to undef or Boolean false to remove any notify, leave default value or
#   set Boolean true to use class defaults, or define, as a string,
#   the name(s) of the resources to notify. Ie: 'Service[network]',
#
# [*config_file_require*]
#   String or Boolean. Optional. Default: undef
#   Defines the require argument of the created file.
#   The default is to leave this undefined and don't force any dependency.
#   Set the name of a resource to require (must be in the catalog) for custom
#   need Ie: 'Package[network-tools]'
#   If value is true, class' default is used (which is undef but can be
#   overwritten by user.
#   If false value remains undefined.
#
# [*options_hash*]
#   Hash. Default undef. Needs: 'template'.
#   An hash of custom options to be used in templates to manage any key pairs of
#   arbitrary settings.
#
define network::conf (

  $source       = undef,
  $template     = undef,
  $content      = undef,

  $path         = undef,
  $mode         = undef,
  $owner        = undef,
  $group        = undef,

  $config_file_notify  = 'class_default',
  $config_file_require = undef,

  $options_hash = undef,

Enum['absent', 'present'] $ensure       = present ) {
  include network

  $manage_path    = pick($path, "${network::config_dir_path}/${name}")
  $manage_mode    = pick($mode, $network::config_file_mode)
  $manage_owner   = pick($owner, $network::config_file_owner)
  $manage_group   = pick($group, $network::config_file_group)
  $manage_require = $config_file_require ? {
    'class_default' => $network::manage_config_file_require,
    true            => $network::manage_config_file_require,
    false           => undef,
    default         => $config_file_require,
  }
  $manage_notify  = $config_file_notify ? {
    'class_default' => $network::manage_config_file_notify,
    true            => $network::manage_config_file_notify,
    false           => undef,
    default         => $config_file_notify,
  }
  $manage_content = $content ? {
    undef => $template ? {
      undef   => undef,
      default => template($template),
    },
    default => $content,
  }

  file { "network_conf_${name}":
    ensure  => $ensure,
    source  => $source,
    content => $manage_content,
    path    => $manage_path,
    mode    => $manage_mode,
    owner   => $manage_owner,
    group   => $manage_group,
    require => $manage_require,
    notify  => $manage_notify,
  }
}

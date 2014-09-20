# This is a sample local configuration file for find_cruft;
# probably there is a more generic configuration in /etc/find_cruft.pl

# If you do not want to use the subsequent code, use the command:
# return 1;

# These are some typical directories which you may want to cut
# because they are known to contain generated files (not by portage).

push(@cut, qw(
	/var/cache/fontconfig
	/usr/share/mime
	/lib/modules
	/lib64/modules
	/var/log/portage
));

1;  # The last executed command in this file should be a true expression

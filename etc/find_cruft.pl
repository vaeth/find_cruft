
# The following directories should never be scanned for cruft-files:
push(@cut,
	'/home',
	'/root',
	'/srv',
	'/boot',
	'/var/tmp',
	'/var/db',
	'/var/cache/edb');

# If the following command is uncommented, it means that our subsequent changes
# to the environment variables $ENV{...} are only valid for this file and
# not also for subsequent config files:
#local %ENV = %ENV;

# When we call eix, we want that it honours chroot:
$ENV{'EIX_PREFIX'} = $root;
# Moreover, eix shall not append \n to its output strings for --print:
$ENV{'PRINT_APPEND'} = '';

# If eix is available, we use it to get PORTDIR.
# Since subsequent config files might also want to use $portdir,
# we make this an "our" variable instead of a "my" variable:
# Use "our $portdir" in subsequent config files if you want to access $portdir.
our $portdir = remove_root(`eix --print PORTDIR 2>/dev/null`);
if($portdir eq '') {
	# If eix is not available, we try the slower portageq
	# Note that the last fallback protageq portdir does not honour $root.
	$portdir = `portageq get_repo_path '$root/' gentoo 2>/dev/null || portageq portdir 2>/dev/null`;
	$portdir = '' unless(defined($portdir));
	# portageq does append \n, so cut it:
	chomp($portdir);
	# If also portageq was not available, we fall back to the default:
	$portdir = ${root} . '/usr/portage' if($portdir eq '')
}
# The whole purpose of the business was to add $portdir to @cut:
push(@cut, $portdir);

# Now we add KERNEL_DIR and KBUILD_OUTPUT (both default to /usr/src/linux)
# and - if it is a symlink - the directory where it points to to @cut.
# Note that resolving the symlink might not honour $root correctly.

# For resolving the symlink we use perl's Cwd:::abs_path:
use Cwd 'abs_path';

my $kernel_dir = remove_root($ENV{'KERNEL_DIR'});
$kernel_dir = '/usr/src/linux' if($kernel_dir eq '');
push(@cut, $kernel_dir);
push_without_root(@cut, abs_path($root . $kernel_dir));

my $kbuild_output = remove_root($ENV{'KBUILD_OUTPUT'});
if($kbuild_output ne '') {
	push(@cut, $kbuild_output);
	push_without_root(@cut, abs_path($root . $kbuild_output))
}

# The following are standard symlinks on all gentoo systems.
# On x86 systems the /lib64 directory does not exist, but entries with
# nonexisting destinations are ignored, so it does no harm to add it here.
# To deal with the unusual setting /lib64->/lib (instead /lib->/lib64),
# we also add the converse test (which only slows down a bit.
push(@symlinks,
	['/usr/doc', '/usr/share/doc'],
	['/usr/man', '/usr/share/man'],
	['/usr/info', '/usr/share/info'],
	['/usr/tmp', '/usr/var/tmp'],
	['/var/mail', '/var/spool/mail'],
	['/lib', '/lib64'],
	['/lib64', '/lib']
);

# However, for /usr/lib64 we better make a separate test, since we also
# decide whether /usr/lib/gcc-lib or /usr/lib64/gcc-lib is the plain directory:
if(-d $root . '/usr/lib64') {
	if(-l $root . '/usr/lib') { # the usual amd64 case
		push(@symlinks,
			['/usr/lib', '/usr/lib64'],
			['/usr/lib/gcc', '/usr/lib64/gcc', '/usr/lib64/gcc-lib'])
	} elsif(-l $root . '/usr/lib64') { # the unusual amd64 case
		push(@symlinks,
			['/usr/lib64', '/usr/lib'],
			['/usr/lib/gcc', '/usr/lib64/gcc', '/usr/lib/gcc-lib'])
	}
} else { # The x86 systems case
	push(@symlinks, ['/usr/lib/gcc', '/usr/lib/gcc-lib'])
}

SEE ALSO: p4prod-managed gitlab API (and non-api) scripts for creating users, projects
ALSO SEE ALSO: Postman queries saved in Postman for same; 

semi-automation of adding mirror to Gconn via command line and via http endpoints

test.pl is  perl script which can
 (via Net::SSH) re-set a Gconn to an 'empty' state by removing the repo cache and deleting the named repo
 (via LWP::UserAgent) contact the Gconn mirror endpoints to add/list/remove mirrors

The idea was to be able to call add/list/remove in various combinations of cmd-line or from HTTP endpoints
to catch gaps in error handling

bug_mirror_add.txt is a (draft) of the bug report already submitted and fixed/verified making
this script mostly of historical interest as an exercise in using Test::More

Relies heavily on local installed instances of GitLab and Helix/P4D

Would be a good candidate (TODO) for using cointainerized instances of either or both
the script test.pl does take as arguments such things as the P4PORT of the backing Helix instance
and the URL of the upstream repo to mirror.

use feature qw(say);
use Net::SSH qw(ssh_cmd sshopen3 sshopen2);
use Data::Dumper;
use Getopt::Long;
use Test::More;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;
use JSON;

my $retval;

my $GCONN_COMMAND_PREAMBLE = "GCONN_CONFIG=/opt/perforce/git-connector/gconn.conf /opt/perforce/git-connector/bin/gconn --mirrorhooks";

my %opts = (
	    "p4port"=>"osiris:1666",
	    "p4super" => "super",
	    "gconn_os_user" => "root",
	    "gconn_hostname" => "osiris",
	    "helix_repo_name" => "//repo/brepo",
	    "upstream_url" =>  "http://gitlabee9/root/brepo.git",
	   );


GetOptions(\%opts,
	   "p4port:s",
	   "p4super:s",
	   "gconn_os_user:s",
	   "gconn_hostname:s",
	   "helix_repo_name:s",
	   "upstream_url:s",
	   );

# a couple of derived values
$opts{'gconn_http_base'} = "https://" . $opts{"gconn_hostname"} . "/mirrorhooks";
$opts{'gconn_repo_cache'} = $opts{"helix_repo_name"};
$opts{'gconn_repo_cache'}  =~ s/\/\///;
$opts{'gconn_repo_cache'}  .= ".git";
$opts{'login'} =  $opts{"gconn_os_user"} . "\@" . $opts{"gconn_hostname"};


print Dumper(\%opts);

# list of commands to run on Gconn host
my %cmds = ("add" => $GCONN_COMMAND_PREAMBLE . " add " . $opts{'gconn_repo_cache'} . " " . $opts{"upstream_url"},
	    "remove" => $GCONN_COMMAND_PREAMBLE . " remove " . $opts{'gconn_repo_cache'},
	    "list" => $GCONN_COMMAND_PREAMBLE . " list ",
	    "reset" => "p4 -u " . $opts{'p4super'} . " -p " . $opts{"p4port"} . " repo -f -d " . $opts{'helix_repo_name'} . "; rm -rf /opt/perforce/git-connector/repos/" . $opts{'gconn_repo_cache'},
	   );
	    
print Dumper(\%cmds);

### TESTS

if (0) { #temporarily shut off the gconn tests
# Test 1 empty - add
print "About to run reset $cmds{'reset'}\n";
$retval = &run_cmd_server($opts{'login'},$cmds{'reset'});
					      
print Dumper($retval);

print "About to run add $cmds{'add'}\n";
$retval = &run_cmd_server($opts{'login'},$cmds{'add'});
print Dumper($retval);

sleep(10);

# Test 2 empty - remove
print "About to run reset $cmds{'reset'}\n";
$retval = &run_cmd_server($opts{'login'},$cmds{'reset'});
print Dumper($retval);

print "About to run remove $cmds{'remove'}\n";
$retval = &run_cmd_server($opts{'login'},$cmds{'remove'});
print Dumper($retval);
} #end if(0)

# Create a reuseable UserAgent
my $ua = LWP::UserAgent->new();
$ua->ssl_opts("verify_hostname" => 0, "SSL_verify_mode"=>0x00);

my $content_body = {
	       	"repo_name" => "//repo/public_repo",
	       "git_url" => "http://hsm-gitlabee.das.perforce.com/root/public_repo.git"
	      };


	     
$content_body=undef;
#my $request = HTTP::Request->new(POST=> $opts{"gconn_http_base"} . "-list");
my $request = create_http_request_gconn("POST",$opts{"gconn_http_base"} . "-list","application/json",$content_body);


my $response = $ua->request($request);
ok($response->is_success == 1, "A success");
like( $response->content, qr/No mirrored repos/, "No mirrored repos");
like( $response->status_line, qr/200/, "Success 200");




## Helper functions
sub create_http_request_gconn {
  my $method = shift;
  my $url = shift;
  my $content_type = shift;
  my $request_body = shift;

  my $request = HTTP::Request->new($method => $url);
  $request->header("Authorization" => "Basic bm9zdWNodXNlcjpub3N1Y2hwYXNzd29yZA==");
  $request->header("Content-Type" => $content_type);  
  if (defined($content_body)) {
    my $content_json = encode_json $content_body;
    $request->content($content_json);
  }

  return $request;
}



sub run_cmd_server {
  my $login = shift;
  my $cmd = shift;
  my $retval;

  print "login is $login\n";
  print "cmd is $cmd\n";
  
  sshopen3 $login, *SEND, *RECV, *ERRORS, "$cmd" or die "$0:ssh failure $1";

  my @ret = <RECV>;
  my @err = <ERRORS>;

  chomp(@ret);
  chomp(@err);
  
  push @{$retval}, @ret;
  push @{$retval}, @err;
  
  return $retval

}

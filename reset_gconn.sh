#!/bin/sh -x

#ssh root@osiris "p4 -usuper -p 1666 repo -f -d //repo/brepo;"
ssh root@osiris 'echo "Testing123" | p4 -u super -p 1666 login';
ssh root@osiris 'p4 -usuper -p 1666 -ztag repos | grep "... RepoName" | cut -f3 -d" " | xargs -n1 p4 -usuper -p 1666 repo -f -d;'
ssh root@osiris "rm -rf /opt/perforce/git-connector/repos/repo;"

#!/usr/bin/expect
set user "group1"
set ip [lindex $argv 0]
set password "#Keras\$2020"
set cmd [lindex $argv 1]
spawn ssh $user@$ip $cmd
expect "password"
send "$password\r"
interact
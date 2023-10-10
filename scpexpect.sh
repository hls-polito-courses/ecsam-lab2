#!/usr/bin/expect
set password "#Keras\$2020"
set src [lindex $argv 0]
set dst [lindex $argv 1]
spawn scp $src $dst
expect "password"
send "$password\r"
interact
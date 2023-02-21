#!/bin/bash

# export any environment variables

# run the program
/usr/bin/early-program-binary

# call systemd-notify to allow other services listed in 'before' variable to start
systemd-notify --ready --status="Done with early program"

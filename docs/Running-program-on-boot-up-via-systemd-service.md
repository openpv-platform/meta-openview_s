Quick steps to get an application or script to run on boot up as a service.
   - add a 'my-program.service' file to /lib/systemd/system/ where my-program is the name of the service you would like to add.
   - contents of the service file should look something like this:
```
[Unit]
Description=Briefly describe your service here

[Service]
ExecStart=bash -c /usr/bin/my-service-start.sh

[Install]
WantedBy=multi-user.target
```
   - the ExecStart variable is the main component because it points to an entry point for your service. In this case, we start a new bash process and run the my-service-start shell script.
      - We need to also make sure that the file we point the ExecStart variable to has execution permissions (it does not have to be saved to the bin folder):
```
user@RCDBoard:/# chmod +x /usr/bin/my-service-start.sh
```

   - Next, verify that the shell script that will run on boot up runs smoothly by doing a test run:
```
user@RCDBoard:/usr/bin# bash -c ./my-service-start.sh
```
   - now we must power cycle the board so that the service file is tracked by systemd
   - Now start the service with systemctl:
```
user@RCDBoard:/# systemctl start my-program
```
   - needs to be 'my-program' because we initially named the service file to be 'my-program.service'
      - if you get an error 'service not found' power cycle the board.
   - check the service status:
```
user@RCDBoard:/# systemctl status my-program
```
   - Note: the status command is also useful for debugging
   - Next enable the service on start up:
```
user@RCDBoard:/# systemctl enable my-program
```
   - You should see something like this:
```
user@RCDBoard:/# systemctl enable my-program

```
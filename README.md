## Setup
`cp mailconf_example.yaml "$HOME/.mailconf.yaml"`

`vim "$HOME/.mailconf.yaml"  # edit your mail config`

## Verify your settings
Option -P prints msmtp settings. Make sure your `PWDCMD` from `$HOME/.mailconf.yaml` outputs a non-empty string.
`echo | ./docker-msmtp_send_mail.sh bogus@email.com "Test" '' -P`

## Usage
`echo "Message body" | ./docker-msmtp_send_mail.sh user@gmail.com "Test mail"`

Email with attachments"
`./docker-msmtp_send_mail.sh user@gmail.com "Test mail with attachments" directory_with_attachments/ <<< "Message body"`


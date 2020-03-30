## Setup
`cp mailconf_example.yaml "$HOME/.mailconf.yaml"`
`vim "$HOME/.mailconf.yaml"  # edit your mail config`

## Usage
`echo "Message body" | ./docker-msmtp_send_mail.sh user@gmail.com "Test mail"`
`./docker-msmtp_send_mail.sh user@gmail.com "Test mail with attachments" directory_with_attachments/ <<< "Message body"`


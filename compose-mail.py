#!/usr/bin/env python3

## Based on https://docs.python.org/3/library/email.examples.html

"""Send the contents of a directory as a MIME message."""

import os, sys
#import smtplib
# For guessing MIME type based on file name extension
import mimetypes

from argparse import ArgumentParser

from email.message import EmailMessage
from email.policy import SMTP


def main():
    parser = ArgumentParser(description="""\
Sends the contents of a directory as a MIME message to output (default /dev/stdout).
""")
    parser.add_argument('-d', '--directory', required=False, default=None,
                        help="""Mail the contents of the specified directory,
                        otherwise use the current directory.  Only the regular
                        files in the directory are sent, and we don't recurse to
                        subdirectories.""")
    parser.add_argument('-o', '--output',default="/dev/stdout",
                        metavar='FILE',
                        help="""Print the composed message to FILE instead of
                        sending the message to the SMTP server.""")
    parser.add_argument('-f', '--from', required=True, dest="sender",
                        help='The value of the From: header (required)')
    parser.add_argument('-r', '--recipient', required=True,
                        action='append', metavar='RECIPIENT',
                        default=[], dest='recipients',
                        help='A To: header value (at least one required)')
    parser.add_argument('-s', '--subject', required=False, default=None, type=str,
                        help='Message Subject: field.')
    parser.add_argument('-m', '--message', required=False, default=None, type=str,
                        help='Message body. If - then the message is taken from stdin.')
    args = parser.parse_args()
    directory = args.directory
    #if not directory:
    #    directory = '.'
    # Create the message
    msg = EmailMessage()
    msg['Subject'] = args.subject if args.subject is not None else f'Contents of directory {directory}'
    msg['To'] = ', '.join(args.recipients)
    msg['From'] = args.sender
    msg.preamble = '' #You will not see this in a MIME-aware mail reader.\n'
    if args.message:
        if args.message=='-': 
            msg.set_content(sys.stdin.read())
        else:
            msg.set_content(args.message)
    
    if directory:
        for filename in os.listdir(directory):
            path = os.path.join(directory, filename)
            if not os.path.isfile(path):
                continue
            # Guess the content type based on the file's extension.  Encoding
            # will be ignored, although we should check for simple things like
            # gzip'd or compressed files.
            ctype, encoding = mimetypes.guess_type(path)
            if ctype is None or encoding is not None:
                # No guess could be made, or the file is encoded (compressed), so
                # use a generic bag-of-bits type.
                ctype = 'application/octet-stream'
            maintype, subtype = ctype.split('/', 1)
            with open(path, 'rb') as fp:
                msg.add_attachment(fp.read(),
                                   maintype=maintype,
                                   subtype=subtype,
                                   filename=filename)
    # Now send or store the message
    if args.output:
        with open(args.output, 'wb') as fp:
            fp.write(msg.as_bytes(policy=SMTP))
    else:
        assert(False)
        #with smtplib.SMTP('localhost') as s:
        #    s.send_message(msg)


if __name__ == '__main__':
    main()


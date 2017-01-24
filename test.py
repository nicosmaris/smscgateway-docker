import json
import requests
from requests.auth import HTTPBasicAuth

from re import search


class Messages(object):
    """
    status = Messages().http().status_code
    expected_status = 200
    assert status==expected_status, "Expected status %d but got %d at /SMS/Messages.json" % (expected_status, status)
    """
    sid = ''
    token = ''
    def __init__(self):
        #sid = open('sid').read().strip()
        #token = open('token').read().strip()
        sid = 'sid'
        token = 'token'
        self.sid = sid
        self.token = token
    def http(self, body_dict=None):
        """
        @type body_dict: dict
        @param body_dict: {To': dest, 'From': src, 'Body': text} to send SMS or None to get the list of SMS
        @rtype: requests.Response
        """
        #protocol_host_port = 'https://tadhack.restcomm.com'
        protocol_host_port = 'http://127.0.0.1:8080'
        auth = (self.sid, self.token)
        urlprefix = protocol_host_port + "/restcomm/2012-04-24/Accounts/" + self.sid
        endpoint = '/SMS/Messages.json'
        url = urlprefix + endpoint
        method = 'GET'
        if body_dict!=None:
            method = 'POST'
            body_dict = json.dumps(body_dict)
        response = requests.request(method, url, data=body_dict, timeout=120)
        return response


def line(regex, filepath):
    """
    Returns all lines that have the term or the empty string
    """
    result = ''
    counter = 0
    with open(filepath, 'r') as inF:
        counter += 1
        for line in inF:
            match = search(regex, line)
            if match:
                matched = match.group()
                if result==False:
                    result = "line %d: %s\n" % (counter, matched)
                else:
                    result += "line %d: %s\n" % (counter, matched)
    return result


def has(regex, filepath):
    start_msg = line(regex, filepath)
    assert start_msg!='', "Expected a line with %s" % regex


def has_not(regex, filepath):
    failed_to_start_msg = line(regex, filepath)
    assert failed_to_start_msg=='', "Expected the file %s to have no line with %s but found: %s" % (filepath, regex, failed_to_start_msg)


def main():
    has("INFO.*org.jboss.bootstrap.microcontainer.ServerImpl.*JBoss.*Started", 'server.log')
    has_not("Not all SBB are running now", 'server.log')


if __name__=='__main__':
    main()


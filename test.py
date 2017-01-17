import json
import requests
from requests.auth import HTTPBasicAuth


class Messages(object):
    sid = ''
    token = ''
    def __init__(self, sid, token):
        self.sid = sid
        self.token = token
    def http(self, body_dict=None):
        """
        @type body_dict: dict
        @param body_dict: {To': dest, 'From': src, 'Body': text} to send SMS or None to get the list of SMS
        @rtype: requests.Response
        """
        #host = 'tadhack.restcomm.com'
        host = '127.0.0.1:8080'
        auth = (self.sid, self.token)
        urlprefix = "https://%s/restcomm/2012-04-24/Accounts/%s" % (host, self.sid)
        endpoint = '/SMS/Messages.json'
        url = urlprefix + endpoint
        method = 'GET'
        if body_dict!=None:
            method = 'POST'
            body_dict = json.dumps(body_dict)
        response = requests.request(method, url, data=body_dict, timeout=120)
        return response

def main():
    #sid = open('sid').read().strip()
    #token = open('token').read().strip()
    sid = 'sid'
    token = 'token'
    smsc = Messages(sid, token)
    status = smsc.http().status_code
    assert status==401, "Expected status 401 but got %d at /SMS/Messages.json" % status

if __name__=='__main__':
    main()


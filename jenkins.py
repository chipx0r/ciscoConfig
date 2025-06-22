import urllib, urllib2, base64
targetbranch = 'UAT'
username = 'admin'
password = 'tokenpass'
jenkinsproject = 'AspNet8DockerBuild'
jenkinstoken = 'uat'

def doCall():
    base64string = base64.b64encode('%s:%s' % (username, password))
   url = 'http://192.168.4.16:8080/job/' + jenkinsproject + '/build?token=' + jenkinstoken
    print 'CI-CD trigger:' + url
    req = urllib2.Request(url)
    req.add_header('Authorization', 'Basic %s' % base64string)
    rsp = urllib2.urlopen(req, timeout=10)


def calljenkins(ui, repo, node, **kwargs):
    send = False
    for rev in xrange(repo[node].rev(), len(repo)):
        ctx = repo[rev]
        if ctx.branch() == targetbranch:
            send = True

    if send:
        doCall()
    else:
        print 'No CI-CD trigger'

    pass


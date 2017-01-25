from re import search


def line(regex, filepath):
    """
    Returns all lines that have the term or the empty string
    """
    result = ''
    counter = 0
    with open(filepath, 'r') as inF:
        for line in inF:
            counter += 1
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
    assert start_msg!='', "Expected a line with %s\n\n%s\n\n%s" % (regex, filepath, open(filepath).read())


def has_not(regex, filepath):
    failed_to_start_msg = line(regex, filepath)
    assert failed_to_start_msg=='', "Expected the file %s to have no line with %s but found: %s\n\n%s" % (filepath, regex, failed_to_start_msg, open(filepath).read())


def main():
    # =Association [name=ass1, associationType=SERVER, ipChannelType=SCTP, hostAddress=, hostPort=0, peerAddress=127.0.0.1, peerPort=8011, serverName=serv1, extraHostAddress=[]]
    expressions = [
        'INFO.*StackImpl.*Started.*DIAMETER.*',
        'INFO.*ServerImpl.*Started.*Server',
        'INFO.*ManagementImpl.*Started SCTP',
        'INFO.*AssociationImpl.*Started Association',
        'INFO.*M3UAManagementImpl.*Started M3UAManagement',
        'INFO.*RouterImpl.*Started SCCP Router',
        'INFO.*SccpResourceImpl.*Started Sccp Resource',
        'INFO.*SmppManagement.*Started SmppManagement',
        'INFO.*SmppShellExecutor.*Started SmppShellExecutor SmppManagement',
        'INFO.*HttpUsersManagement.*Started of HttpUsersManagement',
        'WARN.*SmscManagement.*Started SmscManagemet SmscManagement',
        'INFO.*SMSCShellExecutor.*Started SMSCShellExecutor SmscManagement',
        'INFO.*Ss7Management.*Started ...',
        'INFO.*CounterProviderManagement-CounterHost.*Started ...',
        'INFO.*TcapManagementJmx-TcapStack.*Started ...',
        'INFO.*SmscStatProviderJmx-SMSC.*SmscStatProviderJmx Started ...',
        'INFO.*org.jboss.bootstrap.microcontainer.ServerImpl.*JBoss.*Started'
    ]
    for expression in expressions:
        has(expression, 'server.log')


if __name__=='__main__':
    main()

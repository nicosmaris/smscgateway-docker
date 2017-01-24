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
    has("INFO.*org.jboss.bootstrap.microcontainer.ServerImpl.*JBoss.*Started", 'server.log')
    has_not(".*Not all SBB are running now.*", 'server.log')


if __name__=='__main__':
    main()

# Create your views here.

from django.http import HttpResponse
from django.http import Http404
from django.shortcuts import render_to_response, get_object_or_404

import sys
import commands
import os
import tempfile

def index(request):
    output = 'XSPARQLer REST interface. You must provide an XSPARQL query as GET or POST parameter.'
    return HttpResponse(output)


def query(request):
    # Detect if a SPARQL endpoint is provided
    sparql_endpoint_cmd = ''
    try:
        if request.GET['endpoint'] != '':
            sparql_endpoint_cmd = ' --endpoint ' + request.GET['endpoint']
    except:
        None

    try:
        # XSPARQLer/YACC requires the query to be in ascii
        q = request.GET['query'].encode('ascii')
    except:
        return HttpResponse('You must provide a query parameter.')


    # Store the query into a temp file
    # mkstemp() does not delete temp files. We keep them for now for debugging purposes
    (query_file, query_file_name) = tempfile.mkstemp('.xsparql')

    query_file = os.fdopen(query_file, "w+b")
    query_file.write(q)
    query_file.flush()
    online_interface_path = '/home/xsparql/xsparql/online-interface'
    os.chdir(online_interface_path)

    output = commands.getoutput('./xsparqlrewrite --eval --saxon ' + query_file_name)
    return HttpResponse(output, mimetype="application/xml")


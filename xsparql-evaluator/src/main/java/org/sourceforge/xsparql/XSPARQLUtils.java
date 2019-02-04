package org.sourceforge.xsparql;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.om.*;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import org.apache.jena.query.ResultSet;
import org.apache.jena.query.ResultSetFormatter;

import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

public class XSPARQLUtils {

    @SuppressWarnings({ "unchecked", "rawtypes" })
    public static Sequence resultSetToSequenceIterator(final ResultSet resultSet, final XPathContext context) throws XPathException {

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        ResultSetFormatter.outputAsXML(outputStream, resultSet);
        ByteArrayInputStream inputStream = new ByteArrayInputStream(outputStream.toByteArray());

        DocumentInfo documentInfo = context.getConfiguration().buildDocument(new StreamSource(inputStream));
        return SequenceTool.asItem(documentInfo);
    }
}

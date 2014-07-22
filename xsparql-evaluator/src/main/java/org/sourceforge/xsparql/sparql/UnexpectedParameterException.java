package org.sourceforge.xsparql.sparql;

public class UnexpectedParameterException extends Exception {
	public UnexpectedParameterException(String message) {
		super(message);
	}

	public UnexpectedParameterException(String key, String value) {
		super("The property ("+key+ ","+value+") can not be managed by the system");
	}
}

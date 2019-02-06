package org.sourceforge.xsparql.rewriter;

import org.antlr.runtime.tree.Tree;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

public class TreePrinter {

    private final ByteArrayOutputStream os = new ByteArrayOutputStream();
    private final PrintStream ps = new PrintStream(os);

    public String print(final Tree tree) {

        walk(tree, "");
        return os.toString();
    }

    private void walk(final Tree parent, final String prefix) {

        for (int index = 0; index < parent.getChildCount(); index++) {
            final Tree child = parent.getChild(index);

            if (index == parent.getChildCount() - 1) {
                ps.println(prefix + "└── " + getText(child));
                if (hasChildren(parent)) {
                    walk(child, prefix + "    ");
                }
            } else {
                ps.println(prefix + "├── " + getText(child));
                if (hasChildren(parent)) {
                    walk(child, prefix + "│   ");
                }
            }
        }
    }

    private boolean hasChildren(final Tree tree) {
        return tree.getChildCount() == 0 ? false : true;
    }

    private String getText(final Tree tree) {
        if(tree.getText() == null) {
            return "NULL";
        } else {
            return tree.getText().replaceAll("\n", "\\\\n");
        }
    }
}
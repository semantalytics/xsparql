package org.sourceforge.xsparql.rewriter;

import org.antlr.runtime.tree.Tree;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.PrintStream;

public class TreePrinter {
    private int dirCount;
    private int fileCount;
    private ByteArrayOutputStream os = new ByteArrayOutputStream();
    private PrintStream ps = new PrintStream(os);

    public TreePrinter() {
        this.dirCount = 0;
        this.fileCount = 0;
    }

    public String print(Tree tree) {
        walk(tree, "");
        return os.toString();
    }

    private void register(Tree file) {
        if (file.getChildCount() != 0) {
            this.dirCount += 1;
        } else {
            this.fileCount += 1;
        }
    }

    private void walk(Tree folder, String prefix) {
        Tree file;

        for (int index = 0; index < folder.getChildCount(); index++) {
            file = folder.getChild(index);
            register(file);

            if (index == folder.getChildCount() - 1) {
                ps.println(prefix + "└── " + file.getText());
                if (file.getChildCount() != 0) {
                    walk(file, prefix + "    ");
                }
            } else {
                ps.println(prefix + "├── " + file.getText());
                if (file.getChildCount() != 0) {
                    walk(file, prefix + "│   ");
                }
            }
        }
    }
}
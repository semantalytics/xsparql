/**
 *
 * Copyright (C) 2014, NUI Galway, WU Wien, Politecnico di Milano, 
 * Vienna University of Technology
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * The names of the COPYRIGHT HOLDERS AND CONTRIBUTORS may not be used
 *     to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * Created on 20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio 
 * on behalf of Politecnico di Milano, Stefan Bischof on behalf of Vienna 
 * University of Technology,  Nuno Lopes on behalf of NUI Galway.
 *
 */  

package org.sourceforge.xsparql.test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.LinkedList;
import java.util.List;

public class Utils {
	/**
	 * "Transform" a file on the classpath into a BufferedReader
	 * 
	 * @param filename
	 * @return
	 */
	public static BufferedReader loadReaderFromClasspath(Class c, String filename) {
		return new BufferedReader(new InputStreamReader(c.getClassLoader()
				.getResourceAsStream(filename)));
	}

	/**
	 * "Transform" a file on the classpath into a BufferedReader
	 * 
	 * @param filename
	 * @return
	 */
	public static BufferedReader loadReaderFromClasspath(String filename) {
		try {
			return new BufferedReader(new FileReader(new File(filename)));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	/**
	 * List files contained in a directory in the classpath
	 */
	public static List<String> listFiles(Class c, String dirname) {
		List<String> filenames = new LinkedList<String>();

		InputStream is = c.getClassLoader().getResourceAsStream(dirname); 
		//getClass().getClassLoader().getResourceAsStream(dirname);
		if (is != null) {
			BufferedReader rdr = new BufferedReader(new InputStreamReader(is));
			String line;
			try {
				while ((line = rdr.readLine()) != null) {
					filenames.add(dirname + "/" + line);
				}
			} catch (IOException e) {
				e.printStackTrace();
			} finally {
				try {
					rdr.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return filenames;
	}
	public static List<String> listFiles(String dirName, String extension, boolean subfolders){
		List<String> filenames = new LinkedList<String>();

		File dir = new File(dirName); 
		if (dir.exists() && dir.isDirectory()) {

			for(String fileName : dir.list()){
				File f = new File(dir+File.separator+fileName);
				if(fileName.endsWith(extension) && f.isFile()){
					filenames.add(dir+File.separator+fileName);
				} else if(f.isDirectory()){
					filenames.addAll(listFiles(f.getAbsolutePath(), extension, subfolders));
				}
			} 
		}
		return filenames;
	}
}
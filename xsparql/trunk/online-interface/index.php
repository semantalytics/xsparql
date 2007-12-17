<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>

<head>
    <title>XSPARQL: Smooth Transformations between XML and RDF</title>
    <link rel="stylesheet" type="text/css" href="style.css" />
    <script type="text/javascript" src="code/prototype.lite.js"></script>
    <script type="text/javascript" src="code/moo.fx.js"></script>
    <script type="text/javascript" src="code/moo.fx.pack.js"></script>
    <script type="text/javascript" src="code/moo.ajax.js"></script>
    <script type="text/javascript" src="code/common.js"></script>
</head>

<!-- body onload="initPosition(document.getElementById('query'))" -->
<body>
   <div>
    <table border="0" cellpadding="10" cellspacing="0" width="100%">
    <tbody>
     <tr>
       <td class="withoutBG" align="left"> 
    <h2>XSPARQL: Smooth transformations between XML and RDF</h2>
    <p>Team: <a href="http://www.polleres.net">Axel Polleres</a>, <a href="http://www.postsubmeta.net">Thomas Krennwallner</a>, <a href="http://www.deri.ie/about/team/member/waseem_akhtar/">Waseem Akhtar</a><br/>
    Technical report available <a href="http://www.polleres.net/TRs/DERI-TR-2007-12-14.pdf">here</a>.<br/><br/>
    <i>The greatest thing since sliced bread when it comes to slice your data!</i></p>
      </td>
       <td class="withoutBG" align="left"> 
           <img src="images/XSPARQLLogo.png" alt="XSPARQLLogo"/>
       </td>
    </tr>
  </tbody>
 </table>
    </div>
    <div style="clear: both;"></div>
    </div>
<div id="Wrapper">

    <div class="examplecol">
        <p>Examples:</p>
    <?
        $path = "./examples/";
        $directory = dir($path); 
        $directories_array = array();

        while ($file = $directory->read())
            if (is_dir($path.$file) && ($file != ".") && ($file != "..") && ($file != "CVS"))
                $directories_array[] = $file;

        sort($directories_array);

        foreach ($directories_array as $file)
        {
            // read content of this example directory
            echo "<div class=\"stretchtoggle\"><a href=\"#$file\">$file</a></div>\n";

            $exdirpath = $path.$file."/";
            $exdir = dir($exdirpath); 
            $exfiles_array = array();
            while ($exfile = $exdir->read())
            {
                if (is_file($exdirpath.$exfile) && 
                    ($exfile[0] != ".") && 
                    ($exfile != "CVS") &&
                    ((substr($exfile,-7,7) == "xsparql") || (substr($exfile,-6,6) == "sparql") ||
                     (substr($exfile,-6,6) == "xquery") || (substr($exfile,-2,2) == "xq")))
                {
                    $exfiles_array[] = $exfile;
                }
            }

            sort($exfiles_array);

            echo "<div class=\"stretcher\">\n";
            foreach($exfiles_array as $value)
            {
                $fname = substr($value, 3);
                echo "<span class=\"examplelink\">&nbsp;<a href=\"#\" onClick=\"javascript:loadfile('$exdirpath$value'); return false;\">$fname</a></span><br/>\n";
            }

            echo "</div>\n";
        }
        $directory->close();

    ?>

    <script type="text/javascript">
    /*
     * examples-accordion:
     */
    var myDivs = document.getElementsByClassName('stretcher');
    var myLinks = document.getElementsByClassName('stretchtoggle');
    var myAccordion = new fx.Accordion(myLinks, myDivs, {opacity: true});
    </script>

    </div> <!-- example column -->

    <div class="maincol">

        <!-- next two divs are for ie bug! -->
        <div style='width: 95%;'><div>
        <!-- set top margin to 5px for cropped buttons bug on ie! -->
        <p style='margin-top: 5px;'>Do you want to only rewrite the Query or also Evaluate it?&nbsp;
        <span class="solverbutton" 
              id="rewrite"
              onClick="javascript:togglesolver(this.id);"><a href="#">Rewrite</a></span>
        <span class="solverbutton"
              id="evaluate"
              onClick="javascript:togglesolver(this.id);"><a href="#">Rewrite+Evaluate</a></span><br/><br/>
	<span id="uri">Load Query from URI:&nbsp;
              <input id="URI" type="text" style="width: 400px;" /></span>
        </p>

        <textarea id="query"
                  wrap="off" style="height: 250px;width: 540px;margin-bottom: 10px;">%%% enter your XSPARQL query here %%%</textarea>
                  <!-- name="querytextarea"
                  onmouseup="updatePosition(this)"
                  onmousedown="updatePosition(this)"
                  onkeyup="updatePosition(this)"
                  onkeydown="updatePosition(this)"
                  onfocus="updatePosition(this)" -->
        </div>
        </div>
        <!--
        Line:&nbsp;<span id='txtline'>0</span>&nbsp;
        Column:&nbsp;<span id='txtcol'>0</span><br/>
        -->

        <div style="text-align: left;">
            <span id="evalbutton"><b><a href="#" onClick="javascript:evalquery(); return false;">[ Run it! ]</a></b></span>
	    <a href="#" onClick="javascript:clearquery(); return false;">[clear]</a>
        </div>

        <div id="result"></div>

    <!--
    <div style="clear: both;"></div>
    -->

    </div> <!-- maincol -->

</div> <!-- Wrapper -->

</body>

<script type="text/javascript">
    solverToSet = "evaluate";
    togglesolver(solverToSet);
</script>

</html>

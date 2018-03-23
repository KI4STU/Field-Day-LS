<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Field Day Log Server</title>

    <link rel="shortcut icon" type="image/png" href="/favicon.png"/>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/toastr.min.css" rel="stylesheet">
    <link href="css/jquery.dataTables.min.css" rel="stylesheet">
    <link href="css/sticky-footer-navbar.css" rel="stylesheet">

    <style>
    body {
        padding-top: 70px;
    }
    </style>
</head>

<body>

    <!-- Navigation -->
    <nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
        <div class="container">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="/">FDLS</a>
            </div>
            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                <ul class="nav navbar-nav">
                    <li>
                        <a href="summary.php">Summary</a>
                    </li>
                    <li>
                        <a href="https://github.com/KI4STU/Field-Day-LS">About</a>
                    </li>
                    <li>
                        <a href="mailto:k4iz@arrl.net">Contact</a>
                    </li>
                </ul>
            </div>
            <!-- /.navbar-collapse -->
        </div>
        <!-- /.container -->
    </nav>

    <!-- Page Content -->
    <div class="container">

        <div class="row">
            <div class="col-lg-12 text-center">
                <h1>Field Day Log Server</h1>
                <p class="lead" id="currUTC">&nbsp;</p>
            </div>
        </div>
        <!-- /.row -->

        <div class="row">
            <div class="col-md-4">
              <div class="row">
                <div class="col-md-12">
                  <div class="panel panel-primary">
                    <div class="panel-heading">Contact Summary</div>
                    <div class="panel-body"><ul id="summary"></div>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-md-12">
                  <div class="panel panel-primary">
                    <div class="panel-heading">Operations</div>
                    <div class="panel-body">
                      <button class="btn btn-primary" id="btnExport">Export CSV</button>
                      <button class="btn btn-warning" id="btnReboot">Reboot</button>
                      <button class="btn btn-danger" id="btnShutdown">Shutdown</button>
                    </div>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-md-12">
                  <div class="panel panel-primary">
                    <div class="panel-heading">Uptime</div>
                    <div class="panel-body" id="uptime">&nbsp;</div>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-md-12">
                  <div class="panel panel-primary">
                    <div class="panel-heading">Key Processes</div>
                    <div class="panel-body"><ul id="proc"></div>
                  </div>
                </div>
              </div>

            </div>

            <div class="col-md-8">
              <div class="row">
                <div class="col-md-12">
                  <div class="panel panel-primary">

                    <div class="panel-heading">Contacts</div>
                    <div class="panel-body">
                      <table id="contacts" class="display" cellspacing="0" width="100%">
                        <thead>
                            <tr>
				<th>Time</th>
                                <th>Band</th>
                                <th>Mode</th>
                                <th>Call</th>
                                <th>Class</th>
                                <th>Section</th>
                            </tr>
                        </thead>
                      </table>
                    </div>

                  </div>
                </div>
              </div>
            </div>


        </div>
        <!-- /.row -->

    </div>

    <footer class="footer">
      <div class="container">
        <p class="text-muted"></p>
      </div>
    </footer

    <!-- /.container -->

    <script src="js/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/moment.min.js"></script>
    <script src="js/bootbox.min.js"></script>
    <script src="js/toastr.min.js"></script>
    <script src="js/jquery.dataTables.min.js"></script>
    <script type="text/javascript">
      var cTable;
      <!-- Let's just inline this stuff... -->
      $( document ).ready(function() {
        console.log("ready");

        toastr.options = {
          "closeButton": false,
          "debug": false,
          "newestOnTop": false,
          "progressBar": false,
          "positionClass": "toast-bottom-right",
          "preventDuplicates": false,
          "onclick": null,
          "showDuration": "300",
          "hideDuration": "1000",
          "timeOut": "5000",
          "extendedTimeOut": "1000",
          "showEasing": "swing",
          "hideEasing": "linear",
          "showMethod": "fadeIn",
          "hideMethod": "fadeOut"
        }

        updateUTC();
        setInterval(updateUTC, 1000);
        updateUptime();
        setInterval(updateUptime, 10000);
        updateProc();
        setInterval(updateProc, 6000);
	updateSummary();
        setInterval(updateSummary, 30000);
//	updateContacts();
//       setInterval(updateContacts, 30000);

        cTable = $('#contacts').DataTable( {
          "ajax": '/api/contacts.php',
          "order": [[ 0, "desc" ]]
	});
	setInterval(updateContacts, 30000);
      });

     function updateContacts() {
        console.log("reloading contacts");
        cTable.ajax.reload();
      }

      function updateSummary() {
        sumlist = "";
        $.getJSON( "/api/summary.php", function( data ) {
          $.each( data.summary, function( key, val ) {
            //sumlist = sumlist + '<li>' + val + '</li>';
            sumlist = sumlist + val + '<br>';
          });
          $("#summary").html(sumlist);
        });
      }

      function updateUTC() {
        $("#currUTC").text("UTC Time: " + moment().format('YYYY-MM-DDTHH:mm:ss'));
      }

      function updateUptime() {
        $.getJSON( "/api/uptime.php", function( data ) {
          $("#uptime").html(data.uptime.replace(",  load", "<br>load"));
        });
      }

      function updateProc() {
        newlist = "";
        $.getJSON( "/api/proc.php", function( data ) {
          $.each( data.proc, function( key, val ) {
            newlist = newlist + '<li>' + val + '</li>';
          });
          $("#proc").html(newlist);
        });
      }
      
      $("#btnExport").click(function() {
        window.open('/api/export.php', '_blank');
      });

      $("#btnReboot").click(function() {
        bootbox.confirm("Are you sure you want to reboot?", function(result){ 
          if (result == true) {
            $.getJSON( "/api/reboot.php", function( data ) {
              toastr["info"](data.result)
            });
          }
        })
      });
      
      $("#btnShutdown").click(function() {
        bootbox.confirm("Are you sure you want to shutdown? This is permanent until power cycle.", function(result){ 
          if (result == true) {
            $.getJSON( "/api/shutdown.php", function( data ) {
              toastr["error"](data.result)
            });
          }
        })
      });
    </script>

</body>

</html>


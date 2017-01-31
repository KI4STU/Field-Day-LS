# Field-Day-LS

HamLog (for Android and iOS), HamLogFD (for OSX), and HamLogFDS (for OSX) were written by Pignology, LLC (http://pignology.net/).
They can act as standalone applications, and all support ARRL Field Day logging. HamLogFDS is intended to be a server to which
HamLog and HamLogFD clients connect, creating a central logging point for Field Day. Logging clients maintain a local copy of log entries, perform dupe checking, section validation, and have the ability to send logs to a HamLogFDS server.

HamLog for Android lacks the ability to export Field Day logs in adif format, or save them to an sdcard. This presents a concern
when operating during Field Day. Should a logger go down and need to be replaced, there is no simple way to restore the contacts
onto a new device. Internet connectivty and something like email service would be required to facilite the export, and even then
there is no way to import the data back into another logging device. The HamLogFDS server solves this problem by storing logs
from all clients centrally. As they connect, clients make a request to receive a copy of all logs that the server has. This
provides resiliancy without the need for extensive network infrastructure. While the HamLogFDS server also does not allow for
the export of log data in the adif format, it does allow export in csv format. This can readily be converted to adif, and because
the logs are centrally located there is no concern over having to merge multiple files first.

While the HamLogFDS server presents a tidy solution, powering a Macintosh machine for 24+ hours to serve as the log server would
require external power. Macbook AC power supplies are inherently RF noisy, and would require 120vac from some source, likely a
generator or inverter. Inverters are often also RF noisy, and generators can be no only RF noisy, but also produce a significant
of localized AF noise and air pollution. Because of this, it would be beneficial to operate a log server from battery or
alternative power sources.

The communications between the clients and server are fairly simple. Clients occasionally send requests to the server, and send
new log entries to the server whenever they are made. The server sends new log entries to all clients as they come in, as well
as sending all logs to a client when requested. It is therefore possible to implement a server written in perl on a
linux-based machine. Prevalance, low power consumption, and low cost make the Raspberry Pi an ideal server platform.

The first goal of this script is intended to be listen-only. That is, it will receive logs from multiple clients but
will ignore requests to send data back to the clients. This goal has been met.

The second goal will be bidirectional communication. Ideally, when a client sends a log entry to the server, the server will
then push that log entry back out to all clients. This will facilitate the native dupe checking inherent in the client software.
It will also provide additional log backups (the server as well as all clients should end up with a copy of all logs from the
event). This goal has been partially met: the server can send log data back to clients upon request, but does not proactively
send new log entries received from one client to the other clients.

Ensuring only one transceiver is being operated per band is left up to the operators: the HamLog software currently provides no
provisions for lockout or notification if two stations are set to log on the same band and mode.

#!/usr/bin/env ruby
### dict.rb --- RFC 2229 client for ruby.
## Copyright 2002,2003 by Dave Pearson <davep@davep.org>
## $Revision: 1.10 $
##
## dict.rb is free software distributed under the terms of the GNU General
## Public Licence, version 2. For details see the file COPYING.

### Commentary:
##
## The following code provides a set of RFC 2229 client classes for ruby.
## See <URL:http://www.dict.org/> for more details about dictd.

### TODO:
##
## o Add support for AUTH.

# We need sockets.
require "socket"

############################################################################
# Dictionary error class.
class DictError < RuntimeError
end

############################################################################
# Dict utility code.
module Dict

  # Default host.
  DEFAULT_HOST = "www.dict.org"

  # Default port.
  DEFAULT_PORT = 2628

  # End of line marker.
  EOL = "\r\n"

  # End of data marker
  EOD = "." + EOL

  # The special database names.
  DB_FIRST = "!"
  DB_ALL   = "*"

  # The guaranteed match strategies.
  MATCH_DEFAULT = "."
  MATCH_EXACT   = "exact"
  MATCH_PREFIX  = "prefix"

  # The various response numbers.
  RESPONSE_DATABASES_FOLLOW    = 110
  RESPONSE_STRATEGIES_FOLLOW   = 111
  RESPONSE_INFO_FOLLOWS        = 112
  RESPONSE_HELP_FOLLOWS        = 113
  RESPONSE_SERVER_INFO_FOLLOWS = 114
  RESPONSE_DEFINITIONS_FOLLOW  = 150
  RESPONSE_DEFINITION_FOLLOWS  = 151
  RESPONSE_MATCHES_FOLLOW      = 152
  RESPONSE_CONNECTED           = 220
  RESPONSE_OK                  = 250
  RESPONSE_NO_MATCH            = 552
  RESPONSE_NO_DATABASES        = 554
  RESPONSE_NO_STRATEGIES       = 555

  # Get the reply code of the passed text.
  def replyCode( text, default = nil )

    if text =~ /^\d{3} /
      text.to_i
    elsif default
      default
    else
      raise DictError.new(), "Invalid reply from host \"#{text}\"."
    end

  end

  # replyCode should be private.
  private :replyCode

end

############################################################################
# Dict base class.
class DictBase
  # Mixin the Dict utility code.
  include Dict
end

############################################################################
# Dictionary definition class.
class DictDefinition < Array

  # Mixin the Dict utility code.
  include Dict

  # Constructor
  def initialize( details, conn )

    # Call to the super.
    super()

    # Split the details out.
    details     = /^\d{3} "(.*?)"\s+(\S+)\s+"(.*)"/.match( details )
    @word       = details[ 1 ]
    @database   = details[ 2 ]
    @name       = details[ 3 ]

    # Read in the definition.
    while ( reply = conn.readline() ) != EOD
      push( reply.chop() )
    end

  end

  # Access to the word
  def word
    @word
  end

  # Access to the database
  def database
    @database
  end

  # Access to the database name
  def name
    @name
  end

  # Return an array of words you should also see in regard to this definition.
  def seeAlso
    join( " " ).scan( /\{(.*?)\}/ )
  end

end

############################################################################
# Dictionary definition list class.
class DictDefinitionList < Array

  # Mixin the Dict utility code.
  include Dict

  # Constructor
  def initialize( conn )

    # Call to the super.
    super()

    # While there's a definition to be had...
    while replyCode( reply = conn.readline() ) == RESPONSE_DEFINITION_FOLLOWS
      # ...add it to the list.
      push( DictDefinition.new( reply, conn ) )
    end

  end

end

############################################################################
# Base dictionary array class.
class DictArray < Array

  # Mixin the Dict utility code.
  include Dict

  # Constructor
  def initialize( conn )

    # Call to the super.
    super()

    # While there's a match to be had...
    while replyCode( reply = conn.readline(), 0 ) != RESPONSE_OK
      # ...add it to the list.
      push( reply ) if reply != EOD
    end

  end

end

############################################################################
# Class for holding a dictionary item in a dictionary array.
class DictArrayItem

  # Constructor.
  def initialize( text )
    match        = /^(\S+)\s+"(.*)"/.match( text )
    @name        = match[ 1 ]
    @description = match[ 2 ]
  end

  # Access to the name.
  def name
    @name
  end

  # Access to the description.
  def description
    @description
  end

end

############################################################################
# Dictionary item array class.
class DictItemArray < DictArray

  # Push the text as a DictArrayItem.
  def push( text )
    super( DictArrayItem.new( text ) )
  end

end

############################################################################
# Dict client class.
class DictClient < DictBase

  # Constructor.
  def initialize( host = DEFAULT_HOST, port = DEFAULT_PORT )
    @host   = host
    @port   = port
    @conn   = nil
    @banner = nil
  end

  # Read-only access to the host.
  def host
    @host
  end

  # Read-only access to the port.
  def port
    @port
  end

  # Are we connected?
  def connected?
    @conn != nil
  end

  # Check if there's a connected, throw an error if there isn't one.
  def checkConnection
    unless connected?
      raise DictError.new(), "Not connected."
    end
  end

  # checkConnection should be private.
  private :checkConnection

  # Send text to the server
  def send( text )
    checkConnection()
    @conn.write( text + EOL )
  end

  # send should be private.
  private :send

  # Connect to the host.
  def connect

    # Are we already connected?
    if connected?
      # Yes, throw an error.
      raise DictError.new(), "Attempt to connect a conencted client."
    else

      # Nope, open a connection
      @conn = TCPSocket.open( host, port )

      # Get the banner.
      @banner = @conn.readline()

      # Valid return value?
      unless replyCode( @banner ) == RESPONSE_CONNECTED
        raise DictError.new(), "Connection refused \"#{@banner}\"."
      end

      # Now we announce ourselves to the server.
      send( "client org.davep.dict.rb $Revision: 1.10 $ <URL:http://www.davep.org/misc/dict.rb>" )
      unless replyCode( reply = @conn.readline() ) == RESPONSE_OK
        raise DictError.new(), "Client announcement failed \"#{reply}\""
      end

      # If we were passed a block, yield to it
      yield self if block_given?

    end

  end

  # Disconnect.
  def disconnect

    # Are we connected?
    if connected?
      # Yes, close the connection
      send( "quit" )
      @conn.close()
      @conn   = nil
      @banner = nil
    else
      # No, throw an error.
      raise DictError.new(), "Attempt to disconnect a disconnected client."
    end

  end

  # Return the banner we were handed.
  def banner
    checkConnection()
    @banner
  end

  # Core code for array oriented command.
  def arrayCommand( command, array_class, good, bad = nil )

    # Send the command
    send( command )

    # Worked?
    if replyCode( reply = @conn.readline() ) == good
      # Yes, load up the array
      array_class.new( @conn )
    elsif bad and replyCode( reply ) == bad
      # "Bad" response, return an empty array
      Array.new()
    else
      # Something else, throw an error.
      raise DictError.new(), reply
    end

  end

  # arrayCommand is private.
  private :arrayCommand

  # Define a word.
  def define( word, database = DB_ALL )
    arrayCommand( "define #{database} \"#{word}\"", DictDefinitionList, RESPONSE_DEFINITIONS_FOLLOW, RESPONSE_NO_MATCH )
  end

  # Match a word.
  def match( word, strategy = MATCH_DEFAULT, database = DB_ALL )
    arrayCommand( "match #{database} #{strategy} \"#{word}\"", DictItemArray, RESPONSE_MATCHES_FOLLOW, RESPONSE_NO_MATCH )
  end

  # Get a list of available databases.
  def databases
    arrayCommand( "show db", DictItemArray, RESPONSE_DATABASES_FOLLOW, RESPONSE_NO_DATABASES )
  end

  # Get a list of available strategies.
  def strategies
    arrayCommand( "show strat", DictItemArray, RESPONSE_STRATEGIES_FOLLOW, RESPONSE_NO_STRATEGIES )
  end

  # Get the information for a given database.
  def info( database )
    arrayCommand( "show info \"#{database}\"", DictArray, RESPONSE_INFO_FOLLOWS )
  end

  # Get information about the server.
  def server
    arrayCommand( "show server", DictArray, RESPONSE_SERVER_INFO_FOLLOWS )
  end

  # Get help from the server.
  def help
    arrayCommand( "help", DictArray, RESPONSE_HELP_FOLLOWS )
  end

end

############################################################################
# Provide a dict command.
if $0 == __FILE__

  # We're going to use long options.
  require "getoptlong"

  # Command result
  result = 1

  # Setup the default parameters.
  $params = {
    :host       => ENV[ "DICT_HOST" ]  || Dict::DEFAULT_HOST,
    :port       => ENV[ "DICT_PORT" ]  || Dict::DEFAULT_PORT,
    :database   => ENV[ "DICT_DB" ]    || Dict::DB_ALL,
    :strategy   => ENV[ "DICT_STRAT" ] || Dict::MATCH_DEFAULT,
    :match      => false,
    :dbs        => false,
    :strats     => false,
    :serverhelp => false,
    :info       => nil,
    :serverinfo => false,
    :help       => false,
    :licence    => false
  }

  # Print the help screen.
  def printHelp
    print "dict.rb v#{/(\d+\.\d+)/.match( '$Revision: 1.10 $' )[ 1 ]}
Copyright 2002,2003 by Dave Pearson <davep@davep.org>
http://www.davep.org/

Supported command line options:

  -h --host <host>         Specify the host to be contacted
                           (default is \"#{Dict::DEFAULT_HOST}\").
  -p --port <port>         Specify the port to be connected
                           (default is #{Dict::DEFAULT_PORT}).
  -d --database <db>       Specity the database to be searched
                           (default is \"#{Dict::DB_ALL}\").
  -m --match               Perform a match instead of a define.
  -s --strategy <strat>    Specity the strategy to use for the match/define
                           (default is \"#{Dict::MATCH_DEFAULT}\").
  -D --dbs                 List databases available on the server.
  -S --strats              List stratagies available on the server.
  -H --serverhelp          Display the server's help.
  -i --info <db>           Display information about a database.
  -I --serverinfo          Display information about the server.
     --help                Display this help.
  -L --licence             Display the licence for this program.

Supported environment variables:

  DICT_HOST                Specify the host to be contacted.
  DICT_PORT                Specify the port to be connected.
  DICT_DB                  Specify the database to be searched.
  DICT_STRAT               Specify the strategy to use for the match/define.

"
  end

  # Print the licence.
  def printLicence
   print "dict.rb - RFC 2229 client for ruby.
Copyright (C) 2002,2003 Dave Pearson <davep@davep.org>

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.

"
  end

  # Get the arguments from the command line.
  begin
    GetoptLong.new().set_options(
                                 [ "--host",       "-h", GetoptLong::REQUIRED_ARGUMENT ],
                                 [ "--port",       "-p", GetoptLong::REQUIRED_ARGUMENT ],
                                 [ "--database",   "-d", GetoptLong::REQUIRED_ARGUMENT ],
                                 [ "--match",      "-m", GetoptLong::NO_ARGUMENT       ],
                                 [ "--strategy",   "-s", GetoptLong::REQUIRED_ARGUMENT ],
                                 [ "--dbs",        "-D", GetoptLong::NO_ARGUMENT       ],
                                 [ "--strats",     "-S", GetoptLong::NO_ARGUMENT       ],
                                 [ "--serverhelp", "-H", GetoptLong::NO_ARGUMENT       ],
                                 [ "--info",       "-i", GetoptLong::REQUIRED_ARGUMENT ],
                                 [ "--serverinfo", "-I", GetoptLong::NO_ARGUMENT       ],
                                 [ "--help",             GetoptLong::NO_ARGUMENT       ],
                                 [ "--licence",    "-L", GetoptLong::NO_ARGUMENT       ]
                                 ).each {|name, value| $params[ name.gsub( /^--/, "" ).intern ] = value }
  rescue GetoptLong::Error
    printHelp()
    exit 1
  end

  # Method for printing titles.
  def title( text, char )
    print( ( char * 76 ) + "\n#{text}\n" + ( char * 76 ) + "\n"  )
  end

  # Method for printing a list.
  def printList( name, list )
    title( "#{name} available on #{$params[ :host ]}:#{$params[ :port ]}", "=" )
    list.each {|item| print item.class == DictArrayItem ? "#{item.name} - #{item.description}\n" : item }
    print "\n"
  end

  # The need for help overrides everything else
  if $params[ :help ]
    printHelp()
    result = 0
  elsif $params[ :licence ]
    # As does the need for the legal mumbojumbo
    printLicence()
    result = 0
  else

    begin

      # With a dict client...
      DictClient.new( $params[ :host ], $params[ :port ] ).connect() do |dc|

        # User wants to see a list of databases?
        printList( "Databases", dc.databases ) if $params[ :dbs ]

        # User wants to see a list of strategies?
        printList( "Strategies", dc.strategies ) if $params[ :strats ]

        # User wants to see the server help?
        printList( "Server help", dc.help ) if $params[ :serverhelp ]

        # User wants to see help on a database?
        printList( "Info for #{$params[ :info ]}", dc.info( $params[ :info ] ) ) if $params[ :info ]

        # User wants to see server information?
        printList( "Server information", dc.server ) if $params[ :serverinfo ]

        # Look up any words left on the command line.
        ARGV.each do |word|

          # Did the user require a match?
          if $params[ :match ]

            # Yes, display matches.
            if ( matches = dc.match( word, $params[ :strategy ], $params[ :database ] ) ).empty?
              print "No matches found\n"
            else
              matches.each {|wm| print "Database: \"#{wm.name}\" Match: \"#{wm.description}\"\n" }
            end

          else

            # No, display definitions.
            if ( defs = dc.define( word, $params[ :database ] ) ).empty?
              print "No definitions found\n"
            else
              defs.each do |wd|
                wd.each {|line| print line + "\n" }
              end
            end

          end

        end

        # Disconnect.
        dc.disconnect()

      end

      # If we made it this far everything should have worked.
      result = 0

    rescue SocketError => e
      print "Error connecting to server: #{e}\n"
    rescue DictError => e
      print "Server error: #{e}\n"
    rescue /WIN/i.match( RUBY_PLATFORM ) ? Errno::E10061 : Errno::ECONNREFUSED => e
      print "Error connecting to server: #{e}\n"
    end

  end

  # Return the result to the caller.
  exit result

end

### dict.rb ends here

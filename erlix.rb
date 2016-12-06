require 'erlix'

COOKIE = 'cookie'
HOST = `hostname -s`.strip
NODE_NAME = 'ruby'
DST_NODE_NAME = 'elixir'
DST_NODE = "#{DST_NODE_NAME}@#{HOST}"
DST_PROC = 'ex_rb'

Erlix::Node.init(NODE_NAME, COOKIE)

connection = Erlix::Connection.new(DST_NODE)

connection.esend(
 DST_PROC,
 Erlix::Tuple.new([
   Erlix::Atom.new('register'),
   Erlix::Pid.new(connection)
 ])
)

#x = 0

#puts "t"

while true do
  message = connection.erecv

  resp =  Erlix::Int.new(
    message.message[2].to_i + message.message[3].to_i
  )

  connection.esend(
    "ex_rb_b", resp
  )
end

import net

var playerId: int = 2001 # ID must start with 2001 or Battlefield 2142 will NOT unlock the weapons

proc handleClient(client: Socket) =
  var data: string
  var sdata: string
  sdata = """\lc\1\challenge\\id\1\final\"""
  client.send(sdata)
  echo "GPCM - Send: ", sdata
  try:
    discard client.recv(data, 512, 1000)
  except TimeoutError:
    discard
  echo "GPCM - Received: ", data
  sdata = """\lc\2\sesskey\""" & $playerId & """\proof\\userid\""" & $playerId & """\profileid\""" & $playerId & """\uniquenick\\id\1\final\"""
  client.send(sdata)
  echo "GPCM - Send: ", sdata
  playerId.inc()
  while true:
    if client.recv(data, 512) == 0:
      echo "GPCM - Client disconented!"
      break
    else:
      echo "GPCM - RECEIVED: ", data
  # client.close()

proc run*() =
  var gpcmServer: Socket = newSocket()
  gpcmServer.setSockOpt(OptReuseAddr, true)
  gpcmServer.setSockOpt(OptReusePort, true)
  gpcmServer.bindAddr(Port(29900))
  gpcmServer.listen()

  var client: Socket
  var address: string
  var thread: Thread[Socket]
  echo "Gpcm server running and waiting for clients!"
  while true:
    client = newSocket()
    address = ""
    gpcmServer.acceptAddr(client, address)
    echo("feslAcceptLoopGPCM => Client connected from: ", address)
    thread.createThread(handleClient, client)
    # thread.joinThread()

when isMainModule:
  run()
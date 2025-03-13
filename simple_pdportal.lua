import 'pdportal'
	--pdportal.lua creates a class called "PdPortal"
	--instances of PdPortal act kindof like "playdate":
	--functions which are methods of PdPortal actually
	--interact with pdportal.net when connected.

--Creating a new class with simpler methods;
--We will use an instance of this class to send messages.
class('SimplePortal').extends(PdPortal)


function SimplePortal:init()
	--super.function(self) is key, as with most sub-classes
	SimplePortal.super.init(self)
	
	self.connected = false
	self.peerId = nil
	self.remotePeerId = nil

end

function SimplePortal:onConnect(portalVersion)
	self.connected = true
	self:sendCommand(PdPortal.PortalCommand.InitializePeer)
	
end

function SimplePortal:onDisconnect()
	self.connected = false
	self.peerId = nil --see below
	self.remotePeerId = nil
end

--self.peerID refers to the ID assigned BY pdportal TO local playdate
--onPeerOpen and onPeerClose refer to the moment this ID is assigned or removed

function SimplePortal:onPeerOpen(peerId)
	self.peerId = peerId
end

function SimplePortal:onPeerClose()
	self.peerId = nil
end

--The following functions occur when you 
--connect to a remote playdate (onPeerConnection)
--OR
--when a remote playdate connects to you (onPeerConnOpen).


function SimplePortal:onPeerConnection(remotePeerId)
	self.remotePeerId = remotePeerId
end

-- We connected to remote peer, they are host
function SimplePortal:onPeerConnOpen(remotePeerId)
	self.remotePeerId = remotePeerId
end

--But what about when a remote connection disconnects from you?
--Or what if a new remote connection connects when you already have a connection?
--These cases are not handled here, but a game should handle them with
--function PdPortal:onPeerConnClose(remotePeerId)
--and
--function PdPortal:onPeerClose()
--Did you know a host can be connected to by more than one playdate at once?


--This is the meat of PDPortal: sending and receiving data:
function SimplePortal:onPeerConnData(peerConnId, stringData)
	self:log('peerConnDataEcho!', peerConnId, stringData)
	local payload = json.decode(stringData)
	--note that data is received as a json file
	--it seems strings can also be sent, see below
	
	if peerConnId ~= self.remotePeerId then
		return
	end

	incomingMessage = payload["message"]
end

function SimplePortal:broadcast(payload)
	self:sendToPeerConn(self.remotePeerId, payload)
	--sendToPeerConn does not only transmit payload;
	--if payload is a table, sendToPeerConn converts it into
	--a string containing a json structure, i.e.:
	--[message = "hello"] will become '{"message":"hello"}'
end

local portal = SimplePortal()

return portal
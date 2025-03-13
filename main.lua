--[[
	This program demonstrates a simple PDPortal connection
	through which two Playdates can send the famous
	"hello world" message back and forth in various
	languages.
	
	This file, "main.lua," only contains the code for 
	displaying the status and received messages.
	
	All PDPortal related code is in simple_pdportal.lua and 
	implemented here using "import 'simple_pdportal'" and
	by adding "pdportalUpdate()" to playdate.update(). !!!!!!!!!
]]

portal = import 'simple_pdportal'

--initializing constants
local gfx <const> = playdate.graphics 
	--standard abbreviation that also slightly reduces
	--processing overhead
local mainFont <const> = gfx.font.new("fonts/Newsleak-Serif")
local boldFont <const> = gfx.font.new("fonts/Newsleak-Serif-Bold")
local messageTable <const> = import 'hello_world_in_50_languages'

--initializing variables
	
local say_status = "Visit PDPortal.net to connect (No Connection)"
	--Display-Text indicating connection status
local messageIndex = 1
local outgoingMessage = "Hello World (English)"
incomingMessage = "[No Message Recieved]"

function updateOutgoingMessage(index)
	outgoingMessage = 
	messageTable[messageIndex][2]..
	" ("..
	messageTable[messageIndex][1]..
	")"
end

function playdate.update()
	portal:update() --!!!!! Don't forget to include this.
	say_status = updateStatusText(portal) --this is overly complicated, probably simpler methods to achieve
	
	--drawing the screen
	gfx.clear()
	boldFont:drawText("Connection Status:", 5, 0)
	mainFont:drawText(say_status, 5, 20)
	boldFont:drawText("Message to Send (Use Crank to Select):", 5, 60)
	mainFont:drawText(outgoingMessage, 5, 80)
	boldFont:drawText("Most Recent Message Received:", 5, 120)
	mainFont:drawText(incomingMessage, 5, 140)
end

function playdate.cranked(change)
	--cycles through the languages based on crank input
	if change > 0 then
		messageIndex += 1
		if messageIndex > #messageTable then
			messageIndex = 1
		end
		
	elseif change < 0 then
		messageIndex -= 1
		
		if messageIndex < 1 then
			messageIndex = #messageTable
		end
	end
	
	
		
	updateOutgoingMessage(messageIndex)
end

function playdate.AButtonDown()
	payload = {message = outgoingMessage}
	portal:broadcast(payload)
end

function updateStatusText(self)
	local statusMessage = ""
	if self.connected == true then
		if self.peerId == nil then --connected but no ID assigned, an error
			statusMessage = "connection error, restart program"
		else
			if self.remotePeerId == nil then --waiting for Peer
				statusMessage = "Connected to PDPortal as "..self.peerId..",\nwaiting for remote connection."
			else--fully connected to Playdate with this ID!
				statusMessage = 'Connected to Playdate with ID '..self.remotePeerId..'!'
			end
		end
	else --if not connected
		statusMessage = "Visit PDPortal.net to connect (No Connection)"
	end
	
	return statusMessage
end
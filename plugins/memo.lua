--[[
	Memo System
]]

PLUGIN.Name = "Memo System"

local json = require "json"

--memo handling
--todo: Redo time formatting to allow for an easy sorted list
do
	local memos, users

	function Load()
		local f = io.open("memosystem.json", "r")
		if f then
			local memosystem = json.decode(f:read("*a"))
			memos, users = memosystem.memos, memosystem.users
			f:close()
		else
			memos, users = {}, {}
		end
	end

	function Unload()
		local data = json.encode({memos = memos, users = users})
		local f = assert(io.open("memosystem.json", "w"))
		f:write(data)
		f:close()
	end

	--helpers
	local function formatMemo(m)
		return ("[%s] \"%s\" from %s: \"%s\""):format(m.time, m.name, m.author, m.text)
	end

	local function verifyMemoName(text)
		for c in text:gmatch(".") do
			local b = c:byte()
			if b < 32 or b > 126 then
				return false
			end
		end

		return true
	end

	Hook "OnJoin"
	{
		function(user, channel)
			if user.nick == CONFIG.nick then return end
			
			local u = users[user.nick]
			if u then
				local pending = #u.pending
				if pending > 0 then
					self:sendChat(user.nick, ("You have %i new memo(s)."):format(#u.pending))
					for k, name in ipairs(u.pending) do
						local m = memos[name]
						if m then
							self:sendChat(user.nick, formatMemo(m))
						end
						u.pending[k] = nil
					end
				end
			else
				self:sendChat(channel, ("Welcome to %s, %s."):format(channel, user.nick))
			end
		end
	}

	Command "memo_subscribe" "subscribe"
	{
		function()
			local usr = users[user.nick]
			if usr then
				reply("You are already subscribing to memos.")
			else
				users[user.nick] = {pending = {}}
				reply("Subscribed to memos. Run !memo_list to list previous memos.")
			end
		end
	}

	Command "memo_unsubscribe" "unsubscribe"
	{
		function()
			users[user.nick] = nil
			reply("Done.")
		end
	}

	Command "memo_subscribers" "subscribers"
	{
		function()
			send{method = "notice", target = user.nick, message = "Subscriber list:"}
			for nick, v in pairs(users) do
				send{method = "notice", target = user.nick, message = nick}
			end
		end
	}
	
	Command "memo_add" "memo" "add"
	{
		help = "Add new memo";

		expectedArgs = "^(%S+) (.+)$";
		
		function(name, text)
			if not channels[channel] then
				reply("This command must be initiated from a channel.")
				return
			end
			
			if not users[user.nick] then
				reply("You need to be on the subscription list to add a memo.")
				return
			end

			local existing = memos[name]
			if existing and existing.author ~= user.nick then
				reply("You can't overwrite \"%s\" because you didn't write it.", existing.name)
				return
			end

			if not verifyMemoName(name) then
				reply("Memo name contains invalid characters.")
				return
			end
			
			local m = {
				name = name;
				text = text;
				time = os.date();
				author = user.nick;
			}

			local userList = channels[channel].users
			for nick, v in pairs(users) do
				if userList[nick] then
					send{target = nick, message = formatMemo(m)}
				else
					table.insert(v.pending, name)
				end
			end
			
			memos[name] = m
			reply("Added memo.")
		end
	}

	Command "memo_remove" "remove"
	{
		help = "Remove a memo";
		admin = true;
		
		function(name)
			local m = memos[name]
			if m then
				memos[name] = nil
				reply("Removed memo \"%s\".", name)
			else
				reply("No memo by that name.")
			end
		end
	}

	Command "memo_remove_user" "remove_user"
	{
		help = "Remove all memos added by a specific user.";
		admin = true;

		function(nick)
			local i = 0
			for name, m in pairs(memos) do
				if nick == m.author then
					memos[name] = nil
					i = i + 1
				end
			end
			reply("Removed all memos (%i) by \"%s\".", i, nick)
		end
	}

	Command "memo_list" "list"
	{
		help = "List memos";
		
		function(search)
			search = (search or ""):lower()

			local found = false
			for name, m in pairs(memos) do
				if name:lower():find(search) or m.author:lower():find(search) then
					found = true
					send{method = "notice", target = user.nick, message = formatMemo(m)}
				end
			end

			if not found then
				reply("No matches.")
			end
		end
	}

	Command "memo_help"
	{
		help = "Lists help for memo system.";

		helpText = [[
Use !subscribe to subscribe to memos, then "!memo <name> <text...>" to add a new memo. 
Online subscribers are immediately PM'd the memo. Subscribers not currently in the channel will be messaged as soon as they join the channel. 
You can overwrite your own memos by adding a new one with the same name. 
Finally, you can use "!list <search text...>" to search for a memo either by name or author. Leave the search text blank to list all memos.]];

		function()
			send{method = "notice", target = user.nick, message = helpText}
		end
	}
end

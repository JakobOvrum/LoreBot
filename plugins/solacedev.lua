--[[
	LoreBot
	#solace-dev channel bot
]]

PLUGIN.Name = "LoreBot"

function Load(bot)
	bot:hook("OnJoin", function(user, channel)
		bot:sendChat("jA_cOp", "%s joined %s", user, channel)
	end)
end

--memo handling
--todo: Redo time formatting to allow for an easy sorted list
do
	local memos = {}
	local users = {}

	Command "memo_subscribe" "subscribe"
	{
		function()
			local usr = users[user.nick]
			if usr then
				reply("You are already subscribing to memos.")
			else
				users[user.nick] = true
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
	
	Command "memo_add" "memo"
	{
		help = "Add new memo";

		expectedArgs = "^(%S+) (.+)$";
		
		function(name, text)
			local m = {
				pending = {};
				text = text;
				time = os.date();
				author = user.nick;
			}
			
			for k,v in pairs(users) do
				m.pending[k] = v
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
				reply("Removed \"%s\".", name)
			else
				reply("No memo by that name.")
			end
		end
	}

	Command "memo_list" "list"
	{
		help = "List memos";
		
		function(search)
			search = (search or ""):lower()

			for name, m in pairs(memos) do
				if name:lower():find(search) then
					reply("[%s] \"%s\" from %s: \"%s\"", m.time, name, m.author, m.text)
				end
			end
		end
	}
end

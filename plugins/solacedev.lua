--[[
	LoreBot
	#solace-dev channel bot
]]

PLUGIN.Name = "LoreBot"

--memo handling
do
	local memos = {}
	Command "memo_add" "memo"
	{	
		expectedArgs = "^(%S+) (.+)$";
		
		function(name, text)
			memos[name] = text
			reply("Added memo.")
		end
	}

	Command "memo_list" "list"
	{
		function()
			for name, text in pairs(memos) do
				reply("%s: \"%s\"", name, text)
			end
		end
	}
end

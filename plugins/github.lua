--[[
	Github Repository Tracker
]]

PLUGIN.Name = "Github Repository Tracker"

local gh = require "github"

do
	local repoInfo = CONFIG.github_repository
	local repo = gh.new(repoInfo.user, repoInfo.name)
	local repo_channel = repoInfo.channel
	local updateInterval = repoInfo.interval

	local function commitLink(c)
		return ("http://github.com/%s/%s/commit/%s"):format(repo.owner, repo.name, c.id)
	end

	local function formatCommit(c)
		return ("New commit by %s - %s (%s)"):format(color(c.author, "red"), c.message, color(commitLink(c), "blue"))
	end

	Hook "OnJoin"
	{
		function(user, channel)
			if user.nick == CONFIG.nick then
				self:sendChat(channel, ("Tracking repository %s/%s"):format(repo.owner, repo.name))
			end
		end
	}

	Hook "Think"
	{
		lastUpdate = os.time();
		
		function()
			local now = os.time()
			if now >= lastUpdate + updateInterval then
				lastUpdate = now

				local changes = repo:getChanges()
				if changes then
					for k, commit in ipairs(changes) do
						self:sendChat(repo_channel, formatCommit(commit))
					end
				end
			end
		end
	}
end

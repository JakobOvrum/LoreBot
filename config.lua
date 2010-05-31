nick = "LoreBot"
username = "lua"
realname = "Solace: Star Requiem"

server = "irc.freenode.net"

channels
{
	"#lorebot";
}

plugin_dir = "plugins"

--on_connect callback example for authenticating to services before joining channels
local auth_service = "AuthServ" -- "AuthServ@Services.GameSurge.net" for GameSurge
local auth_user = "replaceme"
local auth_pass = "replaceme"

function on_connect(connection)
	--Uncomment this to enable automatic account authentication
	--connection:sendChat(auth_service, table.concat({"AUTH", auth_user, auth_pass}, " "))
end

--Uncomment this if you're on a network without account services.
--password = "replaceme"

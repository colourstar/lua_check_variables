is_server = false
if is_server then
	require "config_server"
else
	require "config_client"
end

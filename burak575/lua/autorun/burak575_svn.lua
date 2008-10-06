//Deletes the cached spawnlists for PHX in order to keep them up to date.
function burak575_SVN_Init()
	if CLIENT then
		if file.Exists("../settings/spawnlist/burak575 props.txt") then
			file.Delete( "../settings/spawnlist/burak575 props.txt" )
		end
	end
end
hook.Add( "InitPostEntity", "burak575 Cleanup", burak575_SVN_Init );
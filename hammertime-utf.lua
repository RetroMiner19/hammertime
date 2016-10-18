require "string"
nbt = loadfile "nbt.lua"
hammerver = 0.6
execd = 0

if nbt == nil then print "Failed to load NBT.lua" end

print("MetoolDaddy's Hammertime Panel")
print("Running v"..hammerver)
dofile("hammertime.conf")
votebalance = 0
--This started out as MA port so don't judge me
target = ""
word = "a dummy string, hey"
input = {} --Dummy table, hey
hasvoted = {} --For callvote
warnlevel = {}
dofile("perms.lua") --Loading various permissions
function inc(var,amt)
if amt then return var + amt else return var + 1 end
end

function parse()
	if execd == 0 then
		input = {}
		tid = -3
		ninput = bash("tail -1 logs/latest.log")
		if ninput == oinput then return nil end
		oinput = ninput --Failsafe
		for word in string.gmatch(ninput,"%S+") do
			tid = inc(tid)
			if tid > 0 then input[tid] = word end
		end
	end
end

function bash(cmd)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end
function sleep(t)
	while n < t do n=inc(n) end
	n=0
end


function exec(cmd,t) --All it does is prepare a minecrafty input for bash function
	print(cmd)
	bash("screen -S " .. session .. " -X stuff '" .. cmd .. "\\n'")
	return nil
end

--Quality of life things
function command() return input[2] end
function player()
	if input[1] == nil then input[1] = "Failsafe" end
	input[1] = string.gsub(input[1],"<","")
	input[1] = string.gsub(input[1],">","")
	input[1] = string.gsub(input[1],"§[a-f0-9]","")
	input[1] = string.gsub(input[1],"§r","")--Yeah ;-;
 	return input[1]
end
function argument(arg) return input[arg+2] end

session = bash("screen -ls | grep " .. server_name .. " | awk '{print $1}'") --Getting screen session name


math.randomseed( os.time() )
caps = 0
lcase = 0
halted = 1
voted = {}
print("Session is " .. session)
n = 0




while "True" do --------------------------------------------- OH GAWD FINALLY THE INFINITE LOOP SECTION
sleep(100000)
execd = 0 --idk
parse()


--Vhguide
if command() == "vhguide" then
	if argument(1) == "help" then exec("/msg " .. player() .. " Available commands : Shootme, Book, Callvote (permitted players only), Escrow ") end
	if argument(1) == "book" then exec("/give " .. player() .. " book 1 0" ) end
	if argument(1) == "escrow" then exec("/msg " .. player() .. " Escrow message placeholder") end
	if argument(1) == "callvote" then initvote = 1 end
	if argument(1) == "apt-get" and argument(2) == "moo" then exec("/summon Cow 0 300 0") end
	if argument(1) == "shootme" then exec("/kill " .. player()) end
	if argument(1) == "about" then exec("/say Hammertime Panel v" .. hammerver) exec("/say Written in Lua by MetoolDaddy") exec("/say Have you apt-get moo today?") end
	if argument(1) == "vote" then--for voteban
		if hasvoted[player()] ~= nil then exec("/msg " .. player() .. " You have already voted") else
			if argument(2) == "yes" then votebalance=votebalance + 1 hasvoted[player()] = 1 exec("/say " .. player() .. " voted UP (" .. votebalance .. ")") end
			if argument(2) == "no" then votebalance=votebalance - 1 hasvoted[player()] = 1 exec("/say " .. player() .. " voted DOWN (" .. votebalance .. ")") end
			if argument(2) == "fail" and callvoteperm[player()] == 2 then votebalance=-9001 exec("/say " .. player() .. " voted VERY DOWN (" .. votebalance .. ")") end
		end
	end
end


--Movement messages (fly, speed, etc)
if enable_movement_messages > 0 then
	flyingman = bash("tail -3 logs/latest.log | grep floating | awk '{print $4}'")
	if flyingman ~= "" then exec("/msg @a[tag=servernotice] " .. flyingman .. " was kicked for flying!") sleep(1000000) end
	if enable_movement_messages > 1 then
		if command() == "moved" and argument(1) == "wrongly!" then exec("/msg @a[tag=servernotice] " .. player() .. " is moving suspiciously") sleep(100000) end
		if command() == "moved" and argument(1) == "too" then exec("/msg @a[tag=servernotice] " .. player() .. " moved too fast") end
	end
end

--Voteban
if initvote == 1 and votetime == nil then
	initvote = 0
	votebalance = 0
	if argument(2) == nil then
		exec("/msg " .. player() .. " Incorrect syntax - missing target name")
	elseif callvoteperm[player()] ~= nil then
			hasvoted = {}
			starttime = os.time()
			target = argument(2)
			if argument(3) == "ban" then
				votetime = 120 exec("/say Vote ban brought up for " .. target)
				banvote = 1
			else
				votetime = 20 exec("/say Vote kick brought up for " .. target)
				banvote = 0
			end
			exec("/say Vote with §bvhguide §bvote §byes/no")
		else exec("/say Insufficient permissions")
	end

end
if votetime then
--print(os.time() .. " " .. starttime+votetime)
if os.time() > starttime + votetime then votetime = nil
	hasvoted = {}
	if votebalance > 0 then
	exec("/say Vote passed")
	if banvote == 1 then exec("/say Banning " .. target) exec("/ban " .. target .. " Voted off. Appeal at forum.vanillahigh.net") else exec("/say Kicking " .. target) exec("/kick " .. target .. " You have been voted off. Go chill down or whatever.") end
	else
	exec("/say Vote failed")
	end
	votebalance = 0
end
end

for letter in string.gmatch(ninput,"%u") do if letter ~= "" then caps = caps + 1 end end
for letter in string.gmatch(ninput,"%l") do if letter ~= "" then lcase = lcase + 1 end end
if caps > lcase and player() ~= "Failsafe" then
exec("say Less caps, " .. player())
if warnlevel[player()] == nil then warnlevel[player()] = 0 end
warnlevel[player()] = warnlevel[player()] + 1

end
lcase = -12
caps = 0

end; --for while true

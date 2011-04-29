declare("metaaim", {})

-- change the refresh rate here
metaaim.delay = 20

-- on by default
metaaim.runMA = true

metaaim.distance = 80

metaaim.timer = Timer()

-- init to false - because I usually leave it off
metaaim.aastatus = false
gkinterface.GKProcessCommand("set autoaim 0")

function metaaim.start()
   metaaim.runMA = true
   metaaim.mainloop()
end

function metaaim.stop()
   metaaim.runMA = false
end

function metaaim.mainloop()
   if metaaim.runMA == true then
      local dist = GetTargetDistance()
      if dist and dist < metaaim.distance and metaaim.aastatus == false then
         gkinterface.GKProcessCommand("set autoaim 1")
         metaaim.aastatus = true
      elseif dist and dist >= metaaim.distance and metaaim.aastatus == true then
         gkinterface.GKProcessCommand("set autoaim 0")
         metaaim.aastatus = false
      end
      metaaim.timer:SetTimeout(metaaim.delay, function () metaaim.mainloop() end)
   end
end

function metaaim.cmd(_, args)
   local arg = string.lower(args[1])
   if not args then
      print("/metaaim on, /metaaim off, /metaaim (distance)")
   elseif arg == 'on' then
      metaaim.runMA = true
      metaaim.start()
   elseif arg == 'off' then
      metaaim.runMA = false
   else
      metaaim.distance = tonumber(arg)
   end
end

RegisterEvent(metaaim.start, "PLAYER_ENTERED_GAME")
RegisterEvent(metaaim.stop, "PLAYER_LOGGED_OUT")
RegisterUserCommand('metaaim', metaaim.cmd)

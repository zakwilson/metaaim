declare("metaaim", {})

-- change the refresh rate here
metaaim.delay = 20

-- on by default
metaaim.runMA = true

metaaim.default_distance = 80

metaaim.distance = metaaim.default_distance

metaaim.timer = Timer()

-- init to false - because I usually leave it off
metaaim.aastatus = false
gkinterface.GKProcessCommand("set autoaim 0")

weapons = {
   ["Gauss Cannon"] = 120,
   ["Gauss Cannon MkII"] = 120,
   ["Gauss Cannon MkIII"] = 120,
   ["Plasma Eliminator"] = 120,
   ["Plasma Devastator"] = 120,
   ["Plasma Annihilator"] = 140,
   ["Gatling Turret"] = 200,
   ["Rail Gun"] = 0,
   ["Rail Gun MkII"] = 0,
   ["Rail Gun MkIII"] = 0,
   ["Rail Gun Advanced"] = 0
}

function metaaim.get_primary_weapon()
   -- This seems to be broken, as it gives the same result for every group ID.
   -- Here, we don't care because it happens to give the result for the first
   -- trigger, which is what we want.
   local port = next(GetActiveShipWeaponGroup(0))
   local weapon_id = GetActiveShipItemIDAtPort(port)
   local weapon_name = GetInventoryItemName(weapon_id)
   return weapon_name
end

function metaaim.autoset()
   local weapon = metaaim.get_primary_weapon()
   local distance = weapons[weapon] or metaaim.default_distance
   metaaim.distance = distance
   print("MetaAim distance: " .. metaaim.distance)
end

function metaaim.start()
   metaaim.runMA = true
   metaaim.mainloop()
end

function metaaim.stop()
   metaaim.runMA = false
end

function metaaim.inc()
   metaaim.distance = metaaim.distance + 10
   print("MetaAim distance: " .. metaaim.distance)
end

function metaaim.dec()
   metaaim.distance = metaaim.distance - 10
   print("MetaAim distance: " .. metaaim.distance)
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
RegisterEvent(metaaim.autoset, "LEAVING_STATION")
RegisterUserCommand('metaaim', metaaim.cmd)
RegisterUserCommand('metaaiminc', metaaim.inc)
RegisterUserCommand('metaaimdec', metaaim.dec)
ESX = nil
local distancecheck = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)





Citizen.CreateThread(function()

	while true do
		Citizen.Wait(100)
		for k,v in pairs (Config.NPCS) do
			local id = GetEntityCoords(PlayerPedId())
			local dist = #(id - v.coords)
			if dist < 10 and distancecheck == false then
				distancecheck = true
				print('not spawned')
				TriggerEvent('brinn_paycheck:SpawnPed',v.model, v.coords, v.heading, v.animDict, v.animName)
				print('spawned')
				Wait(5000)
			end
			if dist >= 10 and dist <= 10 + 1 then
				distancecheck = false
				DeletePed(ped)
			end
		end
	end
end)

RegisterNetEvent('brinn_paycheck:SpawnPed')
AddEventHandler('brinn_paycheck:SpawnPed',function(model, coords, heading, animDict, animName)
	if distancecheck == false then
		RequestModel(GetHashKey(model))
		while not HasModelLoaded(GetHashKey(model)) do
			Citizen.Wait(1)
		end
		ped = CreatePed(5, GetHashKey(model), coords, heading, false, false)
		FreezeEntityPosition(ped, true) 
		SetEntityInvincible(ped, true) 
		SetBlockingOfNonTemporaryEvents(ped, true) 
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
		TaskPlayAnim(ped, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end
end)



Citizen.CreateThread(function()
	local bossMech = {
		`cs_bankman`,
	}
	exports['bt-target']:AddTargetModel(bossMech, {
		options = {
			{
				event = "brinn_paycheck:Menu",
				icon = "fas fa-car",
				label = "Collect salary",
			},
			
		},
		job = {"all"},
		distance = 3.5
	})
end)


RegisterNetEvent('brinn_paycheck:Menu')
AddEventHandler('brinn_paycheck:Menu',function()
	OpenPaycheckMenu()
end)


function OpenPaycheckMenu()
	local elements = {
		{label = '&nbsp;&nbsp;<span style="color:#13ea13 ;"> Withdraw All </span>', value = 'withdraw_all'},
		{label = '&nbsp;&nbsp;<span style="color:#13ea13 ;"> Withdraw an amount </span>', value = 'withdraw_quantity'},
		{label = '&nbsp;&nbsp;<span style="color:#EA1313;"> Close</span>' , value = 'Salir'},
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paycheck_actions', {
				title    = 'City Hall',
				align    = 'top-left',
				elements = elements
			}, function(data, menu)
					if data.current.value == 'withdraw_all' then
						exports.rprogress:Custom({
							Duration = 5000,
							Label = "Cashing out...",
							Animation = {
								scenario = "WORLD_HUMAN_CLIPBOARD", 
								animationDictionary = "idle_a", 
							},
							DisableControls = {
								Mouse = false,
								Player = true,
								Vehicle = true
							}
						})
						Citizen.Wait(5000)
						TriggerServerEvent('brinn_paycheck:Payout')
						menu.close()
					elseif data.current.value == 'withdraw_quantity'then
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_quantity_count', {
							title = 'Quantity'
						}, function(data2, menu2)
							local count = tonumber(data2.value)
			
							if count == nil then
								ESX.ShowNotification('Invalid Quantity')
							else
								menu2.close()
								menu.close()
								exports.rprogress:Custom({
									Duration = 5000,
									Label = "Cashing out...",
									Animation = {
										scenario = "WORLD_HUMAN_CLIPBOARD", 
										animationDictionary = "idle_a", 
									},
									DisableControls = {
										Mouse = false,
										Player = true,
										Vehicle = true
									}
								})
								Citizen.Wait(5000)
								TriggerServerEvent('brinn_paycheck:withdrawMoney', count)
							end
						end)
					elseif data.current.value == 'Salir' then
						menu.close()
					end
	end, function(data, menu)
		menu.close()
	end)
end




      
Citizen.CreateThread(function()

    for _, info in pairs(Config.Blips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 0.6)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)